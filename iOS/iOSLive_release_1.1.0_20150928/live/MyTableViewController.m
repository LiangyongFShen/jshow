//
//  MyTableViewController.m
//  live
//
//  Created by hysd on 15/8/28.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "MyTableViewController.h"
#import "Macro.h"
#import "UserInfo.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+Category.h"
#import "Business.h"
#import "LiveAlertView.h"
#import "AboutAlertView.h"
#import "MyLogoTableViewCell.h"
#import "MyInfoTableViewCell.h"
#import "MyAppTableViewCell.h"
#import "MBProgressHUD.h"
#import "MultiIMManager.h"
#import "EditTableViewController.h"
@interface MyTableViewController ()<MyAppDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,EditControllerDelegate>
{
    MyLogoTableViewCell* logoCell;
    MyInfoTableViewCell* nameCell;
    MyInfoTableViewCell* genderCell;
    MyInfoTableViewCell* addrCell;
    MyInfoTableViewCell* sigCell;
    MyAppTableViewCell* appCell;
    
    MBProgressHUD *HUD;
}
@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的资料";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:RGB16(COLOR_FONT_RED), NSForegroundColorAttributeName,[UIFont systemFontOfSize:17],NSFontAttributeName,nil];
    self.tableView.backgroundColor = RGB16(0xf3f3f3);
    self.tableView.contentInset = UIEdgeInsetsMake(-14, 0, 0, 0);
    
    //初始化MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(0 == section || 2 == section){
        return 1;
    }
    else{
        return 4;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(0 == indexPath.section){
        if(logoCell == nil){
            logoCell = [[MyLogoTableViewCell alloc] init];
            logoCell.keyLabel.text = @"头像";
            NSInteger width = logoCell.valueImageView.frame.size.width*SCALE;
            NSInteger height = width;
            NSString *logoUrl = [NSString stringWithFormat:URL_IMAGE,[UserInfo sharedInstance].userLogo,width,height];
            [logoCell.valueImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageWithColor:RGB16(COLOR_FONT_WHITE) andSize:logoCell.valueImageView.frame.size]];
        }
        return logoCell;
    }
    else if(2 == indexPath.section){
        if(appCell == nil){
            appCell = [[MyAppTableViewCell alloc] init];
            appCell.delegate = self;
        }
        return appCell;
    }
    else{
        if(0 == indexPath.row){
            if(nameCell == nil){
                nameCell = [[MyInfoTableViewCell alloc] init];
                //可以去掉某一个cell的分割线
                //nameCell.separatorInset = UIEdgeInsetsMake(0.f, nameCell.bounds.size.width, 0.f, 0.f);
            }
            nameCell.keyLabel.text = @"昵称";
            nameCell.valueLabel.text = [UserInfo sharedInstance].userName;
            return nameCell;
        }
        else if(1 == indexPath.row){
            if(genderCell == nil){
                genderCell = [[MyInfoTableViewCell alloc] init];
            }
            genderCell.keyLabel.text = @"性别";
            genderCell.valueLabel.text = [UserInfo sharedInstance].userGender;
            return genderCell;
        }
        else if(2 == indexPath.row){
            if(addrCell == nil){
                addrCell = [[MyInfoTableViewCell alloc] init];
            }
            addrCell.keyLabel.text = @"地址";
            addrCell.valueLabel.text = [UserInfo sharedInstance].userAddress;
            return addrCell;
        }
        else{
            if(sigCell == nil){
                sigCell = [[MyInfoTableViewCell alloc] init];
            }
            sigCell.keyLabel.text = @"签名";
            sigCell.valueLabel.text = [UserInfo sharedInstance].userSignature;
            return sigCell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(0 == indexPath.section){
        return 80;
    }
    if(2 == indexPath.section){
        return 120;
    }
    else{
        return 44;
    }
}

#pragma mark myappcell 代理
- (void)logout{
    LiveAlertView* alert = [[LiveAlertView alloc] init];
    [alert showTitle:@"确定退出随心播吗" confirmTitle:@"退出登录" cancelTitle:@"暂不退出" confirm:^{
        [HUD showText:@"正在退出" atMode:MBProgressHUDModeIndeterminate];
        [[MultiIMManager sharedInstance] logoutSucc:^(NSString *msg) {
            [HUD hideText:msg atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
            [[UserInfo sharedInstance] resetInfo];
            [self.tabBarController dismissViewControllerAnimated:YES completion:NO];
        } fail:^(NSString *err) {
            [HUD hideText:err atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
        }];
    }cancel:nil];
}
- (void)about{
    AboutAlertView* alert = [[AboutAlertView alloc] init];
    [alert showTitle:@"关于随心播" content:@""];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(0 == indexPath.section){
        [self logoClick];
    }
    else{
        NSString* value = nil;
        enum EDITTYPE type;
        NSString* title = nil;
        if(0 == indexPath.row){
            title = @"名字";
            type = EDIT_NAME;
            value = nameCell.valueLabel.text;
        }
        else if(1 == indexPath.row){
            title = @"性别";
            type = EDIT_GERDER;
            value = genderCell.valueLabel.text;
        }
        else if(2 == indexPath.row){
            title = @"地址";
            type = EDIT_ADDR;
            value = addrCell.valueLabel.text;
        }
        else if(3 == indexPath.row){
            title = @"个性签名";
            type = EDIT_SIG;
            value = sigCell.valueLabel.text;
        }
        EditTableViewController* edit = [[EditTableViewController alloc] init];
        edit.navTitle = title;
        edit.editType = type;
        edit.value = value;
        edit.delegate = self;
        [self.navigationController pushViewController:edit animated:YES];
    }
}
#pragma mark 修改成功
- (void)editSuccess{
    [self.tableView reloadData];
    [[UserInfo sharedInstance] saveUserToLocal];
}
#pragma mark 点击头像
- (void)logoClick{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照",
                                  @"从相册获取", nil];
    actionSheet.cancelButtonIndex = 2;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    };
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
    logoCell.isModLogo = YES;
    logoCell.valueImageView.image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];

    [HUD showText:@"正在保存" atMode:MBProgressHUDModeIndeterminate];
    NSString* phone = [UserInfo sharedInstance].userPhone;
    NSString* name = [UserInfo sharedInstance].userName;
    NSString* gender = [UserInfo sharedInstance].userGender;
    NSString* address = [UserInfo sharedInstance].userAddress;
    NSString* sig = [UserInfo sharedInstance].userSignature;
    [[Business sharedInstance] saveUserInfo:phone
                                       name:name
                                     gender:gender
                                    address:address
                                  signature:sig
                                      image:logoCell.valueImageView.image
                                       succ:^(NSString *msg, id data) {
                                           [UserInfo sharedInstance].userLogo = [data objectForKey:@"headimagepath"];
                                           [[UserInfo sharedInstance] saveUserToLocal];
                                           [HUD hideText:msg atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                       } fail:^(NSString *error) {
                                           [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                       }];

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
