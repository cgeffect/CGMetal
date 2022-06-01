//
//  CGMetalTwoBasic.m
//  CGMetal
//
//  Created by Jason on 2021/12/28.
//

#import "CGMetalTwoBasic.h"
@import CoreGraphics;

#define VertexShader @"CGMetalVertexShader"
#define FragmentShader @"CGMetalFragmentTwoShader"

@interface CGMetalTwoBasic ()
{
    id<MTLCommandQueue> _commandQueue;
    id<MTLBuffer> _indexBuffer;
    CGMetalRender *_mtlRender;
    //render target
    CGMetalTexture *_outTexture;
    id<MTLSamplerState> _sampleState;
    id<MTLRenderCommandEncoder> encoder;
    CGMetalRotationMode _rotationMode;
    CGSize _renderFBOSize;
    CGMetalTexture *_inTexture1;
}
@end

@implementation CGMetalTwoBasic

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

//进入到这里的tex是已经在外面把fbo设置成同样尺寸之后
- (void)newTextureAvailable:(CGMetalTexture *)inTexture {
    if (inTexture.texIndex == 0) {
        _inTexture = inTexture;
    } else if (inTexture.texIndex == 1) {
        _inTexture1 = inTexture;
    }
    [self newTextureInput:inTexture];
    
    if (_inTexture1 == nil || _inTexture1 == nil) {
        return;
    }
    id<MTLTexture> texture = [_outTexture newTexture:MTLPixelFormatRGBA8Unorm size:inTexture.textureSize usege:MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget];

    //set render target texture, MTLTexture can be reuse
    [_mtlRender setOutTexture:texture
                           index:0];
    [self renderToTextureWithVertices:[self getVertices]
                   textureCoordinates:[self getTextureCoordinates]];
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
    
    [encoder setFragmentTexture: _inTexture1.texture
                        atIndex: 1];
    
    // set texture sample param in cpu or set texture sample param in shader
//    _sampleState = [self defaultSampler];
//    [encoder setFragmentSamplerState:_sampleState
//                             atIndex:0];
        
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

#pragma mark -
//set value
- (void)setInValue1:(simd_float1)inValue {
    _simd_float1 = inValue;
}
- (void)setInValue2:(simd_float2)inValue {
    _simd_float2 = inValue;
}
- (void)setInValue3:(simd_float3)inValue {
    _simd_float3 = inValue;
}
- (void)setInValue4:(simd_float4)inValue {
    _simd_float4 = inValue;
}
//set value into Vertex Shader
- (void)setVertexValue1:(simd_float1)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
- (void)setVertexValue2:(simd_float2)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
- (void)setVertexValue3:(simd_float3)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
- (void)setVertexValue4:(simd_float4)value index:(int)index {
    [encoder setVertexBytes:&value length:sizeof(float) atIndex:index];
}
//set value into Fragment Shader
- (void)setFragmentValue1:(simd_float1)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}
- (void)setFragmentValue2:(simd_float2)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}
- (void)setFragmentValue3:(simd_float3)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}
- (void)setFragmentValue4:(simd_float4)value index:(int)index {
    [encoder setFragmentBytes: &value length: sizeof(float) atIndex: index];
}

- (void)setFragmentTexture:(id<MTLTexture>)texture index:(int)index {
    [encoder setFragmentTexture:texture atIndex:index];
}

- (id<MTLRenderCommandEncoder>)commandEncoder {
    return encoder;
}
//
//- (void)setDataSize:(NSArray<NSValue *> *)sizeList {
//    CGSize maxSize = CGSizeZero;
//    float maxAspect = 0;
//    for (NSValue *value in sizeList) {
//        CGSize dataSize = value.CGSizeValue;
//        float aspect = dataSize.height / dataSize.width;
//        if (aspect > maxAspect) {
//            maxSize = dataSize;
//            maxAspect = aspect;
//        }
//    }
//    _renderFBOSize = maxSize;
//}
//
//- (BOOL)isNeedCrop:(CGSize)size {
//    if (CGSizeEqualToSize(size, _renderFBOSize)) {
//        return NO;
//    }
//    return YES;
//}

- (void)dealloc {
    
}

@end
