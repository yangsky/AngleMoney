//
//  MMusicViewController.m
//  MSmartApp
//
//  Created by martmoney on 2018/7/17.
//  Copyright © 2018年 sugdev. All rights reserved.
//

#import "MMusicViewController.h"

@interface MMusicViewController ()<UIScrollViewDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mBackgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *mSingerImage;

@property (weak, nonatomic) IBOutlet UILabel *mSongName;
@property (weak, nonatomic) IBOutlet UILabel *mSingerName;

/** 当前的播放器 */
@property (nonatomic, strong) AVAudioPlayer *mCurrentPlayer;
/** 进度的Timer */
@property (nonatomic, strong) NSTimer *mProgressTimer;

// 滑块
@property (weak, nonatomic) IBOutlet UISlider *mProgressSlide;

// 播放停止按钮
@property (weak, nonatomic) IBOutlet UIButton *mPlayOrPauseBtn;

@property (nonatomic, strong) ViewController *mVC;

#pragma mark - 滑块的拖动
- (IBAction)mStartSlider;
- (IBAction)mSliderValueChange;
- (IBAction)mEndSlider;

- (IBAction)mSliderClick:(UITapGestureRecognizer *)sender;

@end

@implementation MMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 1.毛玻璃背景
    [self setupBlurView];
    
    
    // 2.设置滑块的图片
    [self.mProgressSlide setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    // 3.展示界面的信息
    [self startPlayingMusic];
    [self.mCurrentPlayer pause];
    self.mPlayOrPauseBtn.selected = NO;
    [self.mSingerImage.layer pauseAnimate];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToVC) name:@"toVC" object:nil];
    
}

- (void)goToVC
{
    // 跳转主界面
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        _mVC = [[UIStoryboard storyboardWithName:@"ViewController" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        
        [self presentViewController:_mVC animated:NO completion:nil];
    });
    
    
}

- (void)dealloc
{
    NSLog(@"-----music---dealloc----");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 顶部状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 三个控制按钮
- (IBAction)playOrPause {
    self.mPlayOrPauseBtn.selected = !self.mPlayOrPauseBtn.selected;
    
    if (self.mCurrentPlayer.playing) {
        [self.mCurrentPlayer pause];
        
        [self removeProgressTimer];
        
        
        // 暂停iconView的动画
        [self.mSingerImage.layer pauseAnimate];
    } else {
        [self.mCurrentPlayer play];
        
        [self addProgressTimer];
        
        
        // 恢复iconView的动画
        [self.mSingerImage.layer resumeAnimate];
    }
}

- (IBAction)previous {
    
    // 1.取出上一首歌曲
    MMusic *previousMusic = [MMusicTool mPreviousMusic];
    
    // 2.播放上一首歌曲
    [self playingMusicWithMusic:previousMusic];
}

- (IBAction)next {
    
    // 1.取出下一首歌曲
    MMusic *nextMusic = [MMusicTool mNextMusic];
    
    // 2.播放下一首歌曲
    [self playingMusicWithMusic:nextMusic];
}

- (void)playingMusicWithMusic:(MMusic *)music
{
    // 1.停止当前歌曲
    MMusic *playingMusic = [MMusicTool  mPlayingMusic];
    [XMGAudioTool stopMusicWithMusicName:playingMusic.filename];
    
    // 3.播放歌曲
    [XMGAudioTool playMusicWithMusicName:music.filename];
    
    // 4.将工具类中的当前歌曲切换成播放的歌曲
    [MMusicTool mSetPlayingMusic:music];
    
    // 5.改变界面信息
    [self startPlayingMusic];
}
// 背景毛玻璃
- (void)setupBlurView
{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar setBarStyle:UIBarStyleBlack];
    [self.mBackgroundImage addSubview:toolBar];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mBackgroundImage.mas_top);
        make.bottom.equalTo(self.mBackgroundImage.mas_bottom);
        make.left.equalTo(self.mBackgroundImage.mas_left);
        make.right.equalTo(self.mBackgroundImage.mas_right);
        
    }];
}

