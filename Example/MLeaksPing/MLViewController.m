//
//  MLViewController.m
//  MLeaksPing
//
//  Created by cocomanbar on 10/29/2022.
//  Copyright (c) 2022 cocomanbar. All rights reserved.
//

#import "MLViewController.h"
#import "MLTestAController.h"
#import "MLTestAController.h"
#import "MLTestBController.h"
#import "MLTestCController.h"
#import <objc/runtime.h>
#import "MLeaksPing_Example-Swift.h"

@interface MLViewController ()

@end

@implementation MLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"点击屏幕";
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UIViewController *controller = nil;
    controller = [[MLTestAController alloc] init];
//    controller = [[MLTestBController alloc] init];
//    controller = [[MLTestCController alloc] init];
//    controller = [[MLSwiftViewController alloc] init];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
