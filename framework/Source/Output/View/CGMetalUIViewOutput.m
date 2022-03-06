//
//  CGMetalUIViewOutput.m
//  CGMetal
//
//  Created by Jason on 21/3/3.
//

#import "CGMetalUIViewOutput.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CGMetalOutput.h"
#import "CGMetalRender.h"
#import "CGMetalDevice.h"
@import Metal;

#define VertexShader @"CGRenderVertexShader"
#define FragmentShader @"CGRenderFragmentShader"

@interface CGMetalUIViewOutput ()
{
    id<MTLCommandQueue> _commandQueue;
    id<MTLBuffer> _indexBuffer;
    CAMetalLayer *_metalLayer;
    CGMetalRender *_mtlRender;
}
@end

@implementation CGMetalUIViewOutput

@synthesize inTexture = _inTexture;
@synthesize contentMode = _contentMode;
@synthesize alphaChannelMode = _alphaChannelMode;
@synthesize isWaitUntilCompleted = _isWaitUntilCompleted;
@synthesize isWaitUntilScheduled = _isWaitUntilScheduled;

+ (Class) layerClass
{
    return [CAMetalLayer class];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        _contentMode = CGMetalContentModeScaleAspectFit;
        _alphaChannelMode = CGMetalAlphaModeRGBA;
        _commandQueue = [CGMetalDevice sharedDevice].commandQueue;
        CAMetalLayer *metalLayer = (CAMetalLayer *) self.layer;
        [metalLayer setDevice:[CGMetalDevice sharedDevice].device];
        metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        metalLayer.framebufferOnly = true;
        CGFloat scale = UIScreen.mainScreen.nativeScale;
        metalLayer.contentsScale = scale;
        //像素值
        metalLayer.drawableSize = CGSizeApplyAffineTransform(self.bounds.size, CGAffineTransformMakeScale(scale, scale));
        _metalLayer = metalLayer;
        
        _mtlRender = [[CGMetalRender alloc] initWithVertexShader:VertexShader
                                                  fragmentShader:FragmentShader
                                                     pixelFormat:MTLPixelFormatBGRA8Unorm
                                                           index:0];
        //fbo的颜色
        _mtlRender.renderTargetDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0);
        //clear fbo, 防止残留数据
        _mtlRender.renderTargetDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        //MTLBuffer是一个存储器, 可以存储任意数据
        _indexBuffer = [[CGMetalDevice sharedDevice].device newBufferWithBytes: _indices
                                            length: sizeof(_indices)
                                           options: MTLResourceStorageModeShared];
        
        //最大帧率
        if (@available(iOS 10.3, *)) {
            NSInteger maximumFramesPerSecond = UIScreen.mainScreen.maximumFramesPerSecond;
            NSLog(@"设备支持最大帧率: %ld fps", (long)maximumFramesPerSecond);
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

#pragma mark - CGMetalInput
- (void)newTextureAvailable:(CGMetalTexture *)inTexture {
    _inTexture = inTexture;
    NSUInteger width = 0;
    if (_alphaChannelMode == CGMetalAlphaModeRGBA) {
        width = inTexture.texture.width;
    } else if (_alphaChannelMode == CGMetalAlphaModeAloneAlpha) {
        width = inTexture.texture.width / 2.0;
    } else if (_alphaChannelMode == CGMetalAlphaModeScaleAlpha) {
        width = inTexture.texture.width / 3.0 * 2.0;
    }
    
    NSUInteger height = inTexture.texture.height;
    //render
    id<CAMetalDrawable> currentDrawable = [_metalLayer nextDrawable];
    [_mtlRender setOutTexture:currentDrawable.texture index:0];
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"CGMetalView Command Buffer";
    
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: _mtlRender.renderTargetDescriptor];
    encoder.label = @"CGMetalView Command Encoder";
    
    CGRect viewPort = [self glPrepareViewport:width height:height];
    int x = (int) viewPort.origin.x;
    int y = (int) viewPort.origin.y;
    int w = (int) viewPort.size.width;
    int h = (int) viewPort.size.height;

    /**
    因为renderbuffer的尺寸是从EAGLLayer中得到，如果EGLLayer的尺寸不正确，会导致最终的图像大小不如预期。在apple的 Supporting High-Resolution Screens In Views(https://developer.apple.com/library/archive/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/SupportingHiResScreensInViews/SupportingHiResScreensInViews.html) 这篇文章提到，在高分辨率的设备上渲染OpenGL ES， 如果不做设置，那么出现的图像会变得blockly，应该是说是块状的，就是不太清晰，其建议就是使用较大的scale值。可以这样设置:
    eaglLayer.contentsScale = [UIScreen mainScreen].scale;
    记住，如果将eagl layer 的scale值设置变大了，那么在glviewport() 的时候要使用相应的成倍数的尺寸。
     */
    //viewPort的值是纹理数据到屏幕的映射坐标
    [encoder setViewport: (MTLViewport) {
        .originX = x,
        .originY = y,
        .width = w,
        .height = h,
        .znear = 0,
        .zfar = 1
    }];
    [encoder setRenderPipelineState: _mtlRender.renderPipelineState];
    
    //setVertexBytes:length:atIndex:方法是将非常少量（小于 4 KB）的动态缓冲区数据绑定到顶点函数的最佳选择，此方法避免了创建中间MTLBuffer对象的开销。Metal 为您管理一个临时缓冲区。
    //如果您的数据大小大于4KB，创建一个MTLBuffer对象并根据需要更新其内容。调用setVertexBuffer:offset:atIndex:方法将缓冲区绑定到一个顶点函数；
    //如果您的缓冲区包含在多个绘制调用中使用的数据，则setVertexBufferOffset:atIndex:随后调用该方法以更新缓冲区偏移量，使其指向相应的绘制调用数据的位置，如果您只是更新其偏移量，则无需重新绑定当前绑定的缓冲区。
    [encoder setVertexBytes: _vertices
                     length: sizeof(_vertices)
                    atIndex: 0];
    [encoder setVertexBytes: _texCoord
                     length: sizeof(_texCoord)
                    atIndex: 1];
    [encoder setFragmentTexture: inTexture.texture
                        atIndex: 0];
    
    /*
     MTLPrimitiveTypePoint = 0, 点
     MTLPrimitiveTypeLine = 1, 线段
     MTLPrimitiveTypeLineStrip = 2, 线环
     MTLPrimitiveTypeTriangle = 3,  三角形
     MTLPrimitiveTypeTriangleStrip = 4, 三角型扇
     */
    [encoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle
                        indexCount: 6
                         indexType: MTLIndexTypeUInt32
                       indexBuffer: _indexBuffer
                 indexBufferOffset: 0];
    [encoder endEncoding];
    
    //addCompletedHandler回调一定要在commit之前添加, 否则会出现crash
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
//        NSLog(@"command buffer has completed execution");
    }];
    [commandBuffer addScheduledHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
//        NSLog(@"command buffer has been scheduled for execution");
    }];
    [commandBuffer presentDrawable: currentDrawable];
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

