//
//  SKCustomView.h
//  CGMetalMac
//
//  Created by Jason on 2021/12/5.
//

#import <Cocoa/Cocoa.h>
#import "Masonry.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalCustomView : NSView
@property(nonatomic, strong)NSTableView *tabelView;
@property(nonatomic, strong, readonly)NSView *canvasView;
@end

NS_ASSUME_NONNULL_END
