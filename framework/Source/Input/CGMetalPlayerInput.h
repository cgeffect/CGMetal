//
//  CGMetalVideoPlayInput.h
//  CGMetal
//
//  Created by Jason on 2021/6/1.
//

#import "CGMetalOutput.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

#import <AVFoundation/AVFoundation.h>
#import "CGMetalPixelBufferInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalPlayerInput : CGMetalOutput<CGMetalPlayInputProtocol>

@property(nonatomic, assign)BOOL isLoopPlay;

@end

NS_ASSUME_NONNULL_END
#else
#endif
