//
//  SKPlane.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "SKPlane.h"
#import "SKSharedAtlas.h"
@implementation SKPlane

+ (instancetype)bigPlane:(int)t
{
    int num = 2;
    if (t==1)
        num=4;
    else
        num=8;
    SKPlane *plane = [SKPlane spriteNodeWithImageNamed:[NSString stringWithFormat:@"tk%i",num]];
    plane.hp += 15;
    plane.type = 7;
    plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(plane.size.width*0.8, plane.size.height*0.8)];
    return plane;
}

+ (instancetype)mediuPlane:(int)t
{
    int num = 2;
    if (t==1)
        num=3;
    else
        num=7;
    SKPlane *plane = [SKPlane spriteNodeWithImageNamed:[NSString stringWithFormat:@"tk%i",num]];
    plane.hp += 10;
    plane.type = 2;
  plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(plane.size.width*0.8, plane.size.height*0.8)];
    return plane;
}

+ (instancetype)smallPlane:(int)t
{
    int num = 2;
    if (t==1)
        num=1;
    else
        num=3;
    SKPlane *plane = [SKPlane spriteNodeWithImageNamed:[NSString stringWithFormat:@"tk%i",num]];
    plane.hp = 1;
    plane.type = 1;
   plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(plane.size.width*0.8, plane.size.height*0.8)];
    return plane;
}

+ (instancetype)PlayPower 
{
    SKPlane *power = [SKPlane spriteNodeWithImageNamed:@"ufo1"];
    power.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(power.size.width*0.8, power.size.height*0.8)];
    power.type = 4;
    return power;
}

+ (instancetype)PlayBomb
{
    SKPlane *power = [SKPlane spriteNodeWithImageNamed:@"ufo2"];
    power.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(power.size.width*0.8, power.size.height*0.8)];
    power.type = 5;
    return power;
}

+ (instancetype)Stone:(int)t
{
    int num = 2;
    if (t==1)
        num=2;
    else
        num=3;
    SKPlane *stone = [SKPlane spriteNodeWithImageNamed:[NSString stringWithFormat:@"stone%i",num]];
    stone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(stone.size.width*0.8, stone.size.height*0.8)];
    stone.type = 6;
    stone.hp = 60;
    return stone;
}

+ (instancetype)smallPlane2:(int)t
{
    int num = 2;
    if (t==1)
        num=2;
    else
        num=6;
    SKPlane *plane = [SKPlane spriteNodeWithImageNamed:[NSString stringWithFormat:@"tk%i",num]];
    plane.hp += 5;
    plane.type = 3;
    plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(plane.size.width*0.8, plane.size.height*0.8)];
    return plane;
}

@end
