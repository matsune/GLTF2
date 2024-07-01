#ifndef Json_SpringBone_h
#define Json_SpringBone_h

#include <optional>
#include <string>
#include <vector>

namespace gltf2 {
namespace json {
namespace vrmc {

class SpringBoneColliderGroup {
public:
  std::optional<std::string> name;
  std::vector<uint32_t> colliders;
};

class SpringBoneJoint {
public:
  uint32_t node;
  std::optional<float> hitRadius;
  std::optional<float> stiffness;
  std::optional<float> gravityPower;
  std::optional<std::array<float, 3>> gravityDir;
  std::optional<float> dragForce;

  float hitRadiusValue() const { return hitRadius.value_or(0); }

  float stiffnessValue() const { return stiffness.value_or(1.0f); }

  float gravityPowerValue() const { return gravityPower.value_or(0); }

  std::array<float, 3> gravityDirValue() const {
    return gravityDir.value_or(std::array<float, 3>({0, -1.0f, 0}));
  }

  float dragForceValue() const { return dragForce.value_or(0.5f); }
};

class SpringBoneShapeSphere {
public:
  std::optional<std::array<float, 3>> offset;
  std::optional<float> radius;

  std::array<float, 3> offsetValue() const {
    return offset.value_or(std::array<float, 3>({0, 0, 0}));
  }

  float radiusValue() const { return radius.value_or(0); }
};

class SpringBoneShapeCapsule {
public:
  std::optional<std::array<float, 3>> offset;
  std::optional<float> radius;
  std::optional<std::array<float, 3>> tail;

  std::array<float, 3> offsetValue() const {
    return offset.value_or(std::array<float, 3>({0, 0, 0}));
  }

  float radiusValue() const { return radius.value_or(0); }

  std::array<float, 3> tailValue() const {
    return tail.value_or(std::array<float, 3>({0, 0, 0}));
  }
};

class SpringBoneShape {
public:
  std::optional<SpringBoneShapeSphere> sphere;
  std::optional<SpringBoneShapeCapsule> capsule;
};

class SpringBoneCollider {
public:
  uint32_t node;
  SpringBoneShape shape;
};

class SpringBoneSpring {
public:
  std::optional<std::string> name;
  std::vector<SpringBoneJoint> joints;
  std::optional<std::vector<uint32_t>> colliderGroups;
  std::optional<uint32_t> center;
};

class SpringBone {
public:
  std::string specVersion;
  std::optional<std::vector<SpringBoneCollider>> colliders;
  std::optional<std::vector<SpringBoneColliderGroup>> colliderGroups;
  std::optional<std::vector<SpringBoneSpring>> springs;
};

} // namespace springbone
} // namespace json
}; // namespace gltf2

#endif /* Json_SpringBone_h */
