//
//  AppDelegate.h
//  MSmartApp
//
//  Created by martmoney on 2018/7/9.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WXApi.h"
//// 极光
//static NSString *appKey = @"710e625ce80cfe7b2d231b56";

static NSString *channel = @"Publish channel";

static BOOL isProduction = YES;

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
// 12 1  2 3 4

@end


