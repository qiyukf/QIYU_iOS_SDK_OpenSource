#import "YSFCustomAttachment.h"

@class YSFShopInfo;

@interface YSFKFBypassNotification : NSObject<YSFCustomAttachment>

@property (nonatomic,copy)      NSString    *rawStringForCopy;

@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,copy)      NSString    *message;
@property (nonatomic,copy)      NSString    *iconUrl;
@property (nonatomic,copy)      NSArray     *entries;
@property (nonatomic,assign)    BOOL        disable;
@property (nonatomic,strong)    YSFShopInfo *shopInfo;           //平台电商的商铺信息

+ (instancetype)dataByJson:(NSDictionary *)dict;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
