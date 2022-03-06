//
//  CGMetalPixelBufferOutput.m
//  CGMetal
//
//  Created by Jason on 2021/6/14.
//

#import "CGMetalPixelBufferOutput.h"

@implementation CGMetalPixelBufferOutput
{
    UInt8 *_dstData;
}
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)take {
    CGSize _size = self->_mtlTexture.textureSize;
    NSUInteger layoutWidth = ((int)_size.width / 16) * 16;
    NSUInteger totalBytesForImage = layoutWidth * (int)_size.height * 4;

    if (_dstData == NULL) {
        _dstData = (UInt8 *)malloc(totalBytesForImage);
    }
    
//    MTLTextureSwizzleChannels channels = MTLTextureSwizzleChannelsMake(MTLTextureSwizzleBlue, MTLTextureSwizzleGreen, MTLTextureSwizzleRed, MTLTextureSwizzleAlpha);
//    _mtlTexture.accessibilityViewIsModal
    MTLRegion region = MTLRegionMake2D(0, 0, layoutWidth, _size.height);
    [_mtlTexture.texture getBytes:_dstData bytesPerRow:layoutWidth * 4 fromRegion:region mipmapLevel:0];
        
    CVPixelBufferRef dstBuffer = [self pixelBufferCreate:kCVPixelFormatType_32BGRA width:layoutWidth height:_size.height];
    CVPixelBufferLockBaseAddress(dstBuffer, kCVPixelBufferLock_ReadOnly);
    void * dst = CVPixelBufferGetBaseAddress(dstBuffer);
    memcpy(dst, _dstData, totalBytesForImage);
    CVPixelBufferUnlockBaseAddress(dstBuffer, kCVPixelBufferLock_ReadOnly);
    if (self.delegate && [self.delegate respondsToSelector:@selector(pixelbufferRefOutput:)]) {
        [self.delegate pixelbufferRefOutput:dstBuffer];
    }
    CVPixelBufferRelease(dstBuffer);
}

- (CVPixelBufferRef)pixelBufferCreate:(OSType)pixelFormatType width:(NSUInteger)width height:(NSUInteger)height {
    CVPixelBufferRef _pixelBuffer;
    CFDictionaryRef pixelAttributes = (__bridge CFDictionaryRef)
    (@{
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        (id)kCVPixelBufferOpenGLESCompatibilityKey:@(YES),
#else
#endif
        (id)kCVPixelBufferMetalCompatibilityKey:@(YES)

     });
    CVPixelBufferCreate(kCFAllocatorDefault, (size_t) width, (size_t) height, pixelFormatType, pixelAttributes, &_pixelBuffer);
    return _pixelBuffer;
}

- (void)dealloc
{
    if (_dstData) {
        free(_dstData);
        _dstData = NULL;
    }
}
@end
