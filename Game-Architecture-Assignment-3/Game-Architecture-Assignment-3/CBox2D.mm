//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Objective-C++ wrapper for Box2D library
//
//====================================================================

#include <Box2D/Box2D.h>
#include "CBox2D.h"
#include <stdio.h>
#include <map>
#include <string>


// Some Box2D engine paremeters
const float MAX_TIMESTEP = 1.0f/60.0f;
const int NUM_VEL_ITERATIONS = 10;
const int NUM_POS_ITERATIONS = 3;


// Uncomment this lines to use the HelloWorld example
//#define USE_HELLO_WORLD


#pragma mark - Box2D contact listener class

// This C++ class is used to handle collisions
class CContactListener : public b2ContactListener
{
    
public:
    
    void BeginContact(b2Contact* contact) {};
    
    void EndContact(b2Contact* contact) {};
    
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
    {
        
        b2WorldManifold worldManifold;
        contact->GetWorldManifold(&worldManifold);
        b2PointState state1[2], state2[2];
        b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
        
        if (state2[0] == b2_addState)
        {
            
            // Use contact->GetFixtureA()->GetBody() to get the body that was hit
            b2Body* bodyA = contact->GetFixtureA()->GetBody();
            
            // Get the PhysicsObject as the user data, and then the CBox2D object in that struct
            // This is needed because this handler may be running in a different thread and this
            //  class does not know about the CBox2D that's running the physics
            struct PhysicsObject *objData = (struct PhysicsObject *)(bodyA->GetUserData());
            CBox2D *parentObj = (__bridge CBox2D *)(objData->box2DObj);
            
            // Call RegisterHit (assume CBox2D object is in user data)
            [parentObj RegisterHit];    // assumes RegisterHit is a callback function to register collision
            
        }
        
    }
    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {};
    
};

#pragma mark - CBox2D

@interface CBox2D ()
{
    
    // Box2D-specific objects
    b2Vec2 *gravity;
    b2World *world;
    CContactListener *contactListener;
    float totalElapsedTime;
    
    // Map to keep track of physics object to communicate with the renderer
    std::map<std::string, struct PhysicsObject *> physicsObjects;

#ifdef USE_HELLO_WORLD
    b2BodyDef *groundBodyDef;
    b2Body *groundBody;
    b2PolygonShape *groundBox;
#endif

    // Logit for this particular "game"
    bool ballHitBrick;  // register that the ball hit the break
        bool ballLaunched;  // register that the user has launched the ball
    
}
@end

@implementation CBox2D
@synthesize ballLaunched;
// initializing, adding the ball and brick objects here - Jun
- (instancetype)init
{
    
    self = [super init];
    
    if (self) {
        
        // Initialize Box2D
        gravity = new b2Vec2(0.0f, -10.0f);
        world = new b2World(*gravity);
        
#ifdef USE_HELLO_WORLD
        groundBodyDef = NULL;
        groundBody = NULL;
        groundBox = NULL;
#endif

        contactListener = new CContactListener();
        world->SetContactListener(contactListener);
        
        // Set up the brick and ball objects for Box2D
        struct PhysicsObject *newObj = new struct PhysicsObject;
        newObj->loc.x = BRICK_POS_X;
        newObj->loc.y = BRICK_POS_Y;
        newObj->objType = ObjTypeBox;
        newObj->isPaddle = false;
        char *objName = strdup("Brick");
        [self AddObject:objName newObject:newObj];
        
        newObj = new struct PhysicsObject;
        newObj->loc.x = BALL_POS_X;
        newObj->loc.y = BALL_POS_Y;
        newObj->objType = ObjTypeCircle;
        newObj->isPaddle = false;
        objName = strdup("Ball");
        [self AddObject:objName newObject:newObj];
        
        // Set up the paddle object for Box2D
        newObj = new struct PhysicsObject;
        newObj->loc.x = BALL_POS_X;
        newObj->loc.y = BALL_POS_Y - 2 * BALL_RADIUS;
        newObj->objType = ObjTypePaddle;
        newObj->isPaddle = true;
        objName = strdup("Paddle");
        [self AddObject:objName newObject:newObj];
        
        // Right wall
        newObj = new struct PhysicsObject;
        newObj->loc.x = X_BOUND + WALL_THICKNESS / 2;
        newObj->loc.y = WALL_Y_OFFSET;
        newObj->objType = ObjTypeVertWall;
        newObj->isPaddle = false;
        char *rightWallName = strdup("RightWall");
        [self AddObject:rightWallName newObject:newObj];
        
        // Left wall
        newObj = new struct PhysicsObject;
        newObj->loc.x = -X_BOUND - WALL_THICKNESS / 2;
        newObj->loc.y = WALL_Y_OFFSET;
        newObj->objType = ObjTypeVertWall;
        newObj->isPaddle = false;
        char *leftWallName = strdup("LeftWall");
        [self AddObject:leftWallName newObject:newObj];
        
        // Top wall
        newObj = new struct PhysicsObject;
        newObj->loc.x = 0;
        newObj->loc.y = Y_BOUND;
        newObj->objType = ObjTypeHoriWall;
        newObj->isPaddle = false;
        char *topWallName = strdup("TopWall");
        [self AddObject:topWallName newObject:newObj];
        
        totalElapsedTime = 0;
        ballHitBrick = false;
        ballLaunched = false;
        [self createBrickPhysics];
    }
    
    return self;
    
}

