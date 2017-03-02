//
//  main.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/2.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <pthread.h>
#import "ESBTcpSocket.h"
#import "ESBSocketManager.h"
#import "ESBSocketModel.h"


int running = 1;
void sig_int(int sign);


void HandleConnection(int clntSock)
{
    //保存信息
    ESBSocketModel *socketModel = [[ESBSocketModel alloc]init];
    socketModel.thread = [NSThread currentThread];
    socketModel.socket = clntSock;
    [[ESBSocketManager sharedManager].threadSockets addObject:socketModel];
    
    
    while (1) {
     
        //处理子线程的事情
        
        
        
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
      
        
        //启动程序
        NSLog(@"=================启动程序=================\n");
        
        //准备
        ESBTcpSocket *servSock = [[ESBTcpSocket alloc]initWithType:ESBSockTypeServer host:nil port:@"9999" delegate:[ESBSocketManager sharedManager]];
        
        //主循环
        while (1) {
            
            //监听
            int clntSock = [servSock accpetClientConnection];
            if (clntSock < 0) {
                continue;
            }
            
            //创建子线程，处理
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                HandleConnection(clntSock);
                
            });
        }
        
    }
    return 0;
}
