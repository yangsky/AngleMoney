//
//  MMusicTool.h
//  MSmartApp
//
//  Created by martmoney on 2018/7/17.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MMusic;

@interface MMusicTool : NSObject

+ (NSArray *)mMusics;

+ (void)mSetPlayingMusic:(MMusic *)playingMusic;

+ (MMusic *)mNextMusic;

+ (MMusic *)mPreviousMusic;

+ (MMusic *)mPlayingMusic;




@end
