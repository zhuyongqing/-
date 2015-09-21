//
//  SoloScene.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/18.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

//
//  GameScene.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "SoloScene.h"
#import "SKSharedAtlas.h"
#import "SKPlane.h"
#import <GameKit/GameKit.h>
#import "SKBullte.h"
#import "SKPlayer.h"
#import "UIColor+HTColor.h"
//player1 1 8 8
//player2 4 4 4
// 角色类别
typedef NS_ENUM(uint32_t, SKRoleCategory){
    SKRoleCategoryBullet = 1,
    SKRoleCategoryFoePlane = 4,
    SKRoleCategoryPlayerPlane = 8,
    SKRoleCategoryPower = 16
};
//发送数据的类别
typedef NS_ENUM (int,ReciveType)
{
    RecivePlane = 1,
    RecivePosition = 2,
    ReciveRemoveAll = 3,
    RecivePower = 4,
    ReciveOver = 5,
    ReciveGetBack = 6,
    ReciveReStart = 7,
    ReciveTypeBomb = 8,
    ReciveTypePause = 9,
    ReciveTypeStone = 10,
    ReciveTypeSecond,
    ReciveTypeBattle,
    ReciveTypeBattle2,
    ReciveTypeNil = 0,
    ReciveTypePlayerHit = 14,
    ReciveTypeLose=15,
    ReciveTypeThird,
};

@interface SoloScene()
{
    int backgroundMove;
    int bb;
    SKLabelNode *scoreLabel;//分数
    SKLabelNode *countLabel;//炸弹数
    SKLabelNode *passLabel;//关卡
    SKBullte *bullet1;
    SKBullte *bullet2;
    SKLabelNode *pauseLabel;//暂停
    SKLabelNode *gameOver;
    BOOL hoster;
    int person;//单人
    BOOL send;
    BOOL solo;
    BOOL battle;
}
@property(nonatomic) SKPlayer *player;
@property(nonatomic) SKPlayer *player2;
@property(nonatomic) SKSpriteNode *background,*background2;

@end

@implementation SoloScene
static int soloPlane = 0;
static int change = 0;
-(void)didMoveToView:(SKView *)view
{
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    hoster = [_appDelegate mcManager].host;
    person = [_appDelegate mcManager].person;
    solo = [_appDelegate mcManager].solo;
    gameOver = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDataWithNotification:) name:@"MCDidReceiveDataNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSend) name:@"Send" object:nil];
    send = YES;
    battle = YES;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    [self initbackground];
    [self initScore];
    [self initCountLabel];
    [self initPlayer2];
    [self initplayer];
    [self firBullet];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restart) name:@"restart2" object:nil];
   
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBack) name:@"GetBack" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPause) name:@"setPause" object:nil];
               //添加点击手势识别
        UITapGestureRecognizer *tap;
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDo:)];
        tap.numberOfTapsRequired = 1;//次数
        tap.numberOfTouchesRequired = 1;//手指数
        [self.view addGestureRecognizer:tap];
}

- (void)tapDo:(UIPanGestureRecognizer *)r
{
    if (battle&&soloPlane<=5)
    {
        CGPoint tran = [r locationInView:self.view];
        CGPoint point = CGPointMake(tran.x, abs(tran.y-568));
        [self foundBattle:point];
        soloPlane++;
    }
}

- (void)setSend
{
    send = NO;
}

//发送暂停的消息
- (void)sendPause
{
    NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:ReciveTypePause]};
    [self sendPlane:dict];
}
/**
 *  发送返回上一页的消息
 */
- (void)getBack
{
    NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:ReciveGetBack]};
    [self sendPlane:dict];
    [self removeAllActions];
    [self removeAllChildren];
}
//接收数据
- (void)didReceiveDataWithNotification:(NSNotification *)notification
{
    //    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    //    NSString *peerDisplayName = peerID.displayName;
    if (hoster)
    {
        NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
        NSDictionary *dict =[self returnDictionaryWithDataPath:receivedData];
        if ([dict[@"Type"] intValue]==ReciveTypeBattle2)
        {
            [self setBattlePlane:dict];
        }
        else{
            [self performSelectorOnMainThread:@selector(setPlayer2Position:) withObject:dict waitUntilDone:NO];
        }
    }
    else if(!hoster&&send)
    {
        [self performSelectorInBackground:@selector(GetaChild:) withObject:notification];
    }
}