// 设置图片圆角
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // 设置iconView圆角
    self.mSingerImage.layer.cornerRadius = self.mSingerImage.bounds.size.width * 0.5;
    self.mSingerImage.layer.masksToBounds = YES;
    self.mSingerImage.layer.borderWidth = 8.0;
    self.mSingerImage.layer.borderColor = [UIColor colorWithRed:36/256.0 green:36/256.0 blue:36/256.0 alpha:1.0].CGColor;
}


#pragma mark - 播放歌曲
- (void)startPlayingMusic
{
    // 1.取出当前播放歌曲
    MMusic *playingMusic = [MMusicTool mPlayingMusic];
    
    // 2.设置界面信息
    self.mBackgroundImage.image = [UIImage imageNamed:playingMusic.icon];
    ;
    self.mSingerImage.image = [UIImage imageNamed:playingMusic.icon];
    self.mSongName.text = playingMusic.name;
    self.mSingerName.text = playingMusic.singer;
    
    // 3.开始播放歌曲
    AVAudioPlayer *currentPlayer = [XMGAudioTool playMusicWithMusicName:playingMusic.filename];
    currentPlayer.delegate = self;
    self.mCurrentPlayer = currentPlayer;
    self.mPlayOrPauseBtn.selected = self.mCurrentPlayer.isPlaying;
    //    self.currentTimeLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
    
    //    self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
    
    // 播放动画
    [self startIconViewAnimate];
    
    // 6.添加定时器用户更新进度界面
    [self removeProgressTimer];
    [self addProgressTimer];
    
    [self setupLockScreenInfo];
    
}

- (void)startIconViewAnimate
{
    // 1.创建基本动画
    CABasicAnimation *rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // 2.设置基本动画属性
    rotateAnim.fromValue = @(0);
    rotateAnim.toValue = @(M_PI * 2);
    rotateAnim.repeatCount = NSIntegerMax;
    rotateAnim.duration = 40;
    
    // 3.添加动画到图层上
    [self.mSingerImage.layer addAnimation:rotateAnim forKey:nil];
}

#pragma mark - 对定时器的操作
- (void)addProgressTimer
{
    [self updateProgressInfo];
    self.mProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.mProgressTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer
{
    [self.mProgressTimer invalidate];
    self.mProgressTimer = nil;
}

#pragma mark - 更新进度的界面
- (void)updateProgressInfo
{
    // 1.设置当前的播放时间
    //    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    
    // 2.更新滑块的位置
    self.mProgressSlide.value = self.mCurrentPlayer.currentTime / self.mCurrentPlayer.duration;
}

#pragma mark - Slider的事件处理
- (IBAction)mStartSlider {
    [self removeProgressTimer];
}

- (IBAction)mSliderValueChange {
}

- (IBAction)mEndSlider {
    // 1.设置歌曲的播放时间
    self.mCurrentPlayer.currentTime = self.mProgressSlide.value * self.mCurrentPlayer.duration;
    // 2.添加定时器
    [self addProgressTimer];
}

- (IBAction)mSliderClick:(UITapGestureRecognizer *)sender {
    // 1.获取点击的位置
    CGPoint point = [sender locationInView:sender.view];
    // 2.获取点击的在slider长度中占据的比例
    CGFloat ratio = point.x / self.mProgressSlide.bounds.size.width;
    // 3.改变歌曲播放的时间
    self.mCurrentPlayer.currentTime = ratio * self.mCurrentPlayer.duration;
    // 4.更新进度信息
    [self updateProgressInfo];
}

#pragma mark - 设置锁屏界面的信息
- (void)setupLockScreenInfo
{
    // 0.获取当前正在播放的歌曲
    MMusic *playingMusic = [MMusicTool mPlayingMusic];
    
    // 1.获取锁屏界面中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    [playingInfo setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    [playingInfo setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:playingMusic.icon]];
    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
    [playingInfo setObject:@(self.mCurrentPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    playingInfoCenter.nowPlayingInfo = playingInfo;
    
    // 3.让应用程序可以接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}
// 监听远程事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
