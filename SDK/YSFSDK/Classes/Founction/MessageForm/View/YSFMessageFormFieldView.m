//
//  YSFMessageFormFieldView.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormFieldView.h"
#import "YSFMessageFormField.h"
#import "YSFMenuModel.h"
#import "YSFTools.h"

static CGFloat YSFMessageFormFieldMargin = 10.0f;
static CGFloat YSFMessageFormFieldTextFont = 14.0f;
static CGFloat YSFMessageFormFieldTextViewMargin = 2.0f;
static CGFloat YSFMessageFormFieldNameMaxWidth = 72.0f;
static CGFloat YSFMessageFormFieldStarWidth = 15.0f;


@interface YSFMessageFormFieldView () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *starLabel;
@property (nonatomic, strong) UILabel *leadLabel;
@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end


@implementation YSFMessageFormFieldView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self initContentView];
    }
    return self;
}

- (void)reload {
    if (self.fieldData.type == YSFMessageFormFieldTypeSingleMenu
        || self.fieldData.type == YSFMessageFormFieldTypeMultipleMenu) {
        NSString *selectStr = nil;
        NSString *resultStr = nil;
        for (YSFMenuModel *model in self.options) {
            if (model.selected && model.text.length) {
                if (!selectStr) {
                    selectStr = model.text;
                    resultStr = model.text;
                } else {
                    selectStr = [selectStr stringByAppendingString:[NSString stringWithFormat:@",%@", model.text]];
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@";%@", model.text]];
                }
            }
        }
        if ([selectStr isEqualToString:@"未选择"]) {
            _leadLabel.text = selectStr;
            _leadLabel.textColor = YSFColorFromRGB(0xc2c2c9);
        } else {
            _leadLabel.text = selectStr;
            _leadLabel.textColor = YSFColorFromRGB(0x333333);
        }
        self.fieldData.value = resultStr;
    }
}

- (void)resignResponder {
    [_textField resignFirstResponder];
    [_textView resignFirstResponder];
}

- (void)setFieldData:(YSFMessageFormField *)fieldData {
    _fieldData = fieldData;
    /**
     * 1. 若为单选/多选/时间，则显示“请选择”
     * 2. 若为留言，则显示留言框
     * 3. 若为其他，则显示name和textField，注意数字需指定键盘类型
     */
    if (fieldData.type == YSFMessageFormFieldTypeSingleMenu
        || fieldData.type == YSFMessageFormFieldTypeMultipleMenu
        || fieldData.type == YSFMessageFormFieldTypeTime) {
        //解析选项数据
        if (fieldData.type == YSFMessageFormFieldTypeSingleMenu
            || fieldData.type == YSFMessageFormFieldTypeMultipleMenu) {
            NSArray *array = [fieldData.desc ysf_toArray];
            NSMutableArray *optionArray = [NSMutableArray arrayWithCapacity:([array count] + 1)];
            [optionArray addObject:[[YSFMenuModel alloc] initWithText:@"未选择" selected:YES]];
            for (NSDictionary *dict in array) {
                YSFMenuModel *model = [YSFMenuModel dataByJson:dict];
                [optionArray addObject:model];
            }
            self.options = optionArray;
        }
        [self initNameLabel];
        [self initLeadLabel];
        [self initArrowView];
        if (fieldData.required) {
            [self initStarLabel];
        }
        //添加点击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
        [self addGestureRecognizer:singleTap];
    } else if (fieldData.type == YSFMessageFormFieldTypeMessage) {
        [self initTextView];
        [self initPlaceholderLabel];
    } else {
        [self initNameLabel];
        [self initTextField];
        if (fieldData.required) {
            [self initStarLabel];
        }
        _textField.placeholder = [NSString stringWithFormat:@"请输入%@", YSFStrParam(fieldData.name)];
        if (fieldData.type == YSFMessageFormFieldTypePhone
            || fieldData.type == YSFMessageFormFieldTypeNumber) {
            _textField.keyboardType = UIKeyboardTypeNumberPad;
        } else if (fieldData.type == YSFMessageFormFieldTypeEmail) {
            _textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
    }
    //设置名称
    if (_nameLabel && fieldData.name.length) {
        _nameLabel.text = fieldData.name;
    }
}

- (void)initContentView {
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 2.0f;
    _contentView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    _contentView.layer.borderColor = YSFColorFromRGB(0xe1e3e6).CGColor;
    [self addSubview:_contentView];
}

- (void)initNameLabel {
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize:YSFMessageFormFieldTextFont];
    _nameLabel.textColor = [UIColor darkGrayColor];
    _nameLabel.numberOfLines = 1;
    [self.contentView addSubview:_nameLabel];
}

- (void)initTextField {
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.font = [UIFont systemFontOfSize:YSFMessageFormFieldTextFont];
    _textField.textColor = YSFColorFromRGB(0x333333);
    _textField.placeholder = @"请输入";
    _textField.delegate = self;
    [self.contentView addSubview:_textField];
}

- (void)initStarLabel {
    _starLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _starLabel.font = [UIFont systemFontOfSize:YSFMessageFormFieldTextFont];
    _starLabel.textColor = YSFRGB(0x5092E1);
    _starLabel.numberOfLines = 1;
    _starLabel.text = @"*";
    [self.contentView addSubview:_starLabel];
}

