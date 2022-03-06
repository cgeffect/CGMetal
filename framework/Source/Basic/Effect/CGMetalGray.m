//
//  CGMetalGray.m
//  CGMetal
//
//  Created by Jason on 2021/10/21.
//

#import "CGMetalGray.h"

#define kCGMetalGrayFragmentShader @"kCGMetalGrayFragmentShader"

@implementation CGMetalGray

- (instancetype)init {
    self = [super initWithFragmentShader:kCGMetalGrayFragmentShader];
    if (self) {

    }
    
    return self;
}

- (void)mslEncodeCompleted {
    [self setFragmentValue1:_vec_float1 index:0];
}

@end
