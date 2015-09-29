//
//  BaseNavigationController.m
//  live
//
//  Created by hysd on 15/7/13.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()
{
    BOOL noPushRoot;
}
@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(noPushRoot){
        viewController.hidesBottomBarWhenPushed = YES;
    }
    noPushRoot = YES;
    [super pushViewController:viewController animated:animated];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
