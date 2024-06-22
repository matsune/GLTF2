#ifndef SidebarViewControllerDelegate_h
#define SidebarViewControllerDelegate_h

#import "GLTFSCNAsset.h"
#import <Cocoa/Cocoa.h>

@class SidebarViewController;

@protocol SidebarViewControllerDelegate <NSObject>

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
       didSelectCameraAtIndex:(NSInteger)index;
- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
              didChangeLightX:(float)x;
- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
              didChangeWeight:(float)weight
             forBlendShapeKey:(NSString *)key;
- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
             didChangeLookAtX:(float)value;
- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
             didChangeLookAtY:(float)value;
- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
             didChangeLookAtZ:(float)value;

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
        didChangeVrmPositionX:(float)value;
- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
        didChangeVrmPositionY:(float)value;
- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
        didChangeVrmPositionZ:(float)value;

@end

#endif /* SidebarViewControllerDelegate_h */
