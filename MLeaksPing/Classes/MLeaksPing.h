//
//  MLeaksPing.h
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import <Foundation/Foundation.h>
#import "MLeaksHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLeaksPing : NSObject

+ (instancetype)shared;
+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

@property (nonatomic, assign, readonly) BOOL isPinging;

/// 处理策略，以及处理结果回调
- (void)handleLeaksType:(MLeaksHandleType)handleType reportBlock:(nullable void(^)(NSDictionary * _Nullable))reportBlock;

/// 更新检测判定时间，即一个对象被ping多少次才会认定为假想泄漏源
- (void)setPongJudge:(int)pong;

/// 设置常驻或需要屏蔽的控制器集合，避免频繁触发弹框
- (void)setUnPingController:(NSSet <Class>* _Nullable)controllers;


/// 开始监听
- (void)startPing;

/// 停止监听
- (void)stopPing;

@end

NS_ASSUME_NONNULL_END

/**
 *  相关文章参考:
 *  1.如何在 iOS 中解决循环引用的问题
 *  https://github.com/draveness/analyze/blob/master/contents/FBRetainCycleDetector/%E5%A6%82%E4%BD%95%E5%9C%A8%20iOS%20%E4%B8%AD%E8%A7%A3%E5%86%B3%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8%E7%9A%84%E9%97%AE%E9%A2%98.md
 *
 *  2.检测 NSObject 对象持有的强指针
 *  https://github.com/draveness/analyze/blob/master/contents/FBRetainCycleDetector/%E6%A3%80%E6%B5%8B%20NSObject%20%E5%AF%B9%E8%B1%A1%E6%8C%81%E6%9C%89%E7%9A%84%E5%BC%BA%E6%8C%87%E9%92%88.md
 *
 *  3.如何实现 iOS 中的 Associated Object
 *
 *  https://github.com/draveness/analyze/blob/master/contents/FBRetainCycleDetector/%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0%20iOS%20%E4%B8%AD%E7%9A%84%20Associated%20Object.md
 *
 *  4.iOS 中的 block 是如何持有对象的
 *
 *  https://github.com/draveness/analyze/blob/master/contents/FBRetainCycleDetector/iOS%20%E4%B8%AD%E7%9A%84%20block%20%E6%98%AF%E5%A6%82%E4%BD%95%E6%8C%81%E6%9C%89%E5%AF%B9%E8%B1%A1%E7%9A%84.md
 */
