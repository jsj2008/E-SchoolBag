//
//  ESBSocketManager.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/7.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBSocketManager.h"

#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#import "ESBMessageModel.h"
#import "ESBDataFramer.h"

@interface ESBSocketManager ()



@end



@implementation ESBSocketManager


#pragma mark - 单例模式
static id _instance;

+(instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}


#pragma mark - 懒加载
- (NSMutableArray *)connectionList
{
    if (_connectionList == nil) {
        _connectionList = [NSMutableArray array];
    }
    return _connectionList;
}

- (NSMutableDictionary *)clntSockCachePool
{
    if (_clntSockCachePool == nil) {
        _clntSockCachePool = [NSMutableDictionary dictionary];
    }
    return _clntSockCachePool;
}



#pragma mark - socket相关
/**给定端口，监听*/
- (void)listenMainPort:(char *)port result:(void(^)(BOOL success))result log:(void(^)(NSString *logStr))log
{
    //告诉系统我们需要哪种类型的地址
    struct addrinfo addrCritrial;
    memset(&addrCritrial, 0, sizeof(addrCritrial));
    addrCritrial.ai_family = AF_UNSPEC;
    addrCritrial.ai_protocol = IPPROTO_TCP;
    addrCritrial.ai_socktype = SOCK_STREAM;
    addrCritrial.ai_flags = AI_PASSIVE;
    
    //获取服务器相关信息
    struct addrinfo *servAddr;
    int rtnVal = getaddrinfo(NULL, port, &addrCritrial, &servAddr);
    if (rtnVal != 0) {
        NSString *errLog = [NSString stringWithFormat:@"getaddrinfo() error -- %s",gai_strerror(rtnVal)];
        log?log(errLog):nil;
        result?result(NO):nil;
        return;
    }
    
    //创建服务器套接字
    int servSock = socket(servAddr->ai_family, servAddr->ai_socktype, servAddr->ai_protocol);
    if (servSock < 0) {
        log?log(@"socket() failed"):nil;
        result?result(NO):nil;
        return;
    }
    log?log(@"socket() success"):nil;
    
    //绑定服务器套接字
    if (bind(servSock, servAddr->ai_addr, servAddr->ai_addrlen) < 0) {
        log?log(@"bind() failed"):nil;
        result?result(NO):nil;
        return;
    }
    log?log(@"bind() success"):nil;
    
    //listen
    if (listen(servSock, ESBListenMainQueueCount) < 0) {
        log?log(@"listen() failed"):nil;
        result?result(NO):nil;
        return;
    }
    log?log(@"listen() success"):nil;
    
    //保存当前的服务器的监听套接字
    self.servSock = servSock;
    
    //释放资源
    freeaddrinfo(servAddr);
    
    //返回
    result?result(YES):nil;
}

/**循环接收客户端的连接*/
- (void)acceptClientConnectionWithHandle:(void(^)(int clntSock, struct sockaddr_storage clntAddr, socklen_t clntAddrLen))handle log:(void(^)(NSString *logStr))log
{
    //接收客户端的连接
    while (1) {
        //--1 客户端信息
        struct sockaddr_storage clntAddr;
        socklen_t clntAddrLen = sizeof(clntAddr);
        //--2 接收连接
        int clntSock = accept(self.servSock, (struct sockaddr *)&clntAddr, &clntAddrLen);
        if (clntSock < 0) {
            log?log(@"客户端连接失败"):nil;
            continue;
        }
        //--3 回调
        handle?handle(clntSock,clntAddr,clntAddrLen):nil;
    }
}

/**根据sockaddr_storeage解析地址信息*/
- (void)parseAddressWithSockAddr:(struct sockaddr_storage)sockAddr result:(void(^)(BOOL success, BOOL ipv4, NSString *clintIP, in_port_t port))result
{
    //IPV4
    if (sockAddr.ss_family == AF_INET) {
        struct sockaddr_in *clntAddr_in4 = (struct sockaddr_in *)&sockAddr;
        const char *printIP = inet_ntoa(clntAddr_in4->sin_addr);
        in_port_t port = ntohs(clntAddr_in4->sin_port);
        NSString *clintIP = [NSString stringWithUTF8String:printIP];
        result?result(YES, YES, clintIP, port):nil;
    }
    //IPV6
    else if (sockAddr.ss_family == AF_INET6){
        result?result(YES, NO, @"待解析IP", -1):nil;
    }
    //Other
    else{
        result?result(NO, YES, nil, -1):nil;
    }
}

/**从指定的连接socket循环接收数据*/
- (void)receivedMessageFromSocket:(int)socket result:(void(^)(ESBMessageModel *message))result log:(void(^)(NSString *logStr))log
{
    //创建一个输入输出流
    FILE *channel = fdopen(socket, "r+");
    if (channel == nil) {
        NSString *logStr = [NSString stringWithFormat:@"socket id = %d 创建file流失败 fdopen() failed",socket];
        log?log(logStr):nil;
        return;
    }
    
    //循环接收客户端的数据
    char inBuf[ESBBufferLength];    //用来存储接收到的二进制数据
    while (1) {
        
        //从指定流中读取数据，并成帧
        size_t recvBytes = FrameLengthRecv(channel, inBuf, ESBBufferLength);
        
        //判断
        if (recvBytes == -1) {
            NSString *logStr = [NSString stringWithFormat:@"socket id = %d FrameLengthRecv() failed (成帧错误)",socket];
            log?log(logStr):nil;
            break;
        }
        
        //解码
        ESBMessageModel *message = [ESBMessageModel decodeMessageWithBuffer:inBuf length:recvBytes];
        
        //回调
        result?result(message):nil;
        
    }

}

/**给指定的连接socket发送数据*/
- (void)sendMessageToSocket:(int)socket message:(ESBMessageModel *)message result:(void(^)(BOOL success, NSString *errLog))result
{
    //包装输入输出流
    FILE *channel = fdopen(socket, "r+");
    
    //编码
    size_t msgLength;
    void *buffer = [ESBMessageModel encodeMessage:message length:&msgLength];
    
    //发送
    size_t msgSend = FrameLengthSend(buffer, msgLength, channel);
    
    //判断
    if (msgSend == -1) {
        NSString *errLog = [NSString stringWithFormat:@"给 socket id = %d 发送消息失败（sendMessageToSocket failed, 定长成帧失败）",socket];
        result?result(NO,errLog):nil;
    }else if (msgSend != msgLength){
        NSString *errLog = [NSString stringWithFormat:@"给 socket id = %d 发送消息异常（sendMessageToSocket warning, 发送数据与拟发送数据长度不匹配）",socket];
        result?result(NO,errLog):nil;
    }else{
        result?result(YES,nil):nil;
    }
}


@end





































