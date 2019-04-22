//
//  ViewController.m
//  MSmartApp
//
//  Created by martmoney on 2018/7/9.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "SystemServices.h"
#import <AdSupport/AdSupport.h>
#import "PSWebSocketServer.h"
#import "LMAppController.h"
#import "MSmartMoneyPreventer.h"
#import "YingYongYuanetapplicationDSID.h"
#import "DLUDID.h"
#import "UIImageView+WebCache.h"
#import "UIView+ZYDraggable.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMMobClick/MobClick.h"
///获取经纬度
#import <CoreLocation/CoreLocation.h>

//#import "WXApi.h"

@interface ViewController ()<PSWebSocketServerDelegate,UIScrollViewDelegate,UMSocialUIDelegate,CLLocationManagerDelegate>
{
    UILabel * textView;
    //自己加的
    //---登录前
    //适配
    IBOutlet UIImageView *mBgImg; //最底部背景图
    IBOutlet UIImageView *mWechatHeadImg; //登录成功后的微信头像
    IBOutlet UIImageView *mLogoImg;//登录前的logo图
    IBOutlet NSLayoutConstraint *mWechatImgWidthLayout;//微信头像宽
    
    IBOutlet NSLayoutConstraint *mLoginBtnLeadLayout;//登录按钮距头部
    IBOutlet NSLayoutConstraint *mLogoWidthLayout;
    IBOutlet NSLayoutConstraint *mLogoTopLayout;//登录前logo图片，顶部
    IBOutlet UIButton *mStartTaskBtn; //开始任务
    IBOutlet UIButton *mWechatBtn; //微信登录
    //---登录成功后
    
    IBOutlet UIView *mBaseView;
    IBOutlet UILabel *mNickNameLB; //欢迎你。。。
    //做适配
    IBOutlet UILabel *mAPPNameLB;
    IBOutlet NSLayoutConstraint *mTaskBtnHeightLy; // 微信登录按钮高
    
    IBOutlet NSLayoutConstraint *mNickNameTopLayout;
    
//    ///获取北纬东经
//    CLLocationManager *location;
    
}

 ///获取北纬东经
@property(nonatomic,strong) CLLocationManager *location;

@property (nonatomic, strong) NSTimer *ceshi;
//@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *WXBtn;
@property (nonatomic, strong) UIImageView *WXImage;
@property (nonatomic, strong) UIImageView *zaiXianImage;

// 与网页交互
@property (nonatomic, strong) PSWebSocketServer *server;
@property (nonatomic, strong) MSmartMoneyPreventer *mmpPreventer;
// 计算时间用的变量
@property (nonatomic, assign) int appRunTime; //APP运行时间
@property (nonatomic, assign) int shiCanTime; //后台运行时间
@property (nonatomic, assign) int deliverTime; //应用使用的时间，传送服务器时间
@property (nonatomic, strong) NSTimer *timerShiCan;
@property (nonatomic, strong) NSString *shiCanStr;
// 网页连接错误
@property (nonatomic, assign) NSInteger errorCount;

//自己加的，10秒检测一次，应用是否下载好了
@property (nonatomic, strong) dispatch_source_t tenTimer;//十秒定时器 GCD
@property (nonatomic, strong) NSTimer *checkTenTimer;
@property (nonatomic, assign) int tenTime;//十秒 加一次
@property (nonatomic, assign) BOOL tenTimerOpen;//十秒一次的定时器，是否需要关闭（如果需要关闭，开启第二个定时器）
@property (nonatomic, strong) NSString *appIdStr; //应用的APPID 包名
//@property (nonatomic, assign) BOOL tenTimerClosed;//如果关闭十秒定时器，第二次点击就不要

@property (nonatomic, strong) dispatch_source_t thirtyTimer;//十秒定时器 GCD
@property (nonatomic, strong) NSTimer *msThirtyTimer;// 30秒的定时器
@property (nonatomic, assign) int thirtyTime;//三十秒 加一次
@property (nonatomic, strong) PSWebSocket *sendContentServer;

@property (nonatomic, assign) BOOL  againOpen;//再领取任务时，判断之前的存储的包名和当前包名是否一致，从而决定是否打开十秒定时器
///北纬&东经
@property (nonatomic, strong) NSString *eastNorthStr;

@property (nonatomic, strong) NSTimer *timerAutoDetection;
@property (nonatomic, strong) NSTimer *startAutoDetectionTimer;

// 计算检测次数
@property (nonatomic, assign) NSInteger autoDetectCount;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 通知
    [self notificationNum];
    // 客户端界面
    [self interfaceSetUp];
    // 后台监听
    [self backgroundMonitor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:@"changeLabel" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msOepnTimers) name:@"msThirtyCheckOpenApp" object:nil];
    
    //微信登录通知结果
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:@"wechatloginresult" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ////停止定位
    [_location stopUpdatingLocation];
}

//通知  开启30秒定时器
-(void)msOepnTimers{
    if (self.tenTimerOpen == YES) {//说明定检测到 应用已经下载了，关闭10秒定时器，开启30秒定时器
        _thirtyTime = 0; //小于等于6
        NSLog(@"-----30秒定时器---222----appid------self.appIdStr----%@--",self.appIdStr);
//        _msThirtyTimer = [NSTimer scheduledTimerWithTimeInterval:30  target:self selector:@selector(msThirtyOpenApp:) userInfo:self.appIdStr repeats:YES];
        
        dispatch_queue_t tenQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _thirtyTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, tenQueue);
        dispatch_source_set_timer(_thirtyTimer, DISPATCH_TIME_NOW, 30.0 * NSEC_PER_SEC, 30.0 * NSEC_PER_SEC);
        
        __weak typeof (self) weakSelf = self;
        dispatch_source_set_event_handler(_thirtyTimer, ^{
            [weakSelf msThirtyOpenApp:self.appIdStr];
        });
        dispatch_resume(_thirtyTimer);//激活GCD定时器
    }
    //    _shiCanTime++;
    
    
