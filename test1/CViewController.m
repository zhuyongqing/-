//
//  CViewController.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/15.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "CViewController.h"
#import "UIColor+HTColor.h"
@interface CViewController ()

@end

@implementation CViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
    [self.back.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.back.layer setBorderWidth:4];
    [self.back.layer setCornerRadius:10];
    [self.view addSubview:self.back];
    [self.single.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.single.layer setBorderWidth:1];
    [self.single.layer setCornerRadius:20];
    [self.alliance.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.alliance.layer setBorderWidth:1];
    [self.alliance.layer setCornerRadius:20];
    
    [self.solo.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.solo.layer setBorderWidth:1];
    [self.solo.layer setCornerRadius:20];
    
    [self.view addSubview:self.singleRank];
    [self.view addSubview:self.allianceRank];
    [self.view addSubview:self.soloRank];
    [self.view addSubview:self.back];
    [self.view addSubview:self.single];
    [self.view addSubview:self.alliance];
    [self.view addSubview:self.solo];
    
    [self performSelectorOnMainThread:@selector(setScore) withObject:nil waitUntilDone:NO];
    UISwipeGestureRecognizer *swip;
    swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipDo:)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    swip.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swip];
}



- (void)swipDo:(UISwipeGestureRecognizer *)s
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeButtonAction
{
   
}


- (void)setScore
{
    self.singleRank.text = [NSString stringWithFormat:@"%ld分",[_appDelegate mcManager].maxSingle];
    self.allianceRank.text = [NSString stringWithFormat:@"%ld分",[_appDelegate mcManager].maxAlliance];
    self.soloRank.text = [NSString stringWithFormat:@"%ld 胜",[_appDelegate mcManager].maxSolo];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
