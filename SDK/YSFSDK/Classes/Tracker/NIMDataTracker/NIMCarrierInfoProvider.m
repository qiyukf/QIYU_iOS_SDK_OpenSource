//
//  NIMCarrierInfoProvider.m
//  NIMSDK
//
//  Created by amao on 2017/12/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NIMCarrierInfoProvider.h"
#import "NIMDataTrackerCategory.h"
@import CoreTelephony;

@implementation YSF_NIMCarrierInfoProvider
- (instancetype)init
{
    if (self = [super init])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    
    _carrierName        =   carrier.carrierName;
    _mobileCountryCode  =   carrier.mobileCountryCode;
    _mobileNetworkCode  =   carrier.mobileNetworkCode;
    _isoCountryCode     =   carrier.isoCountryCode;
    _radioType          =   info.currentRadioAccessTechnology;

}

- (NSDictionary *)toJsonDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict ysfdt_setObject:_mobileNetworkCode
                   forKey:@"mnc"];
    [dict ysfdt_setObject:_mobileCountryCode
                   forKey:@"mcc"];
    [dict ysfdt_setObject:_radioType
                   forKey:@"radio_tech"];
    [dict ysfdt_setObject:_carrierName
                   forKey:@"carrier_name"];
    [dict ysfdt_setObject:_isoCountryCode
                   forKey:@"iso_cc"];
    return dict;
}
@end
