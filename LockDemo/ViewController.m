//
//  ViewController.m
//  LockDemo
//
//  Created by asus on 16/7/25.
//  Copyright (c) 2016年 asus. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()


- (IBAction)synchronizad:(id)sender;

- (IBAction)NSLook:(id)sender;

- (IBAction)NSCondition:(id)sender;

- (IBAction)NSRecursiveLock:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FDLog(@"各种同步锁使用Demo");
    
}


/**
 *  执行顺序:刚开始还没有加锁。
    备注：谁先准备好是不一定的，因为异步并发执行，AB谁先执行顺序不能确定。
    有可能B在执行锁的内容的时候，A才准备好，也有可能A执行完毕了，B才准备好
 */
- (IBAction)synchronizad:(id)sender {
    
    FDLog(@"synchronizad 测试");
    
    static NSObject *lock = nil;
    
    if (!lock) {
        lock = [[NSString alloc] init];
        
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FDLog(@"线程A，准备好");
        @synchronized(lock){
            FDLog(@"线程A lock, 请等待");
            [NSThread sleepForTimeInterval:3];
            FDLog(@"线程A 执行完毕");
        }

    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FDLog(@"线程B，准备好");
        @synchronized(lock){
            FDLog(@"线程B lock, 请等待");
            [NSThread sleepForTimeInterval:1];
            FDLog(@"线程B 执行完毕");
        }
    });
}



/**
 *   作为不同线程之间锁的使用
 执行顺序:刚开始还没有加锁。
 备注：谁先准备好是不一定的，因为异步并发执行，AB谁先执行顺序不能确定。
 有可能B在执行锁的内容的时候，A才准备好，也有可能A执行完毕了，B才准备好
 */
- (IBAction)NSLook:(id)sender {

    static NSLock *lock = nil;
    if (!lock) {
        lock = [[NSLock alloc] init];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FDLog(@"线程A，准备好");
        [lock lock];
            FDLog(@"线程A lock, 请等待");
            [NSThread sleepForTimeInterval:3];
            FDLog(@"线程A 执行完毕");
        [lock unlock];
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FDLog(@"线程B，准备好");
        [lock lock];
            FDLog(@"线程B lock, 请等待");
            [NSThread sleepForTimeInterval:1];
            FDLog(@"线程B 执行完毕");
        [lock unlock];
    });
    
}

/**
 *  条件锁，只有达到条件之后，才会执行锁操作，否则不会对数据进行加锁
 执行顺序:刚开始还没有加锁。
 备注：谁先准备好是不一定的，因为异步并发执行，AB谁先执行顺序不能确定。
 有可能B在执行锁的内容的时候，A才准备好，也有可能A执行完毕了，B才准备好
 */
- (IBAction)NSCondition:(id)sender {

#define kCondition_A  1
#define kCondition_B  2

    __block NSUInteger condition = kCondition_B;
    static NSConditionLock *conditionLock = nil;
    if (!conditionLock) {
        conditionLock = [[NSConditionLock alloc] initWithCondition:condition];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FDLog(@"线程A，准备好,检测是否可以加锁");
        BOOL canLock = [conditionLock tryLockWhenCondition:kCondition_A];
        
        if (canLock) {
            FDLog(@"线程A lock, 请等待");
            [NSThread sleepForTimeInterval:1];
            FDLog(@"线程A 执行完毕");
            [conditionLock unlock];
        }else{
            FDLog(@"线程A 条件不满足，未加lock");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FDLog(@"线程B，准备好,检测是否可以加锁");
        BOOL canLock = [conditionLock tryLockWhenCondition:kCondition_B];
        
        if (canLock) {
            FDLog(@"线程B lock, 请等待");
            [NSThread sleepForTimeInterval:1];
            FDLog(@"线程B 执行完毕");
            [conditionLock unlock];
        }else{
            FDLog(@"线程B 未加lock");
        }
    });
    
    
    
}


- (void)reverseDebug:(NSUInteger )num lock:(NSRecursiveLock *)lock
{
    [lock lock];
    if (num<=0) {
        FDLog(@"结束");
        return;
    }
    FDLog(@"加了递归锁, num = %ld", num);
    [NSThread sleepForTimeInterval:0.5];
    [self reverseDebug:num-1 lock:lock];
    
    [lock unlock];
}
/**
 *  递归锁
 *
 *  同一个线程可以多次加锁，但是不会引起死锁,如果是NSLock，则会导致崩溃
 */

- (IBAction)NSRecursiveLock:(id)sender {
    
    static NSRecursiveLock *lock = nil;
    
    if (!lock) {
        lock = [[NSRecursiveLock alloc] init];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self reverseDebug:5 lock:lock];
    });
}

@end


