//
//  TIMFriendshipManager.h
//  ImSDK
//
//  Created by bodeng on 21/5/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMFriendshipManager_h
#define ImSDK_TIMFriendshipManager_h


#import "TIMComm.h"

typedef NS_ENUM(NSInteger, TIMFriendAllowType) {
    /**
     *  同意任何用户加好友
     */
    TIM_FRIEND_ALLOW_ANY                    = 0,
    
    /**
     *  需要验证
     */
    TIM_FRIEND_NEED_CONFIRM                 = 1,
    
    /**
     *  拒绝任何人加好友
     */
    TIM_FRIEND_DENY_ANY                     = 2,
};

typedef NS_ENUM(NSInteger, TIMDelFriendType) {
    /**
     *  删除单向好友
     */
    TIM_FRIEND_DEL_SINGLE               = 1,
    
    /**
     *  删除双向好友
     */
    TIM_FRIEND_DEL_BOTH                 = 2,
};

/**
 *  好友列表
 *
 *  @param NSArray 好友列表
 */
typedef void (^TIMFriendSucc)(NSArray *);


/**
 *  好友资料
 */
@interface TIMUserProfile : NSObject

/**
 *  用户identifier
 */
@property(nonatomic,retain) NSString* identifier;

/**
 *  用户昵称
 */
@property(nonatomic,retain) NSString* nickname;

/**
 *  用户备注（最大96字节，获取自己资料时，该字段为空）
 */
@property(nonatomic,retain) NSString* remark;

/**
 *  好友验证方式
 */
@property(nonatomic,assign) TIMFriendAllowType allowType;

/**
 * 用户头像
 */
@property(nonatomic,retain) NSString* faceURL;

@end


typedef NS_ENUM(NSInteger, TIMFriendResponseType) {
    /**
     *  同意加好友（建立单向好友）
     */
    TIM_FRIEND_RESPONSE_AGREE                       = 0,
    
    /**
     *  同意加好友并加对方为好友（建立双向好友）
     */
    TIM_FRIEND_RESPONSE_AGREE_AND_ADD               = 1,
    
    /**
     *  拒绝对方好友请求
     */
    TIM_FRIEND_RESPONSE_REJECT                      = 2,
};

@interface TIMFriendResponse : NSObject

/**
 *  响应类型
 */
@property(nonatomic,assign) TIMFriendResponseType responseType;

/**
 *  用户identifier
 */
@property(nonatomic,retain) NSString* identifier;

/**
 *  （可选）如果要加对方为好友，表示备注，其他type无效，备注最大96字节
 */
@property(nonatomic,retain) NSString* remark;

@end

/**
 *  获取资料回调
 *
 *  @param TIMUserProfile 资料
 */
typedef void (^TIMGetProfileSucc)(TIMUserProfile *);


/**
 * 基本资料标志位
 */
typedef NS_ENUM(NSInteger, TIMProfileFlag) {
    /**
     * 昵称
     */
    TIM_PROFILE_FLAG_NICK                = 0x01,
    /**
     * 好友验证方式
     */
    TIM_PROFILE_FLAG_ALLOW_TYPE          = (0x01 << 1),
    /**
     * 头像
     */
    TIM_PROFILE_FLAG_FACE_URL            = (0x01 << 2),
    /**
     * 好友备注
     */
    TIM_PROFILE_FLAG_REMARK              = (0x01 << 3),
};

/**
 * 好友元信息
 */
@interface TIMFriendMetaInfo : NSObject

/**
 * 时间戳，需要保存，下次拉取时传入，增量更新使用
 */
@property(nonatomic,assign) uint64_t timestamp;
/**
 * 序列号，需要保存，下次拉取时传入，增量更新使用
 */
@property(nonatomic,assign) uint64_t infoSeq;
/**
 * 分页信息，无需保存，返回为0时结束，非0时传入再次拉取，第一次拉取时传0
 */
@property(nonatomic,assign) uint64_t nextSeq;
/**
 * 覆盖：为TRUE时需要重设timestamp, infoSeq, nextSeq为0，清除客户端存储，重新拉取资料
 */
@property(nonatomic,assign) BOOL recover;

@end

/**
 * 获取好友列表回调
 *
 *  @param meta 好友元信息
 *  @param friends 好友列表 TIMUserProfile* 数组，只包含需要的字段
 */