- (void)setBattlePlane:(NSDictionary *)dict
{
    SKPlane *plane = nil;
    switch ([dict[@"tmp"] intValue])
    {
        case 1:
            plane = [SKPlane smallPlane:1];
            break;
        case 2:
            plane = [SKPlane mediuPlane:1];
            break;
        case 3:
            plane = [SKPlane smallPlane2:1];
            break;
        case 6:
            plane = [SKPlane Stone:1];
            break;
        default:
            break;
    }
    plane.zPosition = 1;
    //创建物理形态
    if (hoster)
    {
        plane.physicsBody.categoryBitMask = SKRoleCategoryFoePlane;
        plane.physicsBody.collisionBitMask = SKRoleCategoryBullet;
        plane.physicsBody.contactTestBitMask = SKRoleCategoryBullet;
        
    }
    else
    {
        plane.physicsBody.categoryBitMask = SKRoleCategoryPlayerPlane;
        plane.physicsBody.collisionBitMask = SKRoleCategoryFoePlane;
        plane.physicsBody.contactTestBitMask = SKRoleCategoryFoePlane;
    }
    plane.position = CGPointMake([dict[@"PointX"] floatValue], abs([dict[@"PointY"] floatValue]-568));
    plane.xScale = 0.8;
    plane.yScale = 0.8;
    [plane runAction:[SKAction sequence:@[[SKAction moveToY:0 duration:2],[SKAction removeFromParent]]]];
    [self addChild:plane];
}


//服务端的接收
- (void)GetaChild:(NSNotification *)notification
{
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSDictionary *dict = [self returnDictionaryWithDataPath:receivedData];
    switch ([dict[@"Type"] intValue])
    {
        case RecivePosition:
            [self performSelectorOnMainThread:@selector(setPlayer1P:) withObject:dict waitUntilDone:NO];
            break;
        case ReciveGetBack:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Return" object:nil];
        }
            break;
        case ReciveReStart:
        {
            self.scene.paused = NO;
            [self removeAllChildren];
            [self removeAllActions];
            [self initbackground];
            [self initplayer];
            [self initPlayer2];
            [self initCountLabel];
            [self initScore];
            [self firBullet];
            gameOver = nil;
            battle = YES;
            soloPlane = 0;
        }
            break;
        case ReciveTypePause:
        {
            if (!self.scene.paused)
            {
                self.scene.paused = YES;
                passLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
                passLabel.text = @"Wait Host";
                passLabel.fontColor = [SKColor blackColor];
                passLabel.position = CGPointMake(150 , self.size.height / 2 + 20);
                [self addChild:passLabel];
            }
            else
            {
                self.scene.paused = NO;
                [passLabel removeFromParent];
            }
        }
            break;
            case ReciveTypeBattle:
        {
            [self setBattlePlane:dict];
        }
            break;
        case ReciveTypeNil:
           // NSLog(@"%i",ReciveTypeNil);
            break;
        case ReciveTypePlayerHit:
        {
            [self changedCountLabel];
            if ([dict[@"tmp"] intValue]==1)
            {
                NSString *path = @"MyMagic";
                SKEmitterNode *emitt = [self getParticle:self.player.position andPanth:path andSize:self.player.size];
                [self.scene addChild:emitt];
            }
            else if([dict[@"tmp"] intValue]==2)
            {
                NSString *path = @"MyMagic";
                SKEmitterNode *emitt = [self getParticle:self.player2.position andPanth:path andSize:self.player2.size];
                [self.scene addChild:emitt];
            }
        }
            break;
        case ReciveTypeLose:
        {
             [self changedCountLabel];
            if ([dict[@"tmp"] intValue]==1)
            {
                [self removeAllActions];
                NSString *path = @"MyMagic2";
                SKEmitterNode *emitt = [self getParticle:self.player.position andPanth:path andSize:self.player.size];
                [self.scene addChild:emitt];
                [self.player runAction:[SKAction removeFromParent]];
                battle = NO;
                if (gameOver == nil)
                {
                    gameOver = [self gameOver:@"You Win!" and:@"MarkerFelt-Thin" and:CGPointMake(self.size.width/2, self.size.height/2+20)];
                    [self addChild:gameOver];
                    [self reportScore:++[_appDelegate mcManager].maxSolo forCategory:@"soloId"];
                    SKLabelNode *node = [self gameOver:@"累计:" and:@"-" and:CGPointMake(100,400)];
                    [self addChild:node];
                    SKLabelNode *lable = [self gameOver:[NSString stringWithFormat:@"%ld 胜",[_appDelegate mcManager].maxSolo] and:@"MarkerFelt-Thin" and:CGPointMake(150, 400)];
                    [self addChild:lable];
                    [self ScoreLabel];
                    change++;
                    
                }
            }
            else
            {
                [self removeAllActions];
                NSString *path = @"MyMagic2";
                SKEmitterNode *emitt = [self getParticle:self.player2.position andPanth:path andSize:self.player2.size];
                [self.scene addChild:emitt];
                [self.player2 runAction:[SKAction removeFromParent]];
                battle = NO;
                if (gameOver == nil)
                {
                    gameOver = [self gameOver:@"Lose!" and:@"MarkerFelt-Thin" and:CGPointMake(self.size.width/2, self.size.height/2+20)];
                    [self addChild:gameOver];
                }
            }
        }
            break;
        default:
            break;
    }
}

