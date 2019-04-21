//
//  TBSAlert.h
//  taobisu
//
//  Created by baishuntong on 15-5-6.
//  Copyright (c) 2015年 com.chnbst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WWJShow : NSObject

+ (void)showString:(NSString*)string, ...;
+ (void)showStringWithTime:(NSTimeInterval)delayTime string:(NSString*)string, ...;

@end
