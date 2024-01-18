//
//  J2203Device.m
//  OpenApiSample
//
//  Created by 더조인 on 2018. 6. 14..
//  Copyright © 2018년 thejoin. All rights reserved.
//

#import "AppDelegate.h"
#import "J2203Device.h"
#import "MyDate.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <JOpenApi/JOpenApi-Swift.h>
#import "BleSDK.h"
#import "NewBle.h"

#define TARGET_FUNC_PAIR        0
#define TARGET_FUNC_SYNC        1
#define TARGET_FUNC_GET_DEVICE_INFO 2
#define TARGET_FUNC_SET_DEVICE_INFO 3
#define TARGET_FUNC_EXEC_CALL   4
#define TARGET_FUNC_EXEC_SMS    5
#define TARGET_FUNC_EXEC_SNS    6

#define DEVICE_DATA_MODE_START      0
#define DEVICE_DATA_MODE_CONTINUE   2

@interface J2203Device() <JBLEManagerPeripheralDelegate, JBLEManagerDeviceControllDelegate, JOTAManagerDelegate>{
}

@property (nonatomic, strong) BleDevice *bleDevice;
@property (nonatomic,strong) NSMutableDictionary *deviceInfo;
@property (nonatomic) BOOL isDiscovered;
@property (nonatomic) int targetFunc;
@property (nonatomic) int dataCount;
@property (nonatomic, strong) NSString *strText;
@property (nonatomic, strong) HeartRateArr *arrHeartRate;
@property (nonatomic, strong) Act *activity;
@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) NSArray *execArgs;
//내가 추가한 것
@property (nonatomic, strong) ExcsStatus *excsStatus;
@property (nonatomic, strong) HeartRateArr *arrDynamic;
@end

@implementation J2203Device

/***************************** 필수 구현 함수 *********************************/
+ (instancetype)sharedInstance {
    static J2203Device *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self alloc] init] initDeviceContext];
    });
    return instance;
}

- (J2203Device*)initDeviceContext {
    
    NSLog(@"PedometerDevice.initDeviceContext");
    
    self.deviceInfo = [NSMutableDictionary new];
    self.arrHeartRate = [[HeartRateArr alloc] init];
    self.activity = [[Act alloc] init];
    //내가 추가한 것
    self.excsStatus = [[ExcsStatus alloc] init];
    self.arrDynamic = [[HeartRateArr alloc] init];
    //jBleManager의 peripheralDelegate를 해당 클래스로 변경
    jBleManager.peripheralDelegate = self;
    
    //jBleManager의 deviceControllDelegate를 해당 클래스로 변경
    jBleManager.deviceControllDelegate = self;
    self.isDiscovered = NO;
    return self;
}

- (void)setupBleDevice:(BleDevice *)device {
    self.bleDevice = device;
}

- (void)reset {
    self.isDiscovered = NO;
}

- (void)discoveryService{
    self.isDiscovered = YES;
    NSLog(@"PedometerDevice.discoveryService");
    //DeviceUser 정보 가져와서 셋팅
    if(jBleManager.activeDeviceUser  != nil){
        NSLog(@"PedometerDevice.activeDeviceUser=%@",[jBleManager.activeDeviceUser toString]);
        
    }
    jBleManager.peripheralDelegate = self;
    jBleManager.deviceControllDelegate = self;
    [jBleManager.activePeripheral discoverServices:nil];
}

- (BOOL)checkDiscoverService {
    //    if (self.isDiscovered == NO) {
    //        return NO;
    //    }
    if ([jBleManager activePeripheral] == nil) {
        return NO;
    }
    if  ([jBleManager activePeripheral].services.count > 0) {
        return YES;
    }
    return NO;
}

- (void)initHeartRate {
    [self.arrHeartRate setStartTm:@""];
    [self.arrHeartRate setStartDe:@""];
    [self.arrHeartRate setCollectTime:@5];
    [self.arrHeartRate setMaxHeartRate:@0];
    [self.arrHeartRate setMinHeartRate:@0];
    [self.arrHeartRate setAvgHeartRate:@0];
    [self.arrHeartRate setHeartRateCnt:@0];
    [self.arrHeartRate setHeartRateList:@""];
}

- (void)initAct {
    [self.activity setDeviceNm:@""];
    [self.activity setActCnt:@0];
    [self.activity setActCal:@0];
    [self.activity setActDstc:@0];
    [self.activity setTotActCnt:@0];
    [self.activity setTotActCal:@0];
    [self.activity setTotActDstc:@0];
    [self.activity setTotActTm:@0];
    [self.activity setMeasrDe:@""];
    [self.activity setMeasrTm:@""];
    [self.activity setUserId:@"testuser"];
    [self.activity setSendYn:@"N"];
    [self.activity setBroadcastId:@""];
    [self.activity setMeasrHour:@""];
}
//내가 추가한 것
- (void)initExcs {
    [self.excsStatus setExcsStartDe:@""];
    [self.excsStatus setExcsStartTm:@""];
    [self.excsStatus setExcsEndDe:@""];
    [self.excsStatus setExcsEndTm:@""];
    [self.excsStatus setExcsCnt:@0];
    [self.excsStatus setExcsDstc:@0];
    [self.excsStatus setExcsTm:@0];
    [self.excsStatus setRestTm:@0];
    [self.excsStatus setMaxCal:@0];
    [self.excsStatus setTotCal:@0];
    [self.excsStatus setMaxPace:@0];
    [self.excsStatus setAvgPace:@0];
    [self.excsStatus setMaxAltitude:@0];
    [self.excsStatus setAvgAltitude:@0];
    [self.excsStatus setExcsClf:@(Run)];
    [self.excsStatus setMaxPitch:@0];
    [self.excsStatus setAvgPitch:@0];
    [self.excsStatus setMaxHeartRate:@0];
    [self.excsStatus setAvgHeartRate:@0];
    [self.excsStatus setMinHeartRate:@0];
    [self.excsStatus setAutoManuClf:@"M"];
}
//내가 추가한 것
- (void)initDynamicHR {
    [self.arrDynamic setStartTm:@""];
    [self.arrDynamic setStartDe:@""];
    [self.arrDynamic setCollectTime:@5];
    [self.arrDynamic setMaxHeartRate:@0];
    [self.arrDynamic setMinHeartRate:@0];
    [self.arrDynamic setAvgHeartRate:@0];
    [self.arrDynamic setHeartRateCnt:@0];
    [self.arrDynamic setHeartRateList:@""];
}

- (void)readSyncData {
    self.targetFunc = TARGET_FUNC_SYNC;
    if ([self checkDiscoverService] == NO) {
        [self discoveryService];
        return;
    }
    NSLog(@"PedometerDevice.readSyncData");
    self.strText = @"";
    
    self.dataCount = 0;
    self.listData = [[NSMutableArray alloc] init];
    [self initAct];
    [self initHeartRate];
    //내가 추가한 것
    [self initExcs];
    [self initDynamicHR];
    
    [self setTime];
    
}

