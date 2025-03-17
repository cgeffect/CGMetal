//
//  CGMetalCameraInput.m
//  CGMetal
//
//  Created by Jason on 2021/12/23.
//

#import <CGMetal/CGMetalCameraInput.h>
#import <CGMetal/CGMetalPixelBufferInput.h>

API_AVAILABLE(ios(10.0))
@interface CGMetalCameraInput ()<AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate>
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) dispatch_queue_t captureQueue;

//audio
@property (nonatomic, strong) AVCaptureDeviceInput *audioInputDevice;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;

//video
@property (nonatomic, weak) AVCaptureDeviceInput *videoInputDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *frontCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *backCamera;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;

//photo
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property(nonatomic, strong) CGMetalOutput *output;

@end

@implementation CGMetalCameraInput {
    CGMetalCaptureType _captureType;
}

- (instancetype)initWithType:(CGMetalCaptureType)type {
    self = [super init];
    if (self) {
        _captureType = type;
        _captureSession = [[AVCaptureSession alloc] init];
        _captureQueue = dispatch_queue_create("com.metal.capture.queue", NULL);
        _videoOrientation = AVCaptureVideoOrientationPortrait;
        [self prepare];
    }
    return self;
}

- (void)prepare {
    [self setupAudio];
    [self setupVideo];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080])  {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
}

- (void)startRunning {
    if (!self.isRunning) {
        self.isRunning = YES;
        [self.captureSession startRunning];
    }
}

- (void)stopRunning {
    if (self.isRunning) {
        self.isRunning = NO;
        [self.captureSession stopRunning];
    }
}

- (void)changeCamera {
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.videoInputDevice];
    [self.captureSession removeInput:self.audioInputDevice];
    if ([self.videoInputDevice isEqual: self.frontCamera]) {
        self.videoInputDevice = self.backCamera;
    }else{
        self.videoInputDevice = self.frontCamera;
    }
    [self.captureSession addInput:self.videoInputDevice];
    self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    self.videoConnection.videoOrientation = _videoOrientation;
    [self.captureSession commitConfiguration];
}

#pragma mark-init Audio/video
- (void)setupAudio {
    //麦克风设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //将audioDevice ->AVCaptureDeviceInput 对象
    self.audioInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    //音频输出
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    //配置
    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.audioInputDevice]) {
        [self.captureSession addInput:self.audioInputDevice];
    }
    if([self.captureSession canAddOutput:self.audioDataOutput]){
        [self.captureSession addOutput:self.audioDataOutput];
    }
    [self.captureSession commitConfiguration];
    
    self.audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (void)setupVideo{
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    NSArray *videoDevices = [captureDeviceDiscoverySession devices];
    //camera
    self.frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:videoDevices.lastObject error:nil];
    self.backCamera = [AVCaptureDeviceInput deviceInputWithDevice:videoDevices.firstObject error:nil];
    //front camera
    self.videoInputDevice = self.frontCamera;
    //video output
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    [self.videoDataOutput setVideoSettings:
     @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)}];
    
    // take photo
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];

    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.videoInputDevice]) {
        [self.captureSession addInput:self.videoInputDevice];
    }
    if([self.captureSession canAddOutput:self.videoDataOutput]){
        [self.captureSession addOutput:self.videoDataOutput];
    }
    if([self.captureSession canAddOutput:self.photoOutput]){
        [self.captureSession addOutput:self.photoOutput];
    }
    self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    self.videoConnection.videoOrientation = _videoOrientation;
    [self.captureSession commitConfiguration];

}

- (void)takePhoto {
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    AVCapturePhotoSettings* setting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    [self.photoOutput capturePhotoWithSettings:setting delegate:self];
}

-(void)destroyCaptureSession {
    if (self.captureSession) {
        [self.captureSession removeInput:self.audioInputDevice];
        [self.captureSession removeOutput:self.audioDataOutput];
        [self.captureSession removeInput:self.videoInputDevice];
        [self.captureSession removeOutput:self.videoDataOutput];
        [self.captureSession removeOutput:self.photoOutput];
    }
    self.captureSession = nil;
}

- (void)dealloc {
    [self destroyCaptureSession];
    _captureQueue = NULL;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == self.audioConnection) {
        [_delegate captureAudioSampleBuffer:sampleBuffer];
    } else if (connection == self.videoConnection) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (pixelBuffer != NULL) {
            if (self->_output == nil) {
                self->_output = [[CGMetalPixelBufferInput alloc] initWithFormat:CGPixelFormatNV12];
                [((CGMetalPixelBufferInput *)self->_output) uploadPixelBuffer:pixelBuffer];
            } else {
                [(CGMetalPixelBufferInput *)self->_output updatePixelBuffer:pixelBuffer];
            }
            [self notifyNextTarget];
        } else {

        }
        [_delegate captureVideoSampleBuffer:sampleBuffer];
    }
}

- (void)notifyNextTarget {
    for (id<CGMetalInput> currentTarget in self->_targets) {
        [currentTarget newTextureAvailable:self->_output.outTexture];
    }
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error  API_AVAILABLE(ios(10.0)) {    
    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(takePhotoData:)]) {
            [self.delegate takePhotoData:data];
        }
        
        if ([self.delegate respondsToSelector:@selector(takePhotoSampleBuffer:)]) {
            [self.delegate takePhotoSampleBuffer:photoSampleBuffer];
        }
    }
}

#pragma mark - 授权相关
/**
 *  麦克风授权
 *  0 ：未授权 1:已授权 -1：拒绝
 */
+ (int)checkMicrophoneAuthor{
    int result = 0;
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            }];
            result = 0;
            break;
        case AVAudioSessionRecordPermissionDenied:
            result = -1;
            break;
        case AVAudioSessionRecordPermissionGranted://允许
            result = 1;
            break;
        default:
            break;
    }
    return result;
}
/**
 *  摄像头授权
 *  0 ：未授权 1:已授权 -1：拒绝
 */
+ (int)checkCameraAuthor {
    int result = 0;
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoStatus) {
        case AVAuthorizationStatusNotDetermined://第一次
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
            }];
            break;
        case AVAuthorizationStatusAuthorized://已授权
            result = 1;
            break;
        default:
            result = -1;
            break;
    }
    return result;
}

- (BOOL)isFront {
    return self.videoInputDevice == self.frontCamera;
}

@end


