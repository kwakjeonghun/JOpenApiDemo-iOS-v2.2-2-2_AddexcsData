#import "AppDelegate.h"
#import "MainViewController.h"
#import "SubViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>

#import "J2203Device.h"
#import "NewBle.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _sections = [[NSArray alloc] initWithObjects:@"Paired Device List", @"Search Device List", nil];
    
    jBleManager = [[JBLEManager alloc] init];
    [jBleManager controlSetup];
    jBleManager.centralDelegate = self;
    jBleManager.actionDelegate = self;
    
    // 혈압 스캔 서비스 타입 설정

    [[jBleManager jUtilsDeviceInfo] setJBleDeviceInfo:JENUMDeviceServiceTypePedometer
                                             typeList:[[NSArray alloc] initWithObjects:@"4A43", nil]
                                             nameList:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                       [[NSArray alloc] initWithObjects:@"J2203", nil], @"J2203 E041"
                                                       , nil]];
    
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
    
    [dict setValue:@"L" forKey:JConstantsCoreData.DEVICE_USER_KEY_HANDMODE];
    [dict setValue:@"H" forKey:JConstantsCoreData.DEVICE_USER_KEY_SCREENMODE];
    [dict setValue:@"N" forKey:JConstantsCoreData.DEVICE_USER_KEY_NOTITEL];
    [dict setValue:@"N" forKey:JConstantsCoreData.DEVICE_USER_KEY_NOTISMS];
    [dict setValue:@"N" forKey:JConstantsCoreData.DEVICE_USER_KEY_NOTISNS];
    [dict setValue:@"N" forKey:JConstantsCoreData.DEVICE_USER_KEY_TURNONMODE];
    [dict setValue:@"10000" forKey:JConstantsCoreData.DEVICE_USER_KEY_TARGETWALK];
    [dict setValue:@"145" forKey:JConstantsCoreData.DEVICE_USER_KEY_TARGETHR];
    [dict setValue:@"Y" forKey:JConstantsCoreData.DEVICE_USER_KEY_AUTOENDMODE];
    [dict setValue:@"W" forKey:JConstantsCoreData.DEVICE_USER_KEY_EXSCREENMODE];
    [dict setValue:@"F2" forKey:JConstantsCoreData.DEVICE_USER_KEY_TIMEFORMAT];
    
    jBleManager.activeDeviceUser = [DeviceUser createDeviceUserWithUserInfo:dict inManagedObjectContext:[jBleManager.jDatabaseManager getManagedContext]];

    [jBleManager loadFromCoreData];
}


#pragma mark JOpenApi JBLEManagerActionDelegate
//페어링 이후 호출 delegate
-(void)jBleActionPairDeviceResult:(BleDevice *)device {
    
    NSLog(@"retDevice : %@", device);
    
    [JCommon showAlertView:[NSString stringWithFormat:@"Pairing Complete \n name: %@ \n sn: %@ \n type: %@ \n",device.deviceNm,device.deviceSN,device.deviceType]];
    
    [[self mainTableView] reloadData];
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
            if ([syncData count] > 0) {
                NSDictionary *dict = [syncData lastObject];
                [JCommon showAlertView:[NSString stringWithFormat:@"Update Complite \n MEASR_DE: %@ \n MEASR_TM: %@ \n BLOOD_PRESS_MAX: %@ \n BLOOD_PRESS_MIN: %@ \n PULSE: %@",[dict valueForKey:@"MEASR_DE"],[dict valueForKey:@"MEASR_TM"],[dict valueForKey:@"BLOOD_PRESS_MAX"],[dict valueForKey:@"BLOOD_PRESS_MIN"],[dict valueForKey:@"PULSE"]]];
            }
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
    NSLog(@"jBleManagerDidDiscoverScanDevice");
    [[self mainTableView] reloadData];
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
            //제조사 구현 클래스의 인스턴스 생성
            J2203Device *demoDevice=[J2203Device sharedInstance];
            [demoDevice reset];
            [demoDevice pairDevice];
//            [demoDevice execute:JENUMCommandClassifyBAND_EXEC_SETTING args:nil];
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


#pragma mark TableView
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sections objectAtIndex:section];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sections count];
}

