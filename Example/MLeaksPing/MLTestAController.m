//
//  MLTestAController.m
//  MLeaksPing_Example
//
//  Created by tanxl on 2022/10/29.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "MLTestAController.h"
#import <objc/runtime.h>

static const char *kTestKey = '\0';

@interface MLTestAview : UIView
{
    @public
    UIViewController *_controller11;
}

@property (nonatomic, strong) UIViewController *controller2;

@end

@interface MLTestAController ()

@property (nonatomic, strong) MLTestAview *aView;

@end

@implementation MLTestAController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"退回上级等待检测";
    
    self.aView = [[MLTestAview alloc] init];
    self.aView.frame = CGRectMake(20, 200, 50, 50);
    self.aView.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:self.aView];
    
    // property - ok
//    self.aView.controller2 = self;
    
    // ivar - ok
//    self.aView -> _controller11 = self;
    
    // Associate - no
    objc_setAssociatedObject(self.aView, &kTestKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc {
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
}

@end

@implementation MLTestAview

- (void)dealloc {
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
}

@end

