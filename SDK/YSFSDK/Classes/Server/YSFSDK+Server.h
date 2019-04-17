//
//  YSFSDK+Server.h
//  YSFSDK
//
//  Created by amao on 9/21/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "QYSDK.h"

@interface QYSDK (Server)
- (void)readEnvironmentConfig:(NSNumber *)isTest useHttps:(NSNumber *)useHttps;
@end
