//
//  MViewController.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/3.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "MYBlurIntroductionView.h"
@interface MViewController : UIViewController<MYIntroductionDelegate,AVAudioPlayerDelegate>
@property(nonatomic,strong) AppDelegate *appDelegate;
@property(nonatomic,strong) UIButton *single;
@property(nonatomic,strong) UIButton *action;
@property(nonatomic,strong) AVAudioPlayer *player;
@property(nonatomic,strong) UIButton *maxScore;

@end
