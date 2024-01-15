//
//  CommandController.h
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 12..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>

//@interface CommandController : UIViewController
@interface CommandController : UIViewController<JBLEManagerCentralDelegate, JBLEManagerActionDelegate>
@property (nonatomic, strong) BleDevice *bleDevice;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnManualMode;
@property (weak, nonatomic) IBOutlet UIButton *btnNotiTel;
@property (weak, nonatomic) IBOutlet UIButton *btnNotiTelEnd;
@property (weak, nonatomic) IBOutlet UIButton *btnNotiSms;
@property (weak, nonatomic) IBOutlet UIButton *btnNotiSns;


- (IBAction)clickButton:(id)sender;

@end
