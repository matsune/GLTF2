#import "VRMSCNAsset.h"

@interface SpringBoneJointState : NSObject

@property(nonatomic, nonnull, strong) SCNNode *node;
@property(nonatomic, assign) SCNVector3 prevTail;
@property(nonatomic, assign) SCNVector3 currentTail;
@property(nonatomic, assign) SCNVector3 boneAxis;
@property(nonatomic, assign) CGFloat boneLength;
@property(nonatomic, assign) SCNMatrix4 initialLocalMatrix;
@property(nonatomic, assign) SCNQuaternion quaternion;

@property(nonatomic, assign) float stiffness;
@property(nonatomic, assign) float gravityPower;
@property(nonatomic, assign) SCNVector3 gravityDir;
@property(nonatomic, assign) float dragForce;
@property(nonatomic, assign) float hitRadius;

@end

@implementation SpringBoneJointState

@end

static SCNVector3 crossProduct(SCNVector3 v1, SCNVector3 v2) {
  return SCNVector3Make(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z,
                        v1.x * v2.y - v1.y * v2.x);
}

static float angleBetweenVectors(SCNVector3 v1, SCNVector3 v2) {
  float dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
  float magnitudeV1 = sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
  float magnitudeV2 = sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z);
  return acos(dot / (magnitudeV1 * magnitudeV2));
}

static SCNMatrix4 SCNMatrix4RotationFromQuaternion(const SCNQuaternion &q) {
  CGFloat w = q.w;
  CGFloat x = q.x;
  CGFloat y = q.y;
  CGFloat z = q.z;

  CGFloat angle = 2 * acos(w);
  CGFloat sinHalfAngle = sqrt(1 - w * w);

  CGFloat ux, uy, uz;
  if (sinHalfAngle < 0.0001) {
    ux = 1;
    uy = 0;
    uz = 0;
  } else {
    ux = x / sinHalfAngle;
    uy = y / sinHalfAngle;
    uz = z / sinHalfAngle;
  }
  return SCNMatrix4MakeRotation(angle, ux, uy, uz);
}

static SCNMatrix4 LookAtMatrix(SCNNode *headBone,
                               SCNVector3 offsetFromHeadBone) {
  SCNVector3 headPosition = headBone.worldPosition;
  SCNQuaternion headRotation = headBone.worldOrientation;

  SCNMatrix4 headPositionMatrix =
      SCNMatrix4MakeTranslation(headPosition.x, headPosition.y, headPosition.z);
  SCNMatrix4 headRotationMatrix =
      SCNMatrix4RotationFromQuaternion(headRotation);
  SCNMatrix4 inverseHeadRotationMatrix = SCNMatrix4Invert(headRotationMatrix);

  SCNMatrix4 offsetFromHeadBoneMatrix = SCNMatrix4MakeTranslation(
      offsetFromHeadBone.x, offsetFromHeadBone.y, offsetFromHeadBone.z);

  SCNMatrix4 headMatrix =
      SCNMatrix4Mult(headPositionMatrix, headRotationMatrix);
  SCNMatrix4 offsetMatrix =
      SCNMatrix4Mult(headMatrix, offsetFromHeadBoneMatrix);
  return SCNMatrix4Mult(offsetMatrix, inverseHeadRotationMatrix);
}

static float roundValue(float value) { return value >= 0.5f ? 1.0f : 0.0; }

@interface VRMSCNAsset ()

@property(nonatomic, assign) SCNMatrix4 lookAtMatrix;
@property(nonatomic, assign) SCNVector3 initialLeftEyeAngles;
@property(nonatomic, assign) SCNVector3 initialRightEyeAngles;

@property(nonatomic, strong) NSArray<SpringBoneJointState *> *jointStates;
@property(nonatomic, assign) NSTimeInterval lastTime;

@end

@implementation VRMSCNAsset

