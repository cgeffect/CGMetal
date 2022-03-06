//
//  CGMetalTranslation.m
//  CGMetalOS
//
//  Created by Jason on 2021/12/30.
//

#import "CGMetalTranslation.h"
#define kCGMetalTranslation @"kCGMetalTranslation"

@implementation CGMetalTranslation

float transMatrix[16] = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
};

float* translationMatrix(float matrix[16], float x, float y, float z) {
    matrix[12] = x;
    matrix[13] = y;
    matrix[14] = z;
    return matrix;
}

- (instancetype)init {
    self = [super initWithVertexShader:kCGMetalTranslation];
    if (self) {
//        _vec_float1.x = 1;
    }
    
    return self;
}

- (void)setInValue1:(vec_float1)inValue {
    _vec_float1.x = inValue.x;
}

- (void)mslEncodeCompleted {
    float *mat = translationMatrix(transMatrix, _vec_float1.x, _vec_float1.x, 1);
    [self.commandEncoder setVertexBytes: mat length: sizeof(transMatrix) atIndex: 2];
}

@end
