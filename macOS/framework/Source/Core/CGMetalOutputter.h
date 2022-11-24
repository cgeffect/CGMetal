//
//  CGMetalRenderOutput.h
//  CGMetal
//
//  Created by Jason on 2021/6/14.
//

#import <Foundation/Foundation.h>
#import "CGMetalInput.h"
@import CoreVideo;

NS_ASSUME_NONNULL_BEGIN

@protocol CGMetalOutputDelegate <NSObject>
@optional
- (void)imageRefOutput:(CGImageRef)imageRef;

- (void)pixelbufferRefOutput:(CVPixelBufferRef)pixelbuffer;

- (void)rawDataOutput:(UInt8 *)data;

- (void)textureOutput:(CGMetalTexture *)texture;

@end

@interface CGMetalOutputter : NSObject<CGMetalInput>
{
@protected
    CGMetalTexture *_mtlTexture;
}

@property(nonatomic, weak)id<CGMetalOutputDelegate>delegate;

/**
 输出到目标
  
 @method take
 @discussion 子类各自实现自己的渲染业务逻辑
 */
- (void)take;

@end

NS_ASSUME_NONNULL_END
