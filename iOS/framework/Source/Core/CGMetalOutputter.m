//
//  CGMetalRenderOutput.m
//  CGMetal
//
//  Created by Jason on 2021/6/14.
//

#import "CGMetalOutputter.h"

@implementation CGMetalOutputter

@synthesize inTexture = _inTexture;

#pragma mark -
#pragma mark CGPaintInput

- (void)newTextureAvailable:(CGMetalTexture *)inTexture {
    _mtlTexture = inTexture;
}

- (void)take {
    
}

@end
