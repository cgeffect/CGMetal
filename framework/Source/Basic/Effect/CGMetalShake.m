//
//  CGMetalShake.m
//  CGMetal
//
//  Created by Jason on 2021/6/4.
//

#import "CGMetalShake.h"

#define kCGMetalShakeFragmentShader1 @"kCGMetalShakeFragmentShader1"
#define kCGMetalShakeFragmentShader @"kCGMetalShakeFragmentShader"

@implementation CGMetalShake

- (instancetype)init {
    self = [super initWithFragmentShader:kCGMetalShakeFragmentShader1];
    if (self) {

    }
    
    return self;
}

- (void)mslEncodeCompleted {
    [self setFragmentValue1:_vec_float1 index:0];
}

@end
