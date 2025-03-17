//
//  MTLMetalCompute.m
//  CGMetal
//
//  Created by Jason on 2021/12/11.
//

#import "MTLMetalCompute.h"
#import <CGMetalMac/CGMetalDevice.h>

@implementation MTLMetalCompute
{
    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _computePipelineState;
    MTLComputePassDescriptor *_computePassDescriptor;
}

- (instancetype)initWithCompute:(NSString *)compute
                          index:(NSUInteger)index {
    if ((self = [super init])) {
        
        
        NSError *error = nil;
        // Load the shader files with a .metal file extension in the project
        id<MTLDevice> device = [CGMetalDevice sharedDevice].device;
        id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
        if (defaultLibrary == nil)
        {
            NSLog(@"Failed to find the default library.");
            return nil;
        }

        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:compute];
        if (addFunction == nil)
        {
            NSLog(@"Failed to find the adder function.");
            return nil;
        }

        // Create a compute pipeline state object.
        _computePipelineState = [device newComputePipelineStateWithFunction: addFunction error:&error];
        if (_computePipelineState == nil)
        {
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to created pipeline state object, error %@.", error);
            return nil;
        }
    }
    return self;
}

#pragma mark - getter
- (MTLComputePassDescriptor *)computePassDescriptor {
    return _computePassDescriptor;
}

- (id<MTLComputePipelineState>)computePipelineState {
    return _computePipelineState;
}

- (void)dealloc {
   
}

@end