- (void)setTime {
    NSDate *date = [NSDate date];
    
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents * conponent = [cal components:unitFlags fromDate:date];
    MyDeviceTime deviceTime;
    deviceTime.year  = (int)[conponent year];
    deviceTime.month = (int)[conponent month];
    deviceTime.day = (int)[conponent day];
    deviceTime.hour = (int)[conponent hour];
    deviceTime.minute = (int)[conponent minute];
    deviceTime.second = (int)[conponent second];
    NSMutableData * data = [[BleSDK sharedManager] SetDeviceTime:deviceTime];
    NSLog(@"data : %@", data);
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[NewBle sharedManager].activityPeripheral data:data];
}

- (void)readDetailAct: (int)mode {
    NSLog(@"PedometerDevice.readDetailAct");
    self.strText = @"";
    NSData * data = [[BleSDK sharedManager] GetDetailActivityDataWithMode:mode withStartDate:nil];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}

- (void)readHeartRate: (int)mode {
    NSLog(@"PedometerDevice.readHeartRate");
    self.strText = @"";
    NSData * data = [[BleSDK sharedManager] GetSingleHRDataWithMode:mode withStartDate:nil];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}
//내가 추가한 것
- (void)readExerciseData: (int)mode {
    NSLog(@"PedometerDevice.readExerciseData");
    self.strText = @"";
    NSData * data = [[BleSDK sharedManager] GetActivityModeDataWithMode:mode withStartDate:nil];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}
//내가 추가한 것
- (void)readDynamicHRData: (int)mode {
    NSLog(@"PedometerDevice.readDynamicHRData");
    self.strText = @"";
    NSData * data = [[BleSDK sharedManager] GetContinuousHRDataWithMode:mode withStartDate:nil];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}

- (void)execCall: (NSArray *)args {
    self.targetFunc = TARGET_FUNC_EXEC_CALL;
    self.execArgs = args;
    if ([self checkDiscoverService] == NO) {
        [self discoveryService];
        return;
    }
    NSLog(@"PedometerDevice.execCall");
    self.strText = @"";
    
    NSString *mode = args[0];
    MyNotifier notifier;
    
    notifier.title = args[2];
    notifier.info = args[1];
    if ([mode isEqualToString:@"RINGING"]) {
        notifier.type = 0;
    }
    else {
        notifier.type = 255;
    }
    
    NSData *data = [[BleSDK sharedManager] SetNotifyData:notifier];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}

- (void)execSMS: (NSArray *)args {
    self.targetFunc = TARGET_FUNC_EXEC_SMS;
    self.execArgs = args;
    if ([self checkDiscoverService] == NO) {
        [self discoveryService];
        return;
    }
    NSLog(@"PedometerDevice.execSMS");
    self.strText = @"";
    
    MyNotifier notifier;
    
    notifier.title = args[0];
    notifier.info = args[2];
    notifier.type = 1;
    
    NSData *data = [[BleSDK sharedManager] SetNotifyData:notifier];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}

- (void)execSNS: (NSArray *)args {
    self.targetFunc = TARGET_FUNC_EXEC_SNS;
    self.execArgs = args;
    if ([self checkDiscoverService] == NO) {
        [self discoveryService];
        return;
    }
    NSLog(@"PedometerDevice.execSNS");
    self.strText = @"";
    
    MyNotifier notifier;
    
    notifier.title = args[1];
    notifier.info = args[2];
    notifier.type = 12;
    
    NSData *data = [[BleSDK sharedManager] SetNotifyData:notifier];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}

- (void)readDeviceInfo {
    self.targetFunc = TARGET_FUNC_GET_DEVICE_INFO;
    if ([self checkDiscoverService] == NO) {
        [self discoveryService];
        return;
    }
    NSLog(@"PedometerDevice.readDeviceInfo");
    self.strText = @"";
    NSMutableData * data = [[BleSDK sharedManager] GetDeviceInfo];
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}

- (void)setDeviceInfo {
    self.targetFunc = TARGET_FUNC_SET_DEVICE_INFO;
    if ([self checkDiscoverService] == NO) {
        [self discoveryService];
        return;
    }
    NSLog(@"PedometerDevice.setDeviceInfo");
    self.strText = @"";
    
    NSMutableData *data;
    MyDeviceInfo deviceInfo;
    // deviceInfo setting
    if (jBleManager.activeDeviceUser != nil) {
        //        // 밴드 회전
        //        if ([jBleManager.activeDeviceUser.turnOnMode isEqual: @"Y"]) {
        //            deviceInfo.wristOn = 1;
        //        }
        //        else {
        //            deviceInfo.wristOn = 0;
        //        }
        //        // 전화 알림
        //        if ([jBleManager.activeDeviceUser.notiTel isEqual: @"Y"]) {
        //            deviceInfo.notificationType.call = 1;
        //        }
        //        else {
        //            deviceInfo.notificationType.call = 0;
        //        }
        //        // sms 알림
        //        if ([jBleManager.activeDeviceUser.notiSms isEqual: @"Y"]) {
        //            deviceInfo.notificationType.SMS = 1;
        //        }
        //        else {
        //            deviceInfo.notificationType.SMS = 0;
        //        }
        //        // 타임표시 설정
        //        if ([jBleManager.activeDeviceUser.notiSms isEqual: @"F1"]) {
        //            deviceInfo.timeUnit = 0;
        //        }
        //        else {
        //            deviceInfo.timeUnit = 1;
        //        }
        // target walk step
        NSNumber *targetWalk = jBleManager.activeDeviceUser.targetWalk;
        int nTargetWalk = [targetWalk intValue];
        if (nTargetWalk == 0) {
            nTargetWalk = 10000;
        }
        data = [[BleSDK sharedManager] SetStepGoal:nTargetWalk];
    }
    
    [NewBle sharedManager].activityPeripheral = [jBleManager activePeripheral];
    [[NewBle sharedManager] enable];
    [[NewBle sharedManager] writeValue:SERVICE characteristicUUID:SEND_CHAR p:[jBleManager activePeripheral] data:data];
}

- (void)pairDevice {
    self.targetFunc = TARGET_FUNC_PAIR;
    if ([self checkDiscoverService] == NO) {
        [self discoveryService];
        return;
    }
    
    [self.deviceInfo setValue:@"W83838383838" forKey:JConstantsCoreData.BLEDEVICE_KEY_DEVICESN];
    [self.deviceInfo setValue:@"V3.7.8.0_2023/12/21" forKey:JConstantsCoreData.BLEDEVICE_KEY_FIRMWAREVERSION];
    [self.deviceInfo setValue:@"J2203" forKey:JConstantsCoreData.BLEDEVICE_KEY_MODELNUMBER];
    [jBleManager pairDevice:jBleManager.activePeripheral deviceInfo:self.deviceInfo deviceType:JENUMDeviceServiceTypePedometer];
    
}

