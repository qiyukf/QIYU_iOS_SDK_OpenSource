#import "YSFActionListContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFActionList.h"

@interface YSFActionView3 : UIButton

@property (nonatomic, strong) YSFAction *action;

@end

@implementation YSFActionView3
@end

@interface YSFActionListContentView()

@property (nonatomic, strong) UIView *content;

@end

@implementation YSFActionListContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        _content = [UIView new];
        [self addSubview:_content];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    
    [_content ysf_removeAllSubviews];
    
    __block CGFloat offsetY = self.model.contentViewInsets.top;
    offsetY += 13;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFActionList *actionList = (YSFActionList *)object.attachment;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:16.f];
    label.numberOfLines = 0;
    label.text = actionList.label;
    label.frame = CGRectMake(18, offsetY, 0, 0);
    label.ysf_frameWidth = self.ysf_frameWidth - 28;
    [label sizeToFit];
    [_content addSubview:label];
    
    offsetY += label.ysf_frameHeight;
    offsetY += 13;
    
    UIView *splitLine = [UIView new];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.ysf_frameHeight = 0.5;
    splitLine.ysf_frameLeft = 5;
    splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
    splitLine.ysf_frameTop = offsetY;
    [_content addSubview:splitLine];
    
    [actionList.actionArray enumerateObjectsUsingBlock:^(YSFAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        offsetY += 15;
        if (idx > 0) {
            offsetY += 34;
        }
        
        YSFActionView3 *button = [YSFActionView3 new];
        button.action = action;
        button.layer.borderWidth = 0.5;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.borderColor = YSFRGB(0x5092E1).CGColor;
        button.layer.cornerRadius = 2;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:action.validOperation forState:UIControlStateNormal];
        button.ysf_frameLeft = 25;
        button.ysf_frameWidth = self.ysf_frameWidth - 45;
        button.ysf_frameTop = offsetY;
        button.ysf_frameHeight = 34;
        [_content addSubview:button];
        [button addTarget:self action:@selector(onClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }];


}

- (void)onClickAction:(YSFActionView3 *)actionView
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapBot;
    event.message = self.model.message;
    event.data = actionView.action;
    [self.delegate onCatchEvent:event];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _content.ysf_frameLeft = -5;
    }
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}


@end
