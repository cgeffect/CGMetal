//
//  CGMetalProjection.m
//  CGMetalOS
//
//  Created by Jason on 2021/12/30.
//  Copyright © 2021 com.metal.Jason. All rights reserved.
//

#import "CGMetalProjection.h"

#define kCGMetalProjection @"kCGMetalProjection"

@implementation CGMetalProjection

float projectMatrix[16] = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
};

float* projectionMatrix(float matrix[16], float x, float y, float z) {
    matrix[2] = x;
    matrix[4] = y;
    return matrix;
}

- (instancetype)init {
    self = [super initWithVertexShader:kCGMetalProjection];
    if (self) {

    }
    
    return self;
}

- (void)setInValue1:(vec_float1)inValue {
    _vec_float1.x = inValue.x;
}

- (void)mslEncodeCompleted {
    //正数向正方向拉伸
    //负数向负方向拉伸
    //设置x的值会导致x轴左半部分不显示
    float *mat = projectionMatrix(projectMatrix, 0, _vec_float1.x * 2, 1);
    [self.commandEncoder setVertexBytes: mat length: sizeof(projectMatrix) atIndex: 2];
}

@end
