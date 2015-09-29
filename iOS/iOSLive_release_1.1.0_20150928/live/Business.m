//
//  Business.m
//  live
//
//  Created by hysd on 15/8/6.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "Business.h"
#import "Macro.h"
@interface Business(){
}
@end
@implementation Business
static Business *sharedObj = nil;
+ (Business*) sharedInstance
{
    @synchronized (self)
    {
        if (sharedObj == nil)
        {
            sharedObj = [[self alloc] init];
        }
    }
    return sharedObj;
}

- (void)loginPhone:(NSString*)phone pass:(NSString*)pass succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:
                      @"{\"userphone\":\"%@\",\"password\":\"%@\",\"force\":1}",
                      phone,
                      pass];
    NSDictionary *parameter = @{@"logindata":json,@"version":@"33"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_LOGIN parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if(URL_REQUEST_SUCCESS != code){
            fail(@"账号或密码错误");
        }
        else{
            succ(@"登录成功",[responseObject objectForKey:@"data"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"登录服务器失败");
    }];
}

- (void)getRoomnumSucc:(businessSucc)succ fail:(businessFail)fail{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_GETROOMID parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        NSDictionary* dic = [responseObject objectForKey:@"data"];
        if (URL_REQUEST_SUCCESS == code) {
            if([[dic allKeys] containsObject:@"num"]){
                succ(@"获取房间号成功",[dic objectForKey:@"num"]);
            }
            else{
                fail(@"没有该字段");
            }
        }
        else{
            fail(@"获取房间号失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"获取房间号失败");
    }];
}

- (void)insertLive:(NSString*)tilte phone:(NSString*)phone room:(NSInteger)room chat:(NSString*)chat addr:(NSString*)addr image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"livetitle\":\"%@\",\"userphone\":\"%@\",\"roomnum\":%d,\"groupid\":\"%@\",\"addr\":\"%@\"}",
                      tilte,phone,room,chat,addr];
    NSDictionary *parameter = @{@"livedata":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_CREATELIVE parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:
         UIImageJPEGRepresentation(image, 0.5)
                                    name:@"image"
                                fileName:@"image.jpg"
                                mimeType:@"image/jpg"];
    }success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            succ(@"插入直播数据成功",nil);
        }
        else{
            fail(@"插入直播数据失败");
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        fail(@"插入直播数据失败");
    }];
}
- (void)enterRoom:(NSInteger)room phone:(NSString*)phone succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"userphone\":\"%@\",\"roomnum\":%ld}",
                      phone,room];
    NSDictionary *parameter = @{@"viewerdata":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_ENTERROOM parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* code = [responseObject objectForKey:@"code"];
        if (URL_REQUEST_SUCCESS == [code intValue]) {
            succ(@"插入进入直播数据成功",code);
        }
        else if(URL_ROOM_CLOSE == [code intValue]){
            succ(@"直播已经离开房间",code);
        }
        else{
            fail(@"插入进入直播数据失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"插入进入直播数据失败");
    }];
}

- (void)getUserInfoByPhone:(NSString*)phone succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"userphone\":\"%@\"}",phone];
    NSDictionary *parameter = @{@"data":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_GETUSER parameters:parameter success:^(AFHTTPRequestOperation *operation, id infoResponseObject) {
        if (URL_REQUEST_SUCCESS == [[infoResponseObject objectForKey:@"code"] integerValue]) {
            NSDictionary* infoDic = [infoResponseObject objectForKey:@"data"];
            succ(@"获取用户信息成功",infoDic);
        }
        else{
            fail(@"获取用户信息失败");
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"获取用户信息失败");
    }];
}
-(void)loveLive:(NSInteger)room addCount:(int)count succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"roomnum\":%ld,\"addnum\":%d}",room,count];
    NSDictionary *parameter = @{@"praisedata":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_PRAISE parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (URL_REQUEST_SUCCESS == code) {
            succ(@"",nil);
        }
        else{
            fail(@"");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"");
    }];
}

-(void)closeRoom:(NSInteger)room succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"roomnum\":%ld}",room];
    NSDictionary *parameter = @{@"closedata":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_CLOSELIVE parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            succ(@"",nil);
        }
        else{
            fail(@"关闭房间失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"关闭房间失败");
    }];
}
- (void)leaveRoom:(NSInteger)room phone:(NSString*)phone succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"userphone\":\"%@\",\"roomnum\":%ld}",phone,room];
    NSDictionary *parameter = @{@"viewerout":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_LEAVEROOM parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            succ(@"",nil);
        }
        else{
            fail(@"离开房间失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"离开房间失败");
    }];
}
- (void)logReport:(NSString*)phone log:(NSString*)log{
    if([phone isEqualToString:@""] || [log isEqualToString:@""]){
        return;
    }
    NSDictionary *parameter = @{@"userphone":phone,@"logmsg":log};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_LOGREPORT parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)getUserList:(NSString*)phones succ:(businessSucc)succ fail:(businessFail)fail{
    if([phones isEqualToString:@""]){
        return;
    }
    NSString* json = [NSString stringWithFormat:@"{\"userphones\":\"%@\"}",phones];
    NSDictionary *parameter = @{@"data":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_USERLIST parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            succ(@"获取在线用户成功",[responseObject objectForKey:@"data"]);
        }
        else{
            fail(@"获取在线用户失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            fail(@"获取在线用户失败");
    }];
}

