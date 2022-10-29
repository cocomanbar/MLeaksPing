//
//  MLeaksHandle.h
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MLeaksProxy;

typedef NS_OPTIONS(NSUInteger, MLeaksHandleType){
    MLeaksHandleNone     = 0,
    MLeaksHandleLog      = 1 << 0,
    MLeaksHandleAlert    = 1 << 1,
    MLeaksHandleDone     = 1 << 2,
    
    MLeaksHandleDebug    = MLeaksHandleLog | MLeaksHandleAlert,
    MLeaksHandleRelease  = MLeaksHandleDone                     // 已屏蔽，打开请依赖 `FBRetainCycleDetector`
};

@interface MLeaksHandle : NSObject

@property (nonatomic, assign) MLeaksHandleType handleType;
@property (nonatomic, copy) void(^handleBlock)(NSDictionary *);

- (void)handleObject:(MLeaksProxy *)leaksObject;

@end

NS_ASSUME_NONNULL_END