//    [self writeWebMsg:sendContentServer msg:isOpenAppStr];
}

//自己加的30秒定时器，打开应用
-(void)msThirtyOpenApp:(NSString*)appIdStr{
    _thirtyTime++;
    
    _shiCanTime = _thirtyTime * 30;//30秒定时器如果循环一次 应用计时 *30秒
    
    NSLog(@"--APPID------三十秒定时器，运行了----%d次-------tenTime----%d---:",_thirtyTime,_shiCanTime);
    if ([appIdStr isEqualToString:@""]) {
        return;
    }
    if (_thirtyTime >= 6) {//如果30秒定时器循环，超过6次就关闭掉
        //        [_msThirtyTimer invalidate];
        //        _msThirtyTimer = nil;
        dispatch_source_cancel(self.thirtyTimer); //关闭30秒 GCD定时器
        NSLog(@"-----我是-30秒定时器----要关闭了哈----下次见--👋👋再见-" );
    }
    [[LMAppController sharedInstance] openPPwithID:appIdStr];//打开应用
    
    NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
    NSLog(@"---运行时间---%@", appRunTimeStr);
    [self writeWebMsg:_sendContentServer msg:appRunTimeStr]; //提交APP运行时间
}

#pragma mark - 网页socket连接，互传数据处理
// 初始化网页socket端口
-(void)initServer:(int) port{
    self.server = [PSWebSocketServer serverWithHost:MHOST port:port];
    self.server.delegate = self;
    [self.server start];
}

- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"-----serverDidStop----");
    _errorCount++;
    if(_errorCount > 3){
        //连接失败
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"服务器连接超时，如果后台有其他助手在线请关闭，重新打开此应用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return ;
    }
    [self initServer:MPORT];
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen");
}

-(void)runInbackGround{
    self.mmpPreventer=  [[MSmartMoneyPreventer alloc ]init];
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"MBgMusic" ofType:@"m4a"];
    [self.mmpPreventer setPath:soundFilePath];
    if( self.mmpPreventer.isError){
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请关闭其他软件，在打开该软件" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [self.mmpPreventer mmp_playPreventSleepSound];
    //里面有循环
    [self.mmpPreventer startPreventSleep];
}

#pragma mark - ----------------------接收到数据，作处理
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    // 接收数据
    NSString *jieshouStr = nil;
    jieshouStr = message;
    NSLog(@"--message--%@", jieshouStr);
    NSData *requestData = [jieshouStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;//data转字典json
    NSDictionary *mesDict  =[NSJSONSerialization JSONObjectWithData:requestData options:kNilOptions error:&err];
    
    // 查看转换是否成功
    NSLog(@"mesDict:%@", mesDict);
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return ;
    }
    // 取第一个key 包名
    NSString *messageStr = nil;
    messageStr = mesDict[@"baoming"];
    NSLog(@"messageStr:%@", messageStr);
    
    self.appIdStr = messageStr;//赋值 包名
    // 取第二个key 时间
    NSString *timeStr = mesDict[@"time"];
    _deliverTime = [timeStr intValue];
    if ([messageStr isEqualToString:@"shareFriend000"]) {
        _deliverTime = 200;
    }
    NSLog(@"_deliverTime:%d", _deliverTime);
    // 取第三个判断值
    NSString *panduanStr = mesDict[@"panduan"];
    NSLog(@"panduanStr:%@", panduanStr);
    
    // 传分享的网址内容：好友
    if ([panduanStr isEqualToString:@"shareFriend000"]) {
        NSLog(@"---timeStr-----%@--",timeStr);
        [[LMAppController sharedInstance] openPPwithID:CMZQBundleId];//应用的bundleId
        [UMSocialWechatHandler setWXAppId:WXAppId appSecret:WXAppSecret url:timeStr];
        [UMSocialQQHandler setQQWithAppId:QQAppId appKey:QQAppKey url:timeStr];
        
        NSString *appKey = UmengAppkey;
        NSString *shareText = @"来天使赚，每天多赚上百元ヾ(◍°∇°◍)ﾉﾞ，官网.https://m.angelmoney.cn";
        UIImage *image = [UIImage imageNamed:@"MSWY1024"];
        NSArray *snsNames = @[UMShareToWechatSession, UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone];
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:appKey
                                          shareText:shareText
                                         shareImage:image
                                    shareToSnsNames:snsNames
                                           delegate:nil];        
        return;
    }
    
    // 后台传任务完成的通知
    if ([panduanStr isEqualToString:@"notification002"]) {
        //NSLog(@"notification002");
        UILocalNotification *local = [[UILocalNotification alloc] init];
        
        local.alertBody = [NSString stringWithFormat:@"“%@”任务已经完成,请查看奖励,如未到账,请稍等", timeStr];
        
        local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        
        local.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:local];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
        return;
    }
    
    // 判断是否安装
    if ([panduanStr isEqualToString:@"isDownTheApp"]) {
        //
        BOOL isDownAppBool = YES;//是否安装
        NSLog(@"isDownAppBool:%d", isDownAppBool);
        //iOS 11 判断APP是否安装 手动调用这个方法
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0) {
            NSBundle *container = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/MobileContainerManager.framework"];
            if ([container load]) {
                Class appContainer = NSClassFromString(@"MCMAppContainer");
                id isInstall = [appContainer performSelector:@selector(containerWithIdentifier:error:) withObject:messageStr withObject:nil]; //是否安装应用
                NSLog(@"-----test--%@",isInstall);
                if (isInstall) {
                    isDownAppBool = YES;
                } else {
                    isDownAppBool = NO;
                }
            }
        } else {
            //非iOS11通过获取安装列表判断即可
            isDownAppBool = [[YingYongYuanetapplicationDSID sharedInstance] getAppState:messageStr];//这个私有API方法iOS11，被封掉了，换成下面的
        }
        NSString *isOpenAppStr = [NSString stringWithFormat:@"{\"openApp\":\"%d\"}",isDownAppBool];
        NSLog(@"isOpenAppStr:%@", isOpenAppStr);
        [self writeWebMsg:webSocket msg:isOpenAppStr];
        
        return;
    }
    
    //-------0806-----新加新功能
    if ([panduanStr isEqualToString:@"timing"]) {
        //发送这个指令给你 代表用户领取了任务，并且开始了 需要做的就是开启一个10秒一次的定时任务
        //自动去检测是否下载了该app 检测到了呢就强制打开 定时器关闭
        /*
         新功能就是领取了任务，进来这个页面，我会发送新的指令给助手端
         然后你那边定时10秒检测一下是否下载了，没检测到继续10秒检测，检测到下载就关闭10秒的定时器，并强制打开，转为30秒一次的强制打开
         持续6次，180秒
         */
        NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
        [infoDic setObject:webSocket forKey:@"webSocket"];
        [infoDic setObject:messageStr forKey:@"appID"];
        _tenTime = 0; //

        //开启十秒定时器的时候，存储上次打开的包名，如果上次存储的包名，和当前的包名一致。就不强制打开应用了。
        //取出之前的包名
        NSString *saveAppid = [[NSUserDefaults standardUserDefaults] objectForKey:@"MSAppidStr"];
        //0、如果包名一样，就不强制打开，说明是之前的任务。只有在不同任务 不同包名时才开启10秒定时器
        if ([saveAppid isEqualToString:self.appIdStr]) {
            return ;
        }
        
        //开启十秒定时器 GCD创建
        dispatch_queue_t tenQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _tenTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, tenQueue);
        dispatch_source_set_timer(self.tenTimer, DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC, 10.0 * NSEC_PER_SEC);
        __weak typeof (self) weakSelf = self;
        dispatch_source_set_event_handler(self.tenTimer, ^{
            [weakSelf checkApp:messageStr];
            
        });
        dispatch_resume(self.tenTimer);//激活 10秒定时器
