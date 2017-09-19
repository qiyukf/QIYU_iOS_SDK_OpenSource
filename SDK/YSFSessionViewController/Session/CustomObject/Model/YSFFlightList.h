#import "YSFAction.h"
#import "YSFFlightDetail.h"

typedef NS_ENUM(NSInteger, YSFBotFlagType) {
    QYMessageTypeBold = 1 << 0,
    QYMessageTypeItalic = 1 << 1,
    QYMessageTypeUnderline = 1 << 2,
    QYMessageTypeSingleLine = 1 << 3,
};







@interface YSFFlightList : NSObject<YSF_NIMCustomAttachment>

//命令
@property (nonatomic, assign) NSInteger command;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) YSFAction *action;
@property (nonatomic, strong) NSMutableArray<YSFFlightItem *> *fieldItems;
@property (nonatomic, strong) YSFFlightDetail *detail;

+ (YSFFlightList *)objectByDict:(NSDictionary *)dict;
+ (YSFFlightList *)objectByFlightThumbnail:(YSFFlightThumbnail *)flightThumbnail;
+ (YSFFlightList *)objectByFlightDetail:(YSFFlightDetail *)flightDetail;

@end
