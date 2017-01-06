//
//  YSFGalleryViewController.m
//  NIMDemo
//
//  Created by panqinke on 15-10-25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFImageConfirmedViewController.h"


@interface YSFImageConfirmedViewController ()

@property (strong, nonatomic) UIImage *galleryImage;
@property (strong, nonatomic) UIImageView *galleryImageView;
@property (strong, nonatomic) UIImageView *imagePanel;
@property (strong, nonatomic) UIView *horSep;
@property (strong, nonatomic) UIView *verSep;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *cancelButton;

@end


@implementation YSFImageConfirmedViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        _galleryImage = image;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = YSFColorFromRGBA(0x000000, 0.4);
    _imagePanel = [[UIImageView alloc] init];
    _imagePanel.userInteractionEnabled = YES;
    _imagePanel.image = [[UIImage ysf_imageInKit:@"icon_input_text_bg"]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,20)];
    [self.view addSubview:_imagePanel];
    
    _galleryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _galleryImageView.image = _galleryImage;
    _galleryImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_imagePanel addSubview:_galleryImageView];
    
    _horSep = [[UIView alloc] initWithFrame:CGRectZero];
    _horSep.backgroundColor = YSFColorFromRGB(0xcccccc);
    _horSep.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_imagePanel addSubview:_horSep];

    _verSep = [[UIView alloc] initWithFrame:CGRectZero];
    _verSep.backgroundColor = YSFColorFromRGB(0xcccccc);
    [_imagePanel addSubview:_verSep];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_cancelButton setTitleColor:YSFColorFromRGB(0x808c97) forState:UIControlStateNormal];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelButton addTarget:self action:@selector(cancelSendImage:) forControlEvents:UIControlEventTouchUpInside];
    [_imagePanel addSubview:_cancelButton];

    _sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_sendButton setTitleColor:YSFColorFromRGB(0x37474f) forState:UIControlStateNormal];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_sendButton addTarget:self action:@selector(sendImage:) forControlEvents:UIControlEventTouchUpInside];
    [_imagePanel addSubview:_sendButton];

}

- (void)viewDidLayoutSubviews
{
    _imagePanel.frame = CGRectMake(0,0,245,265);
    _imagePanel.center = self.view.center;
    CGRect frame2 = _imagePanel.bounds;
    frame2.size.height -= 45;
    frame2.origin.x += 18;
    frame2.origin.y += 18;
    frame2.size.width -= 36;
    frame2.size.height -= 36;
    _galleryImageView.frame = frame2;
    CGRect frame4 = CGRectZero;
    frame4.origin.x = _imagePanel.frame.size.width / 2;
    frame4.origin.y = [_galleryImageView ysf_frameBottom] + 18;
    frame4.size.height = 45;
    frame4.size.width = 1;
    _verSep.frame = frame4;
    CGRect frame5 = CGRectZero;
    frame5.origin.y = [_galleryImageView ysf_frameBottom] + 18;
    frame5.size.height = 45;
    frame5.size.width = _imagePanel.frame.size.width / 2;
    _cancelButton.frame = frame5;
    CGRect frame3 = CGRectZero;
    frame3.origin.y = [_galleryImageView ysf_frameBottom] + 18;
    frame3.size.height = 1;
    frame3.size.width = _imagePanel.frame.size.width;
    _horSep.frame = frame3;
    CGRect frame6 = CGRectZero;
    frame6.origin.x = _imagePanel.frame.size.width / 2 + 1;
    frame6.origin.y = [_galleryImageView ysf_frameBottom] + 18;
    frame6.size.height = 45;
    frame6.size.width = _imagePanel.frame.size.width / 2;
    _sendButton.frame = frame6;
}

 - (void)cancelSendImage:(id)sender
{
    _sendingImageConfirmedCallback(NO);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendImage:(id)sender
{
    _sendingImageConfirmedCallback(YES);
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end



