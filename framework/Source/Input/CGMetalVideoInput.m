//
//  CGMetalVideoReaderInput.m
//  CGMetal
//
//  Created by Jason on 2021/12/1.
//

#import "CGMetalVideoInput.h"
#import "CGMetalPixelBufferInput.h"

@implementation CGMetalVideoInfo

- (instancetype)initWithPath:(nonnull NSString *)path {
    self = [self init];
    if (self) {
        _path = path;
        NSURL *url = [NSURL fileURLWithPath:path];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        _durationMs = (NSUInteger) (CMTimeGetSeconds(asset.duration) * 1000);
        for (AVAssetTrack *track in asset.tracks) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                //帧间隔 毫秒
                _frameDuration = CMTimeGetSeconds(track.minFrameDuration) * 1000;
                //帧率 (1000 / 帧率 = 帧间隔)
                _frameRate = track.nominalFrameRate;
                _width = (NSInteger) track.naturalSize.width;
                _height = (NSInteger) track.naturalSize.height;
                _rotate = [CGMetalVideoInfo getVideoRotateFromTransform:track.preferredTransform];
            }
        }
    }
    return self;
}

+ (int)getVideoRotateFromTransform:(CGAffineTransform)transform {
    int degree = 0;
    if (transform.a == 0 && transform.b == 1 && transform.c == -1 && transform.d == 0) {
        // Portrait
        degree = 90;
    } else if (transform.a == 0 && transform.b == -1 && transform.c == 1 && transform.d == 0) {
        // PortraitUpsideDown
        degree = 270;
    } else if (transform.a == 1 && transform.b == 0 && transform.c == 0 && transform.d == 1) {
        // LandscapeRight 横屏home键在右边
        degree = 0;
    } else if (transform.a == -1 && transform.b == 0 && transform.c == 0 && transform.d == -1) {
        // LandscapeLeft 横屏home键在左边
        degree = 180;
    }
    return degree;
}

@end

@interface CGMetalVideoInput ()
{
    CGPixelFormat _pixelFormat;
    BOOL _isFinished;
    int _maxFrameCount;
}
@property(nonatomic, strong)NSString *videoPath;
@property(nonatomic, strong)CGMetalVideoDecoder *videoReader;
@property(nonatomic, strong)CGMetalOutput *output;
@end

@implementation CGMetalVideoInput

- (instancetype)initWithURL:(NSURL *)url pixelFormat:(CGPixelFormat)pixelFormat {
    self = [super init];
    if (self) {
        _videoPath = url.relativePath;
        _pixelFormat = pixelFormat;
        _videoReader = [[CGMetalVideoDecoder alloc] initWithFormat:pixelFormat];
        [_videoReader loadResource:_videoPath];
    }
    return self;
}

- (CGMetalVideoInfo *)videoInfo {
    CGMetalVideoInfo *videoInfo = [[CGMetalVideoInfo alloc] initWithPath:_videoPath];
    return videoInfo;
}

- (void)requestRender {
    [_videoReader copyNextPixelbuffer:^(CVPixelBufferRef  _Nullable pixelBuffer, int index, float pts) {
        @autoreleasepool {
            if (pixelBuffer != NULL) {
                if (self->_output == nil) {
                    self->_output = [[CGMetalPixelBufferInput alloc] initWithFormat:self->_pixelFormat];
                    [((CGMetalPixelBufferInput *)self->_output) uploadPixelBuffer:pixelBuffer];
                } else {
                    [(CGMetalPixelBufferInput *)self->_output updatePixelBuffer:pixelBuffer];
                }
                [self notifyNextTarget];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(videoOutput:onProgress:)]) {
                    [self.delegate videoOutput:self onProgress:(float)index / self->_maxFrameCount];
                }
            });
        }
    } finishHandler:^(BOOL isCancel) {
        if (isCancel) {
            self->_isFinished = NO;
        } else {
            self->_isFinished = YES;
            [self notifyNextTargetStop];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoOutput:onProgress:)]) {
                [self.delegate videoOutput:self onProgress:1];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoOutputFinished)]) {
                [self.delegate videoOutputFinished];
            }
        });
    }];
}

