//
//  LMAppController.h
//  WatchSpringboard
//
//  Created by Andreas Verhoeven on 28-10-14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMApp.h"
#import <objc/message.h>


@interface LMAppController : NSObject
{
}

@property (nonatomic, readonly) NSArray* inApplicaS;
///强制打开某个 APP
- (BOOL)openPPwithID:(NSString *)package;
+ (instancetype)sharedInstance;

@end
