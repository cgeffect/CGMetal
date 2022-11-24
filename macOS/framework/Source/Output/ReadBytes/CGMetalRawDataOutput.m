//
//  CGMetalRawDataOutput.m
//  CGMetal
//
//  Created by Jason on 2021/6/14.
//

#import "CGMetalRawDataOutput.h"

@implementation CGMetalRawDataOutput
{
    UInt8 *_dstData;
}
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}
- (void)captureBufferToOutput {
    if (_dstData == NULL) {
        _dstData = (UInt8 *)malloc(_mtlTexture.textureSize.width * _mtlTexture.textureSize.height * 4);
    }
    MTLRegion region = MTLRegionMake2D(0, 0, _mtlTexture.textureSize.width, _mtlTexture.textureSize.height);
    [_mtlTexture.texture getBytes:_dstData bytesPerRow:_mtlTexture.textureSize.width fromRegion:region mipmapLevel:0];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rawDataOutput:)]) {
        [self.delegate rawDataOutput:_dstData];
    }
}

- (void)dealloc
{
    if (_dstData) {
        free(_dstData);
        _dstData = NULL;
    }
}
@end
