//
//  GameScene.m
//  SpriteKitPlan
//
//  Created by zhuyongqing on 15/4/1.
//  Copyright (c) 2015年 zhuyongqing. All rights reserved.
//

#import "GameScene.h"
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

@interface GameScene()
{
    int backgroundMove;
    int bigPlane;
    int mediuPlane;
    int smallPlane;
    int powerBullet;
    int small;
    int bomb;
    int third;
    SKLabelNode *scoreLabel;//分数
    SKLabelNode *countLabel;//炸弹数
    SKLabelNode *passLabel;//关卡
    SKBullte *bullet1;
    SKBullte *bullet2;
    SKBullte *bullet3;
    SKLabelNode *pauseLabel;//暂停
    SKLabelNode *gameOver;
    BOOL hoster;
    int person;//单人
    BOOL thirdPass;
}
@property(nonatomic) SKPlayer *player;
@property(nonatomic) SKPlayer *player2;
@property(nonatomic) SKSpriteNode *background,*background2;

@end

@implementation GameScene
static int  count = 0;
static bool found = NO;
static int change = 1;
static bool over = YES;

static GameScene *sharedScene = nil;
+ (instancetype)sharedInstance:(CGSize)size
{
    if (sharedScene == nil) {
        sharedScene = [GameScene sceneWithSize:size];
    }
    return sharedScene;
}

-(void)didMoveToView:(SKView *)view
{
     _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    hoster = [_appDelegate mcManager].host;
    person = [_appDelegate mcManager].person;
    gameOver = nil;
    thirdPass = NO;
    count = 0;
    found = NO;
    over = YES;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        NSString *str = @"坦克";
        CGPoint point = CGPointMake(0, 430);
        [self initCustomsPass:str andP:point];
     [self initbackground];
     [self initScore];
    change = 1;
         [self initplayer];
         [self firBullet];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restart) name:@"gameRestart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAll) name:@"removeAll" object:nil];
}

//关卡
- (void)initCustomsPass:(NSString *)str andP:(CGPoint)point
{
    passLabel = [SKLabelNode labelNodeWithFontNamed:@"-"];
    passLabel.text = str;
    passLabel.fontColor = [SKColor sunflowerColor];
    passLabel.fontSize = 50;
    passLabel.zPosition = 2;
    passLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    passLabel.position = point;
    SKAction *interval = [SKAction waitForDuration:2];
    [passLabel runAction:[SKAction sequence:@[[SKAction moveToX:120 duration:0.3],interval,[SKAction moveToX:320 duration:0.3],[SKAction removeFromParent]]]];
    [self addChild:passLabel];
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

//炸弹
- (void)removeAll
{
        for(SKSpriteNode *node in self.children)
        {
            if ([node isKindOfClass:[SKPlane class]])
            {
                SKPlane *plane = (SKPlane *)node;
                if (plane.type!=4&&plane.type!=5)
                {
                     plane.hp = 1;
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"MyMagic3" ofType:@"sks"];
                    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                    explosion.numParticlesToEmit = 50;
                    explosion.position = CGPointMake(130,300);
                    [self.scene addChild:explosion];
                    [self planeMonster:plane];
                }
            }
        }
        [self changedCountLabel];
}
//重新开始
- (void)restart
{
    thirdPass = NO;
    [self removeAllChildren];
    [self removeAllActions];
    [self initbackground];
       [self initplayer];
     over = YES;
    [self initScore];
    [self firBullet];
    gameOver = nil;
    bigPlane=0;
    smallPlane=0;
    mediuPlane=0;
    powerBullet = 0;
    bomb = 0;
    change = 1;
    small = 0;
    count = 4;
    stone = YES;
    found = NO;
}
//初始化分数和炸弹数
- (void)initScore
{
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    scoreLabel.text = @"0000";
    scoreLabel.fontColor = [SKColor peterRiverColor];
    scoreLabel.fontSize = 23;
    scoreLabel.zPosition = 2;
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    scoreLabel.position = CGPointMake(40, self.size.height-22);
    [self addChild:scoreLabel];
    countLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    countLabel.text = @"3";
    countLabel.fontColor = [SKColor redColor];
    countLabel.fontSize = 20;
    countLabel.zPosition = 2;
    countLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    countLabel.position = CGPointMake(0, 40);
    [self addChild:countLabel];
}

//改变炸弹数
- (void)changedCountLabel
{
    [countLabel runAction:[SKAction runBlock:^{
        countLabel.text = [NSString stringWithFormat:@"%d",countLabel.text.intValue-1];
    }]];
    if ([countLabel.text intValue]<=1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Enabled" object:nil];
    }
 }
