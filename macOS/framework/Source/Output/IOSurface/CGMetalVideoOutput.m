//
//  CGMetalVideoSurfaceOutput.m
//  CGMetal
//
//  Created by Jason on 2021/12/1.
//

#import <CGMetalMac/CGMetalVideoOutput.h>
#import <CGMetalMac/CGMetalPixelBufferSurfaceOutput.h>

@interface CGMetalVideoOutput ()<CGVideoEncoderDelegate, CGMetalRenderOutputDelegate>
{
    BOOL _isStart;
}
@property(nonatomic, strong)CGMetalVideoEncoder *videoEncode;
@property(nonatomic, strong)NSURL *dstURL;
@property(nonatomic, strong)CGMetalPixelBufferSurfaceOutput *surfaceOutput;
@end

@implementation CGMetalVideoOutput

@synthesize inTexture = _inTexture;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isManual = NO;
        self->_videoEncode = [[CGMetalVideoEncoder alloc] init];
        self->_videoEncode.delegate = self;

        _surfaceOutput = [[CGMetalPixelBufferSurfaceOutput alloc] init];
        _surfaceOutput.delegate = self;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)dstURL
{
    self = [self init];
    if (self) {
        _dstURL = dstURL;
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:dstURL error:&error];
        NSLog(@"dstURL: %@", dstURL.relativePath);
    }
    return self;
}

- (void)newTextureAvailable:(nonnull CGMetalTexture *)inTexture {
    _inTexture = inTexture;
    if (!_isManual) {
        [_surfaceOutput newTextureAvailable:inTexture];
    }
}

- (void)startRecord {
    if (_isManual) {
        _encodeParam.frameCount = INT_MAX;
    }
    _isManual = NO;
}

- (void)endRecord {
    _isManual = YES;
    [self stopOutput];
}

- (void)stopOutput {
    [_videoEncode stop];
}

#pragma mark - CGMetalRenderOutputDelegate
- (void)onRenderCompleted:(CGMetalPixelBufferSurfaceOutput *)thiz receivedPixelBufferFromTexture:(CVPixelBufferRef)pixelBuffer {
    if (_isStart == NO) {
        _encodeParam.savePath = _dstURL.relativePath;
        [self.videoEncode ready:_encodeParam];
        _isStart = YES;
    }

    if (pixelBuffer == NULL) {
        NSLog(@"Encode Param is Nil");
        return;
    }

    [self.videoEncode append:pixelBuffer];
}

#pragma mark - CGVideoEncoderDelegate

@end

@import VideoToolbox;
@import AVFoundation;

typedef NS_ENUM (NSInteger, CGMetelEncodeStatus) {
    CGMetelEncodeStatusNone = 0,
    CGMetelEncodeStatusStopped = 1,
    CGMetelEncodeStatusEncoding = 2
};

@interface CGMetalVideoEncoder () {
    int _succCount, _failCount, _repeatCount;
    dispatch_semaphore_t _semLock;
}
@property(nonatomic, assign)BOOL encodeFail;
@property(nonatomic, assign)BOOL encodeOK;
@property(nonatomic, assign)CGSize videSize;
@property(nonatomic, assign)int encodedFrameCount;
@property(nonatomic, assign)CGMetelEncodeStatus status;
@property(nonatomic, assign)BOOL startedSession;
@property(nonatomic, strong)AVAssetWriter *assetWriter;
@property(nonatomic, strong)AVAssetWriterInput *assetWriterInput;
@property(nonatomic, strong)AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;
@property(nonatomic, strong)CGMetalEncodeParam *encodeParam;
@property(nonatomic, assign)NSTimeInterval costTime;
@end

@implementation CGMetalVideoEncoder

- (instancetype)init {
    self = [super init];
    if (self) {
        _expectsMediaDataInRealTime = NO;
        _encodedFrameCount = 0;
        _semLock = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)ready:(CGMetalEncodeParam *)param {
    _encodeParam = param;
    if (_status == CGMetelEncodeStatusEncoding) {
        return;
    }
    _videSize = CGSizeMake(param.srcWidth, param.srcHeight);
    BOOL isOK = [self prepareAssetWriter:[NSURL fileURLWithPath:param.savePath]];
    if (isOK == NO) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(encoder:onError:)]) {
            [self.delegate encoder:self onError:-1];
        }
        _encodeFail = YES;
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStart:)]) {
        [self.delegate onStart:self];
    }
    _status = CGMetelEncodeStatusEncoding;
    _costTime = [[NSDate date] timeIntervalSince1970];
}

