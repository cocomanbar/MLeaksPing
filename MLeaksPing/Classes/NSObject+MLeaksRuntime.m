//
//  NSObject+MLeaksRuntime.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "NSObject+MLeaksRuntime.h"

@implementation NSObject (MLeaksRuntime)

+ (BOOL)mleaks_isClassFromSystem:(Class)c {
    NSBundle *bundle = [NSBundle bundleForClass:c];
    if ([bundle isEqual:NSBundle.mainBundle]) {
        return NO;
    }
    static NSString *embededDirPath;
    if (!embededDirPath) {
        embededDirPath = [[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:@"Frameworks"].absoluteString;
    }
    return ![bundle.bundlePath hasPrefix:embededDirPath];
}

+ (void)mleaks_enumerateClasses:(MLeakClassesEnumeration)enumeration {
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    // 2.停止遍历的标记
    BOOL stop = NO;
    // 3.当前正在遍历的类
    Class c = self;
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        // 4.2.获得父类
        c = class_getSuperclass(c);
        // 4.0.系统类就终止查找
        if ([self mleaks_isClassFromSystem:c]) break;
    }
}

+ (void)mleaks_enumerateProperties:(MLeakPropertiesEnumeration)enumeration {
    // 获得成员变量
    NSArray *cachedProperties = [self mleaks_properties];
    // 遍历成员变量
    BOOL stop = NO;
    for (MLeaksPropertyInfo *propertyInfo in cachedProperties) {
        enumeration(propertyInfo, &stop);
        if (stop) break;
    }
}

+ (void)mleaks_enumerateCurrentClassProperties:(MLeakPropertiesEnumeration)enumeration {
    // 1.获得所有的成员变量
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(self, &outCount);
    // 2.遍历每一个成员变量
    BOOL stop = NO;
    for (unsigned int i = 0; i < outCount; i++) {
        MLeaksPropertyInfo *propertyInfo = [[MLeaksPropertyInfo alloc] initWithProperty:properties[i]];
        propertyInfo.cls = self;
        if (propertyInfo) {
            enumeration(propertyInfo, &stop);
            if (stop) break;
        }
    }
    // 3.释放内存
    free(properties);
}

+ (void)mleaks_enumerateIvars:(MLeakIvarsEnumeration)enumeration {
    // 获得成员变量
    NSArray *cachedIvars = [self mleaks_ivars];
    // 遍历成员变量
    BOOL stop = NO;
    for (MLeaksIvarInfo *iavrInfo in cachedIvars) {
        enumeration(iavrInfo, &stop);
        if (stop) break;
    }
}

+ (void)mleaks_enumerateCurrentClassIvars:(MLeakIvarsEnumeration)enumeration {
    // 1.获得所有的成员变量
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList(self, &numIvars);
    // 2.遍历每一个成员变量
    BOOL stop = NO;
    for (unsigned int i = 0; i < numIvars; i++) {
        MLeaksIvarInfo *iavrInfo = [[MLeaksIvarInfo alloc] initWithIvar:vars[i]];
        iavrInfo.cls = self;
        if (iavrInfo) {
            enumeration(iavrInfo, &stop);
            if (stop) break;
        }
    }
    // 3.释放内存
    free(vars);
}

#pragma mark - 公共方法

+ (NSArray *)mleaks_ivars
{
    NSMutableArray *cachedIvars = [NSMutableArray array];
    [self mleaks_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        // 1.获得所有的成员变量
        unsigned int numIvars;
        Ivar *vars = class_copyIvarList(c, &numIvars);
        // 2.遍历每一个成员变量
        for (unsigned int i = 0; i < numIvars; i++) {
            MLeaksIvarInfo *iavrInfo = [[MLeaksIvarInfo alloc] initWithIvar:vars[i]];
            iavrInfo.cls = c;
            if (iavrInfo) {
                [cachedIvars addObject:iavrInfo];
            }
        }
        // 3.释放内存
        free(vars);
    }];
    return [cachedIvars copy];
}

+ (NSArray *)mleaks_properties
{
    NSMutableArray *cachedProperties = [NSMutableArray array];
    [self mleaks_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        // 1.获得所有的成员变量
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList(c, &outCount);
        // 2.遍历每一个成员变量
        for (unsigned int i = 0; i < outCount; i++) {
            MLeaksPropertyInfo *propertyInfo = [[MLeaksPropertyInfo alloc] initWithProperty:properties[i]];
            propertyInfo.cls = c;
            if (propertyInfo) {
                [cachedProperties addObject:propertyInfo];
            }
        }
        // 3.释放内存
        free(properties);
    }];
    return [cachedProperties copy];
}


#pragma mark - Pr

+ (void)swizzleInstanceMethod:(SEL)originalSel with:(SEL)swizzledSel {

    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSel);
    
    BOOL didAddMethod =
    class_addMethod(self,
                    originalSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@end
