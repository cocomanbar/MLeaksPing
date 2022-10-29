//
//  MLeaksHandle.m
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import "MLeaksHandle.h"
#import "NSObject+MLeaks.h"
#import "NSObject+MLeaksRuntime.h"
//#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

typedef NS_ENUM(NSInteger, MLeaksReport){
    MLeaksReportUnknow = 0,
    MLeaksReportObject,
    MLeaksReportBlock,
    MLeaksReportAssociate,
};

@implementation MLeaksHandle

- (void)handleObject:(MLeaksProxy *)leaksObject {
    if (!leaksObject || !leaksObject.target) {
        return;
    }
    
    if (self.handleType & MLeaksHandleNone) {
        return;
    }
    
    NSMutableString *leakString = [NSMutableString string];
    [leakString appendFormat:@"发现可疑的泄漏源：%@（持有者）%@（泄漏源）",
     NSStringFromClass(leaksObject.targetHolderClass),
     NSStringFromClass([leaksObject.target class])];
    
    if (self.handleType & MLeaksHandleLog) {
        NSLog(@"【🔥MLeaksPinge🔥】：%@", leakString);
    }
    
    if (self.handleType & MLeaksHandleAlert) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"泄漏提示"
                                                            message:leakString
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"收到", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
#pragma clang diagnostic pop
    }
    
//    if (self.handleType & MLeaksHandleDone) {
//        [self breakeRefrenceAtObject:leaksObject];
//    }
}


