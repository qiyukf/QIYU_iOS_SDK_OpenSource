#import "YSFOrderDetailContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFOrderDetail.h"

@interface YSFOrderDetailContentView()

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIView *splitLine;
@property (nonatomic,strong) UILabel *status;
@property (nonatomic,strong) UILabel *userName;
@property (nonatomic,strong) UIImageView *statusIcon;
@property (nonatomic,strong) UIImageView *userNameIcon;
@property (nonatomic,strong) UIImageView *orderIcon;
@property (nonatomic,strong) UILabel *address;
@property (nonatomic,strong) UILabel *orderNo;
@property (nonatomic,strong) UILabel *date;

@end

@implementation YSFOrderDetailContentView

- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];

    if (self) {
        _label = [UILabel new];
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.font = [UIFont systemFontOfSize:16.f];
        [self addSubview:_label];
        
        _splitLine = [UIView new];
        _splitLine.backgroundColor = YSFRGB(0xdbdbdb);
        [self addSubview:_splitLine];

        _statusIcon = [UIImageView new];
        _statusIcon.image = [UIImage ysf_imageInKit:@"icon_delivery"];
        [self addSubview:_statusIcon];
        _userNameIcon = [UIImageView new];
        _userNameIcon.image = [UIImage ysf_imageInKit:@"icon_address"];
        [self addSubview:_userNameIcon];
        _orderIcon = [UIImageView new];
        _orderIcon.image = [UIImage ysf_imageInKit:@"icon_order"];
        [self addSubview:_orderIcon];
        
        _status = [UILabel new];
        _status.numberOfLines = 0;
        _status.lineBreakMode = NSLineBreakByWordWrapping;
        _status.font = [UIFont systemFontOfSize:16.f];
        [self addSubview:_status];
        _userName = [UILabel new];
        _userName.numberOfLines = 0;
        _userName.lineBreakMode = NSLineBreakByWordWrapping;
        _userName.font = [UIFont systemFontOfSize:16.f];
        [self addSubview:_userName];
        _address = [UILabel new];
        _address.numberOfLines = 0;
        _address.lineBreakMode = NSLineBreakByWordWrapping;
        _address.font = [UIFont systemFontOfSize:16.f];
        _address.textColor = YSFRGB(0x666666);
        [self addSubview:_address];
        _orderNo = [UILabel new];
        _orderNo.numberOfLines = 0;
        _orderNo.lineBreakMode = NSLineBreakByWordWrapping;
        _orderNo.font = [UIFont systemFontOfSize:16.f];
        [self addSubview:_orderNo];
        _date = [UILabel new];
        _date.numberOfLines = 0;
        _date.lineBreakMode = NSLineBreakByWordWrapping;
        _date.font = [UIFont systemFontOfSize:16.f];
        _date.textColor = YSFRGB(0x666666);
        [self addSubview:_date];
    }
    return self;
}


- (void)refresh:(YSFMessageModel *)data {
    [super refresh:data];
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFOrderDetail *orderDetail = (YSFOrderDetail *)object.attachment;
    [_label setText:orderDetail.label];
    [_status setText:orderDetail.status];
    [_userName setText:orderDetail.userName];
    [_address setText:orderDetail.address];
    [_orderNo setText:orderDetail.orderNo];
    [_date setText:orderDetail.date];
}

- (void)layoutSubviews
{
    CGFloat offsetY = self.model.contentViewInsets.top;
    offsetY += 13;
    _label.ysf_frameLeft = self.model.contentViewInsets.left + 18;
    _label.ysf_frameTop = offsetY;
    _label.ysf_frameWidth = self.model.contentSize.width - 40;
    [_label sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _label.ysf_frameLeft -= 5;
    }
    
    offsetY += _label.ysf_frameHeight;
    offsetY += 13;
    
    _splitLine.ysf_frameHeight = 0.5;
    _splitLine.ysf_frameLeft = 5;
    _splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
    _splitLine.ysf_frameTop = offsetY;
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _splitLine.ysf_frameLeft -= 5;
    }
    
    offsetY += 13;

    _statusIcon.ysf_frameLeft = self.model.contentViewInsets.left + 18;
    _statusIcon.ysf_frameTop = offsetY + 3;
    _statusIcon.ysf_frameWidth = self.model.contentSize.width - 60;
    [_statusIcon sizeToFit];
    _status.ysf_frameLeft = self.model.contentViewInsets.left + 38;
    _status.ysf_frameTop = offsetY;
    _status.ysf_frameWidth = self.model.contentSize.width - 60;
    [_status sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _statusIcon.ysf_frameLeft -= 5;
    }
    
    offsetY += _status.ysf_frameHeight;
    offsetY += 13;
    
    _userNameIcon.ysf_frameLeft = self.model.contentViewInsets.left + 18;
    _userNameIcon.ysf_frameTop = offsetY + 3;
    _userNameIcon.ysf_frameWidth = self.model.contentSize.width - 60;
    [_userNameIcon sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _userNameIcon.ysf_frameLeft -= 5;
    }
    
    _userName.ysf_frameLeft = self.model.contentViewInsets.left + 38;
    _userName.ysf_frameTop = offsetY;
    _userName.ysf_frameWidth = self.model.contentSize.width - 60;
    [_userName sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _userName.ysf_frameLeft -= 5;
    }
    
    offsetY += _userName.ysf_frameHeight;
    _address.ysf_frameLeft = self.model.contentViewInsets.left + 38;
    _address.ysf_frameTop = offsetY;
    _address.ysf_frameWidth = self.model.contentSize.width - 60;
    [_address sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _address.ysf_frameLeft -= 5;
    }
    
    offsetY += _address.ysf_frameHeight;
    offsetY += 13;
    
    _orderIcon.ysf_frameLeft = self.model.contentViewInsets.left + 18;
    _orderIcon.ysf_frameTop = offsetY + 3;
    _orderIcon.ysf_frameWidth = self.model.contentSize.width - 60;
    [_orderIcon sizeToFit];
    _orderNo.ysf_frameLeft = self.model.contentViewInsets.left + 38;
    _orderNo.ysf_frameTop = offsetY;
    _orderNo.ysf_frameWidth = self.model.contentSize.width - 60;
    [_orderNo sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _orderIcon.ysf_frameLeft -= 5;
    }
    
    offsetY += _orderNo.ysf_frameHeight;
    offsetY += 13;

    _date.ysf_frameLeft = self.model.contentViewInsets.left + 38;
    _date.ysf_frameTop = offsetY;
    _date.ysf_frameWidth = self.model.contentSize.width - 60;
    [_date sizeToFit];
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _date.ysf_frameLeft -= 5;
    }
    
    offsetY += _date.ysf_frameHeight;
}


@end
