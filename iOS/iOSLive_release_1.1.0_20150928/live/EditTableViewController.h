//
//  EditTableViewController.h
//  live
//
//  Created by hysd on 15/8/28.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <UIKit/UIKit.h>
enum EDITTYPE{
    EDIT_NAME = 0,
    EDIT_GERDER,
    EDIT_ADDR,
    EDIT_SIG,
    EDIT_NONE
};

@protocol EditControllerDelegate <NSObject>
- (void)editSuccess;
@end
@interface EditTableViewController : UITableViewController
@property (weak,nonatomic) id<EditControllerDelegate> delegate;
@property (strong,nonatomic) NSString* navTitle;
@property (nonatomic) enum EDITTYPE editType;
@property (strong,nonatomic) NSString* value;
@end
