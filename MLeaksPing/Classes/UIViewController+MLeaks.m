//
//  UIViewController+MLeaks.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "UIViewController+MLeaks.h"
#import "NSObject+MLeaks.h"
#import "NSObject+MLeaksRuntime.h"

@implementation UIViewController (MLeaks)

+ (void)preparePing {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(viewDidAppear:) with:@selector(mleaks_viewDidAppear:)];
        [self swizzleInstanceMethod:@selector(viewDidDisappear:) with:@selector(mleaks_viewDidDisappear:)];
    });
}

+ (NSString *)currentAppName {
    static NSString *appName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appName = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
    });
    return appName;
}


/// 向 组件中心 请求权限
- (void)mleaks_viewDidAppear:(BOOL)animated {
    [self mleaks_viewDidAppear:animated];
    
    // 暂时不兼容Swift
    NSString *appName = [self.class currentAppName];
    NSString *className = NSStringFromClass(self.class);
    if (appName && [className hasPrefix:appName] && [className containsString:@"."]) {
        return;
    }
    if (!self.leaksProxy) {
        self.leaksProxy = [MLeaksProxy new];
        self.leaksProxy.target = self;
        self.leaksProxy.targetHolder = self;
    }
}

/// 强制所有 strong 属性生成 Proxy
- (void)mleaks_viewDidDisappear:(BOOL)animated {
    [self mleaks_viewDidDisappear:animated];
    
    if (self.leaksProxy.canPing) {
        // 这里监听控制器self
        if (!self.leaksProxy.isPinging) {
            [self.leaksProxy startPing];
        }
        // 这里监听properties
        [self mleaks_pingLevel:(0)];
    }
}

- (BOOL)isAlive {
    
    BOOL alive = true;
    BOOL beingHeld = false;
    BOOL visibleOnScreen = false;
    
    // 1.view
    UIView *view = self.view;
    while (view.superview != nil) {
        view = view.superview;
    }
    if ([view isKindOfClass:UIWindow.class]) {
        visibleOnScreen = true;
    }
    // 2.控制器
    if (self.navigationController || self.presentingViewController) {
        beingHeld = true;
    }
    
    if (!visibleOnScreen && !beingHeld) {
        alive = false;
    }
    return alive;
}

@end