typedef void (^TIMGetFriendListV2Succ)(TIMFriendMetaInfo * meta, NSArray * friends);


typedef NS_ENUM(NSInteger, TIMPendencyGetType) {
    /**
     *  别人发给我的
     */
    TIM_PENDENCY_GET_COME_IN                    = 1,
    
    /**
     *  我发给别人的
     */
    TIM_PENDENCY_GET_SEND_OUT                   = 2,
    
    /**
     * 别人发给我的 和 我发给别人的
     */
    TIM_PENDENCY_GET_BOTH                       = 3,
};

/**
 * 未决请求元信息
 */
@interface TIMFriendPendencyMeta : NSObject

/**
 * 序列号，未决列表序列号
 *    建议客户端保存seq和未决列表，请求时填入server返回的seq
 *    如果seq是server最新的，则不返回数据
 */
@property(nonatomic,assign) uint64_t seq;

/**
 * 翻页时间戳，只用来翻页，server返回0时表示没有更多数据，第一次请求填0
 *    特别注意的是，如果server返回的seq跟填入的seq不同，翻页过程中，需要使用客户端原始seq请求，直到数据请求完毕，才能更新本地seq
 */
@property(nonatomic,assign) uint64_t timestamp;

/**
 * 每页的数量，请求时有效（建议值，server可根据需要返回或多或少，不能作为完成与否的标志）
 */
@property(nonatomic,assign) uint64_t numPerPage;

/**
 * 未决请求未读数量（仅在server返回时有效）
 */
@property(nonatomic,assign) uint64_t unReadCnt;

@end

/**
 * 未决请求
 */
@interface TIMFriendPendencyItem : NSObject

/**
 * 用户标识
 */
@property(nonatomic,retain) NSString* identifier;
/**
 * 增加时间
 */
@property(nonatomic,assign) uint64_t addTime;
/**
 * 来源
 */
@property(nonatomic,retain) NSString* addSource;
/**
 * 加好友附言
 */
@property(nonatomic,retain) NSString* addWording;

/**
 * 加好友昵称
 */
@property(nonatomic,retain) NSString* nickname;

/**
 * 未决请求类型
 */
@property(nonatomic,assign) TIMPendencyGetType type;

@end

/**
 * 好友推荐
 */
@interface TIMFriendRecommendItem : NSObject

/**
 * 推荐的好友identifier
 */
@property(nonatomic,retain) NSString* identifier;

/**
 * 添加时间
 */
@property(nonatomic,assign) uint64_t addTime;

/**
 * 推荐理由（server端写入）
 */
@property(nonatomic,retain) NSDictionary* tags;
@end

/**
 * 翻页选项
 */
typedef NS_ENUM(NSInteger, TIMPageDirectionType) {
    /**
     *  向上翻页
     */
    TIM_PAGE_DIRECTION_UP_TYPE            = 1,
    
    /**
     *  向下翻页
     */
    TIM_PAGE_DIRECTION_DOWN_TYPE           = 2,
};

/**
 * 推荐好友类型
 */
typedef NS_ENUM(NSInteger, TIMFutureFriendType) {
    /**
     *  未决请求
     */
    TIM_FUTURE_FRIEND_PENDENCY_TYPE            = 1,
    
    /**
     *  推荐好友
     */
    TIM_FUTURE_FRIEND_RECOMMEND_TYPE           = 2,
};

/**
 * 推荐好友
 */
@interface TIMFriendFutureItem : NSObject

/**
 * 推荐好友类型
 */
@property(nonatomic,assign) TIMFutureFriendType type;

/**
 * 推荐好友item
 */
@property(nonatomic,retain) TIMFriendPendencyItem* pendency;

/**
 * 未决好友item
 */
@property(nonatomic,retain) TIMFriendRecommendItem* recommend;

@end

/**
 * 获取未决请求列表成功
 *
 *  @param meta 未决请求元信息
 *  @param pendencies  未决请求列表（TIMFriendPendencyItem*）数组
 */
typedef void (^TIMGetFriendPendencyListSucc)(TIMFriendPendencyMeta * meta, NSArray * pendencies);


