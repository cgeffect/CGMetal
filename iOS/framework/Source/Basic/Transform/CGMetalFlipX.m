//
//  CGMetalFlipX.m
//  CGMetal
//
//  Created by Jason on 2021/6/17.
//

#import "CGMetalFlipX.h"

#define kCGMetalFlipXVertexShader @"kCGMetalFlipXVertexShader"

@implementation CGMetalFlipX

- (instancetype)init {
    self = [super initWithVertexShader:kCGMetalFlipXVertexShader];
    if (self) {

    }
    
    return self;
}

@end
