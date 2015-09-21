//
//  SKPlayer.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/14.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKPlayer : SKSpriteNode

@property(nonatomic,assign) int type,hp;

+ (instancetype)Player1:(int)num;
+ (instancetype)Player2:(int)num;

@end
