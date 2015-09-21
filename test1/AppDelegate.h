//
//  AppDelegate.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MCManager *mcManager;

@end

