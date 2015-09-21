//
//  GameViewController.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import <GameKit/GameKit.h>
#import <ShareSDK/ShareSDK.h>
#import "MViewController.h"
#import "UIColor+HTColor.h"
#import <GoogleMobileAds/GoogleMobileAds.h>


@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SkScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}
@end


#define GAD_SIMULATOR_ID @"Simulator"
@interface GameViewController()<GADInterstitialDelegate>
{
    BOOL host;
    UIButton *bomb;
    SKView *skView;
    SKScene *scene;
}
@property(nonatomic,strong) GADInterstitial *interstial;
@end

@implementation GameViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    host = [_appDelegate mcManager].host;
    skView = (SKView *)self.view;
    if (!skView.scene)
    {
        // Create and configure the scene.
       scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        // Present the scene.
        [skView presentScene:scene];
    }
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameOver) name:@"gameOver" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBombEnabled) name:@"Enabled" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setYes) name:@"setYes" object:nil];
     bomb = [[UIButton alloc]init];
    [ bomb setFrame:CGRectMake(18, self.view.frame.size.height-50, 33, 50)];
    [ bomb setImage:[UIImage imageNamed:@"bom2"] forState:UIControlStateNormal];
    [ bomb addTarget:self action:@selector(removeAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bomb];
    
    self.interstial = [self creteAndLoadInterstitial];
}

- (GADInterstitial *)creteAndLoadInterstitial{
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-9036467512898973/4709421047"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
    
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    self.interstial = [self creteAndLoadInterstitial];
}

- (void)viewDidLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)setYes
{
    [bomb setEnabled:YES];
}
    
- (void)setBombEnabled
{
    [bomb setEnabled:NO];
}



- (void)gameOver
{
    UIView *backgroundView =  [[UIView alloc]initWithFrame:self.view.bounds];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBounds:CGRectMake(0,0,200,30)];
    [button setCenter:backgroundView.center];
    [button setTitle:@"重新开始" forState: UIControlStateNormal];
     [button.titleLabel setFont:[UIFont fontWithName:@"-" size:22]];
    [button setTitleColor:[UIColor sunflowerColor] forState:UIControlStateNormal];
    [button.layer setBorderWidth:3.0];
    [button.layer setCornerRadius:15.0];
    [button.layer setBorderColor:[[UIColor sunflowerColor] CGColor]];
    [button addTarget:self action:@selector(gameRestart:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:button];
 
     UIButton *button2 = [[UIButton alloc]init];
    [button2 setBounds:CGRectMake(0,0,200,30)];
    CGPoint point = backgroundView.center;
    [button2 setCenter:CGPointMake(point.x, point.y+40)];
    [button2 setTitle:@"返回" forState:UIControlStateNormal];
     [button2.titleLabel setFont:[UIFont fontWithName:@"-" size:22]];
    [button2 setTitleColor:[UIColor sunflowerColor] forState:UIControlStateNormal];
    [button2.layer setBorderWidth:3.0];
    [button2.layer setCornerRadius:15.0];
    [button2.layer setBorderColor:[[UIColor sunflowerColor] CGColor]];
    [button2 addTarget:self action:@selector(getReturn) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:button2];
    
    UIButton *button3 = [[UIButton alloc]init];
    [button3 setBounds:CGRectMake(0,0,200,30)];
    [button3 setCenter:CGPointMake(point.x, point.y+80)];
    [button3 setTitle:@"分享" forState:UIControlStateNormal];
     [button3.titleLabel setFont:[UIFont fontWithName:@"-" size:22]];
    [button3 setTitleColor:[UIColor sunflowerColor] forState:UIControlStateNormal];
    [button3.layer setBorderWidth:3.0];
    [button3.layer setCornerRadius:15.0];
    [button3.layer setBorderColor:[[UIColor sunflowerColor] CGColor]];
    [button3 addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:button3];
    [backgroundView setCenter:self.view.center];
    [self.view addSubview:backgroundView];
    if([self.interstial isReady]){
        [self.interstial presentFromRootViewController:self];
    }
}

-(void)share
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xib"  ofType:@"png"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"坦克对战"
                                                  url:@"https://itunes.apple.com/cn/app/da-tan-ke/id982119717?mt=8"
                                          description:@"坦克对战双人趣味无穷。"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"...");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@".,,,");
                                }
                            }];
}

- (void)getReturn
{
     [_appDelegate mcManager].count = 2;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"MVc"];
    //窗口样式
    vcC.modalPresentationStyle = UIModalPresentationFullScreen;
    //动画样式
    vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //弹出模态窗口
     [self presentViewController:vcC animated:NO completion:nil];
}

- (IBAction)psuse:(UIButton *)sender
{
         ((SKView *)self.view).paused = YES;
        UIImage *img = [UIImage imageNamed:@"game_resume_n"];
        [sender setBackgroundImage:img forState:UIControlStateNormal];
        [sender setImage:img forState:UIControlStateNormal];
        UIView *pauseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
        
        UIButton *button1 = [[UIButton alloc]init];
        [button1 setFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 100,50,200,30)];
        [button1 setTitle:@"继续" forState:UIControlStateNormal];
       [button1.titleLabel setFont:[UIFont fontWithName:@"-" size:22]];
        [button1 setTitleColor:[UIColor sunflowerColor] forState:UIControlStateNormal];
        [button1.layer setBorderWidth:3.0];
        [button1.layer setCornerRadius:15.0];
        [button1.layer setBorderColor:[[UIColor sunflowerColor] CGColor]];
        [button1 addTarget:self action:@selector(continueGame:) forControlEvents:UIControlEventTouchUpInside];
        [pauseView addSubview:button1];
        
        UIButton *button2 = [[UIButton alloc]init];
        [button2 setFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 100,100,200,30)];
        [button2 setTitle:@"重新开始" forState:UIControlStateNormal];
         [button2.titleLabel setFont:[UIFont fontWithName:@"-" size:22]];
        [button2 setTitleColor:[UIColor sunflowerColor] forState:UIControlStateNormal];
        [button2.layer setBorderWidth:3.0];
        [button2.layer setCornerRadius:15.0];
        [button2.layer setBorderColor:[[UIColor sunflowerColor] CGColor]];
        [button2 addTarget:self action:@selector(gameRestart:) forControlEvents:UIControlEventTouchUpInside];
        [pauseView addSubview:button2];
        pauseView.center = self.view.center;
        [self.view addSubview:pauseView];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPause" object:nil];
}

- (void)continueGame:(UIButton *)button
{
    UIImage *img = [UIImage imageNamed:@"game_pause_n"];
    [self.btn setBackgroundImage:img forState:UIControlStateNormal];
    [self.btn setImage:img forState:UIControlStateNormal];
    [button.superview removeFromSuperview];
    ((SKView *)self.view).paused = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setPause" object:nil];
}

- (void)gameRestart:(UIButton *)button
{
        UIImage *img = [UIImage imageNamed:@"game_pause_n"];
        [self.btn setBackgroundImage:img forState:UIControlStateNormal];
        [self.btn setImage:img forState:UIControlStateNormal];
        [button.superview removeFromSuperview];
        ((SKView *)self.view).paused = NO;
        [bomb setEnabled:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gameRestart" object:nil];
}

- (void)removeAll:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removeAll" object:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
