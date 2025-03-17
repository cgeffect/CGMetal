//
//  CGMetalUIViewOutput.h
//  CGMetal
//
//  Created by Jason on 21/3/3.
//


#import <CGMetal/CGMetalInput.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CGMetal/CGMetalLayerOutput.h>
//@import UIKit;
#import <UIKit/UIKit.h>

@interface CGMetalUIViewOutput : UIView<CGMetalInput, CGMetalViewOutput>

@end
#else
#endif
