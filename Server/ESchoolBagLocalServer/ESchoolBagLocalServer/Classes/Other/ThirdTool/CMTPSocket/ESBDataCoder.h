//
//  ESBDataCoder.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/6.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESBDataCoder : NSObject

/**解码-------解码json格式为NSDictionary*/
+(NSDictionary *)jsonDataWithBuffer:(void *)buffer length:(size_t)length;

/**编码-------将字典内容序列化为json并返回buffer，且返回buffer的实际长度*/
+(void *)bufferWithDictionary:(NSDictionary *)dict length:(size_t *)size;

@end
