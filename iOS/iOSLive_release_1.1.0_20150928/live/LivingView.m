//
//  LivingView.m
//  live
//
//  Created by hysd on 15/7/18.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "LivingView.h"
#import "UserLogoCell.h"
#import "MessageView.h"
#import "WelcomeView.h"
#import "Macro.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+Category.h"
#import "UserInfo.h"
#define MESSAGE_SURVIVAL_TIME 20
@interface LivingView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>{
    NSMutableArray* messageViewArray;
    NSMutableArray* userArray;
    NSTimer* delMsgViewTimer;
}
@end

@implementation LivingView

- (void)awakeFromNib{
    //隐藏没做功能
    self.pushButton.hidden = YES;
    self.flashButton.hidden = YES;
    //背景透明
    self.backgroundColor = [UIColor clearColor];
    //容器
    self.messageScrollView.backgroundColor = [UIColor clearColor];
    self.messageContentView.backgroundColor = [UIColor clearColor];
    self.messageContainerView.backgroundColor = [UIColor clearColor];
    self.messageContainerView.clipsToBounds = YES;
    //测试按钮
    self.buttonContainer.backgroundColor = RGBA16(COLOR_BG_ALPHAWHITE);
    self.buttonContainer.layer.cornerRadius = 5;
    self.buttonContainer.clipsToBounds = YES;
    //视频参数
    self.paramTextView.layoutManager.allowsNonContiguousLayout = NO;
    self.paramTextView.backgroundColor = RGBA16(COLOR_BG_ALPHAWHITE);
    self.paramTextView.layer.cornerRadius = 5;
    self.paramTextView.clipsToBounds = YES;
    //头像容器
    self.logoContainerView.hidden = NO;
    self.logoContainerView.backgroundColor = [UIColor clearColor];
    //网络连接rongqi
    self.netContainerView.hidden = YES;
    self.netContainerView.backgroundColor = [UIColor clearColor];
    //圆形头像
    self.userLogoImageView.layer.borderWidth = 1;
    self.userLogoImageView.layer.borderColor = RGB16(COLOR_BG_WHITE).CGColor;
    self.userLogoImageView.layer.cornerRadius = self.userLogoImageView.frame.size.width/2;
    self.userLogoImageView.clipsToBounds = YES;
    self.userLogoImageView.image = [UIImage imageNamed:@"userlogo"];
    self.userLogoImageView.userInteractionEnabled = YES;
    [self.logoContainerView bringSubviewToFront:self.userLogoImageView];
    
    UITapGestureRecognizer *logoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTap:)];
    [self.userLogoImageView addGestureRecognizer:logoTap];
    //直播时间
    self.livingTimeLabel.textColor = RGB16(COLOR_FONT_WHITE);
    self.livingTimeLabel.text = @"00:00:00";
    //直播状态和时间
    self.liveStatusLabel.textColor = RGB16(COLOR_FONT_WHITE);
    self.liveStatusLabel.text = @"直播中";
    //直播状态和时间容器
    self.liveStatusView.backgroundColor = RGB16(COLOR_BG_RED);
    self.liveStatusView.layer.cornerRadius = 5;
//    CGRect statusFrame = self.liveStatusView.frame;
//    UIBezierPath* statusPath = [UIBezierPath bezierPath];
//    [statusPath moveToPoint:CGPointMake(0.0, 0.0)];
//    [statusPath addLineToPoint:CGPointMake(statusFrame.size.width-8, 0.0)];
//    [statusPath addLineToPoint:CGPointMake(statusFrame.size.width, statusFrame.size.height)];
//    [statusPath addLineToPoint:CGPointMake(0.0, statusFrame.size.height)];
//    [statusPath closePath];
//    CAShapeLayer* statusShape = [CAShapeLayer layer];
//    statusShape.path = [statusPath CGPath];
//    self.liveStatusView.layer.mask = statusShape;
    //发送编辑框
    self.messageTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么吧" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_BG_WHITE)}];
    self.messageTextField.backgroundColor = [UIColor clearColor];
    self.messageTextField.borderStyle = UITextBorderStyleNone;
    self.messageTextField.delegate = self;
    [self.messageTextField setReturnKeyType:UIReturnKeySend];
    //发送框容器
    self.logoMessageContainer.backgroundColor = RGBA16(COLOR_BG_ALPHAWHITE);
    self.logoMessageContainer.layer.cornerRadius = 5;
    self.logoMessageContainer.clipsToBounds = YES;
    //观看人数
    self.userCountLabel.layer.borderColor = RGB16(COLOR_BG_WHITE).CGColor;
    self.userCountLabel.layer.borderWidth = 1;
    self.userCountLabel.textColor = RGB16(COLOR_FONT_WHITE);
    self.userCountLabel.layer.cornerRadius = self.userCountLabel.frame.size.height/2;
    self.userCountLabel.clipsToBounds = YES;
    //点赞view
    self.loveView.backgroundColor = RGBA16(COLOR_BG_ALPHAWHITE);
    self.loveView.layer.cornerRadius = 5;
    self.loveView.clipsToBounds = YES;
    self.loveView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loveTap:)];
    [self.loveView addGestureRecognizer:tap];
    //点赞人数
    self.loveCountLabel.textColor = RGB16(COLOR_FONT_WHITE);
    //点赞图
    //用户头像集合
    //布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:9];
    [flowLayout setMinimumLineSpacing:9];
    [self.userCollectionView registerClass:[UserLogoCell class] forCellWithReuseIdentifier:@"UserLogoCell"];
    self.userCollectionView.collectionViewLayout = flowLayout;
    self.userCollectionView.delegate = self;
    self.userCollectionView.dataSource = self;
    self.userCollectionView.backgroundColor = [UIColor clearColor];
    self.userCollectionView.showsHorizontalScrollIndicator = NO;
    //消息队列
    messageViewArray = [[NSMutableArray alloc] init];
    //用户队列
    userArray = [[NSMutableArray alloc] init];
    //定时删除消息
    delMsgViewTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(delMsgView) userInfo:nil repeats:YES];
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
    self.messageTextField.inputAccessoryView = toolbar;
    
}
- (void)completeInput{
    [self.messageTextField resignFirstResponder];
}