- (instancetype)init {
  self = [super init];
  if (self) {
    _lastTime = 0;
  }
  return self;
}

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error {
  BOOL ok = [super loadFile:path error:error];
  if (!ok)
    return NO;

  if (self.json.springBone) {
    VRMCSpringBone *springBone = self.json.springBone;
    NSMutableArray<SCNNode *> *colliderNodes = [NSMutableArray array];
    if (springBone.colliders) {
      for (VRMCSpringBoneCollider *collider in springBone.colliders) {
        SCNNode *node = self.scnNodes[collider.node];
        SCNNode *colliderNode = [SCNNode node];
        if (collider.shape.sphere) {
          colliderNode.geometry =
              [SCNSphere sphereWithRadius:collider.shape.sphere.radiusValue];
          SCNVector3 offset = collider.shape.sphere.offsetValue;
          colliderNode.position = offset;
        } else if (collider.shape.capsule) {
          SCNVector3 offset = collider.shape.capsule.offsetValue;
          SCNVector3 tail = collider.shape.capsule.tailValue;
          float height =
              sqrt(pow(tail.x - offset.x, 2) + pow(tail.y - offset.y, 2) +
                   pow(tail.z - offset.z, 2));
          colliderNode.geometry = [SCNCapsule
              capsuleWithCapRadius:collider.shape.capsule.radiusValue
                            height:height];

          colliderNode.position = offset;

          SCNVector3 direction = SCNVector3Make(
              tail.x - offset.x, tail.y - offset.y, tail.z - offset.z);
          SCNVector3 up = SCNVector3Make(0, 1, 0);
          SCNVector3 cross = crossProduct(up, direction);
          SCNVector3 axis = crossProduct(up, direction);
          float angle = angleBetweenVectors(up, direction);
          colliderNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle);
        }
        colliderNode.geometry.firstMaterial.transparency = 0.0;
        colliderNode.physicsBody = [SCNPhysicsBody
            bodyWithType:SCNPhysicsBodyTypeKinematic
                   shape:[SCNPhysicsShape shapeWithNode:colliderNode
                                                options:nil]];
        [node addChildNode:colliderNode];

        [colliderNodes addObject:colliderNode];
      }
    }

    NSMutableArray<NSArray<SCNNode *> *> *colliderGroups =
        [NSMutableArray array];
    if (springBone.colliderGroups) {
      for (VRMCSpringBoneColliderGroup *colliderGroup in springBone
               .colliderGroups) {
        NSMutableArray<SCNNode *> *groupColliders = [NSMutableArray array];
        for (NSNumber *colliderIndex in colliderGroup.colliders) {
          SCNNode *colliderNode = colliderNodes[colliderIndex.unsignedIntValue];
          [groupColliders addObject:colliderNode];
        }
        [colliderGroups addObject:[groupColliders copy]];
      }
    }

    if (springBone.springs) {
      NSMutableArray<SpringBoneJointState *> *jointStates =
          [NSMutableArray array];
      for (VRMCSpringBoneSpring *spring in springBone.springs) {
        for (int i = 0; i < spring.joints.count - 1; i++) {
          NSUInteger headIndex = spring.joints[i].node;
          NSUInteger tailIndex = spring.joints[i + 1].node;
          SCNNode *head = self.scnNodes[headIndex];
          SCNNode *tail = self.scnNodes[tailIndex];
          assert(head == tail.parentNode);

          SpringBoneJointState *state = [[SpringBoneJointState alloc] init];
          state.node = tail;
          state.prevTail = tail.worldPosition;
          state.currentTail = tail.worldPosition;
          state.boneAxis = SCNVector3Make(tail.position.x - head.position.x,
                                          tail.position.y - head.position.y,
                                          tail.position.z - head.position.z);
          state.boneLength = sqrtf(state.boneAxis.x * state.boneAxis.x +
                                   state.boneAxis.y * state.boneAxis.y +
                                   state.boneAxis.z * state.boneAxis.z);
          state.initialLocalMatrix = head.transform;
          state.quaternion = head.orientation;

          state.stiffness = spring.joints[i].stiffnessValue;
          state.gravityPower = spring.joints[i].gravityPowerValue;
          state.gravityDir = spring.joints[i].gravityDirValue;
          state.dragForce = spring.joints[i].dragForceValue;
          state.hitRadius = spring.joints[i].hitRadiusValue;

          [jointStates addObject:state];
        }
      }
      self.jointStates = [jointStates copy];
    }
  }

  if (self.json.vrm0 && self.json.vrm0.secondaryAnimation &&
      self.json.vrm0.secondaryAnimation.colliderGroups) {
    for (VRMSecondaryAnimationColliderGroup *colliderGroup in self.json.vrm0
             .secondaryAnimation.colliderGroups) {
      if (colliderGroup.node && colliderGroup.colliders) {
        SCNNode *node = self.scnNodes[colliderGroup.node.unsignedIntValue];
        for (VRMSecondaryAnimationCollider *collider in colliderGroup
                 .colliders) {
          SCNNode *colliderNode = [SCNNode node];
          colliderNode.geometry =
              [SCNSphere sphereWithRadius:collider.radiusValue];
          SCNVector3 offset = collider.offsetValue;
          colliderNode.position = offset;
          colliderNode.geometry.firstMaterial.transparency = 0.0;
          colliderNode.physicsBody = [SCNPhysicsBody
              bodyWithType:SCNPhysicsBodyTypeKinematic
                     shape:[SCNPhysicsShape shapeWithNode:colliderNode
                                                  options:nil]];
          [node addChildNode:colliderNode];
        }
      }
    }
  }

  if (self.isLookAtTypeBone) {
    // Bone
    _lookAtMatrix = LookAtMatrix(self.vrmHeadBone, self.offsetFromHeadBone);
    _initialLeftEyeAngles = self.leftEyeBone.eulerAngles;
    _initialRightEyeAngles = self.rightEyeBone.eulerAngles;
  }

  if (self.json.vrm0) {
    self.vrmRootNode.rotation = SCNVector4Make(0, 1, 0, M_PI);
  }

  return YES;
}

