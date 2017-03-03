//
//  ESBConnectionSocketModel.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESBConnectionSocketModel : NSObject
/**当前连接的套接字*/
@property(nonatomic,assign) int conectSocket;
/**处理当前连接的线程*/
@property(nonatomic,strong) NSThread *handleThread;

@end
