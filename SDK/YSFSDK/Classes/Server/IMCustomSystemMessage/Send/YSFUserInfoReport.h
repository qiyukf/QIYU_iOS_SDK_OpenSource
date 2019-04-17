#import "YSFIMCustomSystemMessageApi.h"


@interface YSFUserInfoReport : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,copy)          NSString *appKey;
@property (nonatomic,copy)          NSString *deviceId;
@property (nonatomic,copy)          NSString *source;
@property (nonatomic,copy)          NSString *imei;
@property (nonatomic,copy)          NSString *mac;
@property (nonatomic,copy)          NSString *idfa;
@property (nonatomic,copy)          NSString *androidId;
@property (nonatomic,copy)          NSString *brand;
@property (nonatomic,copy)          NSString *model;
@property (nonatomic,copy)          NSString *os;
@property (nonatomic,assign)        long long timestamp;

@end