//改变分数
- (void)changedScroeLabel:(SKPlane *)plane
{
    int scroe = 0;
    switch (plane.type)
    {
        case 1:
            scroe = 100;
            break;
        case 2:
            scroe = 300;
            break;
        case 3:
            scroe = 600;
            break;
        default:
            break;
    }
    [scoreLabel runAction:[SKAction runBlock:^{
        scoreLabel.text = [NSString stringWithFormat:@"%d",scoreLabel.text.intValue+scroe];
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
    self.background2.position = CGPointMake(self.size.width/2, backgroundMove);
    self.background2.zPosition = 0;
    self.background2.anchorPoint = CGPointMake(0.5, 0);
    [self addChild:self.background];
    [self addChild:self.background2];
    [self runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"action_world3.mp3" waitForCompletion:YES]]];
}

- (void)initplayer
{
    self.player = [SKPlayer Player1:1];
    self.player.position = CGPointMake(150, 100);
    self.player.size = CGSizeMake(100, 100);
    self.player.xScale = 0.5;
    self.player.yScale = 0.5;
    self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
    self.player.physicsBody.categoryBitMask = SKRoleCategoryPlayerPlane;
    self.player.physicsBody.collisionBitMask = 0;
    self.player.physicsBody.contactTestBitMask = SKRoleCategoryFoePlane;
    [self addChild:self.player];
    [self addBullet1];
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
    self.background2.position = CGPointMake(self.size.width/2, backgroundMove-1);
}

/**
 *  创建子弹
 */


- (void)addBullet1
{
        bullet1 = [SKBullte bullte1:change];
        bullet1.position = CGPointMake(self.player.position.x, self.player.position.y+20);
        bullet1.zPosition = 1;
        bullet1.xScale = 0.5;
        bullet1.yScale = 0.5;
        bullet1.physicsBody.categoryBitMask = SKRoleCategoryBullet;
        bullet1.physicsBody.contactTestBitMask = SKRoleCategoryFoePlane;
        bullet1.physicsBody.collisionBitMask = SKRoleCategoryFoePlane;
        bullet1.physicsBody.usesPreciseCollisionDetection = YES;
        [self addChild:bullet1];
    SKAction *actionMove = [SKAction moveTo:CGPointMake(bullet1.position.x, 568) duration:0.5];
    SKAction *moveDone = [SKAction removeFromParent];
    [bullet1 runAction:[SKAction sequence:@[actionMove,moveDone]]];
     [self runAction:[SKAction playSoundFileNamed:@"bullet.mp3" waitForCompletion:NO]];
}

- (void)addBullet3
{
    if (thirdPass)
    {
        bullet3 = [SKBullte bullte3:change];
        bullet3.position = CGPointMake(self.player.position.x, self.player.position.y);
        bullet3.zPosition = 1;
        bullet3.xScale = 0.5;
        bullet3.yScale = 0.5;
        bullet3.physicsBody.categoryBitMask = SKRoleCategoryBullet;
        bullet3.physicsBody.contactTestBitMask = SKRoleCategoryFoePlane;
        bullet3.physicsBody.collisionBitMask = SKRoleCategoryFoePlane;
        bullet3.physicsBody.usesPreciseCollisionDetection = YES;
        [self addChild:bullet3];
        SKAction *actionMove2 = [SKAction moveTo:CGPointMake(bullet3.position.x, 0) duration:0.5];
        SKAction *moveDone = [SKAction removeFromParent];
        [bullet3 runAction:[SKAction sequence:@[actionMove2,moveDone]]];
        [self runAction:[SKAction playSoundFileNamed:@"bullet.mp3" waitForCompletion:NO]];
    }
}


//子弹运动  间隔0.2秒
- (void)firBullet
{
    SKAction *action =[SKAction runBlock:^{
        [self addBullet1];
        [self addBullet3];
    }];
     SKAction *interval = [SKAction waitForDuration:0.2];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[action,interval]]]];
}
//手指滑动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInNode:self];
        self.player.position = point;
}

//主机创建飞机
- (SKPlane *)foundPlane:(int)num and:(float)yy and:(int)t
{
    int x = (arc4random()%220)+35;
    SKPlane *plane = nil;
    switch (num)
    {
        case 1:
            plane = [SKPlane smallPlane:t];
            break;
        case 2:
            plane = [SKPlane mediuPlane:t];
            break;
        case 3:
            plane = [SKPlane smallPlane2:t];
            break;
        case 6:
            plane = [SKPlane Stone:t];
            break;
        case 7:
            plane = [SKPlane bigPlane:t];
            break;
        default:
            break;
    }
    plane.zPosition = 1;
    //创建物理形态
        plane.physicsBody.categoryBitMask = SKRoleCategoryFoePlane;
        plane.physicsBody.collisionBitMask = SKRoleCategoryBullet;
        plane.physicsBody.contactTestBitMask = SKRoleCategoryBullet;
    plane.position = CGPointMake(x, yy);
    plane.xScale = 0.8;
    plane.yScale = 0.8;
    return plane;
}

