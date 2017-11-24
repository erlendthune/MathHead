//
//  ETMyScene.m
//  Money
//
//  Created by Erlend Thune on 24.05.14.
//  Copyright (c) 2014 Erlend Thune. All rights reserved.
//
// Background :http://www.albertopasca.it/whiletrue/2014/02/how-to-make-flappy-bird-like-game-using-uikit/
// Breakout: http://www.raywenderlich.com/49721/how-to-create-a-breakout-game-using-spritekit
// Icons: http://icons.mysitemyway.com/legacy-icon/102889-3d-glossy-green-orb-icon-alphanumeric-circled-x2/
//http://makeappicon.com/#
//http://www.clker.com/cliparts/L/0/O/A/J/z/test-hi.png
//http://freesound.org/people/elektroproleter/sounds/157568/ Jumpsound
//http://etc.usf.edu/presentations/extras/buttons/icons_trans/20%20White/index.html play
//https://www.bonanza.com/background_burner
//http://all-free-download.com/free-vector/vector-clip-art/aiga_symbol_signs_clip_art_16430_download.html


#import "ETMyScene.h"
#import "ETNumberNode.h"


@implementation ETMyScene

static const uint32_t jumperCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t borderCategory = 0x1 << 1;  // 00000000000000000000000000000100
static const uint32_t numberCategory = 0x1 << 2; // 00000000000000000000000000000010
static const uint32_t operatorCategory = 0x1 << 3; // 00000000000000000000000000001000
static const uint32_t platformCategory = 0x1 << 4; // 00000000000000000000000000001000
static const uint32_t cheeseCategory = 0x1 << 5; // 00000000000000000000000000001000
static const uint32_t trapCategory = 0x1 << 6; // 00000000000000000000000000001000
static const uint32_t targetCategory = 0x1 << 7; // 00000000000000000000000000001000
static const uint32_t elevatorCategory = 0x1 << 8; // 00000000000000000000000000001000

static const unichar MULT_SIGN=183;
static const short ADD = 10;
static const short SUBTRACT = 11;
static const short MULTIPLY = 12;
static const short DIVIDE = 13;
static const short IMPULSE=91.0f;
static const float IMPULSE_DELTA = 3.5f;
static const int BG_IMAGE_WIDTH = 1024;
static const int BG_IMAGE_HEIGHT = 683;
static const int IPHONE_35_SCREEN_WIDTH = 480;
static const int IPHONE_35_SCREEN_HEIGHT = 320;
static const float IPHONE_35_JUMPER_MASS = 0.28;
static const short FIXED_UPPER_NUMBER=5;
static const short PHY_RAD=12;
static const short SHAFT_HEIGHT = 40;
static const short SPEED_LEVEL = -150.0f;
static const short SPEED_LEVEL_DELTA = 10.0f;
static const float FONT_SIZE = 36.0;
static const short SECONDS_TO_EMPTY_LINE = 4;
static const short SHAFT_OFFSET = 20;
static const short NEW_LEVEL_AT = 10;
static const short START_FLOOR_NUMBER = 0;
static const float ELEVATOR_SOUND_LENGTH = 4.0;
static const short HEAVEN = 10;


enum TARGET_STATE {
    CHEESE_ONLY=0,
    CHEESE_AND_TRAPS,
    NU_ADD,
    NU_SUBTRACT,
    NU_MULTIPLY,
    NU_DIVIDE=5,
    EQ_ADD,
    EQ_SUBTRACT,
    EQ_MULTIPLY,
    EQ_ADD_MULTIPLY,
    EQ_SUBTRACT_MULTIPLY=10,
    EQ_FRACTION_X_NOMINATOR,
    EQ_FRACTION_X_DENOMINATOR
};


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
//        float ay = 32.0/480.0;
//        self.anchorPoint = CGPointMake(0.0f, ay);
        
        self.backgroundColor = [SKColor blackColor];
//        self.backgroundColor = [SKColor whiteColor];
//        [self initalizingScrollingBackground];
        [self.physicsWorld setContactDelegate:self];
        
/*        CGPoint location = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        // 1 Create a physics body that borders the screen
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = borderBody;
        // 3 Set the friction of that physicsBody to 0
 */
        
        self.lineNodes = [[NSMutableArray alloc] init];
        self.numberNodes = [[NSMutableArray alloc] init];
        
        self.crustBelow = nil;
        self.tunnellShaftBelow = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameActivated) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
/*
        NSString *burstPath =
        [[NSBundle mainBundle] pathForResource:@"Rain" ofType:@"sks"];
        
        SKEmitterNode *burstEmitter =
        [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
        
        burstEmitter.position = CGPointMake(0, 400);
        
        [self addChild:burstEmitter];
*/
    }
    return self;
}



- (void) pauseGame
{
    if(self.avElevatorSound.isPlaying)
    {
        self.bElevatorSoundPaused = YES;
        [self.avElevatorSound pause];
    }
    if(self.avSuccessSong.isPlaying)
    {
        self.bSuccessSongPaused = YES;
        [self.avSuccessSong pause];
    }
    if(self.avLoungeSong.isPlaying)
    {
        self.bLoungeSoundPaused = YES;
        [self.avLoungeSong pause];
    }
    if(self.avLevelUpSound.isPlaying)
    {
        self.bLevelUpSoundPaused = YES;
        [self.avLevelUpSound pause];
    }
    if(self.avLevelDownSound.isPlaying)
    {
        self.bLevelDownSoundPaused = YES;
        [self.avLevelDownSound pause];
    }
    self.view.paused = YES;
}

- (void) playGame
{
    if(self.bSuccessSongPaused)
    {
        [self.avSuccessSong play];
    }
    if(self.bLoungeSoundPaused)
    {
        [self.avLoungeSong play];
    }
    if(self.bElevatorSoundPaused)
    {
        [self.avElevatorSound play];
    }
    if(self.bLevelUpSoundPaused)
    {
        [self.avLevelUpSound play];
    }
    if(self.bLevelDownSoundPaused)
    {
        [self.avLevelDownSound play];
    }
    self.bElevatorSoundPaused = NO;
    self.bLevelDownSoundPaused = NO;
    self.bLevelUpSoundPaused = NO;
    self.bSuccessSongPaused = NO;
    self.view.paused = NO;
}

- (void) gameActivated
{
    if(!self.bPause)
    {
        [self playGame];
    }
}


-(bool) pausePlayGame
{
    if(self.bPause)
    {
        [self playGame];
    }
    else
    {
        [self pauseGame];
    }
    self.bPause = !self.bPause;
    return self.bPause;
}

-(bool) audioOnOff
{
    self.bAudioOn = !self.bAudioOn;
    if(self.bAudioOn)
    {
        [self.avLoungeSong setVolume:1.0];
        [self.avSuccessSong setVolume:1.0];
        [self.avLevelUpSound setVolume:1.0];
        [self.avLevelDownSound setVolume:1.0];
        [self.avElevatorSound setVolume:1.0];
    }
    else
    {
        [self.avLoungeSong setVolume:0.0];
        [self.avSuccessSong setVolume:0.0];
        [self.avLevelUpSound setVolume:0.0];
        [self.avLevelDownSound setVolume:0.0];
        [self.avElevatorSound setVolume:0.0];
    }
    
    return self.bAudioOn;
}