#pragma mark 关闭视图
- (IBAction)closeLivingView:(id)sender {
    if(delMsgViewTimer){
        [delMsgViewTimer invalidate];
        delMsgViewTimer = nil;
    }
    if(self.delegate){
        [self.delegate closeLivingView:self];
    }
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.messageTextField resignFirstResponder];
    if(self.delegate){
        [self.delegate sendMessage:self];
        self.messageTextField.text = @"";
    }
    return YES;
}
#pragma mark collection data source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return userArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserLogoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserLogoCell" forIndexPath:indexPath];
    NSDictionary* userDic = [userArray objectAtIndex:indexPath.row];
    //头像
    NSString* logoPath = [userDic objectForKey:@"userLogo"];
    if([logoPath isEqualToString:@""]){
        cell.userLogoImageView.image = [UIImage imageNamed:@"userlogo"];
    }
    else{
        NSInteger width = cell.userLogoImageView.frame.size.width*SCALE;
        NSInteger height = width;
        NSString *myLogoUrl = [NSString stringWithFormat:URL_IMAGE,logoPath,width,height];
        [cell.userLogoImageView sd_setImageWithURL:[NSURL URLWithString:myLogoUrl] placeholderImage:[UIImage imageWithColor:RGB16(COLOR_FONT_WHITE) andSize:cell.userLogoImageView.frame.size]];
    }
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(35, 35);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate){
        [self.delegate clickAudienceLogo:self withPhone:[[userArray objectAtIndex:indexPath.row] objectForKey:@"userPhone"]];
    }
    return;
}
#pragma mark 定时删除消息
- (void)delMsgView{
    if(messageViewArray.count != 0){
        for(NSInteger index = 0; index < messageViewArray.count; index++){
            UIView* view = [messageViewArray objectAtIndex:index];
            NSDate* fromDate;
            if([view isKindOfClass:[MessageView class]]){
                fromDate = ((MessageView*)view).date;
            }
            if([view isKindOfClass:[WelcomeView class]]){
                fromDate = ((WelcomeView*)view).date;
            }
            NSInteger interval = [self getTimeIntervalFromNow:fromDate];
            if(MESSAGE_SURVIVAL_TIME <= interval){
                if(view.superview){
                    [messageViewArray removeObjectAtIndex:index];
                    --index;
                    [UIView animateWithDuration:0.3 animations:^{
                        view.alpha = 0;
                    }completion:^(BOOL finished) {
                        [view removeFromSuperview];
                    }];
                }
            }
        }
    }
}
#pragma mark 计算时间间隔
- (NSInteger)getTimeIntervalFromNow:(NSDate*)from{
    NSDate *to = [NSDate date];
    NSTimeInterval aTimer = [to timeIntervalSinceDate:from];
    int hour = (int)(aTimer/3600);
    int minute = (int)(aTimer - hour*3600)/60;
    int second = aTimer - hour*3600 - minute*60;
    return second;
}
#pragma mark 添加一条信息
- (void)addMessage:(NSString*)message andPhone:(NSString*)phone{
    if([message isEqualToString:@""]){
        return;
    }
    NSString* userName;
    NSString* userLogo;
    for(int index = 0; index < userArray.count; index++){
        NSDictionary* userDic = userArray[index];
        if([phone isEqualToString:[userDic objectForKey:@"userPhone"]]){
            userName = [userDic objectForKey:@"userName"];
            userLogo = [userDic objectForKey:@"userLogo"];
        }
    }
    BOOL isLiver;//是否为主播的信息
    if([phone isEqualToString:[UserInfo sharedInstance].liveUserPhone]){
        isLiver = YES;
    }
    else{
        isLiver = NO;
    }
    MessageView* messageView = [[MessageView alloc]
                                initWithView:self.messageContainerView
                                message:message
                                name:userName
                                logo:userLogo
                                liver:isLiver];
    //[self.messageContainerView addSubview:messageView];
    [messageViewArray addObject:messageView];
    [self moveMessageViewAnimate:messageView.frame.size.height];
}
- (void)addWelcome:(NSString*)name{
    if([name isEqualToString:@""]){
        return;
    }
    WelcomeView* welcomeView = [[WelcomeView alloc] initWithFrame:self.messageContainerView.frame andName:name];
    [self.messageContainerView addSubview:welcomeView];
    [messageViewArray addObject:welcomeView];
    [self moveMessageViewAnimate:welcomeView.frame.size.height];
}
- (void)moveMessageViewAnimate:(NSInteger)height{
    //上移动画
    [UIView animateWithDuration:0.3 animations:^(void){
        for (NSInteger index = 0; index < messageViewArray.count; index++) {
            UIView* view = [messageViewArray objectAtIndex:index];
            CGRect frame = view.frame;
            frame.origin.y -= height + 8;
            view.frame = frame;
            CGFloat alpha = 1 - (messageViewArray.count - index - 1)*0.2;
            if(alpha <= 0){
                if(view.superview){
                    [view removeFromSuperview];
                    [messageViewArray removeObjectAtIndex:index];
                    --index;
                }
            }
            else{
                view.alpha = alpha;
            }
        }
    }completion:^(BOOL finished){
        
    }];
}
#pragma mark 添加用户
- (void)addUsers:(NSArray*)users{
    for(NSInteger i = 0; i < users.count; i++){
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray* array = @[indexPath];
        [userArray insertObject:users[i] atIndex:0];
        [self.userCollectionView insertItemsAtIndexPaths:array];
    }
    //更新用户总数
    [self.userCountLabel setText:[[NSNumber numberWithLong:userArray.count] stringValue]];
}
#pragma mark 删除用户
- (void)delUsers:(NSArray*)phones{
    for(NSInteger i = 0; i < [phones count]; i++){
        for(NSInteger j = 0; j < [userArray count]; j++){
            NSDictionary* infoDic = userArray[j];
            if([phones[i] isEqualToString:[infoDic objectForKey:@"userPhone"]]){
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:j inSection:0];
                NSArray* array = @[indexPath];
                [userArray removeObjectAtIndex:j];
                [self.userCollectionView deleteItemsAtIndexPaths:array];
                break;
            }
        }
    }
    //更新用户总数
    [self.userCountLabel setText:[[NSNumber numberWithLong:userArray.count] stringValue]];
}
#pragma mark 点击用户头像
- (void)logoTap:(UITapGestureRecognizer*)recognizer{
    if(self.delegate){
        [self.delegate logoTap:self];
    }
}
#pragma mark 点赞
- (void)loveTap:(UITapGestureRecognizer*)recognizer{
    if(self.delegate){
        [self.delegate loveTap:self];
    }
}
- (void)addLove:(NSInteger)count{
    NSInteger newCount = [self.loveCountLabel.text integerValue] + count;
    self.loveCountLabel.text = [[NSNumber numberWithInteger:newCount] stringValue];
    
    int index = arc4random() % 6;
    NSString* imageName = [NSString stringWithFormat:@"heart%d",index];
    UIImageView* animateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    animateView.center = self.loveView.center;
    animateView.image = [UIImage imageNamed:imageName];
    [self.messageContentView addSubview:animateView];
    [UIView animateWithDuration:4 animations:^{
        animateView.frame = CGRectMake(animateView.frame.origin.x, 0, animateView.frame.size.width, animateView.frame.size.height);
        animateView.alpha = 0;
    }completion:^(BOOL finish){
        [animateView removeFromSuperview];
    }];
}
#pragma mark 打开麦克风
- (IBAction)openMike:(id)sender {
    if(self.delegate){
        [self.delegate openMike:self];
    }
}
#pragma mark 切换摄像头
- (IBAction)toggleCamera:(id)sender{
    if(self.delegate){
        [self.delegate toggleCamera:self];
    }
}
#pragma mark 推流
#warning 推流测试
- (IBAction)pushFLV:(id)sender {
    if(self.delegate){
        [self.delegate pushFLV:self];
    }
}

- (IBAction)pushHLS:(id)sender {
    if(self.delegate){
        [self.delegate pushHLS:self];
    }
}
- (IBAction)pushRTMP:(id)sender {
    if(self.delegate){
        [self.delegate pushRTMP:self];
    }
}

#pragma mark 录制
- (IBAction)liveREC:(id)sender {
    if(self.delegate){
        [self.delegate liveREC:self];
    }
}
#pragma mark 视频参数
- (IBAction)livePAR:(id)sender {
    if(self.delegate){
        [self.delegate livePAR:self];
    }
}

#pragma mark 旋转
- (void)netRotateStart{
    [self runSpinAnimationOnView:self.netImageView duration:0.4 repeat:FLT_MAX];
}
- (void)netRotateStop{
    [self.netImageView.layer removeAnimationForKey:@"rotationAnimation"];
}
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
@end
