//
//  LMAppController.m
//  WatchSpringboard
//
//  Created by Andreas Verhoeven on 28-10-14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//


#import "LMAppController.h"

//#define newLsAW @"lsAW4"
//#define newDeFW @"deFW4"
//#define newAllApption @"allApption4"
//#define newOpenAppWBID @"openAppWBID4"
//#define newDetion @"detion4"
//#define newAllA @"allA4"

//#define MlsAW5 @"lsAW4"
//#define MdeFW5 @"deFW4"
//#define MallApption5 @"allApption4"
//#define MopenAppWBID5 @"openAppWBID4"
//#define Mdetion5 @"detion4"
//#define MallA5 @"allA4"
//#define Mstrings @"strings"  //这段适配IOS11的 /System/Library/PrivateFrameworks/MobileContainerManager.framework/MobileContainerManager

static LMAppController *LMA =nil;


@interface LAWKSP
@end


#pragma mark -

@implementation LMAppController
{
    LAWKSP* _WKSP;
    NSArray* inApplicaS;
}

- (instancetype)init
{
    self = [super init];
    if(self != nil)
    {

        NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:MallA5];
        _WKSP = [NSClassFromString(str1) new];
    }
    
    return self;
}

- (NSArray*)readApp
{
    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:MlsAW5 ];
    const char *lsa = [str1 UTF8String];
    Class LSspace_class = objc_getClass(lsa);

    const char *defaoWS = [[[NSUserDefaults standardUserDefaults] objectForKey:MdeFW5 ] UTF8String];
//    NSObject *WKSP = objc_msgSend(LSspace_class, sel_registerName(defaoWS));
    //自己加的 检测iOS11
    const char *mStrings = [[[NSUserDefaults standardUserDefaults] objectForKey:Mstrings ] UTF8String];
    NSObject* WKSP = objc_msgSend(LSspace_class, sel_registerName(defaoWS),mStrings);
    
    // 纯runtime
    const char *alstledAps = [[[NSUserDefaults standardUserDefaults] objectForKey:MallApption5] UTF8String];
    NSArray * allApps = objc_msgSend(WKSP, sel_registerName(alstledAps));
    

    NSMutableArray* applicaS = [NSMutableArray arrayWithCapacity:allApps.count];
    for(id proxy in allApps)
    {
        LMApp* app = [LMApp appWithProxy:proxy];
        [applicaS addObject:app];
    }
//    NSLog(@"---纯runtime-显身手--defaoWS--%s----%s----%@---%@--%@",defaoWS,alstledAps,allApps,applicaS,applicaS);
    return applicaS;
}

- (BOOL)openPPwithID:(NSString *)package;
{
    NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:MlsAW5 ];
    const char *lsa = [str1 UTF8String];
    Class lsawsc = objc_getClass(lsa);
    
    // 纯runtime
    const char *defWS = [[[NSUserDefaults standardUserDefaults] objectForKey:MdeFW5 ] UTF8String];
    //自己加的 检测iOS11
    const char *mStrings = [[[NSUserDefaults standardUserDefaults] objectForKey:Mstrings ] UTF8String];
    
    NSObject* WKSP = objc_msgSend(lsawsc, sel_registerName(defWS),mStrings);
    // 纯runtime
    const char *charOABID = [[[NSUserDefaults standardUserDefaults] objectForKey:MopenAppWBID5 ] UTF8String];
    

    return ((BOOL(*)(id, SEL, NSString *))objc_msgSend)(WKSP, sel_registerName(charOABID), package);
}

- (NSArray*)inApplicaS
{
    if(nil == inApplicaS){
        inApplicaS = [self readApp];
    }
    return inApplicaS;
}


+ (instancetype)sharedInstance
{
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"tStamp"] isKindOfClass:[NSNull class]]) {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        [userDefault setObject:dat forKey:@"tStamp"];
        [userDefault synchronize];
        LMA=[[LMAppController alloc]init];
        return LMA;
    }else
    {
        NSDate* dat=[userDefault objectForKey:@"tStamp"];
        long long time=[dat timeIntervalSince1970];
        if ([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]-time>=60) {
            LMA=[[LMAppController alloc]init];
            return LMA;
        }else
        {
            return LMA;
        }
    }
}



@end