- (void)initGame:(ETViewController*) vc
{
    self.vc = vc;
    float fh = self.frame.size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
/*
    CGPathMoveToPoint(path, NULL, self.frame.size.width, self.yoff);
    CGPathAddLineToPoint(path, NULL, self.frame.origin.x, self.yoff);
    CGPathAddLineToPoint(path, NULL, self.frame.origin.x, fh);
*/
    CGPathMoveToPoint(path, NULL, 1, self.yoff);
    CGPathAddLineToPoint(path, NULL, self.frame.origin.x, self.yoff);
    CGPathAddLineToPoint(path, NULL, self.frame.origin.x, fh);
    
    
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
    self.physicsBody = borderBody;
    
    self.physicsBody.friction = 0.0f;
    self.physicsBody.restitution = 0.0f;
    self.physicsBody.categoryBitMask = borderCategory;

    float fx = self.size.width / BG_IMAGE_WIDTH;
    float fy = self.size.height / BG_IMAGE_HEIGHT;
    self.bgscale = MAX(fx, fy);

    fx = self.size.width / IPHONE_35_SCREEN_WIDTH;
    fy = self.size.height / IPHONE_35_SCREEN_HEIGHT;
    self.scrscale = MAX(fx, fy);
    
    self.noOfElementsInHorisontalShaft = 2;
    self.distance = self.size.width / self.noOfElementsInHorisontalShaft;
    
    self.shaftHeight = SHAFT_HEIGHT * self.scrscale;
    self.physicsWorld.gravity = CGVectorMake(0.0f, -3.0f * self.scrscale);
    
    NSError *avPlayerError = nil;
    NSString *loungesoundpath =[[NSBundle mainBundle] pathForResource:@"lounge" ofType:@"mp3"] ;
    NSString *elevatorsoundpath =[[NSBundle mainBundle] pathForResource:@"elevatorshort" ofType:@"wav"] ;
    NSString *levelupsoundpath =[[NSBundle mainBundle] pathForResource:@"levelup" ofType:@"wav"] ;
    NSString *leveldownsoundpath =[[NSBundle mainBundle] pathForResource:@"leveldown" ofType:@"wav"] ;
    NSString *successongpath =[[NSBundle mainBundle] pathForResource:@"successong" ofType:@"mp3"] ;

    self.avElevatorSound =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:elevatorsoundpath] error:&avPlayerError];
    if (avPlayerError)
    {
        NSLog(@"Error: %@", [avPlayerError description]);
    }
    self.avLevelDownSound =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:leveldownsoundpath] error:&avPlayerError];
    if (avPlayerError)
    {
        NSLog(@"Error: %@", [avPlayerError description]);
    }
    self.avLevelUpSound =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:levelupsoundpath] error:&avPlayerError];
    if (avPlayerError)
    {
        NSLog(@"Error: %@", [avPlayerError description]);
    }
    self.cheeseSound = [SKAction playSoundFileNamed:@"StarPing.wav" waitForCompletion:NO];
    self.jumpSound = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];

    self.avSuccessSong =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:successongpath] error:&avPlayerError];
    if (avPlayerError)
    {
        NSLog(@"Error: %@", [avPlayerError description]);
    }

    self.avLoungeSong =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:loungesoundpath] error:&avPlayerError];
    self.avLoungeSong.numberOfLoops = -1;
    if (avPlayerError)
    {
        NSLog(@"Error: %@", [avPlayerError description]);
    }
    [self.avLoungeSong play];

    self.bLoungeSoundPaused = NO;
    self.bElevatorSoundPaused = NO;
    self.bLevelDownSoundPaused = NO;
    self.bLevelUpSoundPaused = NO;
    self.bAudioOn = YES;

    /*
    self.floorImageNameArray = [NSArray arrayWithObjects:
                                @"fire.jpg",        //0
                                @"crust.jpg",
                                @"granite.jpg",
                                @"asphalt1.jpg",
                                @"asphalt2.jpg",
                                @"cement1.jpg",     //5
                                @"ice.jpg",
                                @"clay.jpg",
                                @"cobblestone.jpg",
                                @"cement2.jpg",
                                @"brick.jpg",       //10
                                @"brick2.jpg",
                                @"watercolor.jpg",
                                @"cheeseheaven.png", //13
                                nil];
    */
    self.floorImageNameArray = [NSArray arrayWithObjects:
                                @"fire.jpg",        //0
                                @"crust.jpg",
                                @"granite.jpg",
                                @"asphalt1.jpg",
                                @"asphalt2.jpg",
                                @"cement1.jpg",     //5
                                @"ice.jpg",
                                @"clay.jpg",
                                @"cobblestone.jpg",
                                @"cement2.jpg",
                                @"cheeseheaven.png",       //10
                                nil];

    
    self.nextLevelValueArray = [NSArray arrayWithObjects:
                                [NSNumber numberWithInteger:NEW_LEVEL_AT], //0
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],  //5
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],  //10
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],
                                [NSNumber numberWithInteger:NEW_LEVEL_AT],  //13
                                nil];
    self.floorNumber = START_FLOOR_NUMBER;
    [self addCrusts];
    [self addShafts];
    
    self.vc.pausePlayButton.hidden = YES;
    self.bOnPlatform = YES;
    [self addPlatform];
    [self addStartMessage];
}

-(void) addStartMessage
{
    [self addTarget];
    
    self.targetNode.text = @"TAP SCREEN";
    self.targetNode2.text = @"TO START";
}

- (void)startGame
{
    self.speedlevel = SPEED_LEVEL;
    self.impulse = IMPULSE;
    self.bFirstLeftBorderCollision = TRUE;
    self.bLiftSequenceStarted = NO;
    self.bJumpRequested = NO;
    self.cheeseCollected = 0;
    self.bPause = NO;
    self.equationType = START_FLOOR_NUMBER; //CHEESE_ONLY;
    self.bLevelTransition = NO;
    self.bLevelUp = NO;
    self.bLevelDown = NO;
    self.consecutiveTraps = 0;
    //[self addTarget];
    
    self.state = 0;
    self.bDivByZero = false;
    self.bGameOver = false;
    self.bSuccess = NO;
    self.floorNumber = START_FLOOR_NUMBER;

    [self addElevator];
    [self addJumper];
    self.currentOperatorValue = ADD;
    
//    [self addCurrentOperator];
    
    self.vc.pausePlayButton.hidden = NO;

    [self addElementsToTunnell];
    [self addCheeseStatus];
    [self addFloorNumber];
    [self setBlankTargetText];
    //[self moveUpTimer];
}

- (void)rainHearts
{
    SKEmitterNode *emitter = nil;
    
    emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"hearts" ofType:@"sks"]];
    emitter.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame));
    [self addChild:emitter];
    
}

- (void)rainCheese
{
    SKEmitterNode *emitter = nil;
    
    emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"cheesesnow" ofType:@"sks"]];
    emitter.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame));
    [self addChild:emitter];
    
}


- (void) addSuccessMessage
{
    self.bSuccess = YES;
//    [self runAction:self.applauseSound];

    self.targetNode.text = @"";
    self.targetNode2.text = @"";
    [self.avLoungeSong stop];
    self.bLoungeSoundPaused = false;
    [self.avSuccessSong play];
    [self rainHearts];
    [self rainCheese];
    self.bGameOver = true;
    [self.cheeseNodeStatus removeFromParent];
    [self.cheeseNodeStatusText removeFromParent];
    [self.floorNumberSymbol removeFromParent];
    [self.floorNumberText removeFromParent];
/*
    SKLabelNode *successMsg = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    successMsg.text = @"GREAT!";
 
    
    successMsg.fontSize = FONT_SIZE * self.scrscale;
    successMsg.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:successMsg];
*/
}

