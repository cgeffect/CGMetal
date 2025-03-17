//
//  CGMetalContext.m
//  CGMetal
//
//  Created by Jason on 2021/12/27.
//

#import <CGMetal/CGMetalContext.h>
#import <mach/mach.h>
#import <CGMetal/CGMetalDevice.h>
#pragma mark -
#pragma mark 队列

//首先获取类的queue，然后同步执行。需要注意的是，类的queue是不能直接创建的，而是通过一个GPUImageContext的单例来维护的。很巧妙吧。
void runSynchronouslyOnQueue(dispatch_queue_t serial_queue, void (^block)(void))
{
    //获取队列
    dispatch_queue_t videoProcessingQueue = serial_queue;
    //在videoProcessingQueue 队列中同步执行block
    dispatch_sync(videoProcessingQueue, block);
}

//首先获取类的queue，然后异步执行。需要注意的是，类的queue是不能直接创建的，而是通过一个GPUImageContext的单例来维护的。很巧妙吧。
void runAsynchronouslyOnQueue(dispatch_queue_t serial_queue, void (^block)(void))
{
    //获取队列
    dispatch_queue_t videoProcessingQueue = serial_queue;
    //在videoProcessingQueue 队列中同步执行block
    dispatch_async(videoProcessingQueue, block);
}

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void runSyncOnSerialQueue(void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [[CGMetalContext sharedRenderContext] sharedContextQueue];

    if (dispatch_get_specific([CGMetalContext contextKey]))
    {
        block();
    } else {
        dispatch_sync(videoProcessingQueue, block);
    }
}

void runAsyncOnSerialQueue(void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [[CGMetalContext sharedRenderContext]sharedContextQueue];
    
    if (dispatch_get_specific([CGMetalContext contextKey]))
    {
        block();
    }else
    {
        dispatch_async(videoProcessingQueue, block);
    }
}

void runSyncOnContextSerialQueue(CGMetalContext *context, void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [context contextQueue];
    if (dispatch_get_specific([CGMetalContext contextKey]))
    {
        block();
    }else
    {
        dispatch_sync(videoProcessingQueue, block);
    }
}

void runAsyncOnContextSerialQueue(CGMetalContext *context, void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [context contextQueue];
 
    if (dispatch_get_specific([CGMetalContext contextKey]))
    {
        block();
    }else
    {
        dispatch_async(videoProcessingQueue, block);
    }
}

void reportAvailableMemoryForGPUImage(NSString *tag)
{
    if (!tag)
        tag = @"Default";
    
    struct task_basic_info info;
    
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t kerr = task_info(mach_task_self(),
                                   
                                   TASK_BASIC_INFO,
                                   
                                   (task_info_t)&info,
                                   
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"%@ - Memory used: %u", tag, (unsigned int)info.resident_size); //in bytes
    } else {
        NSLog(@"%@ - Error: %s", tag, mach_error_string(kerr));
    }
}

@interface CGMetalContext()
@end

@implementation CGMetalContext

static void *MetalContextQueueKey;
//readonly
@synthesize coreVideoTextureCache = _coreVideoTextureCache;
@synthesize contextQueue = _contextQueue;

+ (CGMetalContext *)sharedRenderContext;
{
    static dispatch_once_t pred;
    static CGMetalContext *sharedRenderContext = nil;
    
    dispatch_once(&pred, ^{
        sharedRenderContext = [[[self class] alloc] init];
    });
    return sharedRenderContext;
}

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    MetalContextQueueKey = &MetalContextQueueKey;
    _contextQueue = dispatch_queue_create("com.metal.contextQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_set_specific(_contextQueue, MetalContextQueueKey, (__bridge void *)self, NULL);
    
    return self;
}

+ (void *)contextKey {
    return MetalContextQueueKey;
}

- (dispatch_queue_t)sharedContextQueue
{
    return [[CGMetalContext sharedRenderContext] contextQueue];
}

#pragma mark -
#pragma mark Manage fast texture upload
+ (BOOL)supportsFastTextureUpload;
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    return YES;
#endif
}

- (CVMetalTextureCacheRef)coreVideoTextureCache
{
    if (_coreVideoTextureCache == NULL)
    {
        CVReturn err = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, [CGMetalDevice sharedDevice].device, NULL, &_coreVideoTextureCache);
        if (err) {
            NSLog(@"CGMetalPixelBufferInput Error at CVOpenGLESTextureCacheCreate %d", err);
        }
    }
    return _coreVideoTextureCache;
}

#pragma mark -
#pragma mark Device
- (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize
{
    GLint maxTextureSize = [self maximumTextureSizeForThisDevice];
    if ( (inputSize.width < maxTextureSize) && (inputSize.height < maxTextureSize) )
    {
        return inputSize;
    }
    
    CGSize adjustedSize;
    if (inputSize.width > inputSize.height)
    {
        adjustedSize.width = (CGFloat)maxTextureSize;
        adjustedSize.height = ((CGFloat)maxTextureSize / inputSize.width) * inputSize.height;
    }
    else
    {
        adjustedSize.height = (CGFloat)maxTextureSize;
        adjustedSize.width = ((CGFloat)maxTextureSize / inputSize.height) * inputSize.width;
    }

    return adjustedSize;
}

- (GLint)maximumTextureSizeForThisDevice;
{
    static GLint maxTextureSize = 0;
    
    return maxTextureSize;
}

-(void) dealloc {
    if (_coreVideoTextureCache) {
        CFRelease(_coreVideoTextureCache);
        NSLog(@"Realese _coreVideoTextureCache...");
    }
}
@end
