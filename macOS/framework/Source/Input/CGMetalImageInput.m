//
//  CGMetalImageInput.m
//  CGMetal
//
//  Created by Jason on 2021/5/13.
//  Copyright © 2021 CGMetal. All rights reserved.
//


#import "CGMetalImageInput.h"
#import "CGMetalTexture.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

@interface CGMetalImageInput ()
{
}
@end

@implementation CGMetalImageInput

- (instancetype)initWithImage:(UIImage *)newImageSource {
    self = [super init];
    if (self) {
        if (!(self = [super init]))
        {
            return nil;
        }
        size_t width = CGImageGetWidth(newImageSource.CGImage);
        size_t height = CGImageGetHeight(newImageSource.CGImage);
        CGMetalTexture *mtlTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
        UInt8 *byte = [self decodeImage:newImageSource.CGImage];
        id<MTLTexture>texture = [mtlTexture newTexture:byte pixelFormat:MTLPixelFormatRGBA8Unorm size:CGSizeMake(width, height) bytesPerRow:width * 4 usege:MTLTextureUsageShaderRead];

        _outputTexture = [[CGMetalTexture alloc] initWithTexture:texture size:CGSizeMake(width, height)];
    }
    return self;
}

- (void)requestRender {
    [super requestRender];
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget newTextureAvailable:_outputTexture];
    }
}

#pragma mark -
- (UInt8 *)decodeImage:(CGImageRef)cgImage
{
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    size_t dataLen = width * height * 4;
    uint8_t *imageData = malloc(dataLen);
    //不要使用系统提供的方法获取, 系统提供的方法获取的值是经过处理的不是原始值
//    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bitsPerComponent = 8;
//    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;

    CGContextRef ctx = CGBitmapContextCreate(imageData, width, height,
                                             bitsPerComponent, bytesPerRow, colorSpaceRef, bitmapInfo);
    //CGContextDrawImage Core Graphics框架的原点在屏幕的左下角。
    CGContextDrawImage(ctx, rect, cgImage);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(ctx);
    
    return imageData;
    
}

- (void)dealloc
{
}

@end
#else
#endif