- (void) addFailureMessage
{
    self.bSuccess = NO;
    self.bGameOver = true;
    [self removeAllChildren];
//    [self runAction:self.applauseSound];
    
    SKLabelNode *smsg = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    smsg.text = @"OH NO!";
    smsg.fontSize = FONT_SIZE * self.scrscale;
    smsg.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:smsg];
    self.cheeseCollected = 3;
   
}

- (void) addNextCrust
{
    if(self.floorNumber == self.floorImageNameArray.count)
    {
        return;
    }
    
    if(self.crustBelow)
    {
        [self.crustBelow removeFromParent];
    }
    if(self.tunnellShaftBelow)
    {
        [self.tunnellShaftBelow removeFromParent];
    }

    self.crustBelow = self.crust;
    self.tunnellShaftBelow = self.tunnellShaft;
    self.crust = self.crustAbove;
    self.tunnellShaft = self.tunnellShaftAbove;
    
    int s = self.floorImageNameArray.count;
    if(self.floorNumber < (s-1))
    {
        self.crustAbove = [SKSpriteNode spriteNodeWithImageNamed:[self.floorImageNameArray objectAtIndex:self.floorNumber+1]];
        self.crustAbove.zPosition = -1.0;

        self.crustAbove.xScale = self.bgscale;
        self.crustAbove.yScale = self.bgscale;
        self.crustAbove.position = CGPointMake(0.0,CGRectGetMaxY(self.crust.frame));
        self.crustAbove.anchorPoint = CGPointMake(0.0,0.0);
        [self addChild:self.crustAbove];
    }
    else
    {
        self.crustAbove = nil;
    }
    
    if(self.floorNumber < (s-2))
    {
        self.tunnellShaftAbove = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(CGRectGetMaxX(self.frame), self.shaftHeight)];
        self.tunnellShaftAbove.position = CGPointMake(0,CGRectGetMaxY(self.crust.frame)+self.yoff+SHAFT_OFFSET*self.scrscale);
        self.tunnellShaftAbove.anchorPoint = CGPointMake(0.0,0.0);
        self.tunnellShaftAbove.zPosition = -0.5;
        [self addChild:self.tunnellShaftAbove];
    }
    else
    {
        self.crustAbove.zPosition = -0.3;
        self.tunnellShaftAbove = nil;
    }
}

- (void) addPreviousCrust
{
    if(self.floorNumber < 0)
    {
        return;
    }
    if(self.crustAbove)
    {
        [self.crustAbove removeFromParent];
    }

    if(self.tunnellShaftAbove)
    {
        [self.tunnellShaftAbove removeFromParent];
    }
    
    self.crustAbove = self.crust;
    self.crust = self.crustBelow;
    self.tunnellShaftAbove = self.tunnellShaft;
    self.tunnellShaft = self.tunnellShaftBelow;
    
    if(self.floorNumber > 0)
    {
        self.crustBelow = [SKSpriteNode spriteNodeWithImageNamed:[self.floorImageNameArray objectAtIndex:(self.floorNumber-1)]];
        self.crustBelow.zPosition = -1.0;
        self.crustBelow.xScale = self.bgscale;
        self.crustBelow.yScale = self.bgscale;
        self.crustBelow.position = CGPointMake(0.0,-CGRectGetMaxY(self.crust.frame));
        self.crustBelow.anchorPoint = CGPointMake(0.0,0.0);
        [self addChild:self.crustBelow];

        self.tunnellShaftBelow = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(CGRectGetMaxX(self.frame), self.shaftHeight)];
        self.tunnellShaftBelow.position = CGPointMake(0,-CGRectGetMaxY(self.crust.frame)+self.yoff+20);
        self.tunnellShaftBelow.anchorPoint = CGPointMake(0.0,0.0);
        self.tunnellShaftBelow.zPosition = -0.5;
        [self addChild:self.tunnellShaftBelow];
    }
    else
    {
        self.crustBelow = nil;
        self.tunnellShaftBelow = nil;
    }
}

- (void) addCrusts
{
    self.crust = [SKSpriteNode spriteNodeWithImageNamed:[self.floorImageNameArray objectAtIndex:self.floorNumber]];

    self.crust.zPosition = -1.0;
    self.crust.xScale = self.bgscale;
    self.crust.yScale = self.bgscale;
    self.crust.position = CGPointMake(0.0,0.0);
    self.crust.anchorPoint = CGPointMake(0.0,0.0);
    [self addChild:self.crust];

    self.crustAbove = [SKSpriteNode spriteNodeWithImageNamed:[self.floorImageNameArray objectAtIndex:self.floorNumber+1]];
    self.crustAbove.zPosition = -1.0;
    self.crustAbove.xScale = self.bgscale;
    self.crustAbove.yScale = self.bgscale;
    self.crustAbove.position = CGPointMake(0.0,CGRectGetMaxY(self.crust.frame));
    self.crustAbove.anchorPoint = CGPointMake(0.0,0.0);
    [self addChild:self.crustAbove];

    if(self.floorNumber > 0)
    {
        self.crustBelow = [SKSpriteNode spriteNodeWithImageNamed:[self.floorImageNameArray objectAtIndex:self.floorNumber-1]];
        self.crustBelow.zPosition = -1.0;
        self.crustBelow.xScale = self.bgscale;
        self.crustBelow.yScale = self.bgscale;
        self.crustBelow.position = CGPointMake(0.0,-CGRectGetMaxY(self.crust.frame));
        self.crustBelow.anchorPoint = CGPointMake(0.0,0.0);
        [self addChild:self.crustBelow];
    }
}

- (void) addElevator
{
    self.elevator = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.elevatorShaft.size.width, self.yoff/2)];
    self.elevator.position = CGPointMake(self.elevatorShaft.position.x+self.elevator.size.width/2,self.tunnellShaft.position.y-self.elevator.size.height/2);
//    self.elevator.anchorPoint = CGPointMake(0.0,0.0);

    self.elevatorSupport = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.elevatorShaft.size.width/3, self.tunnellShaft.position.y*2)];
    self.elevatorSupport.position = CGPointMake(self.elevatorShaft.position.x+self.elevatorShaft.size.width/2-self.elevatorSupport.size.width/2, -self.tunnellShaft.position.y);
    self.elevatorSupport.anchorPoint = CGPointMake(0.0,0.0);

    self.elevator.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.elevator.size];
    self.elevator.physicsBody.friction = 0.0f;
    self.elevator.physicsBody.affectedByGravity = NO;
    self.elevator.physicsBody.usesPreciseCollisionDetection = YES;
    self.elevator.physicsBody.restitution = 0.0f;
    self.elevator.physicsBody.linearDamping = 0.0f;
    self.elevator.physicsBody.allowsRotation = NO;
    self.elevator.physicsBody.dynamic = NO;
    self.elevator.physicsBody.categoryBitMask = elevatorCategory;
    self.elevator.physicsBody.contactTestBitMask = jumperCategory;
    self.elevator.physicsBody.collisionBitMask = jumperCategory;
    
    [self addChild:self.elevator];
    [self addChild:self.elevatorSupport];
}

