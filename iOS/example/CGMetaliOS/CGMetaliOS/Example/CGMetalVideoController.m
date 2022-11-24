//
//  CGMetalVideoController.m
//  CGPaint
//
//  Created by Jason on 2021/5/31.
//

#import "CGMetalVideoController.h"
#ifdef SOURCE_COMPILE
#import "CGMetal.h"
#else
#import <CGMetal/CGMetal.h>
#endif

@interface CGMetalVideoController ()
{
    CGMetalPlayerInput *_inputSource;
}
@end

@implementation CGMetalVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"CG_VIDEO";
    self.view.backgroundColor = UIColor.whiteColor;
    
    CGMetalUIViewOutput *_metalView = [[CGMetalUIViewOutput alloc] initWithFrame:self.view.bounds];
    _metalView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_metalView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"leftScaleAlpha" ofType:@"mp4"];
    _inputSource = [[CGMetalPlayerInput alloc] initWithURL:[NSURL fileURLWithPath:path] pixelFormat:(CGPixelFormatNV12)];
    _inputSource.isLoopPlay = YES;
    CGMetalBasic *filter = [[CGMetalBlendScaleAlpha alloc] initWithAlphaMode:(CGMetalBlendAlphaModeLeftAlpha)];
    
    _metalView.alphaChannelMode = CGMetalAlphaModeScaleAlpha;
    [_inputSource addTarget:filter];
    [filter addTarget:_metalView];
    [_inputSource play];
    
}

- (void)dealloc
{

}
@end
