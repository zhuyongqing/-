//
//  SViewController.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/13.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "SViewController.h"
#import "MViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DoubleViewController.h"
#import "UIColor+HTColor.h"

@interface SViewController ()

@end
static bool change = NO;
@implementation SViewController
- (void)viewDidLoad
{
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [[_appDelegate mcManager] advertiseSelf:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveData:) name:@"MCDidReceiveDataNotification" object:nil];
    [super viewDidLoad];
    [self btnSet];
    UISwipeGestureRecognizer *swip;
    swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipDo:)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    swip.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swip];
}

- (void)btnSet
{
    [self.view addSubview:self.conects];
    [self.view addSubview:self.action];
    [self.view addSubview:self.disconnects];
    [self.view addSubview:self.battle];
    [self.action.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.action.layer setBorderWidth:3];
    [self.action.layer setCornerRadius:20];
    [self.battle.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.battle.layer setBorderWidth:3];
    [self.battle.layer setCornerRadius:20];
    [self.conects.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.conects.layer setBorderWidth:3];
    [self.conects.layer setCornerRadius:20];
    [self.disconnects.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.disconnects.layer setBorderWidth:3];
    [self.disconnects.layer setCornerRadius:20];
    [self.action setHidden:YES];
    [self.battle setHidden:YES];
}

- (void)showSound
{
    NSURL *fileUrl=[[NSBundle mainBundle] URLForResource:@"laserswitch"     withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    self.player.delegate = self;
    [self.player play];
}


- (void)swipDo:(UISwipeGestureRecognizer *)s
{
    if (change==YES) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"MVc"];
        //窗口样式
        vcC.modalPresentationStyle = UIModalPresentationFullScreen;
        //动画样式
        vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //弹出模态窗口
        [self presentViewController:vcC animated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

- (void)didReceiveData:(NSNotification *)notification
{
        NSData *data = [[notification userInfo] objectForKey:@"data"];
        NSDictionary *dict = [self returnDictionaryWithDataPath:data];
        switch ([dict[@"Type"] intValue])
        {
            case 1:
            {
                [self performSelectorOnMainThread:@selector(setHiDDen) withObject:nil waitUntilDone:NO];
            }
                break;
                   default:
                break;
        }
}

- (void)setHiDDen
{
    [self.action setHidden:NO];
    [self.battle setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)run:(id)sender
{
    [_appDelegate mcManager].person = 2;
    [_appDelegate mcManager].solo = NO;
    [_appDelegate mcManager].send = YES;
    [self showSound];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoubleViewController *vcC = [storyboard instantiateViewControllerWithIdentifier:@"DVC"];
        //窗口样式
    vcC.modalPresentationStyle = UIModalPresentationFullScreen;
        //动画样式
    vcC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //弹出模态窗口
    [self presentViewController:vcC animated:YES completion:nil];
    change = YES;
}

- (IBAction)connect:(id)sender
{
    [[_appDelegate mcManager] setupMCBrowser];
    [[[_appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:nil];
    [self showSound];
}

- (IBAction)disConnect:(id)sender
{
    [_appDelegate.mcManager.session disconnect];
    [self.action setHidden:YES];
    [self.battle setHidden:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"已断开连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [self showSound];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self.action setHidden:NO];
    [self.battle setHidden:NO];
    NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:1]};
    NSData *data = [self returnDataWithDictionary:dict];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    [_appDelegate.mcManager.session sendData:data
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    if (error)
    {
      //  NSLog(@"%@", [error localizedDescription]);
    }
    
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}



- (NSData*)returnDataWithDictionary:(NSDictionary*)dict
{
    NSMutableData* data = [[NSMutableData alloc]init];
    
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    [archiver encodeObject:dict forKey:@"Data"];
    
    [archiver finishEncoding];
    return data;
}

-(NSDictionary*)returnDictionaryWithDataPath:(NSData*)data
{
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:@"Data"];
    
    [unarchiver finishDecoding];
    
    return myDictionary;
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [_appDelegate mcManager].host = NO;
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)solo:(id)sender
{
    [_appDelegate mcManager].solo = YES;
    [_appDelegate mcManager].person = 0;
    [self showSound];
    change = YES;
}
@end