//游戏结束提示
- (SKLabelNode *)gameOver:(NSString *)str and:(NSString *)str2 and:(CGPoint)point
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:str2];
    label.text = str;
    if ([str isEqualToString:@"GameOver"]) {
        label.fontColor = [SKColor redColor];
    }
    else
        label.fontColor = [SKColor peterRiverColor];
    label.position = point;
    return label;
}


//服务端的创建飞机
- (SKPlane *)add2Plane:(int)num andP:(CGFloat)x and:(CGFloat)y
{
    SKPlane *plane = nil;
    switch (num)
    {
        case 1:
            plane = [SKPlane smallPlane:1];
            break;
        case 2:
            plane = [SKPlane mediuPlane:1];
            break;
        case 3:
            plane = [SKPlane smallPlane2:1];
            break;
        case 6:
            plane = [SKPlane Stone:1];
            break;
        case 7:
            plane = [SKPlane bigPlane:1];
            break;
        default:
            break;
    }
    plane.zPosition = 1;
    //创建物理形态
    plane.physicsBody.categoryBitMask = SKRoleCategoryFoePlane;
    plane.physicsBody.collisionBitMask = SKRoleCategoryBullet;
    plane.physicsBody.contactTestBitMask = SKRoleCategoryBullet;
    plane.position = CGPointMake(x, y);
    plane.xScale = 0.8;
    plane.yScale = 0.8;
    return plane;
}
//设置主机的位置
- (void)setPlayer1P:(NSDictionary *)dict
{
    CGPoint point;
    point.y = abs([dict[@"Y"] floatValue]-568);
    point.x = [dict[@"X"] floatValue] ;
     SKAction *actionMove = [SKAction moveTo:CGPointMake(point.x, point.y) duration:0.1];
    [self.player runAction:actionMove];
}
//设置服务端的位置
- (void)setPlayer2Position:(NSDictionary *)dict
{
    CGPoint point;
    point.y = abs([dict[@"Y"] floatValue]-568);
    point.x = [dict[@"X"] floatValue];
     SKAction *actionMove = [SKAction moveTo:CGPointMake(point.x, point.y) duration:0.1];
    [self.player2 runAction:actionMove];
}
//重新开始
- (void)restart
{
    [self removeAllChildren];
    [self removeAllActions];
    [self initbackground];
    [self initPlayer2];
    [self initplayer];
    [self initCountLabel];
    [self initScore];
    [self firBullet];
    gameOver = nil;
    battle = YES;
    bb = 0;
    soloPlane = 0;
    if (send)
    {
        NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:ReciveReStart]};
        [self sendPlane:dict];
    }
}
- (void)initScore
{
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    scoreLabel.text = [NSString stringWithFormat:@"%i",change];
    scoreLabel.fontColor = [SKColor peterRiverColor];
    scoreLabel.fontSize = 23;
    scoreLabel.zPosition = 2;
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    scoreLabel.position = CGPointMake(40, self.size.height-22);
    [self addChild:scoreLabel];
}