//셀 개수
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[jBleManager pairedDeviceList] count];
    }
    else {
        return [[jBleManager searchDeviceList] count];
    }
}

//셀 구성
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"tableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
    
    NSString *label;
    if (indexPath.section == 0) {
        BleDevice *device = [[jBleManager pairedDeviceList] objectAtIndex:indexPath.row];
        label = [NSString stringWithFormat:@"%@(type: %@)", device.deviceNm, device.deviceType];
    }
    else {
        CBPeripheral *peripheral = [[jBleManager searchDeviceList] objectAtIndex:indexPath.row];
        
        label = [NSString stringWithFormat:@"%@(uuid: %@)", peripheral.name, peripheral.identifier.UUIDString];
        
    }
    cell.textLabel.text = label;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    jBleManager.centralDelegate = self;
    jBleManager.actionDelegate = self;
    if (indexPath.section == 0) {
        BleDevice *device = [[jBleManager pairedDeviceList] objectAtIndex:indexPath.row];
        //[jBleManager retriveConnectPeripheral:device];
        
        
        NSLog(@"start SyncView");
        SubViewController *viewController = (SubViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SubViewController"];
        viewController.bleDevice = device;
        
        MainViewController *mainViewController = (MainViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainViewController];
        [nav pushViewController:viewController animated:YES];
        [self presentViewController:nav animated:YES completion:nil];
        
        
        

    }
    else {
        CBPeripheral *peripheral = [[jBleManager searchDeviceList] objectAtIndex:indexPath.row];
        if ([jBleManager checkPairingPeripheral:peripheral]) {
            [jBleManager connectPeripheral:peripheral option:nil];
        } else {
            NSString *message = @"선택하신 장치는 사용 할 수 없는 장치입니다.";
            if ([jBleManager deviceServiceType]) {
                NSString *type = [[jBleManager jUtilsDeviceInfo] getJBleDeviceScanTypeWithNumberToName:[NSNumber numberWithInt:[jBleManager deviceServiceType]]];
                if (type) {
                    message = [NSString stringWithFormat:@"%@ 측정장치는 이미 연결되어 있습니다. 선택하신 장비 사용을 위해 해제 후 다시 진행하세요.",type];
                }
            }
            [JCommon showAlertView:message];
        }
        
    }
   
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"editActionsForRowAtIndexPath");
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"삭제" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.section == 0) {
            [[jBleManager jDatabaseManager] deleteBleDevice:[[jBleManager pairedDeviceList] objectAtIndex:indexPath.row]];
            [jBleManager loadFromCoreData];
            
            [[self mainTableView] reloadData];
        }
    }];
    
    return [[NSArray alloc] initWithObjects:delete, nil];
}

- (IBAction)search:(id)sender {
    [jBleManager setSearchDeviceList:[NSArray new]];
    //jBleManager.searchDeviceList = [[NSArray alloc] init]; setSearchDeviceList와 동일함
    [self.mainTableView reloadData];
    
    NSLog(@"search Bluetooth Device");
    [jBleManager setTimeIntervalForScan:1.0];

    //전체 검색시 사용
    //[jBleManager findBLEPeripheralsWithType:nil option:nil];
    //[jBleManager findBLEPeripheralsWithServices:[[NSArray alloc] initWithObjects:@"fff0", nil] option:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    //장치 종류별 조회시 사용. 장치 종류는 pedometer, bodycomp, bloodpress, bloodsugar 등 4종류가 있다.
    [jBleManager findBLEPeripheralsWithType:@"pedometer" option:nil];
//    [jBleManager findBLEPeripheralsWithMacaddress:@"21:02:02:05:19:DB"];
}


@end
