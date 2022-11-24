//
//  CGMetalNSViewOutput.h
//  CGMetalMac
//
//  Created by Jason on 2021/12/4.
//

#import "CGMetalLayerOutput.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalNSViewOutput : NSView<CGMetalInput, CGMetalViewOutput>

- (void)setCanvasColor:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

@end

NS_ASSUME_NONNULL_END
#endif
