#import "VRMSCNAsset.h"

#pragma mark - SCNQuaternion Utils

static SCNQuaternion SCNQuaternionMake(CGFloat x, CGFloat y, CGFloat z, CGFloat w) {
  return SCNVector4Make(x, y, z, w);
}

static SCNQuaternion SCNQuaternionNormalize(const SCNQuaternion &v) {
    float norm = sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
    if (norm == 0) {
        return v;
    }
    float inverseNorm = 1.0 / norm;
    return SCNQuaternionMake(v.x * inverseNorm, v.y * inverseNorm, v.z * inverseNorm, v.w * inverseNorm);
}

static SCNQuaternion SCNQuaternionMul(const SCNQuaternion &q1,
                                      const SCNQuaternion &q2) {
  return SCNVector4Make(q1.x * q2.w + q1.w * q2.x + q1.y * q2.z - q1.z * q2.y,
                        q1.y * q2.w + q1.w * q2.y + q1.z * q2.x - q1.x * q2.z,
                        q1.z * q2.w + q1.w * q2.z + q1.x * q2.y - q1.y * q2.x,
                        q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z);
}

SCNQuaternion SCNQuaternionFromUnitVectors(const SCNVector3 &vFrom,
                                           const SCNVector3 &vTo) {
  const float EPS = 0.000001;
  SCNQuaternion q;
  float r = vFrom.x * vTo.x + vFrom.y * vTo.y + vFrom.z * vTo.z + 1.0f;

  if (r < EPS) {
    r = 0.0f;

    if (fabs(vFrom.x) > fabs(vFrom.z)) {
      q.x = -vFrom.y;
      q.y = vFrom.x;
      q.z = 0.0f;
      q.w = r;
    } else {
      q.x = 0.0f;
      q.y = -vFrom.z;
      q.z = vFrom.y;
      q.w = r;
    }
  } else {
    q.x = vFrom.y * vTo.z - vFrom.z * vTo.y;
    q.y = vFrom.z * vTo.x - vFrom.x * vTo.z;
    q.z = vFrom.x * vTo.y - vFrom.y * vTo.x;
    q.w = r;
  }

  float magnitude = sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
  q.x /= magnitude;
  q.y /= magnitude;
  q.z /= magnitude;
  q.w /= magnitude;

  return q;
}

SCNQuaternion SCNQuaternionFromRotationMatrix(const SCNMatrix4 &m) {
  SCNQuaternion q;

  float m11 = m.m11, m12 = m.m12, m13 = m.m13;
  float m21 = m.m21, m22 = m.m22, m23 = m.m23;
  float m31 = m.m31, m32 = m.m32, m33 = m.m33;

  float trace = m11 + m22 + m33;

  if (trace > 0) {
    float s = 0.5f / sqrt(trace + 1.0f);
    q.w = 0.25f / s;
    q.x = (m32 - m23) * s;
    q.y = (m13 - m31) * s;
    q.z = (m21 - m12) * s;
  } else if (m11 > m22 && m11 > m33) {
    float s = 2.0f * sqrt(1.0f + m11 - m22 - m33);
    q.w = (m32 - m23) / s;
    q.x = 0.25f * s;
    q.y = (m12 + m21) / s;
    q.z = (m13 + m31) / s;
  } else if (m22 > m33) {
    float s = 2.0f * sqrt(1.0f + m22 - m11 - m33);
    q.w = (m13 - m31) / s;
    q.x = (m12 + m21) / s;
    q.y = 0.25f * s;
    q.z = (m23 + m32) / s;
  } else {
    float s = 2.0f * sqrt(1.0f + m33 - m11 - m22);
    q.w = (m21 - m12) / s;
    q.x = (m13 + m31) / s;
    q.y = (m23 + m32) / s;
    q.z = 0.25f * s;
  }

  return q;
}

#pragma mark - SCNMatrix4 Utils

static SCNMatrix4 SCNMatrix4MakeRotation(const SCNQuaternion &q) {
  SCNQuaternion qn = SCNQuaternionNormalize(q);
  CGFloat angle = 2.0f * acos(qn.w);

  CGFloat s = sqrt(1.0f - qn.w * qn.w);
  if (s < 0.0001f) {
    return SCNMatrix4MakeRotation(angle, 1.0f, 0.0f, 0.0f);
  } else {
    return SCNMatrix4MakeRotation(angle, qn.x / s, qn.y / s, qn.z / s);
  }
}