//        NSString *isOpenAppStr = [NSString stringWithFormat:@"{\"openApp\":\"%d\"}",isDownAppBool];
//        [self writeWebMsg:webSockets msg:isOpenAppStr];
    }
    
    if ([panduanStr isEqualToString:@"19940511"]) { // 打开APP // 传是否安装app
        /*
         19940511检测到并打开之后，会开启一个倒计时;和你那边的30秒一次的打开其实重复倒计时了;这两个计时能不能同步呢;因为你那边开始30秒一次，持续6次相当于是倒计时180秒;如果用户不在网页上点击打开app按钮，就算下载了你那边没接收指令也不会开启倒计时的
         */
        
        // 删除字符串@“19940511”
        BOOL isDownAppBool = [[LMAppController sharedInstance] openPPwithID:messageStr];//打开应用

        NSLog(@"19940511 isDownAppBool:%d", isDownAppBool);
        
        NSString *attD = nil;
        NSArray * atts;
        atts = [LMAppController sharedInstance].inApplicaS;
        
        // appID
        if ([YingYongYuanetapplicationDSID getIOSVersion]>=8.0) {
            for(LMApp* app in atts){
                //NSLog(@"app.appName:%@ ,app.appSID:%@ ,app.bunidfier:%@",app.appName ,app.appSID ,app.bunidfier );
                if ([app.bunidfier isEqualToString:CMZQBundleId]) {//应用的bundleId
                    attD = app.appSID;
                    break;
                }
            }
        }
        // iOS7的appID
        if (!attD) {
            attD = @"iOS7IsNull";
        }
        
        NSString *isOpenAppStr = [NSString stringWithFormat:@"{\"openApp\":\"%d\", \"nowAppID\":\"%d\"}",isDownAppBool, 1];
        [self writeWebMsg:webSocket msg:isOpenAppStr];
        NSLog(@"%@", isOpenAppStr);
        
        if (![_shiCanStr isEqualToString:messageStr] && _shiCanStr) {
            NSLog(@"停止上次定时检测");
            
            if (_startAutoDetectionTimer) {
                [_startAutoDetectionTimer invalidate];
                _startAutoDetectionTimer = nil;
            }
            
            if (_timerAutoDetection) {
                [_timerAutoDetection invalidate];
                _timerAutoDetection = nil;
            }
        }
        
        // 存了上一个包名
        _shiCanStr = messageStr;
        
        NSMutableDictionary *dictInfo = @{@"baoming": messageStr};
        
        if(!_startAutoDetectionTimer && dictInfo) {
            NSLog(@"开启定时检测");
            _startAutoDetectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                        target:self
                                                                      selector:@selector(autoDetect:)
                                                                      userInfo:dictInfo
                                                                       repeats:NO];
            NSLog(@"timing messageStr:%@", messageStr);
        }
    }
    else if ([panduanStr isEqualToString:@"19920505"]){ // 领取奖励金
        [[LMAppController sharedInstance] openPPwithID:messageStr];
    } else { // 提交审核
        // NSLog(@"%d",![_shiCanStr isEqualToString:messageStr]);
        if (![_shiCanStr isEqualToString:messageStr]) {
            _appRunTime = _deliverTime;
            NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
            NSLog(@"----%@", appRunTimeStr);
            [self writeWebMsg:webSocket msg:appRunTimeStr]; //提交APP运行时间
        } else{
            if (_shiCanTime >= _deliverTime) { //shiCanTime; //后台运行时间 //deliverTime 应用使用的时间，传送服务器时间
                _appRunTime = 0;
                NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
                NSLog(@"----%@", appRunTimeStr);
                [self writeWebMsg:webSocket msg:appRunTimeStr];
                // 重置计算时间
                _shiCanTime = 0;
            } else {
                _appRunTime = _deliverTime - _shiCanTime;
                NSString *appRunTimeStr = [NSString stringWithFormat:@"{\"appRunTime\":\"%d\"}", _appRunTime];
                NSLog(@"++++%@", appRunTimeStr);
                [self writeWebMsg:webSocket msg:appRunTimeStr];
            }
        }
    }
    
