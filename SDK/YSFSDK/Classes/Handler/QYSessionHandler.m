//
//  QYSessionHandler.m
//  YSFSDK
//
//  Created by 金华 on 16/3/15.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "QYSessionHandler.h"
#import "YSFImagePickerManager.h"
#import "YSFALListViewController.h"
#import "YSFPHListViewController.h"

@implementation QYSessionHandler

#pragma mark - 图片选择器
#pragma mark - YSFALListViewControllerDelegate
- (void)snsAlbumPickerViewController:(YSFALListViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickImageCompeletedWithImages:)]) {
            [self.delegate pickImageCompeletedWithImages:info];
        }
    }];
}

- (void)snsAlbumPickerViewControllerDidCancel:(YSFALListViewController *)picker
{
    picker.snsAPDelegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PhotoKit YSFPHListViewControllerDelegate
- (void)yxPLAssetListViewController:(YSFPHListViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {

    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickImageCompeletedWithImages:)]) {
            [self.delegate pickImageCompeletedWithImages:info];
        }
    }];
}
- (void)yxPLAssetListViewControllerDidCancel:(YSFPHListViewController *)picker {
    picker.plListDelegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
