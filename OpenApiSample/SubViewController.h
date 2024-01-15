//
//  SubViewController.h
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 12..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>

//@interface SubViewController : UIViewController
@interface SubViewController : UIViewController<JBLEManagerCentralDelegate, JBLEManagerActionDelegate>
@property (nonatomic, strong) BleDevice *bleDevice;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UIButton *execButton;
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UIButton *syncDataButton;
@property (weak, nonatomic) IBOutlet UILabel *DevceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *DeviceUuidLabel;
- (IBAction)clickButton:(id)sender;

@end
