//
//  CGMetalSourceController.m
//  CGPaint
//
//  Created by Jason on 2021/5/31.
//

#import "CGMetalSourceController.h"
#import "CGMetalListController.h"
#import "CGMetalCameraController.h"
#import "CGMetalVideoController.h"
#import "CGMetalEncodeController.h"
#import "CGMetalShowController.h"

@interface CGMetalSourceController ()
{
    NSArray *_inputList;
}
@end

@implementation CGMetalSourceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.title = @"CGMetal";

    _inputList = @[@"camera input",
                   @"data input",
                   @"image input",
                   @"pixel input",
                   @"video input",
                   @"video encode",
                   @"video decode",
                   @"effect"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _inputList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSInteger index = [indexPath row];
    cell.textLabel.text = _inputList[index];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = _inputList[indexPath.row];
    if ([type isEqualToString:@"camera input"]) {
        CGMetalCameraController *vc = [[CGMetalCameraController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    } else if ([type isEqualToString:@"data input"]) {
        CGMetalShowController *vc = [[CGMetalShowController alloc] init];
        vc.inputType = CG_RAWDATA;
        vc.filterType = CGMetalBasicModeSoul;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([type isEqualToString:@"image input"]) {
        CGMetalShowController *vc = [[CGMetalShowController alloc] init];
        vc.inputType = CG_IMAGE;
        vc.filterType = CGMetalBasicModeSoul;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([type isEqualToString:@"pixel input"]) {
        CGMetalShowController *vc = [[CGMetalShowController alloc] init];
        vc.inputType = CG_PIXELBUFFER;
        vc.filterType = CGMetalBasicModeSoul;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([type isEqualToString:@"video input"]) {
        CGMetalVideoController *vc = [[CGMetalVideoController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([type isEqualToString:@"video encode"]) {
        CGMetalEncodeController *vc = [[CGMetalEncodeController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([type isEqualToString:@"video decode"]) {

    } else if ([type isEqualToString:@"effect"]) {
        CGMetalListController *vc = [[CGMetalListController alloc] initWithStyle:(UITableViewStyleGrouped)];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
