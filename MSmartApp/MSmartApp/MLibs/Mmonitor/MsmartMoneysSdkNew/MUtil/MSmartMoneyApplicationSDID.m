//
//  MSmartMoneyApplicationSDID.m
//  MSmartApp
//
//  Created by martmoney on 2018/7/17.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import "MSmartMoneyApplicationSDID.h"
#import "LMAppController.h"



//#define MlsAW5 @"lsAW4"
//#define MdeFW5 @"deFW4"
//#define MallApption5 @"allApption4"
//#define MopenAppWBID5 @"openAppWBID4"
//#define Mdetion5 @"detion4"
//#define MallA5 @"allA4"
//#define Mstrings @"strings"  //这段适配IOS11的 /System/Library/PrivateFrameworks/MobileContainerManager.framework/MobileContainerManager

@implementation MSmartMoneyApplicationSDID

-(int) getAppState:(NSString *) package
{
    
    NSArray * apps;
    if ([MSmartMoneyApplicationSDID getMIOSVersion]>=8.0) {
        apps = [LMAppController sharedInstance].inApplicaS;
        if(package.length!=0){
            for(LMApp* app in apps){
                if ([app.bunidfier isEqualToString:package]) {
                    return 1;
                }
            }
        }
    }else
    {
        NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:MlsAW5 ];
        const char *str2 = [str1 UTF8String];
        
        Class LSspace_class = objc_getClass(str2);
        
        // 纯runtime
        const char *defWS = [[[NSUserDefaults standardUserDefaults] objectForKey:MdeFW5 ] UTF8String];
        //自己加的 检测iOS11
//        const char *mStrings = [[[NSUserDefaults standardUserDefaults] objectForKey:Mstrings ] UTF8String];
//        NSObject* WKSP = objc_msgSend(LSspace_class, sel_registerName(defWS),mStrings);
        NSObject* WKSP = objc_msgSend(LSspace_class, sel_registerName(defWS));
        
        const char *alAption = [[[NSUserDefaults standardUserDefaults] objectForKey:MallA5 ] UTF8String];
        NSArray * resArray = objc_msgSend(WKSP, sel_registerName(alAption));
        
        
        for (LSspace_class in resArray) {
            const char *dededes = [[[NSUserDefaults standardUserDefaults] objectForKey:Mdetion5 ] UTF8String];
            NSString *appName = objc_msgSend(LSspace_class, sel_registerName(dededes));
            
            if ([appName rangeOfString:package].location!=NSNotFound)
            {
                return 1;
            }
        }
    }
    return 0;
}
+ (float)getMIOSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(MSmartMoneyApplicationSDID *)sharedInstance{
    static dispatch_once_t onceToken;
    static MSmartMoneyApplicationSDID * appId;
    dispatch_once(&onceToken, ^{
        appId=[[MSmartMoneyApplicationSDID alloc]init];
    });
    return appId;
}


-(NSString *) deJson:(NSString *) string{
    NSString * base64 = @"";
    for (int i = 0; i<[string length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        if((i>=1 && i<=4) || (i>=6 && i<=9)||  (i>=11 && i<=14) ||  (i>=16 && i<=19) ||  (i>=21 && i<=24) ||  (i>=26 && i<=29)  ||  (i>=31 && i<=34)  ||  (i>=36 && i<=39)){
            continue;
        }
        base64 =  [base64 stringByAppendingString:s];
    }
    //YingYongYuanjStringUtil.h
    base64 = [self replace:base64 reg:@"-" target:@"+"];
    base64 = [self replace:base64 reg:@"_" target:@"/"];
    base64 = [self replace:base64 reg:@"," target:@"="];
    
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
    
}

-(NSString *) replace:(NSString *) str reg:(NSString *) reg target:(NSString *) targetStr{
    NSString *strUrl = [str stringByReplacingOccurrencesOfString:reg withString:targetStr];
    return  strUrl;
    
}

@end
