//
//  CGMetalRender.h
//  CGMetal
//
//  Created by Jason on 21/3/1.
//

@import Foundation;
@import Metal;

@interface CGMetalRender : NSObject

@property(nonatomic, strong, readonly)MTLRenderPassDescriptor *renderTargetDescriptor;

@property(nonatomic, assign, readonly)id<MTLRenderPipelineState>renderPipelineState;

- (instancetype)initWithVertexShader:(NSString *)vertexShader
                      fragmentShader:(NSString *)fragmentShader
                         pixelFormat:(MTLPixelFormat)pixelFormat
                               index:(NSUInteger)index;

- (void)setOutTexture:(id<MTLTexture>)texture
                   index:(NSUInteger)index;

- (void)setLoadAction:(MTLLoadAction)loadAction;

- (void)setStoreAction:(MTLStoreAction)storeAction;

@end
