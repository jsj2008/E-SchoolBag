//
//  ESBSocketManager.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/2.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBTcpSocket.h"

@interface ESBSocketManager : NSObject <ESBTcpSocketDelegate>

+(instancetype)sharedManager;


@property(nonatomic,strong) NSMutableArray *threadSockets;


@end
