//
//  ViewController.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBHomeViewController.h"
#import "ESBConnectionSocketModel.h"

#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#import "ESBDataFramer.h"
#import "ESBDataCoder.h"





@interface ESBHomeViewController ()

#pragma mark - 控件相关属性
@property (unsafe_unretained) IBOutlet NSTextView *textView;

#pragma mark - 线程相关属性
/**主监听线程*/
@property(nonatomic,strong) NSThread *listenThread;
/**客户端连接列表*/
@property(nonatomic,strong) NSMutableArray *connectionList;

@end


@implementation ESBHomeViewController
{
#pragma mark - socket成员变量
    int _servSock;
    
}

#pragma mark - 懒加载
- (NSMutableArray *)connectionList
{
    if (_connectionList == nil) {
        _connectionList = [NSMutableArray array];
    }
    return _connectionList;
}


#pragma mark - 系统回调方法

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置UI
    [self setupUI];
    
    //初始化
    [self initialSystem];
    
    //程序主端口监听
    [self listenMainPort];
}


#pragma mark - 设置UI
- (void)setupUI
{
    //设置textView为只读
    self.textView.editable = NO;
}

/**初始化*/
- (void)initialSystem
{
    //初始化成员变量
    _servSock = -1;
    
    //初始化日志
    [self.textView addLogText:@"程序开始启动"];
}


#pragma mark - Socket相关
/**监听主端口*/
- (void)listenMainPort
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
    int rtnVal = getaddrinfo(NULL, ESBListenMainPort, &addrCritrial, &servAddr);
    if (rtnVal != 0) {
        NSString *error = [NSString stringWithFormat:@"getaddrinfo() error -- %s",gai_strerror(rtnVal)];
        [self.textView dieLogWithText:error];
        return;
    }
    
    //创建服务器套接字
    int servSock = socket(servAddr->ai_family, servAddr->ai_socktype, servAddr->ai_protocol);
    if (servSock < 0) {
        [self.textView dieLogWithText:@"socket() failed"];
        return;
    }
    [self.textView addLogText:@"socket() success"];
    
    //绑定服务器套接字
    if (bind(servSock, servAddr->ai_addr, servAddr->ai_addrlen) < 0) {
        [self.textView dieLogWithText:@"bind() failed"];
        return;
    }
    [self.textView addLogText:@"bind() success"];
    
    //listen
    if (listen(servSock, ESBListenMainQueueCount) < 0) {
       [self.textView dieLogWithText:@"listen() failed"];
        return;
    }
    [self.textView addLogText:@"listen() success"];
    
    //保存当前的服务器的监听套接字
    _servSock = servSock;
    
    //释放资源
    freeaddrinfo(servAddr);
    
    //开启常驻子线程，用于接收客户端的连接
    [self acceptClientConnection];
}

/**开启子线程，用于接收客户端的连接*/
- (void)acceptClientConnection
{
    //开启子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        //保存当前的主监听线程
        self.listenThread = [NSThread currentThread];
        
        //接收客户端的连接
        while (1) {
            //--1 客户端信息
            struct sockaddr_storage clntAddr;
            socklen_t clntAddrLen = sizeof(clntAddr);
            //--2 接收连接
            int clntSock = accept(_servSock, (struct sockaddr *)&clntAddr, &clntAddrLen);
            if (clntSock < 0) {
                //回主线程，打印日志
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.textView addLogText:@"客户端连接失败"];
                });
                continue;
            }
            //--3 打印客户端信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //IPV4
                if (clntAddr.ss_family == AF_INET) {
                    struct sockaddr_in *clntAddr_in4 = (struct sockaddr_in *)&clntAddr;
                    const char *printIP = inet_ntoa(clntAddr_in4->sin_addr);
                    in_port_t port = ntohs(clntAddr_in4->sin_port);
                    NSString *clintIP = [NSString stringWithUTF8String:printIP];
                    NSString *message = [NSString stringWithFormat:@"iPv4客户端连接 -- %@:%d",clintIP,port];
                    [self.textView addLogText:message];
                }
                //IPV6
                else if (clntAddr.ss_family == AF_INET6){
                    
                }
                //Other
                else{
                    [self.textView addLogText:@"未知协议族连接接入"];
                }
            });
            //--4 开启子线程，处理数据
            [self handleClientDataWithSock:(int)clntSock];
        }
        
    });
}

/**开启子线程，处理客户端的数据*/
- (void)handleClientDataWithSock:(int)clntSock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        ESBConnectionSocketModel *connSock = [[ESBConnectionSocketModel alloc]init];
        connSock.conectSocket = clntSock;
        connSock.handleThread = [NSThread currentThread];
        
        //加锁，加入线程池
        @synchronized (self) {
            [self.connectionList addObject:connSock];
        };
        
        //创建一个输入输出流
        FILE *channel = fdopen(clntSock, "r+");
        if (channel == nil) {
            //回主线程打印日志信息
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"socket id = %d 创建file流失败 fdopen() failed",clntSock];
                [self.textView addLogText:message];
            });
            return;
        }
        
        //循环接收客户端的数据
        int mSize;
        char inBuf[ESBBufferLength];    //用来存储接收到的二进制数据
        while (1) {

            //从指定流中读取数据，并成帧
            size_t recvBytes = FrameLengthRecv(channel, inBuf, ESBBufferLength);
            
            //解码
            if (recvBytes == -1) {
                break;
            }
            NSDictionary *dictionary = [ESBDataCoder jsonDataWithBuffer:inBuf length:recvBytes];
            
            //响应客户的数据
            [self responseClientDataWithDict:dictionary];

        }
        
        //客户端主动退出
        //--1 移除连接列表
        @synchronized (self) {
            [self.connectionList removeObject:connSock];
        };
        //--2 销毁
        close(clntSock);
    });
}




#pragma mark - 数据处理相关
/**响应客户端数据*/
- (void)responseClientDataWithDict:(NSDictionary *)dict
{
    
    
    
    
}







@end
