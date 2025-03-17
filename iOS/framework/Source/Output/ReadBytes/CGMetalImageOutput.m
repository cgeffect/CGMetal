//
//  CGMetalImageOutput.m
//  CGMetal
//
//  Created by Jason on 2021/6/14.
//

#import <CGMetal/CGMetalImageOutput.h>
CGColorSpaceRef CGColorSpaceGetDeviceRGB(void) {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

@implementation CGMetalImageOutput
{
    UInt8 *_dstData;
}

/**
 * while CGImageRef is not reference, CGDataProviderRef will be release, callback func will call
 * call CGDataProviderRelease is not trigger callback func
 */
static void _CGDataProviderReleaseDataCallback(void *info, const void *data, size_t size) {
    if (info) free(info);
}

- (void)take {
    if (_dstData == NULL) {
        _dstData = (UInt8 *)malloc(_mtlTexture.textureSize.width * _mtlTexture.textureSize.height * 4);
    }
    MTLRegion region = MTLRegionMake2D(0, 0, _mtlTexture.textureSize.width, _mtlTexture.textureSize.height);
    [_mtlTexture.texture getBytes:_dstData bytesPerRow:_mtlTexture.textureSize.width * 4 fromRegion:region mipmapLevel:0];
    
    CGSize size = self->_mtlTexture.textureSize;
    size_t destBytesPerRow = size.width * 4;
    size_t byteSize = destBytesPerRow * size.height;

    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(_dstData, _dstData, byteSize, _CGDataProviderReleaseDataCallback);
    CGImageRef destImageRef = CGImageCreate((int)size.width,
                                                (int)size.height,
                                                8,
                                                32,
                                                destBytesPerRow,
                                                CGColorSpaceGetDeviceRGB(),
                                                kCGBitmapByteOrderDefault | kCGImageAlphaLast,
                                                dataProvider,
                                                NULL,
                                                NO,
                                                kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    dataProvider = NULL;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageRefOutput:)]) {
        [self.delegate imageRefOutput:destImageRef];
    }
    CGImageRelease(destImageRef);
}

- (void)dealloc
{
}

@end
