//
//  CGMetalPixelBufferInput.m
//  CGMetal
//
//  Created by Jason on 2021/6/1.
//

#import "CGMetalPixelBufferInput.h"
#import "CGMetalDevice.h"
#import "CGMetalRender.h"

#define VertexShader @"kCGMetalPixNV12VertexShader"
#define FragmentShader @"kCGMetalPixNV12FragmentShader"

@interface CGMetalPixelBufferInput ()
{
    int _bufferWidth, _bufferHeight;
    CVMetalTextureCacheRef _renderTextureCache;
    id<MTLBuffer> _indexBuffer;
    CGMetalRender *_mtlRender;
    
    id<MTLTexture> _textureY;
    id<MTLTexture> _textureUV;
    
    CGPixelFormat _pixelFormat;
}
@end

@implementation CGMetalPixelBufferInput

- (instancetype)initWithFormat:(CGPixelFormat)pixelFormat {
    self = [super init];
    if (self) {
        _pixelFormat = pixelFormat;
        if (_pixelFormat == CGPixelFormatNV12) {
            _mtlRender = [[CGMetalRender alloc] initWithVertexShader:VertexShader
                                                      fragmentShader:FragmentShader
                                                         pixelFormat:MTLPixelFormatRGBA8Unorm
                                                               index:0];
            
            _indexBuffer = [[CGMetalDevice sharedDevice].device newBufferWithBytes: _indices
                                                length: sizeof(_indices)
                                               options: MTLResourceStorageModeShared];
            self->_outputTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
        }
    }
    return self;
}

- (void)uploadPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CGPixelFormat format = _pixelFormat;
    if ([CGMetalDevice supportsFastTextureUpload] == NO) {
        NSAssert(NO, @"iPhone simulator not support fast texture upload");
    }
    _bufferWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    _bufferHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    CVReturn err = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, [CGMetalDevice sharedDevice].device, NULL, &_renderTextureCache);
    if (err) {
        NSLog(@"CGMetalPixelBufferInput Error at CVOpenGLESTextureCacheCreate %d", err);
    }
    if (format == CGPixelFormatBGRA) {
        id<MTLTexture> texture = [self newTextureWithPixelBufferBGRA:pixelBuffer];
        self->_outputTexture = [[CGMetalTexture alloc] initWithTexture:texture size:CGSizeMake(self->_bufferWidth, self->_bufferHeight)];
    } else if (format == CGPixelFormatNV12) {
        [self->_outputTexture newTexture:MTLPixelFormatRGBA8Unorm size:CGSizeMake(_bufferWidth, _bufferHeight) usege:MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget];
        [self newTextureWithPixelBuffer420Yp8_CbCr8:pixelBuffer];
        [self drawNV12ToFBO];
    }
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CGPixelFormat format = _pixelFormat;
    _bufferWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    _bufferHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    if (format == CGPixelFormatBGRA) {
        id<MTLTexture> texId = [self newTextureWithPixelBufferBGRA:pixelBuffer];
        [self->_outputTexture updateWithTexture:texId
                                           size:CGSizeMake(self->_bufferWidth, self->_bufferHeight)];
    } else if (format == CGPixelFormatNV12) {
        [self newTextureWithPixelBuffer420Yp8_CbCr8:pixelBuffer];
        [self drawNV12ToFBO];
    }
}

- (id<MTLTexture>)newTextureWithPixelBufferBGRA:(CVPixelBufferRef)pixelBuffer {
    if (!_renderTextureCache) {
        NSLog(@"CGPixelBufferToTexture CVOpenGLESTextureCacheRef nil");
        return 0;
    }
    id<MTLTexture> texture;
    CVMetalTextureRef outTexture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                _renderTextureCache,
                                                                pixelBuffer,
                                                                NULL,
                                                                MTLPixelFormatBGRA8Unorm,
                                                                _bufferWidth,
                                                                _bufferHeight,
                                                                0,
                                                                &outTexture);
    if(status == kCVReturnSuccess) {
        texture = CVMetalTextureGetTexture(outTexture);
        CFRelease(outTexture);
        return texture;
    } else {
        NSLog(@"CGMetalPixelBufferInput Error at CVMetalTextureCacheCreateTextureFromImage %d", status);
        return 0;
    }
}

- (void)newTextureWithPixelBuffer420Yp8_CbCr8:(CVPixelBufferRef)pixelBuffer {
    if (!_renderTextureCache) {
        NSLog(@"CGMetalPixelBufferInput CVOpenGLESTextureCacheRef nil");
    }
   
    //textureY
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        MTLPixelFormat pixelFormat = MTLPixelFormatR8Unorm;
        CVMetalTextureRef outTexture = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                    _renderTextureCache,
                                                                    pixelBuffer,
                                                                    NULL,
                                                                    pixelFormat,
                                                                    width,
                                                                    height,
                                                                    0,
                                                                    &outTexture);
        
        if(status == kCVReturnSuccess) {
            _textureY = CVMetalTextureGetTexture(outTexture);
            CFRelease(outTexture);
        } else {
            NSLog(@"CGMetalPixelBufferInput Error at CVMetalTextureCacheCreateTextureFromImage %d", status);
            return;
        }
    }
    
    //textureUV
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        MTLPixelFormat pixelFormat = MTLPixelFormatRG8Unorm;
        CVMetalTextureRef outTexture = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                    _renderTextureCache,
                                                                    pixelBuffer,
                                                                    NULL,
                                                                    pixelFormat,
                                                                    width,
                                                                    height,
                                                                    1,
                                                                    &outTexture);
        if(status == kCVReturnSuccess) {
            _textureUV = CVMetalTextureGetTexture(outTexture);
            CFRelease(outTexture);
        } else {
            NSLog(@"CGMetalPixelBufferInput Error at CVMetalTextureCacheCreateTextureFromImage %d", status);
            return;
        }
    }
    
    CVMetalTextureCacheFlush(_renderTextureCache, 0);
}

- (void)drawNV12ToFBO {
    [_mtlRender setOutTexture:_outputTexture.texture index:0];
    id<MTLCommandBuffer> commandBuffer = [[CGMetalDevice sharedDevice].commandQueue commandBuffer];
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
    [encoder setFragmentTexture: _textureY
                        atIndex: 0];
    [encoder setFragmentTexture: _textureUV
                        atIndex: 1];
    [encoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle
                        indexCount: 6
                         indexType: MTLIndexTypeUInt32
                       indexBuffer: _indexBuffer
                 indexBufferOffset: 0];
    [encoder endEncoding];
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

- (void)requestRender {
    [super requestRender];
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget newTextureAvailable:_outputTexture];
    }
}

- (void)dealloc
{
    if (_renderTextureCache) {
        CFRelease(_renderTextureCache);
        _renderTextureCache = NULL;
    }
}
@end
