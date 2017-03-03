//
//  NSTextView+ESBExtension.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (ESBExtension)

- (void)addString:(NSString *)string;

/**添加日志信息（包括日期时间）*/
- (void)addLogText:(NSString *)logStr;
/**结束日志*/
- (void)dieLogWithText:(NSString *)logStr;
@end
