//
//  CGMetalRawDataInput.m
//  CGMetal
//
//  Created by Jason on 2021/6/1.
//

#import "CGMetalRawDataInput.h"
#import "CGMetalRender.h"

#define VertexShader       @"CGMetalRawVertexShader"
#define FragmentShaderNV12 @"CGMetalRawNV12FragmentShader"
#define FragmentShaderNV21 @"CGMetalRawNV21FragmentShader"
#define FragmentShaderI420 @"CGMetalRawI420FragmentShader"

@implementation CGMetalRawDataInput
{
    CGDataFormat _dataFormat;
    CGSize _byteSize;
    
    id<MTLCommandQueue> _commandQueue;
    id<MTLBuffer> _indexBuffer;
    CGMetalRender *_mtlRender;
    
    CGMetalTexture *_yTexture;
    CGMetalTexture * _uTexture;
    CGMetalTexture * _vTexture;
    CGMetalTexture * _uvTexture;    
    BOOL _isOverride;
}

- (instancetype)initWithFormat:(CGDataFormat)dataFormat
{
    self = [super init];
    if (self) {
        _dataFormat = dataFormat;
    }
    return self;
}
- (void)uploadByte:(UInt8 *)byte byteSize:(CGSize)byteSize {
    _isOverride = NO;
    CGDataFormat format = _dataFormat;
    _byteSize = byteSize;
    if (format == CGDataFormatRGBA || format == CGDataFormatBGRA) {
        CGMetalTexture *mtlTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
        MTLPixelFormat pixelFormat = MTLPixelFormatRGBA8Unorm;
        if (format == CGDataFormatRGBA) {
            pixelFormat = MTLPixelFormatRGBA8Unorm;
        } else if (format == CGDataFormatBGRA) {
            pixelFormat = MTLPixelFormatBGRA8Unorm;
        }
        [mtlTexture newTexture:byte pixelFormat:pixelFormat size:byteSize bytesPerRow:byteSize.width * 4 usege:MTLTextureUsageShaderRead];
        _outputTexture = mtlTexture;
        
    } else if (format == CGDataFormatNV21 || format == CGDataFormatNV12 || format == CGDataFormatI420) {
        if (format == CGDataFormatNV21 || format == CGDataFormatNV12) {
            int uvOffset = byteSize.width * byteSize.height;
            CGSize uvSize = CGSizeMake(byteSize.width * 0.5, byteSize.height * 0.5);
            
            CGMetalTexture *yTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
            [yTexture newTexture:byte pixelFormat:MTLPixelFormatR8Unorm size:byteSize bytesPerRow:byteSize.width usege:MTLTextureUsageShaderRead];
            _yTexture = yTexture;
            CGMetalTexture *uvTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
            [uvTexture newTexture:byte + uvOffset pixelFormat:MTLPixelFormatRG8Unorm size:uvSize bytesPerRow:byteSize.width usege:MTLTextureUsageShaderRead];
            _uvTexture = uvTexture;
            
            if (format ==CGDataFormatNV21) {
                _mtlRender = [[CGMetalRender alloc] initWithVertexShader:VertexShader
                                                          fragmentShader:FragmentShaderNV21
                                                             pixelFormat:MTLPixelFormatRGBA8Unorm
                                                                   index:0];
            } else if (format == CGDataFormatNV12) {
                _mtlRender = [[CGMetalRender alloc] initWithVertexShader:VertexShader
                                                          fragmentShader:FragmentShaderNV12
                                                             pixelFormat:MTLPixelFormatRGBA8Unorm
                                                                   index:0];
            }
        } else if (format == CGDataFormatI420) {
            int uOffset = byteSize.width * byteSize.height;
            int vOffset = byteSize.width * byteSize.height * 5 / 4;
            CGSize uvSize = CGSizeMake(byteSize.width * 0.5, byteSize.height * 0.5);

            CGMetalTexture *yTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
            [yTexture newTexture:byte pixelFormat:MTLPixelFormatR8Unorm size:byteSize bytesPerRow:byteSize.width usege:MTLTextureUsageShaderRead];
            _yTexture = yTexture;
            CGMetalTexture *uTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
            [uTexture newTexture:byte + uOffset pixelFormat:MTLPixelFormatR8Unorm size:uvSize bytesPerRow:byteSize.width / 2 usege:MTLTextureUsageShaderRead];
            _uTexture = uTexture;
            CGMetalTexture *vTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
            [vTexture newTexture:byte + vOffset pixelFormat:MTLPixelFormatR8Unorm size:uvSize bytesPerRow:byteSize.width / 2 usege:MTLTextureUsageShaderRead];
            _vTexture = vTexture;
            _mtlRender = [[CGMetalRender alloc] initWithVertexShader:VertexShader
                                                      fragmentShader:FragmentShaderI420
                                                         pixelFormat:MTLPixelFormatRGBA8Unorm
                                                               index:0];
        }
        
        _commandQueue = [[CGMetalDevice sharedDevice].device newCommandQueue];
        _indexBuffer = [[CGMetalDevice sharedDevice].device newBufferWithBytes: _indices
                                            length: sizeof(_indices)
                                           options: MTLResourceStorageModeShared];
       
        self->_outputTexture = [[CGMetalTexture alloc] initWithDevice:[CGMetalDevice sharedDevice].device];
        [self->_outputTexture newTexture:MTLPixelFormatRGBA8Unorm size:byteSize usege:MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget];
        
        [self drawYUVToFBO];
    }
    _isOverride = YES;
}

