//
//  EditTableViewController.m
//  live
//
//  Created by hysd on 15/8/28.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "EditTableViewController.h"
#import "EditTableViewCell.h"
#import "Macro.h"
#import "Business.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "UserInfo.h"
#import "GenderTableViewCell.h"
@interface EditTableViewController ()
{
    EditTableViewCell* editCell;
    MBProgressHUD* HUD;
    
    GenderTableViewCell* manCell;
    GenderTableViewCell* womanCell;
    NSInteger selectIndex;
}
@end

@implementation EditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.navTitle;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:RGB16(COLOR_FONT_RED), NSForegroundColorAttributeName,[UIFont systemFontOfSize:17],NSFontAttributeName,nil];
    
    self.tableView.backgroundColor = RGB16(0xf3f3f3);
    self.tableView.contentInset = UIEdgeInsetsMake(-14, 0, 0, 0);
    //设置右边title
    UIBarButtonItem* rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(EDIT_GERDER == self.editType){
        return 2;
    }
    else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(EDIT_GERDER == self.editType){
        if(0 == indexPath.row){
            if(manCell == nil){
                manCell = [[GenderTableViewCell alloc] init];
            }
            manCell.genderLabel.text = @"男";
            if([self.value isEqualToString:@"男"]){
                manCell.selectImageView.image = [UIImage imageNamed:@"genderselect"];
            }
            else{
                manCell.selectImageView.image = nil;
            }
            return manCell;
        }
        else{
            if(womanCell == nil){
                womanCell = [[GenderTableViewCell alloc] init];
            }
            womanCell.genderLabel.text = @"女";
            if([self.value isEqualToString:@"女"]){
                womanCell.selectImageView.image = [UIImage imageNamed:@"genderselect"];
            }
            else{
                womanCell.selectImageView.image = nil;
            }
            return womanCell;
        }
    }
    else{
        if(editCell == nil){
            editCell = [[EditTableViewCell alloc] init];
            editCell.editTextField.text = self.value;
        }
        return editCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(EDIT_GERDER == self.editType){
        selectIndex = indexPath.row;
        if(selectIndex == 0){
            manCell.selectImageView.image = [UIImage imageNamed:@"genderselect"];
            womanCell.selectImageView.image = nil;
        }
        else{
            manCell.selectImageView.image = nil;
            womanCell.selectImageView.image = [UIImage imageNamed:@"genderselect"];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (void)save{
    if([editCell.editTextField.text  isEqualToString:@""]){
        [[Common sharedInstance] shakeView:editCell];
        return;
    }
    [HUD showText:@"正在保存" atMode:MBProgressHUDModeIndeterminate];
    
    NSString* phone = [UserInfo sharedInstance].userPhone;
    NSString* name = [UserInfo sharedInstance].userName;
    NSString* gender = [UserInfo sharedInstance].userGender;
    NSString* address = [UserInfo sharedInstance].userAddress;
    NSString* sig = [UserInfo sharedInstance].userSignature;
    
    if(EDIT_NAME == self.editType){
        sig = editCell.editTextField.text;
    }
    else if(EDIT_GERDER == self.editType){
        if(selectIndex == 0){
            gender = @"男";
        }
        else{
            gender = @"女";
        }
    }
    else if(EDIT_ADDR == self.editType){
        address = editCell.editTextField.text;
    }
    else if(EDIT_SIG == self.editType){
        sig = editCell.editTextField.text;
    }
    [[Business sharedInstance] saveUserInfo:phone
                                       name:name
                                     gender:gender
                                    address:address
                                  signature:sig
                                      image:nil
                                       succ:^(NSString *msg, id data) {
                                           [HUD hideText:@"保存成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                               if(EDIT_NAME == self.editType){
                                                   [UserInfo sharedInstance].userName = editCell.editTextField.text;
                                               }
                                               else if(EDIT_GERDER == self.editType){
                                                   if(selectIndex == 0){
                                                       [UserInfo sharedInstance].userGender = @"男";
                                                   }
                                                   else{
                                                       [UserInfo sharedInstance].userGender  = @"女";
                                                   }
                                               }
                                               else if(EDIT_ADDR == self.editType){
                                                   [UserInfo sharedInstance].userAddress = editCell.editTextField.text;
                                               }
                                               else if(EDIT_SIG == self.editType){
                                                    [UserInfo sharedInstance].userSignature = editCell.editTextField.text;
                                               }
                                               if(self.delegate){
                                                   [self.delegate editSuccess];
                                               }
                                               [self.navigationController popViewControllerAnimated:YES];
                                           }];

                                       } fail:^(NSString *error) {
                                           
                                           [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                       }];
}

@end
