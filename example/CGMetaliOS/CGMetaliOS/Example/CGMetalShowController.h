//
//  CGMetalController.h
//  CGPaint
//
//  Created by Jason on 2021/5/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CGMetalBasicMode) {
    CGMetalBasicModeOrigin,
    CGMetalBasicModeGray,
    CGMetalBasicModeShake,
    CGMetalBasicModeWobble,
    CGMetalBasicModeSoul,
    CGMetalBasicModeGlitch,
    CGMetalBasicModeFlash,
    CGMetalBasicModeColor,
    CGMetalBasicModeFlipX,
    CGMetalBasicModeFlipY,
    CGMetalBasicModeZoom,
    CGMetalBasicModeRotate,
    CGMetalBasicModeTranslation,
    CGMetalBasicModeProjection,
    NUMBERS
};

typedef enum {
    CG_CAMERA,
    CG_RAWDATA,
    CG_IMAGE,
    CG_PIXELBUFFER,
    CG_VIDEO,
    CG_VIDEO_ENCODE
} CGRInputType;

@interface CGMetalShowController : UIViewController
@property(nonatomic, assign)CGMetalBasicMode filterType;
@property(nonatomic, assign)CGRInputType inputType;
@end

NS_ASSUME_NONNULL_END
