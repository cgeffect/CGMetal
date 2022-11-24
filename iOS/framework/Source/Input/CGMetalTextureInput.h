//
//  CGMetalTextureInput.h
//  CGMetal
//
//  Created by Jason on 2021/6/3.
//

#import "CGMetalOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalTextureInput : CGMetalOutput

- (instancetype)initWithTexture:(id<MTLTexture>)newInputTexture size:(CGSize)newTextureSize;

@end

NS_ASSUME_NONNULL_END
