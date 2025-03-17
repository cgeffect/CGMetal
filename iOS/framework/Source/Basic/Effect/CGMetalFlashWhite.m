//
//  CGMetalFlashWhite.m
//  CGMetal
//
//  Created by Jason on 2022/1/1.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#import <CGMetal/CGMetalFlashWhite.h>

#define kCGMetalFlashFragment @"kCGMetalFlashFragment"

@implementation CGMetalFlashWhite

- (instancetype)init {
    self = [super initWithFragmentShader:kCGMetalFlashFragment];
    if (self) {

    }
    
    return self;
}

- (void)mslEncodeCompleted {
    [self setFragmentValue1:_simd_float1 index:0];
}

@end
