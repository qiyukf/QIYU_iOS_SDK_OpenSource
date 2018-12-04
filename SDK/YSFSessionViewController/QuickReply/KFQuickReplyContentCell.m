//
//  KFQuickReplyContentCell.m
//  QYKF
//
//  Created by Jacky Yu on 2018/3/7.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "KFQuickReplyContentCell.h"

static CGFloat kCellHeight = 40;

@interface YSFQuickReplyContentCell()
//view
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation YSFQuickReplyContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.contentLabel];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, kCellHeight-0.5, YSFUIScreenWidth, 0.5)];
    bottomLine.backgroundColor = YSFRGB(0xE6E6E6);
    [self addSubview:bottomLine];
}

#pragma mark - Public Methods
- (void)refresh:(NSString *)keyword showContent:(NSString *)showContent {
    NSString *text = @"";
    if (keyword.length > 0) {
        text = [NSString stringWithFormat:@"#%@ %@", keyword, showContent];
    }
    else {
        text = showContent;
    }
    self.contentLabel.attributedText = [self attributeTextWithContent:text keyword:self.searchText];
}


#pragma mark - Private Methods
- (NSAttributedString *)attributeTextWithContent:(NSString*)content keyword:(NSString*)keyword {
    if (!content || !keyword) {return nil;}
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[content ysf_stringByRemoveRepeatedWhitespaceAndNewline]];
    NSMutableArray<NSValue*> *rangeArray = [NSMutableArray arrayWithCapacity:0];
    NSRange range = [string.string.lowercaseString rangeOfString:keyword.lowercaseString];
    [rangeArray addObject:[NSValue valueWithRange:range]];
    while (range.location != NSNotFound && !_onlyMatchFirst) {
        range = [string.string.lowercaseString rangeOfString:keyword.lowercaseString options:0 range:NSMakeRange(range.location+range.length, string.string.length-range.location-range.length)];
        if (range.location != NSNotFound) {
            [rangeArray addObject:[NSValue valueWithRange:range]];
        }
    }
    [rangeArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [obj rangeValue];
        if (range.location != NSNotFound) {
            [string setAttributes:@{NSForegroundColorAttributeName : YSFRGB(0xF25058), NSFontAttributeName : [UIFont systemFontOfSize:15]} range:range];
        }
    }];
    
    return [string copy];
}

#pragma mark - Propertys
- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, YSFUIScreenWidth-20, kCellHeight)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.textColor = YSFRGB(0x101010);
    }
    return _contentLabel;
}

@end
