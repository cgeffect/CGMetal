//
//  CGMetalPixelBufferSurfaceOutput.h
//  CGMetal
//
//  Created by Jason on 2021/11/30.
//

#import "CGMetalInput.h"
@import CoreVideo;

NS_ASSUME_NONNULL_BEGIN

@class CGMetalPixelBufferSurfaceOutput;
@protocol CGMetalRenderOutputDelegate <NSObject>

- (void)onRenderCompleted:(CGMetalPixelBufferSurfaceOutput *)thiz receivedPixelBufferFromTexture:(CVPixelBufferRef)pixelBuffer;

@end

@interface CGMetalPixelBufferSurfaceOutput : NSObject<CGMetalInput>

@property(nonatomic, strong) id <CGMetalRenderOutputDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
