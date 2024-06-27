#import "GLTFJson.h"
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpringBoneJointState : NSObject

@property(nonatomic, nonnull, strong) SCNNode *bone;
@property(nonatomic, nullable, strong) SCNNode *child;
@property(nonatomic, nullable, strong) SCNNode *center;
@property(nonatomic, nonnull, strong) VRMSpringBoneJoint *joint;
@property(nonatomic, assign) SCNMatrix4 initialLocalMatrix;
@property(nonatomic, assign) SCNQuaternion initialLocalRotation;
@property(nonatomic, assign) SCNVector3 initialLocalChildPosition;
@property(nonatomic, assign) SCNVector3 boneAxisInBone;
@property(nonatomic, assign) SCNVector3 prevTailInCenter;
@property(nonatomic, assign) SCNVector3 currentTailInCenter;

- (instancetype)initWithBone:(SCNNode *)bone
                       child:(nullable SCNNode *)child
                      center:(nullable SCNNode *)center
                       joint:(VRMSpringBoneJoint *)joint;

- (void)update:(NSTimeInterval)deltaTime;

@end

NS_ASSUME_NONNULL_END
