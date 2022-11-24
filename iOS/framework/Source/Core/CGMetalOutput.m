//
//  CGMetalOutput.m
//  CGMetal
//
//  Created by Jason on 21/3/3.
//

#import "CGMetalOutput.h"

@implementation CGMetalOutput

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    _targets = [[NSMutableArray alloc] init];
    return self;
}

- (CGMetalTexture *)outTexture {
    return _outputTexture;
}

- (NSArray*)targets;
{
    return [NSArray arrayWithArray:_targets];
}

- (void)addTarget:(id<CGMetalInput>)newTarget;
{
    [_targets addObject:newTarget];
}

- (void)removeTarget:(id<CGMetalInput>)targetToRemove;
{
    if(![_targets containsObject:targetToRemove])
    {
        return;
    }
    
    [self->_targets removeObject:targetToRemove];
}

- (void)removeAllTargets
{
    [self->_targets removeAllObjects];
}

- (void)waitUntilCompleted {
    _isWaitUntilCompleted = YES;
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget _waitUntilCompleted];
    }
}

- (void)waitUntilScheduled {
    _isWaitUntilScheduled = YES;
    for (id<CGMetalInput> currentTarget in self->_targets){
        [currentTarget _waitUntilScheduled];
    }
}

- (void)requestRender {
    
}

- (void)dealloc
{
    [self removeAllTargets];
}

@end
