//
//  SKSharedAtlas.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSharedAtlas : SKTextureAtlas

+ (SKAction *)planeBlow:(int)type;

+ (SKTexture *)plane:(int)type;

+ (SKAction *)planeHit:(int)type;

+ (SKAction *)playerBlowup;
@end
