//
//  ESBMessageModel.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBMessageModel.h"
#import "ESBDataCoder.h"
#import <MJExtension.h>

@implementation ESBMessageModel

#pragma mark - 编码和解码
/**编码，将消息对象编码成json二进制,返回buffer和buffer的长度*/
+ (void *)encodeMessage:(ESBMessageModel *)message length:(size_t *)msgSize
{
    //将当前对象转换成字典
    NSMutableDictionary *dictM =  [message mj_keyValues];
    
    //编码
    void *buffer = [ESBDataCoder bufferWithDictionary:dictM length:msgSize];
    
    //返回
    return buffer;
}


/**解码，将json二进制解码成消息对象，需要传入buffer和buffer的长度*/
+ (instancetype)decodeMessageWithBuffer:(void *)buffer length:(size_t )msgSize
{
    //解码
    NSDictionary *dict = [ESBDataCoder jsonDataWithBuffer:buffer length:msgSize];
    
    //字典转对象
    ESBMessageModel *message =  [ESBMessageModel mj_objectWithKeyValues:dict];
    
    //返回
    return message;
}




@end
