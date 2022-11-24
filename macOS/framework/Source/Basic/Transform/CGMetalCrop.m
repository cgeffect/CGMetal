//
//  CGMetalCrop.m
//  VGAMac
//
//  Created by Jason on 2022/1/2.
//

#import "CGMetalCrop.h"
#define kCGMetalScaleAlphaFragmentShader @"kCGMetalScaleAlphaFragmentShader"

@implementation CGMetalCrop
{
    float cropTextureCoordinates[8];

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cropRegion = CGRectMake(0.0, 0.0, 1.0, 1.0);
    }
    return self;
}

- (float *)getTextureCoordinates {
    return cropTextureCoordinates;
}

#pragma mark -
#pragma mark Accessors
- (void)setCropRegion:(CGRect)newValue {
    NSParameterAssert(newValue.origin.x >= 0 && newValue.origin.x <= 1 &&
                      newValue.origin.y >= 0 && newValue.origin.y <= 1 &&
                      newValue.size.width >= 0 && newValue.size.width <= 1 &&
                      newValue.size.height >= 0 && newValue.size.height <= 1);

    _cropRegion = newValue;
    [self calculateCropTextureCoordinates];
}

- (void)calculateCropTextureCoordinates {
    CGFloat minX = _cropRegion.origin.x;
    CGFloat minY = _cropRegion.origin.y;
    CGFloat maxX = CGRectGetMaxX(_cropRegion);
    CGFloat maxY = CGRectGetMaxY(_cropRegion);
    
    cropTextureCoordinates[0] = minX; // 0,0
    cropTextureCoordinates[1] = minY;
    
    cropTextureCoordinates[2] = maxX; // 1,0
    cropTextureCoordinates[3] = minY;

    cropTextureCoordinates[4] = minX; // 0,1
    cropTextureCoordinates[5] = maxY;

    cropTextureCoordinates[6] = maxX; // 1,1
    cropTextureCoordinates[7] = maxY;
}

@end
