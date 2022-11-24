//
//  CGMetalListController.h
//  CGPaint
//
//  Created by CGPaint on 2021/5/19.
//

#import <UIKit/UIKit.h>
#import "CGMetalShowController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalListController : UITableViewController

@property(nonatomic, assign)CGRInputType inputType;
@property(nonatomic, strong)NSString *name;

@end

NS_ASSUME_NONNULL_END
