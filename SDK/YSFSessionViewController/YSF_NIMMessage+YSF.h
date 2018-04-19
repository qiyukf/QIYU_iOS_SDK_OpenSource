//
//  YSF_NIMMessage+http.h
//  QYKF
//
//  Created by 金华 on 16/3/22.
//  Copyright © 2016年 Netease. All rights reserved.
//

@interface YSF_NIMMessage (YSF)
/**
 *  缩略文本，用于会话列表显示
 */
- (NSString *)thumbText;

- (NSString *)getTextWithoutTrashWords;
- (BOOL)hasTrashWords;
- (NSString *)getTrashWordsTip;
@end