- (void)execute:(unsigned int)cmd args:(NSArray *)args{
    long cnt =[args count];
    
    if(cmd == JENUMCommandClassifyBAND_EXEC_SETTING){
        NSLog(@"PedometerDevice.BAND_EXEC_SETTING");
        //todo 사용자 정보 및 디바이스 부가기능 셋팅 후 콜백 호출
        // JENUMCommandClassifyBAND_EXEC_SYNCDATA 를 제외하고 jBleManager pairDevice 호출
        if(jBleManager.activeDeviceUser  != nil){
            NSLog(@"PedometerDevice.activeDeviceUser=%@",[jBleManager.activeDeviceUser toString]);
            NSLog(@"PedometerDevice.activeDeviceUser.handMode=%@",jBleManager.activeDeviceUser.handMode);
            NSLog(@"PedometerDevice.activeDeviceUser.screenMode=%@",jBleManager.activeDeviceUser.screenMode);
            NSLog(@"PedometerDevice.activeDeviceUser.notiTel=%@",jBleManager.activeDeviceUser.notiTel);
            NSLog(@"PedometerDevice.activeDeviceUser.notiSms=%@",jBleManager.activeDeviceUser.notiSms);
            NSLog(@"PedometerDevice.activeDeviceUser.notiSns=%@",jBleManager.activeDeviceUser.notiSns);
            NSLog(@"PedometerDevice.activeDeviceUser.turnOnMode=%@",jBleManager.activeDeviceUser.turnOnMode);
            NSLog(@"PedometerDevice.activeDeviceUser.autoEndMode=%@",jBleManager.activeDeviceUser.autoEndMode);
            NSLog(@"PedometerDevice.activeDeviceUser.targetWalk=%@",jBleManager.activeDeviceUser.targetWalk);
            NSLog(@"PedometerDevice.activeDeviceUser.targetHr=%@",jBleManager.activeDeviceUser.targetHr);
            NSLog(@"PedometerDevice.activeDeviceUser.exScreenMode=%@",jBleManager.activeDeviceUser.exScreenMode);
            NSLog(@"PedometerDevice.activeDeviceUser.timeFormat=%@",jBleManager.activeDeviceUser.timeFormat);
        }
        
    }else if(cmd == JENUMCommandClassifyBAND_EXEC_SYNCDATA){
        NSLog(@"PedometerDevice.BAND_EXEC_SYNCDATA");
        //todo 데이터 수신 및 변환작업 후 콜백 호출
        // JENUMCommandClassifyBAND_EXEC_SYNCDATA 는 jBleManager deviceSyncData 호출
        //        [jBleManager deviceSyncData:nil deviceType:JENUMDeviceServiceTypeUnknown];
        [self readSyncData];
    }else if(cmd == JENUMCommandClassifyBAND_EXEC_OTA_MODE){
        NSLog(@"PedometerDevice.BAND_EXEC_OTA_MODE");
        //todo 디바이스 명령어 전달 기능 작업 후 콜백 호출
        if(cnt > 0){
            NSLog(@"Version=%@",args[0]);
        }
        
        
        //1. 현재 디바이스의 firmware버전 가져오기
        //2-1. args[0]으로 들어온 버전과 비교하여 firmware버전이 낮을 경우 : 펌웨어 파일 다운로드 실행
        //2-2. args[0]으로 들어온 버전과 비교하여 firmware버전이 같거나 높을 경우 바로 콜백호출하여 종료
        //3. 펌웨어 파일 다운로드 실행 호출
        //     펌웨어 업데이트 파일과 펌웨어 버전정보, 펌웨어 타입정보를 같이 넘겨줘야 합니다.
        //     예)  PedometerDemoFirmwareUpdate_A.bin   updateVerion=1.0  type=A type
        //          PedometerDemoFirmwareUpdate_B.bin   updateVerion=1.0  type=B type
        //4. 펌웨어 업데이트 실행
        //4. 펌웨어 업데이트 완료 후 콜백호출하여 종료
        
        NSString *version = args[0];
        NSString *type = @"A";
        JOTAManager *jotaManager = [[JOTAManager alloc] init];
        [jotaManager execWithUrl:@"http://thejoin.co.kr/OTATest.bin" deviceInfo:self.deviceInfo version:version type:type delegate:self];
        //[jotaManager execWithDeviceInfo:self.deviceInfo version:version type:type delegate:self];
        
        
        //[jBleManager pairDevice:jBleManager.activePeripheral deviceInfo:self.deviceInfo deviceType:JENUMDeviceServiceTypePedometer];
        
    }
    else if (cmd == JENUMCommandClassifyBAND_EXEC_MANU_ST_MODE) {
        NSLog(@"PedometerDevice.BAND_EXEC_MANUAL_ST_MODE");
    }
    else if (cmd == BAND_EXEC_CALL_MODE) {
        NSLog(@"PedometerDevice.BAND_EXEC_CALL_MODE");
        [self execCall:args];
    }
    else if (cmd == BAND_EXEC_SMS_MODE) {
        NSLog(@"PedometerDevice.BAND_EXEC_SMS_MODE");
        [self execSMS:args];
    }
    else if (cmd == BAND_EXEC_SNS_MODE) {
        NSLog(@"PedometerDevice.BAND_EXEC_SNS_MODE");
        [self execSNS:args];
    }
    else{
        NSLog(@"PedometerDevice.%d",cmd);
    }
    
    //[jBleManager.activePeripheral discoverServices:nil];
    
}

