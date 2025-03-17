//
//  CGMetalPlayerInputMac.h
//  CGMetal
//
//  Created by Jason on 2021/12/7.
//

#import <CGMetalMac/CGMetalOutput.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalPlayerInputMac : CGMetalOutput<CGMetalPlayInputProtocol>

@property(nonatomic, assign)BOOL isLoopPlay;

@end

NS_ASSUME_NONNULL_END
#endif
