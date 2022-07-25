//
//  CGMetalPixelBufferSurfaceOutput.m
//  CGMetal
//
//  Created by Jason on 2021/11/30.
//

#import "CGMetalPixelBufferSurfaceOutput.h"
#import "CGMetalDevice.h"
#import "CGMetalOutput.h"
#import "CGMetalRender.h"

#define VertexShader @"CGMetalPixelBufferSurfaceOutputVertexShader"
#define FragmentShader @"CGMetalPixelBufferSurfaceOutputFragmentShader"
// The maximum number of frames in flight.
static const NSUInteger MaxFramesInFlight = 3;

@interface CGMetalPixelBufferSurfaceOutput ()
{
    int _bufferWidth, _bufferHeight;
    CVMetalTextureCacheRef _renderTextureCache;
    CVPixelBufferPoolRef _pixelBufferPool;
    CVPixelBufferRef _dstPixelBuffer;
    CGMetalTexture *_outputTexture;
    
    id<MTLCommandQueue> _commandQueue;
    id<MTLBuffer> _indexBuffer;
    CGMetalRender *_mtlRender;
    int _colorAttachmentIndex;
    // A semaphore used to ensure that buffers read by the GPU are not simultaneously written by the CPU.
    dispatch_semaphore_t _inFlightSemaphore;
}
@end

@implementation CGMetalPixelBufferSurfaceOutput
@synthesize inTexture = _inTexture;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _inFlightSemaphore = dispatch_semaphore_create(MaxFramesInFlight);
        _colorAttachmentIndex = 0;
        _commandQueue = [CGMetalDevice sharedDevice].commandQueue;
        
        _mtlRender = [[CGMetalRender alloc] initWithVertexShader:VertexShader
                                                  fragmentShader:FragmentShader
                                                     pixelFormat:MTLPixelFormatBGRA8Unorm
                                                           index:_colorAttachmentIndex];
        //EBO
        _indexBuffer = [[CGMetalDevice sharedDevice].device newBufferWithBytes: _indices
                                            length: sizeof(_indices)
                                           options: MTLResourceStorageModeShared];
        
        [self _preparRender];
    }
    return self;
}

- (void)_preparRender {
    if ([CGMetalDevice supportsFastTextureUpload] == NO) {
        NSAssert(NO, @"iPhone simulator not support fast texture upload");
    }
    CVReturn err = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, [CGMetalDevice sharedDevice].device, NULL, &_renderTextureCache);
    if (err) {
        NSLog(@"CGMetalPixelBufferInput Error at CVOpenGLESTextureCacheCreate %d", err);
    }
}

- (void)newTextureAvailable:(nonnull CGMetalTexture *)inTexture {
    _inTexture = inTexture;
    _bufferWidth = (int)_inTexture.textureSize.width;
    _bufferHeight = (int)_inTexture.textureSize.height;
    id<MTLTexture> outTexture = [self newTextureBindPixelBuffer:_bufferWidth height:_bufferHeight];
    self->_outputTexture = [[CGMetalTexture alloc] initWithTexture:outTexture size:CGSizeMake(_bufferWidth, _bufferHeight)];
    
    [self drawTextureToPixelbuffer];
    
}

#pragma mark - private
- (void)drawTextureToPixelbuffer {
    // Wait to ensure only `MaxFramesInFlight` number of frames are getting processed
    // by any stage in the Metal pipeline (CPU, GPU, Metal, Drivers, etc.).
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    [_mtlRender setOutTexture:_outputTexture.texture index:_colorAttachmentIndex];
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: _mtlRender.renderTargetDescriptor];
    [encoder setViewport: (MTLViewport) {
        .originX = 0,
        .originY = 0,
        .width = _bufferWidth,
        .height = _bufferHeight,
        .znear = 0,
        .zfar = 1
    }];
    [encoder setRenderPipelineState: _mtlRender.renderPipelineState];
    [encoder setVertexBytes: _vertices
                     length: sizeof(_vertices)
                    atIndex: 0];
    [encoder setVertexBytes: _texCoord
                     length: sizeof(_texCoord)
                    atIndex: 1];
    [encoder setFragmentTexture: _inTexture.texture
                        atIndex: 0];
    [encoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle
                        indexCount: 6
                         indexType: MTLIndexTypeUInt32
                       indexBuffer: _indexBuffer
                 indexBufferOffset: 0];
    [encoder endEncoding];
    
    [commandBuffer addScheduledHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
        
    }];

    __block dispatch_semaphore_t block_semaphore = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
        [self.delegate onRenderCompleted:self receivedPixelBufferFromTexture:self->_dstPixelBuffer];
        [self destroyPixelBuffer];
        dispatch_semaphore_signal(block_semaphore);
    }];
    [commandBuffer commit];
