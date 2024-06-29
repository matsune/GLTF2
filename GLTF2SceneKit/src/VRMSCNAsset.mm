#import "VRMSCNAsset.h"
#import "SceneKitUtil.h"
#import "SpringBoneJointState.h"

static SCNMatrix4 LookAtMatrix(SCNNode *headBone,
                               SCNVector3 offsetFromHeadBone) {
  SCNVector3 headPosition = headBone.worldPosition;
  SCNQuaternion headRotation = headBone.worldOrientation;

  SCNMatrix4 headPositionMatrix =
      SCNMatrix4MakeTranslation(headPosition.x, headPosition.y, headPosition.z);
  SCNMatrix4 headRotationMatrix = SCNMatrix4MakeRotation(headRotation);
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

#pragma mark - VRMSCNAsset

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

- (NSArray<NSArray<SpringBoneColliderShape *> *> *)
    colliderGroupsFromVRMSpringBone:(VRMSpringBone *)springBone {
  NSMutableArray<NSArray<SpringBoneColliderShape *> *> *colliderGroups =
      [NSMutableArray array];

  NSMutableArray<SpringBoneColliderShape *> *colliders = [NSMutableArray array];
  if (springBone.colliders) {
    for (VRMSpringBoneCollider *collider in springBone.colliders) {
      SCNNode *node = self.scnNodes[collider.node];
      SCNNode *colliderNode = [collider toSCNNode];
      [node addChildNode:colliderNode];

      if (collider.shape) {
        if (collider.shape.sphere) {
          [colliders
              addObject:[[SpringBoneColliderShapeSphere alloc]
                            initWithNode:colliderNode
                                  offset:collider.shape.sphere.offsetValue
                                  radius:collider.shape.sphere.radiusValue]];
        } else if (collider.shape.capsule) {
          [colliders
              addObject:[[SpringBoneColliderShapeCapsule alloc]
                            initWithNode:colliderNode
                                  offset:collider.shape.capsule.offsetValue
                                  radius:collider.shape.capsule.radiusValue
                                    tail:collider.shape.capsule.tailValue]];
        }
      }
    }
  }

  for (VRMSpringBoneColliderGroup *colliderGroup in springBone.colliderGroups) {
    NSMutableArray<SpringBoneColliderShape *> *shapeGroup =
        [NSMutableArray array];
    for (NSNumber *colliderIndex in colliderGroup.colliders) {
      SpringBoneColliderShape *collider =
          colliders[colliderIndex.unsignedIntValue];
      [shapeGroup addObject:collider];
    }
    [colliderGroups addObject:[shapeGroup copy]];
  }

  return [colliderGroups copy];
}

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error {
  BOOL ok = [super loadFile:path error:error];
  if (!ok)
    return NO;

  if (self.isLookAtTypeBone) {
    _lookAtMatrix = LookAtMatrix(self.vrmHeadBone, self.offsetFromHeadBone);
    _initialLeftEyeAngles = self.leftEyeBone.eulerAngles;
    _initialRightEyeAngles = self.rightEyeBone.eulerAngles;
  }

  if (self.json.vrm0) {
    // flip face front direction
    self.vrmRootNode.rotation = SCNVector4Make(0, 1, 0, M_PI);
  }

  if (self.json.springBone) {
    VRMSpringBone *springBone = self.json.springBone;

    NSArray<NSArray<SpringBoneColliderShape *> *> *colliderGroups;
    if (springBone.colliderGroups) {
      colliderGroups = [self colliderGroupsFromVRMSpringBone:springBone];
    }

    if (springBone.springs) {
      NSMutableArray<SpringBoneJointState *> *jointStates =
          [NSMutableArray array];
      for (VRMSpringBoneSpring *spring in springBone.springs) {
        SCNNode *center;
        if (spring.center) {
          center = self.scnNodes[spring.center.unsignedIntValue];
        }

        NSMutableArray<NSArray<SpringBoneColliderShape *> *> *colliders =
            [NSMutableArray array];
        if (spring.colliderGroups) {
          for (NSNumber *index in spring.colliderGroups) {
            [colliders addObject:colliderGroups[index.unsignedIntegerValue]];
          }
        }

        for (int i = 1; i < spring.joints.count; i++) {
          NSUInteger boneIndex = spring.joints[i - 1].node;
          NSUInteger childIndex = spring.joints[i].node;
          SCNNode *bone = self.scnNodes[boneIndex];
          SCNNode *child = self.scnNodes[childIndex];
          assert(bone == child.parentNode);
          VRMSpringBoneJoint *joint = spring.joints[i - 1];
          SpringBoneSetting *setting = [[SpringBoneSetting alloc]
              initWithHitRadius:joint.hitRadiusValue
                      stiffness:joint.stiffnessValue
                   gravityPower:joint.gravityPowerValue
                     gravityDir:joint.gravityDirValue
                      dragForce:joint.dragForceValue];
          SpringBoneJointState *state =
              [[SpringBoneJointState alloc] initWithBone:bone
                                                   child:child
                                                  center:center
                                                 setting:setting
                                          colliderGroups:[colliders copy]];
          [jointStates addObject:state];
        }
      }
      self.jointStates = [jointStates copy];
    }
  }

  if (self.json.vrm0 && self.json.vrm0.secondaryAnimation) {
    NSMutableArray<NSArray<SpringBoneColliderShape *> *> *colliderGroups =
        [NSMutableArray array];
    if (self.json.vrm0.secondaryAnimation.colliderGroups) {
      for (VRM0SecondaryAnimationColliderGroup *colliderGroup in self.json.vrm0
               .secondaryAnimation.colliderGroups) {
        if (colliderGroup.node && colliderGroup.colliders) {
          SCNNode *node = self.scnNodes[colliderGroup.node.unsignedIntValue];
          NSMutableArray<SpringBoneColliderShape *> *group =
              [NSMutableArray array];
          for (VRM0SecondaryAnimationCollider *collider in colliderGroup
                   .colliders) {
            SCNNode *colliderNode = [collider toSCNNode];
            [node addChildNode:colliderNode];

            [group addObject:[[SpringBoneColliderShapeSphere alloc]
                                 initWithNode:colliderNode
                                       offset:collider.offsetValue
                                       radius:collider.radiusValue]];
          }
          [colliderGroups addObject:[group copy]];
        }
      }
    }
    if (self.json.vrm0.secondaryAnimation.boneGroups) {
      NSMutableArray<SpringBoneJointState *> *jointStates =
          [NSMutableArray array];
      for (VRM0SecondaryAnimationSpring *spring in self.json.vrm0
               .secondaryAnimation.boneGroups) {
        SpringBoneSetting *setting = [[SpringBoneSetting alloc]
            initWithHitRadius:spring.hitRadiusValue
                    stiffness:spring.stiffinessValue
                 gravityPower:spring.gravityPowerValue
                   gravityDir:spring.gravityDirValue
                    dragForce:spring.dragForceValue];
        for (int i = 0; i < spring.bones.count; i++) {
          SCNNode *bone = self.scnNodes[spring.bones[i].unsignedIntValue];
          SCNNode *child;
          if (i < spring.bones.count - 1) {
            child = self.scnNodes[spring.bones[i + 1].unsignedIntValue];
          }
          SCNNode *center;
          if (spring.center) {
            int index = spring.center.intValue;
            if (index > 0)
              center = self.scnNodes[index];
          }
          NSMutableArray<NSArray<SpringBoneColliderShape *> *> *colliders =
              [NSMutableArray array];
          if (spring.colliderGroups) {
            for (NSNumber *index in spring.colliderGroups) {
              [colliders addObject:colliderGroups[index.unsignedIntValue]];
            }
          }

          SpringBoneJointState *state =
              [[SpringBoneJointState alloc] initWithBone:bone
                                                   child:child
                                                  center:center
                                                 setting:setting
                                          colliderGroups:colliders];
          [jointStates addObject:state];
        }
      }
      self.jointStates = [jointStates copy];
    }
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
          [self.json.vrm0.humanoid humanBoneByName:VRM0HumanoidBoneNameHead]
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
    VRM0HumanoidBone *bone =
        [self.json.vrm0.humanoid humanBoneByName:VRM0HumanoidBoneNameHips];
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
    VRM0BlendShapeGroup *group = [self.json.vrm0 blendShapeGroupByPreset:key];
    if (group && group.binds) {
      for (VRM0BlendShapeBind *bind in group.binds) {
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
    VRM1Expression *expression = [self.json.vrm1 expressionByName:key];
    if (expression && expression.morphTargetBinds) {
      for (VRM1ExpressionMorphTargetBind *bind in expression.morphTargetBinds) {
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
      for (VRM0BlendShapeBind *bind in group.binds) {
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
    VRM1Expression *expression = [self.json.vrm1 expressionByName:key];
    if (expression && expression.morphTargetBinds) {
      float value = expression.isBinary ? roundValue(weight) : weight;
      for (VRM1ExpressionMorphTargetBind *bind in expression.morphTargetBinds) {
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
        [self.json.vrm0.humanoid humanBoneByName:VRM0HumanoidBoneNameLeftEye]
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
        [self.json.vrm0.humanoid humanBoneByName:VRM0HumanoidBoneNameRightEye]
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
    VRM0FirstPersonDegreeMap *horizontalInner =
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
    VRM0FirstPersonDegreeMap *horizontalOuter =
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
    VRM0FirstPersonDegreeMap *verticalUp =
        self.json.vrm0.firstPerson.lookAtVerticalUp;
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
    VRM0FirstPersonDegreeMap *verticalDown =
        self.json.vrm0.firstPerson.lookAtVerticalDown;
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
    [state update:deltaTime];
  }
}

@end
