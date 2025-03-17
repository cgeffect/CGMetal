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
#import <CGMetalMac/CGMetalBasic.h>
#import <CGMetalMac/CGMetalShake.h>
#import <CGMetalMac/CGMetalFlipX.h>
#import <CGMetalMac/CGMetalFlipY.h>
#import <CGMetalMac/CGMetalSoul.h>
#import <CGMetalMac/CGMetalColour.h>
#import <CGMetalMac/CGMetalGray.h>
#import <CGMetalMac/CGMetalBlendAlpha.h>
#import <CGMetalMac/CGMetalBlendScaleAlpha.h>

#pragma mark -
#pragma mark Input
#import <CGMetalMac/CGMetalPixelBufferInput.h>
#import <CGMetalMac/CGMetalVideoInput.h>
#import <CGMetalMac/CGMetalRawDataInput.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CGMetalMac/CGMetalImageInput.h>
#import <CGMetalMac/CGMetalPlayerInput.h>
#else
#import <CGMetalMac/CGMetalPlayerInputMac.h>
#endif

#pragma mark -
#pragma mark Output
#import <CGMetalMac/CGMetalRawDataOutput.h>
#import <CGMetalMac/CGMetalPixelBufferOutput.h>
#import <CGMetalMac/CGMetalVideoOutput.h>
#import <CGMetalMac/CGMetalPixelBufferSurfaceOutput.h>
#import <CGMetalMac/CGMetalLayerOutput.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CGMetalMac/CGMetalUIViewOutput.h>
#import <CGMetalMac/CGMetalImageOutput.h>
#else
#import <CGMetalMac/CGMetalNSViewOutput.h>
#endif


#import <CGMetalMac/CGMetalBlit.h>
#import <CGMetalMac/CGMetalBufferProvider.h>
#import <CGMetalMac/CGMetalContext.h>
#import <CGMetalMac/CGMetalCrop.h>
#import <CGMetalMac/CGMetalHeader.h>
#import <CGMetalMac/CGMetalHeader.h>
#import <CGMetalMac/CGMetalNSViewOutput.h>
#import <CGMetalMac/CGMetalOpenGLInput.h>
#import <CGMetalMac/CGMetalOpenGLOutput.h>
#import <CGMetalMac/CGMetalPlayerInputMac.h>
#import <CGMetalMac/CGMetalQueueContext.h>
#import <CGMetalMac/CGMetalReSize.h>
#import <CGMetalMac/CGMetalSourfaceTexture.h>
#import <CGMetalMac/CGMetalTextureInput.h>
#import <CGMetalMac/MTLMetalCompute.h>
#import <CGMetalMac/CGMetalFlashWhite.h>
#import <CGMetalMac/CGMetalGlitch.h>
#import <CGMetalMac/CGMetalImageInput.h>
#import <CGMetalMac/CGMetalImageOutput.h>
#import <CGMetalMac/CGMetalPlayerInput.h>
#import <CGMetalMac/CGMetalProjection.h>
#import <CGMetalMac/CGMetalRotate.h>
#import <CGMetalMac/CGMetalTextureOutput.h>
#import <CGMetalMac/CGMetalTranslation.h>
#import <CGMetalMac/CGMetalTwoBasic.h>
#import <CGMetalMac/CGMetalUIViewOutput.h>
#import <CGMetalMac/CGMetalZoom.h>