#pragma mark - SCNVector3 Utils

static SCNVector3 SCNVector3Add(const SCNVector3 &v1, const SCNVector3 &v2) {
  return SCNVector3Make(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
}

static SCNVector3 SCNVector3Sub(const SCNVector3 &a, const SCNVector3 &b) {
  return SCNVector3Make(a.x - b.x, a.y - b.y, a.z - b.z);
}

static SCNVector3 SCNVector3Cross(const SCNVector3 &v1, const SCNVector3 &v2) {
  return SCNVector3Make(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z,
                        v1.x * v2.y - v1.y * v2.x);
}

static SCNVector3 SCNVector3Scale(const SCNVector3 &vector, CGFloat n) {
  return SCNVector3Make(vector.x * n, vector.y * n, vector.z * n);
}

static CGFloat SCNVector3Length(const SCNVector3 &vector) {
  return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

static SCNVector3 SCNVector3Normalize(const SCNVector3 &vector) {
  CGFloat length = SCNVector3Length(vector);
  if (length == 0) {
    return SCNVector3Make(0, 0, 0);
  }
  return SCNVector3Make(vector.x / length, vector.y / length,
                        vector.z / length);
}

static SCNVector3 SCNVector3Apply(const SCNVector3 &v, const SCNMatrix4 &m) {
    float w = 1.0 / (m.m14 * v.x + m.m24 * v.y + m.m34 * v.z + m.m44);
    return SCNVector3Make(
        (m.m11 * v.x + m.m21 * v.y + m.m31 * v.z + m.m41) * w,
        (m.m12 * v.x + m.m22 * v.y + m.m32 * v.z + m.m42) * w,
        (m.m13 * v.x + m.m23 * v.y + m.m33 * v.z + m.m43) * w
    );
}

static SCNVector3 SCNVector3Apply(const SCNVector3 &vector,
                                  const SCNQuaternion &quaternion) {
  return SCNVector3Apply(vector, SCNMatrix4MakeRotation(quaternion));
}

#pragma mark - SpringBoneJointState

@interface SpringBoneJointState : NSObject

@property(nonatomic, nonnull, strong) SCNNode *bone;
@property(nonatomic, nullable, strong) SCNNode *child;
@property(nonatomic, nullable, strong) SCNNode *center;
@property(nonatomic, nonnull, strong) VRMSpringBoneJoint *joint;
@property(nonatomic, assign)
    SCNMatrix4 initialLocalMatrix; // bone to parent space
@property(nonatomic, assign) SCNQuaternion initialLocalRotation;
@property(nonatomic, assign) SCNVector3 initialLocalChildPosition;
@property(nonatomic, assign) SCNVector3 boneAxisInBone;      // in bone space
@property(nonatomic, assign) SCNVector3 prevTailInCenter;    // in center space
@property(nonatomic, assign) SCNVector3 currentTailInCenter; // in center space

- (void)update:(NSTimeInterval)deltaTime;

@end

@implementation SpringBoneJointState

- (instancetype)initWithBone:(SCNNode *)bone
                       child:(nullable SCNNode *)child
                      center:(nullable SCNNode *)center
                       joint:(VRMSpringBoneJoint *)joint {
  self = [super init];
  if (self) {
    _bone = bone;
    _child = child;
    _center = center;
    _joint = joint;
    _initialLocalMatrix = bone.transform;
    _initialLocalRotation = bone.orientation;
    if (child) {
      _initialLocalChildPosition = child.position;
    } else {
      _initialLocalChildPosition =
          SCNVector3Scale(SCNVector3Normalize(bone.position), 0.07);
    }
    _boneAxisInBone = SCNVector3Normalize(_initialLocalChildPosition);

    SCNMatrix4 boneToWorld = self.bone.worldTransform;
    SCNMatrix4 worldToCenter = [self getWorldToCenterMatrix];
    SCNMatrix4 boneToCenter = SCNMatrix4Mult(boneToWorld, worldToCenter);
    _currentTailInCenter =
        SCNVector3Apply(_initialLocalChildPosition, boneToCenter);
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

- (CGFloat)getBoneLength {
  SCNVector3 bonePositionInWorld = self.bone.worldPosition;
  SCNVector3 childPositionInWorld;
  if (self.child) {
    childPositionInWorld = self.child.worldPosition;
  } else {
    childPositionInWorld = SCNVector3Apply(self.initialLocalChildPosition,
                                           self.bone.worldTransform);
  }
  return SCNVector3Length(
      SCNVector3Sub(childPositionInWorld, bonePositionInWorld));
}

- (void)update:(NSTimeInterval)deltaTime {
  if (deltaTime <= 0)
    return;

  CGFloat boneLength = [self getBoneLength];

  // Get bone position in center space
  SCNVector3 bonePositionInWorld = self.bone.worldPosition;
  SCNMatrix4 worldToCenter = [self getWorldToCenterMatrix];
  SCNVector3 bonePositionInCenter =
      SCNVector3Apply(bonePositionInWorld, worldToCenter);

  // Get bone position in center space
  SCNMatrix4 boneToParent = self.initialLocalMatrix;
  SCNMatrix4 parentToWorld = [self getParentToWorldMatrix];
  SCNMatrix4 boneToCenter = SCNMatrix4Mult(
      boneToParent, SCNMatrix4Mult(parentToWorld, worldToCenter));
  SCNVector3 boneAxisInCenter = SCNVector3Normalize(
      SCNVector3Sub(SCNVector3Apply(self.boneAxisInBone, boneToCenter),
                    bonePositionInCenter));

  SCNQuaternion worldToCenterQuat =
      SCNQuaternionFromRotationMatrix(worldToCenter);

  // gravity in center space
  SCNVector3 gravityDirInCenter = SCNVector3Normalize(
      SCNVector3Apply(self.joint.gravityDirValue, worldToCenterQuat));

  SCNMatrix4 centerToWorld = [self getCenterToWorldMatrix];

  // inertia
  SCNVector3 inertia = SCNVector3Scale(
      SCNVector3Sub(self.currentTailInCenter, self.prevTailInCenter),
      1.0 - self.joint.dragForceValue);

  // stiffness
  SCNVector3 stiffness =
      SCNVector3Scale(boneAxisInCenter, self.joint.stiffnessValue * deltaTime);

  // gravity
  SCNVector3 gravity = SCNVector3Scale(
      gravityDirInCenter, self.joint.gravityPowerValue * deltaTime);

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
  nextTailInCenter = SCNVector3Apply(nextTailInWorld, worldToCenter);

  // TODO: collision

  self.prevTailInCenter = self.currentTailInCenter;
  self.currentTailInCenter = nextTailInCenter;

  SCNMatrix4 worldToBoneMatrix =
      SCNMatrix4Invert(SCNMatrix4Mult(boneToParent, parentToWorld));
  SCNVector3 nextBoneAxisInBone =
      SCNVector3Normalize(SCNVector3Apply(nextTailInWorld, worldToBoneMatrix));
  SCNQuaternion applyRotation =
      SCNQuaternionFromUnitVectors(self.boneAxisInBone, nextBoneAxisInBone);
  self.bone.orientation =
      SCNQuaternionMul(self.initialLocalRotation, applyRotation);
}

@end

static float angleBetweenVectors(SCNVector3 v1, SCNVector3 v2) {
  float dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
  float magnitudeV1 = sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
  float magnitudeV2 = sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z);
  return acos(dot / (magnitudeV1 * magnitudeV2));
}

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
      SCNVector3 cross = SCNVector3Cross(up, direction);
      SCNVector3 axis = SCNVector3Cross(up, direction);
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
        SCNNode *center;
        if (spring.center) {
          center = self.scnNodes[spring.center.unsignedIntValue];
        }

        for (int i = 1; i < spring.joints.count; i++) {
          NSUInteger boneIndex = spring.joints[i - 1].node;
          NSUInteger childIndex = spring.joints[i].node;
          SCNNode *bone = self.scnNodes[boneIndex];
          SCNNode *child = self.scnNodes[childIndex];
          assert(bone == child.parentNode);
          VRMSpringBoneJoint *joint = spring.joints[i - 1];
          SpringBoneJointState *state =
              [[SpringBoneJointState alloc] initWithBone:bone
                                                   child:child
                                                  center:center
                                                   joint:joint];
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
