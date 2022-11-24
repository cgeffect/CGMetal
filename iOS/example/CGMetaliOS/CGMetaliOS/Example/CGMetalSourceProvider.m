//
//  CGMetalSource.m
//  CGMetal
//
//  Created by Jason on 2021/11/5.
//

#import "CGMetalSourceProvider.h"
#import <Accelerate/Accelerate.h>

@implementation CGMetalSourceProvider

/*
 int width = (int)CGImageGetWidth(image.CGImage);
 int height = (int)CGImageGetHeight(image.CGImage);
 UInt8 *bgra = CGRDecodeImage32LittleARGB(image.CGImage, width, height);
 NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bgra8_1125x1125.bgra"];
 FILE *file = fopen([path UTF8String], "wb++");
 int buffersize = width * height * 4;
 fwrite((uint8_t *)bgra, 1, buffersize, file);
 fclose(file);
 */


+ (CVPixelBufferRef)pixelBufferCreate:(OSType)pixelFormatType width:(NSUInteger)width height:(NSUInteger)height {
    CVPixelBufferRef _pixelBuffer;
    CFDictionaryRef pixelAttributes = (__bridge CFDictionaryRef)
    (@{
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (id)kCVPixelBufferOpenGLESCompatibilityKey:@(YES)
     });
    CVPixelBufferCreate(kCFAllocatorDefault, (size_t) width, (size_t) height, pixelFormatType, pixelAttributes, &_pixelBuffer);
    return _pixelBuffer;
}
+ (BOOL)create32BGRAPixelBufferWithNV12:(nonnull UInt8 *)nv12 width:(NSUInteger)width height:(NSUInteger)height dstBuffer:(nonnull CVPixelBufferRef)dstBuffer {
    @autoreleasepool {
        vImage_YpCbCrToARGB outInfo;
        vImage_YpCbCrPixelRange pixelRange = (vImage_YpCbCrPixelRange){ 0, 128, 255, 255, 255, 1, 255, 0 };
        vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &pixelRange, &outInfo, kvImage420Yp8_CbCr8, kvImageARGB8888, kvImageNoFlags);
        vImage_Error error = kvImageNoError;
        
        vImage_Buffer srcYp = {.data = nv12, .width = width, .height = height, .rowBytes = width};
        vImage_Buffer srcCbCr = {.data = nv12 + width * height, .width = width, .height = height / 2, .rowBytes = width};

        CVPixelBufferLockBaseAddress(dstBuffer, kCVPixelBufferLock_ReadOnly);
        vImage_Buffer dest;
        dest.data = CVPixelBufferGetBaseAddress(dstBuffer);
        dest.width = CVPixelBufferGetWidth(dstBuffer);
        dest.height = CVPixelBufferGetHeight(dstBuffer);
        dest.rowBytes = CVPixelBufferGetBytesPerRow(dstBuffer);
        
        uint8_t permuteMap[4] = {3, 2, 1, 0};
        vImageConvert_420Yp8_CbCr8ToARGB8888(&srcYp, &srcCbCr, &dest, &outInfo, permuteMap, 255, kvImageNoFlags);
        CVPixelBufferUnlockBaseAddress(dstBuffer, kCVPixelBufferLock_ReadOnly);
        return error == kvImageNoError;
    }
}

+ (nullable CVPixelBufferRef)create420Yp8_CbCr8PixelBufferWithNV12:(UInt8 *)data width:(NSInteger)width height:(NSInteger)height {

    NSDictionary *pixelAttributes = @{
            (NSString *) kCVPixelBufferIOSurfacePropertiesKey: @{},
            (NSString *) kCVPixelBufferOpenGLESCompatibilityKey: @(YES)
    };
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
            (size_t) width, (size_t) height,
            kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            (__bridge CFDictionaryRef) (pixelAttributes), &pixelBuffer);

    if (status != kCVReturnSuccess) {
        NSLog(@"Unable to create CVPixelBuffer %d", status);
        return NULL;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    uint8_t *y_src = data;
    uint8_t *y_dest = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t y_src_bytesPerRow = (size_t) width;
    size_t y_dest_bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);

    for (int i = 0; i < height; i++) {
        bzero(y_dest, y_dest_bytesPerRow);
        memcpy(y_dest, y_src, MIN(y_src_bytesPerRow, y_dest_bytesPerRow));
        y_src += y_src_bytesPerRow;
        y_dest += y_dest_bytesPerRow;
    }

    uint8_t *uv_src = data + width * height;
    uint8_t *uv_dest = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    size_t uv_src_bytesPerRow = (size_t) width;
    size_t uv_dest_bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);

    for (int i = 0; i < height / 2; i++) {
        bzero(uv_dest, uv_dest_bytesPerRow);
        memcpy(uv_dest, uv_src, MIN(uv_src_bytesPerRow, uv_dest_bytesPerRow));
        uv_src += uv_src_bytesPerRow;
        uv_dest += uv_dest_bytesPerRow;
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}
@end
