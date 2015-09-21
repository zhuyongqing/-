//
//  MCManager.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/4.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "MCManager.h"

@implementation MCManager
-(id)init
{
    self = [super init];
    if (self)
    {
       _peerID = nil;
       _session = nil;
       _browser = nil;
       _advertiser = nil;
        _host = NO;
        _solo = NO;
        _send = YES;
        _name = NO;
    }
    return self;
}

- (void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
    _peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
}

- (void)setupMCBrowser
{
    //创建浏览视图，自定义服务类型名称,小于16个字符，ASCII字符、数字、连字符
    _browser = [[MCBrowserViewController alloc] initWithServiceType:@"chat-files" session:_session];
    _host = YES;
}

- (void)advertiseSelf:(BOOL)shouldAdvertise
{
    if(shouldAdvertise)
    {
        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"chat-files" discoveryInfo:nil session:_session];
        [_advertiser start];
    }
    else
    {
        [_advertiser stop];
        _advertiser = nil;
    }
}

#pragma mark -  MCSession Delegate Method
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
   // NSLog(@"连接状态改变(0未连接,1连接中,2已链接):%li",state);
    NSDictionary *dict = @{@"peerID":peerID,@"state":[NSNumber numberWithInt:state]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
     	            object:nil
     	          userInfo:dict];
}

// 数据、流、资源
// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
   // NSLog(@"接收到%li长度的数据",data.length);
   
     NSDictionary *dict = @{@"peerID":peerID,@"data":data};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MCDidReceiveDataNotification" object:nil userInfo:dict];
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
   
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
   
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
   
}

@end