//    [self  mShareFriends];//分享好友
}

//自己加的
- (void)checkApp:(NSString*)appIdStr
{
    NSLog(@"--APPID------10秒定时器-开启---------tenTime-----,%d---%@", _tenTime,appIdStr);
    
    NSLog(@"--APPID-------10秒定时器----------tenTime--------:,%d,",_tenTime);
    //0、如果包名一样，就不强制打开 不同任务不同包名
    if ([appIdStr isEqualToString:self.appIdStr]) {
        return ;
    }
    
    //十秒定时器，强制打开应用时。保存当前包名
    [[NSUserDefaults standardUserDefaults] setObject:appIdStr  forKey:@"MSAppidStr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //1、十秒钟检测一次
    BOOL isDownAppBool = YES;
    //iOS 11 判断APP是否安装 手动调用这个方法
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0) {
        NSBundle *container = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/MobileContainerManager.framework"];
        if ([container load]) {
            Class appContainer = NSClassFromString(@"MCMAppContainer");
            
            id test = [appContainer performSelector:@selector(containerWithIdentifier:error:) withObject:appIdStr withObject:nil];
            NSLog(@"-----test--%@",test);
            if (test) {
                isDownAppBool = YES;
                NSLog(@"----10秒定时器检测应用---已经安装---test--%@",test);
            } else {
                isDownAppBool = NO;
                NSLog(@"----10秒定时器检测应用---没安装---test--%@",test);
            }
        }
        
    } else {
        //非iOS11通过获取安装列表判断即可
        isDownAppBool = [[YingYongYuanetapplicationDSID sharedInstance] getAppState:appIdStr];//这个私有API方法iOS11，被封掉了，换成下面的
    }
    
    if (isDownAppBool) {//下载好了，就打开应用 关闭10秒定时器；开启30秒定时器，尽可能多的让用户打开激活
        
        NSLog(@"---应用下载好了---十秒定时器关闭-----messageStr---%@---isDownAppBool---%d--",appIdStr,isDownAppBool);
        
        dispatch_source_cancel(self.tenTimer); //关闭10秒 GCD定时器
//        [_checkTenTimer invalidate];
//        _checkTenTimer = nil;
        self.tenTimerOpen = YES;//十秒定时器关闭，开启30秒定时器
#pragma mark  ---------- 开启30秒定时器
        [[NSNotificationCenter defaultCenter] postNotificationName:@"msThirtyCheckOpenApp" object:nil]; //发送通知，开启30秒定时器
        [[LMAppController sharedInstance] openPPwithID:appIdStr];//打开应用
    }else{//没有下载好，就继续十秒,持续下去
    }
    
    NSLog(@"---messageStr---%@---isDownAppBool---%d--",appIdStr,isDownAppBool);
    //  NSString *isOpenAppStr = [NSString stringWithFormat:@"{\"openApp\":\"%d\", \"nowAppID\":\"%d\"}",isDownAppBool, appID.intValue];
}

// 自动检测
- (void)autoDetect:(NSTimer *)timer
{
    NSLog(@"-信息是：%@", [timer userInfo] );
    
    NSString *messageStr = [[timer userInfo]objectForKey:@"baoming"];
    
    BOOL isDownAppBool = [[LMAppController sharedInstance] openPPwithID:messageStr];//打开应用

    
    NSLog(@"autoDetect isDownAppBool:%d", isDownAppBool);
    
    NSMutableDictionary *dictInfo = @{@"baoming": messageStr
                                      };
    
    NSInteger timeAutoDetect = 0;
    if (isDownAppBool) {
        
        // 如果已安装，每隔30秒检测一次
        timeAutoDetect = 30;
        _autoDetectCount++;
        
        if (_autoDetectCount == 1)
        {
            // 开始试玩
            // 重置计算时间
            _shiCanTime = 0;
            
            [[LMAppController sharedInstance] openPPwithID:messageStr];//打开应用

            if (_shiCanTime == 0) {
                
                _timerShiCan = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
            }
            
        } else if (_autoDetectCount >= 6) {
            
            if (_timerAutoDetection) {
                [_timerAutoDetection invalidate];
                _timerAutoDetection = nil;
            }
            
            _autoDetectCount = 0;
            _shiCanTime = _deliverTime;
            NSLog(@"_autoDetectCount %d", _autoDetectCount);
            
            [[LMAppController sharedInstance] openPPwithID:messageStr];
            
            return;
            
            
        } else {
            // 每次打开app
            [[LMAppController sharedInstance] openPPwithID:messageStr];
        }
        
    } else {
        // 如果未下载，每隔10秒检测一次
        timeAutoDetect = 10;
        if (_autoDetectCount != 0) {
            _autoDetectCount = 0;
            
            if (_timerAutoDetection) {
                [_timerAutoDetection invalidate];
                _timerAutoDetection = nil;
            }
            
            return;
        }
    }
    
    if (_timerAutoDetection) {
        [_timerAutoDetection invalidate];
        _timerAutoDetection = nil;
    }
    
    _timerAutoDetection = [NSTimer scheduledTimerWithTimeInterval:timeAutoDetect
                                                           target:self
                                                         selector:@selector(autoDetect:)
                                                         userInfo:dictInfo
                                                          repeats:NO];
    
    NSLog(@"_autoDetectCount:[%d] auto_timerAutoDetection:[%@] timeAutoDetect:[%ld]", _autoDetectCount, _timerAutoDetection, (long)timeAutoDetect);
    
}

