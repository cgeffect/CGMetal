//
//  CGMetalRender.m
//  CGMetal
//
//  Created by Jason on 21/3/1.
//

#import "CGMetalRender.h"
#import "CGMetalDevice.h"

@implementation CGMetalRender {
    MTLRenderPassDescriptor *_renderPassDescriptor;
    id<MTLRenderPipelineState> _renderPipelineState;
}

- (instancetype)initWithVertexShader:(NSString *)vertexShader
                      fragmentShader:(NSString *)fragmentShader
                         pixelFormat:(MTLPixelFormat)pixelFormat //和MTLTexture格式要一样
                               index:(NSUInteger)index {
    if ((self = [super init])) {
        _renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[index];
        //https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor/setting_load_and_store_actions?language=objc
        colorAttachment.loadAction = MTLLoadActionClear;
        colorAttachment.storeAction = MTLStoreActionStore;
        colorAttachment.clearColor = MTLClearColorMake(1, 1, 1, 1);
        
        id<MTLLibrary> library = [CGMetalDevice sharedDevice].shaderLibrary;
        id<MTLFunction> vertexFunc = [library newFunctionWithName: vertexShader];
        id<MTLFunction> fragmentFunc = [library newFunctionWithName: fragmentShader];
        
        //只初始化一次
        MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
        pipelineDescriptor.label = @"Offscreen Render Pipeline";
        pipelineDescriptor.rasterSampleCount = 1;
        pipelineDescriptor.vertexFunction = vertexFunc;
        pipelineDescriptor.fragmentFunction = fragmentFunc;
//        MTLVertexDescriptor *vertexDescriptor = [MTLVertexDescriptor vertexDescriptor];
//        pipelineDescriptor.vertexDescriptor = vertexDescriptor;
        pipelineDescriptor.colorAttachments[index].pixelFormat = pixelFormat;
        
        //blend
        [pipelineDescriptor.colorAttachments[0] setBlendingEnabled:YES];
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor =  MTLBlendFactorSourceAlpha;
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
        
        if (@available(iOS 11.0, *)) {
            pipelineDescriptor.vertexBuffers[index].mutability = MTLMutabilityImmutable;
        } else {
            // Fallback on earlier versions
        }//Metal可以优化不可变顶点数据
        NSError *err;
        _renderPipelineState = [[CGMetalDevice sharedDevice].device newRenderPipelineStateWithDescriptor: pipelineDescriptor error: &err];
        NSAssert(_renderPipelineState != nil, @"Failed to create pipeline state: %@", err);
        
        //反射访问顶点和片元的参数
//        MTLRenderPipelineReflection
    }
    return self;
}

#pragma mark -
#pragma mark setter
- (void)setOutTexture:(id<MTLTexture>)texture index:(NSUInteger)index {
    _renderPassDescriptor.colorAttachments[index].texture = texture;
//    _renderPassDescriptor.renderTargetWidth = texture.width;
//    _renderPassDescriptor.renderTargetHeight = texture.height;
}

- (void)setLoadAction:(MTLLoadAction)loadAction {
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.loadAction = MTLLoadActionClear;
}

- (void)setStoreAction:(MTLStoreAction)storeAction {
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.storeAction = MTLStoreActionStore;
}

#pragma mark -
#pragma mark getter
- (MTLRenderPassDescriptor *)renderTargetDescriptor {
    return _renderPassDescriptor;
}

- (id<MTLRenderPipelineState>)renderPipelineState {
    return _renderPipelineState;
}
- (void)dealloc {
   
}

@end
