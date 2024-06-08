#import "GLTF2Availability.h"
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSString *VRM0BlendShapeKeyUnknown;
extern const NSString *VRM0BlendShapeKeyNeutral;
extern const NSString *VRM0BlendShapeKeyA;
extern const NSString *VRM0BlendShapeKeyI;
extern const NSString *VRM0BlendShapeKeyU;
extern const NSString *VRM0BlendShapeKeyE;
extern const NSString *VRM0BlendShapeKeyO;
extern const NSString *VRM0BlendShapeKeyBlink;
extern const NSString *VRM0BlendShapeKeyJoy;
extern const NSString *VRM0BlendShapeKeyAngry;
extern const NSString *VRM0BlendShapeKeySorrow;
extern const NSString *VRM0BlendShapeKeyFun;
extern const NSString *VRM0BlendShapeKeyLookup;
extern const NSString *VRM0BlendShapeKeyLookdown;
extern const NSString *VRM0BlendShapeKeyLookleft;
extern const NSString *VRM0BlendShapeKeyLookright;
extern const NSString *VRM0BlendShapeKeyBlinkL;
extern const NSString *VRM0BlendShapeKeyBlinkR;

extern const NSString *VRM1BlendShapeKeyHappy;
extern const NSString *VRM1BlendShapeKeyAngry;
extern const NSString *VRM1BlendShapeKeySad;
extern const NSString *VRM1BlendShapeKeyRelaxed;
extern const NSString *VRM1BlendShapeKeySurprised;
extern const NSString *VRM1BlendShapeKeyAa;
extern const NSString *VRM1BlendShapeKeyIh;
extern const NSString *VRM1BlendShapeKeyOu;
extern const NSString *VRM1BlendShapeKeyEe;
extern const NSString *VRM1BlendShapeKeyOh;
extern const NSString *VRM1BlendShapeKeyBlink;
extern const NSString *VRM1BlendShapeKeyBlinkLeft;
extern const NSString *VRM1BlendShapeKeyBlinkRight;
extern const NSString *VRM1BlendShapeKeyLookUp;
extern const NSString *VRM1BlendShapeKeyLookDown;
extern const NSString *VRM1BlendShapeKeyLookLeft;
extern const NSString *VRM1BlendShapeKeyLookRight;
extern const NSString *VRM1BlendShapeKeyNeutral;

GLTF_EXPORT @interface GLTFSCNAsset : NSObject

@property(nonatomic, strong) NSArray<SCNScene *> *scenes;
@property(nonatomic, strong, readonly) NSArray<SCNNode *> *cameraNodes;
@property(nonatomic, strong) NSArray<SCNAnimationPlayer *> *animationPlayers;

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error;

- (nullable SCNScene *)defaultScene;

- (void)setBlendShapeWeight:(float)weight forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
