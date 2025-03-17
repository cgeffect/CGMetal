//
//  CGMetal.h
//  CGMetal
//
//  Created by Jason on 2021/5/25.
//

#import <Foundation/Foundation.h>

//! Project version number for CGMetal.
FOUNDATION_EXPORT double CGMetalVersionNumber;

//! Project version string for CGMetal.
FOUNDATION_EXPORT const unsigned char CGMetalVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CGMetal/PublicHeader.h>

#pragma mark -
#pragma mark Basic
#import <CGMetal/CGMetalBasic.h>
#import <CGMetal/CGMetalTwoBasic.h>
#import <CGMetal/CGMetalShake.h>
#import <CGMetal/CGMetalFlipX.h>
#import <CGMetal/CGMetalFlipY.h>
#import <CGMetal/CGMetalSoul.h>
#import <CGMetal/CGMetalColour.h>
#import <CGMetal/CGMetalGray.h>
#import <CGMetal/CGMetalBlendAlpha.h>
#import <CGMetal/CGMetalGlitch.h>
#import <CGMetal/CGMetalFlashWhite.h>
#import <CGMetal/CGMetalRotate.h>
#import <CGMetal/CGMetalTranslation.h>
#import <CGMetal/CGMetalZoom.h>
#import <CGMetal/CGMetalProjection.h>
#import <CGMetal/CGMetalWobble.h>
#import <CGMetal/CGMetalBlendScaleAlpha.h>
#import <CGMetal/CGMetalBlendAlpha.h>

#pragma mark -
#pragma mark Input
#import <CGMetal/CGMetalPixelBufferInput.h>
#import <CGMetal/CGMetalVideoInput.h>
#import <CGMetal/CGMetalRawDataInput.h>
#import <CGMetal/CGMetalCameraInput.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CGMetal/CGMetalImageInput.h>
#import <CGMetal/CGMetalPlayerInput.h>
#else
#import <CGMetal/CGMetalPlayerInputMac.h>
#endif

#pragma mark -
#pragma mark Output
#import <CGMetal/CGMetalRawDataOutput.h>
#import <CGMetal/CGMetalPixelBufferOutput.h>
#import <CGMetal/CGMetalVideoOutput.h>
#import <CGMetal/CGMetalPixelBufferSurfaceOutput.h>
#import <CGMetal/CGMetalLayerOutput.h>
#import <CGMetal/CGMetalTextureOutput.h>
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CGMetal/CGMetalUIViewOutput.h>
#import <CGMetal/CGMetalImageOutput.h>
#else
#import <CGMetal/CGMetalNSViewOutput.h>
#endif

#import <CGMetal/CGMetalBlit.h>
#import <CGMetal/CGMetalBufferProvider.h>
#import <CGMetal/CGMetalContext.h>
#import <CGMetal/CGMetalCrop.h>
#import <CGMetal/CGMetalHeader.h>
#import <CGMetal/CGMetalHeader.h>
#import <CGMetal/CGMetalNSViewOutput.h>
#import <CGMetal/CGMetalOpenGLInput.h>
#import <CGMetal/CGMetalOpenGLOutput.h>
#import <CGMetal/CGMetalPlayerInputMac.h>
#import <CGMetal/CGMetalQueueContext.h>
#import <CGMetal/CGMetalReSize.h>
#import <CGMetal/CGMetalSourfaceTexture.h>
#import <CGMetal/CGMetalTextureInput.h>
#import <CGMetal/MTLMetalCompute.h>
//#import <CGMetal/CGMetalNSViewOutput.h>

