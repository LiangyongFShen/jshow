//
//  Macro.h
//  live
//
//  Created by kenneth on 15-7-9.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#ifndef live_Macro_h
#define live_Macro_h

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCALE ([UIScreen mainScreen].scale);
//状态栏、导航栏、标签栏高度
#define STATUS_HEIGHT ([UIApplication sharedApplication].statusBarFrame.size.height)
#define NAVIGATIONBAR_HEIGHT (self.navigationController.navigationBar.frame.size.height)
#define TABBAR_HEIGHT (self.tabBarController.tabBar.frame.size.height)

//字体颜色
#define COLOR_FONT_RED   0xD54A45
#define COLOR_FONT_WHITE 0xFFFFFF
#define COLOR_FONT_LIGHTWHITE 0xEEEEEE
#define COLOR_FONT_DARKGRAY  0x555555
#define COLOR_FONT_GRAY  0x777777
#define COLOR_FONT_LIGHTGRAY  0x999999
#define COLOR_FONT_BLACK 0x000000

//背景颜色
#define COLOR_BG_GRAY      0xEDEDED
#define COLOR_BG_ALPHABLACK     0x88000000
#define COLOR_BG_ORANGE 0xf69e21
#define COLOR_BG_ALPHARED  0x88D54A45
#define COLOR_BG_LIGHTGRAY 0xEEEEEE
#define COLOR_BG_ALPHAWHITE 0x55FFFFFF
#define COLOR_BG_WHITE     0xFFFFFF
#define COLOR_BG_DARKGRAY     0xAFAEAE
#define COLOR_BG_RED       0xD54A45
#define COLOR_BG_BLUE      0x4586DA
#define COLOR_BG_CLEAR     0x00000000

//rbg转UIColor(16进制)
#define RGB16(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBA16(rgbaValue) [UIColor colorWithRed:((float)((rgbaValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbaValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbaValue & 0xFF))/255.0 alpha:((float)((rgbaValue & 0xFF000000) >> 24))/255.0]

//url
//已经是群成员
#define URL_REQUEST_SUCCESS 200
#define URL_ROOM_CLOSE 562
#define URL_REGISTER_FAIL 561
#define URL_REGISTER_PHONEUSED 562
#define URL_REGISTER_NAMEUSED 563
#define URL_REGISTER_NOIMAGE 260
#define URL_SAVEUSER_NOIMAGE 260
#define URL_SAVE_NAMEUSED 562
//入口
#define URL_ENTRY @"http://203.195.167.34"
//直播列表
#define URL_LIVELIST [URL_ENTRY stringByAppendingString:@"/live_listget.php"]
//预告列表
#define URL_TRAILERLIST [URL_ENTRY stringByAppendingString:@"/live_forcastlist.php"]
//获取房间号
#define URL_GETROOMID [URL_ENTRY stringByAppendingString:@"/create_room_id.php"]
//创建房间
#define URL_CREATELIVE [URL_ENTRY stringByAppendingString:@"/live_create.php"]
//创建预告
#define URL_CREATETRAILER [URL_ENTRY stringByAppendingString:@"/live_forcastcreate.php"]
//关闭房间
#define URL_CLOSELIVE [URL_ENTRY stringByAppendingString:@"/live_close.php"]
//进入房间
#define URL_ENTERROOM [URL_ENTRY stringByAppendingString:@"/enter_room.php"]
//关闭房间
#define URL_LEAVEROOM [URL_ENTRY stringByAppendingString:@"/room_withdraw.php"]
//登录
#define URL_LOGIN [URL_ENTRY stringByAppendingString:@"/login.php"]
//注册
#define URL_REGISTER [URL_ENTRY stringByAppendingString:@"/register.php"]
//获取用户信息
#define URL_GETUSER [URL_ENTRY stringByAppendingString:@"/getuserinfo.php"]
//修改用户信息
#define URL_SAVEUSER [URL_ENTRY stringByAppendingString:@"/user_saveinfo.php"]
//获取图片url
#define URL_IMAGE [URL_ENTRY stringByAppendingString:@"/image_get.php?imagepath=%@&width=%d&height=%d"]
//点赞
#define URL_PRAISE [URL_ENTRY stringByAppendingString:@"/live_addpraise.php"]
//crash上报
#define URL_LOGREPORT [URL_ENTRY stringByAppendingString:@"/log.php"]
//批量获取用户
#define URL_USERLIST [URL_ENTRY stringByAppendingString:@"/user_getinfobatch.php"]
//获取特定房间信息
#define URL_LIVEINFO [URL_ENTRY stringByAppendingString:@"/live_infoget.php"]
//心跳检测
#define URL_HEARTTIME [URL_ENTRY stringByAppendingString:@"/update_heart.php"]


//自定义消息命令
#define MSG_SEPERATOR @"&"
#define MSG_PRAISE @"%@&%d&%d" //userphone&cmd&praisecount
#define MSG_ADDUSER @"%@&%d&%@&%@"  //userphone&cmd&username&userlogo
#define MSG_DELUSER @"%@&%d" //userphone&cmd
#define MSG_CMD_PRAISE 1
#define MSG_CMD_ADDUSER 2
#define MSG_CMD_DELUSER 3

//通知标识
#define NOTIFICATION_IMNETWORK @"NOTIFICATION_IMNETWORK"
#endif
