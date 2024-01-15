//
//  ranix_common_header.h
//  Ble SDK Demo
//
//  Created by yang sai on 2022/4/18.
//

#ifndef ranix_common_header_h
#define ranix_common_header_h

#import "AppDelegate.h"
#import "YCLanguageTools.h"
#import "NewBle.h"
#import "BleSDK.h"
#import "BleSDK_Header.h"
#import "BleSDK_Header.h"

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

#define SERVICE   @"FFF0"
#define SEND_CHAR @"FFF6"
#define REC_CHAR  @"FFF7"
#define DEVICE_ID @"ABCDEFabcdef0123456789"
#define DEVICE_NAME @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 "
#define TEMPERATURE @"0123456789-"


/*状态栏和导航栏总高度*/
#define kNavBarAndStatusBarHeight (CGFloat)(kIs_iPhoneX?(88.0):(64.0))

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height
#define Proportion [UIScreen mainScreen].bounds.size.width/375.0

#define RGBA(a,b,c,d) [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:d]

#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX Width >=375.0f && Height >=812.0f&& kIs_iphone
/*状态栏高度*/
#define kStatusBarHeight (CGFloat)(kIs_iPhoneX?(44.0):(20.0))

#define UserDefaults [NSUserDefaults standardUserDefaults]
#define writeLogs(logs,fileName)   NSLog(logs)
#define  LocalForkey(key)     [[YCLanguageTools shareInstance] locatizedStringForkey:key]
#endif /* PrefixHeader_pch */
