//
//  MTLMetalCompute.h
//  CGMetal
//
//  Created by Jason on 2021/12/11.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(11.0), ios(14.0))
@interface MTLMetalCompute : NSObject
@property(nonatomic, strong, readonly)MTLComputePassDescriptor *computePassDescriptor;

@property(nonatomic, assign, readonly)id<MTLComputePipelineState>computePipelineState;

- (instancetype)initWithCompute:(NSString *)compute
                          index:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
