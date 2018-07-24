//
//  KFQuickReplyContentView.m
//  QYKF
//
//  Created by Jacky Yu on 2018/3/7.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "KFQuickReplyContentView.h"
#import "KFQuickReplyContentCell.h"
#import "YSFSendSearchQuestionResponse.h"

static CGFloat const kCellHeight = 40.f;

@interface YSFQuickReplyContentView()<UITableViewDelegate, UITableViewDataSource>
//view
@property (nonatomic, strong) UITableView *tableview;

//Data
@property (nonatomic, strong) NSMutableArray<YSFQuickReplyKeyWordAndContent*> *dataArray;

@end

@implementation YSFQuickReplyContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithFrame:CGRectZero];
}

- (void)initData {
    self.dataArray = [NSMutableArray array];
}

- (void)initUI {
    self.clipsToBounds = YES;
    [self addSubview:self.tableview];
}

#pragma mark - Public Methods
- (void)updateDataArray:(NSArray<YSFQuickReplyKeyWordAndContent *> *)dataArray {
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:dataArray];
    [self.tableview reloadData];
}

- (NSUInteger)itemCount {
    return self.dataArray.count;
}

- (CGFloat)viewHeight {
    return self.dataArray.count * kCellHeight;
}

#pragma mark - DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSFQuickReplyContentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YSFQuickReplyContentCell class])];
    if (indexPath.row < self.dataArray.count) {
        cell.searchText = self.searchText;
        cell.onlyMatchFirst = _onlyMatchFirst;
        YSFQuickReplyKeyWordAndContent *object = self.dataArray[indexPath.row];
        [cell refresh:object.keyword showContent:object.content];
    }
    
    return cell;
}

#pragma mark - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self onTapCellAtIndexPath:indexPath];
}

#pragma mark - Private Methods
- (void)onTapCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapRowAtIndex:data:)]) {
        [self.delegate didTapRowAtIndex:indexPath.row data:self.dataArray[indexPath.row]];
    }
}

#pragma mark - Property
- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = kCellHeight;
        _tableview.estimatedRowHeight = kCellHeight;
        _tableview.estimatedSectionFooterHeight = 0;
        _tableview.estimatedSectionHeaderHeight = 0;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableview registerClass:[YSFQuickReplyContentCell class] forCellReuseIdentifier:NSStringFromClass([YSFQuickReplyContentCell class])];
    }
    return _tableview;
}


@end
