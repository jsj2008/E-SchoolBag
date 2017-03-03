//
//  ViewController.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBHomeViewController.h"

#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>


@interface ESBHomeViewController ()

#pragma mark - 控件相关属性
@property (unsafe_unretained) IBOutlet NSTextView *textView;





@end


@implementation ESBHomeViewController
{
#pragma mark - socket成员变量
   int _servSock;
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
}













@end
