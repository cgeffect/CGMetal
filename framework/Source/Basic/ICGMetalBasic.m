//
//  ICGMetalBasic.m
//  CGMetal
//
//  Created by Jason on 2022/5/31.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#import "ICGMetalBasic.h"

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
@end
