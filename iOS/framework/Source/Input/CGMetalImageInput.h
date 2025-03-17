//
//  CGMetalImageInput.h
//  CGMetal
//
//  Created by Jason on 2021/5/13.
//  Copyright © 2021 CGMetal. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

//@import UIKit;
#import <UIKit/UIKit.h>
#import <CGMetal/CGMetalOutput.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalImageInput : CGMetalOutput
{

}
- (instancetype)initWithImage:(UIImage *)newImageSource;

@end

NS_ASSUME_NONNULL_END
#else
#endif
