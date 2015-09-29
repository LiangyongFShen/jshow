//
//  WatchLiveTableViewController.m
//  live
//
//  Created by kenneth on 15-7-10.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "WatchLiveTableViewController.h"
#import "WatchLiveTableViewCell.h"
#import "MyLiveViewController.h"
#import "Macro.h"
#import "MJRefresh.h"
#import "AFHTTPRequestOperationManager.h"
#import "UserInfo.h"
#import "LoginViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+Category.h"
#import "SegmentView.h"
#import "LiveTrailerTableViewCell.h"
#import "MBProgressHUD.h"
#import "Business.h"
#import "TrailerAlertView.h"
#import "DoLiveViewController.h"
@interface WatchLiveTableViewController ()<SegmentViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,DoLiveDelegate,WatchLiveCellDelegate>
{
    MJRefreshNormalHeader *liveHeader;//下拉刷新
    MJRefreshBackNormalFooter *liveFooter;//上拉加载
    MJRefreshNormalHeader *trailerHeader;//下拉刷新
    MJRefreshBackNormalFooter *trailerFooter;//上拉加载
    NSMutableArray* liveArray;//直播列表
    NSMutableArray* trailerArray;//预告列表
    
    NSTimer* refreshLiveTimer;
    NSTimer* refreshTrailerTimer;
    
    UIBarButtonItem* rightBarItem;
    SegmentView* segmentView;
    UITableView* liveTableView;
    UITableView* trailerTableView;
    UIScrollView* scrollView;
    UIView* contentView;
    
    MBProgressHUD* HUD;
}
@end

