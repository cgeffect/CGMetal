//
//  CGMetalFlipY.m
//  CGMetal
//
//  Created by Jason on 2021/6/17.
//

#import "CGMetalFlipY.h"

#define kCGMetalFlipYVertexShader @"kCGMetalFlipYVertexShader"

@implementation CGMetalFlipY

- (instancetype)init {
    self = [super initWithVertexShader:kCGMetalFlipYVertexShader];
    if (self) {

    }
    
    return self;
}

@end

