//
//  SKBullte.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/14.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "SKBullte.h"

@implementation SKBullte

+ (instancetype) bullte1:(int)num
{
    SKBullte *power = [SKBullte spriteNodeWithImageNamed:[NSString stringWithFormat:@"bu%i",num]];
    power.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:power.size];
    power.physicsBody.dynamic = YES;
    power.type = 1;
    return power;
}

+ (instancetype) bullte2:(int)num
{
    SKBullte *power = [SKBullte spriteNodeWithImageNamed:[NSString stringWithFormat:@"bu%i",num]];
    power.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:power.size];
    power.physicsBody.dynamic = YES;
    power.type = 2;
    return power;
}

+ (instancetype) bullte3:(int)num
{
    SKBullte *power = [SKBullte spriteNodeWithImageNamed:[NSString stringWithFormat:@"bul%i",num]];
    power.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:power.size];
    power.physicsBody.dynamic = YES;
    power.type = 3;
    return power;
}

@end
