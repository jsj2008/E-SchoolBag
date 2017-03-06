//
//  ESBMessageModel.h
//  ESchoolBagLocalServer
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBClientID.h"

/**消息类型*/
typedef NS_ENUM(NSInteger,ESBMessageType){
    ESBMessageTypeNormal = 0,       //表示客户端之间交互的信息
    ESBMessageTypeGroup = 1,        //表示多个客户端组交互的信息
    ESBMessageTypeHeadline = 2,     //表示系统消息，系统通知、警告、实时数据更新
    ESBMessageTypeError = 3,        //表示错误消息，可以是服务器发送给客户端的，也可以是客户端回发给客户端的
    ESBMessageTypeControl = 4,      //表示控制信息，一般是服务器与客户端之间进行逻辑交互使用
    ESBMessageTypeOther = 5         //其他消息
};

/**控制类型*/
typedef NS_ENUM(NSInteger,ESBMsgCtlType) {
    ESBMsgCtlTypeLogin = 0,         //登录
    ESBMsgCtlTypeLogout = 1,        //退出
    ESBMsgCtlTypeOther = -1          //其他，待后续扩充
};


@interface ESBMessageModel : NSObject

/**接收方用户ID，如无指定则不用转发*/
@property(nonatomic,strong) ESBClientID *toUserId;

/**发送方用户ID*/
@property(nonatomic,strong) ESBClientID *fromUserId;

/**消息类型*/
@property(nonatomic,assign) ESBMessageType msgType;

/**控制消息类型*/
@property(nonatomic,assign) ESBMsgCtlType ctlType;

/**消息创建时间戳*/
@property(nonatomic,assign) NSTimeInterval createTime;

/**承载的JSON内容--json字符串*/
@property(nonatomic,copy) NSDictionary *content;


#pragma mark - 编码和解码
/**编码，将消息对象编码成json二进制,返回buffer和buffer的长度*/
+ (void *)encodeMessage:(ESBMessageModel *)message length:(size_t *)msgSize;
/**解码，将json二进制解码成消息对象，需要传入buffer和buffer的长度*/
+ (instancetype)decodeMessageWithBuffer:(void *)buffer length:(size_t )msgSize;

@end