- (void)dealloc
{
    
    if (gravity) delete gravity;
    if (world) delete world;
#ifdef USE_HELLO_WORLD
    if (groundBodyDef) delete groundBodyDef;
    if (groundBox) delete groundBox;
#endif
    if (contactListener) delete contactListener;
    
}
-(void) createBrickPhysics {
   for (int row = 0; row < NUM_ROWS; row++) {
       for (int column = 0; column < NUM_COLUMNS; column++) {
           struct PhysicsObject *newObj = new struct PhysicsObject;
           newObj->loc.x = -25 + BRICK_POS_X + column * (BRICK_WIDTH + BRICK_SPACING);
           newObj->loc.y = 100 + BRICK_POS_Y - row * (BRICK_HEIGHT + BRICK_SPACING);
           newObj->objType = ObjTypeBox;
           // Create a unique name for each brick using row and column indices
           char objName[50]; // Adjust the size as needed
           snprintf(objName, sizeof(objName), "Brick (%d, %d)", row, column);
           printf("Object name: %s\n", objName);
           [self AddObject:objName newObject:newObj];
       }
   }
}

-(void)Update:(float)elapsedTime
{
    
    // Get pointers to the brick and ball physics objects
    struct PhysicsObject *theBrick = physicsObjects[std::string("Brick")];
    struct PhysicsObject *theBall = physicsObjects["Ball"];
    
    
    // Use these lines for debugging the brick and ball positions
    //    if (theBrick)
    //        printf("Brick: %4.2f %4.2f\t",
    //               ((b2Body *)theBrick->b2ShapePtr)->GetPosition().x,
    //               ((b2Body *)theBrick->b2ShapePtr)->GetPosition().y);
    //    if (theBall &&  theBall->b2ShapePtr)
    //        printf("Ball: %4.2f %4.2f",
    //               ((b2Body *)theBall->b2ShapePtr)->GetPosition().x,
    //               ((b2Body *)theBall->b2ShapePtr)->GetPosition().y);
    //    printf("\n");
    
    
    
    // If the last collision test was positive, stop the ball and destroy the brick
    if (ballHitBrick)
    {
        
        // Destroy the brick from Box2D and related objects in this class
        //world->DestroyBody(((b2Body *)theBrick->b2ShapePtr));
        //delete theBrick;
        //theBrick = nullptr;
        //physicsObjects.erase("Brick");
        //ballHitBrick = false;   // until a reset and re-launch
        
    }
    
    if (world)
    {
        
        while (elapsedTime >= MAX_TIMESTEP)
        {
            world->Step(MAX_TIMESTEP, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
            elapsedTime -= MAX_TIMESTEP;
        }
        
        if (elapsedTime > 0.0f)
        {
            world->Step(elapsedTime, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
        }
        
    }
    
    // Update each node based on the new position from Box2D
    for (auto const &b:physicsObjects) {
        if (b.second && b.second->b2ShapePtr) {
            b.second->loc.x = ((b2Body *)b.second->b2ShapePtr)->GetPosition().x;
            b.second->loc.y = ((b2Body *)b.second->b2ShapePtr)->GetPosition().y;
        }
    }
    
}

-(void)RegisterHit
{
    // Set some flag here for processing later...
    ballHitBrick = true;
}

-(void)LaunchBall
{
    // Check here if we need to launch the ball
    //  and if so, use ApplyLinearImpulse() and SetActive(true)
    if (!ballLaunched) {
        ballLaunched = true;
        // Apply a force (since the ball is set up not to be affected by gravity)
        struct PhysicsObject *theBall = physicsObjects["Ball"];
        ((b2Body *)theBall->b2ShapePtr)->ApplyLinearImpulse(b2Vec2(5000, BALL_VELOCITY),
                                                            ((b2Body *)theBall->b2ShapePtr)->GetPosition(),
                                                            true);
        ((b2Body *)theBall->b2ShapePtr)->SetActive(true);
    }

}

-(void)UpdateBallPosition:(float)xCoordinate andY:(float)yCoordinate {
    // Get the PhysicsObject corresponding to the ball
    struct PhysicsObject *theBall = [self GetObject:"Ball"];
    
    if (theBall && theBall->b2ShapePtr) {
        // Update the position of the ball's Box2D body to the specified coordinates
        ((b2Body *)theBall->b2ShapePtr)->SetTransform(b2Vec2(xCoordinate, yCoordinate), 0);
    }
}

// Method to update paddle position based on player input
-(void)UpdatePaddlePosition:(float)xCoordinate {
    // Get the PhysicsObject corresponding to the paddle (assuming there's only one paddle)
    struct PhysicsObject *thePaddle = physicsObjects["Paddle"];
    
    if (thePaddle && thePaddle->b2ShapePtr) {
        // Update the position of the paddle's Box2D body to the specified x-coordinate
        ((b2Body *)thePaddle->b2ShapePtr)->SetTransform(b2Vec2(xCoordinate, ((b2Body *)thePaddle->b2ShapePtr)->GetPosition().y), 0);
    }
}

-(void) AddObject:(char *)name newObject:(struct PhysicsObject *)newObj
{
    
    // Set up the body definition and create the body from it
    // Box2D Bodies Documentation: https://box2d.org/documentation/md__d_1__git_hub_box2d_docs_dynamics.html
    b2BodyDef bodyDef;
    if (strcmp(name, "Ball") == 0) {
        bodyDef.type = b2_dynamicBody;
    } else {
        bodyDef.type = b2_staticBody;
    }
    b2Body *theObject;
    bodyDef.position.Set(newObj->loc.x, newObj->loc.y);
    theObject = world->CreateBody(&bodyDef);
    if (!theObject) return;
    
    // Setup our physics object and store this object and the shape
    newObj->b2ShapePtr = (void *)theObject;
    newObj->box2DObj = (__bridge void *)self;
    
    // Set the user data to be this object and keep it asleep initially
    theObject->SetUserData(newObj);
    theObject->SetAwake(false);
    
    // Based on the objType passed in, create a box or circle
    b2PolygonShape dynamicBox;
    b2CircleShape circle;
    b2FixtureDef fixtureDef;
    
    switch (newObj->objType) {
            
        case ObjTypeBox:
            dynamicBox.SetAsBox(BRICK_WIDTH/2, BRICK_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 1.0f;
            
            break;
            
        case ObjTypeCircle:
            
            circle.m_radius = BALL_RADIUS;
            fixtureDef.shape = &circle;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 1.0f;
            theObject->SetGravityScale(0.0f);
            
            break;
            
        case ObjTypePaddle:
            dynamicBox.SetAsBox(PADDLE_WIDTH/2, PADDLE_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 0.0f;
            
            break;
            
        case ObjTypeVertWall:
            dynamicBox.SetAsBox(WALL_THICKNESS/2, WALL_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 0.0f;
            
            break;
            
        case ObjTypeHoriWall:
            dynamicBox.SetAsBox(TOP_WALL_WIDTH/2, WALL_THICKNESS/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 0.0f;
            
            break;
            
        default:
            
            break;
            
    }
    
    // Add the new fixture to the Box2D object and add our physics object to our map
    theObject->CreateFixture(&fixtureDef);
    physicsObjects[name] = newObj;
    
}

-(struct PhysicsObject *) GetObject:(const char *)name
{
    return physicsObjects[name];
}

-(void)Reset
{
    
    // Look up the brick, and if it exists, destroy it and delete it
    struct PhysicsObject *theBrick = physicsObjects["Brick"];
    if (theBrick) {
        world->DestroyBody(((b2Body *)theBrick->b2ShapePtr));
        delete theBrick;
        theBrick = nullptr;
        physicsObjects.erase("Brick");
    }
    
    // Create a new brick object
    theBrick = new struct PhysicsObject;
    theBrick->loc.x = BRICK_POS_X;
    theBrick->loc.y = BRICK_POS_Y;
    theBrick->objType = ObjTypeBox;
    char *objName = strdup("Brick");
    [self AddObject:objName newObject:theBrick];
    
    // Look up the ball object and re-initialize the position, etc.
    struct PhysicsObject *theBall = physicsObjects["Ball"];
    theBall->loc.x = BALL_POS_X;
    theBall->loc.y = BALL_POS_Y;
    ((b2Body *)theBall->b2ShapePtr)->SetTransform(b2Vec2(BALL_POS_X, BALL_POS_Y), 0);
    ((b2Body *)theBall->b2ShapePtr)->SetLinearVelocity(b2Vec2(0, 0));
    ((b2Body *)theBall->b2ShapePtr)->SetAngularVelocity(0);
    ((b2Body *)theBall->b2ShapePtr)->SetAwake(false);
    ((b2Body *)theBall->b2ShapePtr)->SetActive(true);
    
    totalElapsedTime = 0;
    ballHitBrick = false;
    ballLaunched = false;
    
}









-(void)HelloWorld
{
    
#ifdef USE_HELLO_WORLD
    
    groundBodyDef = new b2BodyDef;
    groundBodyDef->position.Set(0.0f, -10.0f);
    groundBody = world->CreateBody(groundBodyDef);
    groundBox = new b2PolygonShape;
    groundBox->SetAsBox(50.0f, 10.0f);
    
    groundBody->CreateFixture(groundBox, 0.0f);
    
    // Define the dynamic body. We set its position and call the body factory.
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(0.0f, 4.0f);
    b2Body* body = world->CreateBody(&bodyDef);
    
    // Define another box shape for our dynamic body.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(1.0f, 1.0f);
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    
    // Set the box density to be non-zero, so it will be dynamic.
    fixtureDef.density = 1.0f;
    
    // Override the default friction.
    fixtureDef.friction = 0.3f;
    
    // Add the shape to the body.
    body->CreateFixture(&fixtureDef);
    
    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    float32 timeStep = 1.0f / 60.0f;
    int32 velocityIterations = 6;
    int32 positionIterations = 2;
    
    // This is our little game loop.
    world->SetGravity(b2Vec2(0, -10.0f));
    for (int32 i = 0; i < 60; ++i)
    {
        
        // Instruct the world to perform a single step of simulation.
        // It is generally best to keep the time step and iterations fixed.
        world->Step(timeStep, velocityIterations, positionIterations);
        
        // Now print the position and angle of the body.
        b2Vec2 position = body->GetPosition();
        float32 angle = body->GetAngle();
        
        printf("%4.2f %4.2f %4.2f\n", position.x, position.y, angle);
        
    }
    
#endif
    
}

@end
