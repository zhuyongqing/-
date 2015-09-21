//
//  GameScene.h
//  SpriteKitPlan
//

//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"

@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property(nonatomic,strong) AppDelegate *appDelegate;
+ (instancetype)sharedInstance:(CGSize)size;

@end
