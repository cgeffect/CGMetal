//
//  CGMetalController.m
//  CGPaint
//
//  Created by Jason on 2021/5/15.
//

#import "CGMetalShowController.h"
#import "CGPreviewController.h"
#import "CGMetalSourceProvider.h"
#ifdef SOURCE_COMPILE
#import "CGMetal.h"
#else
#import <CGMetal/CGMetal.h>
#endif

@interface CGMetalShowController ()<CGMetalOutputDelegate>
{
    CGMetalOutput *_inputSource;
    CGMetalBasic<CGMetalInput> *_filter;
    CGMetalUIViewOutput * _metalView;
    UIImage *_sourceImage;
    CGMetalImageOutput *_targetOutput;
}
@end

@implementation CGMetalShowController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];;
    
    _metalView = [[CGMetalUIViewOutput alloc] initWithFrame:CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width)];
    _metalView.backgroundColor = UIColor.redColor;
    [self.view addSubview:_metalView];
    
    [self setInputSource];
    UISlider *slide = [[UISlider alloc] initWithFrame:CGRectMake(30, UIScreen.mainScreen.bounds.size.height - 100, UIScreen.mainScreen.bounds.size.width - 60, 50)];
    slide.minimumValue = 0;
    slide.maximumValue = 1;
    [slide addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slide];
        
    _sourceImage = [UIImage imageNamed:@"rgba"];
    switch (_inputType) {
        case CG_RAWDATA:
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"rgba8_1125x1125" ofType:@"rgba"];
            NSData *rgba = [NSData dataWithContentsOfFile:path];
            _inputSource = [[CGMetalRawDataInput alloc] initWithFormat:CGDataFormatRGBA];
            [((CGMetalRawDataInput *)_inputSource) uploadByte:(UInt8 *)rgba.bytes byteSize:CGSizeMake(1125, 1125)];
            self.navigationItem.title = @"CG_RAWDATA";
        } break;
        case CG_IMAGE:
            _inputSource = [[CGMetalImageInput alloc] initWithImage:_sourceImage];
            self.navigationItem.title = @"CG_IMAGE";
            break;
        case CG_PIXELBUFFER:
        {
            self.navigationItem.title = @"CG_PIXELBUFFER";
            NSString *path = [[NSBundle mainBundle] pathForResource:@"nv12_1120x1120_bgra" ofType:@"yuv"];
            NSData *nv12 = [NSData dataWithContentsOfFile:path];
            CVPixelBufferRef pixel = [CGMetalSourceProvider pixelBufferCreate:kCVPixelFormatType_32BGRA width:1120 height:1120];
            [CGMetalSourceProvider create32BGRAPixelBufferWithNV12:(UInt8 *)nv12.bytes width:1120 height:1120 dstBuffer:pixel];
            _inputSource = [[CGMetalPixelBufferInput alloc] initWithFormat:CGPixelFormatBGRA];
            [((CGMetalPixelBufferInput *)_inputSource) uploadPixelBuffer:pixel];
            CVPixelBufferRelease(pixel);
        } break;
        default:
            break;
    }
    
    _targetOutput = [[CGMetalImageOutput alloc] init];
    _targetOutput.delegate = self;

    [self setupFilter];
}

- (void)setInputSource {
    NSArray *itemList = nil;
    if (_inputType == CG_RAWDATA) {
        itemList = @[@"RGBA", @"BGRA", @"NV21", @"NV12", @"I420"];
    } else if (_inputType == CG_PIXELBUFFER) {
        itemList = @[@"BGRA", @"NV12"];
    }
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:itemList];
    seg.frame = CGRectMake(0, CGRectGetMaxY(_metalView.frame) + 20, UIScreen.mainScreen.bounds.size.width, 50);
    [seg addTarget:self action:@selector(segAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:seg];
    seg.selectedSegmentIndex = 0;
}