- (void)_waitUntilCompleted {
    _isWaitUntilCompleted = YES;
}

- (void)_waitUntilScheduled {
    _isWaitUntilScheduled = YES;
}

#pragma mark - private
- (CGRect)glPrepareViewport:(NSUInteger)texWidth height:(NSUInteger)texHeight {
    if (texWidth == 0 || texHeight == 0) {
        return CGRectZero;
    }
    if (_contentMode == CGMetalContentModeScaleToFill) {
        return CGRectMake(0, 0, self->_metalLayer.drawableSize.width, self->_metalLayer.drawableSize.height);
    } else if (_contentMode == CGMetalContentModeScaleAspectFit) {
        return [self viewportAspectFit:texWidth height:texHeight];
    } else if (_contentMode == CGMetalContentModeScaleAspectFill) {
        return [self viewportAspectFill:texWidth height:texHeight];
    }
    return [self viewportAspectFit:texWidth height:texHeight];
}

- (CGRect)viewportAspectFit:(NSUInteger)texWidth height:(NSUInteger)texHeight {
    int x, y, w, h;
    int layerW = (int) self->_metalLayer.drawableSize.width;
    int layerH = (int) self->_metalLayer.drawableSize.height;
    float ratioTex = (float) texHeight / texWidth;
    float ratioLayer = (float)layerH / (float)layerW;
    if (ratioTex > ratioLayer) {
        h = (int) layerH;
        w = (int) (layerH / ratioTex);
    } else {
        w = (int) layerW;
        h = (int) (layerW * ratioTex);
    }
    x = ((int) layerW - w) / 2;
    y = ((int) layerH - h) / 2;
    return CGRectMake(x, y, w, h);
}

- (CGRect)viewportAspectFill:(NSUInteger)texWidth height:(NSUInteger)texHeight {
    //要显示的纹理相对于原为了的坐标映射
    int x, y, w, h;
    int layerW = (int) self->_metalLayer.drawableSize.width;
    int layerH = (int) self->_metalLayer.drawableSize.height;
    float ratioTex = (float) texHeight / texWidth;
    float ratioLayer = (float)layerH / (float)layerW;
    if (ratioTex > ratioLayer) {
        w = (int) layerW;
        h = (int) (layerW * ratioTex);
    } else {
        h = layerH;
        w = (int) layerH / ratioTex;
    }
    x = ((int) w - layerW) / 2;
    y = ((int) h - layerH) / 2;
    return CGRectMake(-x, -y, w, h);
}

- (void)dealloc {
    
}

@end
#else
#endif
