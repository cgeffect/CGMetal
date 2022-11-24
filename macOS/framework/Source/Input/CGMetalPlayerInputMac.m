//
//  CGMetalPlayerInputMac.m
//  CGMetal
//
//  Created by Jason on 2021/12/7.
//

#import "CGMetalPlayerInputMac.h"
#import "CGMetalPixelBufferInput.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

# define ONE_FRAME_DURATION 0.03
# define LUMA_SLIDER_TAG 0
# define CHROMA_SLIDER_TAG 1
static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface CGMetalPlayerInputMac ()<AVPlayerItemOutputPullDelegate>
{
    dispatch_queue_t _myVideoOutputQueue;
    CGPixelFormat _pixelFormat;
    float _duration, _interval, _assetDuration;
}
@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)AVPlayerItemVideoOutput *videoOutput;
@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, strong)CGMetalOutput *output;
@end

@implementation CGMetalPlayerInputMac

- (instancetype)initWithURL:(NSURL *)url pixelFormat:(CGPixelFormat)pixelFormat {
    self = [super init];
    if (self) {
        _pixelFormat = pixelFormat;
        _player = [[AVPlayer alloc] init];
        _interval = 30;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_interval / 1000 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        OSType type = kCVPixelFormatType_32BGRA;
        if (_pixelFormat == CGPixelFormatBGRA) {
            type = kCVPixelFormatType_32BGRA;
        } else if (_pixelFormat == CGPixelFormatNV12) {
            type = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        }
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(type)};
        self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
        [[self videoOutput] setDelegate:self queue:_myVideoOutputQueue];
        [self setupPlaybackForURL:url];
    }
    return self;
}

#pragma mark - Playback setup
- (void)setupPlaybackForURL:(NSURL *)URL {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:URL];
    AVAsset *asset = [item asset];
    _assetDuration = CMTimeGetSeconds(asset.duration) * 1000;
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [item addOutput:self.videoOutput];
                [self->_player replaceCurrentItemWithPlayerItem:item];
                self.timer.fireDate = [NSDate date];
            });
        }
    }];
}


- (void)updateProgress {
    if (_duration > _assetDuration) {
        _duration = 0;
    }
    _duration = _duration + _interval;
    float nextVSync = _duration;
    CMTime outputItemTime = CMTimeMake((int) nextVSync * 6, 6000);
//    NSLog(@"nextVSync %f", nextVSync);
    [_player seekToTime:outputItemTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if ([[self videoOutput] hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        if (pixelBuffer != NULL) {
            if (self->_output == nil) {
                self->_output = [[CGMetalPixelBufferInput alloc] initWithFormat:self->_pixelFormat];
                [((CGMetalPixelBufferInput *)self->_output) uploadPixelBuffer:pixelBuffer];
            } else {
                [(CGMetalPixelBufferInput *)self->_output updatePixelBuffer:pixelBuffer];
            }
            [self newTextureAvailable];
            CVPixelBufferRelease(pixelBuffer);
        }
    } else {
        
    }
}

- (void)newTextureAvailable {
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget newTextureAvailable:self->_output.outTexture];
    }
}
     
- (void)requestRender {
    [self play];
}

- (void)play {
    self.timer.fireDate = [NSDate date];
}
     
- (void)pause {
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)resume {
    self.timer.fireDate = [NSDate date];
}

- (void)stop {
    self.timer.fireDate = [NSDate distantFuture];
    [self.timer invalidate];
    self.timer = nil;
}


- (void)holdSeek:(BOOL)isSeek {
    if (isSeek) {
        [self pause];
    } else {
        [self resume];
    }
}
     
- (void)seekTo:(float)ptsMs {
    float seekPts = _assetDuration * ptsMs;
    CMTime outputItemTime = CMTimeMake((int) seekPts * 6, 6000);
    NSLog(@"seek %f", CMTimeGetSeconds(outputItemTime) * 1000);
    [_player seekToTime:outputItemTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if ([[self videoOutput] hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        if (pixelBuffer != NULL) {
            if (self->_output == nil) {
                self->_output = [[CGMetalPixelBufferInput alloc] initWithFormat:self->_pixelFormat];
                [((CGMetalPixelBufferInput *)self->_output) uploadPixelBuffer:pixelBuffer];
            } else {
                [(CGMetalPixelBufferInput *)self->_output updatePixelBuffer:pixelBuffer];
            }
            [self newTextureAvailable];
            CVPixelBufferRelease(pixelBuffer);
        }
    } else {
        
    }
}

- (void)dealloc {
    _player = nil;
    _myVideoOutputQueue = nil;
    NSLog(@"%@ dealloc", self);
}
@end
#endif

