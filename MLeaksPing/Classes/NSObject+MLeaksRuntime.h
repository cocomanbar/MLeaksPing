//
//  NSObject+MLeaksRuntime.h
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import <Foundation/Foundation.h>
#import "MLeaksClassInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MLeakClassesEnumeration)(Class c, BOOL *stop);

typedef void (^MLeakIvarsEnumeration)(MLeaksIvarInfo *ivarInfo, BOOL *stop);
typedef void (^MLeakPropertiesEnumeration)(MLeaksPropertyInfo *propertyInfo, BOOL *stop);

@interface NSObject (MLeaksRuntime)

/**
 *  是否是系统类信息
 */
+ (BOOL)mleaks_isClassFromSystem:(Class)c;


/**
 *  当前类以及响应链上的类（工程类）
 */
+ (void)mleaks_enumerateClasses:(MLeakClassesEnumeration)enumeration;


/**
 *  当前类以及响应链上的类（工程类）遍历Property成员
 */
+ (void)mleaks_enumerateProperties:(MLeakPropertiesEnumeration)enumeration;

/**
 *  当前类的遍历Property成员
 */
+ (void)mleaks_enumerateCurrentClassProperties:(MLeakPropertiesEnumeration)enumeration;


/**
 *  当前类以及响应链上的类（工程类）遍历Ivar成员
 */
+ (void)mleaks_enumerateIvars:(MLeakIvarsEnumeration)enumeration;

/**
 *  当前类的遍历Ivar成员
 */
+ (void)mleaks_enumerateCurrentClassIvars:(MLeakIvarsEnumeration)enumeration;

#pragma mark - Pr

+ (void)swizzleInstanceMethod:(SEL)originalSel with:(SEL)swizzledSel;

@end

NS_ASSUME_NONNULL_END
