//
//  CGMetalMutilController.m
//  MetaliOS
//
//  Created by Jason on 2022/5/31.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#import "CGMetalMutilController.h"
#import "CGMetalSourceProvider.h"
#import <CGMetal/CGMetal.h>

@interface CGMetalMutilController ()
{
    CGMetalOutput *_inputSource;
    CGMetalBasic<CGMetalInput> *_filter;
    CGMetalUIViewOutput * _metalView;
    UIImage *_sourceImage;
    CGMetalImageOutput *_targetOutput;
}

@end

@implementation CGMetalMutilController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _metalView = [[CGMetalUIViewOutput alloc] initWithFrame:CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width)];
    _metalView.backgroundColor = UIColor.lightTextColor;
    [self.view addSubview:_metalView];
    
    UISlider *slide = [[UISlider alloc] initWithFrame:CGRectMake(30, UIScreen.mainScreen.bounds.size.height - 100, UIScreen.mainScreen.bounds.size.width - 60, 50)];
    slide.minimumValue = 0;
    slide.maximumValue = 1;
    [slide addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slide];
        
    
    CGMetalImageInput *input = [[CGMetalImageInput alloc] initWithImage:[UIImage imageNamed:@"rgba"]];
    input.outTexture.texIndex = 0;

    CGMetalImageInput *input1 = [[CGMetalImageInput alloc] initWithImage:[UIImage imageNamed:@"IMG"]];
    input1.outTexture.texIndex = 1;

    CGMetalTwoBasic *two = [[CGMetalTwoBasic alloc] init];
    [input addTarget:two];
    [input1 addTarget:two];
    [two addTarget:_metalView];

    [input1 requestRender];
    [input requestRender];
}

- (void)valueChange:(UISlider *)slide {

}

@end
