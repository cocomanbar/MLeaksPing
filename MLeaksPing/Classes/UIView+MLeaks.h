//
//  UIView+MLeaks.h
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MLeaks)

#pragma mark - extension

- ( UIViewController * _Nullable )leakController;

@end

NS_ASSUME_NONNULL_END