- (void)initCountLabel
{
    countLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    countLabel.text = @"5";
    countLabel.fontColor = [SKColor redColor];
    countLabel.fontSize = 20;
    countLabel.zPosition = 2;
    countLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    countLabel.position = CGPointMake(150, self.size.height-22);
    [self addChild:countLabel];
}

//改变炸弹数
- (void)changedCountLabel
{
    [countLabel runAction:[SKAction runBlock:^{
        countLabel.text = [NSString stringWithFormat:@"%d",countLabel.text.intValue-1];
        if ([countLabel.text intValue]<0) {
            countLabel.text = @"0";
        }
    }]];
}

- (void)ScoreLabel
{
    [scoreLabel runAction:[SKAction runBlock:^{
        scoreLabel.text = [NSString stringWithFormat:@"%d",scoreLabel.text.intValue+1];
    }]];
}


//初始化背景图
- (void)initbackground
{
    backgroundMove = self.size.height;
    self.background = [SKSpriteNode spriteNodeWithImageNamed:@"tkb"];
    self.background.anchorPoint = CGPointMake(0.5, 0);
    self.background.position = CGPointMake(self.size.width/2, 0);
    self.background.zPosition = 0;
    
    self.background2 = [SKSpriteNode spriteNodeWithImageNamed:@"tkb"];
    self.background2.position = CGPointMake(self.size.width/2, backgroundMove-3);
    self.background2.zPosition = 0;
    self.background2.anchorPoint = CGPointMake(0.5, 0);
    [self addChild:self.background];
    [self addChild:self.background2];
    [self runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"action_world3.mp3" waitForCompletion:YES]]];
}
//发送数据
- (void)sendPlane:(NSDictionary *)dict
{
        NSData *data = [self returnDataWithDictionary:dict];
        NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
        NSError *error;
        [_appDelegate.mcManager.session sendData:data
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        if (error)
        {
           // NSLog(@"%@", [error localizedDescription]);
        }
}

- (void)initplayer
{
    if (!hoster){
        self.player = [SKPlayer Player1:2];
        self.player.position = CGPointMake(150, 468);
    }
    else{
        self.player = [SKPlayer Player1:1];
        self.player.position = CGPointMake(150, 100);
    }
    self.player.size = CGSizeMake(100, 100);
    self.player.xScale = 0.5;
    self.player.yScale = 0.5;
    self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
    self.player.physicsBody.categoryBitMask = SKRoleCategoryPlayerPlane;
    self.player.physicsBody.collisionBitMask = SKRoleCategoryFoePlane;
     self.player.physicsBody.contactTestBitMask = SKRoleCategoryFoePlane;
    [self addChild:self.player];
    [self addBullet1];
}

- (void)initPlayer2
{
    if (hoster){
        self.player2 = [SKPlayer Player2:4];
        self.player2.position = CGPointMake(250, 468);
    }
    else{
        self.player2 = [SKPlayer Player2:3];
        self.player2.position = CGPointMake(250, 100);
    }
    self.player2.size = CGSizeMake(100, 100);
    self.player2.xScale = 0.5;
    self.player2.yScale = 0.5;
    self.player2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player2.size];
    self.player2.physicsBody.categoryBitMask = SKRoleCategoryFoePlane;
    self.player2.physicsBody.collisionBitMask = SKRoleCategoryBullet;
    self.player2.physicsBody.contactTestBitMask = SKRoleCategoryBullet;
    [self addChild:self.player2];
    [self addBullet2];
}

//让背景动起来
- (void)scrollBack
{
    backgroundMove--;
    if (backgroundMove<=0)
    {
        backgroundMove = 568;
    }
    self.background.position = CGPointMake(self.size.width/2, backgroundMove-568);
    self.background2.position = CGPointMake(self.size.width/2, backgroundMove-3);
}

/**
 *  创建子弹
 */


