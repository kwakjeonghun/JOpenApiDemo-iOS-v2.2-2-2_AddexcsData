//
//  CommandController.m
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 12..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#import "CommandController.h"
#import "AppDelegate.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>
#import "J2203Device.h"

@interface CommandController ()
@property (nonatomic, strong) BleDevice *device;
@property (nonatomic) int execCmd;
@property (nonatomic, strong) NSMutableArray *execArgs;
@end

@implementation CommandController
- (void)viewDidLoad {
    [super viewDidLoad];

    _device = self.bleDevice;
    NSLog(@"%@(type: %@)", _device.deviceNm, _device.deviceType);
    
    jBleManager.centralDelegate = self;
    jBleManager.actionDelegate = self;

    NSLog(@"activeDeviceUser=%@",[jBleManager.activeDeviceUser toString]);
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setFrame:CGRectMake(0, 0, 32, 32)];
    [self.activityIndicator setCenter:self.view.center];
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
}

#pragma mark JOpenApi JBLEManagerActionDelegate
//페어링 이후 호출 delegate
-(void)jBleActionPairDeviceResult:(BleDevice *)device {
    
    NSLog(@"retDevice : %@", device);
    
    [JCommon showAlertView:[NSString stringWithFormat:@"Pairing Complite \n name: %@ \n sn: %@ \n type: %@",device.deviceNm,device.deviceSN,device.deviceType]];
    
}

//페어링 실패 delegate
-(void)jBleActionPairDeviceFailed:(NSDictionary<NSString *,id> *)dict
{
    NSLog(@"jBleActionPairDeviceFailed : %@", dict);
}

//데이터 업데이트 이후 호출 delegate
-(void)jBleActionSyncDataResult:(NSArray<NSDictionary<NSString *,NSString *> *> *)syncData deviceType:(enum JENUMDeviceServiceType)deviceType {
    NSLog(@"success to receive data >> %@",syncData);
    switch (deviceType) {
        case JENUMDeviceServiceTypePedometer:
            
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

-(void)jBleActionUIChangeUpdateText:(NSString *)string
{
    [self hideIndicator];
    NSLog(@"jBleActionUIChangeUpdateText : %@", string);
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
    NSLog(@"jBleManagerDidConnect deviceNm === %@,type=%@",deviceNm,@([jBleManager deviceServiceType]));
    switch ([jBleManager deviceServiceType]) {
        case JENUMDeviceServiceTypePedometer:{
            NSLog(@"JENUMDeviceServiceTypePedometer");

            J2203Device *demoDevice=[J2203Device sharedInstance];
            [demoDevice setupBleDevice:_device];
            [demoDevice reset];
            [demoDevice execute:self.execCmd args:self.execArgs];
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

- (void)showIndicator {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideIndicator {
    [self.activityIndicator stopAnimating];
}


- (IBAction)clickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.execCmd = JENUMCommandClassifyBAND_EXEC_NONE;
    self.execArgs = [[NSMutableArray alloc] init];
    
    jBleManager.centralDelegate = self;
    jBleManager.actionDelegate = self;
    
    if ([button isEqual:self.btnManualMode]) {
        self.execCmd = JENUMCommandClassifyBAND_EXEC_MANU_ST_MODE;
    }
    else if ([button isEqual:self.btnNotiTel]) {
        self.execCmd = BAND_EXEC_CALL_MODE;
        [self.execArgs addObject:@"RINGING"];
        [self.execArgs addObject:@"010-8014-5175"];
        [self.execArgs addObject:@"지역보건)안성희쌤"];
    }
    else if ([button isEqual:self.btnNotiTelEnd]) {
        self.execCmd = BAND_EXEC_CALL_MODE;
        [self.execArgs addObject:@"IDLE"];
        [self.execArgs addObject:@"010-8014-5175"];
        [self.execArgs addObject:@"지역보건)안성희쌤"];
    }
    else if ([button isEqual:self.btnNotiSms]) {
        self.execCmd = BAND_EXEC_SMS_MODE;
        [self.execArgs addObject:@"boram"];
        [self.execArgs addObject:@"1111"];
        [self.execArgs addObject:@"테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다."];
    }
    else if ([button isEqual:self.btnNotiSns]) {
        self.execCmd = BAND_EXEC_SNS_MODE;
        [self.execArgs addObject:@"boram"];
        [self.execArgs addObject:@"김상운"];
        [self.execArgs addObject:@"테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다.테스트 중입니다."];
    }
    
    if(_device!=nil){
        NSLog(@"retriveConnectPeripheral");
        [self showIndicator];
        [jBleManager cancelConnection];
        [jBleManager retriveConnectPeripheral:_device];
    }
}
@end
