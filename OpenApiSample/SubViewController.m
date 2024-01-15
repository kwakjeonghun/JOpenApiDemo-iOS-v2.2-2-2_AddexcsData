//
//  SubViewController.m
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 12..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#import "AppDelegate.h"
#import "SubViewController.h"
#import "SettingController.h"
#import "CommandController.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>

//#import "HealthMaxDevice.h"
#import "J2203Device.h"

@interface SubViewController ()
@property (nonatomic, strong) BleDevice *device;
@end

@implementation SubViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _device = self.bleDevice;
    
    NSLog(@"%@(type: %@)", _device.deviceNm, _device.deviceType);
    [self.DevceNameLabel setText:_device.deviceNm];
    [self.DeviceUuidLabel setText:_device.deviceSN];
    
    NSLog(@"============%lu", [[jBleManager pairedDeviceList] count]);

    jBleManager.centralDelegate = self;
    jBleManager.actionDelegate = self;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setFrame:CGRectMake(0, 0, 32, 32)];
    [self.activityIndicator setCenter:self.view.center];
    self.activityIndicator.hidden = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
}

- (void)showIndicator {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideIndicator {
    [self.activityIndicator stopAnimating];
}

#pragma mark JOpenApi JBLEManagerActionDelegate
//페어링 이후 호출 delegate
-(void)jBleActionPairDeviceResult:(BleDevice *)device {
    
    NSLog(@"retDevice : %@", device);
    [self writeLog:[NSString stringWithFormat:@"retDevice : %@", device]];
    
    [JCommon showAlertView:[NSString stringWithFormat:@"Pairing Complete \n name: %@ \n sn: %@ \n type: %@",device.deviceNm,device.deviceSN,device.deviceType]];
    
}

//페어링 실패 delegate
-(void)jBleActionPairDeviceFailed:(NSDictionary<NSString *,id> *)dict
{
    NSLog(@"jBleActionPairDeviceFailed : %@", dict);
}

//데이터 업데이트 이후 호출 delegate
-(void)jBleActionSyncDataResult:(NSArray<NSDictionary<NSString *,NSString *> *> *)syncData deviceType:(enum JENUMDeviceServiceType)deviceType {
    [self hideIndicator];
    NSLog(@"success to receive data >> %@",syncData);
    [self writeLog:[NSString stringWithFormat:@"syncData : %@", syncData]];
    switch (deviceType) {
        case JENUMDeviceServiceTypePedometer:
            if ([syncData count] > 0) {
                //NSDictionary *dict = [syncData lastObject];
//                [JCommon showAlertView:[NSString stringWithFormat:@"Update Complite %lu",[syncData count]]];
            }
            break;
        case JENUMDeviceServiceTypeBodycompositionmeter:
            
            break;
        case JENUMDeviceServiceTypeBloodpressuremeter:

            break;
        case JENUMDeviceServiceTypeBloodsugarmeter:
            
            break;
            
        default:
            break;
    }
}

//데이터 업데이트 실패 delegate
-(void)jBleActionSyncDataFailed:(NSDictionary<NSString *,id> *)dict
{
    NSLog(@"jBleActionSyncDataFailed : %@", dict);
}

#pragma mark JOpenApi CentralManagerDelegate
/***************************************************************************************
 * JOpenApi JBLEManager.timeIntervalForScan에 설정된 시간 이후 스캔한 항목 처리
 * JBLEManager.timeIntervalForScan 기본 7초 설정
 * 스캔된 항목은 [jBleManager searchDeviceList] 변수에 저장
 * peripheral name 항목 값이 없으면 스캔에서 제외
 ***************************************************************************************/
- (void)jBleManagerDidDiscoverScanDevice {

}

//jBleManager.searchUUID 항목에 찾을 uuid를 설정 시 ble scan 후 실행
-(void)jBleManagerDidDiscoverFindDeviceUUID:(CBPeripheral *)peripheral {
    NSLog(@"jBleManagerDidDiscoverFindDeviceUUID === %@",peripheral);
    [jBleManager connectPeripheral:peripheral option:nil];
}

//jBleManager.activePeripheral 변수에 현재 connect된 peripheral 정보저장 후 실행
-(void)jBleManagerDidConnect:(CBPeripheral *)peripheral {
    NSString *deviceNm = [peripheral name];
    NSLog(@"jBleManagerDidConnect peripheral === %@",peripheral);
    NSLog(@"jBleManagerDidConnect deviceNm === %@,type=%@",deviceNm,@([jBleManager deviceServiceType]));
    switch ([jBleManager deviceServiceType]) {
        case JENUMDeviceServiceTypePedometer:{
            NSLog(@"JENUMDeviceServiceTypePedometer");

            J2203Device *demoDevice=[J2203Device sharedInstance];
            [demoDevice setupBleDevice:_device];
            [demoDevice reset];
            [demoDevice readSyncData];
//            [demoDevice execute:JENUMCommandClassifyBAND_EXEC_SYNCDATA args:nil];

        }break;
        case JENUMDeviceServiceTypeBodycompositionmeter:
            NSLog(@"JENUMDeviceServiceTypeBodycompositionmeter");
            
            break;
        case JENUMDeviceServiceTypeBloodpressuremeter:
            NSLog(@"JENUMDeviceServiceTypeBloodpressuremeter");

            break;
        case JENUMDeviceServiceTypeBloodsugarmeter:
            NSLog(@"JENUMDeviceServiceTypeBloodsugarmeter");
            break;
            
        default:{

        }
            break;
    }

}

-(void)jBleManagerDidDisconnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"jBleManagerDidDisconnectPeripheral peripheral");
    
}

-(void)jBleManagerDidFailToConnect:(CBPeripheral *)peripheral {
    NSLog(@"jBleManagerDidFailToConnect peripheral");
    
}

-(void)writeLog:(NSString *)logMsg{
    NSString *appendStr = [[_logView text] stringByAppendingString:logMsg];
    [_logView setText:appendStr];
}


- (IBAction)clickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if([button isEqual:self.syncDataButton]){
        
        jBleManager.centralDelegate = self;
        jBleManager.actionDelegate = self;
        if(_device!=nil){
            NSLog(@"retriveConnectPeripheral");
            [self showIndicator];
            [jBleManager retriveConnectPeripheral:_device];
        }
        
        
    }else if([button isEqual:self.setButton]){
        SettingController *viewController = (SettingController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SettingController"];
        viewController.bleDevice = _device;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else if([button isEqual:self.execButton]){
        CommandController *viewController = (CommandController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CommandController"];
        viewController.bleDevice = _device;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
@end
