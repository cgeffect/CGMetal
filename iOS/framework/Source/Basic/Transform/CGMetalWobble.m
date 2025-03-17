//
//  CGMetalWobble.m
//  CGMetal
//
//  Created by Jason on 2022/1/2.
//

#import <CGMetal/CGMetalWobble.h>

#define WobbleVertex @"WobbleVertex"
@implementation CGMetalWobble

- (instancetype)init {
    self = [super initWithVertexShader:WobbleVertex];
    if (self) {

    }
    
    return self;
}

- (void)setInValue1:(simd_float1)inValue {
    _simd_float1 = inValue;
}

- (void)mslEncodeCompleted {
    [self setVertexValue1:_simd_float1 index:2];
}
@end
