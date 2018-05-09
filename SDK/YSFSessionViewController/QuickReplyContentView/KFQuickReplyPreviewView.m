//
//  KFQuickReplyPreviewView.m
//  QYKF
//
//  Created by Jacky Yu on 2018/3/7.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "KFQuickReplyPreviewView.h"
#import "YSFCoreText.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonParser.h"

static CGFloat const kContentMarginSpace = 25;
static CGFloat const kTitleHeight = 47;
static CGFloat const kButtonHeight = 50;
static CGFloat const kContentHeight = 270;
static CGFloat const kTextMinHeight = 40;
static CGFloat const kTextMaxHeight = 172;

@interface YSFQuickReplyPreviewView()<YSFAttributedTextContentViewDelegate>
//view
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) YSFAttributedTextView *textView;

//data
@property (nonatomic, copy) NSString *contentText;
@property (nonatomic, assign) BOOL isRichContent;

@end

@implementation YSFQuickReplyPreviewView

- (instancetype)initWithContent:(NSString *)content isRichContent:(BOOL)isRichContent {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.contentText = [content copy];
        self.isRichContent = isRichContent;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.contentView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, CGRectGetWidth(self.contentView.bounds), kTitleHeight-22)];
    titleLabel.text = @"发送确认";
    titleLabel.textColor = YSFRGB(0x222222);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:titleLabel];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 47, CGRectGetWidth(self.contentView.bounds), 0.5)];
    topLine.backgroundColor = YSFRGB(0xcccccc);
    [self.contentView addSubview:topLine];
    CGFloat textViewHeight = [self getContentSizeWithText:self.contentText].height;
    if (textViewHeight < kTextMinHeight) {
        textViewHeight = kTextMinHeight;
    } else if (textViewHeight > kTextMaxHeight) {
        textViewHeight = kTextMaxHeight;
    }
    YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectMake(20, 57.5, CGRectGetWidth(self.contentView.bounds)-20*2, textViewHeight)];
    self.textView = textView;
    textView.shouldDrawImages = NO;
    textView.textDelegate = self;
    textView.attributedString = [self attributedString:self.contentText];
    [self.contentView addSubview:textView];
    
    UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.contentView.bounds)-50.5, CGRectGetWidth(self.contentView.bounds), 0.5)];
    middleLine.backgroundColor = YSFRGB(0xcccccc);
    [self.contentView addSubview:middleLine];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.contentView.bounds)-kButtonHeight, CGRectGetWidth(self.contentView.bounds)*0.5-0.25, kButtonHeight)];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:YSFRGB(0x999999) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cancelButton];
    
    UIView *buttonLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.bounds)*0.5-0.25, CGRectGetHeight(self.contentView.bounds)-50, 0.5, 50)];
    buttonLine.backgroundColor = YSFRGB(0xCCCCCC);
    [self.contentView addSubview:buttonLine];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.bounds)*0.5+0.25, CGRectGetHeight(self.contentView.bounds)-kButtonHeight, CGRectGetWidth(self.contentView.bounds)*0.5-0.25, kButtonHeight)];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [confirmButton setTitle:@"发送" forState:UIControlStateNormal];
    [confirmButton setTitleColor:YSFRGB(0x639FFA) forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(onTapConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:confirmButton];
}

#pragma mark - Events
- (void)onTapCancelButton:(UIButton*)button {
    if (self.cancelBlock) {self.cancelBlock();}
    [self removeFromSuperview];
}

- (void)onTapConfirmButton:(UIButton*)button {
    if (self.sendBlock) {self.sendBlock();}
    [self removeFromSuperview];
}

