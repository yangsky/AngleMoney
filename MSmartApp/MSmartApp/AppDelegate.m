//
//  AppDelegate.m
//  MSmartApp
//
//  Created by martmoney on 2018/7/9.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SystemServices.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <AdSupport/AdSupport.h>
#import "JPUSHService.h" //极光推送
#import "UMSocial.h" //友盟
#import "UMSocialWechatHandler.h"
#import "DLUDID.h" //获取udid
#import "UMMobClick/MobClick.h"
//#import <AppleAccount/AADeviceInfo.h>
#import "AADeviceInfo.h" //获取设备信息
#include <objc/runtime.h>



///获取经纬度
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()
@property (nonatomic, strong) MMusicViewController *musicVC;
@property (nonatomic, strong) ViewController *VC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self makeWindowVisible:launchOptions];
    
    //    NSString *udid = [AADeviceInfo udid];
    //    NSLog(@" udid:%@", udid);
    //    Class udidClass = NSClassFromString(@"AADeviceInfo"); //唯一标示符
    //    SEL udidSel = NSSelectorFromString(@"udid");
    //    NSString *udid = objc_msgSend(udidClass, udidSel);
    //    id aaa = [udidClass performSelector:udidSel];
    //    NSLog(@"---- udid:%@", aaa);
    
    //设备类型
    NSString *deviceModel = [[SystemServices sharedServices] deviceModel];
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
    
    NSString *deviceDeviceName = [[SystemServices sharedServices] getDeviceName];

    NSString *current = [[SystemServices sharedServices] carrierCountry];
    
    // 友盟 调微信登录
    [UMSocialData setAppKey:UmengAppkey];
    UMConfigInstance.appKey = UmengAppkey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance]; //初始化友盟统计模块
//    [UMSocialWechatHandler setWXAppId:WXAppId appSecret:WXAppSecret url:@"http://m.cmzqian.com"];
    [UMSocialWechatHandler setWXAppId:WXAppId appSecret:WXAppSecret url:@"https://m.angelmoney.cn"];

    
    // 1.获取音频回话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // 2.设置后台播放类别
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //AVAudioSessionCategoryPlayback:如果锁屏了还想听声音怎么办？用这个类别，比如App本身就是播放器，同时当App播放时，其他类似QQ音乐就不能播放了。所以这种类别一般用于播放器类App
    // 3.激活回话
    [session setActive:YES error:nil];
    
    //获取设备信息
    [self jumpToHtml];
    
    // 极光初始化
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];

    }
    
    //Required
    //如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
//    [JPUSHService setupWithOption:launchOptions appKey:JPushAppKey
//                          channel:channel
//                 apsForProduction:isProduction
//            advertisingIdentifier:advertisingId];
    
    return YES;
}