- (void)getUserListByRoom:(NSInteger)room succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"roomnum\":\"%ld\"}",room];
    NSDictionary *parameter = @{@"data":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_USERLIST parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            succ(@"获取在线用户成功",[responseObject objectForKey:@"data"]);
        }
        else{
            fail(@"获取在线用户失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"获取在线用户失败");
    }];
}

- (void)getLive:(NSInteger)room succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"roomnum\":\"%ld\"}",room];
    NSDictionary *parameter = @{@"liveinfo":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_LIVEINFO parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            succ(@"",[responseObject objectForKey:@"data"]);
        }
        else{
            fail(@"获取直播信息失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"获取直播信息失败");
    }];
}

- (void)saveUserInfo:(NSString*)phone key:(NSString*)key value:(NSString*)value succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:
                      @"{\"userphone\":\"%@\",\"%@\":\"%@\"}",
                      phone,
                      key,
                      value];
    NSDictionary *parameter = @{@"data":json,@"version":@"34"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_SAVEUSER parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (URL_REQUEST_SUCCESS == code || URL_SAVEUSER_NOIMAGE == code) {
            succ(@"",[responseObject objectForKey:@"data"]);
        }
        else if(URL_SAVE_NAMEUSED == code){
            fail(@"用户名已经使用");
        }
        else{
            fail(@"保存失败");
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
        fail(@"保存失败");
    }];
}
- (void)saveUserInfo:(NSString*)phone image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:
                      @"{\"userphone\":\"%@\"}",
                      phone];
    NSDictionary *parameter = @{@"data":json,@"version":@"34"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_SAVEUSER parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(image != nil){
            [formData appendPartWithFileData:
             UIImageJPEGRepresentation(image, 0.5)
                                        name:@"image"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (URL_REQUEST_SUCCESS == code || URL_SAVEUSER_NOIMAGE == code) {
            succ(@"保存成功",[responseObject objectForKey:@"data"]);
        }
        else{
            fail(@"保存失败");
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
        fail(@"保存失败");
    }];
}
- (void)saveUserInfo:(NSString*)phone name:(NSString*)name gender:(NSString*)gender address:(NSString*)address signature:(NSString*)sig image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail{
    int genderInt = ([gender isEqualToString:@"男"]?0:1);
    NSString* json = [NSString stringWithFormat:
                      @"{\"userphone\":\"%@\",\"username\":\"%@\",\"sex\":%d,\"address\":\"%@\",\"signature\":\"%@\"}",
                      phone,
                      name,
                      genderInt,
                      address,
                      sig];
    NSDictionary *parameter = @{@"data":json,@"version":@"34"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_SAVEUSER parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 上传图片，以文件流的格式
        if(image != nil){
            [formData appendPartWithFileData:
             UIImageJPEGRepresentation(image, 0.5)
                                        name:@"image"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (URL_REQUEST_SUCCESS == code || URL_SAVEUSER_NOIMAGE == code) {
            succ(@"保存成功",[responseObject objectForKey:@"data"]);
        }
        else{
            fail(@"保存失败");
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
        fail(@"保存失败");
    }];
}

- (void)insertTrailer:(NSString*)tilte phone:(NSString*)phone time:(NSString*)time image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail{
    NSString* json = [NSString stringWithFormat:@"{\"livetitle\":\"%@\",\"userphone\":\"%@\",\"starttime\":\"%@\"}",
                      tilte,phone,time];
    NSDictionary *parameter = @{@"forcastdata":json};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_CREATETRAILER parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:
         UIImageJPEGRepresentation(image, 0.5)
                                    name:@"image"
                                fileName:@"image.jpg"
                                mimeType:@"image/jpg"];
    }success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            succ(@"发布成功",nil);
        }
        else{
            fail(@"发布失败");
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        fail(@"发布失败");
    }];
}

- (void)getTrailers:(NSString*)lastTime succ:(businessSucc)succ fail:(businessFail)fail{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* json = [NSString stringWithFormat:@"{\"timelimit\":\"%@\"}",
                      lastTime];
    NSDictionary *parameter = nil;
    if(lastTime != nil && ![lastTime isEqualToString:@""]){
        parameter = @{@"forcastlist":json};
    }
    [manager POST:URL_TRAILERLIST parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            NSArray* data = [responseObject objectForKey:@"data"];
            succ(@"获取预告成功",data);
        }
        else{
            fail(@"获取预告失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"获取预告失败");
    }];
}

- (void)getLives:(NSString*)lastTime succ:(businessSucc)succ fail:(businessFail)fail{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* json = [NSString stringWithFormat:@"{\"timelimit\":\"%@\"}",
                      lastTime];
    NSDictionary *parameter = nil;
    if(lastTime != nil && ![lastTime isEqualToString:@""]){
        parameter = @{@"livelist":json};
    }
    [manager POST:URL_LIVELIST parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (URL_REQUEST_SUCCESS == [[responseObject objectForKey:@"code"] integerValue]) {
            NSArray* data = [responseObject objectForKey:@"data"];
            succ(@"获取直播成功",data);
        }
        else{
            fail(@"获取直播失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(@"获取直播失败");
    }];
}

- (void)heartBeatCheckCrash:(NSString*)phone{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* json = [NSString stringWithFormat:@"{\"livephone\":\"%@\"}",phone];
    NSDictionary *parameter = nil;
    if(phone != nil && ![phone isEqualToString:@""]){
        parameter = @{@"heartTime":json};
    }
    [manager POST:URL_HEARTTIME parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}
@end
