//
//  NSObject+MLeaks.h
//  MLeaksPing
//
//  Created by tanxl on 10/29/2022.
//

#import <Foundation/Foundation.h>
#import "MLeaksProxy.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLeaksPingProtocol <NSObject>

+ (void)preparePing;

- (BOOL)makeAlive;

- (BOOL)isAlive;

@end

@interface NSObject (MLeaksProxy)<MLeaksPingProtocol>

@property (nonatomic, strong) MLeaksProxy *leaksProxy;

- (void)mleaks_pingLevel:(NSInteger)level;

@end

NS_ASSUME_NONNULL_END
