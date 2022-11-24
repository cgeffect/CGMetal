//
//  CGMetalBufferProvider.m
//  CGMetal
//
//  Created by Jason on 2021/6/18.
//

#import "CGMetalBufferProvider.h"

@import Metal;

@interface CGMetalBufferProvider ()
// 1
@property(nonatomic, assign) NSInteger inflightBuffersCount;
// 2
@property(nonatomic, strong) NSMutableArray <id<MTLBuffer>>* uniformsBuffers;
// 3
@property(nonatomic, assign) NSInteger avaliableBufferIndex;
@end

@implementation CGMetalBufferProvider
- (instancetype)initWithDevice:(id<MTLDevice>)device inflightBuffersCount:(NSInteger)inflightBuffersCount sizeOfUniformsBuffer:(NSInteger)sizeOfUniformsBuffer
{
    self = [super init];
    if (self) {
        self.inflightBuffersCount = inflightBuffersCount;
        self.uniformsBuffers = [NSMutableArray array];
        for (int i = 0; i < inflightBuffersCount; i++) {
            MTLResourceOptions options = MTLResourceStorageModeShared;
            id<MTLBuffer> uniformsBuffer = [device newBufferWithLength:sizeOfUniformsBuffer options:options];
            [self.uniformsBuffers addObject:uniformsBuffer];
        }
    }
    return self;
}
    
- (id<MTLBuffer>)nextUniformsBuffer:(float *)projectionMatrix modelViewMatrix:(float *)modelViewMatrix {
    
  // 1
    id<MTLBuffer> buffer = _uniformsBuffers[_avaliableBufferIndex];
//
//  // 2
//    void * bufferPointer = [buffer contents];
//
//  // 3
//    memcpy(bufferPointer, modelViewMatrix.raw, sizeof(float) * Matrix4.numberOfElements);
//    memcpy(bufferPointer + sizeof(float)*Matrix4.numberOfElements, projectionMatrix.raw, sizeof(float)*Matrix4.numberOfElements);
//
//  // 4
    _avaliableBufferIndex += 1;
    if (_avaliableBufferIndex == _inflightBuffersCount) {
        _avaliableBufferIndex = 0;
    }
    
    return buffer;
}
@end