- (void)addBullet1
{
    bullet1 = [SKBullte bullte1:2];
    bullet1.position = CGPointMake(self.player.position.x, self.player.position.y);
    bullet1.zPosition = 1;
    bullet1.xScale = 0.5;
    bullet1.yScale = 0.5;
    bullet1.physicsBody.categoryBitMask = SKRoleCategoryBullet;
    bullet1.physicsBody.contactTestBitMask = SKRoleCategoryFoePlane;
    bullet1.physicsBody.collisionBitMask = SKRoleCategoryFoePlane;
    bullet1.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:bullet1];
    int num = 0;
    if(!hoster)
        num=0;
    else
        num = 568;
    SKAction *actionMove = [SKAction moveTo:CGPointMake(bullet1.position.x, num) duration:0.5];
    SKAction *moveDone = [SKAction removeFromParent];
    [bullet1 runAction:[SKAction sequence:@[actionMove,moveDone]]];
    [self runAction:[SKAction playSoundFileNamed:@"bullet.mp3" waitForCompletion:NO]];
}

- (void)addBullet2
{
        bullet2 = [SKBullte bullte2:2];
        bullet2.position = CGPointMake(self.player2.position.x, self.player2.position.y);
        bullet2.zPosition = 1;
        bullet2.xScale = 0.5;
        bullet2.yScale = 0.5;
        bullet2.physicsBody.categoryBitMask = SKRoleCategoryFoePlane;
        bullet2.physicsBody.contactTestBitMask = SKRoleCategoryPlayerPlane;
        bullet2.physicsBody.collisionBitMask = SKRoleCategoryPlayerPlane;
        bullet2.physicsBody.usesPreciseCollisionDetection = YES;
        [self addChild:bullet2];
        int num = 0;
        if(hoster)
            num=0;
        else
            num = 568;
        SKAction *actionMove2 = [SKAction moveTo:CGPointMake(bullet2.position.x, num) duration:0.5];
        SKAction *moveDone = [SKAction removeFromParent];
        [bullet2 runAction:[SKAction sequence:@[actionMove2,moveDone]]];
         [self runAction:[SKAction playSoundFileNamed:@"bullet.mp3" waitForCompletion:NO]];
}


//子弹运动  间隔0.2秒
- (void)firBullet
{
    SKAction *action =[SKAction runBlock:^{
        [self addBullet1];
        [self addBullet2];
    }];
     SKAction *interval = [SKAction waitForDuration:0.3];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[action,interval]]]];
}
//手指滑动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (hoster)
    {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInNode:self];
        self.player.position = point;
        if (person!=1)
        {
            NSDictionary *dict = @{@"X":[NSNumber numberWithFloat:self.player.position.x],@"Y":[NSNumber numberWithFloat:self.player.position.y],@"Type":[NSNumber numberWithInt:RecivePosition]};
            [self sendPlane:dict];
        }
    }
    else if(!hoster)
    {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInNode:self];
        self.player2.position = point;
        NSDictionary *dict = @{@"X":[NSNumber numberWithFloat:self.player2.position.x],@"Y":[NSNumber numberWithFloat:self.player2.position.y]};
        NSData *data = [self returnDataWithDictionary:dict];
        NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
        NSError *error;
        [_appDelegate.mcManager.session sendData:data
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        if (error)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}
//转化数据类型
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
    
   // NSLog(@"%@", myDictionary);
    return myDictionary;
}



- (void)foundBattle:(CGPoint)point
{
    int a = arc4random()%4+1;
    SKPlane *plane = nil;
    switch (a)
    {
        case 1:
            plane = [SKPlane smallPlane:2];
            break;
        case 2:
            plane = [SKPlane mediuPlane:2];
            break;
        case 3:
            plane = [SKPlane smallPlane2:2];
            break;
        case 4:
            plane = [SKPlane Stone:2];
            break;
        default:
            break;
    }
    plane.zPosition = 1;
    //创建物理形态
    if (hoster)
    {
        plane.physicsBody.categoryBitMask = SKRoleCategoryPlayerPlane;
        plane.physicsBody.collisionBitMask = SKRoleCategoryFoePlane;
        plane.physicsBody.contactTestBitMask = SKRoleCategoryFoePlane;
    }
    else
    {
        plane.physicsBody.categoryBitMask = SKRoleCategoryFoePlane;
        plane.physicsBody.collisionBitMask = SKRoleCategoryBullet;
        plane.physicsBody.contactTestBitMask = SKRoleCategoryBullet;
    }
    plane.position = CGPointMake(point.x, point.y);
    plane.xScale = 0.8;
    plane.yScale = 0.8;
    [plane runAction:[SKAction sequence:@[[SKAction moveToY:568 duration:2],[SKAction removeFromParent]]]];
    [self addChild:plane];
    if (hoster)
    {
        NSDictionary *dict = @{@"PointX":[NSNumber numberWithFloat:plane.position.x],@"PointY":[NSNumber numberWithFloat:plane.position.y],@"Type":[NSNumber numberWithInt:ReciveTypeBattle],@"Speed":[NSNumber numberWithInt:2],@"tmp":[NSNumber numberWithInt:plane.type]};
        [self sendPlane:dict];
    }
    else if(!hoster)
    {
        NSDictionary *dict = @{@"PointX":[NSNumber numberWithFloat:plane.position.x],@"PointY":[NSNumber numberWithFloat:plane.position.y],@"Type":[NSNumber numberWithInt:ReciveTypeBattle2],@"Speed":[NSNumber numberWithInt:2],@"tmp":[NSNumber numberWithInt:plane.type]};
        [self sendPlane:dict];
    }
}