-(void)parseRecvData: (NSData *)data {
    NSLog(@"PedometerDevice.parseRecvData");
    DeviceData * deviceData = [[DeviceData alloc] init];
    deviceData = [[BleSDK sharedManager] DataParsingWithData:data];
    BOOL end = deviceData.dataEnd;
    
    if(deviceData.dataType == SetDeviceTime) {
        //기존 순서 1. Single HR 2. Act 3. Excs 4. Dynamic HR
        [self readHeartRate:DEVICE_DATA_MODE_START];
    }
    else if(deviceData.dataType == SetNotify) {
        [jBleManager changeUpdateText:@"SetNotify"];
    }
    else if(deviceData.dataType == SetDeviceGoal) {
        [jBleManager changeUpdateText:@"SetDeviceGoal"];
    }
    else if(deviceData.dataType == TotalActivityData) {
        NSDictionary * dicData = deviceData.dicData;
        NSArray * arrayTotalActivityData = dicData[@"arrayTotalActivityData"];
        for (int i = 0; i< arrayTotalActivityData.count; i++) {
            NSString * strTemp;
            NSDictionary * dic = arrayTotalActivityData[i];
            strTemp = [NSString stringWithFormat:@"date : %@\ntotalStep : %@\ntotalExerciseMinutes : %@ %@\ntotalDistance : %@ %@\ntotalCalories : %@ %@\ndailyGoal : %@\ntotalActiveMinutes : %@ %@\n\n\n",dic[@"date"],dic[@"step"],dic[@"exerciseMinutes"],LocalForkey(@"分钟"),dic[@"distance"],LocalForkey(@"千米"),dic[@"calories"],LocalForkey(@"千卡"),dic[@"goal"],dic[@"activeMinutes"],LocalForkey(@"分钟")];
            self.strText  = [self.strText stringByAppendingString:strTemp];
            
            NSLog(@"TotalActivityData : %@", self.strText);
            Act *act = [[Act alloc] init];
            
            NSString *strDate = dic[@"date"];
            NSDate *date = [[MyDate sharedManager] dateFromString:strDate WithStringFormat:@"YYYY.MM.dd"];
            
            NSString *strMeasrDe = [[MyDate sharedManager] stringFromDate:date WithStringFormat:@"YYYYMMdd"];
            [act setMeasrDe:strMeasrDe];
            [act setMeasrTm:@"090000"];
            
            NSString *strStep = dic[@"step"];
            int nStep = [strStep intValue];
            [act setActCnt:[NSNumber numberWithInt:nStep]];
            [act setTotActCnt:[NSNumber numberWithInt:nStep]];
            
            NSString *strMin = dic[@"activeMinutes"];
            int nActTm = [strMin intValue] * 60;
            [act setActTm:[NSNumber numberWithInt:nActTm]];
            [act setTotActTm:[NSNumber numberWithInt:nActTm]];
            
            NSString *strDist = dic[@"distance"];
            float fDist = [strDist floatValue];
            int nDist = fDist * 1000;
            [act setActDstc:[NSNumber numberWithInt:nDist]];
            [act setTotActDstc:[NSNumber numberWithInt:nDist]];
            
            NSString *strCalories = [NSString stringWithFormat:@"%@", dic[@"calories"]];
            double fCalories = [strCalories doubleValue];
            fCalories = round(fCalories * 100) / 100;
            [act setActCal:[NSNumber numberWithDouble:fCalories]];
            [act setTotActCal:[NSNumber numberWithDouble:fCalories]];
            
            [jBleManager deviceSyncData:act deviceType:JENUMDeviceServiceTypePedometer];
            if (end == YES) {
                // HeartRate 가져오기
                [self readHeartRate:0];
                return;
            }
        }
    }
    else if(deviceData.dataType == DetailActivityData) {
        NSDictionary * dicData = deviceData.dicData;
        NSArray * arrayStaticHR = dicData[@"arrayDetailActivityData"];
        self.dataCount += 1;
        [self.listData addObjectsFromArray:arrayStaticHR];
        if (end == YES) {
            [self parseDetailActValues];
        }
        if (self.dataCount == 50) {
            self.dataCount = 0;
            if (end == YES) {
                [self parseDetailActValues];
            }
            else {
                [self readDetailAct:DEVICE_DATA_MODE_CONTINUE];
            }
        }
    }
    else if(deviceData.dataType == StaticHR) {
        NSDictionary * dicData = deviceData.dicData;
        NSArray * arrayStaticHR = dicData[@"arraySingleHR"];
        self.dataCount += 1;
        [self.listData addObjectsFromArray:arrayStaticHR];
        if (end == YES) {
            [self parseStaticHrValues];
        }
        if (self.dataCount == 50) {
            self.dataCount = 0;
            if (end == YES) {
                [self parseStaticHrValues];
            }
            else {
                [self readHeartRate:DEVICE_DATA_MODE_CONTINUE];
            }
        }
        
        //        for (int i = 0; i< arrayStaticHR.count; i++) {
        //            NSString * strTemp;
        //            NSDictionary * dic = arrayStaticHR[i];
        //            strTemp = [NSString stringWithFormat:@"date : %@\nheartbeatPerMinute : %@\n\n\n",dic[@"date"],dic[@"singleHR"]];
        //            self.strText  = [self.strText stringByAppendingString:strTemp];
        //            if (i == 0) {
        //                NSLog(@"StaticHR : %@", self.strText);
        //                NSString *strDate = dic[@"date"];
        //                NSDate *date = [[MyDate sharedManager] dateFromString:strDate WithStringFormat:@"YYYY.MM.dd HH:mm:ss"];
        //                HeartRate *hr = [[HeartRate alloc] init];
        //                [hr setMeasrDe:[[MyDate sharedManager] stringFromDate:date WithStringFormat:@"YYYYMMdd"]];
        //                [hr setMeasrTm:[[MyDate sharedManager] stringFromDate:date WithStringFormat:@"HHmmss"]];
        //                NSNumber *numHr = dic[@"singleHR"];
        //                [hr setHeartRate:[numHr stringValue]];
        //
        //                [jBleManager deviceSyncData:hr deviceType:JENUMDeviceServiceTypePedometer];
        //                return;
        //            }
        //        }
    }
    //내가 추가한 것
    else if(deviceData.dataType == ActivityModeData) {
        NSDictionary * dicData = deviceData.dicData;
        NSArray * arrayStaticHR = dicData[@"arrayActivityModeData"];
        self.dataCount += 1;
        [self.listData addObjectsFromArray:arrayStaticHR];
        if (end == YES) {
            [self parseActivityModeDataValues];
        }
        if (self.dataCount == 50) {
            self.dataCount = 0;
            if (end == YES) {
                [self parseActivityModeDataValues];
            }
            else {
                [self readExerciseData:DEVICE_DATA_MODE_CONTINUE];
            }
        }
    }
    //내가 추가한 것
    else if(deviceData.dataType == DynamicHR) {
        NSDictionary * dicData = deviceData.dicData;
        NSArray * arrayStaticHR = dicData[@"arrayContinuousHR"];
        self.dataCount += 1;
        [self.listData addObjectsFromArray:arrayStaticHR];
        if (end == YES) {
            [self parseDynamicHRDataValues];
        }
        if (self.dataCount == 50) {
            self.dataCount = 0;
            if (end == YES) {
                [self parseDynamicHRDataValues];
            }
            else {
                [self readDynamicHRData:DEVICE_DATA_MODE_CONTINUE];
            }
        }
    }
    else if(deviceData.dataType == SetDeviceInfo) {
        NSLog(@"PedometerDevice.parseRecvData.SetDeviceInfo");
    }
}

