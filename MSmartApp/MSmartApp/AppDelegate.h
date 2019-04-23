//
//  AppDelegate.h
//  MSmartApp
//
//  Created by martmoney on 2018/7/9.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WXApi.h"

static NSString *channel = @"Publish channel";

static BOOL isProduction = YES;

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end


