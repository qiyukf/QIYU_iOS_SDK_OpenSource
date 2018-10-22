#import "YSFCustomAttachment.h"


typedef enum : NSUInteger {
    YSFEvaluationSelectionTypeInvisible = 0,
    YSFEvaluationSelectionTypeVisible,
    YSFEvaluationSelectionTypeYes,
    YSFEvaluationSelectionTypeNo,
} YSFEvaluationSelectionType;


@interface YSFMachineResponse : NSObject<YSFCustomAttachment>

@property (nonatomic, copy) NSString *rawStringForCopy;

@property (nonatomic, assign) NSInteger command;
@property (nonatomic, copy) NSString *originalQuestion;
@property (nonatomic, assign) NSInteger answerType;
@property (nonatomic, copy) NSString *answerLabel;
@property (nonatomic, copy) NSArray *answerArray;
@property (nonatomic, assign) BOOL operatorHint;
@property (nonatomic, copy) NSString *operatorHintDesc;

@property (nonatomic, assign) BOOL isOneQuestionRelevant;
@property (nonatomic, assign) YSFEvaluationSelectionType evaluation;
@property (nonatomic, copy) NSString *evaluationContent;
@property (nonatomic, assign) NSInteger evaluationReason;
@property (nonatomic, copy) NSString *evaluationGuide;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *imageUrlStringArray;
@property (nonatomic, assign) BOOL shouldShow;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
