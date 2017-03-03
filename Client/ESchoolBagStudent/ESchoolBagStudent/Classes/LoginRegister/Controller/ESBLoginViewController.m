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
    
    
    //告诉系统我们需要哪种类型的地址
    struct addrinfo addrCritral;
    memset(&addrCritral, 0, sizeof(addrCritral));
    addrCritral.ai_family = AF_UNSPEC;
    addrCritral.ai_protocol = IPPROTO_TCP;
    addrCritral.ai_socktype = SOCK_STREAM;
    
    //解析服务器地址信息
    struct addrinfo *servAddr;
    int rtnVal = getaddrinfo(ESBSeverAddress, ESBServerMainPort, &addrCritral, &servAddr);
    if (rtnVal != 0) {
        [SVProgressHUD showErrorWithStatus:@"getaddrinfo() failed"];
        return;
    }
    
    //创建客户端套接字
    int clntSock = socket(servAddr->ai_family, servAddr->ai_socktype, servAddr->ai_protocol);
    if (clntSock < 0 ) {
        [SVProgressHUD showErrorWithStatus:@"socket() failed"];
        return;
    }
    
    //连接服务器
    if (connect(clntSock, servAddr->ai_addr, servAddr->ai_addrlen) < 0) {
        [SVProgressHUD showErrorWithStatus:@"connect() failed"];
    }
    
    
    //测试
    NSDictionary *response = @{@"success":@(NO), @"reason":@"wrong password"};
    //JSON序列化
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:0 error:&error];
    char *buffer = [jsonData bytes];
    //发送
    send(clntSock, buffer, [jsonData length], 0);
    
    
    //编码
    
    
    
    //成帧发送
    
    
    
}



@end






































