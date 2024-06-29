#import "GLTFJson.h"
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpringBoneSetting : NSObject

@property(nonatomic, assign) CGFloat hitRadius;
@property(nonatomic, assign) CGFloat stiffness;
@property(nonatomic, assign) CGFloat gravityPower;
@property(nonatomic, assign) SCNVector3 gravityDir;
@property(nonatomic, assign) CGFloat dragForce;

- (instancetype)initWithHitRadius:(CGFloat)hitRadius
                        stiffness:(CGFloat)stiffness
                     gravityPower:(CGFloat)gravityPower
                       gravityDir:(SCNVector3)gravityDir
                        dragForce:(CGFloat)dragForce;

@end

@interface SpringBoneColliderShape : NSObject

@property(nonatomic, strong, nonnull) SCNNode *node;
@property(nonatomic, assign) SCNVector3 offset;
@property(nonatomic, assign) CGFloat radius;

- (instancetype)initWithNode:(SCNNode *)node
                      offset:(SCNVector3)offset
                      radius:(CGFloat)radius;

- (void)calculateCollisionWithObjectPosition:(SCNVector3)objectPosition
                                objectRadius:(CGFloat)objectRadius
                                   direction:(SCNVector3 *)direction
                                    distance:(CGFloat *)distance;

@end

@interface SpringBoneColliderShapeCapsule : SpringBoneColliderShape

@property(nonatomic, assign) SCNVector3 tail;

- (instancetype)initWithNode:(SCNNode *)node
                      offset:(SCNVector3)offset
                      radius:(CGFloat)radius
                        tail:(SCNVector3)tail;

@end

@interface SpringBoneColliderShapeSphere : SpringBoneColliderShape

@end

@interface SpringBoneJointState : NSObject

- (instancetype)initWithBone:(SCNNode *)bone
                       child:(nullable SCNNode *)child
                      center:(nullable SCNNode *)center
                     setting:(SpringBoneSetting *)setting
              colliderGroups:(NSArray<NSArray<SpringBoneColliderShape *> *> *)
                                 colliderGroups;

- (void)update:(NSTimeInterval)deltaTime;

@end

NS_ASSUME_NONNULL_END