- (void)initLeadLabel {
    _leadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _leadLabel.font = [UIFont systemFontOfSize:YSFMessageFormFieldTextFont];
    _leadLabel.textColor = YSFColorFromRGB(0xc2c2c9);
    _leadLabel.numberOfLines = 1;
    _leadLabel.textAlignment = NSTextAlignmentRight;
    _leadLabel.text = @"未选择";
    [self.contentView addSubview:_leadLabel];
}

- (void)initArrowView {
    _arrowView = [[UIImageView alloc] init];
    _arrowView.image = [UIImage ysf_imageInKit:@"icon_arrow"];
    [self.contentView addSubview:_arrowView];
}

- (void)initTextView {
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.font = [UIFont systemFontOfSize:YSFMessageFormFieldTextFont];
    _textView.textColor = YSFColorFromRGB(0x333333);
    _textView.delegate = self;
    [self.contentView addSubview:_textView];
}

- (void)initPlaceholderLabel {
    _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _placeholderLabel.textColor = YSFColorFromRGB(0xc2c2c9);
    _placeholderLabel.font = [UIFont systemFontOfSize:YSFMessageFormFieldTextFont];
    NSString *text = [@"留言" stringByAppendingString:@"*"];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    [attrString addAttribute:NSForegroundColorAttributeName value:YSFRGB(0x5092E1) range:NSMakeRange(text.length - 1, 1)];
    _placeholderLabel.attributedText = attrString;
    [_textView addSubview:_placeholderLabel];
}

- (void)setFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)
        || CGRectEqualToRect(frame, self.frame)) {
        return;
    }
    [super setFrame:frame];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat line = 1.0 / [UIScreen mainScreen].scale;
    _contentView.frame = CGRectMake(YSFMessageFormFieldHorizontalSpace,
                                    YSFMessageFormFieldVerticalSpace,
                                    width - 2 * YSFMessageFormFieldHorizontalSpace,
                                    height - 2 * YSFMessageFormFieldVerticalSpace);
    
    if (self.fieldData.type == YSFMessageFormFieldTypeSingleMenu
        || self.fieldData.type == YSFMessageFormFieldTypeMultipleMenu
        || self.fieldData.type == YSFMessageFormFieldTypeTime) {
        CGFloat nameWidth = ROUND_SCALE(self.fieldData.nameWidth);
        nameWidth = MIN(nameWidth, YSFMessageFormFieldNameMaxWidth);
        _nameLabel.frame = CGRectMake(YSFMessageFormFieldMargin, 0, nameWidth, CGRectGetHeight(_contentView.frame));
        if (self.fieldData.required) {
            _starLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame), 0, YSFMessageFormFieldStarWidth, CGRectGetHeight(_contentView.frame));
        }
        CGSize imgSize = _arrowView.image.size;
        _arrowView.frame = CGRectMake(CGRectGetWidth(_contentView.frame) - YSFMessageFormFieldMargin - imgSize.width,
                                      ROUND_SCALE((CGRectGetHeight(_contentView.frame) - imgSize.height) / 2),
                                      imgSize.width,
                                      imgSize.height);
        _leadLabel.frame = CGRectMake(YSFMessageFormFieldNameMaxWidth + YSFMessageFormFieldStarWidth + 2 * YSFMessageFormFieldMargin,
                                      0,
                                      CGRectGetMinX(_arrowView.frame) - YSFMessageFormFieldNameMaxWidth - YSFMessageFormFieldStarWidth - 3 * YSFMessageFormFieldMargin,
                                      CGRectGetHeight(_contentView.frame));
    } else if (self.fieldData.type == YSFMessageFormFieldTypeMessage) {
        _textView.frame = CGRectMake(YSFMessageFormFieldTextViewMargin,
                                     YSFMessageFormFieldTextViewMargin,
                                     CGRectGetWidth(_contentView.frame) - 2 * YSFMessageFormFieldTextViewMargin,
                                     CGRectGetHeight(_contentView.frame) - 2 * YSFMessageFormFieldTextViewMargin);
        _placeholderLabel.frame = CGRectMake(5, 3, CGRectGetWidth(_textView.frame) - 10, YSFMessageFormFieldTextFont * 2);
    } else {
        CGFloat nameWidth = ROUND_SCALE(self.fieldData.nameWidth);
        nameWidth = MIN(nameWidth, YSFMessageFormFieldNameMaxWidth);
        _nameLabel.frame = CGRectMake(YSFMessageFormFieldMargin, 0, nameWidth, CGRectGetHeight(_contentView.frame));
        if (self.fieldData.required) {
            _starLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame), 0, YSFMessageFormFieldStarWidth, CGRectGetHeight(_contentView.frame));
        }
        _textField.frame = CGRectMake(YSFMessageFormFieldNameMaxWidth + YSFMessageFormFieldStarWidth + 2 * YSFMessageFormFieldMargin,
                                      line,
                                      CGRectGetWidth(_contentView.frame) - 3 * YSFMessageFormFieldMargin - YSFMessageFormFieldNameMaxWidth - YSFMessageFormFieldStarWidth,
                                      CGRectGetHeight(_contentView.frame));
    }
}

#pragma mark - Action
- (void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTapMessageFormFieldView:)]) {
        [self.delegate onTapMessageFormFieldView:self];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.fieldData.value = textField.text;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        _placeholderLabel.hidden = YES;
    } else {
        _placeholderLabel.hidden = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        return YES;
    }
    if (range.location >= 500) {
        return NO;
    } else {
        return YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.fieldData.value = textView.text;
}

@end
