//
//  GCHelper.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/2.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import<Foundation/Foundation.h>
#import<GameKit/GameKit.h>

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;

@end