- (void)passSecond:(NSString *)name
{
        for(SKSpriteNode *node in self.children)
        {
            if ([node isKindOfClass:[SKPlane class]])
            {
                SKPlane *plane = (SKPlane *)node;
               if (plane.type!=4&&plane.type!=5)
                {
                    [plane runAction:[SKAction removeFromParent]];
                }
            }
        }
   [self  initCustomsPass:name andP:CGPointMake(0, 430)];
}
/**
 *  添加飞机
 */
static bool stone = YES;


- (void)addMonster
{
    bigPlane++;
    mediuPlane++;
    smallPlane++;
    powerBullet++;
    bomb++;
    small++;
    
    if (small>80&&stone)
    {
        float s = (arc4random()%3)+2;
      SKPlane *plane = [self foundPlane:3 and:self.size.height and:1];
      [plane runAction:[SKAction sequence:@[[SKAction moveToY:0 duration:s],[SKAction removeFromParent]]]];
        [self addChild:plane];
        small=0;
    }
    if (smallPlane>55&&stone)
    {
        float s = (arc4random()%4)+2;
        SKPlane *plane = [self foundPlane:1 and:self.size.height and:1];
        [plane runAction:[SKAction sequence:@[[SKAction moveToY:0 duration:s],[SKAction removeFromParent]]]];
        [self addChild:plane];
        smallPlane =0;
    }
    if (mediuPlane>450-change*30&&stone)
    {
        float s = (arc4random()%4)+2;
        SKPlane *plane = [self foundPlane:2 and:self.size.height and:1];
        [plane runAction:[SKAction sequence:@[[SKAction moveToY:0 duration:s],[SKAction removeFromParent]]]];
        [self addChild:plane];
        mediuPlane = 0;
    }
    if (bigPlane>550-change*30&&stone)
    {
        count++;
        float s = (arc4random()%4)+3;
        SKPlane *plane = [self foundPlane:7 and:self.size.height and:1];
        [plane runAction:[SKAction sequence:@[[SKAction moveToY:0 duration:s],[SKAction removeFromParent]]]];
        [self addChild:plane];
         [self runAction:[SKAction playSoundFileNamed:@"enemy2_out.mp3" waitForCompletion:NO]];
        bigPlane = 0;
    }
    if (powerBullet>2000+change*500&&stone)
    {
        [self foundMirror:4];
        powerBullet = 0;
    }
    if (bomb==4500&&stone)
    {
        [self foundMirror:5];
        bomb = 0;
    }
    if (found&&mediuPlane%150==0)
    {
        count++;
        float s = (arc4random()%3)+2;
        SKPlane *plane = [self foundPlane:6 and:self.size.height and:1];
        SKAction *interval = [SKAction waitForDuration:3];
        [plane runAction:[SKAction sequence:@[[SKAction moveToY:450 duration:s],interval,[SKAction moveToY:0 duration:0.6],[SKAction removeFromParent]]]];
        [self addChild:plane];
        mediuPlane = 0;
        if (count==18)
            stone = YES;
    }
    if (count==14){
        stone = NO;
        found = YES;
        [self passSecond:@"石头"];
        count = 15;
        mediuPlane = 0;
    }
}

- (void)foundMirror:(int)num
{
    float s = (arc4random()%3)+7;
    int x = (arc4random()%220)+35;
    SKPlane *power = [self addPower:x and:num];
    [power runAction:[SKAction sequence:@[[SKAction moveToY:0 duration:s],[SKAction removeFromParent]]]];
    [self addChild:power];
}

//创建掉落的物品
- (SKPlane *)addPower:(int)x and:(int)select
{
    SKPlane *power = nil;
    if (select==4){
        power = [SKPlane PlayPower];
    }
    else{
        power = [SKPlane PlayBomb];
    }
    power.zPosition = 1;
    //创建物理形态
    power.physicsBody.categoryBitMask = SKRoleCategoryPower;
    power.physicsBody.collisionBitMask = SKRoleCategoryPlayerPlane;
    power.physicsBody.contactTestBitMask = SKRoleCategoryPlayerPlane;
    power.position = CGPointMake(x, self.size.height);
    power.xScale = 0.8;
    power.yScale = 0.8;
    return power;
}

