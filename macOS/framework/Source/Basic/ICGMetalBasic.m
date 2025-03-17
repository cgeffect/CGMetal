//
//  ICGMetalBasic.m
//  CGMetal
//
//  Created by Jason on 2022/5/31.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#import <CGMetalMac/ICGMetalBasic.h>

@implementation ICGMetalBasic

@synthesize inTexture;

- (void)newTextureAvailable:(nonnull CGMetalTexture *)inTexture {
    
}

- (void)mslEncodeCompleted {
    
}

- (void)newTextureInput:(nonnull CGMetalTexture *)texture {
    
}

- (void)prepareScheduled {
    
}

- (void)renderCompleted {
    
}
- (float *)getVertices {
    return (float *)_vertices;
}

- (float *)getTextureCoordinates {
    return (float *)_texCoord;
}

#pragma mark - MTLSamplerState
- (id<MTLSamplerState>)defaultSampler {
    MTLSamplerDescriptor *samplerDescriptor = [[MTLSamplerDescriptor alloc] init];
    samplerDescriptor.minFilter = MTLSamplerMinMagFilterNearest;
    samplerDescriptor.magFilter = MTLSamplerMinMagFilterNearest;
    samplerDescriptor.mipFilter = MTLSamplerMipFilterNearest;
    samplerDescriptor.maxAnisotropy = 1;
    samplerDescriptor.sAddressMode = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.tAddressMode = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.rAddressMode = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.normalizedCoordinates = YES;
    samplerDescriptor.lodMinClamp = 0;
    samplerDescriptor.lodMaxClamp = FLT_MAX;
    return [[CGMetalDevice sharedDevice].device newSamplerStateWithDescriptor:samplerDescriptor];
}

- (void)notifyNextTargetsAboutNewTexture:(nonnull CGMetalTexture *)outTexture {
}

- (void)renderToTextureWithVertices:(nonnull const float *)vertices textureCoordinates:(nonnull const float *)textureCoordinates {
}

- (void)setFragmentTexture:(nonnull id<MTLTexture>)texture index:(int)index {
}

- (void)setFragmentValue1:(simd_float1)value index:(int)index {
}

- (void)setFragmentValue2:(simd_float2)value index:(int)index {
}

- (void)setFragmentValue3:(simd_float3)value index:(int)index {
}

- (void)setFragmentValue4:(simd_float4)value index:(int)index {
}

- (void)setInValue1:(simd_float1)inValue {
}

- (void)setInValue2:(simd_float2)inValue {
}

- (void)setInValue3:(simd_float3)inValue {
}

- (void)setInValue4:(simd_float4)inValue {
}

- (void)setVertexValue1:(simd_float1)value index:(int)index {
}

- (void)setVertexValue2:(simd_float2)value index:(int)index {
}

- (void)setVertexValue3:(simd_float3)value index:(int)index {
}

- (void)setVertexValue4:(simd_float4)value index:(int)index {
}

@end