/**
 * 获取推荐好友和未决列表成功
 *
 *  @param timestamp 下次处理的时间戳
 *  @param items     列表（TIMFriendFutureItem*）数组
 */
typedef void (^TIMGetFriendFutureListSucc)(uint64_t timestamp, NSArray * items);


/**
 * 好友管理
 */
@interface TIMFriendshipManager : NSObject

/**
 *  获取好友管理器实例
 *
 *  @return 管理器实例
 */
+(TIMFriendshipManager*)sharedInstance;

/**
 *  设置好友备注
 *
 *  @param identifier 用户标识
 *  @param nick 备注
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) SetFriendRemark:(NSString*)identifier remark:(NSString*)remark succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  设置自己的昵称
 *
 *  @param nick 昵称（最大64字节）
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) SetNickname:(NSString*)nick succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  设置好友验证方式
 *
 *  @param allowType 好友验证方式，详见 TIMFriendAllowType
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) SetAllowType:(TIMFriendAllowType)allowType succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  设置自己的头像
 *
 *  @param faceURL 头像
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) SetFaceURL:(NSString*)faceURL succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取自己的资料
 *
 *  @param succ  成功回调，返回 TIMUserProfile
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) GetSelfProfile:(TIMGetProfileSucc)succ fail:(TIMFail)fail;

/**
 *  获取好友资料
 *
 *  @param users 要获取的好友列表 NSString* 列表
 *  @param succ  成功回调，返回 TIMUserProfile* 列表
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) GetFriendsProfile:(NSArray*)users succ:(TIMFriendSucc)succ fail:(TIMFail)fail;

/**
 *  添加好友
 *
 *  @param users 要添加的用户列表 TIMAddFriendRequest* 列表
 *  @param succ  成功回调，返回 TIMFriendResult* 列表
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) AddFriend:(NSArray*) users succ:(TIMFriendSucc)succ fail:(TIMFail)fail;

/**
 *  删除好友
 *
 *  @param delType 删除类型（单向好友、双向好友）
 *  @param users 要删除的用户列表 NSString* 列表
 *  @param succ  成功回调，返回 TIMFriendResult* 列表
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) DelFriend:(TIMDelFriendType)delType users:(NSArray*) users succ:(TIMFriendSucc)succ fail:(TIMFail)fail;

/**
 *  获取好友列表
 *
 *  @param succ 成功回调，返回好友列表，TIMUserProfile* 列表，只包含identifier，nickname，remark 三个字段
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) GetFriendList:(TIMFriendSucc)succ fail:(TIMFail)fail;


/**
 *  响应对方好友邀请
 *
 *  @param users     响应的用户列表，TIMFriendResponse列表
 *  @param succ      成功回调，返回 TIMFriendResult* 列表
 *  @param fail      失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) DoResponse:(NSArray*)users succ:(TIMFriendSucc)succ fail:(TIMFail)fail;


/**
 *  添加用户到黑名单
 *
 *  @param users 用户列表
 *  @param succ  成功回调，返回 TIMFriendResult* 列表
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) AddBlackList:(NSArray*) users succ:(TIMFriendSucc)succ fail:(TIMFail)fail;

/**
 *  把用户从黑名单中删除
 *
 *  @param users 用户列表
 *  @param succ  成功回调，返回 TIMFriendResult* 列表
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) DelBlackList:(NSArray*) users succ:(TIMFriendSucc)succ fail:(TIMFail)fail;

/**
 *  获取黑名单列表
 *
 *  @param succ 成功回调，返回NSString*列表
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) GetBlackList:(TIMFriendSucc)succ fail:(TIMFail)fail;

/**
 *  获取好友列表（可增量、分页、自定义拉取字段）
 *
 *  @param flags 设置需要拉取的字段
 *  @param custom 自定义字段（目前还不支持）
 *  @param meta 好友元信息（详见TIMFriendMetaInfo说明）
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) GetFriendListV2:(TIMProfileFlag)flags custom:(NSArray*)custom meta:(TIMFriendMetaInfo*)meta succ:(TIMGetFriendListV2Succ)succ fail:(TIMFail)fail;

/**
 *  通过网络获取未决请求列表
 *
 *  @param meta  请求信息，详细参考TIMFriendPendencyMeta
 *  @param type  拉取类型（参考TIMPendencyGetType）
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) GetPendencyFromServer:(TIMFriendPendencyMeta*)meta type:(TIMPendencyGetType)type succ:(TIMGetFriendPendencyListSucc)succ fail:(TIMFail)fail;

/**
 *  未决请求已读上报
 *
 *  @param timestamp 已读时间戳，此时间戳以前的消息都将置为已读
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) PendencyReport:(uint64_t)timestamp succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  未决请求和好友推荐拉取
 *
 *  @param timestamp  时间戳
 *  @param direction  翻页方向，详情参考 TIMPageDirectionType
 *  @param pendencyType  获取的未决类型，详情参考 TIMPendencyGetType
 *  @param num   获取数量
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
-(int) GetFutureFriends:(uint64_t)timestamp direction:(TIMPageDirectionType)direction pendencyType:(TIMPendencyGetType)pendencyType num:(uint64_t)num succ:(TIMGetFriendFutureListSucc)succ fail:(TIMFail)fail;

@end



/**
 *  加好友请求
 */