- (void)parseStaticHrValues {
    NSString *time = @"";
    NSString *heartValue = @"";
    NSString *hrValArr = @"";
    int avrHr = 0;
    int maxHr = 0;
    int minHr = 200;
    int totHR = 0;
    int hr = 0;
    NSString *last_date = @"";
    NSString *check_date = @"";
    
    NSMutableArray *endTmArray = [[NSMutableArray alloc] init];
    NSMutableArray *arrHR = [[NSMutableArray alloc] init];
    
    if (self.listData.count > 0) {
        NSDictionary *map = self.listData[0];
        NSString *time2 = map[@"date"];
        check_date = [time2 substringWithRange:NSMakeRange(0, 10)];
        last_date = time2;
    }
    
    for (int i = 0; i < self.listData.count; i++) {
        NSDictionary *map = self.listData[i];
        time = map[@"date"];
        heartValue = map[@"singleHR"];
        hr = heartValue.intValue;
        
        NSString *strDate = [time substringWithRange:NSMakeRange(0, 10)];
        if ([strDate isEqualToString:check_date]) {
            [arrHR addObject:[NSNumber numberWithInt:hr]];
        }
    }
    
    for (int k = 0; k < arrHR.count; k++) {
        NSNumber *hr = arrHR[k];
        int nHr = [hr intValue];
        if (maxHr < nHr) {
            maxHr = nHr;
        }
        if (minHr > nHr) {
            minHr = nHr;
        }
        totHR += nHr;
        
        if (k == 0) {
            hrValArr = [NSString stringWithFormat:@"%d", nHr];
        }
        else {
            NSString *strTemp = [NSString stringWithFormat:@",%d", nHr];
            hrValArr = [hrValArr stringByAppendingString:strTemp];
        }
    }
    avrHr = totHR / arrHR.count;
    
    NSArray *arrDate = [last_date componentsSeparatedByString:@" "];
    [self.arrHeartRate setStartTm:[arrDate[1] stringByReplacingOccurrencesOfString:@":" withString:@""]];
    [self.arrHeartRate setStartDe:[arrDate[0] stringByReplacingOccurrencesOfString:@"." withString:@""]];
    [self.arrHeartRate setCollectTime:[NSNumber numberWithInt:5]];
    [self.arrHeartRate setMaxHeartRate:[NSNumber numberWithInt:maxHr]];
    [self.arrHeartRate setMinHeartRate:[NSNumber numberWithInt:minHr]];
    [self.arrHeartRate setAvgHeartRate:[NSNumber numberWithInt:avrHr]];
    [self.arrHeartRate setHeartRateCnt:[NSNumber numberWithInt:arrHR.count]];
    [self.arrHeartRate setHeartRateList:hrValArr];
    
    [jBleManager deviceSyncData:self.arrHeartRate deviceType:JENUMDeviceServiceTypePedometer];
    
    self.dataCount = 0;
    [self.listData removeAllObjects];
    [self readDetailAct:DEVICE_DATA_MODE_START];
}

- (void)parseDetailActValues {
    NSString *measrDe = @"";
    NSString *measrTm = @"";
    NSString *measrHr = @"";
    int actCnt = 0;
    int totActCnt = 0;
    
    int totActTm = 0;
    
    int actDstc = 0;
    int totActDstc = 0;
    
    double actCal = 0;
    double totActCal = 0;
    
    NSString *time = @"";
    NSString *last_date = @"";
    NSString *arrStep = @"";
    NSString *last_time = @"";
    NSString *check_date = @"";
    
    NSString *step = @"";
    int iStep = 0;
    NSString *distance = @"";
    int iDistance = 0;
    NSString *cal = @"";
    double dCal = 0.0;
    
    if (self.listData.count > 0) {
        NSDictionary *map = self.listData[0];
        NSString *time2 = map[@"date"];
        check_date = [time2 substringWithRange:NSMakeRange(0, 10)];
    }
    
    for (int i = 0; i < self.listData.count; i++) {
        NSDictionary *map = self.listData[i];
        time = map[@"date"];
        
        NSString *strDate = [time substringWithRange:NSMakeRange(0, 10)];
        if ([strDate isEqualToString:check_date]) {
            step = map[@"step"];
            iStep = step.intValue;
            NSArray *listSteps = map[@"arraySteps"];
            arrStep = [listSteps componentsJoinedByString:@","];
            distance = map[@"distance"];
            cal = map[@"calories"];
            dCal = cal.doubleValue;
            iDistance = (int)(distance.doubleValue * 1000);
            
            totActCnt += iStep;
            totActTm += [self getTimeByArr:arrStep];
            totActDstc += iDistance;
            totActCal += dCal;
            
            if (last_time.length > 0) {
                NSString *strTm = [time substringWithRange:NSMakeRange(0, 13)];
                if ([strTm isEqualToString:last_time]) {
                    actCnt += iStep;
                    actDstc += iDistance;
                    actCal += dCal;
                }
            }
            else {
                last_time = [time substringWithRange:NSMakeRange(0, 13)];
                last_date = time;
                
                actCnt += iStep;
                actDstc += iDistance;
                actCal += dCal;
            }
        }
    }
    
    if (last_date.length > 0) {
        [self.activity setDeviceNm:self.bleDevice.deviceNm];
        [self.activity setActCnt:[NSNumber numberWithInt:actCnt]];
        [self.activity setActCal:[NSNumber numberWithDouble:actCal]];
        [self.activity setActDstc:[NSNumber numberWithInt:actDstc]];
        
        [self.activity setTotActCnt:[NSNumber numberWithInt:totActCnt]];
        [self.activity setTotActCal:[NSNumber numberWithDouble:totActCal]];
        [self.activity setTotActDstc:[NSNumber numberWithInt:totActDstc]];
        [self.activity setTotActTm:[NSNumber numberWithInt:totActTm]];
        
        NSArray *arrDate = [last_date componentsSeparatedByString:@" "];
        measrDe = [arrDate[0] stringByReplacingOccurrencesOfString:@"." withString:@""];
        measrTm = [arrDate[1] stringByReplacingOccurrencesOfString:@":" withString:@""];
        measrHr = [measrTm substringWithRange:NSMakeRange(0, 2)];
        [self.activity setMeasrDe:measrDe];
        [self.activity setMeasrTm:measrTm];
        [self.activity setUserId:@"testuser"];
        [self.activity setSendYn:@"N"];
        [self.activity setBroadcastId:self.bleDevice.broadcastID];
        [self.activity setMeasrHour:measrHr];
    }
    
    [jBleManager deviceSyncData:self.activity deviceType:JENUMDeviceServiceTypePedometer];
    
    //내가 추가한 것
    self.dataCount = 0;
    [self.listData removeAllObjects];
    [self readExerciseData:DEVICE_DATA_MODE_START];
}

