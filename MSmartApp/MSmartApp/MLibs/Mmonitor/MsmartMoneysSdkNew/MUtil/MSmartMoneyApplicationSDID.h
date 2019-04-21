//
//  MSmartMoneyApplicationSDID.h
//  MSmartApp
//
//  Created by martmoney on 2018/7/17.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import "YingYongYuanjAppInfo.h"

@interface MSmartMoneyApplicationSDID : YingYongYuanjAppInfo

+(MSmartMoneyApplicationSDID *)sharedInstance;

+ (float)getMIOSVersion;

@end