- (void) addShafts
{
    self.elevatorShaft = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(CGRectGetMaxX(self.frame)/8, CGRectGetMaxY(self.frame))];
    self.elevatorShaft.position = CGPointMake(CGRectGetMaxX(self.frame)/10,0);
    self.elevatorShaft.anchorPoint = CGPointMake(0.0,0.0);
    self.elevatorShaft.zPosition = -0.5;
    [self addChild:self.elevatorShaft];

    //This is the shaft on the first screen (ground floor)
    self.tunnellShaft = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(CGRectGetMaxX(self.frame), self.shaftHeight)];
    self.tunnellShaft.position = CGPointMake(0,self.yoff+SHAFT_OFFSET*self.scrscale);
    self.tunnellShaft.anchorPoint = CGPointMake(0.0,0.0);
    self.tunnellShaft.zPosition = -0.5;
    [self addChild:self.tunnellShaft];

    //This is the shaft on the next floor
    self.tunnellShaftAbove = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(CGRectGetMaxX(self.frame), self.shaftHeight)];
    self.tunnellShaftAbove.position = CGPointMake(0,CGRectGetMaxY(self.crust.frame)+self.yoff+SHAFT_OFFSET*self.scrscale);
    self.tunnellShaftAbove.anchorPoint = CGPointMake(0.0,0.0);
    self.tunnellShaftAbove.zPosition = -0.5;
    [self addChild:self.tunnellShaftAbove];

}

- (void)addElementToTunnell
{
    NSLog(@"Consecutive traps BEGIN: %d", self.consecutiveTraps);
    if(self.consecutiveTraps == 5)
    {
        [self addCheeseToTunnell];
        self.consecutiveTraps = 0;
        return;
    }
    short newType = 0;
    switch (self.floorNumber)
    {
        case 0: // ground floor
            [self addCheeseToTunnell];
            self.consecutiveTraps = 0;
            break;
        case 1: // first floor
            newType = arc4random() % 2;
            switch (newType)
        {
            case 0:
                self.consecutiveTraps = 0;
                [self addCheeseToTunnell];
                break;
            default:
                self.consecutiveTraps++;
                [self addTrapToTunnell];
                break;
        }
            break;
            
        case 2: //second floor
            newType = arc4random() % 3;
            switch (newType)
        {
            case 0:
                self.consecutiveTraps = 0;
                [self addCheeseToTunnell];
                break;
            case 1:
                self.consecutiveTraps++;
                [self addCatToTunnell];
                break;
            default:
                self.consecutiveTraps++;
                [self addTrapToTunnell];
                break;
        }
            break;
        case 3: //third floor and on
            newType = arc4random() % 4;
            switch (newType)
        {
            case 0:
                self.consecutiveTraps = 0;
                [self addCheeseToTunnell];
                break;
            case 1:
                self.consecutiveTraps++;
                [self addFoxToTunnell];
                break;
            case 2:
                self.consecutiveTraps++;
                [self addCatToTunnell];
                break;
            default:
                self.consecutiveTraps++;
                [self addTrapToTunnell];
                break;
        }
            break;
        case 4: //fourth floor and on
            newType = arc4random() % 5;
            switch (newType)
        {
            case 0:
                self.consecutiveTraps = 0;
                [self addCheeseToTunnell];
                break;
            case 1:
                self.consecutiveTraps++;
                [self addFoxToTunnell];
                break;
            case 2:
                self.consecutiveTraps++;
                [self addCatToTunnell];
                break;
            case 3:
                self.consecutiveTraps++;
                [self addHawkToTunnell];
                break;
            default:
                self.consecutiveTraps++;
                [self addTrapToTunnell];
                break;
        }
            break;
        default: //fifth floor and on
            newType = arc4random() % 6;
            switch (newType)
        {
            case 0:
                self.consecutiveTraps = 0;
                [self addCheeseToTunnell];
                break;
            case 1:
                self.consecutiveTraps++;
                [self addFoxToTunnell];
                break;
            case 2:
                self.consecutiveTraps++;
                [self addCatToTunnell];
                break;
            case 3:
                self.consecutiveTraps++;
                [self addHawkToTunnell];
                break;
            case 4:
                self.consecutiveTraps++;
                [self addSnakeToTunnell];
                break;
            default:
                self.consecutiveTraps++;
                [self addTrapToTunnell];
                break;
        }
    }
    NSLog(@"Consecutive traps END: %d", self.consecutiveTraps);
}

- (void)addElementsToTunnell
{
    for(int i = 0; i < self.noOfElementsInHorisontalShaft; i++)
    {
        [self addElementToTunnell];
    }
}

- (void)addRandomNumber
{
    int randomNumber = self.targetValue;
    int n = arc4random() % 2;
    if(n == 1)
    {
        randomNumber+=n;
    }
    else
    {
        randomNumber-=n;
    }
//    [self addNewNumber:randomNumber];
}


- (void) levelUp
{
    [self setBlankTargetText];
    self.jumperNode.color = [SKColor greenColor];
    self.jumperNode.colorBlendFactor = 1.0;
    [self.avLevelUpSound play];
    
    [self blinkJumper];
    self.bLiftSequenceStarted = YES;;
    self.speedlevel -= SPEED_LEVEL_DELTA;
    self.impulse -= IMPULSE_DELTA;
//    self.speedlevel = SPEED_LEVEL;
    self.bLevelTransition = YES;
    self.bLevelUp = YES;
    self.equationType++;
    NSLog(@"Equation type %d", self.equationType);
//    [self moveUpTimer];

    NSLog(@"Level up speed %f impulse %f", self.speedlevel, self.impulse);
}

- (void) addCheese
{
    NSLog(@"Play cheese sound");
//    [self.avCheeseSound play];
    if(self.bAudioOn)
    {
        [self runAction:self.cheeseSound];
    }
    self.cheeseCollected++;
    [self updateCheeseText];
    
    NSNumber *nextLevel = [self.nextLevelValueArray objectAtIndex:self.floorNumber];
    if(!self.bLevelTransition && self.cheeseCollected >= nextLevel.intValue)
    {
        [self levelUp];
    }
}

- (void) removeCheese
{
    self.cheeseCollected--;
    [self updateCheeseText];
    if(self.cheeseCollected == 0)
    {
        [self addFailureMessage];
    }
}

- (void) updateCheeseText
{
    NSNumber* nextLevel = [self.nextLevelValueArray objectAtIndex:self.floorNumber];
    NSString *s = [[NSString alloc] initWithFormat:@"%ld/%d",(long)self.cheeseCollected, nextLevel.intValue];
    self.cheeseNodeStatusText.text = s;
    float xtext = self.cheeseNodeStatus.position.x+self.cheeseNodeStatusText.frame.size.width;
    self.cheeseNodeStatusText.position = CGPointMake(xtext,self.cheeseNodeStatus.position.y);
}

- (void) updateFloorNumberText
{
    self.floorNumberText.text = [[NSString alloc] initWithFormat:@"%ld/%d",(long)self.floorNumber, HEAVEN];
    float xtext = self.floorNumberSymbol.position.x+self.floorNumberText.frame.size.width;
    self.floorNumberText.position = CGPointMake(xtext,self.floorNumberText.position.y);
}

- (void) addCheeseStatus
{
    CGFloat fs = FONT_SIZE * self.scrscale;
    self.cheeseNodeStatus = [SKSpriteNode spriteNodeWithImageNamed:@"cheese.png"];
    float h = self.cheeseNodeStatus.size.height;
    float scale =  fs / h;
    self.cheeseNodeStatus.xScale = scale;
    self.cheeseNodeStatus.yScale = scale;
    float maxy = CGRectGetMaxY(self.frame);
    float x = self.elevatorShaft.frame.origin.x + self.elevatorShaft.size.width*1.5;
    float y = maxy-self.cheeseNodeStatus.size.height*3;
    self.cheeseNodeStatus.position = CGPointMake(x,y);
    self.cheeseNodeStatus.anchorPoint = CGPointMake(0.0,0.0);
    [self addChild:self.cheeseNodeStatus];

    self.cheeseNodeStatusText = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.cheeseNodeStatusText.fontSize = fs;
    [self updateCheeseText];
    [self addChild:self.cheeseNodeStatusText];

}