- (BOOL)isLookAtTypeBone {
  if (self.json.vrm0 && self.json.vrm0.firstPerson) {
    return self.json.vrm0.firstPerson.isLookAtTypeBone;
  } else if (self.json.vrm1 && self.json.vrm1.lookAt) {
    return self.json.vrm1.lookAt.isTypeBone;
  }
  return NO;
}

- (nullable SCNNode *)vrmHeadBone {
  if (self.json.vrm0) {
    if (self.json.vrm0.firstPerson &&
        self.json.vrm0.firstPerson.firstPersonBone) {
      return self.scnNodes[self.json.vrm0.firstPerson.firstPersonBone
                               .unsignedIntValue];
    } else if (self.json.vrm0.humanoid) {
      return self.scnNodes[
          [self.json.vrm0.humanoid humanBoneByName:VRMHumanoidBoneTypeHead]
              .node.unsignedIntValue];
    }
  } else if (self.json.vrm1 && self.json.vrm1.humanoid &&
             self.json.vrm1.humanoid.humanBones &&
             self.json.vrm1.humanoid.humanBones.head) {
    return self.scnNodes[self.json.vrm1.humanoid.humanBones.head.node
                             .unsignedIntValue];
  }
  return nil;
}

- (nullable SCNNode *)vrmRootNode {
  if (self.json.vrm0) {
    VRMHumanoidBone *bone =
        [self.json.vrm0.humanoid humanBoneByName:VRMHumanoidBoneTypeHips];
    return self.scnNodes[bone.node.unsignedIntValue];
  } else if (self.json.vrm1) {
    return self.scnNodes[self.json.vrm1.humanoid.humanBones.hips.node
                             .unsignedIntValue];
  }
  return nil;
}

- (NSArray<NSString *> *)blendShapeKeys {
  if (self.json.vrm0) {
    if (self.json.vrm0.blendShapeMaster &&
        self.json.vrm0.blendShapeMaster.blendShapeGroups) {
      return self.json.vrm0.blendShapeMaster.groupNames;
    }
  } else if (self.json.vrm1) {
    if (self.json.vrm1.expressions) {
      return self.json.vrm1.expressions.expressionNames;
    }
  }
  return @[];
}

