//
//  CGMetalVideoPlayInput.m
//  CGMetal
//
//  Created by Jason on 2021/6/1.
//

#import "CGMetalPlayerInput.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CGMetalRawDataInput.h"

# define ONE_FRAME_DURATION 0.03
# define LUMA_SLIDER_TAG 0
# define CHROMA_SLIDER_TAG 1

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface CGMetalPlayerInput ()<AVPlayerItemOutputPullDelegate>
{
    dispatch_queue_t _myVideoOutputQueue;
    CGPixelFormat _pixelFormat;
    float _duration, _assetDuration;
}
@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)AVPlayerItemVideoOutput *videoOutput;
@property(nonatomic, strong)CADisplayLink *displayLink;
@property(nonatomic, strong)CGMetalOutput *output;
@end

@implementation CGMetalPlayerInput

- (instancetype)initWithURL:(NSURL *)URL pixelFormat:(CGPixelFormat)pixelFormat {
    self = [super init];
    if (self) {
        _pixelFormat = pixelFormat;
        _player = [[AVPlayer alloc] init];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [[self displayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self displayLink] setPaused:YES];
        OSType type = kCVPixelFormatType_32BGRA;
        if (_pixelFormat == CGPixelFormatBGRA) {
            type = kCVPixelFormatType_32BGRA;
        } else if (_pixelFormat == CGPixelFormatNV12) {
            type = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        }
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(type),
                                            (id) kCVPixelBufferIOSurfacePropertiesKey: @{},
                                            (id) kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
                                            (id) kCVPixelBufferMetalCompatibilityKey: @(YES)
        };
        self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
        [[self videoOutput] setDelegate:self queue:_myVideoOutputQueue];
        [self setupPlaybackForURL:URL];
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
            });
        }
    }];
}

#pragma mark - CADisplayLink Callback
- (void)displayLinkCallback:(CADisplayLink *)sender {
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    CMTime outputItemTime = [[self videoOutput] itemTimeForHostTime:nextVSync];
    int pts = CMTimeGetSeconds(outputItemTime) * 1000;
    [self decodePixelbufferWithCMTime:outputItemTime];
    if (pts > _assetDuration) {
        if (_isLoopPlay == NO) {
            [self pause];
        } else {
            [self pause];
            [_player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self play];
        }
    }
}

- (void)decodePixelbufferWithCMTime:(CMTime)outputItemTime {
    CVPixelBufferRef pixelBuffer = NULL;
    if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        pixelBuffer = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
    }

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
}

- (void)newTextureAvailable {
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget newTextureAvailable:self->_output.outTexture];
    }
}

- (void)requestRender {

}

- (void)play {
    [self.displayLink setPaused:NO];
    [self.player play];
}
- (void)pause {
    [self.displayLink setPaused:YES];
    [self.player pause];
}

- (void)resume {
    [self.displayLink setPaused:NO];
    [self.player play];
}

- (void)stop {
    [self.displayLink setPaused:YES];
    [self.player pause];
}

- (void)destroy {
    [self.displayLink invalidate];
    self.displayLink = nil;
    if (_player) {
        [_player pause];
        _player = nil;
    }
    if (_myVideoOutputQueue) {
        _myVideoOutputQueue = nil;
    }
    if (_videoOutput) {
        _videoOutput = nil;
    }
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self);
}

@end
#else
#endif
