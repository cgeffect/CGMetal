//
//  CGMetalLayerOutput.h
//  CGMetalMac
//
//  Created by Jason on 2021/12/3.
//

#import <QuartzCore/QuartzCore.h>
#import "CGMetalInput.h"

NS_ASSUME_NONNULL_BEGIN
@interface CGMetalLayerOutput : CAMetalLayer<CGMetalInput, CGMetalViewOutput>

- (instancetype)initWithScale:(CGFloat)nativeScale;

@end

NS_ASSUME_NONNULL_END
