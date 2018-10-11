#import "YSFAction.h"


@interface YSFFlightInfoField: NSObject


@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *align;
@property (nonatomic, assign)  NSInteger flag;

+ (YSFFlightInfoField *)objectByDict:(NSDictionary *)dict;

@end

@interface YSFFlightItem: NSObject

@property (nonatomic, strong) YSFAction *action;
@property (nonatomic, strong) NSMutableArray *fields;

@end

@interface YSFFlightThumbnail: NSObject

@property (nonatomic, strong) YSFAction *action;
@property (nonatomic, strong) NSMutableArray *fields;

+ (YSFFlightThumbnail *)objectByDict:(NSDictionary *)dict;

@end



@interface YSFFlightDetail: NSObject

@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) NSMutableArray *flightDetailItems;

+ (YSFFlightDetail *)objectByDict:(NSDictionary *)dict;

@end


@interface YSFFlightThumbnailAndDetail : NSObject <YSF_NIMCustomAttachment>

@property (nonatomic, strong) YSFFlightThumbnail *thumbnail;
@property (nonatomic, strong) YSFFlightDetail *detail;

+ (YSFFlightThumbnailAndDetail *)objectByDict:(NSDictionary *)dict;

@end
