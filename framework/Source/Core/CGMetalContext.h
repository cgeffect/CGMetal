//
//  CGMetalContext.h
//  CGMetalOS
//
//  Created by Jason on 2021/12/27.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@class CGMetalContext;
//在主线程执行,并且不死锁
void runOnMainQueueWithoutDeadlocking(void (^block)(void));
//在默认的CGRenderContext中执行
void runSyncOnSerialQueue(void (^block)(void));
void runAsyncOnSerialQueue(void (^block)(void));
//在指定的CGRenderContext中执行
void runSyncOnContextSerialQueue(CGMetalContext *context, void (^block)(void));
void runAsyncOnContextSerialQueue(CGMetalContext *context, void (^block)(void));
void reportAvailableMemoryForGPUImage(NSString *tag);

//在VideoProcessingQueue队列中,同步执行
void runSynchronouslyOnQueue(dispatch_queue_t serial_queue, void (^block)(void));
//在VideoProcessingQueue队列中,异步执行
void runAsynchronouslyOnQueue(dispatch_queue_t concurrent_queue, void (^block)(void));


//给OpenGL ES基本环境
@interface CGMetalContext : NSObject

@property(readonly, nonatomic) dispatch_queue_t contextQueue;
@property(readonly, nonatomic, assign) CVMetalTextureCacheRef coreVideoTextureCache;

+ (void *)contextKey;

+ (CGMetalContext *)sharedRenderContext;

+ (BOOL)supportsFastTextureUpload;

- (dispatch_queue_t)sharedContextQueue;

- (CVMetalTextureCacheRef)coreVideoTextureCache;

- (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize;

@end

NS_ASSUME_NONNULL_END