// 后台运行时间
- (void)timeRun
{
    _shiCanTime++;
    NSLog(@"shicantime:%d", _shiCanTime);
    textView.text=[NSString stringWithFormat:@"%d",_shiCanTime];
    if (_shiCanTime>=_deliverTime) {
        [_timerShiCan invalidate];
        _timerShiCan = nil;
    }
}


#pragma mark uisocialdelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    //NSLog(@"%@",response);
    if (response.responseCode == UMSResponseCodeSuccess) {
        [WWJShow showString:@"分享成功"];
    }
    if (response.responseCode == UMSResponseCodeCancel) {
        [WWJShow showString:@"取消分享"];
    }
}

//提交信息，到网页服务器
-(void) writeWebMsg:(PSWebSocket *) client msg:(NSString *)msg{
    if(msg == nil || client == nil){
        return;
    }
    [client send:msg];
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"------didFailWithError----error----%@---",error);
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"--------didCloseWithCode--------reason--%@---",reason);
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request
{
    return  YES;
}
- (void)server:(PSWebSocketServer *)server webSocketDidFlushInput:(PSWebSocket *)webSocket
{
    NSLog(@"webSocketDidFlushInput"); // 完成刷新输入
}


- (void)serverDidStart:(PSWebSocketServer *)server {
    _errorCount = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //干点啥 激动  通知 启动了
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLabel" object:nil];
    });
    
}

- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    NSLog(@"++++++didFailWithError");
    _errorCount++;
    if(_errorCount > 3){
        //NSString *str = @"已掉线，点击此处可重新激活";// [NSString stringWithFormat: ];
        //连接失败
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"服务器连接超时，如果后台有其他助手在线请关闭，重新打开此应用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return ;
    }
    
    [self initServer:MPORT];
}


//自己加的
#pragma mark -------- 微信登录
/********************************************/
- (IBAction)mWechatLoginClick:(UIButton *)sender {
    NSLog(@"-微信登录-");
    ///本地描述文件
    NSString *localudidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"localudid"];
    NSString *wechatcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    
     NSLog(@"-微信登录-localProfileStr--%@",localudidStr);
    
    NSLog(@"-微信登录-wechatcode--%@",wechatcode);

    

    ///检查本地有没有 描述文件。没有去safari浏览器 安装
    if (localudidStr == nil || localudidStr == NULL) {
        //去安装描述文件的地方
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:InstallLocalProfileUrl]];

    }else{
        
        if  (wechatcode == nil || wechatcode == NULL) {
            [mWechatBtn setTitle:@"微信登录" forState:UIControlStateNormal];
            [self WXLogin];//微信登录
        }else{
            [mWechatBtn setHidden:true];
            [mStartTaskBtn setHidden:false];
            
        }
       
        
        
    }
    
    
}

/********************************************/
-(void)removeAllObjects{
    NSLog(@"---------通知来了---火车开走了--------");
}

#pragma mark -------- 通知数量
- (void)notificationNum
{
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:0];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
}

#pragma mark ----------------

//- (void)onResp:(BaseResp *)resp{
//    if ([resp isKindOfClass:[SendAuthResp class]]) {
//        SendAuthResp *temp = (SendAuthResp *)resp;
//
//        NSLog(@"--tempp--%@---",temp);
//
//    }
//}
//
//- (void)onReq:(BaseReq *)req{
//
//}

- (void)WXLogin
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
//    __weak typeof(&*self)weakSelf = self;
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            //微信登录成功
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            
            NSLog(@"--微信授权信息---dict--%@---",dict);
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatform.platformName];
            NSString *unionid =  response.thirdPlatformUserProfile[@"unionid"];
            NSString *nickname =  response.thirdPlatformUserProfile[@"nickname"];
            NSString *headimgurl =  response.thirdPlatformUserProfile[@"headimgurl"];
            
            NSLog(@"--微信信息---nickname--%@---",nickname);
            [[NSUserDefaults standardUserDefaults] setObject:unionid  forKey:@"WXLoginID"];
            [[NSUserDefaults standardUserDefaults] setObject:headimgurl forKey:@"headImgUrl"];
            [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:@"nickname"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //自己加的
            /********************************************/
            //登录成功，展示登录成功的页面，隐藏之前的页面
//            mWechatBtn.isHidden == YES;
            
            [mWechatBtn setHidden:YES];
            [mStartTaskBtn setHidden:NO];
            [mLogoImg setHidden:YES];
            [mWechatHeadImg setHidden:NO];
            
            [mAPPNameLB setHidden:YES];
            [mNickNameLB setHidden:NO];
            
            [mWechatHeadImg sd_setImageWithURL:[NSURL URLWithString:headimgurl]];//登录过就微信头像
            mNickNameLB.text = nickname;
        }
    });
}