//重要的方法  根据帧数 来创建飞机  和  地图的滚动
//static int rain = 0;
-(void)update:(CFTimeInterval)currentTime
{
    if (hoster)
    {
        NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:ReciveTypeNil]};
        [self sendPlane:dict];
    }
    [self scrollBack];
    if (battle) {
        bb++;
        if (bb>50) {
            float x = arc4random()%220+45;
            [self foundBattle:CGPointMake(x, 0)];
            bb=0;
        }
    }
    
}

//得到粒子效果
- (SKEmitterNode *)getParticle:(CGPoint)point andPanth:(NSString *)tmpPath andSize:(CGSize)size
{
    NSString *path = [[NSBundle mainBundle] pathForResource:tmpPath ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    explosion.numParticlesToEmit = 20;
    explosion.position = CGPointMake(point.x, point.y);
    return explosion;
}

//碰撞之后  移除
- (void)planeMonster:(SKPlane *)monster
{
    NSString *soundFileName = nil;
    if (![monster actionForKey:@"blowup"])
    {
        switch (monster.type)
        {
            case 1:
                soundFileName = @"enemy1_down.mp3";
                break;
            case 2:
                soundFileName = @"explosion_rocket.mp3";
                break;
            case 3:
                soundFileName = @"explosion1.mp3";
                break;
            case 6:
                soundFileName = @"explosion1.mp3";
                break;
            case 7:
                soundFileName = @"explosion_rocket.mp3";
                break;
            default:
                break;
        }
        monster.hp-=change;
        if (monster.hp<=0||monster.type==1)
        {
            [monster removeAllActions];
            switch (monster.type)
            {
                case 1:
                {
                    NSString *path = @"MyFire";
                    SKEmitterNode *emitt = [self getParticle:monster.position andPanth:path andSize:monster.size];
                    [self.scene addChild:emitt];
                }
                    break;
                case 2:
                {
                    NSString *path = @"MyFire";
                    SKEmitterNode *emitt = [self getParticle:monster.position andPanth:path andSize:monster.size];
                    [self.scene addChild:emitt];
                }
                    break;
                case 3:
                {
                    NSString *path = @"MyFire";
                    SKEmitterNode *emitt = [self getParticle:monster.position andPanth:path andSize:monster.size];
                    [self.scene addChild:emitt];
                }
                    break;
                case 7:
                {
                    NSString *path = @"MyFire";
                    SKEmitterNode *emitt = [self getParticle:monster.position andPanth:path andSize:monster.size];
                    [self.scene addChild:emitt];
                }
                default:
                    break;
            }
            [monster runAction:[SKAction removeFromParent]];
            [self runAction:[SKAction playSoundFileNamed:soundFileName waitForCompletion:NO]];
        }
        else
        {
            //[monster runAction:[SKSharedAtlas planeHit:monster.type]];
            NSString *path2 = [[NSBundle mainBundle] pathForResource:@"MySmoke" ofType:@"sks"];
            SKEmitterNode *explosion2 = [NSKeyedUnarchiver unarchiveObjectWithFile:path2];
            explosion2.numParticlesToEmit = 20;
            explosion2.position = CGPointMake(monster.position.x, monster.position.y-monster.size.height/2);
            [self.scene addChild:explosion2];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"MyFir" ofType:@"sks"];
            SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            explosion.numParticlesToEmit = 20;
            explosion.position = CGPointMake(monster.position.x, monster.position.y-monster.size.height/2);
            [self.scene addChild:explosion];
            [self runAction:[SKAction playSoundFileNamed:@"destroyer_lazer3.mp3" waitForCompletion:NO]];
        }
    }
}


