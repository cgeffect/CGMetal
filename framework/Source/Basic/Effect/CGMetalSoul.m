//
//  CGMetalSoul.m
//  CGMetal
//
//  Created by Jason on 2021/6/19.
//

#import "CGMetalSoul.h"

#define kCGMetalSoulFragmentShader @"kCGMetalSoulFragmentShader"

@implementation CGMetalSoul

- (instancetype)init {
    self = [super initWithFragmentShader:kCGMetalSoulFragmentShader];
    if (self) {

    }
    
    return self;
}

- (void)mslEncodeCompleted {
    [self setFragmentValue1:_vec_float1 index:0];
}

@end
