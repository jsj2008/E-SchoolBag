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
   
    /*
    
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
*/
    
    
    
    NSDictionary *response = @{@"success":@(NO),
                               @"reason":@"wrong password",
                               @"a":@"阿萨德法师法师法师法师法安非a",
                               @"b":@"阿发是干啥大公司的感受到了卡死机弗兰克就b",
                               @"c":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克萨q",
                               @"d":@"破啊设计费卢卡斯放假哈森林防火辣椒水你发了q",
                               @"e":@"啊连接好多法拉盛卢卡斯福利卡健身房拉上来看风景q",
                               @"f":@"岸上；发；冷风机雷克萨风口浪尖首付款静安寺；六块腹肌q",
                               @"g":@"岸上；发送了扩；放假；库拉索解放路卡设计费拉实际发送；姐夫q",
                               @"h":@"岸上；了开发建立健全欧力萨菲隆举案说法q",
                               @"i":@"阿发三国杀的归属感萨芬都是啊阿发q",
                               @"j":@"阿斯顿发所发生的好人好事想法q",
                               @"k":@"阿萨德刚和多发工资西安首付q",
                               @"l":@"q啊所发生的发送到噶苏ZFa",
                               @"m":@"q阿发阿发阿发岸上阿发阿发阿斯蒂芬阿斯蒂芬阿斯蒂芬",
                               @"n":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"o":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"q":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"r":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"s":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"t":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"u":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"v":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"w":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"x":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"y":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"z":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"qq":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"ww":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"ee":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"rr":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"tt":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"yy":@"阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克q",
                               @"aa":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"ss":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克",
                               @"ff":@"q阿斯蒂芬岸上；‘反馈啊；蓝山咖啡；啊设计费；喀什雷克"};
    //编码
    size_t dataSize;
    char *buffer = [ESBDataCoder bufferWithDictionary:response length:&dataSize];
    
    //成帧发送
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    FrameLengthSend(buffer, dataSize, fdopen(delegate.clntSock, "r+"));
    
    
}



@end






































