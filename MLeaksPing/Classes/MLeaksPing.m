//
//  MLeaksPing.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "MLeaksPing.h"
#import "NSObject+MLeaks.h"

NSString *const kMLeaksPingNotification = @"MLeaksPingNotification";
NSString *const kMLeaksPongNotification = @"MLeaksPongNotification";
NSString *const kMLeaksAuthNotification = @"MLeaksAuthNotification";

@interface MLeaksPing ()

@property (nonatomic, strong) MLeaksHandle *handler;

@property (nonatomic, strong) NSNumber *leaksPongNum;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSThread *activeThread;

@property (nonatomic, strong) NSSet *ignoreControllers;

@end

@implementation MLeaksPing

+ (instancetype)shared{
    static MLeaksPing *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MLeaksPing alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        [self.activeThread start];
    }
    return self;
}

- (void)startPing {
    
    _isPinging = true;
    
    __weak typeof(self)weakSelf = self;
    
    // 监听通知
    [[NSNotificationCenter defaultCenter] addObserverForName:kMLeaksAuthNotification
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        MLeaksBlockProxy *proxy = (MLeaksBlockProxy *)note.object;
        if (![proxy isKindOfClass:MLeaksBlockProxy.class]) {
            return;
        }
        if (self.isPinging == false) {
            proxy.authBlock(false);
            return;
        }
        Class targetClass = [proxy.target class];
        if ([weakSelf.ignoreControllers containsObject:targetClass]) {
            proxy.authBlock(false);
            return;
        }
        proxy.authBlock(true);
    }];
    
    // 泄漏收集
    [[NSNotificationCenter defaultCenter] addObserverForName:kMLeaksPongNotification
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        MLeaksProxy *PingProxy = (MLeaksProxy *)note.object;
        if (![PingProxy isKindOfClass:[MLeaksProxy class]]) {
            return;
        }
        [weakSelf.handler handleObject:PingProxy];
    }];
    
    // 常驻线程
    [self performSelector:@selector(_startPing) onThread:self.activeThread withObject:nil waitUntilDone:NO];
    
    // 初始化hook
    [UIViewController preparePing];
    [UIView preparePing];
    [NSObject preparePing];
}

- (void)stopPing {
    
    _isPinging = false;
    
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (void)handleLeaksType:(MLeaksHandleType)handleType reportBlock:(void(^)(NSDictionary *))reportBlock {
    self.handler.handleType = handleType;
    self.handler.handleBlock = reportBlock;
}

- (void)setPongJudge:(int)pong {
    if (pong > 0 && self.leaksPongNum.intValue != pong) {
        self.leaksPongNum = [NSNumber numberWithInt:pong];
    }
}

- (void)setUnPingController:(NSSet <Class>*)controllers {
    if (controllers.count) {
        self.ignoreControllers = [controllers copy];
    }
}

#pragma mark - Private

- (void)_startPing {
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
}

- (void)activeThreadRespond:(NSThread *)thread {
    @autoreleasepool {
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
        [runloop run];
    }
}

- (void)activeTimer:(NSTimer *)timer {
    if (self.isPinging) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMLeaksPingNotification object:self.leaksPongNum userInfo:nil];
    }
}

#pragma mark - Lazyload

- (NSNumber *)leaksPongNum {
    if (!_leaksPongNum) {
        _leaksPongNum = [NSNumber numberWithInt:5];
    }
    return _leaksPongNum;
}

- (MLeaksHandle *)handler {
    if (!_handler) {
        _handler = [[MLeaksHandle alloc] init];
    }
    return _handler;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(activeTimer:) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (NSThread *)activeThread {
    if (!_activeThread) {
        _activeThread = [[NSThread alloc] initWithTarget:self selector:@selector(activeThreadRespond:) object:nil];
        _activeThread.name = @"MLeaks Active Thread";
    }
    return _activeThread;
}

@end