- (CGFloat)weightForBlendShapeKey:(NSString *)key {
  if (self.json.vrm0) {
    VRMBlendShapeGroup *group = [self.json.vrm0 blendShapeGroupByPreset:key];
    if (group && group.binds) {
      for (VRMBlendShapeBind *bind in group.binds) {
        NSInteger meshIndex = 0;
        if (bind.mesh)
          meshIndex = bind.mesh.integerValue;
        NSInteger bindIndex = 0;
        if (bind.index)
          bindIndex = bind.index.integerValue;

        SCNNode *meshNode = self.meshNodes[meshIndex];
        for (SCNNode *childNode in meshNode.childNodes) {
          if (childNode.morpher) {
            return [childNode.morpher weightForTargetAtIndex:bindIndex];
          }
        }
      }
    }
  } else if (self.json.vrm1) {
    VRMCExpression *expression = [self.json.vrm1 expressionByName:key];
    if (expression && expression.morphTargetBinds) {
      for (VRMCExpressionMorphTargetBind *bind in expression.morphTargetBinds) {
        SCNNode *meshNode = self.meshNodes[bind.node];
        for (SCNNode *childNode in meshNode.childNodes) {
          if (childNode.morpher) {
            return [childNode.morpher weightForTargetAtIndex:bind.index];
          }
        }
      }
    }
  }
  return 0.0f;
}

- (void)setBlendShapeWeight:(CGFloat)weight
                   meshNode:(SCNNode *)meshNode
                  bindIndex:(NSInteger)bindIndex {
  for (SCNNode *childNode in meshNode.childNodes) {
    if (childNode.morpher) {
      [childNode.morpher setWeight:weight forTargetAtIndex:bindIndex];
    }
  }
}

- (void)setBlendShapeWeight:(CGFloat)weight forKey:(NSString *)key {
  if (self.json.vrm0) {
    const auto group = [self.json.vrm0 blendShapeGroupByPreset:key];
    if (group && group.binds) {
      float value = group.isBinary ? roundValue(weight) : weight;
      for (VRMBlendShapeBind *bind in group.binds) {
        float bindWeight = weight;
        if (bind.weight) {
          bindWeight = (bind.weight.floatValue / 100.0f) * weight;
        }
        NSInteger meshIndex = 0;
        if (bind.mesh)
          meshIndex = bind.mesh.integerValue;
        NSInteger bindIndex = 0;
        if (bind.index)
          bindIndex = bind.index.integerValue;
        SCNNode *meshNode = self.meshNodes[meshIndex];
        [self setBlendShapeWeight:bindWeight
                         meshNode:meshNode
                        bindIndex:bindIndex];
      }
    }
  } else if (self.json.vrm1) {
    VRMCExpression *expression = [self.json.vrm1 expressionByName:key];
    if (expression && expression.morphTargetBinds) {
      float value = expression.isBinary ? roundValue(weight) : weight;
      for (VRMCExpressionMorphTargetBind *bind in expression.morphTargetBinds) {
        SCNNode *node = self.meshNodes[bind.node];
        [self setBlendShapeWeight:value meshNode:node bindIndex:bind.index];
      }
      // TODO: materialColorBinds, textureTransform, overrides
    }
  }
}

- (SCNVector3)offsetFromHeadBone {
  if (self.json.vrm0 && self.json.vrm0.firstPerson &&
      self.json.vrm0.firstPerson.firstPersonBoneOffset) {
    return self.json.vrm0.firstPerson.firstPersonBoneOffset.scnVector3;
  }
  if (self.json.vrm1 && self.json.vrm1.lookAt &&
      self.json.vrm1.lookAt.offsetFromHeadBone) {
    return self.json.vrm1.lookAt.offsetFromHeadBone.scnVector3;
  }
  return SCNVector3Make(0, 0, 0);
}

- (nullable SCNNode *)leftEyeBone {
  if (self.json.vrm0 && self.json.vrm0.humanoid && self.json.vrm0.humanoid) {
    return self.scnNodes[
        [self.json.vrm0.humanoid humanBoneByName:VRMHumanoidBoneTypeLeftEye]
            .node.unsignedIntValue];
  } else if (self.json.vrm1 && self.json.vrm1.humanoid &&
             self.json.vrm1.humanoid.humanBones &&
             self.json.vrm1.humanoid.humanBones.leftEye) {
    return self.scnNodes[self.json.vrm1.humanoid.humanBones.leftEye.node
                             .unsignedIntValue];
  }
  return nil;
}

