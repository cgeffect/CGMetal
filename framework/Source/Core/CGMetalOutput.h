//
//  CGMetalOutput.h
//  CGMetal
//
//  Created by Jason on 21/3/3.
//

#import "CGMetalDevice.h"
#import "CGMetalInput.h"
#import <simd/simd.h>

@import Metal;

//顶点坐标
static const float _vertices[] = {
    -1,  1, 0, 1, // 左上角
     1,  1, 0, 1, // 右上角
    -1, -1, 0, 1, // 左下角
     1, -1, 0, 1, // 右下角
};

//Metal 纹理坐标使用UIKit坐标系
static const float _texCoord[] = {
    0, 0, // 左上角
    1, 0, // 右上角
    0, 1, // 左下角
    1, 1, // 右下角
};

static const float _texCoordFlipX[] = {
    0, 1, // 左下角
    1, 1, // 右下角
    0, 0, // 左上角
    1, 0, // 右上角
};

static const UInt32 _indices[] = {
    0, 1, 2,
    1, 3, 2
};

// BT.601, which is the standard for SDTV.
static const matrix_float3x3 kColorConversionMatrix601Default = {{
    {1.164,     1.164,      1.164},
    {0.0,       -0.392,     2.017},
    {1.596,     -0.813,     0.0}
}};

/*矩阵形式！！！
 1.0 0.0 1.4
 [1.0 -0.343 -0.711 ]
 1.0 1.765 0.0
 */
//ITU BT.601 Full Range
static const matrix_float3x3 kColorConversionMatrix601FullRangeDefault = {{
    {1.0,       1.0,        1.0},
    {0.0,       -0.34413,   1.772},
    {1.402,     -0.71414,   0.0}
}};

// BT.709, which is the standard for HDTV.
static const matrix_float3x3 kColorConversionMatrix709Default = {{
    {1.164,     1.164,      1.164},
    {0.0,       -0.213,     2.112},
    {1.793,     -0.533,     0.0}
}};

// BT.709 Full Range.
static const matrix_float3x3 kColorConversionMatrix709FullRangeDefault = {{
    {1.0,       1.0,        1.0},
    {0.0,       -.18732,    1.8556},
    {1.57481,   -.46813,    0.0}
}};

// Blur weight matrix.
static const matrix_float3x3 kBlurWeightMatrixDefault = {{
    {0.0625,     0.125,      0.0625},
    {0.125,      0.25,       0.125},
    {0.0625,     0.125,      0.0625}
}};

@interface CGMetalOutput : NSObject
{
@protected
    CGMetalTexture *_outputTexture;
@protected
    NSMutableArray <id<CGMetalInput>>*_targets;
@protected
    BOOL _isWaitUntilCompleted;
@protected
    BOOL _isWaitUntilScheduled;
}

@property(nonatomic, strong, readonly)CGMetalTexture *outTexture;

- (void)addTarget:(id<CGMetalInput>)newTarget;

- (void)removeTarget:(id<CGMetalInput>)targetToRemove;

- (void)removeAllTargets;

- (NSArray*)targets;

- (void)requestRender;

- (void)waitUntilCompleted;

- (void)waitUntilScheduled;

@end
