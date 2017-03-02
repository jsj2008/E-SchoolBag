//
//  ESBSocketManager.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/2.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBSocketManager.h"

@implementation ESBSocketManager

#pragma mark - 单例
static id _instance;

+(instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    
    return _instance;
}


@end
