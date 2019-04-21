//
//  TBSAlert.m
//  taobisu
//
//  Created by baishuntong on 15-5-6.
//  Copyright (c) 2015年 com.chnbst. All rights reserved.
//

#import "WWJShow.h"


@implementation WWJShow


//1.在屏幕上显示自消失的提示框，显示位置和消失时间不作为参数，直接在方法内部设定，保持整个应用风格统一
//2.字符串放在label上显示，label放在view上，view放在window上
//3.label以string的size创建，view在label外围留出一定的边距
+ (void)showString:(NSString*)format,...
{
    if (format == nil) {
        return;
    }
    
    va_list args;
    va_start(args,format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args] ;
    va_end(args);
   
    
    //取得window，及window的宽高
    
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGFloat windowWidth = window.frame.size.width;
    //CGFloat windowHeight = window.frame.size.height;
    
    //获取传入的字符串占用的大小，最大宽度为window宽度减120，120为字符边距和view边距总和
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    CGRect frame = [string boundingRectWithSize:CGSizeMake(windowWidth-120, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];

    //创建一个label容纳字符串
    frame.origin.x += 30;
    frame.origin.y += 10;
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.text = string;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    
    //显示不下时自动缩小字体
    label.numberOfLines = 15;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.8;
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    //创建一个view容纳label
    frame.size.width += 60;
//    frame.origin.x = (windowWidth-frame.size.width)/2;
//    frame.origin.y = windowHeight/3;
    frame.size.height += 20;
    UIView *view =  [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    view.layer.cornerRadius = 5.0f;
    view.layer.masksToBounds = YES;
    view.alpha = 1.0;
    
    //label加入view
    [view addSubview:label];
    
    view.center = window.center;
    //view加入window
    [window addSubview:view];
    
    //持续显示1.2s以后，以持续时间0.8s的动画方式变淡消失
    [UIView animateWithDuration:0.5 delay:1.2 options:0 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];

}

+(void)showStringWithTime:(NSTimeInterval)delayTime string:(NSString *)format, ...{
    if (format == nil) {
        return;
    }
    
    va_list args;
    va_start(args,format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args] ;
    va_end(args);
    
    //取得window，及window的宽高
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGFloat windowWidth = window.frame.size.width;
    //CGFloat windowHeight = window.frame.size.height;
    
    //获取传入的字符串占用的大小，最大宽度为window宽度减120，120为字符边距和view边距总和
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    CGRect frame = [string boundingRectWithSize:CGSizeMake(windowWidth-80, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    
    //创建一个label容纳字符串
    frame.origin.x += 30;
    frame.origin.y += 10;
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.text = string;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    
    //显示不下时自动缩小字体
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 15;
    label.minimumScaleFactor = 0.8;
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    //创建一个view容纳label
    frame.size.width += 60;
    //    frame.origin.x = (windowWidth-frame.size.width)/2;
    //    frame.origin.y = windowHeight/3;
    frame.size.height += 20;
    UIView *view =  [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    view.layer.cornerRadius = 5.0f;
    view.layer.masksToBounds = YES;
    view.alpha = 1.0;
    
    //label加入view
    [view addSubview:label];
    
    view.center = window.center;
    //view加入window
    [window addSubview:view];
    
    //持续显示1.2s以后，以持续时间0.8s的动画方式变淡消失
    [UIView animateWithDuration:0.8 delay:delayTime options:0 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

@end
