//
//  RecordParamView.m
//  live
//
//  Created by hysd on 15/8/24.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "RecordParamView.h"
#import "Macro.h"
#import "Common.h"
@interface RecordParamView(){
    UIView* mBackgroundView;
    UIWindow *mOriginalWindow;
    RecordConfirm confirmBlock;
    RecordCancel cancelBlock;
}
@end
@implementation RecordParamView

- (id)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"RecordParamView" owner:self options:nil] lastObject];
    if(self){
        self.layer.cornerRadius = 5;
        self.backgroundColor = RGB16(COLOR_BG_WHITE);
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.confirmButton.backgroundColor = RGB16(COLOR_BG_WHITE);
        [self.confirmButton setTitleColor:RGB16(COLOR_FONT_RED) forState:UIControlStateNormal];
        self.confirmButton.layer.cornerRadius = self.confirmButton.frame.size.height/2;
        self.confirmButton.layer.borderWidth = 1;
        self.confirmButton.layer.borderColor = RGB16(COLOR_BG_RED).CGColor;
        
        self.cancelButton.backgroundColor = RGB16(COLOR_BG_RED);
        [self.cancelButton setTitleColor:RGB16(COLOR_BG_WHITE) forState:UIControlStateNormal];
        self.cancelButton.layer.cornerRadius = self.cancelButton.frame.size.height/2;
        
        self.fileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入文件名" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTGRAY)}];
        self.tagTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入视频标签" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTGRAY)}];
        self.classTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入分类Id" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTGRAY)}];
        
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
        
        //为TextField添加inputAccessoryView
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-55, 5, 50.0f, 30.0f)];
        button.layer.cornerRadius = 4;
        [button setBackgroundColor:RGB16(COLOR_FONT_RED)];
        button.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(completeInput) forControlEvents:UIControlEventTouchUpInside];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40.0f)];
        [toolbar addSubview:button];
        toolbar.backgroundColor = RGB16(COLOR_BG_LIGHTGRAY);
        self.fileTextField.inputAccessoryView = toolbar;
        self.tagTextField.inputAccessoryView = toolbar;
        self.classTextField.inputAccessoryView = toolbar;
    }
    return self;
}
- (void)completeInput{
    [self.fileTextField resignFirstResponder];
    [self.tagTextField resignFirstResponder];
    [self.classTextField resignFirstResponder];
}
- (void)showTitle:(NSString*)title confirmTitle:(NSString*)conTitle cancelTitle:(NSString*)canTitle confirm:(RecordConfirm)confirm cancel:(RecordCancel)cancel{
    self.titleLabel.text = title;
    [self.confirmButton setTitle:conTitle forState:UIControlStateNormal];
    [self.cancelButton setTitle:canTitle forState:UIControlStateNormal];
    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
    confirmBlock = confirm;
    cancelBlock = cancel;
    
    self.alpha=0;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=1;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)confirmAction:(id)sender {
    if([self.fileTextField.text isEqualToString:@""]){
        [[Common sharedInstance] shakeView:self.fileTextField];
        return;
    }
    if([self.tagTextField.text isEqualToString:@""]){
        [[Common sharedInstance] shakeView:self.fileTextField];
        return;
    }
    if([self.classTextField.text isEqualToString:@""]){
        [[Common sharedInstance] shakeView:self.fileTextField];
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished) {
        if (confirmBlock) {
            confirmBlock();
        }
        [self removeFromSuperview];
        [mBackgroundView removeFromSuperview];
        mOriginalWindow = nil;
    }];
}

- (IBAction)cancelAction:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished) {
        if (cancelBlock) {
            cancelBlock();
        }
        [self removeFromSuperview];
        [mBackgroundView removeFromSuperview];
        mOriginalWindow = nil;
    }];
}
@end