//
//  SettingController.m
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 12..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#import "SettingController.h"
#import "AppDelegate.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>
#import "J2203Device.h"


@interface SettingController ()
@property (nonatomic, strong) BleDevice *device;
@end

@implementation SettingController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _device = self.bleDevice;
    NSLog(@"%@(type: %@)", _device.deviceNm, _device.deviceType);
    
    jBleManager.centralDelegate = self;
    jBleManager.actionDelegate = self;
    
    NSLog(@"activeDeviceUser=%@",[jBleManager.activeDeviceUser toString]);

    [jBleManager loadFromCoreData];
    if(jBleManager.activeDeviceUser != nil){

        [_handMode setSelectedSegmentIndex:[@[@"L",@"R"]  indexOfObject:jBleManager.activeDeviceUser.handMode]];
        [_screenMode setSelectedSegmentIndex:[@[@"H",@"P"]  indexOfObject:jBleManager.activeDeviceUser.screenMode]];
        [_notiTel setSelectedSegmentIndex:[@[@"Y",@"N"]   indexOfObject:jBleManager.activeDeviceUser.notiTel]];
        [_notiSms setSelectedSegmentIndex:[@[@"Y",@"N"]   indexOfObject:jBleManager.activeDeviceUser.notiSms]];
        [_notiSns setSelectedSegmentIndex:[@[@"Y",@"N"]   indexOfObject:jBleManager.activeDeviceUser.notiSns]];
        [_turnOnMode setSelectedSegmentIndex:[@[@"Y",@"N"]   indexOfObject:jBleManager.activeDeviceUser.turnOnMode]];
        [_autoEndMode setSelectedSegmentIndex:[@[@"Y",@"N"]   indexOfObject:jBleManager.activeDeviceUser.autoEndMode]];
        [_targetWalk setText:[NSString stringWithFormat:@"%@",jBleManager.activeDeviceUser.targetWalk]] ;
        [_targetHr setText:[NSString stringWithFormat:@"%@",jBleManager.activeDeviceUser.targetHr]] ;
        [_exScreenMode setSelectedSegmentIndex:[@[@"W",@"H"]   indexOfObject:jBleManager.activeDeviceUser.exScreenMode]];
        [_timeFormat setSelectedSegmentIndex:[@[@"F1",@"F2"]   indexOfObject:jBleManager.activeDeviceUser.timeFormat]];
    }

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
            [demoDevice setDeviceInfo];
                        
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


-(void)getDeviceSettingInfo{
    
    //DeviceUser 임시 정보 설정
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:@"00000001" forKey:JConstantsCoreData.DEVICE_USER_KEY_ID];
    [dict setValue:@"00000001" forKey:JConstantsCoreData.DEVICE_USER_KEY_NAME];
    [dict setValue:@"30" forKey:JConstantsCoreData.DEVICE_USER_KEY_AGE];
    [dict setValue:@"80" forKey:JConstantsCoreData.DEVICE_USER_KEY_WEIGHT];//kg
    [dict setValue:@"180" forKey:JConstantsCoreData.DEVICE_USER_KEY_HEIGHT];//m
    [dict setValue:@"19880101" forKey:JConstantsCoreData.DEVICE_USER_KEY_BIRTHDAY];//yyyyMMdd
    [dict setValue:@"0" forKey:JConstantsCoreData.DEVICE_USER_KEY_GENDER];//남자 = 0, 여자 = 1
    [dict setValue:@"0" forKey:JConstantsCoreData.DEVICE_USER_KEY_ATHLETELEVEL];
    [dict setValue:@"200" forKey:JConstantsCoreData.DEVICE_USER_KEY_TARGETCALORIE];
    [dict setValue:@"1800" forKey:JConstantsCoreData.DEVICE_USER_KEY_TARGETEXCSTM];//second
    [dict setValue:@"145" forKey:JConstantsCoreData.DEVICE_USER_KEY_MAXHEARTRATE];
    [dict setValue:@"28" forKey:JConstantsCoreData.DEVICE_USER_KEY_INBODY_COMP];
    [dict setValue:@"80" forKey:JConstantsCoreData.DEVICE_USER_KEY_INBODY_WEIGHT];

    [dict setValue:[@[@"L",@"R"] objectAtIndex:_handMode.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_HANDMODE];
    [dict setValue:[@[@"H",@"P"] objectAtIndex:_screenMode.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_SCREENMODE];
    [dict setValue:[@[@"Y",@"N"] objectAtIndex:_notiTel.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_NOTITEL];
    [dict setValue:[@[@"Y",@"N"] objectAtIndex:_notiSms.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_NOTISMS];
    [dict setValue:[@[@"Y",@"N"] objectAtIndex:_notiSns.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_NOTISNS];
    [dict setValue:[@[@"Y",@"N"] objectAtIndex:_turnOnMode.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_TURNONMODE];
    [dict setValue:[_targetWalk text] forKey:JConstantsCoreData.DEVICE_USER_KEY_TARGETWALK];
    [dict setValue:[_targetHr text] forKey:JConstantsCoreData.DEVICE_USER_KEY_TARGETHR];
    [dict setValue:[@[@"Y",@"N"] objectAtIndex:_autoEndMode.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_AUTOENDMODE];
    [dict setValue:[@[@"W",@"H"] objectAtIndex:_exScreenMode.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_EXSCREENMODE];
    [dict setValue:[@[@"F1",@"F2"] objectAtIndex:_timeFormat.selectedSegmentIndex] forKey:JConstantsCoreData.DEVICE_USER_KEY_TIMEFORMAT];

    jBleManager.activeDeviceUser = [DeviceUser createDeviceUserWithUserInfo:dict inManagedObjectContext:[jBleManager.jDatabaseManager getManagedContext]];
    
    [jBleManager loadFromCoreData];
    
}

- (IBAction)clickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if([button isEqual:self.saveButton]){
        if(_device!=nil){
            [self showIndicator];
            [jBleManager cancelConnection];
            [self getDeviceSettingInfo];
            [jBleManager retriveConnectPeripheral:_device];
        }
        
    }
}

- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([_targetHr isFirstResponder] && [touch view] != _targetHr)
    {
        [_targetHr resignFirstResponder];
    }
    else if ([_targetWalk isFirstResponder] && [touch view] != _targetWalk)
    {
        [_targetWalk resignFirstResponder];
    }
}
@end
