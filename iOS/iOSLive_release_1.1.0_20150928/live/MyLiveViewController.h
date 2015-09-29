//
//  MyLiveViewController.h
//  live
//
//  Created by hysd on 15/7/16.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLiveViewController : UIViewController
@property (nonatomic,strong) UIImage* liveImage;
@property (nonatomic,strong) NSString* liveTitle;
- (void)startLive;
@end
