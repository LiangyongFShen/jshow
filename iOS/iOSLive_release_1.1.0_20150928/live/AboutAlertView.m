//
//  AboutAlertView.m
//  live
//
//  Created by hysd on 15/8/21.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "AboutAlertView.h"
#import "Macro.h"
@interface AboutAlertView(){
    UIView* mBackgroundView;
    UIWindow *mOriginalWindow;
}
@end
@implementation AboutAlertView

- (id)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"AboutAlertView" owner:self options:nil] lastObject];
    if(self){
        
        self.backgroundColor = RGB16(COLOR_BG_WHITE);
        self.layer.cornerRadius = 5;
        self.titleLabel.textColor = RGB16(COLOR_FONT_BLACK);
        self.sepView.backgroundColor = RGB16(COLOR_BG_LIGHTGRAY);
        [self.closeButton setTitleColor:RGB16(COLOR_FONT_RED) forState:UIControlStateNormal];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        self.contentLabel.text = [NSString stringWithFormat:@"当前版本%@",version];
        CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH-40, size.height);
        
        CGRect rect = [UIScreen mainScreen].bounds;
        mOriginalWindow = [[UIWindow alloc] initWithFrame:rect];
        mOriginalWindow.windowLevel = UIWindowLevelAlert;
        
        mBackgroundView  = [[UIView alloc] initWithFrame:rect];
        mBackgroundView.alpha = 0.4;
        mBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        mBackgroundView.backgroundColor = [UIColor blackColor];
        mBackgroundView.center = mOriginalWindow.center;
        self.center = mOriginalWindow.center;
        
        [mOriginalWindow addSubview:mBackgroundView];
        [mOriginalWindow addSubview:self];
        [mOriginalWindow makeKeyAndVisible];
        [mOriginalWindow resignKeyWindow];
    }
    return self;
}

- (IBAction)closeAction:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [mBackgroundView removeFromSuperview];
        mOriginalWindow = nil;
    }];
}

- (void)showTitle:(NSString*)title content:(NSString*)content{
    self.titleLabel.text = title;
    self.alpha=0;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=1;
    } completion:^(BOOL finished) {
    }];
}

@end