- (nullable SCNNode *)rightEyeBone {
  if (self.json.vrm0 && self.json.vrm0.humanoid && self.json.vrm0.humanoid) {
    return self.scnNodes[
        [self.json.vrm0.humanoid humanBoneByName:VRMHumanoidBoneTypeRightEye]
            .node.unsignedIntValue];
  } else if (self.json.vrm1 && self.json.vrm1.humanoid &&
             self.json.vrm1.humanoid.humanBones &&
             self.json.vrm1.humanoid.humanBones.rightEye) {
    return self.scnNodes[self.json.vrm1.humanoid.humanBones.rightEye.node
                             .unsignedIntValue];
  }
  return nil;
}

- (void)calcYawPitchDegreesForTarget:(SCNVector3)target
                                 yaw:(CGFloat *)yaw
                               pitch:(CGFloat *)pitch {
  SCNMatrix4 lookAtSpace = self.lookAtMatrix;
  SCNMatrix4 inverseLookAtSpace = SCNMatrix4Invert(lookAtSpace);

  SCNVector3 localTarget = SCNVector3Make(
      inverseLookAtSpace.m11 * target.x + inverseLookAtSpace.m21 * target.y +
          inverseLookAtSpace.m31 * target.z + inverseLookAtSpace.m41,
      inverseLookAtSpace.m12 * target.x + inverseLookAtSpace.m22 * target.y +
          inverseLookAtSpace.m32 * target.z + inverseLookAtSpace.m42,
      inverseLookAtSpace.m13 * target.x + inverseLookAtSpace.m23 * target.y +
          inverseLookAtSpace.m33 * target.z + inverseLookAtSpace.m43);

  CGFloat z = localTarget.z;
  CGFloat x = localTarget.x;
  *yaw = atan2(x, z) * (180.0 / M_PI);

  CGFloat xz = sqrt(x * x + z * z);
  CGFloat y = localTarget.y;
  *pitch = atan2(-y, xz) * (180.0 / M_PI);
}

- (void)lookAtTarget:(SCNVector3)target {
  CGFloat yaw, pitch;
  [self calcYawPitchDegreesForTarget:target yaw:&yaw pitch:&pitch];
  [self applyLeftEyeBoneWithYaw:yaw pitch:pitch];
  [self applyRightEyeBoneWithYaw:yaw pitch:pitch];
}

- (CGFloat)clampHorizontalInner:(CGFloat)degree {
  if (self.json.vrm0 && self.json.vrm0.firstPerson) {
    VRMDegreeMap *horizontalInner =
        self.json.vrm0.firstPerson.lookAtHorizontalInner;
    if (horizontalInner && horizontalInner.xRange) {
      CGFloat inputMaxValue = horizontalInner.xRange.floatValue;
      return fmin(fabs(degree), inputMaxValue);
    }
  } else if (self.json.vrm1 && self.json.vrm1.lookAt &&
             self.json.vrm1.lookAt.rangeMapHorizontalInner) {
    CGFloat inputMaxValue = 90.0;
    if (self.json.vrm1.lookAt.rangeMapHorizontalInner.inputMaxValue) {
      inputMaxValue = self.json.vrm1.lookAt.rangeMapHorizontalInner
                          .inputMaxValue.floatValue;
    }
    CGFloat outputScale = 1.0;
    if (self.json.vrm1.lookAt.rangeMapHorizontalInner.outputScale) {
      outputScale =
          self.json.vrm1.lookAt.rangeMapHorizontalInner.outputScale.floatValue;
    }
    return fmin(fabs(degree), inputMaxValue) / inputMaxValue * outputScale;
  }
  return degree;
}

