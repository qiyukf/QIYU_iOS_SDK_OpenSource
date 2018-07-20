
@interface YSFBotEntry : NSObject

@property (nonatomic,copy)   NSArray *entryArray;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end