- (void)segAction:(UISegmentedControl *)seg {
    if (seg.numberOfSegments == 5) {
        NSString *path = nil;
        CGDataFormat format = 0;
        CGSize size = CGSizeZero;
        if (seg.selectedSegmentIndex == 0) {
            path = [[NSBundle mainBundle] pathForResource:@"rgba8_1125x1125" ofType:@"rgba"];
            format = CGDataFormatRGBA;
            size = CGSizeMake(1125, 1125);
        } else if (seg.selectedSegmentIndex == 1) {
            path = [[NSBundle mainBundle] pathForResource:@"bgra8_1125x1125" ofType:@"bgra"];
            format = CGDataFormatBGRA;
            size = CGSizeMake(1125, 1125);
        } else if (seg.selectedSegmentIndex == 2) {
            path = [[NSBundle mainBundle] pathForResource:@"nv21_1120x1120" ofType:@"yuv"];
            format = CGDataFormatNV21;
            size = CGSizeMake(1120, 1120);
        } else if (seg.selectedSegmentIndex == 3) {
            path = [[NSBundle mainBundle] pathForResource:@"nv12_1120x1120" ofType:@"yuv"];
            format = CGDataFormatNV12;
            size = CGSizeMake(1120, 1120);
        } else if (seg.selectedSegmentIndex == 4) {
            path = [[NSBundle mainBundle] pathForResource:@"I420_1120x1120" ofType:@"yuv"];
            format = CGDataFormatI420;
            size = CGSizeMake(1120, 1120);
        }
        NSData *data = [NSData dataWithContentsOfFile:path];
        _inputSource = [[CGMetalRawDataInput alloc] initWithFormat:format];
        [((CGMetalRawDataInput *)_inputSource) uploadByte:(UInt8 *)data.bytes byteSize:size];
    } else {
        if (seg.selectedSegmentIndex == 0) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"nv12_1120x1120_bgra" ofType:@"yuv"];
            NSData *nv12 = [NSData dataWithContentsOfFile:path];
            CVPixelBufferRef pixel = [CGMetalSourceProvider pixelBufferCreate:kCVPixelFormatType_32BGRA width:1120 height:1120];
            [CGMetalSourceProvider create32BGRAPixelBufferWithNV12:(UInt8 *)nv12.bytes width:1120 height:1120 dstBuffer:pixel];
            _inputSource = [[CGMetalPixelBufferInput alloc] initWithFormat:CGPixelFormatBGRA];
            [((CGMetalPixelBufferInput *)_inputSource) uploadPixelBuffer:pixel];
            CVPixelBufferRelease(pixel);
        } else if (seg.selectedSegmentIndex == 1) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"nv12_1120x1120" ofType:@"yuv"];
            NSData *nv12 = [NSData dataWithContentsOfFile:path];
            CVPixelBufferRef pixel = [CGMetalSourceProvider create420Yp8_CbCr8PixelBufferWithNV12:(UInt8 *)nv12.bytes width:1120 height:1120];
            _inputSource = [[CGMetalPixelBufferInput alloc] initWithFormat:CGPixelFormatNV12];
            [((CGMetalPixelBufferInput *)_inputSource) uploadPixelBuffer:pixel];
            CVPixelBufferRelease(pixel);
        }
    }
    [self setupFilter];
}

- (void)setupFilter {
    [_inputSource removeAllTargets];
    switch (_filterType) {
        case CGMetalBasicModeOrigin: _filter = [[CGMetalBasic alloc] init]; break;
        case CGMetalBasicModeGray: _filter = [[CGMetalGray alloc] init]; break;
        case CGMetalBasicModeShake: _filter = [[CGMetalShake alloc] init]; break;
        case CGMetalBasicModeWobble: _filter = [[CGMetalWobble alloc] init]; break;
        case CGMetalBasicModeSoul: _filter = [[CGMetalSoul alloc] init]; break;
        case CGMetalBasicModeGlitch: _filter = [CGMetalGlitch new]; break;
        case CGMetalBasicModeFlash: _filter = [CGMetalFlashWhite new]; break;
        case CGMetalBasicModeColor: _filter = [[CGMetalColour alloc] init]; break;
        case CGMetalBasicModeFlipX: _filter = [CGMetalFlipX new]; break;
        case CGMetalBasicModeFlipY: _filter = [CGMetalFlipY new]; break;
        case CGMetalBasicModeZoom: _filter = [CGMetalZoom new]; break;
        case CGMetalBasicModeRotate: _filter = [CGMetalRotate new]; break;
        case CGMetalBasicModeTranslation: _filter = [CGMetalTranslation new]; break;
        case CGMetalBasicModeProjection: _filter = [CGMetalProjection new]; break;
        default:
            break;
    }
    [_inputSource addTarget:_filter];
    [_filter addTarget:_metalView];
    [_filter addTarget:_targetOutput];
    [_inputSource requestRender];
}

- (void)valueChange:(UISlider *)slide {
    simd_float1 value = {slide.value};
    [_filter setInValue1:value];
    [_inputSource requestRender];
}

- (void)save {
    [_targetOutput take];
}

- (void)imageRefOutput:(CGImageRef)imageRef {
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    CGPreviewController *preview = [[CGPreviewController alloc] init];
    preview.image = image;
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self.navigationController pushViewController:preview animated:YES];
}

- (void)dealloc
{
    
}

@end
