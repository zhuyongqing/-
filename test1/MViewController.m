//
//  MViewController.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/3.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "MViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SViewController.h"
#import <GameKit/GameKit.h>
#import "GameViewController.h"
#import "UIColor+HTColor.h"
#import "CViewController.h"
@interface MViewController ()
{
   long int score;
}
@end
static int count = 1;
static BOOL change = NO;
@implementation MViewController

- (void)viewWillAppear:(BOOL)animated
{
    //从文件中读取数据
    NSURL *fileUrl=[[NSBundle mainBundle] URLForResource:@"pad_world1"     withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    //[self setImg];
    self.player.delegate = self;
    [self.player play];
    [self retrieveTopTenScores];
    [self retrieveTopTenScores2];
    [self retrieveTopTenScores3];
    if (change) {
        [self.single setFrame:CGRectMake(84, 190, self.single.frame.size.width, self.single.frame.size.height)];
        [self.view addSubview:self.single];
        [self.action setFrame:CGRectMake(84, 244, self.action.frame.size.width, self.action.frame.size.height)];
        [self.view addSubview:self.action];
        [self.maxScore setFrame:CGRectMake(84, 304, self.maxScore.frame.size.width, self.maxScore.frame.size.height)];
        [self.view addSubview:self.maxScore];
    }
}



- (void)setBtn
{
    self.single = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.single setFrame:CGRectMake(84, -30, 164, 47)];
    [self.single setTitle:@"单人游戏" forState:UIControlStateNormal];
    [self.single setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.single.titleLabel setFont:[UIFont fontWithName:@"-" size:35]];
    self.single.backgroundColor = [UIColor citrusColor];
    [self.single.layer setCornerRadius:20];
   // [self.single contentHorizontalAlignment];
    [self.view addSubview:self.single];
    
    self.action = [[UIButton alloc] initWithFrame:CGRectMake(84, -30, 164, 47)];
    [self.action setTitle:@"双人游戏" forState:UIControlStateNormal];
    [self.action.titleLabel setFont:[UIFont fontWithName:@"-" size:35]];
    [self.action setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.action.backgroundColor = [UIColor citrusColor];
    [self.action.layer setCornerRadius:20];
    [self.view addSubview:self.action];
    
    self.maxScore = [[UIButton alloc] initWithFrame:CGRectMake(84, -30, 164, 47)];
    [self.maxScore setTitle:@"最高分" forState:UIControlStateNormal];
    self.maxScore.titleLabel.font = [UIFont fontWithName:@"-" size:35];
    [self.maxScore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.maxScore.backgroundColor = [UIColor citrusColor];
    [self.maxScore.layer setCornerRadius:20];
    [self.view addSubview:self.maxScore];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beijjj"]];
//    [self.view addSubview:img];
    [self setBtn];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.single addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapdo:)];
    [self.maxScore addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapdid:)];
    [self.action addGestureRecognizer:tap3];
}

- (void)setDong:(UIButton *)button and:(CGSize)size and:(CGFloat)h
{
    [UIView animateWithDuration:0.6 animations:^{
        [button setFrame:CGRectMake(84, h, button.frame.size.width, button.frame.size.height)];
    }];
    CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc] init];
    [animation setDelegate:self];
    animation.values = @[@(M_PI/64),@(-M_PI/64),@(M_PI/64),@(0)];
    animation.duration = 1.5;
    [animation setKeyPath:@"transform.rotation"];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [button.layer addAnimation:animation forKey:@"shake"];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]&&count==1) {
         //这里判断是否第一次
        [self buildIntro];
        count++;
    }
    if((![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]&&count==1) ||([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]&&count==2))
    {
        [self setDong:self.single and:self.single.frame.size and:190];
        [self setDong:self.action and:self.action.frame.size and:244];
        [self setDong:self.maxScore and:self.maxScore.frame.size and:304];
        change = YES;
        count++;
    }
}


-(void)buildIntro{
    //Create Stock Panel with header
    UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TestHeader" owner:nil options:nil][0];
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"" description:@"双人游戏的联机方法，首先确保你和你要联机的小伙伴在同一局域网下，然后一起选择双人游戏。" image:[UIImage imageNamed:@"1"] header:headerView];
    //Create Stock Panel With Image
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"主机与僚机" description:@"进入双人游戏界面后，你和你的小伙伴其中一人，选择联机按钮，另一个人等候接受。" image:[UIImage imageNamed:@"2"]];
    
    //Create Panel From Nib
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"TestPanel3" description:@"当联机完成后右上角完成的按钮会变成可用的状态，这个时候就可以点击它了，谁主动联机的就是主机，另一个人就是僚机。" image:[UIImage imageNamed:@"3"]];
    
    //Create custom panel with events
    //    MYCustomPanel *panel4 = [[MYCustomPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"MYCustomPanel"];
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"TestPanel3" description:@"这时候就回到了双人游戏的界面，这时候界面上已经多了两个按钮了，你可以和你的小伙伴一起进入某个模式一起游戏。" image:[UIImage imageNamed:@"4"]];
    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3, panel4];
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"Toronto, ON.jpg"];
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
   
    
    //You can edit introduction view properties right from the delegate method!
    //If it is the first panel, change the color to green!
    if (panelIndex == 0) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:1]];
    }
    //If it is the second panel, change the color to blue!
    else if (panelIndex == 1){
        [introductionView setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:1]];
    }
    
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
   
}

