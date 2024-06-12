#ifndef SCNViewControllerDelegate_h
#define SCNViewControllerDelegate_h

#import "GLTF2SceneKit.h"
#import <Cocoa/Cocoa.h>

@class SCNViewController;

@protocol SCNViewControllerDelegate <NSObject>

- (void)scnViewController:(SCNViewController *)scnViewController
             didLoadAsset:(GLTFSCNAsset *)asset;

@end

#endif /* SCNViewControllerDelegate_h */
