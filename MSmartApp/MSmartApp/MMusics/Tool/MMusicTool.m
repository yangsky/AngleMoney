//
//  MMusicTool.m
//  MSmartApp
//
//  Created by martmoney on 2018/7/17.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import "MMusicTool.h"
#import "MJExtension.h"
#import "MMusic.h"


@implementation MMusicTool

static NSArray *_mMusics;
static MMusic *_mPlayingMusic;

+ (void)initialize
{
    
    if (_mMusics == nil) {
        _mMusics = [MMusic objectArrayWithFilename:@"Musics.plist"];
    }
    
    if (_mPlayingMusic == nil) {
        _mPlayingMusic = _mMusics[0];
    }
}

+ (NSArray *)musics
{
    return _mMusics;
}


+ (MMusic *)mPlayingMusic
{
    return _mPlayingMusic;
}

+ (void)mSetPlayingMusic:(MMusic *)playingMusic
{
    _mPlayingMusic = playingMusic;
}


+ (MMusic *)mNextMusic
{
    // 1.拿到当前播放歌词下标值
    NSInteger currentIndex = [_mMusics indexOfObject:_mPlayingMusic];
    
    // 2.取出下一首
    NSInteger nextIndex = ++currentIndex;
    if (nextIndex >= _mMusics.count) {
        nextIndex = 0;
    }
    MMusic *nextMusic = _mMusics[nextIndex];
    
    return nextMusic;
}

+ (MMusic *)mPreviousMusic
{
    // 1.拿到当前播放歌词下标值
    NSInteger currentIndex = [_mMusics indexOfObject:_mPlayingMusic];
    
    // 2.取出下一首
    NSInteger previousIndex = --currentIndex;
    if (previousIndex < 0) {
        previousIndex = _mMusics.count - 1;
    }
    MMusic *previousMusic = _mMusics[previousIndex];
    
    return previousMusic;
}

@end