//发送主机爆炸 游戏结束
- (void)sendPlayerBlowUp:(int)type
{
    NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:type]};
    NSData *data = [self returnDataWithDictionary:dict];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    [_appDelegate.mcManager.session sendData:data
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    if (error)
    {
        //NSLog(@"%@", [error localizedDescription]);
    }
}


- (void)battle:(SKSpriteNode *)sprite and:(SKSpriteNode *)player
{
    if ([sprite isKindOfClass:[SKBullte class]]&&[player isKindOfClass:[SKPlane class]])
    {
        [sprite removeFromParent];
        [self planeMonster:(SKPlane *)player];
    }
    else if([sprite isKindOfClass:[SKPlane class]]&&[player isKindOfClass:[SKPlane class]])
    {
        NSString *path = @"MyMagic2";
        SKEmitterNode *emitt = [self getParticle:sprite.position andPanth:path andSize:sprite.size];
        [self.scene addChild:emitt];
        [sprite runAction:[SKAction removeFromParent]];
        [player runAction:[SKAction removeFromParent]];
        [self runAction:[SKAction playSoundFileNamed:@"explosion1.mp3" waitForCompletion:NO]];
    }
    else if(([sprite isKindOfClass:[SKPlane class]]&&[player isKindOfClass:[SKPlayer class]])||([sprite isKindOfClass:[SKBullte class]]&&[player isKindOfClass:[SKPlayer class]]))
    {
        if ([sprite isKindOfClass:[SKPlane class]])
        {
            NSString *path = @"MyMagic2";
            SKEmitterNode *emitt = [self getParticle:sprite.position andPanth:path andSize:sprite.size];
            [self.scene addChild:emitt];
            [sprite runAction:[SKAction removeFromParent]];
            [self runAction:[SKAction playSoundFileNamed:@"explosion1.mp3" waitForCompletion:NO]];
            [self playerDown:(SKPlayer *)player];
        }
        else{
            [sprite removeFromParent];
            [self playerDown:(SKPlayer *)player];
        }
        
    }
    else if([sprite isKindOfClass:[SKPlayer class]]&&[player isKindOfClass:[SKPlane class]]){
        NSString *path = @"MyMagic2";
        SKEmitterNode *emitt = [self getParticle:player.position andPanth:path andSize:player.size];
        [self.scene addChild:emitt];
        [player runAction:[SKAction removeFromParent]];
        [self runAction:[SKAction playSoundFileNamed:@"explosion1.mp3" waitForCompletion:NO]];
        [self playerDown:(SKPlayer *)sprite];
    }
}