#pragma mark - Delegate
- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView viewForAttachment:(YSFTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]])
    {
        // if the attachment has a hyperlinkURL then this is currently ignored
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.backgroundColor = YSFRGB(0xebebeb);
        imageView.contentMode = UIViewContentModeCenter;
        CGRect orginalRect = frame;
        if (frame.size.width < 90) {
            frame.size.width = 90;
        }
        if (frame.size.height < 90) {
            frame.size.height = 90;
        }
        if (!CGRectEqualToRect(orginalRect, frame)) {
            [attachment setDisplaySize:frame.size];
            [attributedTextContentView.superview setNeedsLayout];
        }
        UIImage *placeHoderImage = [UIImage imageNamed:@"icon_image_loading_default"];
        [imageView ysf_setImageWithURL:attachment.contentURL placeholderImage:placeHoderImage
                             completed:^(UIImage * _Nullable image, NSError * _Nullable error,
                                         YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                 if (error != nil) {
                                     UIImage *failedImage = [UIImage imageNamed:@"icon_image_loading_failed"];
                                     imageView.image = failedImage;
                                 }
                                 else {
                                     if (!CGRectEqualToRect(orginalRect, frame)) {
                                         [attachment setDisplaySize:orginalRect.size];
                                         [attributedTextContentView.superview setNeedsLayout];
                                     }
                                     imageView.contentMode = UIViewContentModeScaleToFill;
                                     imageView.backgroundColor = [UIColor clearColor];
                                 }
                             }];
        
        // NOTE: this is a hack, you probably want to use your own image view and touch handling
        // also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
        imageView.userInteractionEnabled = YES;
        
        return imageView;
    }
    else if ([attachment isKindOfClass:[YSFObjectTextAttachment class]])
    {
        UIImageView *someView = [[UIImageView alloc] initWithFrame:frame];
        NSInteger type = [[attachment.attributes objectForKey:@"type"] integerValue];
        if (type == 0) {    //emoji
            NSString *emojiStr = [attachment.attributes objectForKey:@"data"];
            YSFInputEmoticon *emoticon = [[YSFInputEmoticonManager sharedManager] emoticonByTag:emojiStr];
            UIImage *image = [UIImage imageNamed:emoticon.filename];
            someView.image = image;
        }
        
        return someView;
    }
    
    return nil;
}

#pragma mark - Private Methods
- (NSAttributedString *)attributedString:(NSString *)text
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    __block NSInteger index = 0;
    __block NSString *resultText = @"";
    [exp enumerateMatchesInString:text
                          options:0
                            range:NSMakeRange(0, [text length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [text substringWithRange:result.range];
                           if ([[YSFInputEmoticonManager sharedManager] emoticonByTag:rangeText])
                           {
                               if (result.range.location > index)
                               {
                                   NSString *rawText = [text substringWithRange:NSMakeRange(index, result.range.location - index)];
                                   resultText = [resultText stringByAppendingString:rawText];
                               }
                               NSString *rawText = [NSString stringWithFormat:@"<object type=\"0\" data=\"%@\" width=\"18\" height=\"18\"></object>", rangeText];
                               resultText = [resultText stringByAppendingString:rawText];
                               
                               index = result.range.location + result.range.length;
                           }
                       }];
    
    if (index < [text length])
    {
        NSString *rawText = [text substringWithRange:NSMakeRange(index, [text length] - index)];
        resultText = [resultText stringByAppendingString:rawText];
    }
    resultText = [NSString stringWithFormat:@"<span>%@</span>", resultText];
    NSData *data = [resultText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create attributed string from HTML
    CGSize maxImageSize = CGSizeMake(239, 425);

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGSize:maxImageSize], YSFMaxImageSize, @(16), YSFDefaultFontSize, [UIColor blackColor], YSFDefaultTextColor, [UIColor blueColor], YSFDefaultLinkColor, nil];
    NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}

- (CGSize)getContentSizeWithText:(NSString*)text {
    if (!text) {return CGSizeZero;}
    CGSize size = CGSizeZero;
    if (self.isRichContent) {
        return CGSizeMake(YSFUIScreenWidth-kContentMarginSpace*2-40, kTextMaxHeight);
    } else {
        size = [text boundingRectWithSize:CGSizeMake(YSFUIScreenWidth-kContentMarginSpace*2-40, kTextMaxHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size;
    }
    return size;
}


#pragma mark - Properties
- (UIView *)contentView {
    if (!_contentView) {
        CGFloat contentViewHeight = [self getContentSizeWithText:self.contentText].height;
        if (contentViewHeight < kTextMinHeight) {
            contentViewHeight = kTextMinHeight;
        } else if (contentViewHeight > kTextMaxHeight) {
            contentViewHeight = kTextMaxHeight;
        }
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(kContentMarginSpace, (YSFUIScreenHeight-(contentViewHeight+kContentHeight-kTextMaxHeight))*0.5, YSFUIScreenWidth-kContentMarginSpace*2, contentViewHeight+kContentHeight-kTextMaxHeight+10)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 8;
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}


@end