//- (void)breakeRefrenceAtObject:(MLeaksProxy *)leaksObject {
//    if (!leaksObject || !leaksObject.target) {
//        return;
//    }
//
//    /**
//     *  导致一个实例没有释放掉的原因可能有：
//     *      - 动态关联存在（第一步尝试解决，有解决的结果回调）
//     *      - Block形式（仅实现开发过程中的警告）
//     *      - 循环引用存在
//     *          - property（第一步尝试解决，有解决的结果回调）
//     *          - Ivar（第二步尝试解决，有解决的结果回调）
//     *          - 数组等集合（第一步尝试解决，有解决的结果回调）
//     *
//     *  解决需要考虑的情况：
//     *      1. Ab - Ba / B_a
//     *      2. A_b - Ba / B_a
//     *      3. (Cb)->A - Ba / B_a / Bc / B_c
//     *      4. (C_b)->A - Ba / B_a / Bc / B_c
//     *      5. A(b) - Ba / B_a
//     */
//
//    @autoreleasepool {
//
//        Class cls = leaksObject.target.class;
//        NSObject *target = leaksObject.target;
//
//        // 1.回调处理结果
//        void(^MLeaksBlock)(BOOL succeed, MLeaksReport report, MLeaksIvarInfo *ivarInfo) =
//        ^(BOOL succeed, MLeaksReport report, MLeaksIvarInfo *ivarInfo){
//            if (self.handleBlock) {
//                NSString *status = succeed ? @"succeed" : @"failed";
//                NSString *targetString = NSStringFromClass(cls);
//                NSString *targetHolderString = NSStringFromClass(leaksObject.targetHolderClass);
//                NSString *targetRefernceName = ivarInfo.name;
//                NSString *reportSource = nil;
//                switch (report) {
//                    case MLeaksReportBlock:
//                        reportSource = @"Block";
//                        break;
//                    case MLeaksReportObject:
//                        reportSource = @"Object";
//                        break;
//                    case MLeaksReportAssociate:
//                        reportSource = @"Associate";
//                        break;
//                    default:
//                        break;
//                }
//                NSMutableDictionary *report = [NSMutableDictionary dictionary];
//                if (status) {
//                    [report setObject:status forKey:@"status"];
//                }
//                if (targetString) {
//                    [report setObject:targetString forKey:@"targetString"];
//                }
//                if (targetHolderString) {
//                    [report setObject:targetHolderString forKey:@"targetHolderString"];
//                }
//                if (targetRefernceName) {
//                    [report setObject:targetRefernceName forKey:@"targetRefernceName"];
//                }
//                if (reportSource) {
//                    [report setObject:reportSource forKey:@"reportSource"];
//                }
//                self.handleBlock([report copy]);
//            }
//        };
//
//        // 2.破解循环引用
//        [[target class] mleaks_enumerateIvars:^(MLeaksIvarInfo * _Nonnull ivarInfo, BOOL * _Nonnull stop) {
//
//            // 2.1.针对id类型和block类型进行处理
//            if (ivarInfo.type & MLeaksEncodingTypeObject || ivarInfo.type & MLeaksEncodingTypeBlock) {
//
//                // 2.2.尝试取值，取到值说明可能是循环引用点
//                id objc = object_getIvar(target, ivarInfo.ivar);
//                if (objc) {
//                    __block BOOL succeed = false;
//
//                    // 2.3.如果是block导致的循环
//                    if (ivarInfo.type & MLeaksEncodingTypeBlock) {
//                        // 2.3.1.回调处理结果
//                        if (MLeaksBlock) {
//                            MLeaksBlock(succeed, MLeaksReportBlock, ivarInfo);
//                        }
//                    }
//
//                    // 2.4.如果是object类型，只需要断开彼此引用即可
//                    if (ivarInfo.type & MLeaksEncodingTypeObject) {
//
//                        // 2.4.1.利用 FBRetainCycleDetector 再次深度遍历检查引用环是否存在
//                        FBRetainCycleDetector *cycleDetector = [[FBRetainCycleDetector alloc] init];
//                        [cycleDetector addCandidate:objc];
//                        NSMutableArray<NSArray<FBObjectiveCGraphElement *> *> *findRetainCycles = [[cycleDetector findRetainCycles].allObjects mutableCopy];
//
//                        // 2.5.检查未通过，可能存在Associated关联的情况，这就离谱~，谁写的喔~
//                        if (!findRetainCycles || !findRetainCycles.count) {
//                            succeed = true;
//
//                            // 2.5.1.移除动态关联
//                            objc_removeAssociatedObjects(objc);
//                            objc_removeAssociatedObjects(target);
//
//                            // 2.5.2.回调处理结果
//                            if (MLeaksBlock) {
//                                MLeaksBlock(succeed, MLeaksReportAssociate, ivarInfo);
//                            }
//                            return;
//                        }
//
//                        // 2.6.将检查到的断开引用
//                        while (findRetainCycles.count) {
//                            NSArray<FBObjectiveCGraphElement *> *retainCycles = findRetainCycles.lastObject;
//                            [findRetainCycles removeLastObject];
//                            if (retainCycles.count != 2) {
//                                continue;
//                            }
//
//                            // 2.6.1.逐一断开检测环
//                            FBObjectiveCGraphElement *element1 = retainCycles.firstObject;
//                            FBObjectiveCGraphElement *element2 = retainCycles.lastObject;
//
//                            [[element1.object class] mleaks_enumerateCurrentClassIvars:^(MLeaksIvarInfo * _Nonnull ivarInfo, BOOL * _Nonnull stop) {
//                                if (ivarInfo.type & MLeaksEncodingTypeObject) {
//                                    if ([element2.namePath containsObject:ivarInfo.name]) {
//                                        object_setIvarWithStrongDefault(element1.object, ivarInfo.ivar, nil);
//                                        succeed = true;
//                                    }
//                                }
//                            }];
//
//                            [[element2.object class] mleaks_enumerateCurrentClassIvars:^(MLeaksIvarInfo * _Nonnull ivarInfo, BOOL * _Nonnull stop) {
//                                if (ivarInfo.type & MLeaksEncodingTypeObject) {
//                                    if ([element1.namePath containsObject:ivarInfo.name]) {
//                                        object_setIvarWithStrongDefault(element2.object, ivarInfo.ivar, nil);
//                                        succeed = true;
//                                    }
//                                }
//                            }];
//
//                            // 2.6.2.回调处理结果
//                            if (MLeaksBlock) {
//                                MLeaksBlock(succeed, MLeaksReportObject, ivarInfo);
//                            }
//                        }
//                    }
//                }
//            }
//        }];
//    }
//}

/**
 *  block的基类 NSBlock，用于破解block循环
 */
//static Class _MLeaksBlockClass() {
//    static dispatch_once_t onceToken;
//    static Class blockClass;
//    dispatch_once(&onceToken, ^{
//        void (^testBlock)(void) = [^{} copy];
//        blockClass = [testBlock class];
//        while(class_getSuperclass(blockClass) && class_getSuperclass(blockClass) != [NSObject class]) {
//            blockClass = class_getSuperclass(blockClass);
//        }
//    });
//    return blockClass;
//}

@end