//내가 추가한 것(운동 데이터 누적(심박데이터 이상함))
- (void)parseActivityModeDataValues {
    NSString *time = @"";
    int HR = 0;
    
    NSString *step = @"";
    int iStep = 0;
    NSString *distance = @"";
    int iDistance = 0;
    NSString *cal = @"";
    double dCal = 0.0;
    
    NSString *heartValue = @"";
    NSString *paceMinutes = @"";
    int iPaceMinutes = 0;
    NSString *paceSeconds = @"";
    int iPaceSeconds = 0;
    
    NSMutableArray *arrPace = [[NSMutableArray alloc] init];
    
    NSString *actTm = @"";
    int iActTm = 0;
    NSString *ActivityMode = @"";
    
    NSString *check_date = @"";
    
    if (self.listData.count > 0) {
        NSDictionary *map = self.listData[0];
        NSString *time2 = map[@"date"];
        check_date = [time2 substringWithRange:NSMakeRange(0, 10)];
    }
    
    for (int i = 0; i < self.listData.count; i++) {
        NSDictionary *map = self.listData[i];
        time = map[@"date"];
        
        NSString *strDate = [time substringWithRange:NSMakeRange(0, 10)];
        if ([strDate isEqualToString:check_date]) {
            ActivityMode = map[@"activityMode"];
            heartValue = map[@"heartRate"];
            HR = heartValue.intValue;
            actTm = map[@"activeMinutes"];
            iActTm = actTm.intValue;
            step = map[@"step"];
            iStep = step.intValue;
            paceMinutes = map[@"paceMinutes"];
            iPaceMinutes = paceMinutes.intValue;
            paceSeconds = map[@"paceSeconds"];
            iPaceSeconds = paceSeconds.intValue;
            distance = map[@"distance"];
            iDistance = (int)(distance.doubleValue * 1000);
            cal = map[@"calories"];
            dCal = cal.doubleValue;
            
            NSArray *excsDate = [time componentsSeparatedByString:@" "];
            
            NSString *endDateString = [self getEndDate:time duration:iActTm];
            NSArray *endDateComponents = [endDateString componentsSeparatedByString:@" "];
            
            NSString *combinedPace = [NSString stringWithFormat:@"%d.%02d", iPaceMinutes, iPaceSeconds];
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *numericValue = [formatter numberFromString:combinedPace];
            double iPacedouble = [numericValue doubleValue];
            
            [self.excsStatus setExcsStartDe:[excsDate[0] stringByReplacingOccurrencesOfString:@"." withString:@""]];
            [self.excsStatus setExcsStartTm:[excsDate[1] stringByReplacingOccurrencesOfString:@":" withString:@""]];
            [self.excsStatus setExcsEndDe:[endDateComponents[0] stringByReplacingOccurrencesOfString:@"." withString:@""]];
            [self.excsStatus setExcsEndTm:[endDateComponents[1] stringByReplacingOccurrencesOfString:@":" withString:@""]];
            [self.excsStatus setExcsCnt:[NSNumber numberWithInt:iStep]];
            [self.excsStatus setExcsDstc:[NSNumber numberWithInt:iDistance]];
            [self.excsStatus setExcsTm:[NSNumber numberWithInt:iActTm]];
            [self.excsStatus setRestTm:@0];
            [self.excsStatus setMaxCal:@0];
            [self.excsStatus setTotCal:[NSNumber numberWithInt:dCal]];
            [self.excsStatus setMaxPace:[NSNumber numberWithDouble:iPacedouble]]; // iPaceMinutes'iPaceSeconds 로 변경하기
            [self.excsStatus setAvgPace:[NSNumber numberWithDouble:iPacedouble]]; // iPaceMinutes'iPaceSeconds 로 변경하기
            [self.excsStatus setMaxAltitude:@0];
            [self.excsStatus setAvgAltitude:@0];
            [self.excsStatus setMaxPitch:@0];
            [self.excsStatus setAvgPitch:@0];
            [self.excsStatus setMinHeartRate:[NSNumber numberWithInt:HR]];
            [self.excsStatus setMaxHeartRate:[NSNumber numberWithInt:HR]];
            [self.excsStatus setAvgHeartRate:[NSNumber numberWithInt:HR]];
            [self.excsStatus setAutoManuClf:@"M"];
            /*
             if ([ActivityMode isEqualToString:@"Run"]) {
             [self.excsStatus setExcsClf:@(Run)];
             } else if ([ActivityMode isEqualToString:@"Cycle"]) {
             [self.excsStatus setExcsClf:@(Cycling)];
             } else {
             [self.excsStatus setExcsClf:@(Walk)];
             }
             */
            //[jBleManager deviceSyncData:self.excsStatus deviceType:JENUMDeviceServiceTypePedometer]; //모든 데이터 출력할 때
        }
    }
    
    [jBleManager deviceSyncData:self.excsStatus deviceType:JENUMDeviceServiceTypePedometer]; // 최근 데이터만 출력할 때
    self.dataCount = 0;
    [self.listData removeAllObjects];
    [self readDynamicHRData:DEVICE_DATA_MODE_START];
}
- (void)parseDynamicHRDataValues {
    NSString *time = @"";
    NSString *heartValue = @"";
    NSString *hrValArr = @"";
    int avrHr = 0;
    int maxHr = 0;
    int minHr = 200;
    int totHR = 0;
    int hr = 0;
    NSString *last_date = @"";
    NSString *check_date = @"";
    
    NSMutableArray *arrHR = [[NSMutableArray alloc] init];
    
    int nonZeroCount = 0;
    
    if (self.listData.count > 0) {
        NSDictionary *map = self.listData[0];
        NSString *time2 = map[@"date"];
        check_date = [time2 substringWithRange:NSMakeRange(0, 10)];
        last_date = time2;
    }
    
    for (int i = 0; i < self.listData.count; i++) {
        NSDictionary *map = self.listData[i];
        time = map[@"date"];
        heartValue = map[@"arrayHR"];
        if ([heartValue isKindOfClass:[NSArray class]]) {
            NSArray *hrArray = (NSArray *)heartValue;
            
            NSString *strDate = [time substringWithRange:NSMakeRange(0, 10)];
            if ([strDate isEqualToString:check_date]) {
                for (NSNumber *number in hrArray) {
                    if ([number isKindOfClass:[NSNumber class]]) {
                        [arrHR addObject:number];
                    }
                }
            }
        }
    }
    
    for (int k = 0; k < arrHR.count; k++) {
        NSNumber *hr = arrHR[k];
        int nHr = [hr intValue];
        if (nHr != 0) {
            nonZeroCount++;
            if (maxHr < nHr) {
                maxHr = nHr;
            }
            if (minHr > nHr) {
                minHr = nHr;
            }
            totHR += nHr;
        }
        if (k == 0) {
            hrValArr = [NSString stringWithFormat:@"%d", nHr];
        }
        else {
            NSString *strTemp = [NSString stringWithFormat:@",%d", nHr];
            hrValArr = [hrValArr stringByAppendingString:strTemp];
        }
    }
    avrHr = totHR / nonZeroCount;
    
    NSArray *arrDate = [last_date componentsSeparatedByString:@" "];
    [self.arrDynamic setStartTm:[arrDate[1] stringByReplacingOccurrencesOfString:@":" withString:@""]];
    [self.arrDynamic setStartDe:[arrDate[0] stringByReplacingOccurrencesOfString:@"." withString:@""]];
    [self.arrDynamic setCollectTime:[NSNumber numberWithInt:5]];
    [self.arrDynamic setMaxHeartRate:[NSNumber numberWithInt:maxHr]];
    [self.arrDynamic setMinHeartRate:[NSNumber numberWithInt:minHr]];
    [self.arrDynamic setAvgHeartRate:[NSNumber numberWithInt:avrHr]];
    [self.arrDynamic setHeartRateCnt:[NSNumber numberWithInt:arrHR.count]];
    [self.arrDynamic setHeartRateList:hrValArr];
    
    [jBleManager deviceSyncData:self.arrDynamic deviceType:JENUMDeviceServiceTypePedometer];
    
    self.dataCount = 0;
    [self.listData removeAllObjects];
}
//- (void)parseActivityModeDataValues {
//    NSString *time = @"";
//    int HR = 0;
//    
//    NSString *step = @"";
//    int iStep = 0;
//    NSString *distance = @"";
//    int iDistance = 0;
//    NSString *cal = @"";
//    double dCal = 0.0;
//    
//    NSString *heartValue = @"";
//    NSString *paceMinutes = @"";
//    int iPaceMinutes = 0;
//    NSString *paceSeconds = @"";
//    int iPaceSeconds = 0;
//    
//    NSMutableArray *arrPace = [[NSMutableArray alloc] init];
//    NSMutableArray *arrHR = [[NSMutableArray alloc] init];
//    
//    NSString *actTm = @"";
//    int iActTm = 0;
//    NSString *ActivityMode = @"";
//    
//    NSString *check_date = @"";
//    
//    int avrHr = 0;
//    int maxHr = 0;
//    int minHr = 200;
//    int totHR = 0;
//    NSString *hrValArr = @"";
//    
//    if (self.listData.count > 0) {
//        NSDictionary *map = self.listData[0];
//        NSString *time2 = map[@"date"];
//        check_date = [time2 substringWithRange:NSMakeRange(0, 10)];
//    }
//    
//    for (int i = 0; i < self.listData.count; i++) {
//        NSDictionary *map = self.listData[i];
//        time = map[@"date"];
//        
//        NSString *strDate = [time substringWithRange:NSMakeRange(0, 10)];
//        if ([strDate isEqualToString:check_date]) {
//            ActivityMode = map[@"activityMode"];
//            heartValue = map[@"heartRate"];
//            HR = heartValue.intValue;
//            actTm = map[@"activeMinutes"];
//            iActTm = actTm.intValue;
//            step = map[@"step"];
//            iStep = step.intValue;
//            paceMinutes = map[@"paceMinutes"];
//            iPaceMinutes = paceMinutes.intValue;
//            paceSeconds = map[@"paceSeconds"];
//            iPaceSeconds = paceSeconds.intValue;
//            distance = map[@"distance"];
//            iDistance = (int)(distance.doubleValue * 1000);
//            cal = map[@"calories"];
//            dCal = cal.doubleValue;
//            [arrHR addObject:[NSNumber numberWithInt:HR]];
//        }
//    }
//    
//    for (int k = 0; k <arrHR.count; k++) {
//        NSNumber *HR = arrHR[k];
//        int nHr = [HR intValue];
//        if (maxHr < nHr) {
//            maxHr = nHr;
//        }
//        if (minHr > nHr) {
//            minHr = nHr;
//        }
//        totHR += nHr;
//        
//        if (k == 0) {
//            hrValArr = [NSString stringWithFormat:@"%d", nHr];
//        }
//        else {
//            NSString *strTemp = [NSString stringWithFormat:@",%d", nHr];
//            hrValArr = [hrValArr stringByAppendingString:strTemp];
//        }
//    }
//    avrHr = totHR / arrHR.count;
//    
//    NSArray *excsDate = [time componentsSeparatedByString:@" "];
//    
//    NSString *endDateString = [self getEndDate:time duration:iActTm];
//    NSArray *endDateComponents = [endDateString componentsSeparatedByString:@" "];
//    
//    NSString *combinedPace = [NSString stringWithFormat:@"%d.%02d", iPaceMinutes, iPaceSeconds];
//    
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    formatter.numberStyle = NSNumberFormatterDecimalStyle;
//    NSNumber *numericValue = [formatter numberFromString:combinedPace];
//    double iPacedouble = [numericValue doubleValue];
//    
//    [self.excsStatus setExcsStartDe:[excsDate[0] stringByReplacingOccurrencesOfString:@"." withString:@""]];
//    [self.excsStatus setExcsStartTm:[excsDate[1] stringByReplacingOccurrencesOfString:@":" withString:@""]];
//    [self.excsStatus setExcsEndDe:[endDateComponents[0] stringByReplacingOccurrencesOfString:@"." withString:@""]];
//    [self.excsStatus setExcsEndTm:[endDateComponents[1] stringByReplacingOccurrencesOfString:@":" withString:@""]];
//    [self.excsStatus setExcsCnt:[NSNumber numberWithInt:iStep]];
//    [self.excsStatus setExcsDstc:[NSNumber numberWithInt:iDistance]];
//    [self.excsStatus setExcsTm:[NSNumber numberWithInt:iActTm]];
//    [self.excsStatus setRestTm:@0];
//    [self.excsStatus setMaxCal:@0];
//    [self.excsStatus setTotCal:[NSNumber numberWithInt:dCal]];
//    [self.excsStatus setMaxPace:[NSNumber numberWithDouble:iPacedouble]]; // iPaceMinutes'iPaceSeconds 로 변경하기
//    [self.excsStatus setAvgPace:[NSNumber numberWithDouble:iPacedouble]]; // iPaceMinutes'iPaceSeconds 로 변경하기
//    [self.excsStatus setMaxAltitude:@0];
//    [self.excsStatus setAvgAltitude:@0];
//    [self.excsStatus setMaxPitch:@0];
//    [self.excsStatus setAvgPitch:@0];
//    [self.excsStatus setMinHeartRate:[NSNumber numberWithInt:minHr]];
//    [self.excsStatus setMaxHeartRate:[NSNumber numberWithInt:maxHr]];
//    [self.excsStatus setAvgHeartRate:[NSNumber numberWithInt:avrHr]];
//    [self.excsStatus setAutoManuClf:@"M"];
//    /*
//    if ([ActivityMode isEqualToString:@"Run"]) {
//        [self.excsStatus setExcsClf:@(Run)];
//    } else if ([ActivityMode isEqualToString:@"Cycle"]) {
//        [self.excsStatus setExcsClf:@(Cycling)];
//    } else {
//        [self.excsStatus setExcsClf:@(Walk)];
//    }
//    */
//    [jBleManager deviceSyncData:self.excsStatus deviceType:JENUMDeviceServiceTypePedometer];
//    self.dataCount = 0;
//    [self.listData removeAllObjects];
//}

