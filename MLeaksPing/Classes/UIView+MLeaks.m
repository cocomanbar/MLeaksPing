//
//  UIView+MLeaks.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "UIView+MLeaks.h"
#import <objc/runtime.h>
#import "MLeaksProxy.h"

@implementation UIView (MLeaks)

#pragma mark - protocol

+ (void)preparePing {
    
}

- (BOOL)isAlive {
    BOOL alive = false;
    
    // 1. 在栈内
    UIView *view = self;
    while (view.superview != nil) {
        view = view.superview;
    }
    if ([view isKindOfClass:UIWindow.class]) {
        alive = true;
    }
    // 2. 可能是属于某些常驻VC
    if (!alive) {
        if (self.leakController) {
            alive = true;
        }
    }
    return alive;
}

#pragma mark - extension

- (UIViewController * _Nullable)leakController {
    UIResponder *nextResponder = self.nextResponder;
    while (nextResponder) {
        if ([nextResponder isKindOfClass:UIViewController.class]) {
            return (UIViewController *)nextResponder;
        }
        nextResponder = nextResponder.nextResponder;
    }
    return nil;
}

@end