- (void) addFloorNumber
{
    CGFloat fs = FONT_SIZE * self.scrscale;
    self.floorNumberSymbol = [SKSpriteNode spriteNodeWithImageNamed:@"elevatorsymbol.png"];
    float h = self.floorNumberSymbol.size.height;
    float scale =  fs / h;
    self.floorNumberSymbol.xScale = scale;
    self.floorNumberSymbol.yScale = scale;
    float maxy = CGRectGetMaxY(self.frame);
    float x = self.elevatorShaft.frame.origin.x + self.elevatorShaft.frame.size.width*1.5;
    float y = maxy-self.cheeseNodeStatus.frame.size.height*4.2;
    self.floorNumberSymbol.position = CGPointMake(x,y);
    self.floorNumberSymbol.anchorPoint = CGPointMake(0.0,0.0);
    [self addChild:self.floorNumberSymbol];

    self.floorNumberText = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.floorNumberText.fontSize = FONT_SIZE * self.scrscale;
    NSLog(@"Floornumbertext font size: %f", self.floorNumberText.fontSize);
    float xtext = self.floorNumberSymbol.frame.origin.x+self.floorNumberSymbol.frame.size.width;;
    self.floorNumberText.position = CGPointMake(xtext,y);
    [self updateFloorNumberText];
    [self addChild:self.floorNumberText];
}


- (void) addCheeseToTunnell
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"cheese.png"];
    [self addNodeToTunnell:node];
    node.physicsBody.categoryBitMask = cheeseCategory;
    node.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    node.physicsBody.collisionBitMask = 0;
}

- (void) addTrapToTunnell
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"mousetrap.png"];
    [self addNodeToTunnell:node];
    node.physicsBody.categoryBitMask = trapCategory;
    node.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    node.physicsBody.collisionBitMask = 0;
}

- (void) addNodeToTunnell:(SKSpriteNode*)node
{
    int x = self.state * self.distance;
    NSLog(@"addNodeToTunnell at %d speed %f", x, self.speedlevel);
    float yScale = self.tunnellShaft.size.height/node.size.height;
    node.xScale = yScale;
    node.yScale = yScale;
    node.position = CGPointMake(CGRectGetMaxX(self.frame)+x,self.yoff+(self.shaftHeight+node.frame.size.height)/2);
//    node.anchorPoint = CGPointMake(0.0,0.0);
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:node.frame.size.width/PHY_RAD];
    node.physicsBody.friction = 0.0f;
    node.physicsBody.affectedByGravity = NO;
    node.physicsBody.velocity = CGVectorMake(self.speedlevel * self.scrscale, 0.0f);
    node.physicsBody.restitution = 0.0f;
    node.physicsBody.linearDamping = 0.0f;
    node.physicsBody.allowsRotation = NO;
    [self addChild:node];
    [self.lineNodes addObject:node];
    self.state++;
}

- (void) addCatToTunnell
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"cat.png"];
    [self addNodeToTunnell:node];
    node.physicsBody.categoryBitMask = trapCategory;
    node.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    node.physicsBody.collisionBitMask = 0;
}
- (void) addFoxToTunnell
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"fox.png"];
    [self addNodeToTunnell:node];
    node.physicsBody.categoryBitMask = trapCategory;
    node.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    node.physicsBody.collisionBitMask = 0;
}
- (void) addHawkToTunnell
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"hawk.png"];
    [self addNodeToTunnell:node];
    node.physicsBody.categoryBitMask = trapCategory;
    node.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    node.physicsBody.collisionBitMask = 0;
}
- (void) addSnakeToTunnell
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"snake.png"];
    [self addNodeToTunnell:node];
    node.physicsBody.categoryBitMask = trapCategory;
    node.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    node.physicsBody.collisionBitMask = 0;
}


- (void) addNewNumber:(int)number
{
    int x = self.state * self.distance;
    NSLog(@"addNewNumber %d at %d speed %f", number, x, self.speedlevel);
    ETNumberNode *numberNode;
    
    numberNode = [ETNumberNode labelNodeWithFontNamed:@"Chalkduster"];
    numberNode.numberValue = number;
    
    numberNode.text = [[NSString alloc] initWithFormat:@"%d",number];
    numberNode.fontSize = FONT_SIZE * self.scrscale;
    numberNode.color = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    numberNode.colorBlendFactor = 1.0;
    //    numberNode.position = CGPointMake(CGRectGetMaxX(self.frame)+x,CGRectGetMinY(self.frame)+30);
    numberNode.position = CGPointMake(CGRectGetMaxX(self.frame)+x,self.yoff+(self.shaftHeight+numberNode.frame.size.height)/2);
    numberNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:numberNode.frame.size.width/PHY_RAD];
    //    numberNode.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:numberNode.frame];
    numberNode.physicsBody.affectedByGravity = NO;
    numberNode.physicsBody.velocity = CGVectorMake(self.speedlevel * self.scrscale, 0.0f);
    numberNode.physicsBody.restitution = 0.0f;
    numberNode.physicsBody.linearDamping = 0.0f;
    numberNode.physicsBody.allowsRotation = NO;
    numberNode.physicsBody.categoryBitMask = numberCategory;
    numberNode.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    numberNode.physicsBody.collisionBitMask = 0;
    [self addChild:numberNode];
    [self.lineNodes addObject:numberNode];
    self.state++;
}

- (void) addRandomOperator
{
    if((arc4random() % 2) == 0)
    {
        if(self.currentOperatorValue == ADD)
        {
            NSLog(@"Adding subtract operator");
            [self addNewOperator:SUBTRACT];
        }
        else
        {
            NSLog(@"Adding add operator");
            [self addNewOperator:ADD];
        }
    }
}


- (void) addJumper
{
    //self.jumperNode = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
//    self.jumperNode = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(self.elevatorShaft.size.width, self.yoff/2)];

    self.jumperNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg1.png"];
    float xScale = self.elevatorShaft.size.width/self.jumperNode.size.width;
    self.jumperNode.xScale = xScale;
    self.jumperNode.yScale = xScale;
    
    
    self.jumperNode.anchorPoint = CGPointMake(0.5,0.0);
    //    self.jumperNode.text = @"0";
    self.jumperValue = 0;
    
//    self.jumperNode.fontSize = 82;
    NSLog(@"jumperNode width:%f", self.jumperNode.size.width);
    NSLog(@"jumperNode height:%f", self.jumperNode.size.height);
    
    int x = self.elevatorShaft.size.width;
    NSLog(@"Shaft width:%d", x);
    self.jumperNode.position = CGPointMake(self.elevatorShaft.position.x+self.jumperNode.size.width/2,self.platform.position.y);

    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, self.jumperNode.size.width,self.jumperNode.size.height);
    CGPathAddLineToPoint(path, NULL, 0,self.jumperNode.size.height);
    CGPathCloseSubpath(path);
    
    
    /*
    SKShapeNode *shape = [[SKShapeNode alloc] init];
    shape.path = path;
    shape.strokeColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    shape.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:shape];
*/
    self.jumperNode.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
