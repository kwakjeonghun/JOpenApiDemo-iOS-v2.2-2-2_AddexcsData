//
//  CBPeripheral+Extensions.h
//  JOpenApi
//
//  Created by bongpro on 2017. 8. 18..
//  Copyright © 2017년 thejoin. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral(com_megster_ble_extension)

@property (nonatomic, retain) NSDictionary *advertising;
@property (nonatomic, retain) NSNumber *advertisementRSSI;

-(void)setAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber*)rssi;
-(NSDictionary *)asDictionary;
-(NSString *)uuidAsString;

@end