- (CGFloat)clampHorizontalOuter:(CGFloat)degree {
  if (self.json.vrm0 && self.json.vrm0.firstPerson) {
    VRMDegreeMap *horizontalOuter =
        self.json.vrm0.firstPerson.lookAtHorizontalOuter;
    if (horizontalOuter && horizontalOuter.xRange) {
      CGFloat inputMaxValue = horizontalOuter.xRange.floatValue;
      return fmin(fabs(degree), inputMaxValue);
    }
  } else if (self.json.vrm1 && self.json.vrm1.lookAt &&
             self.json.vrm1.lookAt.rangeMapHorizontalOuter) {
    CGFloat inputMaxValue = 90.0;
    if (self.json.vrm1.lookAt.rangeMapHorizontalOuter.inputMaxValue) {
      inputMaxValue = self.json.vrm1.lookAt.rangeMapHorizontalOuter
                          .inputMaxValue.floatValue;
    }
    CGFloat outputScale = 1.0;
    if (self.json.vrm1.lookAt.rangeMapHorizontalOuter.outputScale) {
      outputScale =
          self.json.vrm1.lookAt.rangeMapHorizontalOuter.outputScale.floatValue;
    }
    return fmin(fabs(degree), inputMaxValue) / inputMaxValue * outputScale;
  }
  return degree;
}

- (CGFloat)clampVerticalUp:(CGFloat)degree {
  if (self.json.vrm0 && self.json.vrm0.firstPerson) {
    VRMDegreeMap *verticalUp = self.json.vrm0.firstPerson.lookAtVerticalUp;
    if (verticalUp && verticalUp.yRange) {
      CGFloat inputMaxValue = verticalUp.yRange.floatValue;
      return fmin(fabs(degree), inputMaxValue);
    }
  } else if (self.json.vrm1 && self.json.vrm1.lookAt &&
             self.json.vrm1.lookAt.rangeMapVerticalUp) {
    CGFloat inputMaxValue = 90.0;
    if (self.json.vrm1.lookAt.rangeMapVerticalUp.inputMaxValue) {
      inputMaxValue =
          self.json.vrm1.lookAt.rangeMapVerticalUp.inputMaxValue.floatValue;
    }
    CGFloat outputScale = 1.0;
    if (self.json.vrm1.lookAt.rangeMapVerticalUp.outputScale) {
      outputScale =
          self.json.vrm1.lookAt.rangeMapVerticalUp.outputScale.floatValue;
    }
    return fmin(fabs(degree), inputMaxValue) / inputMaxValue * outputScale;
  }
  return degree;
}

- (CGFloat)clampVerticalDown:(CGFloat)degree {
  if (self.json.vrm0 && self.json.vrm0.firstPerson) {
    VRMDegreeMap *verticalDown = self.json.vrm0.firstPerson.lookAtVerticalDown;
    if (verticalDown && verticalDown.yRange) {
      CGFloat inputMaxValue = verticalDown.yRange.floatValue;
      return fmin(fabs(degree), inputMaxValue);
    }
  } else if (self.json.vrm1 && self.json.vrm1.lookAt &&
             self.json.vrm1.lookAt.rangeMapVerticalDown) {
    CGFloat inputMaxValue = 90.0;
    if (self.json.vrm1.lookAt.rangeMapVerticalDown.inputMaxValue) {
      inputMaxValue =
          self.json.vrm1.lookAt.rangeMapVerticalDown.inputMaxValue.floatValue;
    }
    CGFloat outputScale = 1.0;
    if (self.json.vrm1.lookAt.rangeMapVerticalDown.outputScale) {
      outputScale =
          self.json.vrm1.lookAt.rangeMapVerticalDown.outputScale.floatValue;
    }
    return fmin(fabs(degree), inputMaxValue) / inputMaxValue * outputScale;
  }
  return degree;
}

- (void)applyLeftEyeBoneWithYaw:(CGFloat)yawDegrees
                          pitch:(CGFloat)pitchDegrees {
  CGFloat yaw = 0;
  if (yawDegrees > 0) {
    yaw = [self clampHorizontalOuter:yawDegrees];
  } else {
    yaw = -[self clampHorizontalInner:yawDegrees];
  }

  CGFloat pitch = 0;
  if (pitchDegrees > 0) {
    pitch = [self clampVerticalDown:pitchDegrees];
  } else {
    pitch = -[self clampVerticalUp:pitchDegrees];
  }
  if (self.json.vrm0) {
    pitch *= -1;
  }

  SCNVector3 angles = self.initialLeftEyeAngles;
  angles.x += pitch * M_PI / 180.0f;
  angles.y += yaw * M_PI / 180.0f;
  self.leftEyeBone.eulerAngles = angles;
}