//自己加的
/********************************************/
- (IBAction)mStarTaskClick:(UIButton *)sender {
    //开始任务
    [self jumpToHtml];//去跳转到网页
    //    mStarTaskBtn.isEnabled = YES;
}

//自己加的
/********************************************/
- (IBAction)mInviteClick:(UIButton *)sender {
    //立即邀请
    [WWJShow showStringWithTime:4.0 string:@"火车🚄开了宝贝，点我了吗？？火车🚄开了宝贝，点我了吗？？火车🚄开了宝贝，点我了吗？？火车🚄开了宝贝，点我了吗？？火车🚄开了宝贝，点我了吗？？火车🚄开了宝贝，点我了吗？？？"];
    
    [MobClick event:@"1010"]; //友盟统计
    
}

#pragma mark -------- 后台监听
- (void)backgroundMonitor
{
    //初始化server
    [self initServer:MPORT];
    //是否安装
    //NSLog(@"是否安装了软件：%d",[[YingYongYuanetapplicationDSID sharedInstance]getAppState:@"com.zhihu.daily"]);
    //app后台运行
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:newJump]){ // 跳转成功的设置
        [self runInbackGround];
//    }
    //打开app
    //如果说你这个APP正在下载，通过这个去打开。是yes状态，但是实际上这个应用根本没有下载下来,结合这个安装包是否存在一起用最好。
    //[[LMAppController sharedInstance] openPPwithID:@"com.zhihu.daily"];
}

// 检测是否联网
-(BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark - 跳转网页的按钮
- (void)jumpToHtml
{
    
    //设备类型
//    NSString *deviceModel = [[SystemServices sharedServices] deviceModel];
    NSString *deviceDeviceName = [[SystemServices sharedServices] getDeviceName];
    //设备型号
    NSString *systemDeviceTypeFormatted = [[SystemServices sharedServices] systemDeviceTypeFormatted];
    
    //设备系统版本
    NSString *systemsVersion = [[SystemServices sharedServices] systemsVersion];
    //手机名称
    NSString *deviceName = [[SystemServices sharedServices] deviceName];
    //运营商标志
    NSString *carrierName = [[SystemServices sharedServices] carrierName];
    //运营商国家
    NSString *carrierCountry = [[SystemServices sharedServices] carrierCountry];
    //MCC编码
    NSString *MCC = [NSString stringWithFormat:@"%@%@", [[SystemServices sharedServices] carrierMobileCountryCode], [[SystemServices sharedServices] carrierMobileNetworkCode]];
    //网络类型
    NSString *netType;
    if ([[SystemServices sharedServices] connectedToWiFi]) {
        netType = @"WiFi";
    }else if([[SystemServices sharedServices] connectedToCellNetwork]){
        netType = @"3G/4G";
    }
    //    NSLog(@"------netType:%@", netType);
    //MAC地址
    NSString *currentMACAddress = [[SystemServices sharedServices] currentMACAddress];
    //IP
    NSString *currentIPAddress = [[SystemServices sharedServices] currentIPAddress];
    //是否越狱
    BOOL jailbroken = [[SystemServices sharedServices] jailbroken] != NOTJAIL;
    //IDFA
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSString *idfa7 = [idfa substringWithRange:NSMakeRange(0, 7)];
    if ([idfa7 isEqualToString:@"0000000"]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"已检测到您关闭了广告标识符，请打开手机“设置->隐私->广告->'关闭限制广告追踪'”，然后退出程序，重新打开助手" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *uniqueID = [[SystemServices sharedServices] uniqueID];
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *keychain =  [DLUDID changeKeychain];     //
    
    NSLog(@"key:%@   idfa:%@", keychain, idfa);
    
    NSString *appID = nil;
    NSArray * apps;
    apps = [LMAppController sharedInstance].inApplicaS;
    
    
    ///本地描述文件 udid
    NSString *localudidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"localudid"];
    
    ///---------------刚进来登录 随便传的值udid
    
    // appID
    if ([YingYongYuanetapplicationDSID getIOSVersion]>=8.0) {
        for(LMApp* app in apps){
            //NSLog(@"app.appName:%@ ,app.appSID:%@ ,app.bunidfier:%@",app.appName ,app.appSID ,app.bunidfier );
            if ([app.bunidfier isEqualToString:CMZQBundleId]) {//应用的bundleId
                appID = app.appSID;
                break;
            }
        }
    }
    // iOS7的appID
    if (!appID) {
        appID = @"iOS7IsNull";
    }
    
    // 微信登陆的信息
     NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    
//    NSString *WXLoginID = @"123";
    NSString *headImgUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"headImgUrl"];
    
    // 判断是否联网
    if(![self connectedToNetwork])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络连接失败,请查看网络是否连接正常！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        //解析服务端返回json数据
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MUserLogin2] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40];
        [request setHTTPMethod:@"POST"];
        //设置参数
        //NSString *YYYApp = @"Yellow1.2";
        // 取分辨率
        UIScreen *MainScreen = [UIScreen mainScreen];
        CGSize Size = [MainScreen bounds].size;
        CGFloat scale = [MainScreen scale];
        int screenWidth = (int)Size.width * scale;
        int screenHeight = (int)Size.height * scale;
        int resolution = screenWidth * screenHeight;
        //NSLog(@"rererer:%d", resolution);
        // 请求参数
