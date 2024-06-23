#import "GLTFSCNAsset.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VRMSCNAsset : GLTFSCNAsset

- (NSArray<NSString *> *)blendShapeKeys;
- (CGFloat)weightForBlendShapeKey:(NSString *)key;
- (void)setBlendShapeWeight:(CGFloat)weight forKey:(NSString *)key;

- (nullable SCNNode *)vrmRootNode;
- (void)lookAtTarget:(SCNVector3)target;
- (void)updateAtTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
