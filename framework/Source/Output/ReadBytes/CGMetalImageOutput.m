//
//  CGMetalImageOutput.m
//  CGMetal
//
//  Created by Jason on 2021/6/14.
//

#import "CGMetalImageOutput.h"

@implementation CGMetalImageOutput
{
    UInt8 *_dstData;
}

- (void)take {
    if (_dstData == NULL) {
        _dstData = (UInt8 *)malloc(_mtlTexture.textureSize.width * _mtlTexture.textureSize.height * 4);
    }
    NSLog(@"%ld", _mtlTexture.texture.bufferBytesPerRow);
    MTLRegion region = MTLRegionMake2D(0, 0, _mtlTexture.textureSize.width, _mtlTexture.textureSize.height);
    [_mtlTexture.texture getBytes:_dstData bytesPerRow:_mtlTexture.textureSize.width * 4 fromRegion:region mipmapLevel:0];
    
    CGSize size = self->_mtlTexture.textureSize;
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger totalBytesForImage = (int)size.width * (int)size.height * 4;

    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, _dstData, totalBytesForImage, NULL);
    CGImageRef cgImageFromBytes = CGImageCreate((int)size.width, (int)size.height, 8, 32, 4 * (int)size.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageRefOutput:)]) {
        [self.delegate imageRefOutput:cgImageFromBytes];
    }
    CGImageRelease(cgImageFromBytes);
}

- (void)dealloc
{
    if (_dstData) {
        free(_dstData);
        _dstData = NULL;
    }
}

@end
