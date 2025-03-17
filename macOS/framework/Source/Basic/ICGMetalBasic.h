//
//  ICGMetalBasic.h
//  CGMetal
//
//  Created by Jason on 2022/5/31.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#import <simd/simd.h>
#import <CGMetalMac/CGMetalInput.h>
#import <CGMetalMac/CGMetalOutput.h>
#import <CGMetalMac/CGMetalRender.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICGMetalBasic : CGMetalOutput<CGMetalInput>
{
@protected
    simd_float1 _simd_float1;
    simd_float2 _simd_float2;
    simd_float3 _simd_float3;
    simd_float4 _simd_float4;
}

#pragma mark -
#pragma mark Init
- (instancetype)initWithVertexShader:(NSString *)vertexShader
                      fragmentShader:(NSString *)fragmentShader;

- (instancetype)initWithVertexShader:(NSString *)vertexShader;

- (instancetype)initWithFragmentShader:(NSString *)fragmentShader;

@property(nonatomic, assign, readonly)CGSize textureSize;

@property(nonatomic, strong) id<MTLRenderCommandEncoder> commandEncoder;

#pragma mark -
#pragma mark Render
//render with Vertex Texture coordinates
- (void)renderToTextureWithVertices:(const float *)vertices
                 textureCoordinates:(const float *)textureCoordinates;

//notify next filter to render
- (void)notifyNextTargetsAboutNewTexture:(CGMetalTexture *)outTexture;

#pragma mark -
#pragma mark setter
//set value
- (void)setInValue1:(simd_float1)inValue;
- (void)setInValue2:(simd_float2)inValue;
- (void)setInValue3:(simd_float3)inValue;
- (void)setInValue4:(simd_float4)inValue;
//set value into Vertex Shader
- (void)setVertexValue1:(simd_float1)value index:(int)index;
- (void)setVertexValue2:(simd_float2)value index:(int)index;
- (void)setVertexValue3:(simd_float3)value index:(int)index;
- (void)setVertexValue4:(simd_float4)value index:(int)index;
//set value into Fragment Shader
- (void)setFragmentValue1:(simd_float1)value index:(int)index;
- (void)setFragmentValue2:(simd_float2)value index:(int)index;
- (void)setFragmentValue3:(simd_float3)value index:(int)index;
- (void)setFragmentValue4:(simd_float4)value index:(int)index;
//Texture
- (void)setFragmentTexture:(nonnull id <MTLTexture>)texture index:(int)index;

#pragma mark -
#pragma mark getter
- (float *)getVertices;
- (float *)getTextureCoordinates;
@end

NS_ASSUME_NONNULL_END
