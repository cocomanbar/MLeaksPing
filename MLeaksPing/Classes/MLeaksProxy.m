//
//  MLeaksBlockProxy.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "MLeaksProxy.h"
#import "NSObject+MLeaks.h"

extern NSString *const kMLeaksPingNotification;
extern NSString *const kMLeaksPongNotification;
extern NSString *const kMLeaksAuthNotification;

@interface MLeaksProxy ()

@property (nonatomic, assign, readwrite) BOOL canPing;
@property (nonatomic, assign, readwrite) BOOL isPinging;
@property (nonatomic, assign, readwrite) Class targetHolderClass;

@property (nonatomic, assign) int pingPong;
@property (nonatomic, assign) BOOL alreadyPong;

@property (nonatomic, assign) NSInteger dealTimes;  // 处理时间，默认5秒，默认时间过后，重新打开一次pong流程，目的是完善自检能力
@property (nonatomic, assign) BOOL dealAlready;     // 限制自检一次就行了，能处理就已经处理了，没有只需要再上报一次就知道是什么情况没有完善到

@end

@implementation MLeaksProxy

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _dealTimes = 5;
    }
    return self;
}

- (void)setTargetHolder:(NSObject *)targetHolder {
    _targetHolder = targetHolder;
    if (targetHolder) {
        _targetHolderClass = [targetHolder class];
    }
}

- (void)setTarget:(NSObject *)target {
    _target = target;
    
    if ([target isKindOfClass:UIViewController.class]) {
        __weak typeof(self)weakSelf = self;
        MLeaksBlockProxy *proxy = [[MLeaksBlockProxy alloc] init];
        proxy.target = target;
        proxy.authBlock = ^(BOOL auth) {
            weakSelf.canPing = auth;
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:kMLeaksAuthNotification object:proxy];
    }
}

- (void)startPing {
    if (self.isPinging) {
        return;
    }
    self.isPinging = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMLeaksPingNotification object:nil];
    __weak typeof(self)weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kMLeaksPingNotification
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification * _Nonnull note)
     {
        [weakSelf receivePing:note];
    }];
}

- (void)receivePing:(NSNotification *)notification {
    
    if (self.alreadyPong) {
        // 自检过了就返回
        if (self.dealAlready) {
            return;
        }
        // 开始自检倒计时
        self.dealTimes -= 1;
        if (self.dealTimes <= 0) {
            self.dealTimes = 0;
            self.pingPong = 0;
            self.alreadyPong = false;
        }
        return;
    }
    if (self.target == nil) {
        return;
    }
    BOOL alive = [self.target isAlive];
    if (alive == false) {
        self.pingPong += 1;
    }
    if (self.pingPong < [notification.object intValue]) {
        return;
    }
    if (self.dealTimes <= 0) {
        self.dealAlready = true;
    }
    self.alreadyPong = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMLeaksPongNotification object:self];
}

- (void)dealloc {
    
    _targetHolderClass = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation MLeaksBlockProxy

@end
