#import "KFNewMsgTipViewToDown.h"

@interface KFNewMsgTipViewToDown()

@property (strong,nonatomic) UIButton* titleLabel;

@end

@implementation KFNewMsgTipViewToDown


-(instancetype)initWithUnreadCount:(int)unreadCount{
    self = [super init];
    if (self) {
        self.backgroundColor = YSFRGB(0xe1efff);
        self.layer.cornerRadius = 12.0;

        _titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleLabel.layer setMasksToBounds:YES];
        _titleLabel.layer.cornerRadius = 10;
        [_titleLabel setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
        _titleLabel.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_titleLabel setTitle:[NSString stringWithFormat:@"%d条未读消息",unreadCount] forState:UIControlStateNormal];
        [_titleLabel sizeToFit];
        _titleLabel.ysf_frameLeft = 10;
        [_titleLabel addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleLabel];

        self.ysf_frameWidth = _titleLabel.ysf_frameWidth + 20;
        self.ysf_frameHeight = _titleLabel.ysf_frameHeight;
    }
    return self;
}


-(void)setUnreadCount:(int)unreadCount{
    [_titleLabel setTitle:[NSString stringWithFormat:@"%d条未读消息",unreadCount] forState:UIControlStateNormal];
}


-(void)onTap:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onScrollToNewMessagesToDown)]) {
        [self.delegate onScrollToNewMessagesToDown];
    }
}
@end