- (void)setSingle
{
    [_appDelegate mcManager].person = 1;
    [_appDelegate mcManager].host = NO;
    [_appDelegate mcManager].solo = NO;
    if ([_appDelegate mcManager].count==2) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GameViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"GVC"];
        //窗口样式
        vcC.modalPresentationStyle = UIModalPresentationFullScreen;
        //动画样式
        vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //弹出模态窗口
        [self presentViewController:vcC animated:YES completion:nil];
    }
}

- (void)showSound
{
    NSURL *fileUrl=[[NSBundle mainBundle] URLForResource:@"laserswitch"     withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    self.player.delegate = self;
    [self.player play];
}

- (void) retrieveTopTenScores
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        leaderboardRequest.identifier = @"scoreId";
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil){
                // handle the error.
              
            }
            if (scores != nil){
                // process the score information.
               
                NSArray *tempScore = [NSArray arrayWithArray:leaderboardRequest.scores];
                for (GKScore *obj in tempScore)
                {
                    [_appDelegate mcManager].maxSingle = obj.value;
                }
            }
        }];
    }
}

- (void) retrieveTopTenScores2
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        leaderboardRequest.identifier = @"allianceId";
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil){
            }
            if (scores != nil){
                NSArray *tempScore = [NSArray arrayWithArray:leaderboardRequest.scores];
                for (GKScore *obj in tempScore)
                {
                    [_appDelegate mcManager].maxAlliance = obj.value;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Max" object:nil];
            }
        }];
    }
}

- (void) retrieveTopTenScores3
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        leaderboardRequest.identifier = @"soloId";
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil){
                // handle the error.
             
            }
            if (scores != nil){
                // process the score information.
                
                NSArray *tempScore = [NSArray arrayWithArray:leaderboardRequest.scores];
                for (GKScore *obj in tempScore)
                {
                    [_appDelegate mcManager].maxSolo = obj.value;
                   
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Max" object:nil];
            }
        }];
    }
}

#pragma mark - Private
- (void)didTap:(UITapGestureRecognizer *)tapGestureHandler
{
    CGPoint tapLocation = [tapGestureHandler locationInView:self.single];
    [self setTap:tapLocation and:self.single];
    [self setSingle];
    [self showSound];
}

- (void)didTapdo:(UITapGestureRecognizer *)tapGestureHandler
{
    CGPoint tapLocation = [tapGestureHandler locationInView:self.maxScore];
    [self setTap:tapLocation and:self.maxScore];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"Cvc"];
    //窗口样式
    vcC.modalPresentationStyle = UIModalPresentationFullScreen;
    //动画样式
    vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //弹出模态窗口
    [self presentViewController:vcC animated:YES completion:nil];
    [self showSound];
}

- (void)didTapdid:(UITapGestureRecognizer *)tapGestureHandler
{
    CGPoint tapLocation = [tapGestureHandler locationInView:self.action];
    [self setTap:tapLocation and:self.action];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"SVc"];
    //窗口样式
    vcC.modalPresentationStyle = UIModalPresentationFullScreen;
    //动画样式
    vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //弹出模态窗口
    [self presentViewController:vcC animated:YES completion:nil];
    [self showSound];
}


- (void)setTap:(CGPoint)tapLocation and:(UIButton *)button
{
    CAShapeLayer *circleShape = nil;
    CGFloat scale = 1.0f;
    
    CGFloat width = button.bounds.size.width, height = button.bounds.size.height;

        CGFloat biggerEdge = width > height ? width : height, smallerEdge = width > height ? height : width;
        CGFloat radius = smallerEdge / 2 > 20 ? 20 : smallerEdge / 2;
        
        scale = biggerEdge / radius + 0.5;
        circleShape = [self createCircleShapeWithPosition:CGPointMake(tapLocation.x - radius, tapLocation.y - radius)
                                                 pathRect:CGRectMake(0, 0, radius*2 , radius*2)
                                                   radius:radius];

    
    [button.layer addSublayer:circleShape];
    CAAnimationGroup *groupAnimation = [self createFlashAnimationWithScale:scale duration:0.5f];
    
    /* Use KVC to remove layer to avoid memory leak */
    [groupAnimation setValue:circleShape forKey:@"circleShaperLayer"];
    
    [circleShape addAnimation:groupAnimation forKey:nil];
    [circleShape setDelegate:self];

}

- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius
{
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    
        circleShape.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
        circleShape.fillColor = [UIColor sunflowerColor].CGColor;
    
    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    
    return circleShape;
}

- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.delegate = self;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return animation;
}

- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *layer = [anim valueForKey:@"circleShaperLayer"];
    if (layer) {
        [layer removeFromSuperlayer];
    }
}


@end
