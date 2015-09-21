//
//  SKPlayer.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/14.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "SKPlayer.h"

@implementation SKPlayer

+ (instancetype)Player1:(int)num
{
    SKPlayer *play = [SKPlayer spriteNodeWithImageNamed:[NSString stringWithFormat:@"he%i",num]];
    play.type = 1;
    play.hp = 5;
    play.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:play.size];
    return play;
    
}
+ (instancetype)Player2:(int)num
{
    SKPlayer *play = [SKPlayer spriteNodeWithImageNamed:[NSString stringWithFormat:@"he%i",num]];
    play.type = 2;
    play.hp = 5;
    play.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:play.size];
    return play;
}

@end
