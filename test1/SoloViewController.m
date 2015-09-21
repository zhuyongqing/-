//
//  SoloViewController.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/18.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "SoloViewController.h"
#import "SoloScene.h"
//#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import <ShareSDK/ShareSDK.h>
//#import <AGCommon/AGCommon.h>
#import "MViewController.h"
#import "SViewController.h"
#import "UIColor+HTColor.h"
@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}
@end



@interface SoloViewController()
{
    BOOL host;
    UIButton *bomb;
}

@end

@implementation SoloViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    host = [_appDelegate mcManager].host;
    SKView *skView = (SKView *)self.view;
    if (!skView.scene)
    {
        // Create and configure the scene.
        SKScene *scene = [SoloScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        // Present the scene.
        [skView presentScene:scene];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameOver) name:@"gameOver" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReturn2P) name:@"Return" object:nil];
    
}


- (void)viewDidLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)getReturn2P
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Send" object:nil];
    [_appDelegate mcManager].count = 3;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"SVc"];
    //窗口样式
    vcC.modalPresentationStyle = UIModalPresentationFullScreen;
    //动画样式
    vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //弹出模态窗口
    [self presentViewController:vcC animated:YES completion:nil];
   // [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)gameOver
{
    UIView *backgroundView =  [[UIView alloc]initWithFrame:self.view.bounds];
    UIButton *button = [[UIButton alloc]init];
    [button setBounds:CGRectMake(0,0,200,30)];
    [button setCenter:backgroundView.center];
    [button setTitle:@"重新开始" forState:UIControlStateNormal];
     [button.titleLabel setFont:[UIFont fontWithName:@"-" size:22]];
    [button setTitleColor:[UIColor sunflowerColor] forState:UIControlStateNormal];
    [button.layer setBorderWidth:3.0];
    [button.layer setCornerRadius:15.0];
    [button.layer setBorderColor:[[UIColor sunflowerColor] CGColor]];
    [button addTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
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
}

-(void)share
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"https://itunes.apple.com/cn/app/da-tan-ke/id982119717?mt=8"
                                          description:@"坦克对战双人趣味无穷"
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
                                   // NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                   // NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)getReturn
{
    [_appDelegate mcManager].host = NO;
    [_appDelegate mcManager].count = 3;
     [[NSNotificationCenter defaultCenter]postNotificationName:@"GetBack" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Send" object:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"SVc"];
    //窗口样式
    vcC.modalPresentationStyle = UIModalPresentationFullScreen;
    //动画样式
    vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //弹出模态窗口
    [self presentViewController:vcC animated:NO completion:nil];
    //[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)restart:(UIButton *)button
{
    [button.superview removeFromSuperview];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"restart2" object:nil];
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