- (BOOL)prepareAssetWriter:(NSURL *)saveURL {
    @autoreleasepool {
        _encodeFail = false;
        NSError *error = nil;
        //saveURL不需要自己创建文件,AVAssetWriter会自动创建
        self->_assetWriter = [[AVAssetWriter alloc] initWithURL:saveURL fileType:AVFileTypeMPEG4 error:&error];
        self->_assetWriter.shouldOptimizeForNetworkUse = false;
        self->_assetWriter.movieFragmentInterval = kCMTimeZero;
        int bitPerSec = self->_videSize.width * self->_videSize.height * 4;
        NSDictionary *outputSettings = nil;
        NSDictionary *compressionProperties = nil;
        compressionProperties = @{
            AVVideoAverageBitRateKey: @(bitPerSec),//only h264
            AVVideoMaxKeyFrameIntervalKey: @(7200), //only h264
            AVVideoMaxKeyFrameIntervalDurationKey:@(240),//only h264
            AVVideoAllowFrameReorderingKey: @(YES),
            AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel
        };
        outputSettings = @{
            AVVideoCodecKey: AVVideoCodecTypeH264,
           AVVideoWidthKey: @(self->_videSize.width),
           AVVideoHeightKey: @(self->_videSize.height),
           AVVideoCompressionPropertiesKey: compressionProperties
       };
        
        if ([self->_assetWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo]) {
            self->_assetWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
            if ([self->_assetWriter canAddInput:self->_assetWriterInput]) {
                [self->_assetWriter addInput:self->_assetWriterInput];
            }
            self->_assetWriterInput.expectsMediaDataInRealTime = _expectsMediaDataInRealTime;
        } else {
            return NO;
        }
        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary
                dictionaryWithObjectsAndKeys:@(kCVPixelFormatType_32BGRA), kCVPixelBufferPixelFormatTypeKey,
                                             @((int) self->_videSize.width), kCVPixelBufferWidthKey,
                                             @((int) self->_videSize.height), kCVPixelBufferHeightKey,
                        nil];
        _pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        if (self->_assetWriterInput == NULL) {
            NSString *exceptionReason = [NSString stringWithFormat:@"sample buffer create failed "];
            NSLog(@"writerInput %@", exceptionReason);
        }
        BOOL success = [self->_assetWriter startWriting];
        if (!success) {
            error = self->_assetWriter.error;
            NSLog(@"startWriting %@", error);
            return NO;
        }
        return success;
    }
}

- (void)stop {
    _encodeOK = YES;
//    NSLog(@"total encode count: %d, once encode count: %d, repeat encode count: %d, fail encode count: %d", _encodedFrameCount, _succCount, _repeatCount, _failCount);
//    NSLog(@"encode video costTime = %f s", ([[NSDate date] timeIntervalSince1970] - _costTime));
    //生成视频
    if (_assetWriter.status != AVAssetWriterStatusWriting) {
        NSLog(@"encode exception do not call finishWritingWithCompletionHandler when status is %ld", (long)_assetWriter.status);
        return;
    }
    //标记写文件结束
    [self->_assetWriterInput markAsFinished];
    [self->_assetWriter finishWritingWithCompletionHandler:^{
        dispatch_semaphore_signal(self->_semLock);
    }];
    dispatch_semaphore_wait(_semLock, DISPATCH_TIME_FOREVER);
    if (!_encodeFail && self.delegate && [self.delegate respondsToSelector:@selector(encoder:onFinish:)]) {
        [self.delegate encoder:self onFinish:_encodeParam.savePath];
    }
}

#pragma mark - encode
- (void)append:(CVPixelBufferRef)pixelbuffer {
    if (_encodeOK || _encodeFail) {
        return;
    }

    int fps = _encodeParam.videoRate;
    int oneFrameDuration = 1000 / fps;
    int pts = _encodedFrameCount * oneFrameDuration;
    CMTime presentationTime = CMTimeMake(pts * 6, 6000);
    _encodedFrameCount++;

    NSTimeInterval startMs = [[NSDate date] timeIntervalSince1970];
    @autoreleasepool {
        [self appendVideoPixelBuffer:pixelbuffer withPresentationTime:presentationTime];
    }
    NSTimeInterval endMs = [[NSDate date] timeIntervalSince1970];
    NSLog(@"encode index:%d, total:%d, time: %f, costTime: %f",_encodedFrameCount, _encodeParam.frameCount, CMTimeGetSeconds(presentationTime) * 1000, (endMs - startMs) * 1000);
    float progress = self->_encodedFrameCount * 1.0f /self-> _encodeParam.frameCount;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(encoder:onProgress:)]) {
            [self.delegate encoder:self onProgress:MIN(1, progress)];
        }
    });
}

- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime {
    if (pixelBuffer) {
        @autoreleasepool {
            if (!self->_startedSession && _assetWriter.status == AVAssetWriterStatusWriting) {
                [self->_assetWriter startSessionAtSourceTime:presentationTime];
                self->_startedSession = YES;
            }
            AVAssetWriterInput *writerInput = self->_assetWriterInput;
            BOOL isComplete = false;
            int loopCount = 0;
            NSTimeInterval costTime = [[NSDate date] timeIntervalSince1970] * 1000;
            while (!isComplete && loopCount < 50) {
                if (writerInput.readyForMoreMediaData) {
                    BOOL success = false;
                    @try {
                        success = [_pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];
                    } @catch (NSException *exception) {
                        [self encodeOnStop];
                        _encodeFail = true;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(encoder:onError:)]) {
                            [self.delegate encoder:self onError:-1];
                        }
                        break;
                    } @finally {

                    }
                    if (success) {
                        isComplete = true;
                    } else {
                        NSLog(@"encode fail: %@", self->_assetWriter.error);
                        isComplete = false;
                    }
                    break;
                } else {
                    NSLog(@"input not ready for more media data, dropping buffer");
                    isComplete = false;
                    loopCount++;
                    usleep(5 * 1000);
                }
            }
            if (isComplete) {
                if (loopCount) {
                    self->_repeatCount++;
                    costTime = [[NSDate date] timeIntervalSince1970] * 1000 - costTime;
                    NSLog(@"encode once success cost time: %f ms, loop encode count %ld", (float) costTime, (long) loopCount);
                } else {
                    self->_succCount++;
                }
            } else {
                self->_failCount++;
                NSLog(@"encode once fail cost time: %f ms, loop encode count %ld", (float) costTime, (long) loopCount);
            }
        }
    }
}

- (void)destroy {
    NSLog(@"CGMetalVideoEncoder destroy");
    if (_assetWriter) {
        [self encodeOnStop];
        _assetWriter = nil;
    }
    _assetWriterInput = nil;
    if (_semLock) {
        dispatch_semaphore_signal(self->_semLock);
        _semLock = NULL;
    }
    _status = CGMetelEncodeStatusStopped;
}

- (void)encodeOnStop {
    NSLog(@"encodeOnStop");
    if (_assetWriter.status != AVAssetWriterStatusFailed || _assetWriter.status != AVAssetWriterStatusCompleted) {
        [_assetWriter cancelWriting];
    }
    _status = CGMetelEncodeStatusStopped;
}

- (void)dealloc {
    [self destroy];
    NSLog(@"CGMetalVideoEncoder dealloc");
}

// The function returns the max allowed sample rate (pixels per second) that
// can be processed by given encoder with `profile_level_id`.
// See https://www.itu.int/rec/dologin_pub.asp?lang=e&id=T-REC-H.264-201610-S!!PDF-E&type=items
// for details.
NSUInteger GetMaxSampleRate(CFStringRef profile_level_id) {
    if (profile_level_id == kVTProfileLevel_H264_Baseline_3_0) {
        return 10368000;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_3_1) {
        return 27648000;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_3_2) {
        return 55296000;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_4_0
               || profile_level_id == kVTProfileLevel_H264_Baseline_4_1) {
        return 62914560;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_4_2) {
        return 133693440;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_5_0) {
        return 150994944;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_5_1) {
        return 251658240;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_5_2) {
        return 530841600;
    } else if (profile_level_id == kVTProfileLevel_H264_Baseline_AutoLevel) {
        // Zero means auto rate setting.
        return 0;
    }
    return 0;
}

CFArrayRef getDataRateLimit(int bitrateBps) {
    float kLimitToAverageBitRateFactor = 1.5;
    int64_t dataLimitBytesPerSecondValue = (bitrateBps * kLimitToAverageBitRateFactor / 8);
    CFNumberRef bytesPerSecond = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &dataLimitBytesPerSecondValue);
    int64_t oneSecondValue = 1;
    CFNumberRef oneSecond = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &oneSecondValue);
    const void *nums[2] = {bytesPerSecond, oneSecond};
    CFArrayRef dataRateLimits = CFArrayCreate(NULL, nums, 2, &kCFTypeArrayCallBacks);
    if (bytesPerSecond) {
        CFRelease(bytesPerSecond);
    }
    if (oneSecond) {
        CFRelease(oneSecond);
    }
    return dataRateLimits;
}

@end


@implementation CGMetalEncodeParam

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end
