#import "YSFSessionInviteEvaluationContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"
#import "YSFMachineResponse.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"




@interface YSFSessionInviteEvaluationContentView()

@property (nonatomic, strong) YSFAttributedLabel *textLabel;
@property (nonatomic, strong) UIButton *evaluationButton;
@property (nonatomic, strong) UIView *panel;

@end

@implementation YSFSessionInviteEvaluationContentView

-(instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        self.bubbleType = YSFKitBubbleTypeNone;
        
        _panel = [UIView new];
        [self addSubview:_panel];
        _panel.ysf_frameWidth = 280;
        _panel.ysf_frameHeight = 110;
        _panel.backgroundColor = [UIColor whiteColor];
        _panel.layer.cornerRadius = 2;
        _panel.layer.borderWidth = 1;
        _panel.layer.borderColor = YSFColorFromRGB(0xdadada).CGColor;
        _textLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.font = [UIFont systemFontOfSize:14.f];
        _textLabel.highlightColor = YSFRGBA2(0x1a000000);
        [_textLabel setText:@"感谢您的咨询，请对我们的服务作出评价"];
        _textLabel.backgroundColor = [UIColor clearColor];
        [_panel addSubview:_textLabel];
        
        _evaluationButton = [UIButton new];
        _evaluationButton.backgroundColor = YSFColorFromRGB(0x5e94e2);
        _evaluationButton.layer.cornerRadius = 2;
        _evaluationButton.ysf_frameTop = 40;
        _evaluationButton.ysf_frameWidth = 60;
        _evaluationButton.ysf_frameHeight = 30;
        [_evaluationButton setTitle:@"评价" forState:UIControlStateNormal];
        _evaluationButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_panel addSubview:_evaluationButton];
        
        [_evaluationButton addTarget:self action:@selector(onEvaluate:) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

- (void)onEvaluate:(id)sender
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapEvaluation;
    event.message = self.model.message;
    event.data = nil;
    [self.delegate onCatchEvent:event];
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    


}

- (void)layoutSubviews{
    [super layoutSubviews];
    _panel.ysf_frameCenterX = self.ysf_frameWidth / 2;
    _panel.ysf_frameTop = 5;
    
    [_textLabel sizeToFit];
    _textLabel.ysf_frameTop = 20;
    _textLabel.ysf_frameCenterX = _panel.ysf_frameWidth / 2;
    _evaluationButton.ysf_frameTop = 62;
    _evaluationButton.ysf_frameCenterX = _panel.ysf_frameWidth / 2;
}

@end
