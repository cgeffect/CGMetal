//
//  CGMetalChainController.m
//  MetaliOS
//
//  Created by Jason on 2022/5/29.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#import "CGMetalChainController.h"
#ifdef SOURCE_COMPILE
#import "CGMetal.h"
#else
#import <CGMetal/CGMetal.h>
#endif

@interface CGMetalChainController ()
{
    CGMetalOutput *_inputSource;
    CGMetalUIViewOutput * _metalView;
    UIImage *_sourceImage;
    CGMetalImageOutput *_targetOutput;
    
    CGMetalSoul *soul;
    CGMetalGlitch *glitch;
}

@end

@implementation CGMetalChainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _metalView = [[CGMetalUIViewOutput alloc] initWithFrame:CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width)];
    _metalView.backgroundColor = UIColor.redColor;
    [self.view addSubview:_metalView];
    
    UISlider *slide = [[UISlider alloc] initWithFrame:CGRectMake(30, UIScreen.mainScreen.bounds.size.height - 100, UIScreen.mainScreen.bounds.size.width - 60, 50)];
    slide.minimumValue = 0;
    slide.maximumValue = 1;
    [slide addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slide];
    
    _inputSource = [[CGMetalImageInput alloc] initWithImage:[UIImage imageNamed:@"rgba"]];
    simd_float1 value = {0.3};
    soul = [[CGMetalSoul alloc] init];
    glitch = [[CGMetalGlitch alloc] init];
    [glitch setInValue1:value];
    [soul setInValue1:value];

    [_inputSource addTarget:soul];
    [soul addTarget:glitch];
    [glitch addTarget:_metalView];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (true) {
            @autoreleasepool {
                usleep(30 * 1000);
                [self->_inputSource requestRender];
            }
        }
    });
}

- (void)valueChange:(UISlider *)slide {
//    [_inputSource removeAllTargets];
//    [soul removeAllTargets];
//
//    [_inputSource addTarget:soul];
//    [soul addTarget:_metalView];
    for (int i = 0; i < 100; i++) {
        [_inputSource requestRender];
    }

}

@end
