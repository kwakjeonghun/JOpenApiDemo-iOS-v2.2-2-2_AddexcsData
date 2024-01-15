//
//  J2203Device.h
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 14..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#ifndef J2203Device_h
#define J2203Device_h
#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>

typedef NS_ENUM(NSInteger, EXEC_CMD_TYPE) {
    BAND_EXEC_CALL_MODE = 10,
    BAND_EXEC_SMS_MODE = 11,
    BAND_EXEC_SNS_MODE = 12
};

@interface J2203Device : NSObject

+ (instancetype)sharedInstance;
- (void)discoveryService;
- (void)execute:(unsigned int)cmd args:(NSArray *)args;
- (void)readSyncData;
- (void)pairDevice;
- (void)readDeviceInfo;
- (void)setDeviceInfo;
- (void)reset;
- (void)setupBleDevice:(BleDevice *)device;
@end


#endif /* J2203Device_h */