- (void)notifyNextTarget {
    for (id<CGMetalInput> currentTarget in self->_targets) {
        [currentTarget newTextureAvailable:self->_output.outTexture];
    }
}

- (void)notifyNextTargetStop {
    for (id<CGMetalInput> currentTarget in self->_targets) {
        [currentTarget stopOutput];
    }
}

- (void)cancel {
    if (_isFinished == NO) {
        [_videoReader cancel];
    }
    [_videoReader destroy];
}

@end


@implementation CGMetalVideoDecoder {
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_trackOutput;
    BOOL _isReading;
    BOOL _isReadCompleted;
    BOOL _flagCancel;
    int _videoWidth, _videoHeight;
    CGPixelFormat _pixelFormat;
}

- (instancetype)initWithFormat:(CGPixelFormat)pixelFormat {
    self = [super init];
    if (self) {
        _pixelFormat = pixelFormat;
    }
    return self;
}

- (void)prepareAssetReader:(NSString *)videoPath {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];

    _assetReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];

    if (nil == _assetReader) {
        return;
    }
    OSType type = kCVPixelFormatType_32BGRA;
    if (_pixelFormat == CGPixelFormatBGRA) {
        type = kCVPixelFormatType_32BGRA;
    } else if (_pixelFormat == CGPixelFormatNV12) {
        type = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    }
    NSDictionary *option = @{
            (NSString *) kCVPixelBufferPixelFormatTypeKey: @(type),
            (NSString *) kCVPixelBufferWidthKey: @(floorf(_videoWidth)),
            (NSString *) kCVPixelBufferHeightKey: @(floorf(_videoHeight)),
            (id) kCVPixelBufferIOSurfacePropertiesKey: @{},
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            (id)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
#else
#endif
            (id)kCVPixelBufferMetalCompatibilityKey:@(YES)
    };

    _trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:option];
    _trackOutput.alwaysCopiesSampleData = NO;
    [_assetReader addOutput:_trackOutput];
}

- (void)loadResource:(NSString *)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    for (AVAssetTrack *track in asset.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            _videoWidth = track.naturalSize.width;
            _videoHeight = track.naturalSize.height;
        }
    }
    [self prepareAssetReader:filePath];
}

- (void)copyNextPixelbuffer:(void (^)(CVPixelBufferRef _Nullable, int, float))processHandler finishHandler:(void (^)(BOOL))finishHandler {
    if (nil == _assetReader || nil == _trackOutput) {
        return;
    }
    int currentIndex = 1;
    BOOL isCancel = self->_flagCancel;
    [self->_assetReader startReading];
    while (self->_assetReader.status == AVAssetReaderStatusReading && !isCancel) {
        @autoreleasepool {
            CMSampleBufferRef smBuffer = [self->_trackOutput copyNextSampleBuffer];
            if (nil != smBuffer) {
                CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(smBuffer);
                CMTime time = CMSampleBufferGetPresentationTimeStamp(smBuffer);
                NSInteger pts = (NSInteger) (CMTimeGetSeconds(time) * 1000);
                NSLog(@"decode success index %ld, pts %ld", (long)currentIndex, (long)pts);
                if (nil != pixelBuffer && nil != processHandler) {
                    if (processHandler) {
                        processHandler(pixelBuffer, currentIndex, pts);
                    }
                    CVBufferRelease(pixelBuffer);
                }
            }
            currentIndex++;
            isCancel = self->_flagCancel;
        }
    }
    if (self->_assetReader.status == AVAssetReaderStatusCompleted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishHandler) {
                finishHandler(NO);
            }
        });
        self->_isReadCompleted = YES;
    }
    if (self->_flagCancel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != finishHandler) {
                finishHandler(YES);
            }
        });
    }
    [self destroy];
    self->_isReading = NO;
}

- (BOOL)checkVideoValid:(NSString *)path {
    if (nil == path) {
        return NO;
    }
    return YES;
}

- (void)cancel {
    _flagCancel = YES;
}

- (void)destroy {
    [self cancel];
    _assetReader = nil;
    _trackOutput = nil;
    NSLog(@"CGMetalVideoDecoder destroy");
}

- (void)dealloc {
    NSLog(@"CGMetalVideoDecoder dealloc");
}

@end
