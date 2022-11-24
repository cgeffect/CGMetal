//
//  CGMetalBlit.m
//  CGMetal
//
//  Created by Jason on 2021/5/29.
//

#import "CGMetalBlit.h"

@interface CGMetalBlit ()
{
    id<MTLBlitCommandEncoder>_blitCommandEncoder;
//    MTLBlitPip
    id<MTLComputeCommandEncoder> computeEncoder;
    id<MTLComputePipelineState> _mAddFunctionPSO;

}
@end
@implementation CGMetalBlit

- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)queue
{
    self = [super init];
    if (self) {
        id<MTLCommandBuffer>buffer = [queue commandBuffer];

        id<MTLBlitCommandEncoder>blitCmd = [buffer blitCommandEncoder];
        _blitCommandEncoder = blitCmd;
    }
    return self;
}

- (void)copyFromTexture:(id<MTLTexture>)sourceTexture toTexture:(id<MTLTexture>)destinationTexture {
    if (@available(iOS 13.0, *)) {
        [_blitCommandEncoder copyFromTexture:sourceTexture toTexture:destinationTexture];
    } else {
        // Fallback on earlier versions
    }

}

@end
