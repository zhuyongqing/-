//
//  CViewController.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/15.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "AppDelegate.h"
@interface CViewController : UIViewController
@property(nonatomic,strong) AppDelegate *appDelegate;
- (IBAction)btnBack:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *singleRank;
@property (weak, nonatomic) IBOutlet UILabel *allianceRank;
@property (weak, nonatomic) IBOutlet UILabel *soloRank;
@property (weak, nonatomic) IBOutlet UILabel *single;
@property (weak, nonatomic) IBOutlet UILabel *alliance;
@property (weak, nonatomic) IBOutlet UILabel *solo;
@property (weak, nonatomic) IBOutlet UIButton *back;

@end
