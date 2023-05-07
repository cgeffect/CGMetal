//
//  CGMetalRotate.m
//  CGMetal
//
//  Created by Jason on 2021/12/30.
//  Copyright © 2021 com.metal.Jason. All rights reserved.
//

#import "CGMetalRotate.h"
#import "MetalMatrix.h"
#import "AAPLMathUtilities.h"

#define kCGMetalRotate @"kCGMetalRotate"

struct Rotate {
    float x;
    float y;
    float z;
};

@implementation CGMetalRotate
{
    struct Rotate _rotate;
    CGMetalTexture *_inTex;
    CGSize _fboSize;
    float _angle;
}
//float rotMatrix[16] = {
//    1, 0, 0, 0,
//    0, 1, 0, 0,
//    0, 0, 1, 0,
//    0, 0, 0, 1
//};
//
//float* rotateMatrix(float matrix[16], struct Rotate rot) {
//    matrix[0] = cos(rot.y) * cos(rot.z);
//    matrix[4] = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z);
//    matrix[8] = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z);
//    matrix[1] = cos(rot.y) * sin(rot.z);
//    matrix[5] = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z);
//    matrix[9] = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y) * sin(rot.z);
//    matrix[2] = -sin(rot.y);
//    matrix[6] = cos(rot.y) * sin(rot.x);
//    matrix[10] = cos(rot.x) * cos(rot.y);
//    matrix[15] = 1.0;
//    return matrix;
//};
//
//float* rotateMatrixX(float matrix[16], struct Rotate rot) {
//    matrix[5] = cos(rot.x);
//    matrix[6] = sin(rot.x);
//    matrix[9] = -sin(rot.x);
//    matrix[10] = cos(rot.x);
//    return matrix;
//};
//
//float* rotateMatrixZ(float matrix[16], struct Rotate rot) {
//    matrix[0] = cos(rot.x);
//    matrix[1] = sin(rot.x);
//    matrix[4] = -sin(rot.x);
//    matrix[5] = cos(rot.x);
//    return matrix;
//};

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

- (void)newTextureAvailable:(CGMetalTexture *)inTexture {
    _inTex = inTexture;
    _angle = _simd_float1 * 360;
    if (_angle <= 90) {
        _angle = 90;
    }
    if (_angle == 90 || _angle == 270) {
        _fboSize = CGSizeMake(inTexture.textureSize.height, inTexture.textureSize.width);
    } else {
        _fboSize = CGSizeMake(inTexture.textureSize.width, inTexture.textureSize.height);
    }
    
    _fboSize = CGSizeMake(inTexture.textureSize.width, inTexture.textureSize.height);

    [super newTextureAvailable:inTexture];
}

- (void)mslEncodeCompleted {
    
    float canvasWidth = _inTex.textureSize.width;
    float canvasHeight = _inTex.textureSize.height;
    
    float aspect_ratio = canvasHeight / canvasWidth;
    simd_float4x4 projectionMatrix = [MetalMatrix mm_orthoWithLeft:-1
                                                      withRight:1
                                                     withBottom:-aspect_ratio
                                                        withTop:aspect_ratio
                                                       withNear:0.1
                                                        withFar:0];
    float radians = _angle * M_PI / 180.0;
    matrix_float4x4 rotationMatrix = matrix4x4_rotation(radians, 0, 0, 1);
    matrix_float4x4 translationMatrix = matrix4x4_translation(0, 0, 0);
    matrix_float4x4 scaleMatrix = matrix4x4_scale(1, aspect_ratio * 1, 1);

    matrix_float4x4 modelMatrix = matrix_multiply(translationMatrix, rotationMatrix);
    modelMatrix = matrix_multiply(modelMatrix, scaleMatrix);
    modelMatrix = matrix_multiply(projectionMatrix, modelMatrix);
    [self.commandEncoder setVertexBytes: &modelMatrix length: sizeof(modelMatrix) atIndex: 2];
}

- (CGSize)getRenderPassSize {
    return CGSizeMake(_fboSize.width * 2, _fboSize.height * 2);
}
@end
