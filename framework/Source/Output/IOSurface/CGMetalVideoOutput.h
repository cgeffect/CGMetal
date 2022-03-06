//
//  CGMetalVideoSurfaceOutput.h
//  CGMetal
//
//  Created by Jason on 2021/12/1.
//

#import "CGMetalInput.h"
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@class CGMetalEncodeParam;
@interface CGMetalVideoOutput : NSObject<CGMetalInput>

- (instancetype)initWithURL:(NSURL *)dstURL;

@property(nonatomic, strong)CGMetalEncodeParam *encodeParam;

@property(nonatomic, assign)BOOL isManual; //default value is NO

- (void)startRecord;

- (void)endRecord;

@end

@interface CGMetalEncodeParam : NSObject
@property(nonatomic, strong) NSString *savePath;
@property(nonatomic, assign) int srcWidth;
@property(nonatomic, assign) int srcHeight;
@property(nonatomic, assign) int videoRate;
@property(nonatomic, assign) int frameCount; //if camera record, frameCount not set
@end

@class CGMetalVideoEncoder;
@protocol CGVideoEncoderDelegate <NSObject>
@optional
- (void)onStart:(CGMetalVideoEncoder *)videoEncoder;

- (void)encoder:(CGMetalVideoEncoder *)videoEncoder onProgress:(float)progress;

- (void)encoder:(CGMetalVideoEncoder *)videoEncoder onFinish:(NSString *)filePath;

- (void)encoder:(CGMetalVideoEncoder *)videoEncoder onError:(NSInteger)errorCode;

@end

@interface CGMetalVideoEncoder : NSObject

@property(nonatomic, weak) id <CGVideoEncoderDelegate> delegate;

@property(nonatomic, assign)BOOL expectsMediaDataInRealTime; //default value is NO

- (void)prepareEncode:(CGMetalEncodeParam *)param;

- (void)stopEncode;

- (void)appendPixelBuffer:(CVPixelBufferRef)pixelbuffer;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
