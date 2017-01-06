
@interface YSFAppSetting : NSObject

@property (nonatomic)      BOOL    recevierOrSpeaker;

- (BOOL)isValid;

+ (instancetype)infoByDict:(NSDictionary *)dict;
+ (instancetype)defaultSetting;

- (NSDictionary *)toDict;


@end
