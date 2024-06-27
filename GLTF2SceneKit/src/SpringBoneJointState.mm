#import "SpringBoneJointState.h"
#import "SceneKitUtil.h"

@implementation SpringBoneSetting

- (instancetype)initWithHitRadius:(CGFloat)hitRadius
                        stiffness:(CGFloat)stiffness
                     gravityPower:(CGFloat)gravityPower
                       gravityDir:(SCNVector3)gravityDir
                        dragForce:(CGFloat)dragForce {
  self = [super init];
  if (self) {
    _hitRadius = hitRadius;
    _stiffness = stiffness;
    _gravityPower = gravityPower;
    _gravityDir = gravityDir;
    _dragForce = dragForce;
  }
  return self;
}
@end

@interface SpringBoneJointState ()

@property(nonatomic, nonnull, strong) SCNNode *bone;
@property(nonatomic, nullable, strong) SCNNode *child;
@property(nonatomic, nullable, strong) SCNNode *center;
@property(nonatomic, nonnull, strong) SpringBoneSetting *setting;
@property(nonatomic, nonnull, strong)
    NSArray<NSArray<SCNNode *> *> *colliderGroups;
@property(nonatomic, assign) SCNMatrix4 initialLocalMatrix;
@property(nonatomic, assign) SCNQuaternion initialLocalRotation;
@property(nonatomic, assign) SCNVector3 initialLocalChildPosition;
@property(nonatomic, assign) SCNVector3 boneAxisInBone;
@property(nonatomic, assign) SCNVector3 prevTailInCenter;
@property(nonatomic, assign) SCNVector3 currentTailInCenter;

@end

@implementation SpringBoneJointState

- (instancetype)initWithBone:(SCNNode *)bone
                       child:(nullable SCNNode *)child
                      center:(nullable SCNNode *)center
                     setting:(SpringBoneSetting *)setting
              colliderGroups:(NSArray<NSArray<SCNNode *> *> *)colliderGroups {
  self = [super init];
  if (self) {
    _bone = bone;
    _child = child;
    _center = center;
    _setting = setting;
    _colliderGroups = colliderGroups;
    _initialLocalMatrix = bone.transform;
    _initialLocalRotation = bone.orientation;
    if (child) {
      _initialLocalChildPosition = child.position;
    } else {
      _initialLocalChildPosition =
          SCNVector3Scale(SCNVector3Normalize(bone.position), 0.07);
    }
    _boneAxisInBone = SCNVector3Normalize(_initialLocalChildPosition);

    SCNMatrix4 boneToCenterMatrix =
        SCNMatrix4Mult(bone.worldTransform, [self getWorldToCenterMatrix]);
    _currentTailInCenter =
        SCNVector3Apply(_initialLocalChildPosition, boneToCenterMatrix);

    _prevTailInCenter = _currentTailInCenter;
  }
  return self;
}

- (SCNMatrix4)getCenterToWorldMatrix {
  if (self.center) {
    return self.center.worldTransform;
  } else {
    return SCNMatrix4Identity;
  }
}

- (SCNMatrix4)getWorldToCenterMatrix {
  if (self.center) {
    return SCNMatrix4Invert(self.center.worldTransform);
  } else {
    return SCNMatrix4Identity;
  }
}

- (SCNMatrix4)getParentToWorldMatrix {
  if (self.bone.parentNode) {
    return self.bone.parentNode.worldTransform;
  } else {
    return SCNMatrix4Identity;
  }
}

- (SCNVector3)getChildPositionInWorld {
  if (self.child) {
    return self.child.worldPosition;
  } else {
    return SCNVector3Apply(self.initialLocalChildPosition,
                           self.bone.worldTransform);
  }
}

- (CGFloat)getBoneLength {
  return SCNVector3LengthBetween(self.bone.worldPosition,
                                 [self getChildPositionInWorld]);
}

- (void)update:(NSTimeInterval)deltaTime {
  if (deltaTime <= 0)
    return;

  CGFloat boneLength = [self getBoneLength];

  // Get bone position in center space
  SCNVector3 bonePositionInWorld = self.bone.worldPosition;
  SCNMatrix4 worldToCenterMatrix = [self getWorldToCenterMatrix];
  SCNVector3 bonePositionInCenter =
      SCNVector3Apply(bonePositionInWorld, worldToCenterMatrix);

  // Get bone axis in center space
  SCNMatrix4 parentToWorldMatrix = [self getParentToWorldMatrix];
  SCNMatrix4 parentToCenterMatrix =
      SCNMatrix4Mult(parentToWorldMatrix, worldToCenterMatrix);
  SCNVector3 boneAxisInCenter =
      SCNVector3Axis(bonePositionInCenter,
                     SCNVector3Apply(SCNVector3Apply(self.boneAxisInBone,
                                                     self.initialLocalMatrix),
                                     parentToCenterMatrix));

  SCNQuaternion worldToCenterQuat =
      SCNQuaternionFromRotationMatrix(worldToCenterMatrix);

  // gravity in center space
  SCNVector3 gravityDirInCenter = SCNVector3Normalize(
      SCNVector3Apply(self.setting.gravityDir, worldToCenterQuat));

  SCNMatrix4 centerToWorld = [self getCenterToWorldMatrix];

  // inertia
  SCNVector3 inertia = SCNVector3Scale(
      SCNVector3Sub(self.currentTailInCenter, self.prevTailInCenter),
      1.0 - self.setting.dragForce);

  // stiffness
  SCNVector3 stiffness =
      SCNVector3Scale(boneAxisInCenter, self.setting.stiffness * deltaTime);

  // gravity
  SCNVector3 gravity = SCNVector3Scale(gravityDirInCenter,
                                       self.setting.gravityPower * deltaTime);

  // nextTail = currentTail + inertia + stiffness + gravity (in center space)
  SCNVector3 nextTailInCenter =
      SCNVector3Add(self.currentTailInCenter,
                    SCNVector3Add(SCNVector3Add(inertia, stiffness), gravity));
  // nextTail in world space
  SCNVector3 nextTailInWorld = SCNVector3Apply(nextTailInCenter, centerToWorld);

  nextTailInWorld =
      SCNVector3Add(SCNVector3Scale(SCNVector3Normalize(SCNVector3Sub(
                                        nextTailInWorld, bonePositionInWorld)),
                                    boneLength),
                    bonePositionInWorld);
  nextTailInCenter = SCNVector3Apply(nextTailInWorld, worldToCenterMatrix);

  // TODO: collision

  self.prevTailInCenter = self.currentTailInCenter;
  self.currentTailInCenter = nextTailInCenter;

  SCNMatrix4 worldToBoneMatrix = SCNMatrix4Invert(
      SCNMatrix4Mult(self.initialLocalMatrix, parentToWorldMatrix));
  SCNVector3 nextBoneAxisInBone =
      SCNVector3Normalize(SCNVector3Apply(nextTailInWorld, worldToBoneMatrix));
  SCNQuaternion applyRotation =
      SCNQuaternionFromUnitVectors(self.boneAxisInBone, nextBoneAxisInBone);
  self.bone.orientation =
      SCNQuaternionMul(self.initialLocalRotation, applyRotation);
}

@end
