//
//  SViewController.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/13.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <AVFoundation/AVFoundation.h>

@interface SViewController : UIViewController<MCBrowserViewControllerDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *action;
- (IBAction)run:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)disConnect:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *conects;
@property (weak, nonatomic) IBOutlet UIButton *disconnects;
@property (weak, nonatomic) IBOutlet UIButton *battle;
- (IBAction)solo:(id)sender;

@property(nonatomic,strong) AppDelegate *appDelegate;

@property(nonatomic,strong) AVAudioPlayer *player;

@end
