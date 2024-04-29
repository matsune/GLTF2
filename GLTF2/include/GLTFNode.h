#import <Foundation/Foundation.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFNode : NSObject

@property(nonatomic, assign) NSUInteger camera;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *children;
@property(nonatomic, assign) NSUInteger skin;
@property(nonatomic, assign) simd_float4x4 matrix;
@property(nonatomic, assign) NSUInteger mesh;
@property(nonatomic, strong) NSArray<NSNumber *> *rotation;    // number[4]
@property(nonatomic, strong) NSArray<NSNumber *> *scale;       // number[3]
@property(nonatomic, strong) NSArray<NSNumber *> *translation; // number[3]
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSDictionary *extensions;
@property(nonatomic, copy, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
