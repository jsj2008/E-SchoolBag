//
//  ESBTcpSocket.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/2.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBTcpSocket.h"
#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <netinet/in.h>

/**给定地址和端口号，创建处于监听状态下的socket*/
int SetupTCPServerSocket(const char *server, const char *service);

/**获取客户端的连接*/
int AcceptClientConnection(int servSock);


@interface ESBTcpSocket ()

/**当前socket类型*/
@property(nonatomic,assign) ESBSockType sockType;

/**服务器端监听套接字*/
@property(nonatomic,assign) int servSock;




@end



@implementation ESBTcpSocket



- (instancetype)initWithType:(ESBSockType )type host:(NSString *)host port:(NSString *)port delegate:(id<ESBTcpSocketDelegate>)delegate
{
    if (self = [super init]) {
        
        //保存socket类型及代理
        self.sockType = type;
        self.delegate = delegate;
        
        //转换参数类型
        const char *server = [host UTF8String];
        const char *service = [port UTF8String];
        
        //创建socket
        if (type == ESBSockTypeServer) {
            //如果是需要创建服务器socket
            self.servSock = SetupTCPServerSocket(server, service);
        }else{
            //创建客户端socket
            
        }
        
    }
    return self;
}

- (int)accpetClientConnection
{
    int clntSock = AcceptClientConnection(self.servSock);
    
    return clntSock;
}



@end





/**
 给定地址和端口号创建TCP服务器端socket
 @param server 服务器地址（通常为NULL）
 @param service 服务或者端口
 @return 处于监听状态下的socket描述符
 */
int SetupTCPServerSocket(const char *server, const char *service)
{
    
    //告诉系统我们需要哪种类型的地址
    struct addrinfo addrCritrial;
    memset(&addrCritrial, 0, sizeof(addrCritrial));
    addrCritrial.ai_family = AF_UNSPEC;
    addrCritrial.ai_socktype = SOCK_STREAM;
    addrCritrial.ai_protocol = IPPROTO_TCP;
    addrCritrial.ai_flags = AI_PASSIVE;
    
    //获取服务器IP地址
    struct addrinfo *servAddr;
    int rtnVal = getaddrinfo(server, service, &addrCritrial, &servAddr);
    if (rtnVal != 0) {
        NSLog(@"getaddrinfo() failed -- error = %s",gai_strerror(rtnVal));
        return -1;
    }
    
    //创建socket
    int sock = -1;
    sock = socket(servAddr->ai_family, servAddr->ai_socktype, servAddr->ai_protocol);
    if (sock < 0) {
        NSLog(@"socket() failed");
        return -1;
    }
    
    //bind
    if (bind(sock, servAddr->ai_addr, servAddr->ai_addrlen) < 0) {
        NSLog(@"bind() failed -- error = %d",errno);
       
        return -1;
    }
    
    //listen
    if (listen(sock, BACKUPLOG) < 0) {
        NSLog(@"listen() failed -- %d",errno);
        return -1;
    }
    
    return sock;
}


/**获取客户端的连接*/
int AcceptClientConnection(int servSock)
{
    //定义保存客户端信息的参数
    struct sockaddr_storage clntAddr;
    socklen_t clntAddrLen = sizeof(clntAddr);
    
    //获取客户端的连接
    int clntSock = accept(servSock, (struct sockaddr *)&clntAddr, &clntAddrLen);
    if (clntSock < 0) {
        NSLog(@"accpet() failed -- %d",errno);
        
        return -1;
    }
    
    //打印信息
    NSLog(@"========当前有客户端连接============");
    
    NSLog(@"=================================");
    
    return clntSock;
}























