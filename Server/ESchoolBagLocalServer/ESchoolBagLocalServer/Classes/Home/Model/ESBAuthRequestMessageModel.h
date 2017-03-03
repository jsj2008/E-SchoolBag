//
//  ESBAuthMessageModel.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBMessageModel.h"

@interface ESBAuthRequestMessageModel : ESBMessageModel

/**用户名*/
@property(nonatomic,copy) NSString *username;

/**密码*/
@property(nonatomic,copy) NSString *password;

@end
