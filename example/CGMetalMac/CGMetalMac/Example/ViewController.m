//
//  ViewController.m
//  CGMetalMac
//
//  Created by Jason on 2021/12/2.
//

#import "ViewController.h"
#import "CGMetalCustomView.h"
#import <CGMetalMac/CGMetalMac.h>

@interface ViewController ()<NSTableViewDelegate, NSTableViewDataSource>
{
    CGMetalCustomView *_customView;
    NSArray *_managerList;
    CGMetalOutput *_inputSource;
    CGMetalNSViewOutput *_metalView;
    CGMetalGray *_gray;;
}
@property(nonatomic, strong)NSTableView *inputTab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _managerList = @[@"RGBA", @"Video"];
    
    _customView = [[CGMetalCustomView alloc] init];
    [self.view addSubview:_customView];
    [_customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    _inputTab = _customView.tabelView;
    _inputTab.delegate = self;
    _inputTab.dataSource = self;
    _inputTab.target = self;
    _inputTab.action = @selector(onTableCellClick);

    _metalView = [[CGMetalNSViewOutput alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width / 2, self.view.frame.size.height - 100)];
    _metalView.layer.backgroundColor = NSColor.clearColor.CGColor;
    [_customView.canvasView addSubview:_metalView];
    [_metalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_customView.canvasView);
    }];
    
    _gray = [[CGMetalGray alloc] init];
}

- (void)onTableCellClick {
    NSInteger colum = _inputTab.clickedColumn;
    NSInteger row = _inputTab.clickedRow;
    if (colum < 0 || row < 0) {
        return;
    }
    [_inputSource removeAllTargets];
    NSString *value = _managerList[row];
    if ([value isEqualToString:@"RGBA"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"rgba8_1125x1125" ofType:@"rgba"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        _inputSource = [[CGMetalRawDataInput alloc] initWithFormat:CGDataFormatRGBA];
        _metalView.alphaChannelMode = CGMetalAlphaModeRGBA;
        [((CGMetalRawDataInput *)_inputSource) uploadByte:(UInt8 *)data.bytes byteSize:CGSizeMake(1125, 1125)];
        [_inputSource addTarget:_gray];
        [_gray addTarget:_metalView];
        [_inputSource requestRender];
    } else if ([value isEqualToString:@"Video"]) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"overlay" ofType:@"mp4"];
//        _inputSource = [[CGMetalPlayerInputMac alloc] initWithURL:[NSURL fileURLWithPath:path] pixelFormat:(CGPixelFormatNV12)];
//        ((CGMetalPlayerInputMac *)_inputSource).isLoopPlay = YES;
//        CGMetalOverlayAlpha *alpha = [[CGMetalOverlayAlpha alloc] init];
//        _metalView.alphaChannelMode = CGMetalAlphaModeAloneAlpha;
//        [_inputSource addTarget:alpha];
//        [alpha addTarget:_flipX];
//        [_flipX addTarget:_metalView];
//        [((CGMetalPlayerInputMac *)_inputSource) play];
    }
}

// MARK: - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _managerList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return _managerList[row];
}

// MARK: - NSTableViewDelegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *iden = @"tableColumn.identifier";
    NSView *cell = [tableView makeViewWithIdentifier:iden owner:self];
    if (cell == nil) {
        cell = [[NSTextField alloc] init];
        ((NSTextField *)cell).editable = NO;
        cell.identifier = iden;
    }
    ((NSTextField *)cell).stringValue = _managerList[row];
    return cell;
}

@end

