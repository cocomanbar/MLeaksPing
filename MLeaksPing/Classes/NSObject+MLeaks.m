//
//  NSObject+MLeaksProxy.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "NSObject+MLeaks.h"
#import "NSObject+MLeaksRuntime.h"

char *const kLeaksProxyKey = "kLeaksProxyKey";

static int kLeaksPingLevel = 5;

@implementation NSObject (MLeaksProxy)

- (MLeaksProxy *)leaksProxy {
    return objc_getAssociatedObject(self, kLeaksProxyKey);
}

- (void)setLeaksProxy:(MLeaksProxy *)leaksProxy {
    objc_setAssociatedObject(self, kLeaksProxyKey, leaksProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)mleaks_pingLevel:(NSInteger)level {
    
    //限制深挖层数
    if (level >= kLeaksPingLevel) {
        return;
    }
    
    /**
     深挖 self，supper，supper supper，supper supper supper...等的property属性
     这里有个逻辑缺陷未考虑ivar的情况
     举例子：
     UIViewController           : UIResponder
     MLeaksBaseViewController   : UIViewController
     MLeaksViewController       : MLeaksBaseViewController
     MLeaksBusinessController   : MLeaksViewController
     
     计划收集 MLeaksBusinessController  上绑定的strong类型property
     计划收集 MLeaksViewController      上绑定的strong类型property
     计划收集 MLeaksBaseViewController  上绑定的strong类型property
     */
    @autoreleasepool {
        
        NSMutableArray *strongProperties = [NSMutableArray array];
        
        //遍历类的层级，挖工程类的property
        [self.class mleaks_enumerateProperties:^(MLeaksPropertyInfo * _Nonnull propertyInfo, BOOL * _Nonnull stop) {
            if ((propertyInfo.type & MLeaksEncodingTypeObject) && ![propertyInfo.typeEncoding hasPrefix:@"T@\"MLeaks"]) {
                [strongProperties addObject:propertyInfo];
            }
        }];
        
        if (strongProperties.count == 0) {
            return;
        }
        for (MLeaksPropertyInfo *propertyInfo in strongProperties) {
            id objc = [self valueForKey:propertyInfo.name];
            if (![objc makeAlive]) {
                continue;
            }
            if ([objc leaksProxy] && [objc leaksProxy].isPinging) {
                continue;
            }
            MLeaksProxy *proxy = [MLeaksProxy new];
            proxy.target = objc;
            proxy.targetHolder = self;
            [objc setLeaksProxy:proxy];
            [proxy startPing];
            // 递归
            [objc mleaks_pingLevel:level+1];
        }
    }
}

#pragma mark - protocol

+ (void)preparePing {
    
}

- (BOOL)makeAlive
{
    // 1. 存在Proxy
    if ([self leaksProxy] != nil) {
        return false;
    }
    
    // 2. 系统类
    if ([self.class mleaks_isClassFromSystem:[self class]]) {
        return false;
    }
    
    // 3. view 但没有父类
    if ([self isKindOfClass:[UIView class]]) {
        UIView *v = (UIView *)self;
        if (v.superview == nil) {
            return false;
        }
    }
    
    // 4. 控制器但没有栈
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController *c = (UIViewController*)self;
        if (c.navigationController == nil && c.presentingViewController == nil) {
            return false;
        }
    }
    
    return true;
}

- (BOOL)isAlive {
    BOOL alive = true;
    if (self.leaksProxy.target == nil) {
        alive = false;
    }
    return alive;
}

@end