//        NSString *str = [NSString stringWithFormat:@"idfa=%@&device_name=%@&os_version=%@&carrier_name=%@&carrier_country_code=%@&keychain=%@&uniqueID=%@&idfv=%@&appID=%@&device_type=%@&net=%@&mac=%@&lad=%d&client_ip=%@&WXLoginID=%@&headImgUrl=%@&YYYApp=%@&resolution=%d", idfa, deviceName, systemsVersion, carrierName, carrierCountry, keychain, uniqueID, idfv, appID, deviceModel, netType, currentMACAddress, jailbroken, currentIPAddress, WXLoginID, headImgUrl, CMZQapp, resolution];
        NSString *str = [NSString stringWithFormat:@"idfa=%@&device_name=%@&os_version=%@&carrier_name=%@&carrier_country_code=%@&keychain=%@&uniqueID=%@&idfv=%@&appID=%@&device_type=%@&net=%@&mac=%@&lad=%d&client_ip=%@&WXLoginID=%@&headImgUrl=%@&angelApp=%@&resolution=%d&udid=%@&eastNorth=%@", idfa, deviceName, systemsVersion, carrierName, carrierCountry, keychain, uniqueID, idfv, appID, deviceDeviceName, netType, currentMACAddress, jailbroken, currentIPAddress, WXLoginID, headImgUrl, CMZQapp, resolution,localudidStr,_eastNorthStr];
        
        
                NSLog(@"-----str-----REREstr----:%@", str);
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            
            NSMutableDictionary *dict = NULL;
            // 防止重启服务器
            if (!data) {
                return;
            }
            //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
            dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&connectionError];
            
            NSLog(@"--------第二次服务返回--------dict--%@--",dict); //服务端 返回的网页
            if(dict != nil){
                NSMutableString *retcode = [dict objectForKey:@"code"];
                NSLog(@"ViewController.retcode.intValue:%d", retcode.intValue);
                if (retcode.intValue == 0){
                    NSString *url = [dict objectForKey:@"url"];
                    //进入H5的网页
                    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    });
                    NSLog(@"---当前线程-111-%@---\n--222-%@--",[NSThread currentThread],[NSThread callStackSymbols]);
                } else if (retcode.intValue == 2)
                {
                    [DLUDID changeKeychain];
                    [self jumpToHtml];
                } else {
                    NSLog(@"失败");
                }
            }else{
                NSLog(@"接口返回错误");
            }
        }];
    }
    
}

#pragma mark - 设置客户端界面
- (void)interfaceSetUp
{
    //自己加的
    /********************************************/
    self.tenTimerOpen = NO;//十秒定时器关闭，开启30秒定时器
    
//    [mStartTaskBtn setHidden:YES];//开始任务隐藏
//    [mWechatBtn setHidden:NO];//微信登录
//    [mLogoImg setHidden:NO]; //登录前logo图片
//    [mWechatHeadImg setHidden:YES]; //登录后微信头像
    
    [mWechatBtn setBackgroundColor:[UIColor colorWithRed:19/255.0 green:110/255.0 blue:251/255.0 alpha:1.0]];
    
    ///本地描述文件 udid
    NSString *localudidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"localudid"];
    
    [_location requestAlwaysAuthorization];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    NSString *wechatcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    if  (wechatcode == nil || wechatcode == NULL) {
        if (localudidStr == nil) {
            [mWechatBtn setTitle:@"安装描述文件" forState:UIControlStateNormal];

        } else {
            [mWechatBtn setTitle:@"微信登录" forState:UIControlStateNormal];
        }
        
        [mWechatBtn setHidden:false];
        [mStartTaskBtn setHidden:true];
    }else{
        [mWechatBtn setHidden:true];
        [mStartTaskBtn setHidden:false];
    }
    
    
    
    mLogoImg.layer.masksToBounds = true;
    
    if (IS_iPhone4 || IS_iPhone5) {
        //登录前的
        mLoginBtnLeadLayout.constant = 20;//登录按钮距头部
        mLogoWidthLayout.constant = 80;
        //登录后的
        mWechatImgWidthLayout.constant = 80;
        mWechatHeadImg.layer.cornerRadius = 40;
        
        mTaskBtnHeightLy.constant = 50;//登录按钮高
        mLogoTopLayout.constant = 40; //登录前/后 logo/头像距离顶部
        
        mLogoImg.layer.cornerRadius = 40;
        
    }else if (IS_iPhone6){
        mLoginBtnLeadLayout.constant = 40;//登录按钮距头部
        mWechatImgWidthLayout.constant = 120;
        mWechatHeadImg.layer.cornerRadius = 60;
        mLogoWidthLayout.constant = 90;
        mTaskBtnHeightLy.constant = 50;//登录按钮高
        
        mNickNameTopLayout.constant = 20;
        
        mLogoImg.layer.cornerRadius = 45;
        
    }else if (IS_IPHONEX){
        mLoginBtnLeadLayout.constant = 40;//登录按钮距头部
        mWechatImgWidthLayout.constant = 120;
        mWechatHeadImg.layer.cornerRadius = 60;
        mLogoTopLayout.constant = 50;
        mBgImg.image = [UIImage imageNamed:@"MSHomeBgImg_IPx"];
        mTaskBtnHeightLy.constant = 50;//登录按钮高
        
        mLogoWidthLayout.constant = 100;
        
        mLogoImg.layer.cornerRadius = 50;
        
    }else if (IS_iPhonePlus){
         mLoginBtnLeadLayout.constant = 50;//登录按钮距头部
        mLogoWidthLayout.constant = 120;
        mWechatImgWidthLayout.constant = 120;
        mWechatHeadImg.layer.cornerRadius = 60;
        mTaskBtnHeightLy.constant = 55;//登录按钮高
        
        mLogoImg.layer.cornerRadius = 60;
        
    } else {  //ipad
        mLoginBtnLeadLayout.constant = 50;//登录按钮距头部
        mWechatImgWidthLayout.constant = 130;
        mWechatHeadImg.layer.cornerRadius = 65;
        mLogoWidthLayout.constant = 100;
        mLogoImg.layer.cornerRadius  = 50;
        mTaskBtnHeightLy.constant = 55;//登录按钮高

    }
    
