//
//  SKBullte.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/14.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKBullte : SKSpriteNode

@property(nonatomic,assign) int type;

+ (instancetype) bullte1:(int)num;
+ (instancetype) bullte2:(int)num;
+ (instancetype) bullte3:(int)num;
@end
