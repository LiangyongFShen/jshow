//
//  RecordParamView.h
//  live
//
//  Created by hysd on 15/8/24.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^RecordConfirm)();
typedef void (^RecordCancel)();
@interface RecordParamView : UIView
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *titleBgView;
@property (weak, nonatomic) IBOutlet UITextField *fileTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet UITextField *classTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)confirmAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
/**
 *  showView
 *  @param superView  父view
 *  @param title      标题
 *  @param conTitle   确定
 *  @param canTitle   取消
 *  @param confirm    确定block
 *  @param cancel     取消block
 */
@property (weak, nonatomic) IBOutlet UISwitch *codeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cutSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *waterSwitch;
- (void)showTitle:(NSString*)title confirmTitle:(NSString*)conTitle cancelTitle:(NSString*)canTitle confirm:(RecordConfirm)confirm cancel:(RecordCancel)cancel;
@end
