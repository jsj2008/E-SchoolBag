//
//  ESBSocketManager.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/7.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESBMessageModel;

@interface ESBSocketManager : NSObject


@property(nonatomic,assign) int servSock;

#pragma mark - 线程相关属性
/**主监听线程*/
@property(nonatomic,strong) NSThread *listenThread;
/**客户端连接列表*/
@property(nonatomic,strong) NSMutableArray *connectionList;


#pragma mark - 当前客户端和对应的socket缓存池
@property(nonatomic,strong) NSMutableDictionary *clntSockCachePool;


+(instancetype)shareManager;


#pragma mark - socket相关

/**给定端口，监听*/
- (void)listenMainPort:(char *)port result:(void(^)(BOOL success))result log:(void(^)(NSString *logStr))log;

/**循环接收客户端的连接*/
- (void)acceptClientConnectionWithHandle:(void(^)(int clntSock, struct sockaddr_storage clntAddr, socklen_t clntAddrLen))handle log:(void(^)(NSString *logStr))log;

/**根据sockaddr_storeage解析地址信息*/
-(void)parseAddressWithSockAddr:(struct sockaddr_storage)sockAddr result:(void(^)(BOOL success, BOOL ipv4, NSString *clintIP, in_port_t port))result;


#pragma mark - 数据收发
/**从指定的连接socket循环接收数据*/
- (void)receivedMessageFromSocket:(int)socket result:(void(^)(ESBMessageModel *message))result log:(void(^)(NSString *logStr))log;

/**给指定的连接socket发送数据*/
- (void)sendMessageToSocket:(int)socket message:(ESBMessageModel *)message result:(void(^)(BOOL success, NSString *errLog))result;

@end