- (void)playerDown:(SKPlayer *)player
{
    if (hoster)
    {
        if (player.type==1)
        {
            self.player.hp--;
            [self changedCountLabel];
            if (self.player.hp<=0)
            {
                [self removeAllActions];
                NSString *path = @"MyMagic2";
                SKEmitterNode *emitt = [self getParticle:self.player.position andPanth:path andSize:self.player.size];
                [self.scene addChild:emitt];
                [self.player runAction:[SKAction removeFromParent]];
                battle = NO;
                if (gameOver == nil)
                {
                    gameOver = [self gameOver:@"Lose!" and:@"MarkerFelt-Thin" and:CGPointMake(self.size.width/2, self.size.height/2+20)];
                    [self addChild:gameOver];
                    [self ScoreLabel];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameOver" object:nil];
                    NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:ReciveTypeLose],@"tmp":[NSNumber numberWithInt:1]};
                    [self sendPlane:dict];
                    SKLabelNode *node = [self gameOver:@"累计:" and:@"-" and:CGPointMake(100,400)];
                    [self addChild:node];
                    SKLabelNode *lable = [self gameOver:[NSString stringWithFormat:@"%ld 胜",[_appDelegate mcManager].maxSolo] and:@"MarkerFelt-Thin" and:CGPointMake(150, 400)];
                    [self addChild:lable];
                }
            }
            else
            {
                NSString *path = @"MyMagic";
                SKEmitterNode *emitt = [self getParticle:self.player.position andPanth:path andSize:self.player.size];
                [self.scene addChild:emitt];
                NSDictionary *dict = @{@"Type":[NSNumber numberWithInt: ReciveTypePlayerHit],@"tmp":[NSNumber numberWithInt:1]};
                [self sendPlane:dict];
            }
        }
        else
        {
            self.player2.hp--;
            if (self.player2.hp<=0)
            {
                [self removeAllActions];
                NSString *path = @"MyMagic2";
                SKEmitterNode *emitt = [self getParticle:self.player2.position andPanth:path andSize:self.player2.size];
                [self.scene addChild:emitt];
                [self.player2 runAction:[SKAction removeFromParent]];
                battle = NO;
                if (gameOver==nil)
                {
                    gameOver = [self gameOver:@"You Win!" and:@"MarkerFelt-Thin" and:CGPointMake(self.size.width/2, self.size.height/2+20)];
                    [self addChild:gameOver];
                    [self ScoreLabel];
                    change++;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameOver" object:nil];
                    NSDictionary *dict = @{@"Type":[NSNumber numberWithInt:ReciveTypeLose],@"tmp":[NSNumber numberWithInt:2]};
                    [self sendPlane:dict];
                    [self reportScore:++[_appDelegate mcManager].maxSolo forCategory:@"soloId"];
                    SKLabelNode *node = [self gameOver:@"累计:" and:@"-" and:CGPointMake(100,400)];
                    [self addChild:node];
                    SKLabelNode *lable = [self gameOver:[NSString stringWithFormat:@"%ld 胜",[_appDelegate mcManager].maxSolo] and:@"MarkerFelt-Thin" and:CGPointMake(150, 400)];
                    [self addChild:lable];
                }
            }
            else
            {
                NSString *path = @"MyMagic";
                SKEmitterNode *emitt = [self getParticle:self.player2.position andPanth:path andSize:self.player2.size];
                [self.scene addChild:emitt];
                NSDictionary *dict = @{@"Type":[NSNumber numberWithInt: ReciveTypePlayerHit],@"tmp":[NSNumber numberWithInt:2]};
                [self sendPlane:dict];
            }
        }
    }
}

//检测物理的碰撞
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if ((contact.bodyA.categoryBitMask & SKRoleCategoryFoePlane) ||
        (contact.bodyB.categoryBitMask & SKRoleCategoryFoePlane))
    {
        SKSpriteNode *sprite = (contact.bodyA.categoryBitMask & SKRoleCategoryFoePlane) ? (SKSpriteNode *)contact.bodyA.node : (SKSpriteNode *)contact.bodyB.node;
        if ((contact.bodyA.categoryBitMask & SKRoleCategoryPlayerPlane) ||
            (contact.bodyB.categoryBitMask & SKRoleCategoryPlayerPlane))
        {
            SKSpriteNode *player = (contact.bodyA.categoryBitMask & SKRoleCategoryPlayerPlane?(SKSpriteNode *)contact.bodyA.node:(SKSpriteNode *)contact.bodyB.node);
          
                [self battle:sprite and:player];
        }
        else
        {
            SKSpriteNode *bullet =  (contact.bodyA.categoryBitMask & SKRoleCategoryBullet?(SKSpriteNode *)contact.bodyA.node:(SKSpriteNode *)contact.bodyB.node);
            [bullet removeFromParent];
                if ([sprite isKindOfClass:[SKPlane class]])
                    [self planeMonster:(SKPlane *)sprite];
                else if([sprite isKindOfClass:[SKBullte class]])
                    [sprite removeFromParent];
                else{
                    [self playerDown:(SKPlayer *)sprite];
                }
        }
    }
}

//上传分数到GameCenter
- (void) reportScore: (int64_t) score forCategory: (NSString*) category
{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:category];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // handle the reporting error
          //  NSLog(@"上传分数出错.");
            //If your application receives a network error, you should not discard the score.
            //Instead, store the score object and attempt to report the player’s process at
            //a later time.
        }else
        {
          //  NSLog(@"上传分数成功");
        }
    }];
}


@end
