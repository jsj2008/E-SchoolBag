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


#import "ESBMessageModel.h"

#import "ESBSocketManager.h"


#include <AFNetworking.h>



@interface ESBHomeViewController ()

#pragma mark - 控件相关属性
@property (unsafe_unretained) IBOutlet NSTextView *textView;



@end


@implementation ESBHomeViewController


#pragma mark - 懒加载


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
    [ESBSocketManager shareManager].servSock = -1;
    
    //初始化日志
    [self.textView addLogText:@"程序开始启动"];
}


#pragma mark - Socket相关
/**监听主端口*/
- (void)listenMainPort
{
    ESBWeakSelf;
    [[ESBSocketManager shareManager] listenMainPort:ESBListenMainPort result:^(BOOL success) {
        
        if (!success) {
            [weakSelf.textView dieLogWithText:@"监听失败，服务结束"];
            return;
        }
        [weakSelf.textView addLogText:@"服务器准备就绪，等待客户端的连接..."];
        
        //开启常驻子线程，用于接收客户端的连接
        [weakSelf acceptClientConnection];
        
    } log:^(NSString *logStr) {
       
        [weakSelf.textView addLogText:logStr];
        
    }];
    
}

/**开启子线程，用于接收客户端的连接*/
- (void)acceptClientConnection
{
    //开启子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        //保存当前的主监听线程
        [ESBSocketManager shareManager].listenThread = [NSThread currentThread];
        
        //循环接收客户端的连接
        ESBWeakSelf;
        [[ESBSocketManager shareManager] acceptClientConnectionWithHandle:^(int clntSock, struct sockaddr_storage clntAddr, socklen_t clntAddrLen) {
            
            //解析并打印客户端信息
            [[ESBSocketManager shareManager] parseAddressWithSockAddr:clntAddr result:^(BOOL success, BOOL ipv4, NSString *clintIP, in_port_t port) {
                
                //回主线程，打印日志
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        NSString *logStr = [NSString stringWithFormat:@"%@ 协议族连接接入 IP地址:%@ 端口号:%d",ipv4?@"IPV4":@"IPV6",clintIP, port];
                        [weakSelf.textView addLogText:logStr];
                    }else{
                        [weakSelf.textView addLogText:@"未知协议族连接接入"];
                    }
                });
                
            }];
            
            //再次开启子线程处理数据 -- 对应于每个客户端的处理线程
            [weakSelf handleClientDataWithSock:clntSock];
            
        } log:^(NSString *logStr) {
            //回主线程，打印日志
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.textView addLogText:logStr];
            });
        }];
        
        
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
            [[ESBSocketManager shareManager].connectionList addObject:connSock];
        };
        
        
        //循环接收客户端的数据
        ESBWeakSelf;
        [[ESBSocketManager shareManager] receivedMessageFromSocket:clntSock result:^(ESBMessageModel *message) {
            
            //解析消息
            [weakSelf parseMessage:message withSock:clntSock];
            
        } log:^(NSString *logStr) {
            //回主线程打印日志
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.textView addLogText:logStr];
            });
        }];
        
              
        //客户端主动退出
        //--1 移除连接列表
        @synchronized (self) {
            [[ESBSocketManager shareManager].connectionList removeObject:connSock];
        };
        //--2 销毁
        close(clntSock);
    });
}




#pragma mark - 数据处理相关
/**解析消息*/
- (void)parseMessage:(ESBMessageModel *)message withSock:(int )sock
{
    //取出客户端ID
    @synchronized (self) {
        //self.clntSockCachePool[message.fromUserId.username] = @(sock);
        [ESBSocketManager shareManager].clntSockCachePool[message.fromUserId.username] = @(sock);
    }
    
    //取出消息中的类型
    ESBMessageType msgType = message.msgType;
    if (msgType == ESBMessageTypeNormal) {
        //转发--客户端之间的交互
        
        
    }else if(msgType == ESBMessageTypeGroup){
        //转发--客户端组内的交互信息
        
    }else if(msgType == ESBMessageTypeHeadline){
        //服务器处理--系统消息
        
        
    }else if(msgType == ESBMessageTypeError){
        //错误消息
        
        
        
    }else if(msgType == ESBMessageTypeControl){
        //控制消息
        ESBMsgCtlType ctlType = message.ctlType;
        NSString *logStr = [NSString stringWithFormat:@"%@",message.fromUserId.username];
        if (ctlType == ESBMsgCtlTypeLogin) {
            //登录
            logStr = [logStr stringByAppendingString:@" 发起了登录请求"];
            [self handleLoginRequest:message];
            
        }else if(ctlType == ESBMsgCtlTypeLogout){
            //退出
            logStr = [logStr stringByAppendingString:@" 发起了退出请求"];
            
            
            
            
        }else{
            //其他控制消息
            
            
            
            
            
        }
        
        
        //打印日志
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textView addLogText:logStr];
        });
        
        
    }else{
        //其他类型
        
        
    }
}



#pragma mark - 客户端事件响应
/**处理登录请求*/
-(void)handleLoginRequest:(ESBMessageModel *)message
{
    //获取用户名密码
    NSString *username = [message.content valueForKey:@"username"];
    NSString *password = [message.content valueForKey:@"password"];
    
    //构造响应消息
    ESBMessageModel *rspMsg = [[ESBMessageModel alloc]init];
    rspMsg.fromUserId = nil;
    rspMsg.toUserId = message.fromUserId;
    rspMsg.msgType = ESBMessageTypeControl;
    rspMsg.ctlType = ESBMsgCtlTypeLogin;
    rspMsg.createTime = [[NSDate new] timeIntervalSince1970];
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    
    //判断
    if (username.length == 0 || password.length == 0) {
        //构造出错响应
        content[@"code"] = @"0";
        content[@"result"] = @"0";  //失败
        content[@"reason"] = @"username/password is null";
        
    }else{
        
        //连接服务器验证
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        
        
        [manager POST:@"http://www.baidu.com" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSLog(@"%@",responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        
        
        
        //构造成功
        content[@"code"] = @"0";
        content[@"result"] = @"1";
        content[@"reason"] = nil;
    }
    
    rspMsg.content = content;
    
    //响应消息
    ESBWeakSelf;
    int clntSock = [[[ESBSocketManager shareManager].clntSockCachePool valueForKey:rspMsg.toUserId.username] intValue];
    [[ESBSocketManager shareManager] sendMessageToSocket:clntSock message:rspMsg result:^(BOOL success, NSString *errLog) {
        //回主线程打印日志
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = [NSString stringWithFormat:@"%@ 用户登录",rspMsg.toUserId.username];
            [weakSelf.textView addLogText:success?msg:errLog];
        });
    }];
    
}



@end
