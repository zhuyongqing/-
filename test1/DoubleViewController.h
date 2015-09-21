//
//  DoubleViewController.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/18.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
@interface DoubleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property(nonatomic,strong) AppDelegate *appDelegate;
@end
