//
//  CGMetalBlit.h
//  CGMetal
//
//  Created by Jason on 2021/5/29.
//

#import <Foundation/Foundation.h>
@import Metal;

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalBlit : NSObject

- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)queue;

- (void)copyFromTexture:(id<MTLTexture>)sourceTexture toTexture:(id<MTLTexture>)destinationTexture;

@end

NS_ASSUME_NONNULL_END
