//
//  CGMetalInput.h
//  CGMetal
//
//  Created by Jason on 2021/5/13.
//  Copyright © 2021 CGMetal. All rights reserved.
//

@import Foundation;
#import "CGMetalTexture.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CGMetalRotationMode) {
    kCGMetalNoRotation,
    kCGMetalRotateLeft,
    kCGMetalRotateRight,
    kCGMetalFlipVertical,
    kCGMetalFlipHorizonal,
    kCGMetalRotateRightFlipVertical,
    kCGMetalRotateRightFlipHorizontal,
    kCGMetalRotate180
};

typedef NS_ENUM(NSUInteger, CGMetalContentMode)
{
    CGMetalContentModeScaleToFill,
    CGMetalContentModeScaleAspectFit,
    CGMetalContentModeScaleAspectFill
};

typedef NS_ENUM(NSInteger, CGMetalAlphaMode) {
    CGMetalAlphaModeAloneAlpha,
    CGMetalAlphaModeScaleAlpha,
    CGMetalAlphaModeRGBA
};

typedef NS_ENUM(NSInteger, CGMetalBlendAlphaMode) {
    CGMetalBlendAlphaModeLeftAlpha,
    CGMetalBlendAlphaModeRightAlpha
};

typedef NS_ENUM(NSUInteger, CGPixelFormat) {
    CGPixelFormatBGRA,
    CGPixelFormatNV12,
    CGPixelFormatARGB
};

typedef NS_ENUM(NSUInteger, CGDataFormat) {
    CGDataFormatRGBA,
    CGDataFormatBGRA,
    CGDataFormatARGB, //AE 无损格式
    CGDataFormatNV21,
    CGDataFormatNV12,
    CGDataFormatI420,
};

#pragma mark -
#pragma mark subclass implementation
/**
 * Render pipeline aspect, Can handle some business logic
 * @discussion Execution sequence step1, step2, step3, step4
 */
@protocol CGMetalRenderPipeline <NSObject>
/**
 * setp1
 * set Vertex/Fragment value
 */
- (void)mslEncodeCompleted;
/**
 * setp2
 * Receive the parameter passed in from the previous filter
 */
- (void)newTextureInput:(CGMetalTexture *)texture;
/**
 * setp3
 * Parameter ready, ready to render
 */
- (void)prepareScheduled;
/**
 * setp4
 * render finished
 */
- (void)renderCompleted;

@end

@protocol CGMetalInput <NSObject>

//Attributes are defined in the protocol, and the implementation class uses the @ synthesize keyword to abstract some public attributes
@property(nonatomic, strong)CGMetalTexture *inTexture;

- (void)newTextureAvailable:(CGMetalTexture *)inTexture;

@optional
- (void)setInputRotation:(CGMetalRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;

- (void)stopOutput;

- (void)_waitUntilCompleted;

- (void)_waitUntilScheduled;

@end

@protocol CGMetalViewOutput <NSObject>
@property(nonatomic, assign)CGMetalContentMode contentMode;
@property (nonatomic, assign)CGMetalAlphaMode alphaChannelMode;
@property(nonatomic, assign)BOOL isWaitUntilCompleted;
@property(nonatomic, assign)BOOL isWaitUntilScheduled;
@end

@protocol CGMetalPlayInputProtocol <NSObject>

- (instancetype)initWithURL:(NSURL *)URL pixelFormat:(CGPixelFormat)pixelFormat;

- (void)play;

- (void)pause;

- (void)resume;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
