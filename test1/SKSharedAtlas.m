//
//  SKSharedAtlas.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "SKSharedAtlas.h"
static SKSharedAtlas *shared = nil;
@implementation SKSharedAtlas

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = (SKSharedAtlas *)[SKSharedAtlas atlasNamed:@"shoot"];
    });
    return shared;
}

+ (SKAction *)planeBlow:(int)type
{
    int num = 0;
    if (type==1||type==2)
    {
        num = 4;
    }
    else if(type==3)
    {
        num=6;
    }
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 1; i<=num; i++)
    {
        SKTexture *tures = [self planeBlowup:type andIndex:i];
        [list addObject:tures];
    }
    SKAction *dieAction = [SKAction animateWithTextures:list timePerFrame:0.1];
    return [SKAction sequence:@[dieAction,[SKAction removeFromParent]]];
}

+ (SKTexture *)planeBlowup:(int)type andIndex:(int)index
{
    return [[self shared] textureNamed:[NSString stringWithFormat:@"enemy%i_down%i",type,index]];
}



+ (SKTexture *)plane:(int)type 
{
    return [[self shared] textureNamed:[NSString stringWithFormat:@"enemy%i",type]];
}

+ (SKAction *)planeHit:(int)type
{
    NSMutableArray *list = [NSMutableArray array];
    for (int i =1; i<=2; i++)
    {
        SKTexture *ture = [[self shared] textureNamed:[NSString stringWithFormat:@"enemy%i_hit%i",type,i]];
        [list addObject:ture];
    }
    SKAction *dieAction = [SKAction animateWithTextures:list timePerFrame:0.1];
    return [SKAction sequence:@[dieAction]];
}

+ (SKAction *)playerBlowup
{
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 1; i<=8; i++)
    {
        SKTexture *tures = [[self shared] textureNamed:[NSString stringWithFormat:@"p1%i",i]];
        [list addObject:tures];
    }
    SKAction *dieAction = [SKAction animateWithTextures:list timePerFrame:0.1];
    return [SKAction sequence:@[dieAction,[SKAction removeFromParent]]];
}

@end
