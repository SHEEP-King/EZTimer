//
//  ViewController.m
//  EZKit
//
//  Created by macbook pro on 2018/3/15.
//  Copyright © 2018年 sheep. All rights reserved.
//

#import "ViewController.h"
#import "EZTimer.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@end

@implementation ViewController

- (IBAction)createTimer:(id)sender {
    [[EZTimer shareInstance] timer:@"logNumber" timerInterval:5 leeway:0.1 resumeType:EZTimerQueueTypeNext queue:EZTimerQueueTypeConcurrent queueName:@"log" repeats:YES action:^(NSString *timerName) {
        static NSInteger number = 1;
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.numLabel.text = @(number).stringValue;
            number ++;
        });
    }];
}
- (IBAction)pause:(id)sender {
    [[EZTimer shareInstance] pause:@"logNumber"];
}
- (IBAction)resum:(id)sender {
    [[EZTimer shareInstance] resume:@"logNumber"];
}
- (IBAction)stop:(id)sender {
    [[EZTimer shareInstance] cancel:@"logNumber"];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
