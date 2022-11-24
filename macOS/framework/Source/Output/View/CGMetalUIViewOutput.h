//
//  CGMetalUIViewOutput.h
//  CGMetal
//
//  Created by Jason on 21/3/3.
//


#import "CGMetalInput.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CGMetalLayerOutput.h"
@import UIKit;

@interface CGMetalUIViewOutput : UIView<CGMetalInput, CGMetalViewOutput>

@end
#else
#endif
