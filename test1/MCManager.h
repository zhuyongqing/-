//
//  MCManager.h
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/4.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject<MCSessionDelegate>
// 设备,它包含发现设备和建立会话所需的各种属性
@property (nonatomic,strong) MCPeerID *peerID;
// 对等点创建的会话,任何数据交换和通信细节由该对象控制
@property (nonatomic,strong) MCSession *session;
// 苹果提供的浏览对等点的UI
@property (nonatomic,strong) MCBrowserViewController *browser;
// 广告发布对象，让设备可被发现
@property (nonatomic,strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic,assign) BOOL host;
@property(nonatomic,assign) int person;
@property(nonatomic,assign) BOOL solo;
@property(nonatomic,assign) long int maxSingle;
@property(nonatomic,assign) long int maxAlliance;
@property(nonatomic,assign) long int maxSolo;
@property(nonatomic,assign) int count;
@property(nonatomic,assign) BOOL send;
@property(nonatomic,assign) bool name;
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;
@end
