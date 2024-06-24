#import "VRMSCNAsset.h"

static CGFloat SCNVector3Length(const SCNVector3 &vector) {
  return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

static SCNVector3 SCNVector3Normalized(const SCNVector3 &vector) {
  CGFloat length = SCNVector3Length(vector);
  if (length == 0) {
    return SCNVector3Make(0, 0, 0);
  }
  return SCNVector3Make(vector.x / length, vector.y / length,
                        vector.z / length);
}

static SCNVector3 SCNVector3Add(SCNVector3 v1, SCNVector3 v2) {
  return SCNVector3Make(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
}

static SCNVector3 SCNVector3Sub(const SCNVector3 &a, const SCNVector3 &b) {
  return SCNVector3Make(a.x - b.x, a.y - b.y, a.z - b.z);
}

static SCNVector3 SCNVector3Scale(const SCNVector3 &vector, CGFloat n) {
  return SCNVector3Make(vector.x * n, vector.y * n, vector.z * n);
}

static BOOL SCNVectorIsEqual(const SCNVector3 &a, const SCNVector3 &b) {
  return a.x == b.x && a.y == b.y && a.z == b.z;
}

static SCNQuaternion SCNQuaternionMultiply(SCNQuaternion q1, SCNQuaternion q2) {
  SCNQuaternion result;
  result.x = q1.x * q2.w + q1.w * q2.x + q1.y * q2.z - q1.z * q2.y;
  result.y = q1.y * q2.w + q1.w * q2.y + q1.z * q2.x - q1.x * q2.z;
  result.z = q1.z * q2.w + q1.w * q2.z + q1.x * q2.y - q1.y * q2.x;
  result.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
  return result;
}

static SCNVector3 SCNVector3CrossProduct(SCNVector3 v1, SCNVector3 v2) {
  return SCNVector3Make(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z,
                        v1.x * v2.y - v1.y * v2.x);
}

static SCNVector3 SCNVector3ApplyQuaternion(SCNVector3 v, SCNQuaternion q) {
  SCNVector3 qVec = SCNVector3Make(q.x, q.y, q.z);
  SCNVector3 uv = SCNVector3CrossProduct(qVec, v);
  SCNVector3 uuv = SCNVector3CrossProduct(qVec, uv);
  uv = SCNVector3Scale(uv, 2.0 * q.w);
  uuv = SCNVector3Scale(uuv, 2.0);

  return SCNVector3Add(SCNVector3Add(v, uv), uuv);
}

static SCNVector3 SCNVector3ApplyTransform(SCNVector3 vector, SCNMatrix4 transform) {
    SCNVector3 result;
    result.x = transform.m11 * vector.x + transform.m21 * vector.y + transform.m31 * vector.z + transform.m41;
    result.y = transform.m12 * vector.x + transform.m22 * vector.y + transform.m32 * vector.z + transform.m42;
    result.z = transform.m13 * vector.x + transform.m23 * vector.y + transform.m33 * vector.z + transform.m43;
    return result;
}

static SCNVector3 SCNVector3Transform(SCNVector3 vector, SCNQuaternion quaternion) {
    SCNMatrix4 rotationMatrix = SCNMatrix4MakeRotation(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
    return SCNVector3ApplyTransform(vector, rotationMatrix);
}

static SCNVector3 SCNVector3Transform(SCNVector3 vector, SCNMatrix4 transform) {
    SCNVector3 result;
    result.x = transform.m11 * vector.x + transform.m21 * vector.y + transform.m31 * vector.z + transform.m41;
    result.y = transform.m12 * vector.x + transform.m22 * vector.y + transform.m32 * vector.z + transform.m42;
    result.z = transform.m13 * vector.x + transform.m23 * vector.y + transform.m33 * vector.z + transform.m43;
    return result;
}

SCNVector3 SCNVector3Cross(SCNVector3 a, SCNVector3 b) {
    return SCNVector3Make(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

float SCNVector3Dot(SCNVector3 a, SCNVector3 b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

SCNQuaternion SCNQuaternionMakeWithAngleAndAxis(float angle, float x, float y, float z) {
    float halfAngle = angle * 0.5;
    float sinHalfAngle = sin(halfAngle);

    SCNQuaternion quaternion;
    quaternion.x = x * sinHalfAngle;
    quaternion.y = y * sinHalfAngle;
    quaternion.z = z * sinHalfAngle;
    quaternion.w = cos(halfAngle);

    return quaternion;
}

SCNQuaternion SCNQuaternionFromToRotation(SCNVector3 from, SCNVector3 to) {
    SCNVector3 axis = SCNVector3Normalized(SCNVector3Cross(from, to));
    float angle = acos(SCNVector3Dot(SCNVector3Normalized(from), SCNVector3Normalized(to)));
    return SCNQuaternionMakeWithAngleAndAxis(angle, axis.x, axis.y, axis.z);
}

@interface SpringBoneJointState : NSObject

@property(nonatomic, nonnull, strong) SCNNode *tailNode;
@property(nonatomic, assign) SCNVector3 prevTail;
@property(nonatomic, assign) SCNVector3 currentTail;
@property(nonatomic, assign) SCNVector3 boneAxis;
@property(nonatomic, assign) CGFloat boneLength;
@property(nonatomic, assign) SCNMatrix4 initialLocalMatrix;
@property(nonatomic, assign) SCNQuaternion initialLocalRotation;
@property(nonatomic, strong) VRMSpringBoneJoint *joint;

- (void)update:(NSTimeInterval)deltaTime;

@end

@implementation SpringBoneJointState

- (void)update:(NSTimeInterval)deltaTime {
  SCNVector3 worldPosition = self.tailNode.parentNode.worldPosition;
  SCNQuaternion parentWorldRotation = self.tailNode.parentNode.worldOrientation;

  // 慣性計算
  SCNVector3 inertia = SCNVector3Scale(
      SCNVector3Sub(self.currentTail, self.prevTail),
      1.0 - self.joint.dragForceValue);

  // 剛性計算
  SCNVector3 stiffness = SCNVector3Scale(
      SCNVector3Transform(
                          SCNVector3Scale(self.boneAxis, self.joint.stiffnessValue),
          parentWorldRotation),
      deltaTime);

  // 重力計算
  SCNVector3 gravity = SCNVector3Scale(
      self.joint.gravityDirValue, self.joint.gravityPowerValue * deltaTime);

  // 次の位置を計算
  SCNVector3 nextTail = SCNVector3Add(
      SCNVector3Add(SCNVector3Add(self.currentTail, inertia), stiffness),
      gravity);

  // 長さの制約
  nextTail = SCNVector3Add(
      worldPosition,
                           SCNVector3Scale(SCNVector3Normalized(SCNVector3Sub(nextTail, worldPosition)),
          self.boneLength));

  // prevTail・currentTailの更新
  self.prevTail = self.currentTail;
  self.currentTail = nextTail;

  // 回転の更新
  SCNMatrix4 invertedMatrix = SCNMatrix4Invert(self.initialLocalMatrix);
  SCNVector3 to = SCNVector3Normalized(SCNVector3Transform(SCNVector3Sub(nextTail, worldPosition), invertedMatrix));

//  SCNVector3 to = SCNVector3Normalized(
//      SCNVector3Transform(SCNVector3Sub(nextTail, worldPosition),
//                          SCNMatrix4Invert(self.initialLocalMatrix)));
  self.tailNode.orientation =
      SCNQuaternionMultiply(self.initialLocalRotation,
                            SCNQuaternionFromToRotation(self.boneAxis, to));

  SCNVector3 localNextTail = [self.tailNode.parentNode convertPosition:nextTail fromNode:nil];
    self.tailNode.position = localNextTail;
  //  SCNNode *headNode = self.tailNode.parentNode;
  //  if (!headNode)
  //    return;
  //
  //  SCNVector3 currentTail = self.currentTail;
  //  SCNVector3 prevTail = self.prevTail;
  //  SCNQuaternion initialLocalRotation = self.initialLocalRotation;
  //  SCNVector3 boneAxis = self.boneAxis;
  //  CGFloat boneLength = self.boneLength;
  //
  //  CGFloat dragForce = self.joint.dragForceValue;
  //  CGFloat stiffnessForce = self.joint.stiffnessValue;
  //  SCNVector3 gravityDir = self.joint.gravityDirValue;
  //  CGFloat gravityPower = self.joint.gravityPowerValue;
  //
  //  SCNVector3 worldPosition = self.tailNode.worldPosition;
  //  SCNQuaternion parentWorldRotation = headNode.worldOrientation;
  //
  //  SCNVector3 inertia =
  //      SCNVector3Scale(SCNVector3Sub(currentTail, prevTail), (1.0 -
  //      dragForce));
  //
  //  SCNQuaternion combinedRotation =
  //      SCNQuaternionMultiply(parentWorldRotation, initialLocalRotation);
  //  SCNVector3 rotatedDirection =
  //      SCNVector3ApplyQuaternion(boneAxis, combinedRotation);
  //  SCNVector3 stiffness =
  //      SCNVector3Scale(rotatedDirection, stiffnessForce * deltaTime);
  //
  //  SCNVector3 external = SCNVector3Scale(gravityDir, gravityPower *
  //  deltaTime);
  //
  //  SCNVector3 nextTail = SCNVector3Add(
  //      SCNVector3Add(SCNVector3Add(currentTail, inertia), stiffness),
  //      external);
  //
  //  SCNVector3 direction =
  //      SCNVector3Normalized(SCNVector3Sub(nextTail, worldPosition));
  //  nextTail =
  //      SCNVector3Add(worldPosition, SCNVector3Scale(direction, boneLength));
  //
  //  self.prevTail = self.currentTail;
  //  self.currentTail = nextTail;
  //
  //  self.tailNode.worldPosition = nextTail;
}

@end

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

- (NSArray<SCNNode *> *)addColliderNodes:
    (NSArray<VRMSpringBoneCollider *> *)colliders {
  NSMutableArray<SCNNode *> *colliderNodes = [NSMutableArray array];

  for (VRMSpringBoneCollider *collider in colliders) {
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
      colliderNode.geometry =
          [SCNCapsule capsuleWithCapRadius:collider.shape.capsule.radiusValue
                                    height:height];

      colliderNode.position = offset;

      SCNVector3 direction = SCNVector3Make(
          tail.x - offset.x, tail.y - offset.y, tail.z - offset.z);
      SCNVector3 up = SCNVector3Make(0, 1, 0);
      SCNVector3 cross = SCNVector3CrossProduct(up, direction);
      SCNVector3 axis = SCNVector3CrossProduct(up, direction);
      float angle = angleBetweenVectors(up, direction);
      colliderNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle);
    }
    colliderNode.geometry.firstMaterial.transparency = 0.0;
    colliderNode.physicsBody = [SCNPhysicsBody
        bodyWithType:SCNPhysicsBodyTypeKinematic
               shape:[SCNPhysicsShape shapeWithNode:colliderNode options:nil]];
    [node addChildNode:colliderNode];

    [colliderNodes addObject:colliderNode];
  }

  return [colliderNodes copy];
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

    NSArray<SCNNode *> *colliderNodes = [NSMutableArray array];
    if (springBone.colliders) {
      colliderNodes = [self addColliderNodes:springBone.colliders];
    }

    NSMutableArray<NSArray<SCNNode *> *> *colliderGroups =
        [NSMutableArray array];
    if (springBone.colliderGroups) {
      for (VRMSpringBoneColliderGroup *colliderGroup in springBone
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
      for (VRMSpringBoneSpring *spring in springBone.springs) {
        // TODO: center space
        for (int i = 0; i < spring.joints.count - 1; i++) {
          NSUInteger headIndex = spring.joints[i].node;
          NSUInteger tailIndex = spring.joints[i + 1].node;
          SCNNode *head = self.scnNodes[headIndex];
          SCNNode *tail = self.scnNodes[tailIndex];
          assert(head == tail.parentNode);

          SpringBoneJointState *state = [[SpringBoneJointState alloc] init];
          state.tailNode = tail;
          state.prevTail = tail.worldPosition;
          state.currentTail = tail.worldPosition;
          state.boneAxis = SCNVector3Normalized(
              SCNVector3Sub(tail.worldPosition, head.worldPosition));
          state.boneLength = SCNVector3Length(
              SCNVector3Sub(tail.worldPosition, head.worldPosition));
          state.initialLocalMatrix = tail.transform;
          state.initialLocalRotation = tail.orientation;
          state.joint = spring.joints[i];

          [jointStates addObject:state];
        }
      }
      self.jointStates = [jointStates copy];
    }
  }

  if (self.json.vrm0 && self.json.vrm0.secondaryAnimation &&
      self.json.vrm0.secondaryAnimation.colliderGroups) {
    for (VRM0SecondaryAnimationColliderGroup *colliderGroup in self.json.vrm0
             .secondaryAnimation.colliderGroups) {
      if (colliderGroup.node && colliderGroup.colliders) {
        SCNNode *node = self.scnNodes[colliderGroup.node.unsignedIntValue];
        for (VRM0SecondaryAnimationCollider *collider in colliderGroup
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