//
//    self.mLogoImg.layer.cornerRadius =
    
    mWechatHeadImg.layer.masksToBounds = YES;
    //mHeaderImg.layer.masksToBounds = YES;
    
    // 判断是否已经微信登陆过
    NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    NSLog(@"--WXLoginID---%@--",WXLoginID);//微信ID
    if (WXLoginID) {
        //登录成功，展示登录成功的页面，隐藏之前的页面
        [mStartTaskBtn setHidden:NO];
        [mWechatBtn setHidden:YES];//微信登录
        
        [mLogoImg setHidden:YES];
        [mWechatHeadImg setHidden:NO];
        
        [mAPPNameLB setHidden:YES];
        [mNickNameLB setHidden:NO];
        
    }else{
        //没有登录成功或没登录
        [mStartTaskBtn setHidden:YES];
        [mWechatBtn setHidden:NO];//微信登录
        [mAPPNameLB setHidden:NO];
        [mNickNameLB setHidden:YES];
        
        [mLogoImg setHidden:NO];
        [mWechatHeadImg setHidden:YES];
        
    }
    // 判断是否已经微信登陆过
    NSString *headImgUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"headImgUrl"];
    
    NSLog(@"--headImgUrl---%@--",headImgUrl);//微信头像
    
    if (headImgUrl) {
        [mWechatHeadImg sd_setImageWithURL:[NSURL URLWithString:headImgUrl]];//登录过就微信头像
    }else{
        mWechatHeadImg.image = [UIImage imageNamed:@"mNomalHeaderImg"];//没有微信登录过，就默认头像
    }
    
    NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    
    if (nickname == nil) {
        mNickNameLB.text = @"天使赚钱";
    }else {
        mNickNameLB.text = nickname;
    }
    
    mWechatBtn.layer.masksToBounds = true;
    mWechatBtn.layer.cornerRadius = 10.0;
    
    [self.view layoutIfNeeded];
    /********************************************/
    
    
    ///获取北纬东经
    _location  = [[CLLocationManager alloc] init];
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [_location requestWhenInUseAuthorization];// 前台定位
        
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    //初始化
    _location.delegate = self;
    //设置代理
    _location.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //设置精度
    _location.distanceFilter = 10.f;
    //表示至少移动1000米才通知委托更新
    [_location startUpdatingLocation];
    //开始定位服务
    
    
}

#pragma mark---- 经纬度
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *currLocation = [locations lastObject];
    float lat = currLocation.coordinate.latitude;
    //正值代表北纬
    float lon = currLocation.coordinate.longitude;
    //正值代表东经
    if (lat != 0 && lon != 0){
        NSString *string = [NSString stringWithFormat:@"您的当前位置为%f,%f",lat,lon];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"位置信息" message:string delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
//        [alert show];
        
        _eastNorthStr = [NSString stringWithFormat:@"%f|%f",lat,lon];
        NSLog(@"string---string----\n\n\n %@----_eastNorthStr---%@",string,_eastNorthStr);
        
        
    }
    
    
}

- (IBAction)mStartTaskClick:(id)sender {
    //开始任务
    [self jumpToHtml];//去跳转到网页
}

#pragma mark -- private method
- (UIImage *) drawImage
{
    //创建CGContextRef
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    //创建CGMutablePathRef
    CGMutablePathRef path = CGPathCreateMutable();
    
    //绘制Path
    CGRect rect = CGRectMake(0, 100, 300, 200);
    CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(rect), CGRectGetMaxY(rect));
    CGPathCloseSubpath(path);
    
    //绘制渐变
    [self drawLinearGradient:gc
                        path:path
                  startColor:[UIColor colorWithRed:17/255.0 green:95/255.0 blue:251/255.0 alpha:1.0].CGColor
                    endColor:[UIColor colorWithRed:28/255.0 green:168/255.0 blue:252/255.0 alpha:1.0].CGColor];
    
    //注意释放CGMutablePathRef
    CGPathRelease(path);
    
    //从Context中获取图像，并显示在界面上
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMidY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)didBecomeActive:(NSNotification *)notification
{
    ///本地描述文件 udid
    NSString *localudidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"localudid"];
    
    NSString *wechatcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    if  (wechatcode == nil || wechatcode == NULL) {
        if (localudidStr == nil) {
            [mWechatBtn setTitle:@"安装描述文件" forState:UIControlStateNormal];
            
        } else {
            [mWechatBtn setTitle:@"微信登录" forState:UIControlStateNormal];
        }
        
        [mWechatBtn setHidden:false];
        [mStartTaskBtn setHidden:true];
    }else{
        [mWechatBtn setHidden:true];
        [mStartTaskBtn setHidden:false];
    }
}

@end
