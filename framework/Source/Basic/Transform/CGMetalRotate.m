//
//  CGMetalRotate.m
//  CGMetalOS
//
//  Created by Jason on 2021/12/30.
//  Copyright © 2021 com.metal.Jason. All rights reserved.
//

#import "CGMetalRotate.h"

#define kCGMetalRotate @"kCGMetalRotate"

struct Rotate {
    float x;
    float y;
    float z;
};

@implementation CGMetalRotate
{
    struct Rotate _rotate;
}
float rotMatrix[16] = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
};

float* rotateMatrix(float matrix[16], struct Rotate rot) {
    matrix[0] = cos(rot.y) * cos(rot.z);
    matrix[4] = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z);
    matrix[8] = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z);
    matrix[1] = cos(rot.y) * sin(rot.z);
    matrix[5] = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z);
    matrix[9] = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y) * sin(rot.z);
    matrix[2] = -sin(rot.y);
    matrix[6] = cos(rot.y) * sin(rot.x);
    matrix[10] = cos(rot.x) * cos(rot.y);
    matrix[15] = 1.0;
    return matrix;
};

float* rotateMatrixX(float matrix[16], struct Rotate rot) {
    matrix[5] = cos(rot.x);
    matrix[6] = sin(rot.x);
    matrix[9] = -sin(rot.x);
    matrix[10] = cos(rot.x);
    return matrix;
};

float* rotateMatrixZ(float matrix[16], struct Rotate rot) {
    matrix[0] = cos(rot.x);
    matrix[1] = sin(rot.x);
    matrix[4] = -sin(rot.x);
    matrix[5] = cos(rot.x);
    return matrix;
};

- (instancetype)init {
    self = [super initWithVertexShader:kCGMetalRotate];
    if (self) {
//        _simd_float1 = 1;
    }
    return self;
}

- (void)setInValue1:(simd_float1)inValue {
    _simd_float1 = inValue;
}

- (void)mslEncodeCompleted {
//    _rotate.x = 0;
//    _rotate.y = 0;
//    _rotate.z = _simd_float1;
//    float *mat = rotateMatrix(rotMatrix, _rotate);

    float radX = _simd_float1 * 360 * M_PI / 180.0;
    _rotate.x = radX;
    float *matX = rotateMatrixZ(rotMatrix, _rotate);
    [self.commandEncoder setVertexBytes: matX length: sizeof(rotMatrix) atIndex: 2];
}
@end