//    self.jumperNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.jumperNode.frame.size.width/2];
//    self.jumperNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.jumperNode.size];
    self.jumperNode.physicsBody.usesPreciseCollisionDetection = YES;
    self.jumperNode.physicsBody.friction = 0.0f;
    self.jumperNode.physicsBody.restitution = 0.0f;
    self.jumperNode.physicsBody.linearDamping = 0.0f;
    self.jumperNode.physicsBody.mass = IPHONE_35_JUMPER_MASS;
    self.jumperNode.physicsBody.allowsRotation = NO;
    self.jumperNode.physicsBody.categoryBitMask = jumperCategory;
    self.jumperNode.physicsBody.collisionBitMask = elevatorCategory;
    self.jumperNode.physicsBody.contactTestBitMask = elevatorCategory;
    [self addChild:self.jumperNode];
}

- (void) addPlatform
{
    //self.jumperNode = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
//    SKSpriteNode* platform = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(64,8)];
    self.platform = [SKSpriteNode spriteNodeWithImageNamed:@"mousehole.png"];
    self.platform.xScale = self.elevatorShaft.size.width/self.platform.size.width;
    self.platform.yScale = self.elevatorShaft.size.width/self.platform.size.height;
    self.platform.anchorPoint = CGPointMake(0.0,0.0);
    
    self.platform.position = CGPointMake(CGRectGetMaxX(self.frame)/10,CGRectGetMaxY(self.frame)/8*5);

    /*
    [self createRandomNumber];

    int i = 0;
    int iDistance = self.frame.size.width / 7;
    int isx = CGRectGetMinX(self.frame);
    for (i = 1; i < FIXED_UPPER_NUMBER; i++)
    {
        SKLabelNode *numberNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        numberNode.text = [[NSString alloc] initWithFormat:@"%d",i];
        numberNode.fontSize = FONT_SIZE;
        numberNode.color = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        numberNode.colorBlendFactor = 1.0;
        numberNode.position = CGPointMake(isx+i*iDistance,CGRectGetMinY(self.frame)+self.yoff+30);
        [self addChild:numberNode];
    }
    SKLabelNode *numberNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    numberNode.text = [[NSString alloc] initWithFormat:@"%d",self.randomNumber];
    numberNode.fontSize = FONT_SIZE;
    numberNode.color = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    numberNode.colorBlendFactor = 1.0;
    numberNode.position = CGPointMake(isx+i*iDistance,CGRectGetMinY(self.frame)+self.yoff+30);
    [self addChild:numberNode];
     */
    
/*
    platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform.frame.size];
    platform.physicsBody.affectedByGravity = NO;
    platform.physicsBody.friction = 0.0f;
    platform.physicsBody.restitution = 0.0f;
    platform.physicsBody.linearDamping = 0.0f;
    platform.physicsBody.allowsRotation = NO;
    platform.physicsBody.categoryBitMask = platformCategory;
    platform.physicsBody.collisionBitMask = 0;
    platform.physicsBody.contactTestBitMask = jumperCategory;
 */
    [self addChild:self.platform];
}

/*
- (void) addPausePlatform
{
    SKSpriteNode* platform = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:CGSizeMake(64,8)];
    self.platform.position = CGPointMake(CGRectGetMidX(self.frame)/2,CGRectGetMaxY(self.frame)/8*5);
    [self addChild:platform];
}
*/


- (void) addNewOperator:(int)operatorValue
{
    int x = self.state * self.distance;
    
    NSLog(@"addNewOperator %d at %d", operatorValue, x);
    ETNumberNode *operatorNode;
    
    operatorNode = [ETNumberNode labelNodeWithFontNamed:@"Chalkduster"];
    operatorNode.numberValue = operatorValue;
    
    switch (operatorValue) {
        case ADD:
            operatorNode.text = @"±";
            operatorNode.numberValue = ADD;
            break;
        case SUBTRACT:
            operatorNode.text = @"±";
            operatorNode.numberValue = SUBTRACT;
            break;
        case MULTIPLY:
            operatorNode.text = [[NSString alloc] initWithFormat: @"%C", MULT_SIGN];
            operatorNode.numberValue = MULTIPLY;
            break;
        case DIVIDE:
            operatorNode.text = @":";
            operatorNode.numberValue = DIVIDE;
            break;
        default:
            break;
    }
    operatorNode.fontSize = FONT_SIZE * self.scrscale;
    operatorNode.color = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    
    operatorNode.colorBlendFactor = 1.0;
    operatorNode.position = CGPointMake(CGRectGetMaxX(self.frame)+x,self.yoff+30);
    operatorNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:operatorNode.frame.size.width/2];
    operatorNode.physicsBody.friction = 0.0f;
    operatorNode.physicsBody.velocity = CGVectorMake(self.speedlevel * self.scrscale, 0.0f);
    operatorNode.physicsBody.affectedByGravity = NO;
    operatorNode.physicsBody.restitution = 0.0f;
    operatorNode.physicsBody.linearDamping = 0.0f;
    operatorNode.physicsBody.allowsRotation = NO;
    operatorNode.physicsBody.categoryBitMask = operatorCategory;
    operatorNode.physicsBody.contactTestBitMask = jumperCategory | borderCategory;
    operatorNode.physicsBody.collisionBitMask = 0;
    [self addChild:operatorNode];
    [self.lineNodes addObject:operatorNode];
    
    self.state++;
}

- (void) addCurrentOperator
{
    self.currentOperatorNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.currentOperatorNode.text = @"+";
    self.currentOperatorNode.fontSize = FONT_SIZE * self.scrscale;
    self.currentOperatorNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    self.currentOperatorNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.currentOperatorNode.frame.size.width/2];
    self.currentOperatorNode.physicsBody.friction = 0.0f;
    self.currentOperatorNode.physicsBody.affectedByGravity = NO;
    self.currentOperatorNode.physicsBody.restitution = 0.0f;
    self.currentOperatorNode.physicsBody.linearDamping = 0.0f;
    self.currentOperatorNode.physicsBody.allowsRotation = NO;
    [self addChild:self.currentOperatorNode];
}


- (void) setBlankTargetText
{
    self.targetNode.text = @"";
    self.targetNode2.text = @"";
}

