//
//  MLeaksProxy.h
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLeaksProxy : NSObject

@property (nonatomic, weak, nullable) NSObject *target;
@property (nonatomic, weak, nullable) NSObject *targetHolder;

@property (nonatomic, assign, readonly) BOOL isPinging;
@property (nonatomic, assign, readonly) Class targetHolderClass;

- (void)startPing;

/// for controller
@property (nonatomic, assign, readonly) BOOL canPing;

@end

@interface MLeaksBlockProxy : NSObject

@property (nonatomic, weak) NSObject *target;
@property (nonatomic, copy) void(^authBlock)(BOOL);

@end

NS_ASSUME_NONNULL_END

