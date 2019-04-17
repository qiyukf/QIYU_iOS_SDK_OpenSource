//
//  YSFEmoticonTabView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2019/1/21.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFEmoticonTabView.h"
#import "YSFEmoticonDataManager.h"
#import "YSFEmoticonTabCell.h"


@interface YSFEmoticonTabView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *emoticonData;

@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, assign) NSUInteger selectIndex;

@end


@implementation YSFEmoticonTabView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = YSFColorFromRGB(0xcccccc);
        [self addSubview:_seperatorLine];

        [self initCollectionView];
        [self initSendButton];
        
        _selectIndex = 0;
    }
    return self;
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(YSFEmoticon_kTabCellWidth, YSFEmoticon_kTabHeight);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[YSFEmoticonTabCell class] forCellWithReuseIdentifier:YSFEmoticonTabCellIdentifier];
    [self addSubview:_collectionView];
}

- (void)initSendButton {
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.backgroundColor = [UIColor clearColor];
    _sendButton.layer.cornerRadius = 5.0f;
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
    [_sendButton setBackgroundImage:[UIImage ysf_imageInKit:@"icon_input_send_btn_normal"] forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:[UIImage ysf_imageInKit:@"icon_input_send_btn_pressed"] forState:UIControlStateHighlighted];
    [_sendButton addTarget:self action:@selector(onTouchSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat line = 1.0 / [UIScreen mainScreen].scale;
    _seperatorLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), line);
    _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - YSFEmoticon_kRefreshButtonWidth, YSFEmoticon_kTabHeight);
    _sendButton.frame = CGRectMake(CGRectGetMaxX(_collectionView.frame) + YSFEmoticon_kRefreshButtonMargin,
                                   YSFEmoticon_kRefreshButtonMargin,
                                   YSFEmoticon_kRefreshButtonWidth - 2 * YSFEmoticon_kRefreshButtonMargin,
                                   YSFEmoticon_kTabHeight - 2 * YSFEmoticon_kRefreshButtonMargin);
}

- (void)reloadEmoticonData:(NSArray *)emoticonData {
    _emoticonData = emoticonData;
    [self.collectionView reloadData];
}

- (void)reloadView:(NSUInteger)curIndex {
    _selectIndex = curIndex;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.emoticonData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YSFEmoticonTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YSFEmoticonTabCellIdentifier forIndexPath:indexPath];
    YSFEmoticonPackage *package = [self.emoticonData objectAtIndex:indexPath.item];
    cell.packageData = package;
    cell.selected = (indexPath.item == _selectIndex);
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YSFEmoticonPackage *package = [self.emoticonData objectAtIndex:indexPath.item];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectEmoticonPackage:indexPath:)]) {
        [self.delegate selectEmoticonPackage:package indexPath:indexPath];
    }
    _selectIndex = indexPath.item;
    [collectionView reloadData];
}

#pragma mark - Actions
- (void)onTouchSendButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapSendButton:)]) {
        [self.delegate tapSendButton:sender];
    }
}

@end
