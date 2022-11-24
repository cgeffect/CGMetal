//
//  CGMetalVideoReaderInput.h
//  CGMetal
//
//  Created by Jason on 2021/12/1.
//

#import "CGMetalOutput.h"
#import "CGMetalPixelBufferInput.h"

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalVideoInfo : NSObject
- (instancetype)initWithPath:(nonnull NSString *)path;
@property(nonatomic, strong, readonly) NSString *path;
@property(nonatomic, assign) NSInteger width;
@property(nonatomic, assign) NSInteger height;
@property(nonatomic, assign) NSInteger rotate;
@property(nonatomic, assign) double durationMs;
@property(nonatomic, assign) float frameRate;
@property(nonatomic, assign) float frameDuration;
@end

@class CGMetalVideoInput;
@protocol CGMetalVideoReadDelegate <NSObject>

- (void)videoOutput:(CGMetalVideoInput *)output onProgress:(float)progress;

- (void)videoOutputFinished;

@end

@interface CGMetalVideoInput : CGMetalOutput

@property (readwrite, nonatomic, assign) id <CGMetalVideoReadDelegate>delegate;

@property (nonatomic, assign)CGMetalVideoInfo *videoInfo;

- (instancetype)initWithURL:(NSURL *)url pixelFormat:(CGPixelFormat)pixelFormat;

- (void)cancel;

@end

@interface CGMetalVideoDecoder : NSObject {
}
- (instancetype)initWithFormat:(CGPixelFormat)pixelFormat;

- (void)loadResource:(NSString *)filePath;

- (void)copyNextPixelbuffer:(void (^)(_Nullable CVPixelBufferRef pixelBuffer, int index, float pts))processHandler
                            finishHandler:(void (^)(BOOL isCancel))finishHandler;

- (void)cancel;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
