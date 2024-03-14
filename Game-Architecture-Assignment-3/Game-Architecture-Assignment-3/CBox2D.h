//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Objective-C++ wrapper for Box2D library
//
//====================================================================

#ifndef MyGLGame_CBox2D_h
#define MyGLGame_CBox2D_h

#import <Foundation/NSObject.h>
#import <Foundation/Foundation.h>
#include <vector>


// Set up brick and ball physics parameters here:
//   position, width+height (or radius), velocity,
//   and how long to wait before dropping brick

#define BRICK_POS_X         0
#define BRICK_POS_Y         90
#define BRICK_WIDTH         10.0f
#define BRICK_HEIGHT        5.0f
#define BRICK_WAIT            1.0f
#define BALL_POS_X            0
#define BALL_POS_Y            5
#define BALL_RADIUS            3.0f
#define BALL_VELOCITY        10000.0f
#define BALL_OUT_OF_BOUNDS_Y    (-10.0f)

#define PADDLE_WIDTH        15.0f
#define PADDLE_HEIGHT       3.0f
#define PADDLE_START_X      200.0f
#define PADDLE_START_Y      100.0f

#define NUM_ROWS            10
#define NUM_COLUMNS         7
#define BRICK_SPACING       1
#define BRICK_START_X       -32.5f
#define BRICK_START_Y       100

#define X_BOUND             65          // Width (x-value) from center of screen (0,0)
#define Y_BOUND             225         // Height (y-value) from center of screen (0,0)

#define WALL_Y_OFFSET       100.0f      // Y offset to move side walls up by
#define WALL_THICKNESS      1.0f        // Wall thickness
#define WALL_HEIGHT         250.0f
#define TOP_WALL_WIDTH      130.0f

// You can define other object types here
typedef enum { ObjTypeBox=0, ObjTypeCircle=1, ObjTypePaddle=2, ObjTypeVertWall=3, ObjTypeHoriWall=4 } ObjectType;


// Location of each object in our physics world
struct PhysicsLocation {
    float x, y, theta;
};

struct BrickPosition {
    float x;
    float y;
};

// Information about each physics object
struct PhysicsObject {

    struct PhysicsLocation loc; // location
    ObjectType objType;         // type
    void *b2ShapePtr;           // pointer to Box2D shape definition
    void *box2DObj;             // pointer to the CBox2D object for use in callbacks
    bool isPaddle;              // a flag to identify the paddle
};


// Wrapper class
@interface CBox2D : NSObject

-(void) HelloWorld; // Basic Hello World! example from Box2D

-(void) createBrickPhysics;
-(void) LaunchBall;                                                         // launch the ball
-(void) UpdateBallPosition:(float)xCoordinate andY:(float)yCoordinate;      // move the ball directly, used at game start to move with the paddle
-(void) UpdatePaddlePosition:(float)xCoordinate;                            // move the paddle directly, only need to change the x value
-(void) Update:(float)elapsedTime;                                          // update the Box2D engine
-(void) RegisterHitWithString:(NSString *)physicsObjName;                   // Register when the ball hits the brick
-(void) AddObject:(char *)name newObject:(struct PhysicsObject *)newObj;    // Add a new physics object
-(struct PhysicsObject *) GetObject:(const char *)name;                     // Get a physics object by name
-(void) Reset:(int)numLives;                                                              // Reset Box2D
-(int) GetScore;

@property (nonatomic, assign) BOOL ballLaunched;

@end

#endif
