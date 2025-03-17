//
//  CGMetalUIViewOutput.h
//  CGMetal
//
//  Created by Jason on 21/3/3.
//


#import <CGMetalMac/CGMetalInput.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CGMetalMac/CGMetalLayerOutput.h>
#import <UIKit/UIKit.h>

@interface CGMetalUIViewOutput : UIView<CGMetalInput, CGMetalViewOutput>

@end
#else
#endif
