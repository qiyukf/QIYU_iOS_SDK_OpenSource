#import "YSFSessionInviteEvaluationContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"
#import "YSFMachineResponse.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"
#import "YSFInviteEvaluationObject.h"


@interface YSFSessionInviteEvaluationContentView()

@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) YSFAttributedLabel *textLabel;
@property (nonatomic, strong) UIButton *evaluationButton;
@property (nonatomic, strong) UIButton *inviteButton;

@end


@implementation YSFSessionInviteEvaluationContentView
- (instancetype)initSessionMessageContentView {
    if (self = [super initSessionMessageContentView]) {
        self.bubbleType = YSFKitBubbleTypeNone;
        
        _panel = [[UIView alloc] init];
        _panel.backgroundColor = [UIColor whiteColor];
        _panel.ysf_frameWidth = 280;
        _panel.layer.cornerRadius = 2;
        _panel.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        _panel.layer.borderColor = YSFColorFromRGB(0xdadada).CGColor;
        [self addSubview:_panel];
        
        _textLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.font = [UIFont systemFontOfSize:14.f];
        _textLabel.highlightColor = YSFRGBA2(0x1a000000);
        [_panel addSubview:_textLabel];
        
        _evaluationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _evaluationButton.backgroundColor = YSFColorFromRGB(0x5e94e2);
        _evaluationButton.layer.cornerRadius = 2;
        _evaluationButton.ysf_frameWidth = 60;
        _evaluationButton.ysf_frameHeight = 30;
        _evaluationButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_evaluationButton setTitle:@"评价" forState:UIControlStateNormal];
        [_panel addSubview:_evaluationButton];
        [_evaluationButton addTarget:self action:@selector(onEvaluate:) forControlEvents:UIControlEventTouchUpInside];
        
        _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _inviteButton.backgroundColor = [UIColor clearColor];
        _inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _inviteButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_inviteButton setTitle:@"邀请用户修改" forState:UIControlStateNormal];
        [_inviteButton setTitleColor:YSFRGB(0x008fff) forState:UIControlStateNormal];
        [_panel addSubview:_inviteButton];
        [_inviteButton addTarget:self action:@selector(onInvite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data {
    [super refresh:data];
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
    if ([object.attachment isKindOfClass:[YSFInviteEvaluationObject class]]) {
        YSFInviteEvaluationObject *attachment = (YSFInviteEvaluationObject *)object.attachment;
        if (attachment.localCommand == YSFCommandInviteEvaluation) {
            if (attachment.inviteText.length > 0) {
                [_textLabel setText:attachment.inviteText];
            } else {
                [_textLabel setText:@"感谢您的咨询，请对我们的服务作出评价"];
            }
            _evaluationButton.hidden = NO;
            _inviteButton.hidden = YES;
            if (attachment.evaluationTimes == 0) {
                [_evaluationButton setTitle:@"评价" forState:UIControlStateNormal];
                _evaluationButton.ysf_frameWidth = 60;
            } else {
                [_evaluationButton setTitle:@"再次评价" forState:UIControlStateNormal];
                _evaluationButton.ysf_frameWidth = 100;
            }
        } else if (attachment.localCommand == YSFCommandSatisfactionResult) {
            [_textLabel setText:[NSString stringWithFormat:@"用户提交的服务评价为：%@", YSFStrParam(attachment.evaluationResult)]];
            _evaluationButton.hidden = YES;
            if (attachment.inviteStatus == YSFInviteEvaluateStatusHidden) {
                _inviteButton.hidden = YES;
            } else if (attachment.inviteStatus == YSFInviteEvaluateStatusEnable) {
                _inviteButton.hidden = NO;
                _inviteButton.enabled = YES;
                [_inviteButton setTitleColor:YSFRGB(0x008fff) forState:UIControlStateNormal];
            } else if (attachment.inviteStatus == YSFInviteEvaluateStatusUnable) {
                _inviteButton.hidden = NO;
                _inviteButton.enabled = NO;
                [_inviteButton setTitleColor:YSFColorFromRGB(0xdadada) forState:UIControlStateNormal];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = 75;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
    if ([object.attachment isKindOfClass:[YSFInviteEvaluationObject class]]) {
        YSFInviteEvaluationObject *attachment = (YSFInviteEvaluationObject *)object.attachment;
        if (attachment.localCommand == YSFCommandSatisfactionResult) {
            height = (attachment.inviteStatus == YSFInviteEvaluateStatusHidden) ? 30 : 56;
        }
    }
    
    _textLabel.ysf_frameWidth = _panel.ysf_frameWidth - 30;
    [_textLabel sizeToFit];
    
    _panel.ysf_frameHeight = _textLabel.ysf_frameHeight + height;
    _panel.ysf_frameTop = 5;
    _panel.ysf_frameCenterX = self.ysf_frameWidth / 2;
    
    _textLabel.ysf_frameTop = 15;
    _textLabel.ysf_frameCenterX = _panel.ysf_frameWidth / 2;
    
    _evaluationButton.ysf_frameTop = _textLabel.ysf_frameBottom + 15;
    _evaluationButton.ysf_frameCenterX = _panel.ysf_frameWidth / 2;
    
    _inviteButton.frame = CGRectMake(0, _textLabel.ysf_frameBottom + 10, _panel.ysf_frameWidth, 16);
}

- (void)onEvaluate:(id)sender {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapEvaluation;
    event.message = self.model.message;
    event.data = nil;
    [self.delegate onCatchEvent:event];
}

- (void)onInvite:(id)sender {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapInviteEvaluation;
    event.message = self.model.message;
    event.data = nil;
    [self.delegate onCatchEvent:event];
}

@end