@implementation WatchLiveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    //分段视图
    NSArray* items = [NSArray arrayWithObjects:@"最新直播",@"直播预告", nil];
    CGRect segmentFrame = CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH/2, 44);
    segmentView = [[SegmentView alloc] initWithFrame:segmentFrame andItems:items andSize:17 border:NO];
    segmentView.delegate = self;
    self.navigationItem.titleView = segmentView;
    //设置scrollview
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-NAVIGATIONBAR_HEIGHT-TABBAR_HEIGHT-STATUS_HEIGHT)];
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
    //设置tableview
    liveTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, contentView.frame.size.height)];
    liveTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    liveTableView.delegate = self;
    liveTableView.dataSource = self;
    liveTableView.backgroundColor = [UIColor clearColor];
    liveArray = [[NSMutableArray alloc] init];
    [contentView addSubview:liveTableView];
    
    trailerTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, contentView.frame.size.height)];
    trailerTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    trailerTableView.delegate = self;
    trailerTableView.dataSource = self;
    trailerTableView.backgroundColor = [UIColor clearColor];
    trailerArray = [[NSMutableArray alloc] init];
    [contentView addSubview:trailerTableView];
    //添加下拉刷新
    liveHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshLiveData)];
    liveHeader.stateLabel.hidden = YES;
    liveHeader.lastUpdatedTimeLabel.hidden = YES;
    liveTableView.header = liveHeader;
    
    trailerHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTrailerData)];
    trailerHeader.stateLabel.hidden = YES;
    trailerHeader.lastUpdatedTimeLabel.hidden = YES;
    trailerTableView.header = trailerHeader;
    //添加上拉加载
    liveFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadLiveData)];
    liveFooter.stateLabel.hidden = YES;
    liveTableView.footer = liveFooter;
    
    trailerFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadTrailerData)];
    trailerFooter.stateLabel.hidden = YES;
    trailerTableView.footer = trailerFooter;
    //初始化MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.hidden = YES;
    //获取数据
    [liveHeader beginRefreshing];
    [trailerHeader beginRefreshing];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //定时刷新
    refreshLiveTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refreshLive) userInfo:nil repeats:YES];
    //定时更新时间
    refreshTrailerTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTrailerTime) userInfo:nil repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(refreshLiveTimer){
        [refreshLiveTimer invalidate];
        refreshLiveTimer = nil;
    }
    if(refreshTrailerTimer){
        [refreshTrailerTimer invalidate];
        refreshTrailerTimer = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma segmentview 代理
- (void)segmentView:(SegmentView *)segmentView selectIndex:(NSInteger)index{
    [UIView animateWithDuration:0.2f animations:^{
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width*index, 0);
    }];
}
#pragma mark 刷新数据和加载数据
- (void)refreshLiveData{
    [self requestLiveData:@""];
}
- (void)loadLiveData{
    //[self requestLiveData:[[liveArray lastObject] objectForKey:@"begin_time"]];
    [liveFooter endRefreshing];
}
- (void)refreshTrailerData{
    [self requestTrailerData:@""];
}
- (void)loadTrailerData{
    [self requestTrailerData:[[trailerArray lastObject] objectForKey:@"starttime"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == liveTableView){
        return liveArray.count;
    }
    else{
        return trailerArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == liveTableView){
        NSDictionary* dataDic = [liveArray objectAtIndex:indexPath.row];
        WatchLiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WatchLiveCell"];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WatchLiveTableViewCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        NSString* logoPath = [dataDic objectForKey:@"headimagepath"];
        if([logoPath isEqualToString:@""]){
            cell.userLogoImageView.image = [UIImage imageNamed:@"userlogo"];
        }
        else{
            NSInteger width = cell.userLogoImageView.frame.size.width*SCALE;
            NSInteger height = width;
            NSString *logoUrl = [NSString stringWithFormat:URL_IMAGE,logoPath,width,height];
            [cell.userLogoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageWithColor:RGB16(COLOR_FONT_WHITE) andSize:cell.userLogoImageView.frame.size]];
        }
        NSString* coverPath = [dataDic objectForKey:@"coverimagepath"];
        if([coverPath isEqualToString:@""]){
            cell.liveImageView.image = [UIImage imageNamed:@"liveimage"];
        }
        else{
            NSInteger width = cell.liveImageView.frame.size.width*SCALE;
            NSInteger height = cell.liveImageView.frame.size.height*SCALE;
            NSString *coverUrl = [NSString stringWithFormat:URL_IMAGE,coverPath,width,height];
            [cell.liveImageView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:[UIImage imageWithColor:RGB16(COLOR_FONT_WHITE) andSize:cell.liveImageView.frame.size]];
        }
        cell.userNameLabel.text = [NSString stringWithFormat:@"@%@",[dataDic objectForKey:@"username"]];
        cell.liveTitleLabel.text = [dataDic objectForKey:@"subject"];
        cell.praiseNumLabel.text = [dataDic objectForKey:@"praisenum"];
        cell.audienceNumLabel.text = [dataDic objectForKey:@"viewernum"];
        return cell;
    }
    else{
        NSDictionary* dataDic = [trailerArray objectAtIndex:indexPath.row];
        LiveTrailerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveTrailerCell"];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LiveTrailerTableViewCell" owner:self options:nil] lastObject];
        }
        //封面
        NSString* coverPath = [dataDic objectForKey:@"coverimagepath"];
        if([coverPath isEqualToString:@""]){
            cell.trailerImageView.image = [UIImage imageNamed:@"liveimage"];
        }
        else{
            NSInteger width = cell.trailerImageView.frame.size.width*SCALE;
            NSInteger height = width/2;
            NSString *coverUrl = [NSString stringWithFormat:URL_IMAGE,coverPath,width,height];
            [cell.trailerImageView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:[UIImage imageWithColor:RGB16(COLOR_FONT_WHITE) andSize:cell.trailerImageView.frame.size]];
        }
        //头像
        NSString* logoPath = [dataDic objectForKey:@"headimagepath"];
        if([logoPath isEqualToString:@""]){
            cell.logoImageView.image = [UIImage imageNamed:@"userlogo"];
        }
        else{
            NSInteger width = cell.logoImageView.frame.size.width*SCALE;
            NSInteger height = width;
            NSString *logoUrl = [NSString stringWithFormat:URL_IMAGE,logoPath,width,height];
            [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageWithColor:RGB16(COLOR_FONT_WHITE) andSize:cell.logoImageView.frame.size]];
        }

        //标题
        cell.trailerTitleLabel.text = [dataDic objectForKey:@"subject"];
        //发布人
        cell.trailerUserLabel.text = [dataDic objectForKey:@"username"];
        //发布时间
        cell.leftTimeLabel.text = [self getTimeIntervalFromNow:[dataDic objectForKey:@"starttime"]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 2*SCREEN_WIDTH/3;
}