- (void)applyRightEyeBoneWithYaw:(CGFloat)yawDegrees
                           pitch:(CGFloat)pitchDegrees {
  CGFloat yaw = 0;
  if (yawDegrees > 0) {
    yaw = [self clampHorizontalInner:yawDegrees];
  } else {
    yaw = -[self clampHorizontalOuter:yawDegrees];
  }

  CGFloat pitch = 0;
  if (pitchDegrees > 0) {
    pitch = [self clampVerticalDown:pitchDegrees];
  } else {
    pitch = -[self clampVerticalUp:pitchDegrees];
  }
  if (self.json.vrm0) {
    pitch *= -1;
  }

  SCNVector3 angles = self.initialRightEyeAngles;
  angles.x += pitch * M_PI / 180.0f;
  angles.y += yaw * M_PI / 180.0f;
  self.rightEyeBone.eulerAngles = angles;
}

- (void)updateAtTime:(NSTimeInterval)time {
  if (self.lastTime == 0) {
    self.lastTime = time;
    return;
  }

  float deltaTime = time - self.lastTime;
  self.lastTime = time;

  for (SpringBoneJointState *state in self.jointStates) {
    SCNNode *tail = state.node;
    SCNNode *head = tail.parentNode;
    if (!head)
      continue;

    SCNVector3 currentTail = state.currentTail;
    SCNVector3 prevTail = state.prevTail;
    SCNQuaternion initialLocalRotation = state.quaternion;
    SCNVector3 boneAxis = state.boneAxis;
    CGFloat boneLength = state.boneLength;

    CGFloat dragForce = state.dragForce;
    CGFloat stiffnessForce = state.stiffness;
    SCNVector3 gravityDir = state.gravityDir;
    CGFloat gravityPower = state.gravityPower;

    SCNVector3 worldPosition = head.worldPosition;
    SCNQuaternion parentWorldRotation = head.orientation;

    // 慣性の計算
    SCNVector3 inertia =
        SCNVector3Make((currentTail.x - prevTail.x) * (1.0 - dragForce),
                       (currentTail.y - prevTail.y) * (1.0 - dragForce),
                       (currentTail.z - prevTail.z) * (1.0 - dragForce));

    // 剛性の計算
    SCNVector3 stiffness = SCNVector3Make(
        deltaTime * stiffnessForce *
            (parentWorldRotation.x * initialLocalRotation.x) * boneAxis.x,
        deltaTime * stiffnessForce *
            (parentWorldRotation.y * initialLocalRotation.y) * boneAxis.y,
        deltaTime * stiffnessForce *
            (parentWorldRotation.z * initialLocalRotation.z) * boneAxis.z);

    // 重力の計算
    SCNVector3 external =
        SCNVector3Make(deltaTime * gravityDir.x * gravityPower,
                       deltaTime * gravityDir.y * gravityPower,
                       deltaTime * gravityDir.z * gravityPower);

    // 次のテール位置の計算
    SCNVector3 nextTail =
        SCNVector3Make(currentTail.x + inertia.x + stiffness.x + external.x,
                       currentTail.y + inertia.y + stiffness.y + external.y,
                       currentTail.z + inertia.z + stiffness.z + external.z);

    // 長さの制約を適用
    SCNVector3 direction = SCNVector3Make(nextTail.x - worldPosition.x,
                                          nextTail.y - worldPosition.y,
                                          nextTail.z - worldPosition.z);

    float length = sqrtf(direction.x * direction.x + direction.y * direction.y +
                         direction.z * direction.z);
    if (length > boneLength) {
      direction.x = (direction.x / length) * boneLength;
      direction.y = (direction.y / length) * boneLength;
      direction.z = (direction.z / length) * boneLength;

      nextTail = SCNVector3Make(worldPosition.x + direction.x,
                                worldPosition.y + direction.y,
                                worldPosition.z + direction.z);
    }

    tail.worldPosition = nextTail;

    state.prevTail = currentTail;
    state.currentTail = nextTail;
  }
}

@end
