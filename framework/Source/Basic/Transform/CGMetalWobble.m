//
//  CGMetalWobble.m
//  CGMetal
//
//  Created by Jason on 2022/1/2.
//

#import "CGMetalWobble.h"

#define WobbleVertex @"WobbleVertex"
@implementation CGMetalWobble

- (instancetype)init {
    self = [super initWithVertexShader:WobbleVertex];
    if (self) {

    }
    
    return self;
}

- (void)setInValue1:(vec_float1)inValue {
    _vec_float1 = inValue;
}

- (void)mslEncodeCompleted {
    [self setVertexValue1:_vec_float1 index:2];
}
@end
