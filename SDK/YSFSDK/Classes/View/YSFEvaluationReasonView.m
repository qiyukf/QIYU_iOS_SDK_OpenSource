//
//  YSFEvaluationReasonView.m
//  YSFSDK
//
//  Created by Jacky Yu on 2018/3/1.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFEvaluationReasonView.h"
#import "YSFAlertController.h"

static CGFloat const kContentHeight = 220;
static CGFloat const kTitleHeight = 25;
static CGFloat const kcontentTextViewHeight = 116;
static CGFloat const kMaxTextLength = 200;

@interface YSFEvaluationReasonView ()<UITextViewDelegate, UIAlertViewDelegate>
//data
@property (nonatomic, copy) NSString *contentText;
@property (nonatomic, copy) NSString *holdText;
//View
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation YSFEvaluationReasonView

- (instancetype)initWithFrame:(CGRect)frame content:(NSString *)string holdText:(NSString *)holdText
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentText = string;
        self.holdText = holdText;
        [self initData];
        [self initUI];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initData {
    //注册键盘监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(15, (CGRectGetHeight(self.bounds)-kContentHeight)*0.5, CGRectGetWidth(self.bounds)-15*2, kContentHeight)];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 7;
    [self addSubview:contentView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(contentView.bounds)-30, kTitleHeight)];
    titleLabel.text = @"请告知我们具体原因";
    titleLabel.textColor = YSFRGB(0x222222);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    [contentView addSubview:titleLabel];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.bounds)-38, 5, 33, 33)];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [closeButton setImage:[UIImage ysf_imageInKit:@"icon_evaluation_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(onTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeButton];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 47, CGRectGetWidth(self.contentView.bounds), 0.5)];
    topLine.backgroundColor = YSFRGB(0xD3D3D3);
    [contentView addSubview:topLine];
    
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 47.5, CGRectGetWidth(contentView.bounds)-30, kcontentTextViewHeight)];
    self.contentTextView = contentTextView;
    contentTextView.delegate = self;
    contentTextView.text = self.contentText;
    [contentView addSubview:contentTextView];
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(contentTextView.bounds)-10, 20)];
    self.placeholderLabel = placeholderLabel;
    placeholderLabel.textAlignment = NSTextAlignmentLeft;
    placeholderLabel.textColor = YSFRGB(0x999999);
    placeholderLabel.numberOfLines = 0;
    placeholderLabel.text = self.holdText;
    placeholderLabel.font = [UIFont systemFontOfSize:15.0];
    [placeholderLabel sizeToFit];
    [contentTextView addSubview:placeholderLabel];
    if (self.contentText.length) {
        placeholderLabel.hidden = YES;
    }
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentTextView.frame), CGRectGetWidth(self.contentView.bounds), 0.5)];
    bottomLine.backgroundColor = YSFRGB(0xD3D3D3);
    [contentView addSubview:bottomLine];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(bottomLine.frame)+10, CGRectGetWidth(contentView.bounds)-30, 37)];
    self.confirmButton = confirmButton;
    confirmButton.backgroundColor = YSFRGB(0x529DF9);
    confirmButton.layer.cornerRadius = 5;
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(onTapConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmButton];
    
    [self checkConfirmButton];
}


#pragma mark - Events
- (void)onTapCloseButton:(UIButton *)sender {
    [self endEditing:YES];
    if (!self.contentTextView.text.ysf_trim.length || [self.contentTextView.text.ysf_trim isEqualToString:self.contentText]) {
        [self removeView];
    } else {
        self.hidden = YES;
        __weak typeof(self) weakSelf = self;
        YSFAlertController *alert = [YSFAlertController alertWithTitle:nil message:@"确定放弃编辑吗？"];
        [alert addCancelActionWithHandler:^(YSFAlertAction * _Nonnull action) {
            weakSelf.hidden = NO;
            [weakSelf.contentTextView becomeFirstResponder];
        }];
        [alert addAction:[YSFAlertAction actionWithTitle:@"确定" handler:^(YSFAlertAction * _Nonnull action) {
            [weakSelf removeView];
        }]];
        [alert showWithSender:nil controller:self.ysf_viewController animated:YES completion:nil];
    }
}

- (void)onTapConfirmButton:(UIButton*)sender {
    [self removeView];
    if ([self.contentTextView.text.ysf_trim isEqualToString:self.contentText.ysf_trim]) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(evaluationReasonView:didConfirmWithText:)]) {
        [self.delegate evaluationReasonView:self didConfirmWithText:self.contentTextView.text.ysf_trim];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.contentView];
    
    BOOL isInContentView = [self.contentView pointInside:point withEvent:nil];
    
    if (isInContentView) {
        return;
    }
    if (!self.contentTextView.text.ysf_trim.length) {
        [self removeView];
    }
}

#pragma mark - Delegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length) {
        _placeholderLabel.hidden = YES;
    } else {
        _placeholderLabel.hidden = NO;
    }
    
    if (textView.text.length >= kMaxTextLength) {
        textView.text = [textView.text substringToIndex:kMaxTextLength];
    }
    
    [self checkConfirmButton];
}

- (void)keyboardWillShow:(NSNotification*)notification{
    
    CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.frame = CGRectMake(15, (CGRectGetHeight(self.bounds)-keyBoardFrame.size.height)*0.4, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
    } completion:nil];
}


- (void)keyboardWillHidden:(NSNotification*)notification{
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.frame = CGRectMake(15, (CGRectGetHeight(self.bounds)-kContentHeight)*0.5, CGRectGetWidth(self.bounds)-15*2, kContentHeight);
    } completion:nil];
}

#pragma mark - Private Methods
- (void)checkConfirmButton {
    if ([self.contentTextView.text ysf_trim].length && ![self.contentTextView.text.ysf_trim isEqualToString:self.contentText.ysf_trim]) {
        self.confirmButton.enabled = YES;
        self.confirmButton.backgroundColor = YSFRGB(0x529DF9);
    } else {
        self.confirmButton.enabled = NO;
        self.confirmButton.backgroundColor = YSFRGB(0xcbe0ff);
    }
}

- (void)removeView {
    [self removeFromSuperview];
    if (self.completedBlock) {
        self.completedBlock();
    }
}

@end
