//
//  ESBLoginViewController.m
//  ESchoolBagStudent
//
//  Created by 23 on 2017/3/3.
//  Copyright © 2017年 23. All rights reserved.
//

#import "ESBLoginViewController.h"
#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>

#import "ESBDataFramer.h"
#import "ESBDataCoder.h"
#import "AppDelegate.h"
#import "ESBMessageModel.h"

#import <SVProgressHUD.h>

@interface ESBLoginViewController ()

/**用户名输入框*/
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
/**密码输入框*/
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;



@end

@implementation ESBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //设置UI
    [self setupUI];
}


#pragma mark - 设置UI
- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
}


#pragma mark - 事件监听

- (IBAction)loginBtnClick:(UIButton *)sender {
   

    //构造消息
    ESBMessageModel *message = [[ESBMessageModel alloc]init];
    message.toUserId = nil;
    ESBClientID *from = [[ESBClientID alloc]init];
    from.username = @"chenhua";
    message.fromUserId = from;
    message.msgType = ESBMessageTypeControl;
    message.ctlType = ESBMsgCtlTypeLogin;
    message.createTime = [[NSDate new] timeIntervalSince1970];
    message.content = @{@"username":@"chenhua",@"password":@"123456"};
    
    //编码
    size_t dataSize;
    void *buffer = [ESBMessageModel encodeMessage:message length:&dataSize];
    
    
    //成帧发送
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    FrameLengthSend(buffer, dataSize, fdopen(delegate.clntSock, "r+"));
    
    
}



@end






































