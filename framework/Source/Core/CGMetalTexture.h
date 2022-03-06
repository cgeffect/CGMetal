//
//  CGMetalTexture.h
//  CGMetal
//
//  Created by Jason on 2021/5/27.
//

@import Foundation;
@import Metal;
@import CoreGraphics;

NS_ASSUME_NONNULL_BEGIN

#define MTL_EXTERN extern MTL_EXPORT
typedef NSString * MTLTextureLoaderOption NS_STRING_ENUM NS_SWIFT_NAME(MTLTextureLoader.Option);
//MTLPixelFormat flag
MTL_EXTERN MTLTextureLoaderOption __nonnull const MTLTextureLoaderOptionPixelFormat;
//MTLTextureUsage flag @[@(MTLTextureUsageShaderRead), @(MTLTextureUsageRenderTarget)]
MTL_EXTERN MTLTextureLoaderOption __nonnull const MTLTextureLoaderOptionTextureUsage;

@interface CGMetalTexture : NSObject

@property (nonatomic, readonly, nonnull) id <MTLDevice> device;

@property(nonatomic, readonly)id<MTLTexture>texture;

@property(nonatomic, readonly)CGSize textureSize;

- (nonnull instancetype)initWithDevice:(nonnull id <MTLDevice>)device;

#pragma mark -
#pragma mark use MTLTexture create CGMetalTexture
- (instancetype)initWithTexture:(id<MTLTexture>)texture
                           size:(CGSize)size;
- (void)updateWithTexture:(id<MTLTexture>)texture
                     size:(CGSize)size;

#pragma mark -
#pragma mark new
/*!
 @method newTexture:size:usege:
 @abstract Create a new texture.
 */
- (nullable id<MTLTexture>)newTexture:(MTLPixelFormat)pixelFormat
                                 size:(CGSize)size
                                usege:(MTLTextureUsage)usage;

/*!
 @abstract Create a new texture with data.
 */
- (nullable id<MTLTexture>)newTexture:(UInt8 *)data
                          pixelFormat:(MTLPixelFormat)pixelFormat
                                 size:(CGSize)size
                          bytesPerRow:(NSUInteger)bytesPerRow
                                usege:(MTLTextureUsage)usage;

#pragma mark -
#pragma mark update texture data
- (void)updateTexture:(const void *)pixelBytes
             byteSize:(CGSize)byteSize
          bytesPerRow:(NSUInteger)bytesPerRow;

#pragma mark -
#pragma mark
- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                   refTexture:(id<MTLTexture>)refTexture;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                       offset:(NSUInteger)offset
                  bytesPerRow:(NSUInteger)bytesPerRow
                       buffer:(id<MTLBuffer>)buffer;


@end

NS_ASSUME_NONNULL_END