- (void) updateTargetText
{
    return;
    self.targetValue = arc4random() % FIXED_UPPER_NUMBER;

    int i = arc4random() % FIXED_UPPER_NUMBER;
    int j = arc4random() % FIXED_UPPER_NUMBER;;
    int k = arc4random() % FIXED_UPPER_NUMBER;

    switch (self.equationType) {
        case CHEESE_ONLY:
            NSLog(@"Equation type CHEESE_ONLY=%d", self.equationType);
            self.targetNode.text = @"";
            self.targetNode2.text = @"";
            break;
        case CHEESE_AND_TRAPS:
            NSLog(@"Equation type CHEESE_AND_TRAPS=%d", self.equationType);
            self.targetNode.text = @"";
            self.targetNode2.text = @"";
            break;
        case NU_ADD:
            NSLog(@"Equation type NU_ADD=%d", self.equationType);
            self.targetValue = i + j;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%d+%d=",i,j];
            self.targetNode2.text = @"";
            break;
        case NU_SUBTRACT:
            NSLog(@"Equation type NU_SUBTRACT=%d", self.equationType);
            if(i < self.targetValue)
            {
                j = self.targetValue + i;
                self.targetNode.text = [[NSString alloc] initWithFormat:@"%d-%d=",j,i];
                self.targetNode2.text = @"";
            }
            else
            {
                j = i - self.targetValue;
                self.targetNode.text = [[NSString alloc] initWithFormat:@"%d-%d=",i,j];
                self.targetNode2.text = @"";
            }
            break;
        case NU_MULTIPLY:
            NSLog(@"Equation type NU_MULTIPLY=%d", self.equationType);
            while(j == 0)
            {
                j = arc4random() % FIXED_UPPER_NUMBER;
            }
            while(i == 0)
            {
                i = arc4random() % FIXED_UPPER_NUMBER;
            }
            self.targetValue = j * i;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%d%C%d=",i, MULT_SIGN, j];
            self.targetNode2.text = @"";
            break;
        case NU_DIVIDE:
            NSLog(@"Equation type NU_DIVIDE=%d", self.equationType);
            while(self.targetValue == 0)
            {
                self.targetValue = arc4random() % FIXED_UPPER_NUMBER;
            }
            while(i == 0)
            {
                i = arc4random() % FIXED_UPPER_NUMBER;
            }
            j = self.targetValue * i;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%d:%d=",j, i];
            self.targetNode2.text = @"";
            break;
        case EQ_ADD:
            NSLog(@"Equation type EQ_ADD=%d", self.equationType);
            j = self.targetValue + i;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%d+x=%d",i,j];
            self.targetNode2.text = @"x=";
            break;
        case EQ_SUBTRACT:
            NSLog(@"Equation type EQ_SUBTRACT=%d", self.equationType);
            if(i < self.targetValue)
            {
                j = self.targetValue - i;
                self.targetNode.text = [[NSString alloc] initWithFormat:@"x-%d=%d",i,j];
                self.targetNode2.text = @"";
            }
            else
            {
                j = i + self.targetValue;
                self.targetNode.text = [[NSString alloc] initWithFormat:@"%d-x=%d",j,i];
            }
            self.targetNode2.text = @"x=";
            break;
        case EQ_MULTIPLY:
            NSLog(@"Equation type EQ_MULTIPLY=%d", self.equationType);
            while(self.targetValue == 0)
            {
                self.targetValue = arc4random() % FIXED_UPPER_NUMBER;
            }
            while(i <= 1)
            {
                i = arc4random() % FIXED_UPPER_NUMBER;
            }
            j = self.targetValue * i;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%dx=%d",i,j];
            self.targetNode2.text = @"x=";
            break;
        case EQ_ADD_MULTIPLY:
            while(k <= 1)
            {
                k = arc4random() % FIXED_UPPER_NUMBER;
            }
            NSLog(@"Equation type EQ_ADD_MULTIPLY=%d", self.equationType);
            j = self.targetValue * k + i;;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%dx+%d=%d",k,i,j];
            self.targetNode2.text = @"x=";
            break;
        case EQ_SUBTRACT_MULTIPLY:
            NSLog(@"Equation type EQ_SUBTRACT_MULTIPLY=%d", self.equationType);
            while(k <= 1)
            {
                k = arc4random() % FIXED_UPPER_NUMBER;
            }
            j = self.targetValue * k - i;;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%dx-%d=%d",k,i,j];
            self.targetNode2.text = @"x=";
            break;
        case EQ_FRACTION_X_NOMINATOR:
            NSLog(@"Equation type EQ_FRACTION_X_NOMINATOR=%d", self.equationType);
            while(j == 0)
            {
                j = arc4random() % FIXED_UPPER_NUMBER;
            }
            while(i == 0)
            {
                i = arc4random() % FIXED_UPPER_NUMBER;
            }
            self.targetValue = j * i;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"x:%d=%d",j, i];
            self.targetNode2.text = @"x=";
            break;
        case EQ_FRACTION_X_DENOMINATOR:
            NSLog(@"Equation type EQ_FRACTION_X_DENOMINATOR=%d", self.equationType);
            while(self.targetValue == 0)
            {
                self.targetValue = arc4random() % FIXED_UPPER_NUMBER;
            }
            while(i == 0)
            {
                i = arc4random() % FIXED_UPPER_NUMBER;
            }
            j = self.targetValue * i;
            self.targetNode.text = [[NSString alloc] initWithFormat:@"%d:x=%d",j, i];
            self.targetNode2.text = @"x=";
            break;
        default:
            NSLog(@"Default statement in updateTargetText");
            break;
    }
}
- (void) addTarget
{
    self.jumperValue = 0;

    self.targetNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.targetNode.fontSize = FONT_SIZE * self.scrscale;
    self.targetNode.position = CGPointMake(CGRectGetMaxX(self.frame)*0.6,CGRectGetMaxY(self.frame)*2/3);
    [self addChild:self.targetNode];

    self.targetNode2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.targetNode2.fontSize = FONT_SIZE * self.scrscale;
    self.targetNode2.position = CGPointMake(CGRectGetMaxX(self.frame)*0.6,CGRectGetMaxY(self.frame)*1/2);
    [self addChild:self.targetNode2];

//    [self updateTargetText];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1 Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    // 3 react to the contact between number and jumper
    NSLog(@"Contact %u %u", firstBody.categoryBitMask, secondBody.categoryBitMask);
    if (firstBody.categoryBitMask == jumperCategory && !self.bLiftSequenceStarted)
    {
//        self.speedlevel-=SPEED_LEVEL_DELTA;
//        self.impulse-= IMPULSE_DELTA;
        
        if(secondBody.categoryBitMask == elevatorCategory)
        {
            if(self.bJumpRequested == YES)
            {
                self.bJumpRequested = NO;
                [self jump];
            }
            else
            {
                self.jumperNode.physicsBody.contactTestBitMask = 0;
            }
            NSLog(@"Jump requested set to no");
        }
        else
        {
            if(secondBody.categoryBitMask == numberCategory)
            {
                ETNumberNode* numberNode = (ETNumberNode*)secondBody.node;
                if(numberNode.numberValue == self.targetValue)
                {
                    numberNode.text = @"";
                    [self addCheese];
                    
                    if(!self.bLevelTransition)
                    {
                        [self updateTargetText];
                    }
                }
                else
                {
                    [self levelDown];
                }
            }
            else if(secondBody.categoryBitMask == cheeseCategory)
            {
                SKSpriteNode* cheeseNode = (SKSpriteNode*)secondBody.node;
                [self addCheese];
                cheeseNode.yScale = 0.0f;
            }
            else if(secondBody.categoryBitMask == trapCategory)
            {
                [self levelDown];
            } //endif number, cheese, trap
        } //endif border
    }
    else if (firstBody.categoryBitMask == borderCategory)
    {
        self.state--;
        [secondBody.node removeFromParent];
        [self.lineNodes removeObjectAtIndex:0]; //Removes first object

        if(self.bFirstLeftBorderCollision)
        {
            self.state -= 1;
            self.bFirstLeftBorderCollision = FALSE;
        }
        if(!self.bLevelTransition)
        {
            [self addElementToTunnell];
        }
        else if(![self.lineNodes count])
        {
            if(self.bLevelUp)
            {
                [self moveElevatorUp];
            }
            else if(self.bLevelDown)
            {
                [self moveElevatorDown];
            }
        }
    }
}

- (void) levelDown
{
    [self setBlankTargetText];
    self.jumperNode.color = [SKColor redColor];
    self.jumperNode.colorBlendFactor = 1.0;
    [self.avLevelDownSound play];
    
//    [self moveDownTimer];
    [self blinkJumper];
    self.bLiftSequenceStarted = YES;;
//    self.speedlevel = SPEED_LEVEL;
    self.speedlevel += SPEED_LEVEL_DELTA;
    self.impulse += IMPULSE_DELTA;
    self.bLevelTransition = YES;
    self.bLevelDown = YES;
    self.equationType--;
    NSLog(@"Level down speed %f impulse %f", self.speedlevel, self.impulse);
}