- (NSString *)getEndDate:(NSString *)startDate duration:(NSInteger)exTimeSecond {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    
    NSDate *dateStart = [dateFormat dateFromString:startDate];
    
    if (dateStart) {
        dateStart = [dateStart dateByAddingTimeInterval:(NSTimeInterval)exTimeSecond];
        return [dateFormat stringFromDate:dateStart];
    }
    
    return @"";
}

-(int)getTimeByArr:(NSString *)stepArr {
    int act = 0;
    
    if (stepArr.length < 1) {
        return act;
    }
    
    NSArray *arrays = [stepArr componentsSeparatedByString:@","];
    act += arrays.count;
    
    return act;
}

#pragma mark JOTAManagerDelegate
- (void)success:(NSData *)data{
    NSLog(@"success==============");
}
- (void)error:(NSError *)error{
    NSLog(@"error==============");
}
- (void)downloading:(NSData *)data{
    NSLog(@"downloading==============");
}


/**************************************************************************/

#pragma mark JBLEManagerPeripheralDelegate
//-(void)peripheralDidUpdateName:(CBPeripheral *)peripheral
-(void)jBleManagerDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"PedometerDevice.jBleManagerDidUpdateName");
}

//-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
-(void)jBleManagerDidModifyServices:(CBPeripheral *)peripheral invalidatedServices:(NSArray<CBService *> *)invalidatedServices {
    NSLog(@"PedometerDevice.jBleManagerDidModifyServices invalidatedServices");
}

