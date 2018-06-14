#import "YSFOrderStatusContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFOrderStatus.h"
#import "UIControl+BlocksKit.h"


@interface YSFOrderStatusContentView()

@property (nonatomic, strong) UIView *content;

@end

@implementation YSFOrderStatusContentView

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
    offsetY+= 13;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFOrderStatus *orderStatus = (YSFOrderStatus *)object.attachment;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:16.f];
    label.text = orderStatus.label;
    label.frame = CGRectMake(18, offsetY,
                             self.model.contentSize.width - 28, 0);
    
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
    
    offsetY += 13;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont systemFontOfSize:16.f];
    title.text = orderStatus.title;
    title.frame = CGRectMake(18, offsetY,
                             self.model.contentSize.width - 28, 0);
    
    [title sizeToFit];
    [_content addSubview:title];
    
    offsetY += title.ysf_frameHeight;
    offsetY += 13;
    
    [orderStatus.actionArray enumerateObjectsUsingBlock:^(YSFAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            offsetY += 34;
            offsetY += 15;
        }
        
        UIButton *button = [UIButton new];
        button.layer.borderWidth = 0.5;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.borderColor = YSFRGB(0x5092E1).CGColor;
        button.layer.cornerRadius = 2;
        [button setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
        [button setTitle:action.validOperation forState:UIControlStateNormal];
        button.ysf_frameLeft = 25;
        button.ysf_frameWidth = self.ysf_frameWidth - 45;
        button.ysf_frameTop = offsetY;
        button.ysf_frameHeight = 34;
        [self.content addSubview:button];
        __weak typeof(self) weakSelf = self;
        [button ysf_addEventHandler:^(id  _Nonnull sender) {
            [weakSelf onClickAction:action];
        } forControlEvents:UIControlEventTouchUpInside];
    }];
    

}

- (void)onClickAction:(YSFAction *)action
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapBot;
    event.message = self.model.message;
    event.data = action;
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
