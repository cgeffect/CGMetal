//
//  CGMetalScaleAlpha.m
//  VGAMac
//
//  Created by Jason on 2022/1/2.
//

#import "CGMetalScaleAlpha.h"

#define kCGMetalScaleAlphaFragmentShader @"kCGMetalScaleAlphaFragmentShader"

@implementation CGMetalScaleAlpha

- (instancetype)init {
    self = [super initWithFragmentShader:kCGMetalScaleAlphaFragmentShader];
    if (self) {

    }
    
    return self;
}

@end