- (void)watchLogoTap:(UITableViewCell *)watchCell{
    
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == liveTableView){
        NSDictionary* item = [liveArray objectAtIndex:indexPath.row];
        if([[item objectForKey:@"userphone"] isEqualToString:[UserInfo sharedInstance].userPhone]){
            return;
        }
        
        MyLiveViewController* myLiveViewController = [[MyLiveViewController alloc ] init];
        [UserInfo sharedInstance].liveUserPhone = [item objectForKey:@"userphone"];
        [UserInfo sharedInstance].liveUserName = [item objectForKey:@"username"];
        [UserInfo sharedInstance].liveUserLogo = [item objectForKey:@"headimagepath"];
        [UserInfo sharedInstance].liveTime = [item objectForKey:@"begin_time"];
        [UserInfo sharedInstance].liveRoomId = [[item objectForKey:@"programid"] integerValue];
        [UserInfo sharedInstance].chatRoomId = [item objectForKey:@"groupid"];
        [UserInfo sharedInstance].liveTitle = [item objectForKey:@"subject"];
        [UserInfo sharedInstance].liveType = LIVE_WATCH;
        [UserInfo sharedInstance].livePraiseNum = [item objectForKey:@"praisenum"];
        [self presentViewController:myLiveViewController animated:YES completion:nil];
    }
    else{
        NSDictionary* item = [trailerArray objectAtIndex:indexPath.row];
        NSString* name = [item objectForKey:@"username"];
        NSString* logo = [item objectForKey:@"headimagepath"];
        NSString* time = [item objectForKey:@"starttime"];
        TrailerAlertView* alert = [[TrailerAlertView alloc] init];
        [alert showTime:time logo:logo name:name praise:@"2453"];
    }
}
#pragma mark scrollview 代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll
{
    CGPoint offset = scrollView.contentOffset;
    NSInteger page = (offset.x + scrollView.frame.size.width/2) / scrollView.frame.size.width;
    [segmentView setSelectIndex:page];
}
#pragma mark 定时更新预告剩余时间
- (void)updateTrailerTime{
    NSArray* visibleCells = trailerTableView.visibleCells;
    if(visibleCells && 0 != visibleCells.count){
        for(LiveTrailerTableViewCell* cell in visibleCells){
            NSIndexPath* indexPath = [trailerTableView indexPathForCell:cell];
            NSString* time = [trailerArray[indexPath.row] objectForKey:@"starttime"];
            NSString* leftTime = [self getTimeIntervalFromNow:time];
            if([leftTime isEqualToString:@""]){
//                [trailerArray removeObjectAtIndex:indexPath.row];
//                [trailerTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                cell.leftTimeLabel.text = @"即将开播";
                cell.leftTimeView.backgroundColor = RGB16(COLOR_BG_RED);
            }
            else{
                cell.leftTimeLabel.text = leftTime;
            }
        }
    }
}
#pragma mark - 获取列表
- (void)refreshLive{
    [[Business sharedInstance] getLives:@"" succ:^(NSString *msg, id data) {
        [liveArray removeAllObjects];
        [liveArray addObjectsFromArray:data];
        [liveTableView reloadData];
        [liveHeader endRefreshing];
    } fail:^(NSString *error) {
        [liveHeader endRefreshing];
    }];
}
- (void)requestLiveData:(NSString*)lastTime{
    [[Business sharedInstance] getLives:lastTime succ:^(NSString *msg, id data) {
        if([lastTime isEqualToString:@""]){
            //刷新，如果是加载更多不用删除旧数据
            [liveArray removeAllObjects];
        }
        [liveArray addObjectsFromArray:data];
        [liveTableView reloadData];
        [liveHeader endRefreshing];
        [liveFooter endRefreshing];
    } fail:^(NSString *error) {
        [liveHeader endRefreshing];
        [liveFooter endRefreshing];
    }];
}
- (void)requestTrailerData:(NSString*)lastTime{
    [[Business sharedInstance] getTrailers:lastTime succ:^(NSString *msg, id data) {
        if([lastTime isEqualToString:@""]){
            //刷新，如果是加载更多不用删除旧数据
            [trailerArray removeAllObjects];
        }
        [trailerArray addObjectsFromArray:data];
        [trailerTableView reloadData];
        [trailerHeader endRefreshing];
        [trailerFooter endRefreshing];
    } fail:^(NSString *error) {
        [trailerHeader endRefreshing];
        [trailerFooter endRefreshing];
    }];
}
#pragma mark 发布成功代理
- (void)publishTrailerSuccess{
    [trailerHeader beginRefreshing];
}
#pragma mark 计算时间间隔
- (NSString*)getTimeIntervalFromNow:(NSString*)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *to = [formatter dateFromString:time];
    NSDate *from = [NSDate date];
    NSTimeInterval aTimer = [to timeIntervalSinceDate:from];
    int hour = (int)(aTimer/3600);
    int minute = (int)(aTimer - hour*3600)/60;
    int second = aTimer - hour*3600 - minute*60;
    NSString* dural = @"";
    if(second < 0){
        return dural;
    }
    if(0 != hour){
        dural = [dural stringByAppendingString:[NSString stringWithFormat:@"%d%d时",hour/10,hour%10]];
        dural = [dural stringByAppendingString:[NSString stringWithFormat:@"%d%d分",minute/10,minute%10]];
    }
    else{
        dural = [dural stringByAppendingString:[NSString stringWithFormat:@"%d%d分",minute/10,minute%10]];
        dural = [dural stringByAppendingString:[NSString stringWithFormat:@"%d%d秒",second/10,second%10]];
    }
    return dural;
}
@end
