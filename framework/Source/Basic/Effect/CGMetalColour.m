//
//  CGMetalColour.m
//  CGMetal
//
//  Created by Jason on 2021/6/20.
//

#import "CGMetalColour.h"

#define kCGMetalColourFragmentShader @"kCGMetalColourFragmentShader"

@implementation CGMetalColour

- (instancetype)init {
    self = [super initWithFragmentShader:kCGMetalColourFragmentShader];
    if (self) {

    }
    
    return self;
}

- (void)mslEncodeCompleted {
    [self setFragmentValue1:_vec_float1 index:0];
}

@end
