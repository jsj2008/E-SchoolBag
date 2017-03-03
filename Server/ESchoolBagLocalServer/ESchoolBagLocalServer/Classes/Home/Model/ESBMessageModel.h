//
//  ESBMessageModel.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESBMessageModel : NSObject

/**接收方用户ID，如无指定则不用转发*/
@property(nonatomic,copy) NSString *toUserId;


/**发送方用户ID*/
@property(nonatomic,copy) NSString *fromUserId;


/**消息类型*/
@property(nonatomic,copy) NSString *msgType;


/**消息创建时间戳*/
@property(nonatomic,assign) NSTimeInterval createTime;


/**承载的JSON内容--json字符串*/
@property(nonatomic,copy) NSString *content;



@end
