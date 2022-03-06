//
//  CGMetalEncodeController.m
//  CGMetaliOS
//
//  Created by Jason on 2021/12/26.
//

#import "CGMetalEncodeController.h"
#ifdef SOURCE_COMPILE
#import "CGMetal.h"
#else
#import <CGMetalOS/CGMetalOS.h>
#endif

@interface CGMetalEncodeController ()<CGMetalVideoReadDelegate>
{
    CGMetalBasic<CGMetalInput> *filter;
    CGMetalVideoOutput *_surfaceOutput;
    CGMetalVideoInput *_videoInput;
}
@end

@implementation CGMetalEncodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hevc_alpha" ofType:@"mov"];
    NSURL *srcUrl = [NSURL fileURLWithPath:path];
    NSURL *outUrl = [NSURL fileURLWithPath:[self creatFile:@"out.mp4"]];
    _videoInput = [[CGMetalVideoInput alloc] initWithURL:srcUrl pixelFormat:CGPixelFormatNV12];
    _videoInput.delegate = self;
    _surfaceOutput = [[CGMetalVideoOutput alloc] initWithURL:outUrl];
    
    CGMetalEncodeParam *encodeParam = [[CGMetalEncodeParam alloc] init];
    encodeParam.srcWidth = (int)_videoInput.videoInfo.width;
    encodeParam.srcHeight = (int)_videoInput.videoInfo.height;
    encodeParam.frameCount = _videoInput.videoInfo.frameRate * (_videoInput.videoInfo.durationMs / 1000);
    encodeParam.videoRate = _videoInput.videoInfo.frameRate;
    _surfaceOutput.encodeParam = encodeParam;
    
    filter = [[CGMetalShake alloc] init];
    vec_float1 v = {2};
    [filter setInValue1:v];
    [_videoInput addTarget:filter];
    [filter addTarget:_surfaceOutput];
    [_videoInput requestRender];
}

- (NSString *)creatFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *tmpPath = [path stringByAppendingPathComponent:@"temp"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString* outFilePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%@", (int)time, fileName]];
    return outFilePath;
}

- (void)videoOutput:(CGMetalVideoInput *)output onProgress:(float)progress {
    
}

- (void)videoOutputFinished {
    
}
- (void)dealloc {
    
}
@end