@interface TIMAddFriendRequest : NSObject

/**
 *  用户identifier
 */
@property(nonatomic,retain) NSString* identifier;

/**
 *  用户备注（备注最大96字节）
 */
@property(nonatomic,retain) NSString* remark;

/**
 *  请求说明（最大120字节）
 */
@property(nonatomic,retain) NSString* addWording;

/**
 *  添加来源
 */
@property(nonatomic,retain) NSString* addSource;

@end


/**
 * 好友操作状态
 */
typedef NS_ENUM(NSInteger, TIMFriendStatus) {
    /**
     *  操作成功
     */
    TIM_FRIEND_STATUS_SUCC                              = 0,
    
    
    /**
     *  加好友时有效：被加好友在自己的黑名单中
     */
    TIM_ADD_FRIEND_STATUS_IN_SELF_BLACK_LIST                = 30515,
    
    /**
     *  加好友时有效：被加好友设置为禁止加好友
     */
    TIM_ADD_FRIEND_STATUS_FRIEND_SIDE_FORBID_ADD            = 30516,

    /**
     *  加好友时有效：好友数量已满
     */
    TIM_ADD_FRIEND_STATUS_SELF_FRIEND_FULL                  = 30519,
    
    /**
     *  加好友时有效：已经是好友
     */
    TIM_ADD_FRIEND_STATUS_ALREADY_FRIEND                    = 30520,
    
    /**
     *  加好友时有效：已被被添加好友设置为黑名单
     */
    TIM_ADD_FRIEND_STATUS_IN_OTHER_SIDE_BLACK_LIST          = 30525,
    
    /**
     *  加好友时有效：等待好友审核同意
     */
    TIM_ADD_FRIEND_STATUS_PENDING                           = 30539,
    
    /**
     *  删除好友时有效：删除好友时对方不是好友
     */
    TIM_DEL_FRIEND_STATUS_NO_FRIEND                         = 31704,
    
    
    /**
     *  响应好友申请时有效：对方没有申请过好友
     */
    TIM_RESPONSE_FRIEND_STATUS_NO_REQ                       = 30614,
    
    /**
     *  响应好友申请时有效：自己的好友满
     */
    TIM_RESPONSE_FRIEND_STATUS_SELF_FRIEND_FULL             = 30615,
    
    /**
     *  响应好友申请时有效：好友已经存在
     */
    TIM_RESPONSE_FRIEND_STATUS_FRIEND_EXIST                 = 30617,
    
    /**
     *  响应好友申请时有效：对方好友满
     */
    TIM_RESPONSE_FRIEND_STATUS_OTHER_SIDE_FRIEND_FULL       = 30630,
    
    
    /**
     *  添加黑名单有效：已经在黑名单了
     */
    TIM_ADD_BLACKLIST_FRIEND_STATUS_IN_BLACK_LIST           = 31307,
    
    /**
     *  删除黑名单有效：用户不在黑名单里
     */
    TIM_DEL_BLACKLIST_FRIEND_STATUS_NOT_IN_BLACK_LIST       = 31503,
};

@interface TIMFriendResult : NSObject


@property(nonatomic,retain) NSString* identifier;
/**
 *  返回状态
 */
@property(nonatomic,assign) TIMFriendStatus status;

@end


#endif
