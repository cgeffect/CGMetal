//
//  CGPreviewController.m
//  CGPaint
//
//  Created by Jason on 2021/5/23.
//

#import "CGPreviewController.h"

@interface CGPreviewController ()

@end

@implementation CGPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.center = self.view.center;
    [self.view addSubview:imgView];
    
    imgView.image = _image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