/*
- (void) moveUpTimer
{
    NSLog(@"moveUpTimer started");
    self.bLiftSequenceStarted = YES;
    [self blinkJumper];

    [NSTimer scheduledTimerWithTimeInterval:SECONDS_TO_EMPTY_LINE
                                     target:self
                                   selector:@selector(moveUp:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) moveDownTimer
{
    NSLog(@"moveDownTimer started");
    self.bLiftSequenceStarted = YES;
    [self blinkJumper];

    [NSTimer scheduledTimerWithTimeInterval:SECONDS_TO_EMPTY_LINE
                                     target:self
                                   selector:@selector(moveDown:)
                                   userInfo:nil
                                    repeats:NO];
}

*/

- (void) moveElevatorUp
{
    SKAction *moveShaftNode = [SKAction moveByX:0.0 y:-self.crust.frame.size.height duration:ELEVATOR_SOUND_LENGTH];
    SKAction *waitForFloorNode = [SKAction waitForDuration:ELEVATOR_SOUND_LENGTH-2.0];

    SKAction *liftUp = [SKAction moveByX:0.0 y:20 duration:1.0];
    SKAction *liftStop = [SKAction moveByX:0.0 y:-20 duration:1.0];
    SKAction *liftSequence = [SKAction sequence:@[liftUp, waitForFloorNode, liftStop]];
    [self.elevator runAction: liftSequence];
    [self.elevatorSupport runAction: liftSequence];

    SKAction *shaftSequence = [SKAction sequence:@[moveShaftNode]];
    [self.tunnellShaft runAction:shaftSequence];
    [self.tunnellShaftAbove runAction:shaftSequence];
    [self.crust runAction: shaftSequence];
    [self.crustAbove runAction:shaftSequence completion:^{
        [self elevatorArrivedOneFloorUp];
    }];
    [self.avElevatorSound play];
//    [self runAction:self.elevatorSound];
}
/*
- (void) startElevatorUpTimer {
    NSLog(@"startElevatorUpTimer started");
    
    [NSTimer scheduledTimerWithTimeInterval:8
                                     target:self
                                   selector:@selector(elevatorArrivedOneFloorUp:)
                                   userInfo:nil
                                    repeats:NO];
}
*/
- (void) elevatorArrivedOneFloorUp //:(NSTimer *) timer
{
    self.bLevelTransition = NO;
    self.bLevelUp = NO;
    self.bLiftSequenceStarted = NO;
//    self.impulse = IMPULSE;
    self.state = 0;
    self.bFirstLeftBorderCollision = YES;
    self.cheeseCollected = 0;
    self.floorNumber++;
    self.jumperNode.colorBlendFactor = 0.0;
    self.jumperNode.physicsBody.contactTestBitMask = 0;
    
    
    NSLog(@"Floornumber %d", self.floorNumber);
    [self updateFloorNumberText];
    [self updateCheeseText];
    if(self.floorNumber == HEAVEN)
    {
        [self addSuccessMessage];
    }
    else
    {
//        [self updateTargetText];
        [self addElementsToTunnell];
        [self addNextCrust];
    }
}

/*
- (void) startElevatorDownTimer {
    NSLog(@"startElevatorDownTimer started");
    self.bLiftSequenceStarted = NO;
    [NSTimer scheduledTimerWithTimeInterval:8
                                     target:self
                                   selector:@selector(elevatorArrivedOneFloorDown:)
                                   userInfo:nil
                                    repeats:NO];
}
*/
- (void) elevatorArrivedOneFloorDown //:(NSTimer *) timer
{
    self.bLevelDown = NO;
    self.bLevelTransition = NO;
    self.bLiftSequenceStarted = NO;
//    self.impulse = IMPULSE;
    self.state = 0;
    self.bFirstLeftBorderCollision = YES;
    self.cheeseCollected = 0;
    self.floorNumber--;
    self.jumperNode.colorBlendFactor = 0.0;
    self.jumperNode.physicsBody.contactTestBitMask = 0;

    [self updateCheeseText];
    [self updateFloorNumberText];
    
//    [self updateTargetText];
    [self addElementsToTunnell];
    [self addPreviousCrust];
}




- (void) blinkJumper
{
    SKAction *fadeAway = [SKAction fadeOutWithDuration:0.1];
    SKAction *fadeIn = [SKAction fadeInWithDuration: 0.1];
    
    SKAction *sequence = [SKAction sequence:@[fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,
                                              fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,
                                              fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,
                                              fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn,fadeAway,fadeIn]];
    [self.jumperNode runAction: sequence];
}

- (void) moveElevatorDown
{
    SKAction *moveShaftNode = [SKAction moveByX:0.0 y:self.crust.size.height duration:ELEVATOR_SOUND_LENGTH];
    SKAction *waitForFloorNode = [SKAction waitForDuration:ELEVATOR_SOUND_LENGTH-2.0];
    
    SKAction *liftDown = [SKAction moveByX:0.0 y:-20 duration:1.0];
    SKAction *liftStop = [SKAction moveByX:0.0 y:20 duration:1.0];
    SKAction *liftSequence = [SKAction sequence:@[liftDown, waitForFloorNode, liftStop]];
    [self.elevator runAction: liftSequence];
    [self.elevatorSupport runAction: liftSequence];
    
    SKAction *shaftSequence = [SKAction sequence:@[moveShaftNode]];
    [self.tunnellShaft runAction:shaftSequence];
    [self.tunnellShaftBelow runAction:shaftSequence];
    [self.crust runAction: shaftSequence];
    [self.crustBelow runAction: shaftSequence completion:^{
        [self elevatorArrivedOneFloorDown];
    }];
    [self.avElevatorSound play];
//    [self runAction:self.elevatorSound];
}
/*
- (BOOL)pausePlayButtonTouched:(NSSet*)touches
{
    for (UITouch *touch in touches)
    {
        CGPoint positionInScene = [touch locationInNode:self];
        if([self.pauseNode containsPoint:positionInScene])
        {
            return TRUE;
        }
    }
    return FALSE;
}
 */

- (BOOL)adTouched:(NSSet*)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint positionInScene = [touch locationInNode:self];
        if(self.vc._bannerView)
        {
            return [self.vc._bannerView pointInside:positionInScene withEvent:event];
        }
    }
    return FALSE;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self adTouched:touches withEvent:event])
    {
        return;
    }
    if(self.bOnPlatform)
    {
        self.bOnPlatform = NO;
        //self.jumperNode.physicsBody.collisionBitMask &= ~platformCategory;
//        [self addJumper];
        [self.platform removeFromParent];
        [self startGame];
    }
    else if(self.bGameOver && !self.avSuccessSong.isPlaying)
    {
        [self removeAllChildren];
        [self.lineNodes removeAllObjects];
        [self.numberNodes removeAllObjects];
        self.bOnPlatform = YES;
        self.floorNumber = START_FLOOR_NUMBER;
        [self addCrusts];
        [self addShafts];
        [self addPlatform];
        [self.avLoungeSong play];
        [self addStartMessage];
    }
    else if(!self.jumperNode.physicsBody.contactTestBitMask)
    {
        self.jumperNode.physicsBody.contactTestBitMask = elevatorCategory;
        [self jump];
    }
    else
    {
        self.bJumpRequested = true;
    }
}

- (void) jump
{
    [self.jumperNode.physicsBody applyImpulse:CGVectorMake(0.0f, self.impulse * self.scrscale )];
    if(self.bAudioOn)
    {
        [self runAction:self.jumpSound];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self Move:touches];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
