//
//  SettingController.h
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 12..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>

//@interface SettingController : UIViewController
@interface SettingController : UIViewController<JBLEManagerCentralDelegate, JBLEManagerActionDelegate, UITextFieldDelegate>
@property (nonatomic, strong) BleDevice *bleDevice;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UISegmentedControl *handMode;
@property (weak, nonatomic) IBOutlet UISegmentedControl *screenMode;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notiTel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notiSms;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notiSns;
@property (weak, nonatomic) IBOutlet UISegmentedControl *turnOnMode;
@property (weak, nonatomic) IBOutlet UISegmentedControl *autoEndMode;
@property (weak, nonatomic) IBOutlet UITextField *targetWalk;
@property (weak, nonatomic) IBOutlet UITextField *targetHr;
@property (weak, nonatomic) IBOutlet UISegmentedControl *exScreenMode;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeFormat;


@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)clickButton:(id)sender;

- (IBAction)textFieldReturn:(id)sender;
@end