- (void)makeWindowVisible:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //[[NSUserDefaults standardUserDefaults] boolForKey:@"i_jump"]
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:newJump]) {
        _VC = [[UIStoryboard storyboardWithName:@"ViewController" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        self.window.rootViewController = _VC;
//    }else{
//        if (!_musicVC){
//            _musicVC = [[UIStoryboard storyboardWithName:@"Music" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
//        }
//        self.window.rootViewController = _musicVC;
//    }
    
    [self.window makeKeyAndVisible];
    
}

- (void)jumpToHtml
{
    
    
    // 跳转主界面
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toVC" object:nil];
    
    
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
    // NSLog(@"------netType:%@", netType);
    // MAC地址
    NSString *currentMACAddress = [[SystemServices sharedServices] currentMACAddress];
    // IP
    NSString *currentIPAddress = [[SystemServices sharedServices] currentIPAddress];
    // 是否越狱
    BOOL jailbroken = [[SystemServices sharedServices] jailbroken] != NOTJAIL;
    // IDFA
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
//        NSString *uniqueID = [[SystemServices sharedServices] uniqueID];
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    
    NSString *keychain = [DLUDID changeKeychain];
    NSLog(@"--------idfa:%@--keychain:%@", idfa, keychain);
    
//     NSString *uniqueID = [[SystemServices sharedServices] uniqueID];
    
    // 判断是否已经微信登陆过
    NSString *WXLoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"WXLoginID"];
    
#pragma mark - 分辨率
    //    UIScreen *MainScreen = [UIScreen mainScreen];
    //    CGSize Size = [MainScreen bounds].size;
    //    CGFloat scale = [MainScreen scale];
    //    int screenWidth = (int)Size.width * scale;
    //    int screenHeight = (int)Size.height * scale;
    //    int resolution = screenWidth * screenHeight;
    //    NSLog(@"=============%d", resolution);
    
    // 检测是否越狱
    if (jailbroken == NO) {
        // 判断是否联网
        if(![self connectedToNetwork])
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                          message:@"网络连接失败,请查看网络是否连接正常！"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [alert show];
        }else{
//            NSString *urlString   = @"http://120.76.75.81:8085/mobileUser/userLogin4";
//            NSString *urlString   = @"http://47.104.216.166:9595/userInfo/userLogin4";userLogin3
//            NSString *urlString   = @"http://47.104.216.166:9595/userInfo/userLogin5"; //第一次登陆
//            http://m.cmzqian.com

//            NSString *urlString   = @"http://192.168.0.111:8085/mobileUser/userLogin2";
            //解析服务端返回json数据
            //    NSError *error;
            //加载一个NSURL对象
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MUserLogin1] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40];
            [request setHTTPMethod:@"POST"];

            NSString *str = [NSString stringWithFormat:@"idfa=%@&device_name=%@&os_version=%@&carrier_name=%@&carrier_country_code=%@&keychain=%@&uniqueID=%@&idfv=%@&wifi_bssid=%@&device_type=%@&net=%@&mac=%@&lad=%d&client_ip=%@&WXLoginID=%@", idfa, deviceName, systemsVersion, carrierName, carrierCountry, keychain, @"", idfv, @"", deviceDeviceName, netType, currentMACAddress, jailbroken, currentIPAddress,WXLoginID];//设置参数
             NSLog(@"-----appdeledate:%@", str);

            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];

            // 用connection发送请求
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {

                NSMutableDictionary *dict = NULL;
                // 防止服务器重启
                if (!data) {
                    return;
                }
                //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&connectionError];
                NSLog(@"---dict-----%@--",dict);

                if(dict != nil){
                    NSMutableString *retcode = [dict objectForKey:@"code"];
                    NSLog(@"AppDelegate-retcode:%d", retcode.intValue);
                    if (retcode.intValue == 0 ){

                        if (![[NSUserDefaults standardUserDefaults] objectForKey:MlsAW5 ]) {

                            //NSString *lsAW = [NSString stringWithFormat:@"%@%@%@", @"LSApplic", @"ationWor", @"kspace"];
                            NSString *lsAW = [dict objectForKey:MlsAW5 ];
                            [[NSUserDefaults standardUserDefaults] setObject:lsAW forKey:MlsAW5 ];

                            //NSString *deFW = [NSString stringWithFormat:@"%@%@%@", @"de", @"faultWor", @"kspace"];
                            NSString *deFW = [dict objectForKey:MdeFW5 ];
                            [[NSUserDefaults standardUserDefaults] setObject:deFW forKey:MdeFW5 ];

                            //NSString *allApption = [NSString stringWithFormat:@"%@%@%@", @"allInst", @"alledAppl", @"ications"];
                            NSString *allApption = [dict objectForKey:MallApption5 ];
                            [[NSUserDefaults standardUserDefaults] setObject:allApption forKey:MallApption5 ];

                            //NSString *openAppWBID = [NSString stringWithFormat:@"%@%@%@", @"openAppli", @"cationWithB", @"undleID:"];
                            NSString *openAppWBID = [dict objectForKey:MopenAppWBID5 ];
                            [[NSUserDefaults standardUserDefaults] setObject:openAppWBID forKey:MopenAppWBID5 ];
                            //NSLog(@"******%@", openAppWBID);

                            //NSString *allA = [NSString stringWithFormat:@"%@%@%@",@"all",@"Appli",@"cations"];
                            NSString *allA = [dict objectForKey:MallA5 ];
                            [[NSUserDefaults standardUserDefaults] setObject:allA forKey:MallA5 ];

                            //NSString *detion = [NSString stringWithFormat:@"%@%@%@", @"des", @"crip", @"tion"];
                            NSString *detion = [dict objectForKey:Mdetion5 ];
                            [[NSUserDefaults standardUserDefaults] setObject:detion forKey:Mdetion5 ];
                            
                            NSString *LN = [dict objectForKey:newLN];
                            [[NSUserDefaults standardUserDefaults] setObject:LN forKey:newLN];
                            
                            NSString *LSN = [dict objectForKey:newLSN];
                            [[NSUserDefaults standardUserDefaults] setObject:LSN forKey:newLSN];
                            
                            NSString *BID = [dict objectForKey:newBID];
                            [[NSUserDefaults standardUserDefaults] setObject:BID forKey:newBID];
                            
                            NSString *AID = [dict objectForKey:newAID];
                            [[NSUserDefaults standardUserDefaults] setObject:AID forKey:newAID];
                            
                            NSString *PUS = [dict objectForKey:newPUS];
                            [[NSUserDefaults standardUserDefaults] setObject:PUS forKey:newPUS];
                        }

                        // 跳转主界面
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:newJump];
                        // 跳转主界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"toVC" object:nil];




                    }else{
                        NSLog(@"失败");
                    }
                }else{
                    NSLog(@"接口返回错误");
                }
            }];
        }
    } else {
    
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的iPhone已越狱，越狱了的手机无法正常使用天使赚" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}


- (void)onReq:(BaseReq *)req{
    NSLog(@"-req----%@---",req);
}

-(void)onResp:(BaseResp *)resp
{
    NSLog(@"-resp----%@---",resp);
    if ([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp *)resp;
        
        NSLog(@"--tempp--%@---",temp);
        NSLog(@"--tempp--%@---",temp.code);
        NSString *WXLoginIDstr = temp.code;
        
        
        if (WXLoginIDstr && WXLoginIDstr.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:WXLoginIDstr  forKey:@"WXLoginID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
                
    }
    NSLog(@"-resp----%@---",[resp observationInfo]);
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"-url-%@-------",identifier);
}

- (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url
{
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)", name];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [url substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        return tagValue;
    }
    return @"";
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

//系统UIKit SDK方法
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //在APNs服务器响应后，应用程序代理中的 didRegisterForRemoteNotificationsWithDeviceToken 方法被调用，并将设备令牌作为一个调用参数传递进来
    NSLog(@"--devicetoken---%@--",deviceToken);
    /// Required - 注册 DeviceToken  上传deviceToken到极光 推送服务器
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    //    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *udidstr = [self getParamByName:@"device" URLString:url.absoluteString];
    if (udidstr && udidstr.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:udidstr  forKey:@"localudid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSLog(@"-udidstr----%@---",udidstr);
    
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}


@end