- (void)updateByte:(UInt8 *)byte byteSize:(CGSize)byteSize {
    CGDataFormat format = _dataFormat;
    if (format == CGDataFormatRGBA) {
        [_outputTexture updateTexture:byte byteSize:byteSize bytesPerRow:byteSize.width * 4];
    } else if (format == CGDataFormatBGRA) {
        [_outputTexture updateTexture:byte byteSize:byteSize bytesPerRow:byteSize.width * 4];
    } else if (format == CGDataFormatNV21 || format == CGDataFormatNV12) {
        int uvOffset = byteSize.width * byteSize.height;
        CGSize uvSize = CGSizeMake(byteSize.width * 0.5, byteSize.height * 0.5);
        [_yTexture updateTexture:byte byteSize:byteSize bytesPerRow:byteSize.width];
        [_uvTexture updateTexture:byte + uvOffset byteSize:uvSize bytesPerRow:byteSize.width];
        [self drawYUVToFBO];
    } else if (format == CGDataFormatI420) {
        CGSize uvSize = CGSizeMake(byteSize.width * 0.5, byteSize.height * 0.5);
        int uOffset = byteSize.width * byteSize.height;
        int vOffset = byteSize.width * byteSize.height * 5 / 4;
        [_yTexture updateTexture:byte byteSize:byteSize bytesPerRow:byteSize.width];
        [_uTexture updateTexture:byte + uOffset byteSize:uvSize bytesPerRow:byteSize.width / 2];
        [_vTexture updateTexture:byte + vOffset byteSize:uvSize bytesPerRow:byteSize.width / 2];
        [self drawYUVToFBO];
    }
}

- (void)drawYUVToFBO {
    [_mtlRender setOutTexture:_outputTexture.texture index:0];
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: _mtlRender.renderTargetDescriptor];
    encoder.label = @"Render Command Encoder";
    [encoder setViewport: (MTLViewport) {
        .originX = 0,
        .originY = 0,
        .width = _byteSize.width,
        .height = _byteSize.height,
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
    [encoder setFragmentTexture: _yTexture.texture
                        atIndex: 0];
    if (_dataFormat == CGDataFormatNV12 || _dataFormat == CGDataFormatNV21) {
        [encoder setFragmentTexture: _uvTexture.texture
                            atIndex: 1];
    } else if (_dataFormat == CGDataFormatI420) {
        [encoder setFragmentTexture: _uTexture.texture atIndex: 1];
        [encoder setFragmentTexture: _vTexture.texture atIndex: 2];
    }
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

@end
