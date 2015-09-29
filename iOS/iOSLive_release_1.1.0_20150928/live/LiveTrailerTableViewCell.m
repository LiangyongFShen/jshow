//
//  LiveTrailerTableViewCell.m
//  live
//
//  Created by hysd on 15/7/13.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "LiveTrailerTableViewCell.h"
#import "Macro.h"
@implementation LiveTrailerTableViewCell

- (void)awakeFromNib {
    //选中背景不发生改变
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //self.layer.cornerRadius = 5;
    //self.clipsToBounds = YES;
    //剩余时间
    self.leftTimeView.backgroundColor = RGB16(COLOR_BG_ORANGE);
    self.leftTimeView.layer.cornerRadius = 2;
    self.leftTimeView.clipsToBounds = YES;
    self.leftTimeLabel.textColor = RGB16(COLOR_FONT_WHITE);
    //圆形头像
    self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width/2;
    self.logoImageView.clipsToBounds = YES;
    self.logoImageView.layer.borderWidth = 1;
    self.logoImageView.layer.borderColor = RGB16(COLOR_BG_WHITE).CGColor;
    //标题
    self.trailerTitleLabel.textColor = RGB16(COLOR_FONT_WHITE);
    //主播
    self.trailerUserLabel.textColor = RGB16(COLOR_FONT_WHITE);
    //容器
    self.containerView.backgroundColor = RGBA16(COLOR_BG_ALPHABLACK);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    //更改x
    //frame.origin.x += 5;
    //更改宽高
    frame.size.height -= 5;
    //frame.size.width -= 10;
    [super setFrame:frame];
}
@end
