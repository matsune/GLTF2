#ifndef SceneKitUtil_h
#define SceneKitUtil_h

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

static SCNQuaternion SCNQuaternionMake(CGFloat x, CGFloat y, CGFloat z,
                                       CGFloat w) {
  return SCNVector4Make(x, y, z, w);
}

static SCNQuaternion SCNQuaternionNormalize(const SCNQuaternion &v) {
  float norm = sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
  if (norm == 0) {
    return v;
  }
  float inverseNorm = 1.0 / norm;
  return SCNQuaternionMake(v.x * inverseNorm, v.y * inverseNorm,
                           v.z * inverseNorm, v.w * inverseNorm);
}

static SCNQuaternion SCNQuaternionMul(const SCNQuaternion &q1,
                                      const SCNQuaternion &q2) {
  return SCNVector4Make(q1.x * q2.w + q1.w * q2.x + q1.y * q2.z - q1.z * q2.y,
                        q1.y * q2.w + q1.w * q2.y + q1.z * q2.x - q1.x * q2.z,
                        q1.z * q2.w + q1.w * q2.z + q1.x * q2.y - q1.y * q2.x,
                        q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z);
}

static SCNQuaternion SCNQuaternionFromUnitVectors(const SCNVector3 &vFrom,
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

static SCNQuaternion SCNQuaternionFromRotationMatrix(const SCNMatrix4 &m) {
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
  return SCNVector3Make((m.m11 * v.x + m.m21 * v.y + m.m31 * v.z + m.m41) * w,
                        (m.m12 * v.x + m.m22 * v.y + m.m32 * v.z + m.m42) * w,
                        (m.m13 * v.x + m.m23 * v.y + m.m33 * v.z + m.m43) * w);
}

static SCNVector3 SCNVector3Apply(const SCNVector3 &vector,
                                  const SCNQuaternion &quaternion) {
  return SCNVector3Apply(vector, SCNMatrix4MakeRotation(quaternion));
}

static CGFloat SCNVector3LengthBetween(const SCNVector3 &a,
                                       const SCNVector3 &b) {
  return SCNVector3Length(SCNVector3Sub(a, b));
}

static SCNVector3 SCNVector3Axis(const SCNVector3 &from, const SCNVector3 &to) {
  return SCNVector3Normalize(SCNVector3Sub(to, from));
}

// angle in radians
static CGFloat SCNVector3AngleBetween(const SCNVector3 &v1,
                                      const SCNVector3 &v2) {
  CGFloat dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
  CGFloat magnitudeV1 = sqrt(pow(v1.x, 2) + pow(v1.y, 2) + pow(v1.z, 2));
  CGFloat magnitudeV2 = sqrt(pow(v2.x, 2) + pow(v2.y, 2) + pow(v2.z, 2));
  return acos(dot / (magnitudeV1 * magnitudeV2));
}

#endif /* SceneKitUtil_h */
