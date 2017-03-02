//
//  ESBSocketModel.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/2.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESBSocketModel : NSObject

/**当前的线程id*/
@property(nonatomic,strong) NSThread *thread;

/**当前的已连接socket描述符*/
@property(nonatomic,assign) int socket;


@end
