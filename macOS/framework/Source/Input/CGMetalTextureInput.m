//
//  CGMetalTextureInput.m
//  CGMetal
//
//  Created by Jason on 2021/6/3.
//

#import "CGMetalTextureInput.h"

@implementation CGMetalTextureInput

- (instancetype)initWithTexture:(id<MTLTexture>)newInputTexture size:(CGSize)newTextureSize {
    self = [super init];
    if (self) {
        _outputTexture = [[CGMetalTexture alloc] initWithTexture:newInputTexture size:newTextureSize];
    }

    return self;
}

- (void)requestRender {
    [super requestRender];
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget newTextureAvailable:_outputTexture];
    }
}

@end
