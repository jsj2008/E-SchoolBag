//
//  ESBAuthResponseMessageModel.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESBAuthResponseMessageModel : NSObject

/**登录是否成功*/
@property(nonatomic,assign) BOOL success;

/**失败的原因*/
@property(nonatomic,copy) NSString *reason;

@end
