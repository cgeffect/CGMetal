//
//  CGMetalBasicTwo.h
//  CGMetalOS
//
//  Created by Jason on 2021/12/28.
//

#import <Foundation/Foundation.h>
#import "CGMetalBasic.h"

NS_ASSUME_NONNULL_BEGIN

//多纹理渲染可以使用多线程encode, 最后统一到buffer
@interface CGMetalBasicTwo : CGMetalOutput<CGMetalInput, CGMetalRenderPipeline>

@end

NS_ASSUME_NONNULL_END
