//
//  CGMetalDevice.m
//  CGMetal
//
//  Created by Jason on 21/3/3.
//

#import "CGMetalDevice.h"
@import MetalPerformanceShaders;

@interface CGMetalDevice()
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLLibrary> _shaderLibrary;
    BOOL _metalPerformanceShadersAreSupported;
}

@end

@implementation CGMetalDevice

+ (CGMetalDevice *)sharedDevice;
{
    static dispatch_once_t pred;
    static CGMetalDevice *device = nil;
    
    dispatch_once(&pred, ^{
        device = [[[self class] alloc] init];
    });
    return device;
}

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _device = MTLCreateSystemDefaultDevice();
    if (!_device) {
        NSLog(@"Could not create Metal Device");
    }
    _metalPerformanceShadersAreSupported = MPSSupportsMTLDevice(_device);
#if TARGET_IPHONE_POD
    NSBundle *bunle = [NSBundle bundleForClass:[CGMetalDevice class]];
//    NSError *error = nil;
//    id<MTLLibrary> library =[_device newDefaultLibraryWithBundle:bunle error:&error];
    
    NSError *error = nil;
    NSString *libPath = [bunle pathForResource:@"default" ofType:@"metallib"];
    id<MTLLibrary> library = [_device newLibraryWithFile:libPath error:&error];
#else
//    id<MTLLibrary> library = [_device newDefaultLibrary];
    
    //framework里获取default.metallib, framework设置为dynamic, Embed & Sign
    NSBundle *bunle = [NSBundle bundleForClass:[CGMetalDevice class]];
    NSError *error = nil;
    id<MTLLibrary> library =[_device newDefaultLibraryWithBundle:bunle error:&error];
    
//    NSError *error = nil;
//    NSString *libPath = [bunle pathForResource:@"default" ofType:@"metallib"];
//    id<MTLLibrary> library = [_device newLibraryWithFile:libPath error:&error];

#endif
    _shaderLibrary = library;
    
    return self;
}

//create once
- (id<MTLCommandQueue>)commandQueue {
    if (_commandQueue) {
        return _commandQueue;
    }
    //MTLCommandQueue is expensive resources, you can reuse
    _commandQueue = [_device newCommandQueue];
    if (!_commandQueue) {
        NSLog(@"Could not create command queue");
    }
    return _commandQueue;
}
- (id<MTLDevice>)device {
    return _device;
}

- (id<MTLLibrary>)library {
    return _shaderLibrary;
}

+ (BOOL)supportsFastTextureUpload
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    return YES;
#endif
}

-(void) dealloc {
  
}
@end
