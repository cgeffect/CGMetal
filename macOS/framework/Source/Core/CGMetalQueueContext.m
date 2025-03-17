//
//  CGMetalQueueContext.m
//  CGMetal
//
//  Created by Jason on 2021/12/28.
//

#import <CGMetalMac/CGMetalQueueContext.h>
#include <pthread.h>

@implementation CGMetalQueueContext
- (instancetype)init
{
    self = [super init];
    if (self) {
        int policy;
        struct sched_param param;
        pthread_t pid = pthread_self();
        pthread_getschedparam(pid, &policy, &param);
        
//        int minPriority = sched_get_priority_min(policy);
//        int maxPriority = sched_get_priority_max(policy);
//        int oriPriority = param.sched_priority;

    }
    return self;
}
@end
