//
//  TrailerLiveViewController.m
//  live
//
//  Created by hysd on 15/8/20.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "TrailerLiveViewController.h"
#import "Macro.h"
#import "TrailerView.h"
#import "LiveView.h"
#import "SegmentView.h"
#import "TimePickView.h"
#import "Business.h"
#import "Common.h"
#import "UserInfo.h"
#import "MBProgressHUD.h"
#import "MyLiveViewController.h"
#import "UIImage+Category.h"
@interface TrailerLiveViewController ()<UIScrollViewDelegate,SegmentViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,TrailerViewDelegate,LiveViewDelegate,UIActionSheetDelegate,TimePickViewDelegate>
{
    SegmentView* segmentView;
    UIScrollView* scrollView;
    UIView* contentView;
    LiveView* liveView;
    TrailerView* trailerView;
    TimePickView* timePickView;
    MBProgressHUD* HUD;
}
@end

@implementation TrailerLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB16(COLOR_BG_WHITE);
    [self createNavView];
    [self createScrollView];
    [self createLiveView];
    [self createTrailerView];
    [self createDatePickeView];
    
    //初始化MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark 创建滚动视图
- (void)createScrollView{
    //设置scrollview
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50)];
    scrollView.backgroundColor = RGB16(COLOR_BG_LIGHTGRAY);
    scrollView.contentSize = CGSizeMake(2*SCREEN_WIDTH, 0);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    //设置contentView
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*SCREEN_WIDTH, scrollView.frame.size.height)];
    contentView.backgroundColor = RGB16(COLOR_BG_WHITE);
    [scrollView addSubview:contentView];
}
#pragma mark 创建分段视图
- (void)createNavView{
    //分段视图
    NSArray* items = [NSArray arrayWithObjects:@"发布直播",@"发布预告", nil];
    CGRect segmentFrame = CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH/2, 44);
    segmentView = [[SegmentView alloc] initWithFrame:segmentFrame andItems:items andSize:17 border:NO];
    segmentView.delegate = self;
    //导航栏
    UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    navBar.backgroundColor = RGB16(COLOR_BG_WHITE);
    UINavigationItem* navItem = [[UINavigationItem alloc] init];
    navItem.titleView = segmentView;
    [navBar pushNavigationItem:navItem animated:NO];
    [self.view addSubview:navBar];
    //关闭
    UIImage *closeImage = [UIImage imageNamed:@"close_red"];
    UIButton *closeBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
}
-(void)closeView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 创建发直播视图
- (void)createLiveView{
    liveView = [[LiveView alloc] init];
    liveView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    liveView.backgroundColor = [UIColor clearColor];
    liveView.delegate = self;
    [contentView addSubview:liveView];
}
#pragma mark 创建发预告视图
- (void)createTrailerView{
    trailerView = [[TrailerView alloc] init];
    trailerView.frame = CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    trailerView.backgroundColor = [UIColor clearColor];
    trailerView.delegate = self;
    [contentView addSubview:trailerView];
}
#pragma mark 创建时间选择视图
- (void)createDatePickeView{
    timePickView = [[TimePickView alloc] init];
    timePickView.delegate = self;
}
#pragma mark scrollview 代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll
{
    CGPoint offset = scrollView.contentOffset;
    NSInteger page = (offset.x + scrollView.frame.size.width/2) / scrollView.frame.size.width;
    [segmentView setSelectIndex:page];
}
#pragma mark segmentview 代理
- (void)segmentView:(SegmentView *)segmentView selectIndex:(NSInteger)index{
    [UIView animateWithDuration:0.2f animations:^{
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width*index, 0);
    }];
}
#pragma mark liveview 代理
- (void)liveViewTakeCover:(LiveView *)lv{
    [self openImageActionSheet];
}
- (void)liveVIewStartLive:(LiveView *)lv{
    if([liveView.titleTextField.text isEqualToString:@""]){
        [[Common sharedInstance] shakeView:liveView.titleTextField];
        return;
    }
    if(![liveView.coverImageView viewWithTag:101]){
        [[Common sharedInstance] shakeView:liveView.coverImageView];
        return;
    }
    if(self.delegate){
        [self.delegate startLiveController:liveView.titleTextField.text image:liveView.coverImageView.image];
    }
}
#pragma mark trailerview 代理
- (void)trailerViewTakeCover:(TrailerView *)tv{
    [self openImageActionSheet];
}
- (void)trailerViewPublish:(TrailerView *)tv{
    if([trailerView.titleTextField.text isEqualToString:@""]){
        [[Common sharedInstance] shakeView:trailerView.titleTextField];
        return;
    }
    if(![trailerView.coverImageView viewWithTag:101]){
        [[Common sharedInstance] shakeView:trailerView.coverImageView];
        return;
    }
    if([trailerView.timeTextField.text isEqualToString:@""]){
        [[Common sharedInstance] shakeView:trailerView.timeTextField];
        return;
    }
    NSString *futureTime = trailerView.timeTextField.text;
    [HUD showText:@"正在发布预告" atMode:MBProgressHUDModeIndeterminate];
    [[Business sharedInstance] insertTrailer:trailerView.titleTextField.text
                                       phone:[UserInfo sharedInstance].userPhone
                                        time:futureTime
                                       image:trailerView.coverImageView.image
                                        succ:^(NSString *msg, id data) {
                                            [HUD hideText:msg atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                                [self dismissViewControllerAnimated:YES completion:^{
                                                    if(self.delegate){
                                                        [self.delegate publishTrailerSuccess];
                                                    }
                                                }];
                                            }];
                                        }
                                        fail:^(NSString *error) {
                                            [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                        }];


}
- (void)trailerViewTime:(TrailerView *)trailerView{
    [timePickView showView:self.view];
}
#pragma datepickview liveview 代理
- (void)datePickViewConfirm:(TimePickView *)dpv{
    trailerView.timeTextField.text = [timePickView getSelectTime];
    trailerView.leftTimeLabel.text = [timePickView getLeftTime];
}
#pragma mark 打开拍照或相册
- (void)openImageActionSheet{
    [liveView.titleTextField resignFirstResponder];
    [trailerView.titleTextField resignFirstResponder];
    [trailerView.timeTextField resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  @"拍照",
                                  @"相册", nil];
    actionSheet.cancelButtonIndex = 2;
    [actionSheet showInView:self.view];
}
#pragma mark 图片选择
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImageView* imageView = liveView.coverImageView;
    if(1 == [segmentView getSelectIndex]){
        imageView = trailerView.coverImageView;
    }
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

    } else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImageView* imageView = liveView.coverImageView;
    if(1 == [segmentView getSelectIndex]){
        imageView = trailerView.coverImageView;
    }
    UIImage* image = info[UIImagePickerControllerEditedImage];
    CGFloat hOffset = (image.size.height - 2*image.size.width/3)/2;
    imageView.image = [image getSubImage:CGRectMake(0, hOffset, image.size.width, 2*image.size.width/3)];
    UIView* tmp = [imageView viewWithTag:101];
    if(tmp == nil){
        UIButton* delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        delBtn.tag = 101;
        delBtn.frame = CGRectMake(imageView.frame.size.width-20, -10, 30, 30);
        [delBtn setImage:[UIImage imageNamed:@"close_circle"] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(delImage:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:delBtn];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 删除封面
- (void)delImage:(id)sender{
    UIImageView* imageView = (UIImageView*)((UIButton*)sender).superview;
    imageView.image = [UIImage imageNamed:@"addimage"];
    [((UIButton*)sender) removeFromSuperview];
}

@end