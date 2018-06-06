# EZKit
v0.0.1
增加EZTimer控件，封装GCD版timer。

v0.0.2
增加timer状态控制，内部控制suspend等的配对使用，用户使用不再需要注意配对使用的问
题，使用更加方便简单。
v0.0.3
增加pod
v0.0.4
修复EZTimer cancel 方法bug

pod 'EZTimer'

即可。


用法简单：
创建timer 并执行
/**
 * 简单方式创建并执行timer，其他未给出的参数均为默认参数
 * timerName timer的名称，创建好的timer以name为key存储于timers字典中
 * interval timer时间间隔
 * resumeType 是否立刻开始执行，默认立刻开始执行，此时block会立刻执行，next下一个interval执行
 * action   timer回调
 */
-(void)repeatTimer:(NSString*)timerName timerInterval:(double)interval resumeType:(EZTimerResumeType)resumeType action:(EZTimerBlock)action;

[[EZTimer shareInstance] timer:@"logNumber" timerInterval:5 leeway:0.1 resumeType:EZTimerQueueTypeNext queue:EZTimerQueueTypeConcurrent queueName:@"log" repeats:YES action:^(NSString *timerName) {
        static NSInteger number = 1;
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.numLabel.text = @(number).stringValue;
            number ++;
        });
    }];
    
/**
 * 注销此timer
 * timerName timer名称
 */
-(void)cancel:(NSString *)timerName;
/**
 * 暂停此timer
 * 暂停及恢复的操作不建议使用，这两个操作需配对使用，
 * 不然会出现崩溃，原因是source未提供检测状态的接口
 * timerName timer名称
 */
-(void)pause:(NSString *)timerName;
/**
 * 恢复此timer
 * 暂停及恢复的操作不建议使用，这两个操作需配对使用，
 * 不然会出现崩溃，原因是source未提供检测状态的接口
 * timerName timer名称
 */
-(void)resume:(NSString *)timerName;


