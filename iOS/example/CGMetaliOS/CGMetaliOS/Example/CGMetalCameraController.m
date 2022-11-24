//
//  CGMetalCameraController.m
//  CGMetaliOS
//
//  Created by Jason on 2021/12/25.
//

#import "CGMetalCameraController.h"
#ifdef SOURCE_COMPILE
#import "CGMetal.h"
#else
#import <CGMetal/CGMetal.h>
#endif
#import "CGPreviewController.h"

@interface CGMetalCameraController ()<CGMetalCaptureDelegate>
{
    CGMetalUIViewOutput *_metalView;
    CGMetalPixelBufferInput *_inputSource;
    CGMetalBasic<CGMetalInput> *filter;
    CGMetalFlipX *_flipX;
    CGMetalCameraInput *_cameraInput;
    CGMetalVideoOutput *_videoOut;
}

@end

@implementation CGMetalCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"CG_VIDEO";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIBarButtonItem *take = [[UIBarButtonItem alloc] initWithTitle:@"take" style:(UIBarButtonItemStyleDone) target:self action:@selector(takePhoto)];
    UIBarButtonItem *toggle = [[UIBarButtonItem alloc] initWithTitle:@"switch" style:(UIBarButtonItemStyleDone) target:self action:@selector(toggle)];
    UIBarButtonItem *start = [[UIBarButtonItem alloc] initWithTitle:@"start" style:(UIBarButtonItemStyleDone) target:self action:@selector(start)];
    UIBarButtonItem *end = [[UIBarButtonItem alloc] initWithTitle:@"end" style:(UIBarButtonItemStyleDone) target:self action:@selector(end)];
    self.navigationItem.rightBarButtonItems = @[take, toggle, start, end];
    
    _metalView = [[CGMetalUIViewOutput alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    _metalView.backgroundColor = UIColor.blackColor;
    _metalView.contentMode = CGMetalContentModeScaleAspectFit;
    [self.view addSubview:_metalView];
    
    [CGMetalCameraInput checkCameraAuthor];
    [CGMetalCameraInput checkMicrophoneAuthor];
    filter = [[CGMetalShake alloc] init];
    simd_float1 v = {2};
    [filter setInValue1:v];

    NSURL *outUrl = [NSURL fileURLWithPath:[self createFile:@"out.mp4"]];
    CGMetalVideoOutput *videoOut = [[CGMetalVideoOutput alloc] initWithURL:outUrl];
    videoOut.isManual = YES;
    CGMetalVideoInfo *info = [[CGMetalVideoInfo alloc] init];
    info.width = 1080;
    info.height = 1920;
    info.frameRate = 30;
    
    CGMetalEncodeParam *encodeParam = [[CGMetalEncodeParam alloc] init];
    encodeParam.srcWidth = (int)info.width;
    encodeParam.srcHeight = (int)info.height;
    encodeParam.videoRate = info.frameRate;
    videoOut.encodeParam = encodeParam;
    _videoOut = videoOut;
    
    _cameraInput = [[CGMetalCameraInput alloc] initWithType:(CGMetalCaptureTypeVideo)];
    _cameraInput.delegate = self;
    [_cameraInput addTarget:filter];
    [filter addTarget:videoOut];
    [filter addTarget:_metalView];
    [_cameraInput startRunning];
    
}

- (void)takePhoto {
    [_cameraInput takePhoto];
}

- (void)toggle {
    [_cameraInput changeCamera];
}

- (void)start {
    [_videoOut startRecord];
}
- (void)end {
    [_videoOut endRecord];
}
- (void)captureAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

- (void)captureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

- (void)takePhotoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

- (void)takePhotoData:(NSData *)photoData {
    UIImage *image = [UIImage imageWithData:photoData];
    CGPreviewController *vc = [[CGPreviewController alloc] init];
    vc.image = image;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc {

}
- (NSString *)createFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *tmpPath = [path stringByAppendingPathComponent:@"temp"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString* outFilePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%@", (int)time, fileName]];
    return outFilePath;
}
@end