//重要的方法  根据帧数 来创建飞机  和  地图的滚动
//static int rain = 0;
-(void)update:(CFTimeInterval)currentTime
{
    if (count<35&&over)
    {
       [self addMonster];
    }
    [self scrollBack];
    if (count>34) {
        third++;
        powerBullet++;
        bomb++;
        thirdPass = YES;
        if (count==35) {
            [self passSecond:@"镜像"];
            [self.player removeFromParent];
            [self initplayer];
             if (bomb==2000) {
                [self foundMirror:5];
                bomb=0;
            }
            if (powerBullet==1500) {
                [self foundMirror:4];
                powerBullet = 0;
            }
            count++;
            stone = NO;
        }
        if (third>70) {
            [self getThird:0 and:self.size.height and:1];
            [self getThird:568 and:0 and:2];
            third = 0;
        }
    }
}

- (void)getThird:(int)n and:(float)move and:(int)t
{
    float s = (arc4random()%4)+4;
    int num = arc4random()%6+1;
    if (num==4||num==5) {
        num=3;
    }
    SKPlane *plane = [self foundPlane:num and:move and:t];
    [plane runAction:[SKAction sequence:@[[SKAction moveToY:n duration:s],[SKAction removeFromParent]]]];
    [self addChild:plane];
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
        if (monster.hp<=0)
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
            [self changedScroeLabel:monster];
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

//主机的移除
- (void)playerBlowup:(SKSpriteNode *)player
{
        [self removeAllActions];
        if (person==1) {
        over = NO;
        NSString *path = @"MyMagic2";
        SKEmitterNode *emitt = [self getParticle:self.player.position andPanth:path andSize:self.player.size];
               [self.scene addChild:emitt];
        [self.player runAction:[SKAction removeFromParent]];
        [self runAction:[SKAction playSoundFileNamed:@"bounce.mp3" waitForCompletion:NO]];
        if (gameOver==nil)
        {
            gameOver = [self gameOver:@"GameOver" and:@"MarkerFelt-Thin" and:CGPointMake(self.size.width/2, self.size.height/2+20)];
            [self addChild:gameOver];
            NSString *str;
            NSString *ss;
            str = @"scoreId";
            ss = [NSString stringWithFormat:@"%ld",[_appDelegate mcManager].maxSingle];
            [self reportScore:[[scoreLabel text] intValue] forCategory:str];
           SKLabelNode *node = [self gameOver:@"历史最高:" and:@"-" and:CGPointMake(80,400)];
            [self addChild:node];
            SKLabelNode *lable = [self gameOver:ss and:@"MarkerFelt-Thin" and:CGPointMake(200, 400)];
            [self addChild:lable];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gameOver" object:nil];
        }
    }
 }

//得到子弹 和 炸弹
- (void)playerPower:(SKPlane *)play
{
    if (play.type==4)
    {
        if (change<5)
            change++;
    }
    if (play.type == 5)
    {
        [countLabel runAction:[SKAction runBlock:^{
            countLabel.text = [NSString stringWithFormat:@"%d",countLabel.text.intValue+1];
        }]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setYes" object:nil];
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
                [self playerBlowup:player];
          
         }
        else
        {
            SKSpriteNode *bullet =  (contact.bodyA.categoryBitMask & SKRoleCategoryBullet?(SKSpriteNode *)contact.bodyA.node:(SKSpriteNode *)contact.bodyB.node);
            [bullet removeFromParent];
           
                [self planeMonster:(SKPlane *)sprite];
        }
    }
    if ((contact.bodyA.categoryBitMask & SKRoleCategoryPlayerPlane) ||
        (contact.bodyB.categoryBitMask & SKRoleCategoryPlayerPlane))
    {
        if((contact.bodyA.categoryBitMask & SKRoleCategoryPower) ||
           (contact.bodyB.categoryBitMask & SKRoleCategoryPower))
        {
             SKPlane *power= (contact.bodyA.categoryBitMask & SKRoleCategoryPower?(SKPlane *)contact.bodyA.node:(SKPlane *)contact.bodyB.node);
            [power removeFromParent];
            [self runAction:[SKAction playSoundFileNamed:@"bonus.mp3" waitForCompletion:NO]];
            [self playerPower:power];
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
           
            //If your application receives a network error, you should not discard the score.
            //Instead, store the score object and attempt to report the player’s process at
            //a later time.
        }else
        {
            
        }
    }];
}


@end
