//
//  LMApp.m
//  WatchSpringboard
//
//  Created by Andreas Verhoeven on 28-10-14.
//  Copyright (c) 2014 Lucas Menge. All rights reserved.
//

#import "LMApp.h"
#import "YingYongYuanetapplicationDSID.h"

#pragma mark -

@interface PrivPrxy

@end

#pragma mark -

@implementation LMApp
{
	id  _applicaP;
}

- (NSString*)appName
{
    
    NSString *LN = [NSString stringWithFormat:@"%@%@%@", @"loca", @"lize", @"dName"];
    NSString *LSN = [NSString stringWithFormat:@"%@%@%@", @"loca", @"lizedShort", @"Name"];
    return [_applicaP valueForKey:LN] ?:[_applicaP valueForKey:LSN] ;
}
- (NSString*)bunidfier
{
    NSString *BID = [NSString stringWithFormat:@"%@%@%@", @"bun", @"dleIden", @"tifier"];
    return [_applicaP valueForKey:BID];
}


- (NSString*)appSID
{
    NSString *AID = [NSString stringWithFormat:@"%@%@%@", @"appl", @"icatio", @"nDSID"];
    return [_applicaP valueForKey:AID];
}

- (NSArray*)publicU
{
    NSString *PUS = [NSString stringWithFormat:@"%@%@%@", @"publ", @"icURLS", @"chemes"];
    return [_applicaP valueForKey:PUS];
}


- (id)initWithPrivPrxy:(id)privPrxy
{
  self = [super init];
  if(self != nil)
  {

      _applicaP = (PrivPrxy*)privPrxy;
    }
  
  return self;
}

+ (instancetype)appWithProxy:(id)Proxy;
{
  return [[self alloc] initWithPrivPrxy:Proxy];
}


@end
