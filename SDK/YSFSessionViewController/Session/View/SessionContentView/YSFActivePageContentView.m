#import "YSFActivePageContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFActivePage.h"
#import "UIImageView+YSFWebCache.h"

@interface YSFActionView5 : UIButton

@property (nonatomic, strong) YSFAction *action;

@end

@implementation YSFActionView5
@end

@interface YSFActivePageContentView()

@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UILabel * content;
@property (nonatomic,strong) YSFActionView5 *actionButton;

@end

@implementation YSFActivePageContentView

- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
        _content = [UILabel new];
        [self addSubview:_content];
        _content.font = [UIFont systemFontOfSize:15];
        _content.numberOfLines = 0;
        _actionButton = [YSFActionView5 new];
        [self addSubview:_actionButton];
    }
    return self;
}


- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    
    CGFloat offsetY = 0;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFActivePage *activePage = (YSFActivePage *)object.attachment;
    _imageView.frame = CGRectMake(5, offsetY,
                                self.model.contentSize.width - 5, 90);
    
    _imageView.layer.cornerRadius = 2;
    _imageView.layer.masksToBounds = YES;
    NSURL *url = nil;
    if (activePage.img) {
        url = [NSURL URLWithString:activePage.img];
    }
    if (url) {
        [_imageView ysf_setImageWithURL:url];
    }
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _imageView.ysf_frameLeft -= 5;
    }
    
    offsetY += 90;
    offsetY += 13;

    _content.text = activePage.content;
    _content.frame = CGRectMake(18, offsetY,
                             self.model.contentSize.width - 33, 0);
    [_content sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _content.ysf_frameLeft -= 5;
    }
    
    offsetY += _content.ysf_frameHeight;
    offsetY += 13;
    
    _actionButton.action = activePage.action;
    _actionButton.layer.borderWidth = 0.5;
    _actionButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _actionButton.layer.borderColor = YSFRGB(0x5092E1).CGColor;
    _actionButton.layer.cornerRadius = 2;
    [_actionButton setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
    [_actionButton setTitle:activePage.action.validOperation forState:UIControlStateNormal];
    _actionButton.frame = CGRectMake(18, offsetY,
                                self.model.contentSize.width - 33, 34);
    [_actionButton addTarget:self action:@selector(onClickAction:) forControlEvents:UIControlEventTouchUpInside];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _actionButton.ysf_frameLeft -= 5;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}


- (void)onClickAction:(YSFActionView5 *)actionView
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapBot;
    event.message = self.model.message;
    event.data = actionView.action;
    [self.delegate onCatchEvent:event];
}


@end
