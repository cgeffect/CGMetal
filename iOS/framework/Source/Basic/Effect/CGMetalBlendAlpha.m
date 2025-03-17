//
//  CGMetalBlendAlpha.m
//  CGMetal
//
//  Created by Jason on 2021/11/19.
//

#import <CGMetal/CGMetalBlendAlpha.h>

#define kCGMetalAlphaFragmentShader @"kCGMetalAlphaFragmentShader"

@implementation CGMetalBlendAlpha

- (instancetype)init {
    self = [super initWithFragmentShader:kCGMetalAlphaFragmentShader];
    if (self) {

    }
    
    return self;
}

@end
