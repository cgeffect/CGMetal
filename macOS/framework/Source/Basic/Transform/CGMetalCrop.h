//
//  CGMetalCrop.h
//  VGAMac
//
//  Created by Jason on 2022/1/2.
//

#import "CGMetalBasic.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalCrop : CGMetalBasic

//(0,0)左上角, UIKit归一化坐标
@property(assign, nonatomic, readwrite) CGRect cropRegion;

@end

NS_ASSUME_NONNULL_END
