//
//  EZTimer.m
//  EZKit
//
//  Created by macbook pro on 2018/3/20.
//  Copyright © 2018年 sheep. All rights reserved.
//

#import "EZTimer.h"

#define EZTimerQueueName(x) [NSString stringWithFormat:@"NSTimer_%@_queue",x]

#define EZTimerDfaultLeeway 0.1

#define EZTimerDfaultTimeInterval 60

@interface EZTimer()

@property(nonatomic,strong)NSMutableDictionary *timers;

@end

@implementation EZTimer

+(instancetype)shareInstance{
    static EZTimer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZTimer alloc] init];
    });
    
    return instance;
}

-(void)repeatTimer:(NSString*)timerName timerInterval:(double)interval resumeType:(EZTimerResumeType)resumeType action:(EZTimerBlock)action{
    [self timer:timerName timerInterval:interval leeway:EZTimerDfaultLeeway resumeType:resumeType queue:EZTimerQueueTypeGlobal queueName:nil repeats:YES action:action];
}


-(void)timer:(NSString*)timerName timerInterval:(double)interval leeway:(double)leeway resumeType:(EZTimerResumeType)resumeType queue:(EZTimerQueueType)queue queueName:(NSString *)queueName repeats:(BOOL)repeats action:(EZTimerBlock)action{
    
    dispatch_queue_t que = nil;
    if (!timerName) { return; }
    if (!queueName) {
        queueName = EZTimerQueueName(timerName);
    }
    switch (queue) {

        case EZTimerQueueTypeConcurrent:{
            que = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
            break;
        }
        case EZtimerQueueTypeSerial:{
            que = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
            break;
        }
        default:
            que = dispatch_get_global_queue(0, 0);
            break;
    }
    dispatch_source_t timer = [self.timers objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, que);
        [self.timers setObject:timer forKey:timerName];
    }
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), (interval==0?EZTimerDfaultTimeInterval:interval) * NSEC_PER_SEC, (leeway == 0 ? EZTimerDfaultLeeway:leeway) * NSEC_PER_SEC);

    dispatch_source_set_event_handler(timer, ^{
        action(timerName);
        if (!repeats) {
            dispatch_source_cancel(timer);
        }
        NSLog(@"tiemr action");
    });
    if (resumeType == EZTimerResumeTypeNow) {
        dispatch_resume(timer);
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), que, ^{
            dispatch_resume(timer);
        });
    }
}

-(void)cancel:(NSString *)timerName{
    dispatch_source_t timer = [self.timers objectForKey:timerName];
    //NSAssert(timer, @"%s\n定时器列表中不存在此名称的timer -- %@",__func__,timerName);
    if (!timer) {
        return;
    }
    [self.timers removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
    NSLog(@"tiemr action - cancel");
}

-(void)pause:(NSString *)timerName{
    dispatch_source_t timer = [self.timers objectForKey:timerName];
    //NSAssert(timer, @"%s\n定时器列表中不存在此名称的timer -- %@",__func__,timerName);
    if (!timer) {
        return;
    }
    dispatch_suspend(timer);
    NSLog(@"tiemr action - pause" );
}

-(void)resume:(NSString *)timerName{
    dispatch_source_t timer = [self.timers objectForKey:timerName];
    //NSAssert(timer, @"%s\n定时器列表中不存在此名称的timer -- %@",__func__,timerName);
    if (!timer) {
        return;
    }
    dispatch_resume(timer);
    NSLog(@"tiemr action - resume");
}

-(NSMutableDictionary *)timers{
    if (!_timers) {
        _timers = [NSMutableDictionary dictionary];
    }
    return _timers;
}

@end
