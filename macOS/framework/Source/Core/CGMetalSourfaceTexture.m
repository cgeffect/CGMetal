//
//  CGMetalSourfaceTexture.m
//  CGMetal
//
//  Created by Jason on 2021/11/30.
//

#import <CGMetalMac/CGMetalSourfaceTexture.h>
#import <CGMetalMac/CGMetalDevice.h>
#import <CoreVideo/CoreVideo.h>

@interface CGMetalSourfaceTexture ()
{
    int _bufferWidth, _bufferHeight;
    CVMetalTextureCacheRef _renderTextureCache;
}
@end

@implementation CGMetalSourfaceTexture

- (id<MTLTexture>)newTextureWithPixelBufferBGRA:(CVPixelBufferRef)pixelBuffer {
    if ([CGMetalDevice supportsFastTextureUpload] == NO) {
        NSAssert(NO, @"iPhone simulator not support fast texture upload");
    }
    _bufferWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    _bufferHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    CVReturn err = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, [CGMetalDevice sharedDevice].device, NULL, &_renderTextureCache);
    if (err) {
        NSLog(@"CGMetalPixelBufferInput Error at CVOpenGLESTextureCacheCreate %d", err);
    }

    ///
    if (!_renderTextureCache) {
        NSLog(@"CGPixelBufferToTexture CVOpenGLESTextureCacheRef nil");
        return 0;
    }
    id<MTLTexture> texture;
    CVMetalTextureRef outTexture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                _renderTextureCache,
                                                                pixelBuffer,
                                                                NULL,
                                                                MTLPixelFormatBGRA8Unorm,
                                                                _bufferWidth,
                                                                _bufferHeight,
                                                                0,
                                                                &outTexture);
    if(status == kCVReturnSuccess) {
        texture = CVMetalTextureGetTexture(outTexture);
        CFRelease(outTexture);
        return texture;
    } else {
        NSLog(@"CGMetalPixelBufferInput Error at CVMetalTextureCacheCreateTextureFromImage %d", status);
        return 0;
    }
}

- (void)dealloc {
    if (_renderTextureCache) {
        CFRelease(_renderTextureCache);
    }
}
@end
