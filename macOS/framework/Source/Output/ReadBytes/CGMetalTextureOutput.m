//
//  CGMetalTextureOutput.m
//  CGMetal
//
//  Created by Jason on 2021/6/14.
//

#import "CGMetalTextureOutput.h"

@implementation CGMetalTextureOutput

@synthesize inTexture = _inTexture;

- (id<MTLTexture>)texture {
    return _inTexture.texture;
}

- (CGSize)textureSize {
    return _inTexture.textureSize;
}

- (void)newTextureAvailable:(CGMetalTexture *)inTexture {
    _inTexture = inTexture;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textureOutput:)]) {
        [self.delegate textureOutput:inTexture];
    }
}


@end
