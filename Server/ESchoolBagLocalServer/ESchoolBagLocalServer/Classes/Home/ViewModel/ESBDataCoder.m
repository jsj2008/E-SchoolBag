//
//  ESBDataCoder.m
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/6.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBDataCoder.h"

@implementation ESBDataCoder

/**解码-------解码json格式为NSDictionary*/
+(NSDictionary *)jsonDataWithBuffer:(void *)buffer length:(size_t)length
{
    NSData *decodeData = [NSData dataWithBytes:buffer length:length];
    NSError *err;
    NSDictionary *decodeDict = [NSJSONSerialization JSONObjectWithData:decodeData options:NSJSONReadingMutableLeaves error:&err];
    if (err) {
        NSLog(@"解码失败");
        return nil;
    }else{
        NSLog(@"解码成功---%@",[decodeDict description]);
        return decodeDict;
    }
}


/**编码-------将字典内容序列化为json并返回buffer，且返回buffer的实际长度*/
+(void *)bufferWithDictionary:(NSDictionary *)dict length:(size_t *)size;
{
    //json序列化
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error ];
    
    //转换
    char *buffer = [jsonData bytes];
    *size = [jsonData length];
    
    //返回
    return buffer;
}




@end