//    [commandBuffer waitUntilScheduled];
    [commandBuffer waitUntilCompleted];
}

- (id<MTLTexture>)newTextureBindPixelBuffer:(NSInteger)widht height:(NSInteger)height {
    if (!_renderTextureCache) {
        NSLog(@"CGPixelBufferToTexture CVOpenGLESTextureCacheRef nil");
        return 0;
    }
    
    if (_pixelBufferPool == NULL) {
        _pixelBufferPool = [self createPixelBufferPool:widht height:height];
    }
    CVReturn err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _pixelBufferPool, &_dstPixelBuffer);
    if (err || _dstPixelBuffer == NULL) {
        NSLog(@"CVPixelBufferPoolCreatePixelBuffer error: %d", err);
        return NULL;
    }
    CVBufferSetAttachment(_dstPixelBuffer,
                          kCVImageBufferColorPrimariesKey,
                          kCVImageBufferColorPrimaries_ITU_R_709_2,
                          kCVAttachmentMode_ShouldPropagate);
    
    CVBufferSetAttachment(_dstPixelBuffer,
                          kCVImageBufferYCbCrMatrixKey,
                          kCVImageBufferYCbCrMatrix_ITU_R_601_4,
                          kCVAttachmentMode_ShouldPropagate);
    
    CVBufferSetAttachment(_dstPixelBuffer,
                          kCVImageBufferTransferFunctionKey,
                          kCVImageBufferTransferFunction_ITU_R_709_2,
                          kCVAttachmentMode_ShouldPropagate);
    
    id<MTLTexture> texture;
    CVMetalTextureRef outTexture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                _renderTextureCache,
                                                                _dstPixelBuffer,
                                                                NULL,
                                                                MTLPixelFormatBGRA8Unorm,
                                                                _bufferWidth,
                                                                _bufferHeight,
                                                                0,
                                                                &outTexture);
    if(status != kCVReturnSuccess) {
        NSLog(@"CGMetalPixelBufferSurfaceOutput Error at CVMetalTextureCacheCreateTextureFromImage %d", status);
        [self destroyPixelBuffer];
        CFRelease(outTexture);
        return 0;
    }
    texture = CVMetalTextureGetTexture(outTexture);
    CFRelease(outTexture);
    return texture;
}

- (void)destroyPixelBuffer {
    if (_dstPixelBuffer) {
        CVPixelBufferRelease(_dstPixelBuffer);
        _dstPixelBuffer = NULL;
    }
}

- (CVPixelBufferPoolRef)createPixelBufferPool:(NSInteger)width height:(NSInteger)height {
    CVPixelBufferPoolRef outputPool = NULL;
    NSDictionary *sourcePixelBufferOptions = @{(id) kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
            (id) kCVPixelBufferWidthKey: @(width),
            (id) kCVPixelBufferHeightKey: @(height),
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            (id) kCVPixelFormatOpenGLESCompatibility: @(YES),//神奇问题, PixelBufferPool里的pixelbuffer一直无法释放, 初步猜测是IOSurface复用除了问题, 把这个注释掉, 运行一次, 又打开就好了
//            (id) kCVPixelBufferOpenGLESCompatibilityKey: @(YES),//和kCVPixelFormatOpenGLESCompatibility区别是啥
#else
#endif
            (id)kCVPixelBufferPixelFormatTypeKey:@(YES),
            (id) kCVPixelBufferMetalCompatibilityKey: @(YES),
            (id) kCVPixelBufferIOSurfacePropertiesKey: @{ /*empty dictionary*/ }};
//    NSDictionary *pixelBufferPoolOptions = @{ (texId)kCVPixelBufferPoolMinimumBufferCountKey : @(0) };
    CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef) sourcePixelBufferOptions, &outputPool);
    return outputPool;
}

- (void)dealloc {
    [self destroyPixelBuffer];
    if (_pixelBufferPool) {
        CFRelease(_pixelBufferPool);
        _pixelBufferPool = NULL;
    }
    if (_renderTextureCache) {
        CFRelease(_renderTextureCache);
        _renderTextureCache = NULL;
    }
}

@end
