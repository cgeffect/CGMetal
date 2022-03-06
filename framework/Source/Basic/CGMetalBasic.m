//
//  CGMetalBasic.m
//  CGMetal
//
//  Created by Jason on 2021/5/13.
//  Copyright © 2021 CGMetal. All rights reserved.
//

#import "CGMetalBasic.h"

#define VertexShader @"CGMetalVertexShader"
#define FragmentShader @"CGMetalFragmentShader"

@interface CGMetalBasic ()
{
    id<MTLCommandQueue> _commandQueue;
    id<MTLBuffer> _indexBuffer;
    CGMetalRender *_mtlRender;
    //render target
    CGMetalTexture *_outTexture;
    id<MTLSamplerState> _sampleState;
    id<MTLRenderCommandEncoder> encoder;
    CGMetalRotationMode _rotationMode;
}
@end

@implementation CGMetalBasic

@synthesize inTexture = _inTexture;

- (instancetype)init
{
    self = [self initWithVertexShader:VertexShader fragmentShader:FragmentShader];
    if (self) {
       
    }
    return self;
}

- (instancetype)initWithVertexShader:(NSString *)vertexShader {
    return [self initWithVertexShader:vertexShader fragmentShader:FragmentShader];
}

- (instancetype)initWithFragmentShader:(NSString *)fragmentShader {
    return [self initWithVertexShader:VertexShader fragmentShader:fragmentShader];
}

- (instancetype)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader {
    if (vertexShader == nil) {
        NSLog(@"vertexShader is nil");
        return nil;
    }
    if (fragmentShader == nil) {
        NSLog(@"fragmentShader is nil");
        return nil;
    }
    if (!(self = [super init]))
    {
        return nil;
    }
    _rotationMode = kCGMetalNoRotation;
    _outTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
    _commandQueue = [CGMetalDevice sharedDevice].commandQueue;
    _mtlRender = [[CGMetalRender alloc] initWithVertexShader:vertexShader
                                              fragmentShader:fragmentShader
                                                 pixelFormat:MTLPixelFormatRGBA8Unorm
                                                       index:0];
    
    _indexBuffer = [[CGMetalDevice sharedDevice].device newBufferWithBytes: _indices
                                        length: sizeof(_indices)
                                       options: MTLResourceStorageModeShared];
    return self;
}

#pragma mark -
#pragma mark CGRenderInput
- (void)setInputRotation:(CGMetalRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    _rotationMode = newInputRotation;
}

- (void)newTextureAvailable:(CGMetalTexture *)inTexture {
    _inTexture = inTexture;
    [self newTextureInput:_inTexture];
    
    id<MTLTexture> texture = [_outTexture newTexture:MTLPixelFormatRGBA8Unorm size:inTexture.textureSize usege:MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget];

    //set render target texture, MTLTexture can be reuse
    [_mtlRender setOutTexture:texture
                           index:0];
    [self renderToTextureWithVertices:self.getVertices
                   textureCoordinates:self.getTextureCoordinates];
    [self notifyNextTargetsAboutNewTexture:_outTexture];
}

- (void)notifyNextTargetsAboutNewTexture:(CGMetalTexture *)outTexture {
    for (id<CGMetalInput> currentTarget in _targets) {
        [currentTarget newTextureAvailable:outTexture];
    }
}

- (void)stopOutput {
    for (id<CGMetalInput> currentTarget in _targets) {
        [currentTarget stopOutput];
    }
}

#pragma mark -
#pragma mark Render
- (void)renderToTextureWithVertices:(const float *)vertices textureCoordinates:(const float *)textureCoordinates {
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"CGMetalFilter Command Buffer";
    encoder = [commandBuffer renderCommandEncoderWithDescriptor: _mtlRender.renderTargetDescriptor];
    
    encoder.label = @"CGMetalFilter Command Encoder";
    
    [encoder setViewport: (MTLViewport) {
        .originX = 0,
        .originY = 0,
        .width = _inTexture.textureSize.width,
        .height = _inTexture.textureSize.height,
        .znear = 0,
        .zfar = 1
    }];
    [encoder setRenderPipelineState: _mtlRender.renderPipelineState];
    
    // set vertex value
    [encoder setVertexBytes: _vertices
                     length: sizeof(_vertices)
                    atIndex: 0];

    [encoder setVertexBytes: _texCoord
                     length: sizeof(_texCoord)
                    atIndex: 1];
   
    // set fragment value
    [encoder setFragmentTexture: _inTexture.texture
                        atIndex: 0];
    // set texture sample param in cpu or set texture sample param in shader
    _sampleState = [self defaultSampler];
    [encoder setFragmentSamplerState:_sampleState
                             atIndex:0];
        
    [self mslEncodeCompleted];
    //draw
    [encoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle
                        indexCount: 6
                         indexType: MTLIndexTypeUInt32
                       indexBuffer: _indexBuffer
                 indexBufferOffset: 0];
    
    [encoder endEncoding];
    [commandBuffer addScheduledHandler:^(id<MTLCommandBuffer> cmdBuffer) {
        [self prepareScheduled];
    }];
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> cmdBuffer) {
        [self renderCompleted];
    }];
    [commandBuffer commit];
    if (_isWaitUntilScheduled) {
        [commandBuffer waitUntilScheduled];
        _isWaitUntilScheduled = NO;
    }
    if (_isWaitUntilCompleted) {
        [commandBuffer waitUntilCompleted];
        _isWaitUntilCompleted = NO;
    }
}

- (void)_waitUntilScheduled {
    _isWaitUntilScheduled = YES;
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget _waitUntilScheduled];
    }
}

- (void)_waitUntilCompleted {
    _isWaitUntilCompleted = YES;
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget _waitUntilCompleted];
    }
}

#pragma mark - getter
- (CGSize)textureSize {
    return _outputTexture.textureSize;
}

- (float *)getVertices {
    return (float *)_vertices;
}

- (float *)getTextureCoordinates {
    return (float *)_texCoord;
}
#pragma mark -
- (void)mslEncodeCompleted {
    
}
- (void)newTextureInput:(CGMetalTexture *)texture {
    
}
- (void)prepareScheduled {
    
}
- (void)renderCompleted {
    
}

#pragma mark -
//set value
- (void)setInValue1:(vec_float1)inValue {
    _vec_float1 = inValue;
}
- (void)setInValue2:(vec_float2)inValue {
    _vec_float2 = inValue;
}
- (void)setInValue3:(vec_float3)inValue {
    _vec_float3 = inValue;
}
- (void)setInValue4:(vec_float4)inValue {
    _vec_float4 = inValue;
}
//set value into Vertex Shader
- (void)setVertexValue1:(vec_float1)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
- (void)setVertexValue2:(vec_float2)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
- (void)setVertexValue3:(vec_float3)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
- (void)setVertexValue4:(vec_float4)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
//set value into Fragment Shader
- (void)setFragmentValue1:(vec_float1)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}
- (void)setFragmentValue2:(vec_float2)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}
- (void)setFragmentValue3:(vec_float3)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}
- (void)setFragmentValue4:(vec_float4)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}

- (void)setFragmentTexture:(id<MTLTexture>)texture index:(int)index {
    [encoder setFragmentTexture:texture atIndex:index];
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

- (id<MTLRenderCommandEncoder>)commandEncoder {
    return encoder;
}
- (void)dealloc
{
    
}

@end
