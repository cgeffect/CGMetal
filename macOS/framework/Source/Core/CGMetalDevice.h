//
//  CGMetalDevice.h
//  CGMetal
//
//  Created by Jason on 21/3/3.
//

@import Foundation;
@import CoreMedia;
@import Metal;

@class CGMetalDevice;
@interface CGMetalDevice : NSObject

+ (CGMetalDevice *)sharedDevice;

@property(nonatomic, readonly) id<MTLDevice> device;

@property(nonatomic, readonly) id<MTLLibrary> shaderLibrary;

@property(nonatomic, readonly) id<MTLCommandQueue>commandQueue;

+ (BOOL)supportsFastTextureUpload;

@end
