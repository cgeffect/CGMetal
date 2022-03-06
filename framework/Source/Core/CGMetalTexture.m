//
//  CGMetalTexture.m
//  CGMetal
//
//  Created by Jason on 2021/5/27.
//

#import "CGMetalTexture.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@import UIKit;
#else
#endif

MTLTextureLoaderOption const MTLTextureLoaderOptionTextureUsage = @"usage";  // NSInteger
MTLTextureLoaderOption const MTLTextureLoaderOptionPixelFormat = @"pixelFormat";  // NSInteger

@interface CGMetalTexture ()
{
    id<MTLTexture> _texture;
    CGSize _texutreSize;
}
@end

@implementation CGMetalTexture

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        _device = device;
    }
    return self;
}

- (instancetype)initWithTexture:(id<MTLTexture>)texture
                           size:(CGSize)size {
    self = [super init];
    if (self) {
        [self updateWithTexture:texture size:size];
    }
    return self;
}

- (void)updateWithTexture:(id<MTLTexture>)texture
                     size:(CGSize)size {
    _texture = texture;
    _texutreSize = size;
}

//offset screen render use MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
- (id<MTLTexture>)newTexture:(MTLPixelFormat)pixelFormat
                        size:(CGSize)size
                       usege:(MTLTextureUsage)usege {
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:pixelFormat width:size.width height:size.height mipmapped:NO];
    textureDescriptor.textureType = MTLTextureType2D;
    textureDescriptor.usage = usege;
    id<MTLTexture> texture = [_device newTextureWithDescriptor:textureDescriptor];
    if (texture == nil) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        NSLog(@"Could not create texture of size: %@", NSStringFromCGSize(size));
#else
        NSLog(@"Could not create texture of size: %@", NSStringFromSize(size));
#endif
    }
    _texture = texture;
    _texutreSize = size;
    return _texture;
}

/*
 <CVPixelBuffer 0x28132e120 width=720 height=720 pixelFormat=420v iosurface=0x282029a80 planes=2 poolName=12314:decode>
 <Plane 0 width=720 height=720 bytesPerRow=768>
 <Plane 1 width=360 height=360 bytesPerRow=768>
 */
- (id<MTLTexture>)newTexture:(UInt8 *)data pixelFormat:(MTLPixelFormat)pixelFormat size:(CGSize)size bytesPerRow:(NSUInteger)bytesPerRow usege:(MTLTextureUsage)usage {
    id<MTLTexture> texture = [self createEmptyTexture:_device pixelFormat:pixelFormat size:size usage:usage];
    MTLRegion region = MTLRegionMake2D(0, 0, size.width, size.height);
    [texture replaceRegion:region  mipmapLevel: 0 withBytes: data bytesPerRow: bytesPerRow];
    _texture = texture;
    _texutreSize = size;
    return texture;
}

#pragma mark -
- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                   refTexture:(id<MTLTexture>)refTexture {
    self = [super init];
    if (self) {
        _texutreSize = CGSizeMake(width, height);
        _texture = [refTexture newTextureViewWithPixelFormat:MTLPixelFormatRGBA8Unorm];
    }
    return self;
}

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                       offset:(NSUInteger)offset
                  bytesPerRow:(NSUInteger)bytesPerRow
                       buffer:(id<MTLBuffer>)buffer {
    self = [super init];
    if (self) {
        _texutreSize = CGSizeMake(width, height);
        MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                     width:width
                                                                                                    height:height
                                                                                                 mipmapped:NO];
        _texture = [buffer newTextureWithDescriptor:textureDescriptor offset:offset bytesPerRow:bytesPerRow];
    }
    return self;
}

- (id<MTLTexture>)texture {
    return _texture;
}
- (CGSize)textureSize {
    return _texutreSize;
//    return CGSizeMake(_texture.width, _texture.height);
}

- (void)updateTexture:(const void *)pixelBytes
             byteSize:(CGSize)byteSize
          bytesPerRow:(NSUInteger)bytesPerRow {
    MTLRegion region = MTLRegionMake2D(0, 0, byteSize.width, byteSize.height);
    [_texture replaceRegion:region  mipmapLevel: 0 withBytes: pixelBytes bytesPerRow: bytesPerRow];

}

- (nullable id<MTLTexture>)createEmptyTexture:(id<MTLDevice>)device
                                  pixelFormat:(MTLPixelFormat)pixelFormat
                                        size:(CGSize)size
                                        usage:(MTLTextureUsage)usage {
    MTLTextureDescriptor *texDescriptor = [MTLTextureDescriptor
                                           texture2DDescriptorWithPixelFormat: pixelFormat
                                           width: size.width
                                           height: size.height
                                           mipmapped: false];
    texDescriptor.usage = usage;
    id<MTLTexture> texture = [device newTextureWithDescriptor: texDescriptor];
    return texture;
}

@end
