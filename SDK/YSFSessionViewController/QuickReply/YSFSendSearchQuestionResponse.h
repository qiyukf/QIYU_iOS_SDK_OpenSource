

#import "YSFIMCustomSystemMessageApi.h"


@interface YSFQuickReplyKeyWordAndContent : NSObject

@property (nonatomic, copy) NSString *keyword;          //关键字
@property (nonatomic, copy) NSString *content;          //回复内容
@property (nonatomic, copy) NSString *showContent;      //显示内容
@property (nonatomic, assign) NSInteger isContentRich;  //内容是否为富文本，0-纯文本、1-富文本

@end


@interface YSFSendSearchQuestionResponse : NSObject

@property (nonatomic, assign) long long sessionId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSArray *questionContents;

+ (YSFSendSearchQuestionResponse *)dataByJson:(NSDictionary *)dict;

@end



