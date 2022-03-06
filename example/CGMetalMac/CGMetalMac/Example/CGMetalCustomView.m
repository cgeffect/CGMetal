//
//  SKCustomView.m
//  CGMetalMac
//
//  Created by Jason on 2021/12/5.
//

#import "CGMetalCustomView.h"

@interface CGMetalCustomView ()
{
    NSScrollView *_scrollView;
    NSView *_canvas_View;
}
@end

@implementation CGMetalCustomView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tabelView = self.tabelView;
        _scrollView = [self getScrollView];
        [self addSubview:_scrollView];
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.width.mas_equalTo(300);
            make.bottom.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(20);
        }];
        _scrollView.documentView = _tabelView;
        
        _canvas_View = [[NSView alloc] init];
        _canvas_View.layer.backgroundColor = NSColor.redColor.CGColor;
        [self addSubview:_canvas_View];
        [_canvas_View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_scrollView.mas_right).offset(20);
            make.right.equalTo(self).offset(20);
            make.bottom.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(20);
        }];

    }
    return self;
}

- (NSScrollView *)getScrollView {
    NSScrollView *_scrollView = [[NSScrollView alloc] init];
    _scrollView.hasVerticalScroller = true;
    _scrollView.hasHorizontalScroller = false;
    _scrollView.focusRingType = NSFocusRingTypeNone;
    _scrollView.autohidesScrollers = true;
    _scrollView.borderType = NSBezelBorder;
    _scrollView.translatesAutoresizingMaskIntoConstraints = false;
    return _scrollView;
}

- (NSView *)canvasView {
    return _canvas_View;
}
- (NSTableView *)tabelView {
    if (_tabelView) {
        return _tabelView;
    }
    NSTableView *_tabelView = [[NSTableView alloc] init];
    NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@"input"];
    column1.title = @"输入";
    column1.minWidth = 300;

    [_tabelView addTableColumn:column1];
    _tabelView.allowsColumnReordering = NO;
//    _tabelView.autoresizesSubviews = true;
    _tabelView.focusRingType = NSFocusRingTypeNone;
    [_tabelView sizeLastColumnToFit];
    return _tabelView;
}

@end
