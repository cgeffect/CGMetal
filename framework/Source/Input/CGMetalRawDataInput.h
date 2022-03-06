//
//  CGMetalRawDataInput.h
//  CGMetal
//
//  Created by Jason on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "CGMetalOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGMetalRawDataInput : CGMetalOutput

- (instancetype)initWithFormat:(CGDataFormat)dataFormat;

- (void)uploadByte:(UInt8 *)byte
            byteSize:(CGSize)byteSize;

- (void)updateByte:(UInt8 *)byte
          byteSize:(CGSize)byteSize;

@end

NS_ASSUME_NONNULL_END
