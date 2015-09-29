//
//  LivingView.h
//  live
//
//  Created by hysd on 15/7/18.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LivingView;
@protocol LivingViewDelegate <NSObject>
@optional
- (void)sendMessage:(LivingView*)livingView;
- (void)toggleCamera:(LivingView*)livingView;
- (void)openMike:(LivingView*)livingView;
- (void)closeLivingView:(LivingView*)livingView;
- (void)logoTap:(LivingView*)livingView;
- (void)loveTap:(LivingView*)livingView;
- (void)clickAudienceLogo:(LivingView*)livingView withPhone:(NSString*)phone;
#warning 推流测试
- (void)pushFLV:(LivingView*)livingView;
- (void)pushHLS:(LivingView*)livingView;
- (void)pushRTMP:(LivingView*)livingView;
- (void)liveREC:(LivingView*)livingView;
- (void)livePAR:(LivingView*)livingView;
@end

@interface LivingView : UIView
@property (nonatomic, weak) id <LivingViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *livingTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *logoMessageContainer;
@property (weak, nonatomic) IBOutlet UILabel *userCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loveImageView;
@property (weak, nonatomic) IBOutlet UILabel *loveCountLabel;
@property (weak, nonatomic) IBOutlet UIView *loveView;
@property (weak, nonatomic) IBOutlet UICollectionView *userCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *netImageView;

@property (weak, nonatomic) IBOutlet UIView *liveStatusView;
@property (weak, nonatomic) IBOutlet UILabel *liveStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *pushButton;
@property (weak, nonatomic) IBOutlet UIButton *mikeButton;
//发送消息和消息展示的滚动窗口，用于键盘弹起时滚动
@property (weak, nonatomic) IBOutlet UIScrollView *messageScrollView;
//发送消息和消息展示的内容视图
@property (weak, nonatomic) IBOutlet UIView *messageContentView;
//消息展示的容器视图
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIView *logoContainerView;
@property (weak, nonatomic) IBOutlet UIView *netContainerView;

- (IBAction)closeLivingView:(id)sender;
- (IBAction)openMike:(id)sender;
- (IBAction)toggleCamera:(id)sender;
//添加信息
- (void)addMessage:(NSString*)message andPhone:(NSString*)phone;
- (void)addWelcome:(NSString*)name;
//添加用户
- (void)addUsers:(NSArray*)users;
//删除用户
- (void)delUsers:(NSArray*)phones;
//增加点赞
- (void)addLove:(NSInteger)count;

#warning 推流测试
//测试推流
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UITextView *paramTextView;
- (IBAction)pushFLV:(id)sender;
- (IBAction)pushHLS:(id)sender;
- (IBAction)liveREC:(id)sender;
- (IBAction)livePAR:(id)sender;
- (IBAction)pushRTMP:(id)sender;

//旋转
- (void)netRotateStart;
- (void)netRotateStop;
@end
