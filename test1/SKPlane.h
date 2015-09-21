//
//  SKPlane.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKPlane : SKSpriteNode

@property(nonatomic,assign) int hp;
@property(nonatomic,assign) int type;

+ (instancetype)bigPlane:(int)t;

+ (instancetype)mediuPlane:(int)t;

+ (instancetype)smallPlane:(int)t;

+ (instancetype)PlayPower;

+ (instancetype)PlayBomb;

+ (instancetype)Stone:(int)t;

+ (instancetype)smallPlane2:(int)t;


@end
