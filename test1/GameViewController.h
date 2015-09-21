//
//  GameViewController.h
//  SpriteKitPlan
//

//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"



@interface GameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property(nonatomic,strong) AppDelegate *appDelegate;



@end
