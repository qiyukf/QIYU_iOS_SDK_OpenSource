
@interface YSFAppSetting : NSObject

@property (nonatomic, assign) BOOL recevierOrSpeaker;

+ (instancetype)infoByDict:(NSDictionary *)dict;
- (NSDictionary *)toDict;

+ (instancetype)defaultSetting;
- (BOOL)isValid;

@end
