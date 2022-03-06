//
//  CGMetalOS.h
//  CGMetalOS
//
//  Created by Jason on 2021/5/25.
//

#import <Foundation/Foundation.h>

//! Project version number for CGMetal.
FOUNDATION_EXPORT double CGMetalVersionNumber;

//! Project version string for CGMetal.
FOUNDATION_EXPORT const unsigned char CGMetalVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CGMetalOS/PublicHeader.h>

#pragma mark -
#pragma mark Basic
#import "CGMetalBasic.h"
#import "CGMetalShake.h"
#import "CGMetalFlipX.h"
#import "CGMetalFlipY.h"
#import "CGMetalSoul.h"
#import "CGMetalColour.h"
#import "CGMetalGray.h"
#import "CGMetalBlendAlpha.h"
#import "CGMetalGlitch.h"
#import "CGMetalFlashWhite.h"
#import "CGMetalRotate.h"
#import "CGMetalTranslation.h"
#import "CGMetalZoom.h"
#import "CGMetalProjection.h"
#import "CGMetalWobble.h"
#import "CGMetalBlendScaleAlpha.h"

#pragma mark -
#pragma mark Input
#import "CGMetalPixelBufferInput.h"
#import "CGMetalVideoInput.h"
#import "CGMetalRawDataInput.h"
#import "CGMetalCameraInput.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CGMetalImageInput.h"
#import "CGMetalPlayerInput.h"
#else
#import "CGMetalPlayerInputMac.h"
#endif

#pragma mark -
#pragma mark Output
#import "CGMetalRawDataOutput.h"
#import "CGMetalPixelBufferOutput.h"
#import "CGMetalVideoOutput.h"
#import "CGMetalPixelBufferSurfaceOutput.h"
#import "CGMetalLayerOutput.h"
#import "CGMetalTextureOutput.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CGMetalUIViewOutput.h"
#import "CGMetalImageOutput.h"
#else
#import "CGMetalNSViewOutput.h"
#endif

