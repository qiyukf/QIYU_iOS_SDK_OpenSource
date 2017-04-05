//
//  NSData+YSF.h
//  YSFSDK
//
//  Created by amao on 8/27/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (YSF)
- (NSString *)ysf_md5;

- (NSData *)ysf_gzippedData;

- (NSData *)ysf_gunzippedData;

- (NSData *)ysf_gzippedDataWithCompressLevel:(float)level;

@end