//-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
-(void)jBleManagerDidReadRSSI:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidReadRSSI RSSI");
}

//-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
-(void)jBleManagerDidDiscoverServices:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidDiscoverServices");
    if (error == nil) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    } else {
        NSLog(@"didDiscoverServices was unsuccessful ! error: %@",error);
    }
    
}

//-(void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
-(void)jBleManagerDidDiscoverIncludedServices:(CBPeripheral *)peripheral service:(CBService *)service error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidDiscoverIncludedServices service");
}

//-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
-(void)jBleManagerDidDiscoverCharacteristics:(CBPeripheral *)peripheral service:(CBService *)service error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidDiscoverCharacteristics service");
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Characteristic UUID UUIDString %@", [characteristic.UUID UUIDString]);
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

//-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
-(void)jBleManagerDidUpdateValue:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidUpdateValue characteristic");
    if (error) {
        NSLog(@"updateValueForCharacteristic failed !");
        
        //페어링
        if(jBleManager.isPairingDevice){
            /*****************************************************
             JConstantsCoreData.class
             public static let BLEDEVICE_KEY_BROADCASTID                     :String = "broadcastId"
             public static let BLEDEVICE_KEY_DEVICEID                        :String = "deviceId"
             public static let BLEDEVICE_KEY_DEVICESN                        :String = "deviceSn"
             public static let BLEDEVICE_KEY_DEVICENAME                      :String = "deviceName"
             public static let BLEDEVICE_KEY_DEVICETYPE                      :String = "deviceType"
             public static let BLEDEVICE_KEY_PROTOCOLTYPE                    :String = "protocolType"
             public static let BLEDEVICE_KEY_IDENTIFIER                      :String = "peripheralIdentifier"
             public static let BLEDEVICE_KEY_PASSWORD                        :String = "password"
             public static let BLEDEVICE_KEY_HARDWAREVERSION                 :String = "hardwareVersion"
             public static let BLEDEVICE_KEY_FIRMWAREVERSION                 :String = "firmwareVersion"
             public static let BLEDEVICE_KEY_SOFTWAREVERSION                 :String = "softwareVersion"
             public static let BLEDEVICE_KEY_MODELNUMBER                     :String = "modelNumber"
             public static let BLEDEVICE_KEY_DEVICEUSERNUMBER                :String = "deviceUserNumber"
             
             필요한 정보를 [String:String] 형태로 생성 후 deviceInfo로 전달
             *****************************************************/
            [self pairDevice];
//            [jBleManager pairDevice:peripheral deviceInfo:self.deviceInfo deviceType:JENUMDeviceServiceTypePedometer];
        }
    } else {
        CBUUID *charUUID = characteristic.UUID;
//        NSLog(@"entered didUpdateValueForChar");
//        NSLog(@"charUUID is %@", charUUID);
//        NSLog(@"charValue is %@", characteristic.value);
        NSString * strUUID = characteristic.UUID.UUIDString;
        if([strUUID isEqualToString:REC_CHAR]) {
            [self parseRecvData:characteristic.value];
        }
    }
}

//-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
-(void)jBleManagerDidWriteValue:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidWriteValue characteristic");
}

//-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
-(void)jBleManagerDidUpdateNotificationState:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidUpdateNotificationState characteristic");
}

//-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
-(void)jBleManagerDidDiscoverDescriptors:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic error:(NSError * _Nullable)error {
    NSLog(@"PedometerDevice.jBleManagerDidDiscoverDescriptors characteristic");
    if (error == nil) {
        CBService *s = [peripheral.services lastObject];
        CBCharacteristic *c = [s.characteristics lastObject];
        if ([[[characteristic UUID] UUIDString] isEqualToString: [[c UUID] UUIDString]]) {
            //connect 시 CoreData 저장소에 해당 객체 타입이 없으면 자동으로 isPairingDevice = true 설정.
            if(jBleManager.isPairingDevice){
                [self pairDevice];
            }
            else if (self.targetFunc == TARGET_FUNC_SYNC){
                [self readSyncData];
            }
            else if (self.targetFunc == TARGET_FUNC_GET_DEVICE_INFO){
                [self readDeviceInfo];
            }
            else if (self.targetFunc == TARGET_FUNC_SET_DEVICE_INFO){
                [self setDeviceInfo];
            }
            else if (self.targetFunc == TARGET_FUNC_EXEC_CALL){
                [self execCall:self.execArgs];
            }
            else if (self.targetFunc == TARGET_FUNC_EXEC_SMS){
                [self execSMS:self.execArgs];
            }
            else if (self.targetFunc == TARGET_FUNC_EXEC_SNS){
                [self execSNS:self.execArgs];
            }
        }
    } else {
        NSLog(@"PedometerDevice.jBleManagerDidDiscoverDescriptors was unsuccessful ! error: %@",error);
    }
}

//-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
-(void)jBleManagerDidUpdateValue:(CBPeripheral *)peripheral descriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidUpdateValue descriptor");
}

//-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
-(void)jBleManagerDidWriteValue:(CBPeripheral *)peripheral descriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"PedometerDevice.jBleManagerDidWriteValue descriptor");
}

//-(void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral
-(void)jBleManagerIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral {
    NSLog(@"PedometerDevice.jBleManagerIsReadyToSendWriteWithoutResponse");
}

#pragma mark JBLEManagerDeviceControllDelegate function start
-(void)jBleDeviceControllStopScan {
    NSLog(@"jBleDeviceControllStopScan");
    
}

-(void)jBleDeviceControllCancelConnect {
    NSLog(@"jBleDeviceControllCancelConnect");
    self.isDiscovered = NO;
}

@end
