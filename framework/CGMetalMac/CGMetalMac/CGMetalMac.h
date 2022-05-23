//
//  CGMetalMacOS.h
//  CGMetalMacOS
//
//  Created by Jason on 2021/12/24.
//

#import <Foundation/Foundation.h>

//! Project version number for CGMetalMacOS.
FOUNDATION_EXPORT double CGMetalMacOSVersionNumber;

//! Project version string for CGMetalMacOS.
FOUNDATION_EXPORT const unsigned char CGMetalMacOSVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CGMetalMacOS/PublicHeader.h>

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
#import "CGMetalBlendScaleAlpha.h"

#pragma mark -
#pragma mark Input
#import "CGMetalPixelBufferInput.h"
#import "CGMetalVideoInput.h"
#import "CGMetalRawDataInput.h"
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
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CGMetalUIViewOutput.h"
#import "CGMetalImageOutput.h"
#else
#import "CGMetalNSViewOutput.h"
#endif



