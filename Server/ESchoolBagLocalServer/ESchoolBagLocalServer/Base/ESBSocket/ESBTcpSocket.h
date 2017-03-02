//
//  ESBTcpSocket.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/2.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ESBSockType){
    ESBSockTypeServer = 0,
    ESBSockTypeClient = 1
};


@protocol ESBTcpSocketDelegate <NSObject>



@end


@interface ESBTcpSocket : NSObject

@property(nonatomic,weak) id<ESBTcpSocketDelegate> delegate;


- (instancetype)initWithType:(ESBSockType )type host:(NSString *)host port:(NSString *)port delegate:(id<ESBTcpSocketDelegate>)delegate;
- (int)accpetClientConnection;

@end
