#import "YSFOrderLogisticContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFOrderLogistic.h"

@interface YSFActionView4 : UIButton

@property (nonatomic, strong) YSFAction *action;

@end

@implementation YSFActionView4
@end


@interface YSFOrderLogisticContentView()

@property (nonatomic, strong) UIView *content;

@end

@implementation YSFOrderLogisticContentView

- (instancetype)initSessionMessageContentView {
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
    YSFOrderLogistic *orderLogistic = (YSFOrderLogistic *)object.attachment;
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.f];
    [label setText:orderLogistic.label];
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

    UILabel *title = [UILabel new];
    title.numberOfLines = 0;
    title.font = [UIFont systemFontOfSize:15.f];
    [title setText:orderLogistic.title];
    title.frame = CGRectMake(18, offsetY,
                             self.model.contentSize.width - 28, 0);
    [title sizeToFit];
    [_content addSubview:title];
    offsetY += title.ysf_frameHeight;
    
    CGFloat lineTop = offsetY + 28;

    [orderLogistic.logistic enumerateObjectsUsingBlock:^(YSFOrderLogisticNode *logisticNode, NSUInteger idx, BOOL * _Nonnull stop) {
    
        offsetY += 13;

        if (idx == 0) {
            UIView *point = [UIView new];
            point.frame = CGRectMake(21, offsetY + 7, 8, 8);
            point.backgroundColor = YSFRGB(0x5092e1);
            point.layer.cornerRadius = 4;
            [_content addSubview:point];
        }
        else {
            UIView *point = [UIView new];
            point.frame = CGRectMake(22, offsetY + 7, 6, 6);
            point.backgroundColor = YSFRGB(0xdbdbdb);
            point.layer.cornerRadius = 3;
            [_content addSubview:point];
        }
        
        UILabel *logistic = [UILabel new];
        logistic.numberOfLines = 0;
        logistic.font = [UIFont systemFontOfSize:15.f];
        [logistic setText:logisticNode.logistic];
        logistic.frame = CGRectMake(38, offsetY,
                                 self.model.contentSize.width - 48, 0);
        [logistic sizeToFit];
        [_content addSubview:logistic];
        if (idx == 0) {
            logistic.textColor = YSFRGB(0x5092E1);
        }
        
        offsetY += logistic.ysf_frameHeight;
        offsetY += 4;

        UILabel *time = [UILabel new];
        time.textColor = YSFRGB(0x666666);
        logistic.numberOfLines = 0;
        time.font = [UIFont systemFontOfSize:15.f];
        [time setText:logisticNode.timestamp];
        time.frame = CGRectMake(38, offsetY,
                                    self.model.contentSize.width - 48, 0);
        
        [time sizeToFit];
        [_content addSubview:time];
        if (idx == 0) {
            time.textColor = YSFRGB(0x5092E1);
        }
        
        offsetY += time.ysf_frameHeight;
    }];
    
    offsetY += 13;
    
    UIView *line = [UIView new];
    line.backgroundColor = YSFRGB(0xdbdbdb);
    line.ysf_frameLeft = 25;
    line.ysf_frameWidth = 0.5;
    line.ysf_frameTop = lineTop;
    line.ysf_frameHeight = offsetY - lineTop;
    [_content addSubview:line];
    
    UIView *splitLine2 = [UIView new];
    splitLine2.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine2.ysf_frameHeight = 0.5;
    splitLine2.ysf_frameLeft = 5;
    splitLine2.ysf_frameWidth = self.ysf_frameWidth - 5;
    splitLine2.ysf_frameTop = offsetY;
    [_content addSubview:splitLine2];
    
    YSFActionView4 *more = [YSFActionView4 new];
    [more setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
    [more setTitle:orderLogistic.action.validOperation forState:UIControlStateNormal];
    more.titleLabel.font = [UIFont systemFontOfSize:15.f];
    more.frame = CGRectMake(0, offsetY,
                            self.model.contentSize.width, 44);
    more.action = orderLogistic.action;
    [_content addSubview:more];
    [more addTarget:self action:@selector(onClickAction:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _content.ysf_frameLeft = -5;
    }
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}


- (void)onClickAction:(YSFActionView4 *)actionView
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapBot;
    event.message = self.model.message;
    event.data = actionView.action;

    [self.delegate onCatchEvent:event];
}


@end
