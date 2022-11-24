//
//  CGMetalListController.m
//  CGPaint
//
//  Created by CGPaint on 2021/5/19.
//

#import "CGMetalListController.h"
#import "CGMetalShowController.h"

@interface CGMetalListController ()

@end

@implementation CGMetalListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUMBERS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSInteger index = [indexPath row];
    NSString *name = @"";
    switch (index) {
        case CGMetalBasicModeOrigin: name = @"CGMetalBasicModeOrigin"; break;
        case CGMetalBasicModeGray: name = @"CGMetalBasicModeGray"; break;
        case CGMetalBasicModeShake: name = @"CGMetalBasicModeShake"; break;
        case CGMetalBasicModeWobble: name = @"CGMetalBasicModeWobble"; break;
        case CGMetalBasicModeSoul: name = @"CGMetalBasicModeSoul"; break;
        case CGMetalBasicModeGlitch: name = @"CGMetalBasicModeGlitch"; break;
        case CGMetalBasicModeFlash: name = @"CGMetalBasicModeFlash"; break;
        case CGMetalBasicModeColor: name = @"CGMetalBasicModeColor"; break;
        case CGMetalBasicModeFlipX: name = @"CGMetalBasicModeFlipX"; break;
        case CGMetalBasicModeFlipY: name = @"CGMetalBasicModeFlipY"; break;
        case CGMetalBasicModeZoom: name = @"CGMetalBasicModeZoom"; break;
        case CGMetalBasicModeRotate: name = @"CGMetalBasicModeRotate"; break;
        case CGMetalBasicModeTranslation: name = @"CGMetalBasicModeTranslation"; break;
        case CGMetalBasicModeProjection: name = @"CGMetalBasicModeProjection"; break;
    }
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGMetalShowController *vc = [[CGMetalShowController alloc] init];
    vc.inputType = CG_IMAGE;
    vc.filterType = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
