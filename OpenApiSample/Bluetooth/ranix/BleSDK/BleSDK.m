//
//  BleSDK.m
//  BleSDK
//
//  Created by yang sai on 2022/4/27.
//

#import "BleSDK.h"
#define CMD_SET_TIME 0x01
#define CMD_GET_TIME 0x41
#define CMD_SET_INFO 0x02
#define CMD_GET_INFO 0x42
#define CMD_SET_DEVICE_INFO 0x03
#define CMD_GET_DEVICE_INFO 0x04
#define CMD_SET_DEVICE_ID 0x05
#define CMD_STEP 0x09
#define CMD_SET_GOAL 0x0B
#define CMD_GET_GOAL 0x4B
#define CMD_GET_BATTERY 0x13
#define CMD_GET_MAC 0x22
#define CMD_GET_VERSION 0x27
#define CMD_MCU 0x2E
#define CMD_FACTORY_RESET 0x12
#define CMD_MOTOR 0x36
#define CMD_SET_DEVICE_NAME 0x3D
#define CMD_GET_DEVICE_NAME 0x3E
#define CMD_SET_AUTO_HEART 0x2A
#define CMD_GET_AUTO_HEART 0x2B
#define CMD_SET_ALARM 0x23
#define CMD_GET_ALARM 0x57
#define CMD_SET_ANCS 0x30
#define CMD_GET_ANCS 0x5B
#define CMD_SET_ACTIVITY_TIME 0x25
#define CMD_GET_ACTIVITY_TIME 0x26
#define CMD_GET_TOTAL_STEP 0x51
#define CMD_GET_DETAIL_STEP 0x52
#define CMD_GET_DETAIL_SLEEP 0x53
#define CMD_GET_HEART 0x54
#define CMD_GET_SINGLE_HEART 0x55 //获取单次的心率数据
#define CMD_GET_HRV 0x56
#define CMD_GET_GPS 0x5A //获取运动模式的数据
#define CMD_GET_ACTIVITY_DATA 0x5C //获取运动模式的数据
#define CMD_GET_SPO2_DATA 0x60 //获取Spo2的历史数据 (手动)
#define CMD_GET_AUTOMATIC_SPO2_DATA 0x66 //获取Spo2的历史数据 (自动)

#define CMD_GET_TEMPERATURE_DATA 0x62 //获取温度的历史数据
#define CMD_GET_AXILLARY_TEMPERATURE_DATA 0x65 //获取温度的历史数据
#define CMD_SET_ACTIVITY_MODE //设置运动模式
#define CMD_PACKAGE_APP 0x17
#define CMD_PACKAGE_DEVICE 0x18
#define CMD_FUNCTION_MODE 0x16
#define CMD_SET_WEATHER 0x15
#define CMD_ENTER_ACTIVITY_MODE 0x19
#define CMD_OTA_MODE 0x47
#define CMD_TAKEPHOTO_MODE 0x20
#define CMD_BACK_HOME 0x10
#define CMD_ECG_PPG_START 0x99
#define CMD_ECG_PPG_STOP 0x98
#define CMD_SOCIAL_DISTANCE_REMINDER 0x64
#define CMD_ECG_RECEIVE  0xaa
#define CMD_PPG_RECEIVE  0xab
#define CMD_PPG_ECG_RESULT  0x9c
#define CMD_PPG_HRV_RESULT  0x83
#define CMD_TEMPERATURE_CORRECTION 0x38
#define CMD_HEART_BEAT_PACKETS 0x06
#define CMD_CONTACT 0x33
#define CMD_ECG_HISTORY_DATA 0x71
#define CMD_S0S 0xfe
#define CMD_DEVICE_Measurement 0x28  //开启测量
#define CMD_QRCODE_SCREEN 0xb0
#define CMD_RR_INTERVAL 0x9B
#define CMD_PPG_DATA 0x3a
#define CMD_PPG_Measurement 0x78
#define CMD_CLEAR_ALL_DATA 0x61

#define CMD_SET_Menstruation_Info 0x1c  //设置月经周期你
#define CMD_SET_Pregnancy_Info 0x1e //设置怀孕周期

#define CMD_SET_NOTIFY  0x4D

@interface BleSDK ()
{
    
//    NSString * strEcgDataStartTime;
//    int HRV;
//    int HeartRate;
//    int Mood;
    
    BOOL unLock;
    char  ecgData;
    int GPSDataNumber;
    BOOL isGet;
    BOOL isSet;
    BOOL isDelete;
    NSMutableArray * arrayPPG_X;
    NSMutableArray * arrayPPG_Y;
}
@end

@implementation BleSDK

/*!
 *  @method CRCWithData:
 *
 *  @discussion CRC校验
 *
 */
-(char)CRCWithData:(char*)b length:(int)length
{
    char sam = 0;
    for (int i  = 0; i < length-1; i++)
    {
        sam += b[i];
    }
    return sam;
}


/*!
 *  @method sharedManager:
 *
 *  @discussion 单列模式
 *
 */
+(BleSDK *)sharedManager
{
    static BleSDK *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

/*!
 *  @method GetDeviceTime:
 *
 *  @discussion 获取手环的时间
 *
 */
-(NSMutableData*)GetDeviceTime
{
    char b[] = {CMD_GET_TIME,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}
/*!
 *  @method SetDeviceTime:
 *  @param deviceTime   时间.
 *  @discussion 设置手环的时间
 *
 */
-(NSMutableData*)SetDeviceTime:(MyDeviceTime)deviceTime
{
    char b[] = {CMD_SET_TIME,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[1] = deviceTime.year-2000+((deviceTime.year-2000)/10*6);
    b[2] = deviceTime.month+deviceTime.month/10*6;
    b[3] = deviceTime.day+deviceTime.day/10*6;
    b[4] = deviceTime.hour+deviceTime.hour/10*6;
    b[5] = deviceTime.minute+deviceTime.minute/10*6;
    b[6] = deviceTime.second+deviceTime.second/10*6;
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method GetPersonalInfo:
 *
 *  @discussion 获取手环的个人信息
 *
 */
-(NSMutableData*)GetPersonalInfo
{
    char b[] = {CMD_GET_INFO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}
/*!
 *  @method SetPersonalInfo:
 *  @param personalInfo   个人基本信息.
 *  @discussion 设置手环的时间
 *
 */
-(NSMutableData*)SetPersonalInfo:(MyPersonalInfo)personalInfo
{
    char b[] = {CMD_SET_INFO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[1] = personalInfo.gender;
    b[2] = personalInfo.age;
    b[3] = personalInfo.height;
    b[4] = personalInfo.weight;
    b[5] = personalInfo.stride;
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}
/*!
 *  @method RealTimeStep:
 *  @param dataType   0:表示关闭  1:当步数发生变化时，手环会上传数据  11:固定一秒钟上传一个数据
 *  @discussion 实时计步
 *
 */
-(NSMutableData*)RealTimeDataWithType:(int8_t)dataType
{
    
    char b[] = {CMD_STEP,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(dataType==1)
    {
        b[1] = 1;
        b[2] = 0;
    }
    else if(dataType==2)
    {
        b[1] = 1;
        b[2] = 1;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method setWeather:
 *  @param weatherParameter   天气的参数 weather parameters
 *
 *  @discussion 设置当前的天气 Set the current weather
 *
 */
-(NSMutableData*)setWeather:(MyWeatherParameter)weatherParameter
{
    
    NSString * CityName = weatherParameter.strCity;
    int weatherType = weatherParameter.weatherType;
    int CurrentTemp = weatherParameter.currentTemperature;
    int LowTemp = weatherParameter.lowestTemperature;
    int HighTemp = weatherParameter.highestTemperature;
    NSData * cityData  = [CityName dataUsingEncoding:NSUTF8StringEncoding];
    unsigned long CityNamelengt = 0;
    Byte * cityBytes =(Byte*)cityData.bytes;
    if (cityData.length>=32) {
        CityNamelengt = 32;
    }else{
        CityNamelengt = cityData.length;
    }
    Byte b[CityNamelengt+8];
    b[0] = CMD_SET_WEATHER;
    b[1] = weatherType;
    b[2] = CurrentTemp;
    b[3] = LowTemp;
    b[4] = HighTemp;
    b[5] = 0;
    b[6] = 0;
    b[7] = CityNamelengt;
    for (int j = 0; j<CityNamelengt; j++) {
            b[j+8] = cityBytes[j];
    }
    unsigned long bleng = 8+CityNamelengt;
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:bleng];
    return data;
}




/*!
 *  @method setMenstruationInfoWithStartTime:::
 *  @param dateStartTime  when menstruation started    月经开始的时间
    @param durationDays   duration days  月经持续的天数
 *  @param cycleLengthDays   cycle length days  这次月经开始到下一次月经开始的天数
 *
 *  @discussion Set menstruation info   设置月经信息
 *
 */
-(NSMutableData*)setMenstruationInfoWithStartTime:(NSDate*)dateStartTime durationOfMenstruation:(NSInteger)durationDays  cycleLength:(NSInteger)cycleLengthDays
{
    char b[] = {CMD_SET_Menstruation_Info,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    NSInteger month = [self GetMonthFromDate:dateStartTime];
    NSInteger day = [self GetDayFromDate:dateStartTime];
    b[1] = month+(month/10*6);
    b[2] = day + (day/10*6) ;
    b[3] = durationDays;
    b[4] = cycleLengthDays;
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method setPregnancyInfoWithStartTime:
 *  @param dateStartTime  when the pregnancy started 孕期的开始时间
 *
 *  @discussion Set  pregnancy info  设置孕期信息
 *
 */


-(NSMutableData*)setPregnancyInfoWithStartTime:(NSDate*)dateStartTime
{
    char b[] = {CMD_SET_Pregnancy_Info,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    
    NSInteger year = [self GetYearFromDate:dateStartTime]-2000;
    NSInteger month = [self GetMonthFromDate:dateStartTime];
    NSInteger day = [self GetDayFromDate:dateStartTime];
    b[3] = year + (year/10*6);
    b[4] = month + (month/10*6);
    b[5] = day + (day/10*6);
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method GetDeviceInfo:
 *
 *  @discussion 获取手环的基本信息
 *
 */
-(NSMutableData*)GetDeviceInfo
{
    char b[] = {CMD_GET_DEVICE_INFO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method SetDeviceInfo:
 *  @param deviceInfo   手环的基本信息.
 *  @discussion 设置手环的时间
 *
 */
-(NSMutableData*)SetDeviceInfo:(MyDeviceInfo)deviceInfo
{
    char b[] = {CMD_SET_DEVICE_INFO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(deviceInfo.distanceUnit!=-1)
        b[1] = deviceInfo.distanceUnit + 0x80;
    if(deviceInfo.timeUnit!=-1)
        b[2] = deviceInfo.timeUnit + 0x80;
    if(deviceInfo.wristOn!=-1)
        b[3] = deviceInfo.wristOn + 0x80;
    if(deviceInfo.temperatureUnit!=-1)
        b[4] = deviceInfo.temperatureUnit + 0x80;
    if(deviceInfo.notDisturbMode!=-1)
    b[5] = deviceInfo.notDisturbMode + 0x80;
    if(deviceInfo.ANCS!=-1)
        b[6] = deviceInfo.ANCS + 0x80;
    
    MyNotificationType  notificationType = deviceInfo.notificationType;
    int call  = notificationType.call;
    int sms  = notificationType.SMS;
    int wechat  = notificationType.wechat;
    int facebook  = notificationType.facebook;
    int instagram  = notificationType.instagram;
    int skype  = notificationType.skype;
    int telegram  = notificationType.telegram;
    int twitter  = notificationType.twitter;
    int vkclient  = notificationType.vkclient;
    int whatsapp  = notificationType.whatsapp;
    int qq  = notificationType.qq;
    int In  = notificationType.In;
    b[7] = call + sms * (1<<1)+ wechat * (1<<2)+ facebook * (1<<3)+ instagram * (1<<4)+ skype * (1<<5)+ telegram * (1<<6)+ twitter * (1<<7);
    b[8] = vkclient + whatsapp * (1<<1)+ qq * (1<<2)+ In * (1<<3);
    if(deviceInfo.ANCS!=-1)
        b[8]  =  b[8] +0x80;
    if(deviceInfo.baseHeartRate!=-1)
        b[9] = deviceInfo.baseHeartRate + 0x80;
    if(deviceInfo.screenBrightness!=-1)
        b[11] = deviceInfo.screenBrightness + 0x80;
    if(deviceInfo.watchFaceStyle!=-1)
        b[12] = deviceInfo.watchFaceStyle + 0x80;
    if(deviceInfo.socialDistanceRemind!=-1)
        b[13] = deviceInfo.socialDistanceRemind + 0x80;
    if(deviceInfo.language!=-1)
        b[14] = deviceInfo.language + 0x80;
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method SetDeviceID:
 *  @param strDeviceID   ID 12个字节 不足12个字节就会自动补0.
 *  @discussion 设置手环ID
 *
 */
-(NSMutableData*)SetDeviceID:(NSString*)strDeviceID
{
    
    char b[] = {CMD_SET_DEVICE_ID,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(strDeviceID.length<12)
    {
        NSInteger temp = 12-strDeviceID.length;
        for (int i = 0; i<temp; i++)
           strDeviceID= [strDeviceID stringByAppendingString:@"0"];
        
    }
    for (int i =0; i<6; i++) {
        b[i+1] = (int)strtoul([[strDeviceID substringWithRange:NSMakeRange(i*2, 2)] UTF8String], 0, 16);
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetStepGoal:
 *
 *  @discussion 获取手环的步数目标
 *
 */
-(NSMutableData*)GetStepGoal
{
    char b[] = {CMD_GET_GOAL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}
/*!
 *  @method SetStepGoal:
 *  @param stepGoal   步数的目标值.
 *  @discussion 设置步数目标
 *
 */
-(NSMutableData*)SetStepGoal:(int)stepGoal
{
    char b[] = {CMD_SET_GOAL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    memcpy(b+1, &stepGoal, 4);
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method SetNotifyData
 *  @param sendData notification data
 *  @discussion send notification data
 *
 */
-(NSMutableData*)SetNotifyData:(MyNotifier)sendData
{
    Byte b[79];
    
    NSString *info = sendData.info;
    NSString *title = sendData.title;
    Byte infoValue[60];
    Byte titleValue[15];
    int infoValueLen = 0;
    int titleValueLen = 0;
    
    if (info.length == 0) {
        infoValueLen = 1;
        infoValue[0] = 0;
    }
    else {
        NSData *infoData = [self getInfoValue:info maxLength:60];
        infoValueLen = (int)infoData.length;
        Byte *chInfo = (Byte *)[infoData bytes];
        for (int i = 0; i < infoValueLen; i++)
        {
            infoValue[i] = chInfo[i];
        }
    }
    
    if (title.length == 0) {
        titleValueLen = 1;
        titleValue[0] = 0;
    }
    else {
        NSData *titleData = [self getInfoValue:title maxLength:15];
        titleValueLen = (int)titleData.length;
        Byte *chTitle = (Byte *)[titleData bytes];
        for (int i = 0; i < titleValueLen; i++)
        {
            titleValue[i] = chTitle[i];
        }
    }
    
    b[0] = CMD_SET_NOTIFY;
    b[1] = (Byte)sendData.type;
    b[2] = (Byte)infoValueLen;
    for (int i = 0; i < infoValueLen; i++)
    {
        b[3 + i] = infoValue[i];
    }
    if (title.length > 0) {
        b[63] = titleValueLen;
        for (int i = 0; i < titleValueLen; i++)
        {
            b[64 + i] = titleValue[i];
        }
    }
    
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:79];
    return data;
}

-(NSData *)getInfoValue:(NSString *)info maxLength:(int)maxLength
{
    NSData *nameBytes;
    
    nameBytes = [info dataUsingEncoding:NSUTF8StringEncoding];
    if (nameBytes.length >= maxLength) {
        return [nameBytes subdataWithRange:NSMakeRange(0, maxLength)];
    }
    
    return nameBytes;
}

/*!
 *  @method unlockScreen
 *
 *  @discussion Scan QR Code to pair the device and enter main dial
 *
 */
-(NSMutableData*)unlockScreen
{
    unLock = YES;
    char b[] = {CMD_QRCODE_SCREEN,0x81,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method lockScreen
 *
 *  @discussion Enter the QR code pairing page on the normal screen
 *
 */
-(NSMutableData*)lockScreen
{
    unLock = NO;
    char b[] = {CMD_QRCODE_SCREEN,0x80,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}




/*!
 *  @method GetDeviceBatteryLevel:
 *
 *  @discussion 获取手环的电量
 *
 */
-(NSMutableData*)GetDeviceBatteryLevel
{
    char b[] = {CMD_GET_BATTERY,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetDeviceMacAddress:
 *
 *  @discussion 获取手环的Mac地址
 *
 */
-(NSMutableData*)GetDeviceMacAddress
{
    char b[] = {CMD_GET_MAC,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method GetDeviceVersion:
 *
 *  @discussion 获取手环的版本信息
 *
 */
-(NSMutableData*)GetDeviceVersion
{
    char b[] = {CMD_GET_VERSION,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method Reset:
 *
 *  @discussion 恢复出厂设置(恢复出厂设置会让设备的数据全部删除)
 *
 */
-(NSMutableData*)Reset
{
    char b[] = {CMD_FACTORY_RESET,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method MCUReset:
 *
 *  @discussion MCU软复位
 *
 */
-(NSMutableData*)MCUReset
{
    char b[] = {CMD_MCU,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method MotorVibrationWithTimes:
 *  @param times   马达震动的次数.
 *  @discussion 马达震动
 *
 */
-(NSMutableData*)MotorVibrationWithTimes:(int)times
{
    char b[] = {CMD_MOTOR,times,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method GetDeviceName:
 *
 *  @discussion 获取手环的蓝牙名称
 *
 */
-(NSMutableData*)GetDeviceName
{
    char b[] = {CMD_GET_DEVICE_NAME,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method SetDeviceName:
 *  @param strDeviceName   设备的蓝牙名称（必须为ASCII字符码 32 to 127，发其它数据将被当做空格处理）
 *  @discussion 设置蓝牙设备名称，此命令执行后请执行软复位命令
 *
 */
-(NSMutableData*)SetDeviceName:(NSString*)strDeviceName
{
    char b[] = {CMD_SET_DEVICE_NAME,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i = 0; i<(strDeviceName.length>12?12:strDeviceName.length); i++) {
        b[i+1] = [strDeviceName characterAtIndex:i];
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
    
}

/*!
 *  @method GetAutomaticMonitoringWithDataType:
 *  @param dataType   1 means heartRate  2 means spo2  3 means temperature  4 means HRV
 *  @discussion get  the automatic monitoring information set by the watch
 *
 */
-(NSMutableData*)GetAutomaticMonitoringWithDataType:(int)dataType
{
    char b[] = {CMD_GET_AUTO_HEART,dataType,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method SetAutomaticMonitoring:
 *  @param automaticHRMonitoring   Automatic measurement setting information of the watch  手表的自动测量设置信息
 *  @discussion Set the automatic measurement setting information of the watch 设置手表的自动测量设置信息
 *
 */
-(NSMutableData*)SetAutomaticHRMonitoring:(MyAutomaticMonitoring)automaticHRMonitoring
{
    char b[] = {CMD_SET_AUTO_HEART,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[1] = automaticHRMonitoring.mode;
    b[2] = automaticHRMonitoring.startTime_Hour+automaticHRMonitoring.startTime_Hour/10*6;
    b[3] = automaticHRMonitoring.startTime_Minutes+automaticHRMonitoring.startTime_Minutes/10*6;
    b[4] = automaticHRMonitoring.endTime_Hour+automaticHRMonitoring.endTime_Hour/10*6;
    b[5] = automaticHRMonitoring.endTime_Minutes+automaticHRMonitoring.endTime_Minutes/10*6;
    
    int week = (automaticHRMonitoring.weeks.sunday==YES?1:0) + (automaticHRMonitoring.weeks.monday==YES?2:0) +(automaticHRMonitoring.weeks.Tuesday==YES?4:0) + (automaticHRMonitoring.weeks.Wednesday==YES?8:0) +(automaticHRMonitoring.weeks.Thursday==YES?16:0) + (automaticHRMonitoring.weeks.Friday==YES?32:0) +(automaticHRMonitoring.weeks.Saturday==YES?64:0);
    b[6] = week;
    b[7] = automaticHRMonitoring.intervalTime%256;
    b[8] = automaticHRMonitoring.intervalTime/256;
    b[9] = automaticHRMonitoring.dataType;
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetAlarmClock:
 *
 *  @discussion 获取闹钟
 *
 */
-(NSMutableData*)GetAlarmClock
{
    char b[] = {CMD_GET_ALARM,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method  DeleteAllAlarmClock
 *
 *  @discussion 删除所有闹钟  delete all alarms
 *
 */
-(NSMutableData*)DeleteAllAlarmClock
{
    isDelete = YES;
    char b[] = {CMD_GET_ALARM,0x99,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method SetAlarmClockWithAllClock:
 *  @param arrayClockAlarm   设置的所有闹钟(闹钟最大的个数是10) 闹钟的格式是一个NSDictionary (NSDictionary 包含的key有 )
 *  @discussion 获取闹钟
 *
 */
-(nullable NSMutableArray<NSMutableData *> *)SetAlarmClockWithAllClock:(nullable NSArray<NSDictionary *> *)arrayClockAlarm
{
    NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
    [arrayTemp removeAllObjects];
    NSNumber * longestBites = [NSNumber numberWithInt:128];
    if(longestBites)
    {
        int lenghtUnit = 39;
        int longestSendBites = longestBites.intValue;
        int count = (int)arrayClockAlarm.count*lenghtUnit+2;
        if(count>longestSendBites)
        {
            //每次能发多少个包
            int CanSendCount  = longestSendBites/lenghtUnit;
            //分成几次发送
            int needSendCount = count/(CanSendCount*lenghtUnit)+1;
            for (int i = 0; i<needSendCount; i++) {
                if(i==needSendCount-1)
                {
                    //还剩下多少个包没有发送
                    int remainingCount = (int)arrayClockAlarm.count - CanSendCount*i;
                    char b[remainingCount*lenghtUnit+2];
                    for (int m = 0 ; m<remainingCount; m++) {
                        NSDictionary * dicClock = arrayClockAlarm[CanSendCount*i+m];
                        NSNumber * clockOpenOrClose = dicClock[@"openOrClose"];
                        NSNumber * clockType = dicClock[@"clockType"];
                        NSString * strTime = dicClock[@"clockTime"];
                        NSNumber * weekValue = dicClock[@"week"];
                        NSNumber * textLenght = dicClock[@"textLenght"];
                        NSString * strText  = dicClock[@"text"];
                        b[lenghtUnit*m+0] = 0x23;
                        b[lenghtUnit*m+1] = arrayClockAlarm.count;
                        b[lenghtUnit*m+2] = CanSendCount*i+m;
                        b[lenghtUnit*m+3] = clockOpenOrClose.intValue;
                        b[lenghtUnit*m+4] = clockType.intValue;
                        b[lenghtUnit*m+5] = [strTime substringWithRange:NSMakeRange(0, 2)].intValue +[strTime substringWithRange:NSMakeRange(0, 2)].intValue/10*6;
                        b[lenghtUnit*m+6] = [strTime substringWithRange:NSMakeRange(3, 2)].intValue +[strTime substringWithRange:NSMakeRange(3, 2)].intValue/10*6;
                        b[lenghtUnit*m+7] = weekValue.intValue;
                        b[lenghtUnit*m+8] = textLenght.intValue;
                        for (int j = 9; j<39; j++) {
                            b[lenghtUnit*m+j] = 0;
                        }
                        for (int j = 9; j<9+textLenght.intValue; j++) {
                            if(strText.length>(j-9))
                                b[lenghtUnit*m+j] = [strText characterAtIndex:j-9];
                        }
                    }
                    b[remainingCount*lenghtUnit] = 0x23;
                    b[remainingCount*lenghtUnit+1] = 0xff;
                    //发送过去
                    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:remainingCount*lenghtUnit+2];
                    [arrayTemp addObject:data];
                }
                else
                {
                    char b[CanSendCount*lenghtUnit];
                    for (int j =0; j<CanSendCount; j++) {
                        NSDictionary * dicClock = arrayClockAlarm[CanSendCount*i+j];
                        NSNumber * clockOpenOrClose = dicClock[@"openOrClose"];
                        NSNumber * clockType = dicClock[@"clockType"];
                        NSString * strTime = dicClock[@"clockTime"];
                        NSNumber * weekValue = dicClock[@"week"];
                        NSNumber * textLenght = dicClock[@"textLenght"];
                        NSString * strText  = dicClock[@"text"];
                        
                        b[lenghtUnit*j+0] = 0x23;
                        b[lenghtUnit*j+1] = arrayClockAlarm.count;
                        b[lenghtUnit*j+2] = i*CanSendCount+j;
                        b[lenghtUnit*j+3] = clockOpenOrClose.intValue;
                        b[lenghtUnit*j+4] = clockType.intValue;
                        b[lenghtUnit*j+5] = [strTime substringWithRange:NSMakeRange(0, 2)].intValue +[strTime substringWithRange:NSMakeRange(0, 2)].intValue/10*6;
                        b[lenghtUnit*j+6] = [strTime substringWithRange:NSMakeRange(3, 2)].intValue +[strTime substringWithRange:NSMakeRange(3, 2)].intValue/10*6;
                        b[lenghtUnit*j+7] = weekValue.intValue;
                        b[lenghtUnit*j+8] = textLenght.intValue;
                        for (int m = 9; m< 39 ; m++) {
                            b[lenghtUnit*j+m] = 0;
                        }
                        for (int m = 9; m<9+textLenght.intValue; m++) {
                            if(strText.length>(m-9))
                                b[lenghtUnit*j+m] = [strText characterAtIndex:m-9];
                        }
                    }
                    //发送过去
                    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:CanSendCount*lenghtUnit];
                    [arrayTemp addObject:data];
                }
            }
        }
        else
        {
            char b[count];
            for (int i = 0 ; i<count; i++) {
                b[i]= 0;
            }
            for (int i = 0; i<arrayClockAlarm.count; i++ ) {
                NSDictionary * dicClock = arrayClockAlarm[i];
                NSNumber * clockOpenOrClose = dicClock[@"openOrClose"];
                NSNumber * clockType = dicClock[@"clockType"];
                NSString * strTime = dicClock[@"clockTime"];
                NSNumber * weekValue = dicClock[@"week"];
                NSNumber * textLenght = dicClock[@"textLenght"];
                NSString * strText  = dicClock[@"text"];
                b[lenghtUnit*i+0] = 0x23;
                b[lenghtUnit*i+1] = arrayClockAlarm.count;
                b[lenghtUnit*i+2] = i;
                b[lenghtUnit*i+3] = clockOpenOrClose.intValue;
                b[lenghtUnit*i+4] = clockType.intValue;
                b[lenghtUnit*i+5] = [strTime substringWithRange:NSMakeRange(0, 2)].intValue +[strTime substringWithRange:NSMakeRange(0, 2)].intValue/10*6;
                b[lenghtUnit*i+6] = [strTime substringWithRange:NSMakeRange(3, 2)].intValue +[strTime substringWithRange:NSMakeRange(3, 2)].intValue/10*6;
                b[lenghtUnit*i+7] =weekValue.intValue;
                b[lenghtUnit*i+8] = textLenght.intValue;
                for (int j = 9; j< 39; j++) {
                    b[lenghtUnit*i+j] = 0;
                }
                for (int j = 9; j<9+textLenght.intValue; j++) {
                    if(strText.length>(j-9))
                        b[lenghtUnit*i+j] = [strText characterAtIndex:j-9];
                }
            }
            b[count-2]  = 0x23;
            b[count-1] = 0xff;
            NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:count];
             [arrayTemp addObject:data];
        }
    }
    return arrayTemp;
}

/*!
 *  @method GetSedentaryReminder:
 *
 *  @discussion 获取久坐提醒
 *
 */
-(NSMutableData*)GetSedentaryReminder
{
    char b[] = {CMD_GET_ACTIVITY_TIME,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}
/*!
 *  @method SetSedentaryReminder:
 *  @param sedentaryReminder   久坐提醒
 *  @discussion 设置久坐提醒
 *
 */
-(NSMutableData*)SetSedentaryReminder:(MySedentaryReminder)sedentaryReminder
{
    char b[] = {CMD_SET_ACTIVITY_TIME,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[1] = sedentaryReminder.startTime_Hour+sedentaryReminder.startTime_Hour/10*6;
    b[2] = sedentaryReminder.startTime_Minutes+sedentaryReminder.startTime_Minutes/10*6;
    b[3] = sedentaryReminder.endTime_Hour+sedentaryReminder.endTime_Hour/10*6;
    b[4] = sedentaryReminder.endTime_Minutes+sedentaryReminder.endTime_Minutes/10*6;
    int week = (sedentaryReminder.weeks.sunday==YES?1:0) + (sedentaryReminder.weeks.monday==YES?2:0) +(sedentaryReminder.weeks.Tuesday==YES?4:0) + (sedentaryReminder.weeks.Wednesday==YES?8:0) +(sedentaryReminder.weeks.Thursday==YES?16:0) + (sedentaryReminder.weeks.Friday==YES?32:0) +(sedentaryReminder.weeks.Saturday==YES?64:0);
    b[5] = week;
    b[6] = sedentaryReminder.intervalTime;
    b[7] = sedentaryReminder.leastSteps;
    b[8] = sedentaryReminder.mode;
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method StartDeviceMeasurementWithType::::
 *   @param dataType    The type of measurement that needs to be turned on   1 means HRV   2 means HR   3 means Spo2
 *   @param isOpen   When its value is YES, it means on, otherwise it means off
 *   @param isPPG_Open  Whether to enable PPG data return， When its value is YES, it means on, otherwise it means off
 *   *   @param isPPI_Open  Whether to enable PPI data return， When its value is YES, it means on, otherwise it means off
 *  @discussion  Turn on device measurement
 *
 */

-(NSMutableData*)StartDeviceMeasurementWithType:(int)dataType  isOpen:(BOOL)isOpen isPPG_Open:(BOOL)isPPG_Open isPPI_Open:(BOOL)isPPI_Open
{
    isSet = NO;
    char b[] = {CMD_DEVICE_Measurement,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[1] = dataType;
    if(isOpen==YES)
        b[2] = 1;
    if(isPPG_Open==YES)
        b[3] = 1;
    if(isPPI_Open==YES)
        b[4] = 1;
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method StartECGMode
 *  @discussion 开启ECG监测
 *
 */

-(NSMutableData*)StartECGMode
{
    char b[] = {CMD_ECG_PPG_START,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method StopECGMode
 *  @discussion 关闭ECG监测
 *
 */
-(NSMutableData*)StopECGMode
{
    char b[] = {CMD_ECG_PPG_STOP,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetECGHistoryDataWithType
 *  @param type (0-9) (最近10条的ECG历史数据)
 *  @discussion 获取手环测试的ECG历史数据
 *
 */
-(NSMutableData*)GetECGHistoryDataWithType:(int16_t)type withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_ECG_HISTORY_DATA,0,type,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(type==0x99)
    {
        b[1]=0x99;
        b[2] = 0;
        isDelete = YES;
    }
    if(startDate)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method ppgWithMode::
 *  @param ppgMode  1 表示开启ppg测量   2表示给设备发送测量结果  3表示停止ppg测量  4表示给设备发送ppg测量的进度  5表示退出ppg测量
 *  @param ppgStatus 当 ppgMode=2或者 ppgMode=4的时候才有效。当ppgMode=2时，0表示测量失败  1 表示测量结果偏低  2表示测量结果正常 3表示测量结果偏高 。 当ppgMode=4时，ppgStatus表示测量的进度值，范围是0-100
 *  @discussion Turn on ECG measurement 开启ECG测量
 *
 */
-(NSMutableData*)ppgWithMode:(int)ppgMode  ppgStatus:(int)ppgStatus
{
    char b[] = {CMD_PPG_Measurement,ppgMode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(ppgMode==2||ppgMode==4)
        b[2] = ppgStatus;
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method GetTotalActivityDataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有运动总数据
 *  @discussion 获取运动总数据
 *
 */
-(NSMutableData*)GetTotalActivityDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_TOTAL_STEP,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
        isDelete = YES;
    if(startDate)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetDetailActivityDataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有运动数据
 *  @discussion 获取运动详细数据
 *
 */
-(NSMutableData*)GetDetailActivityDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_DETAIL_STEP,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetDetailSleepDataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有睡眠数据
 *  @discussion 获取睡眠详细数据
 *
 */
-(NSMutableData*)GetDetailSleepDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_DETAIL_SLEEP,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetDynamicHRWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有动态心率总数据
 *  @discussion 获取动态心率
 *
 */
-(NSMutableData*)GetContinuousHRDataWithMode:(int)mode  withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_HEART,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method GetStaticHRWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有静态心率数据
 *  @discussion 获取静态心率
 *
 */
-(NSMutableData*)GetSingleHRDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_SINGLE_HEART,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}



/*!
 *  @method GetHRVDataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有HRV数据
 *  @discussion 获取HRV监测数据
 *
 */
-(NSMutableData*)GetHRVDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_HRV,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method GetActivityModeDataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有多模式运动数据
 *  @discussion 获取多模式运动数据
 *
 */
-(NSMutableData*)GetActivityModeDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_ACTIVITY_DATA,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetAutomaticSpo2DataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有自动血氧历史数据
 *  @discussion 获取自动Spo2历史数据
 *
 */
-(NSMutableData*)GetAutomaticSpo2DataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_AUTOMATIC_SPO2_DATA,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
        isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method GetManualSpo2DataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有手动血氧历史数据
 *  @discussion 获取手动Spo2历史数据
 *
 */
-(NSMutableData*)GetManualSpo2DataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
    char b[] = {CMD_GET_SPO2_DATA,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
     if(mode==0x99)
            isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
     b[15] = [self CRCWithData:b length:16];
     NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
     return data;
}

-(NSMutableData*)GetTemperatureDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
   char b[] = {CMD_GET_TEMPERATURE_DATA,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method GetAxillaryTemperatureDataWithMode:
 *  @param mode   0:表示是从最新的位置开始读取(最多50组数据)  2:表示接着读取(当数据总数大于50的时候) 0x99:表示删除所有多模式运动数据
 *  @discussion 获取腋下测量温度的历史数据
 *
 */
-(NSMutableData*)GetAxillaryTemperatureDataWithMode:(int)mode withStartDate:(NSDate*)startDate
{
  char b[] = {CMD_GET_AXILLARY_TEMPERATURE_DATA,mode,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(mode==0x99)
           isDelete = YES;
    if(startDate!=nil)
    {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSDateComponents * conponent = [cal components:unitFlags fromDate:startDate];
        NSInteger year = [conponent year]-2000;
        NSInteger month = [conponent month];
        NSInteger day = [conponent day];
        NSInteger hour = [conponent hour];
        NSInteger minute = [conponent minute];
        NSInteger second = [conponent second];
        b[4] = year + year/10*6;
        b[5] = month + month/10*6;
        b[6] = day + day/10*6;
        b[7] = hour + hour/10*6;
        b[8] = minute + minute/10*6;
        b[9] = second + second/10*6;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}


/*!
 *  @method ClearAllHistoryData
 *  @discussion  Clear all historical data  清除所有历史数据
 *
 */
-(NSMutableData*)ClearAllHistoryData
{
    char b[] = {CMD_CLEAR_ALL_DATA,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}




/*!
 *  @method EnterActivityMode:
 *  @param activityMode   运动模式
 *  @discussion 进入多运动模式
 *
 */
-(NSMutableData*)EnterActivityMode:(ACTIVITYMODE)activityMode WorkMode:(int)WorkMode BreathParameter:(MyBreathParameter)breathParameter
{
    char b[] = {CMD_ENTER_ACTIVITY_MODE,WorkMode,activityMode,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(activityMode==6)
    {
        b[3] =  breathParameter.breathMode;
        b[4] = breathParameter.DurationOfBreathingExercise;
    }
    
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method AppSendToDevice:
 *  @param distance   距离
 *  @param pace_Minutes   配速:分钟
 *  @param pace_Seconds   配速:秒
 *  @param GPS_SignalStrength   机GPS信号强度
 *  @discussion 当手环是通过APP进入多运动模式后，APP必须每隔1秒发送一个数据给手环，否则手环会退出多运动模式
 *
 */
-(NSMutableData*)AppSendToDevice:(float)distance pace_Minutes:(int)pace_Minutes pace_Seconds:(int)pace_Seconds GPS_SignalStrength:(int)GPS_SignalStrength
{
    char b[] = {CMD_PACKAGE_APP,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    memcpy(b+1, &distance,4);
    memcpy(b+5, &pace_Minutes, 1);
    memcpy(b+6, &pace_Seconds, 1);
    memcpy(b+7, &GPS_SignalStrength, 1);
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method EnterTakePhotoMode
 *  @discussion 进入拍照模式
 *
 */
-(NSMutableData*)EnterTakePhotoMode
{
    char b[] = {CMD_TAKEPHOTO_MODE,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}
/*!
 *  @method BachHomeView
 *  @discussion 返回主界面
 *
 */
-(NSMutableData*)BachHomeView
{
   char b[] = {CMD_BACK_HOME,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}






/*!
 *  @method StartECGAndPPGWithMode:
 *  @param startMode  Yes:Start NO:Stop
 *  @param colorOfSkinLevel  color of skin: white(1)~black(15) default is 4
 *  @param needBPCalibration  whether to turn on blood pressure calibration
 *  @param BPCalibrationInfo if needBPCalibration is YES,the correct value must be entered here, and if  needBPCalibration is no,you can ignore it.
 *  @discussion 开启或者关闭ECG和PPG监测
 *
 */

-(NSMutableData*)StartECGAndPPGWithMode:(BOOL)startMode ColorOfSkinLevel:(int)colorOfSkinLevel NeedBPCalibration:(BOOL)needBPCalibration BPCalibrationInfo:(  MyBPCalibrationParameter)BPCalibrationInfo
{
    if(arrayPPG_X==nil)
        arrayPPG_X = [[NSMutableArray alloc] init];
    [arrayPPG_X removeAllObjects];
    if(arrayPPG_Y==nil)
        arrayPPG_Y = [[NSMutableArray alloc] init];
    [arrayPPG_Y removeAllObjects];
    for (int i = 0; i<3; i++) {
        [arrayPPG_Y addObject:@(0)];
    }
    
    char b[] = {CMD_ECG_PPG_START,colorOfSkinLevel,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(startMode==NO)
    {
        b[0] = CMD_ECG_PPG_STOP;
        b[1] = 0;
    }
    if(needBPCalibration==YES)
    {
        b[2] = 1;
        b[3]  = BPCalibrationInfo.gender;
        b[4]  = BPCalibrationInfo.age;
        b[5]  = BPCalibrationInfo.height;
        b[6]  = BPCalibrationInfo.weight;
        b[7]  = BPCalibrationInfo.BP_high;
        b[8]  = BPCalibrationInfo.BP_low;
        b[9]  = BPCalibrationInfo.heartRate;
    }
    b[15] = [self CRCWithData:b length:16];
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
    return data;
}

/*!
 *  @method openRRIntervalTime:
 *   @param open  YES means open, NO means close YES表示开启，NO表示关闭
 *  @discussion The RR interval is the interval between two heartbeats. After it is turned on, it will be returned when measuring HRV  RR间隔就是两个心跳之间的间隔。开启之后，测量HRV的时候就会回传
 *
 */
-(NSMutableData*)openRRIntervalTime:(BOOL)open
{
    isSet = YES;
    char b[] = {CMD_RR_INTERVAL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    if(open==YES)
    {
        isSet = YES;
        b[1] = 1;
    }
     b[15] = [self CRCWithData:b length:16];
     NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:16];
     return data;
}



#pragma mark ECG PPG

//PPG算法
-(float)getPPGWithOriginalData:(int)originalData
{
    float x1 = ((NSNumber*)arrayPPG_X[0]).floatValue;
    float x3 = ((NSNumber*)arrayPPG_X[2]).floatValue;
    float y1 = ((NSNumber*)arrayPPG_Y[0]).floatValue;
    float y2 = ((NSNumber*)arrayPPG_Y[1]).floatValue;
    float b1 = 0.0268 ,b3 = -0.0268;
    float a2 = -1.9447, a3 = 0.9465;
    float temp =  b1*x1 + b3*x3 - a2*y1-a3*y2;
    return temp;
}


-(DeviceData*)DataParsingWithData:(NSData*)bleData
{
    DeviceData * deviceData = [[DeviceData alloc] init];
    Byte *byte = (Byte *)[bleData bytes];
    switch (byte[0]) {
        case CMD_GET_TIME:
        {
            deviceData.dataType = GetDeviceTime;
            NSString * strDeviceTime = [NSString stringWithFormat:@"20%02x-%02x-%02x %02x:%02x:%02x",byte[1],byte[2],byte[3],byte[4],byte[5],byte[6]];
            NSDictionary * dicData = @{@"deviceTime":strDeviceTime};
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_TIME:
        {
            deviceData.dataType = SetDeviceTime;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_INFO:
        {
            NSNumber * MyGender= [NSNumber numberWithInt:byte[1]];
            NSNumber * MyAge = [NSNumber numberWithInt:byte[2]];
            NSNumber * MyHeight = [NSNumber numberWithInt:byte[3]];
            NSNumber * MyWeight = [NSNumber numberWithInt:byte[4]];
            NSNumber * MyStride = [NSNumber numberWithInt:byte[5]];
            NSString * strID = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x",byte[6],byte[7],byte[8],byte[9],byte[10],byte[11]];
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:MyGender,@"gender",MyAge,@"age",MyHeight,@"height",MyWeight,@"weight",MyStride,@"stride",strID,@"deviceID",nil];
            deviceData.dataType = GetPersonalInfo;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_INFO:
        {
            deviceData.dataType = SetPersonalInfo;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_DEVICE_INFO:
        {
            
           
            
            NSNumber * distancUnit = [NSNumber numberWithInt:byte[1]];
            NSNumber * timeUnit = [NSNumber numberWithInt:byte[2]];
            NSNumber * wristOn = [NSNumber numberWithInt:byte[3]];
            NSNumber * temperatureUnit = [NSNumber numberWithInt:byte[4]];
            NSNumber * notDisturbMode = [NSNumber numberWithInt:byte[5]];
            NSNumber * ANCS = [NSNumber numberWithInt:byte[6]];
//            NSNumber * remindType = [NSNumber numberWithInt:byte[7]];
//            NSNumber * remindType1 = [NSNumber numberWithInt:byte[8]];
            
            NSNumber * numberCall = [NSNumber numberWithInt: (byte[7]&(1<<0))>0?1:0];
            NSNumber * numberSMS = [NSNumber numberWithInt: (byte[7]&(1<<1))>0?1:0];
            NSNumber * numberWechat = [NSNumber numberWithInt: (byte[7]&(1<<2))>0?1:0];
            NSNumber * numberFacebook = [NSNumber numberWithInt: (byte[7]&(1<<3))>0?1:0];
            NSNumber * numberInstagram = [NSNumber numberWithInt: (byte[7]&(1<<4))>0?1:0];
            NSNumber * numberSkype = [NSNumber numberWithInt: (byte[7]&(1<<5))>0?1:0];
            NSNumber * numberTelegram = [NSNumber numberWithInt: (byte[7]&(1<<6))>0?1:0];
            NSNumber * numberTwitter = [NSNumber numberWithInt: (byte[7]&(1<<7))>0?1:0];
            
            NSNumber * numberVkclient = [NSNumber numberWithInt: (byte[8]&(1<<0))>0?1:0];
            NSNumber * numberWhatsapp = [NSNumber numberWithInt: (byte[8]&(1<<1))>0?1:0];
            NSNumber * numberQQ = [NSNumber numberWithInt: (byte[8]&(1<<2))>0?1:0];
            NSNumber * numberIn = [NSNumber numberWithInt: (byte[8]&(1<<3))>0?1:0];
            
            NSNumber * baseHeartRate = [NSNumber numberWithInt:byte[9]];
            NSNumber * screenBrightness = [NSNumber numberWithInt:byte[11]];
            NSNumber * watchFaceStyle = [NSNumber numberWithInt:byte[12]];
            NSNumber * socialDistanceRemind = [NSNumber numberWithInt:byte[13]];
            NSNumber * language = [NSNumber numberWithInt:byte[14]];
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:distancUnit,@"distanceUnit",timeUnit,@"timeUnit",wristOn,@"wristOn",temperatureUnit,@"temperatureUnit",notDisturbMode,@"notDisturbMode",ANCS,@"ANCS",numberCall,@"call",numberSMS,@"SMS",numberWechat,@"wechat",numberFacebook,@"facebook",numberInstagram,@"instagram",numberSkype,@"skype",numberTelegram,@"telegram",numberTwitter,@"twitter",numberVkclient,@"vkclient",numberWhatsapp,@"whatsapp",numberQQ,@"qq",numberIn,@"in",baseHeartRate,@"baseHeartRate",screenBrightness,@"screenBrightness",watchFaceStyle,@"watchFaceStyle",socialDistanceRemind,@"socialDistanceRemind",language,@"language",nil];
            deviceData.dataType = GetDeviceInfo;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_DEVICE_INFO:
        {
            deviceData.dataType = SetDeviceInfo;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_DEVICE_ID:
        {
            deviceData.dataType = SetDeviceID;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_GOAL:
        {
            int goal = 0;
            memcpy(&goal, byte+1, 4);
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:goal],@"stepGoal",nil];
            deviceData.dataType = GetDeviceGoal;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_GOAL:
        {
            deviceData.dataType = SetDeviceGoal;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_QRCODE_SCREEN:
        {
            if(unLock==YES)
            {
                deviceData.dataType = unLockScreen;
                deviceData.dicData = NULL;
                deviceData.dataEnd = YES;
            }
            else
            {
                if(byte[1]>1)
                {
                    if(byte[1]==0x81)
                    deviceData.dataType = clickYesWhenUnLockScreen;
                    else
                     deviceData.dataType = clickNoWhenUnLockScreen;
                    deviceData.dicData = NULL;
                    deviceData.dataEnd = YES;
                }
                else
                {
                    deviceData.dataType = lockScreen;
                    deviceData.dicData = NULL;
                    deviceData.dataEnd = YES;
                }
            }
        }
            break;
        case CMD_GET_BATTERY:
        {
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:byte[1]],@"batteryLevel",nil];
            deviceData.dataType = GetDeviceBattery;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_MAC:
        {
            NSString * strMac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",byte[1],byte[2],byte[3],byte[4],byte[5],byte[6]].uppercaseString;
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strMac,@"macAddress", nil];
            deviceData.dataType = GetDeviceMacAddress;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_VERSION:
        {
            NSString * strVersion = [NSString stringWithFormat:@"%d%d%d%d",byte[1],byte[2],byte[3],byte[4]];
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strVersion,@"deviceVersion", nil];
            deviceData.dataType = GetDeviceVersion;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_FACTORY_RESET:
        {
            deviceData.dataType = FactoryReset;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_MCU:
        {
            deviceData.dataType = MCUReset;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_MOTOR:
        {
            deviceData.dataType = MotorVibration;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_DEVICE_NAME:
        {
            NSString * strName = @"";
            for (int i = 1 ; i<bleData.length-1; i++)
            strName  = [strName stringByAppendingString:[NSString stringWithFormat:@"%c",byte[i]]];
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strName,@"deviceName", nil];
            deviceData.dataType = GetDeviceName;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_DEVICE_NAME:
        {
            deviceData.dataType = SetDeviceName;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_NOTIFY:
        {
            deviceData.dataType = SetNotify;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_DEVICE_Measurement:
        {
            if(byte[1]==1||byte[1]==0)
            {
                
                /* NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",[NSNumber numberWithInt:HRV],@"hrv",[NSNumber numberWithInt:Blood],@"vascularAging",[NSNumber numberWithInt:HeartRate],@"heartRate",[NSNumber numberWithInt:Stress],@"stress",[NSNumber numberWithInt:HighPressure],@"highBP",[NSNumber numberWithInt:LowPressure],@"lowBP",nil];*/
                int heartRate = byte[2];
                int hrv = byte[4];
                int stress = byte[5];
                int highBP = byte[6];
                int lowBP = byte[7];
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:hrv],@"hrv",[NSNumber numberWithInt:heartRate],@"heartRate",[NSNumber numberWithInt:stress],@"stress",[NSNumber numberWithInt:highBP],@"highBP",[NSNumber numberWithInt:lowBP],@"lowBP",nil];
                deviceData.dataType = DeviceMeasurement_HRV;
                deviceData.dicData = dicData;
                if(byte[1]==1)
                    deviceData.dataEnd = NO;
                else
                    deviceData.dataEnd = YES;
                
                
            }
            else if(byte[1]==2)
            {
                int heartRate = byte[2];
                deviceData.dataType = DeviceMeasurement_HR;
                deviceData.dicData = @{@"heartRate":[NSNumber numberWithInt:heartRate]};
                deviceData.dataEnd = YES;
            }
            else if(byte[1]==3)
            {
                int spo2 = byte[3];
                deviceData.dataType = DeviceMeasurement_Spo2;
                deviceData.dicData = @{@"spo2":[NSNumber numberWithInt:spo2]};
                deviceData.dataEnd = YES;
            }
            else
            {
                deviceData.dataType = DataError;
                deviceData.dicData = NULL;
                deviceData.dataEnd = YES;
            }
        }
            break;
        case CMD_GET_AUTO_HEART:
        {
            NSNumber * workMode = [NSNumber numberWithInt:byte[1]];
            NSString * strStartTime = [NSString stringWithFormat:@"%02x:%02x",byte[2],byte[3]];
            NSString * strEndTime = [NSString stringWithFormat:@"%02x:%02x",byte[4],byte[5]];
            NSNumber * weekValue = [NSNumber numberWithInt:byte[6]];
            NSNumber * intervalTime = [NSNumber numberWithInt:byte[7]+byte[8]*256];
            NSNumber * dataType = [NSNumber numberWithInt:byte[9]];
            NSMutableDictionary * dicData = [NSMutableDictionary dictionaryWithObjectsAndKeys:workMode,@"workMode",strStartTime,@"startTime",strEndTime,@"endTime",weekValue,@"weeks",intervalTime,@"intervalTime",dataType,@"dataType",nil];
            deviceData.dataType = GetAutomaticMonitoring;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_AUTO_HEART:
        {
            deviceData.dataType = SetAutomaticMonitoring;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_ALARM:
        {
            if(isDelete==YES)
            {
                deviceData.dataType = DeleteAllAlarmClock;
                deviceData.dicData = NULL;
                deviceData.dataEnd = YES;
            }else
            {
                int lenghtUnit = 41;
                int TotalLength = (int)bleData.length;
                NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
                for (int i =0; i<TotalLength/lenghtUnit; i++) {
                    NSNumber * clockOpenOrClose = [NSNumber numberWithInt:byte[i*lenghtUnit+5]];
                    NSNumber * clockType = [NSNumber numberWithInt:byte[i*lenghtUnit+6]];
                    NSString * strTime = [NSString stringWithFormat:@"%02x:%02x",byte[i*lenghtUnit+7],byte[i*lenghtUnit+8]];
                    NSNumber * weekValue = [NSNumber numberWithInt:byte[i*lenghtUnit+9]];
                    NSNumber * textLenght = [NSNumber numberWithInt:byte[i*lenghtUnit+10]];
                    NSString * strText = @"";
                    for (int j =11 ; j <(11+textLenght.intValue); j++)
                    strText = [strText stringByAppendingString:[NSString stringWithFormat:@"%c",byte[i*lenghtUnit+j]]];
                    NSDictionary * dicClock = [NSDictionary dictionaryWithObjectsAndKeys:clockOpenOrClose,@"openOrClose",clockType,@"clockType",strTime,@"clockTime",weekValue,@"week",strText,@"text",textLenght,@"textLenght",nil];
                    [arrayTemp addObject:dicClock];
                }
                NSDictionary * dicData = @{@"arrayAlarmClock":arrayTemp};
                
                deviceData.dataType = GetAlarmClock;
                deviceData.dicData = dicData;
                deviceData.dataEnd = TotalLength%lenghtUnit==0?NO:YES;
            }
        }
            break;
        case CMD_SET_ALARM:
        {
            deviceData.dataType = SetAlarmClock;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_ACTIVITY_TIME:
        {
            NSString * strStartTime = [NSString stringWithFormat:@"%02x:%02x",byte[1],byte[2]];
            NSString * strEndTime = [NSString stringWithFormat:@"%02x:%02x",byte[3],byte[4]];
            NSNumber * weekValue = [NSNumber numberWithInt:byte[5]];
            NSNumber * intervalTimeValue = [NSNumber numberWithInt:byte[6]];
            NSNumber * leastSteps = [NSNumber numberWithInt:byte[7]];
            NSNumber * openOrClose  =[NSNumber numberWithInt:byte[8]];
            NSMutableDictionary * dicData = [NSMutableDictionary dictionaryWithObjectsAndKeys:strStartTime,@"startTime",strEndTime,@"endTime",weekValue,@"weeks",intervalTimeValue,@"intervalTime",leastSteps,@"leastSteps",openOrClose,@"openOrClose",nil];
            deviceData.dataType = GetSedentaryReminder;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_ACTIVITY_TIME:
        {
            deviceData.dataType = SetSedentaryReminder;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SOCIAL_DISTANCE_REMINDER:
        {
            if(isGet==YES)
            {
                char signalValue = byte[4];
                deviceData.dataType = GetSocialDistanceReminder;
                NSDictionary * dicSocialDistance = @{@"scanInterval":@(byte[2]),@"scanTime":@(byte[3]),@"signalStrength":@(signalValue)};
                deviceData.dicData = dicSocialDistance;
                deviceData.dataEnd = YES;
            }
            else
            {
                deviceData.dataType = SetSocialDistanceReminder;
                deviceData.dicData = NULL;
                deviceData.dataEnd = YES;
            }
        }
            break;
        case CMD_STEP:
        {
            int step = 0,calories = 0,distance = 0,time =0,StrengthTrainingTime = 0,heartRate=0,temperature = 0;
            memcpy(&step, byte+1, 4);
            memcpy(&calories, byte+5, 4);
            memcpy(&distance, byte+9, 4);
            memcpy(&time, byte+13, 4);
            memcpy(&StrengthTrainingTime, byte+17, 4);
            memcpy(&heartRate, byte+21, 1);
            memcpy(&temperature, byte+22, 2);
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:step],@"step",[NSNumber numberWithFloat:calories*0.01],@"calories",[NSNumber numberWithFloat:distance*0.01],@"distance",[NSNumber numberWithInt:time/60],@"exerciseMinutes",[NSNumber numberWithInt:StrengthTrainingTime],@"activeMinutes",[NSNumber numberWithInt:heartRate],@"heartRate",[NSNumber numberWithFloat:temperature*0.1],@"temperature",nil];
            deviceData.dataType = RealTimeStep;
            deviceData.dicData = dicData;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_SET_WEATHER:
        {
            deviceData.dataType = setWeather;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_TOTAL_STEP:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int tempLength = 27;
            for (int i = 0; i<length/tempLength; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x",byte[tempLength*i+2],byte[tempLength*i+3],byte[tempLength*i+4]];
                int step = 0;
                int time = 0;
                int distance = 0;
                int calories = 0;
                int goal = 0;
                int StrengthTrainingTime = 0;
                memcpy(&step, byte+(5+tempLength*i), 4);
                memcpy(&time, byte+(9+tempLength*i), 4);
                memcpy(&distance, byte+(13+tempLength*i),4);
                memcpy(&calories, byte+(17+tempLength*i),4);
                memcpy(&goal, byte+(21+tempLength*i), 2);
                memcpy(&StrengthTrainingTime, byte+(23+tempLength*i), 4);
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",[NSNumber numberWithInt:step],@"step",[NSNumber numberWithInt:time/60],@"exerciseMinutes",[NSNumber numberWithFloat:distance*0.01],@"distance",[NSNumber numberWithFloat:calories*0.01],@"calories",[NSString stringWithFormat:@"%d%%",goal],@"goal",[NSNumber numberWithInt:StrengthTrainingTime],@"activeMinutes",nil];
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = TotalActivityData;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arrayTotalActivityData":arrayTemp};
            deviceData.dataEnd = length%tempLength==0?NO:YES;
        }
            break;
        case CMD_GET_DETAIL_STEP:
        {
            int length = (int)bleData.length;
            int tempLength =25;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            for (int i = 0; i<length/tempLength; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[tempLength*i+3],byte[tempLength*i+4],byte[tempLength*i+5],byte[tempLength*i+6],byte[tempLength*i+7],byte[tempLength*i+8]];
                int step = 0, calories = 0 , distance = 0;
                memcpy(&step, byte+(tempLength*i)+9, 2);
                memcpy(&calories, byte+(tempLength*i)+11, 2);
                memcpy(&distance, byte+(tempLength*i)+13, 2);
                
                NSMutableArray * arrayStep  = [[NSMutableArray alloc] init];
                for (int j = 15; j<=24; j++)
                [arrayStep addObject:[NSNumber numberWithInt:byte[j+tempLength*i]]];
                NSDictionary * dicData = @{@"date":strDate,@"step":@(step),@"calories":@(calories*0.01),@"distance":@(distance*0.01),@"arraySteps":arrayStep};
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = DetailActivityData;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arrayDetailActivityData":arrayTemp};
            deviceData.dataEnd = length%tempLength==0?NO:YES;
        }
            break;
        case CMD_GET_DETAIL_SLEEP:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int lengthUnit = 34;
            if(length==130||length==132)
                lengthUnit = 130;
            for (int i = 0; i<length/lengthUnit; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                int sleepLength = byte[lengthUnit*i+9];
                NSMutableArray * arraySleep  = [[NSMutableArray alloc] init];
                for (int j = 10; j<10+sleepLength; j++)
                    [arraySleep addObject:[NSNumber numberWithInt:byte[j+lengthUnit*i]]];
                NSDictionary * dicData = @{@"startTime_SleepData":strDate,@"totalSleepTime":@(lengthUnit==34?sleepLength*5:sleepLength),@"arraySleepQuality":arraySleep,@"sleepUnitLength":@(lengthUnit==34?5:1)};
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = DetailSleepData;
            if(isDelete==YES)
               deviceData.dicData =NULL;
            else
            deviceData.dicData = @{@"arrayDetailSleepData":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
        }
            break;
        case CMD_GET_HEART:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int lengthUnit = 24;
            for (int i = 0; i<length/lengthUnit; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                NSMutableArray * arrayDynamic  = [[NSMutableArray alloc] init];
                for (int j = 9; j<24; j++)
                [arrayDynamic addObject:[NSNumber numberWithInt:byte[j+lengthUnit*i]]];
                NSDictionary * dicData = @{@"date":strDate,@"arrayHR":arrayDynamic};
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = DynamicHR;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arrayContinuousHR":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
        }
            break;
        case CMD_GET_SINGLE_HEART:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int lengthUnit = 10;
            for (int i = 0; i<length/lengthUnit; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                NSNumber * staticHR = [NSNumber numberWithInt:byte[lengthUnit*i+9]];
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",staticHR,@"singleHR",nil];
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = StaticHR;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arraySingleHR":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
            
        }
            break;
        case CMD_GET_SPO2_DATA:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            
            [arrayTemp removeAllObjects];
            int lengthUnit = 10;
            int number = 0;
            for (int i = 0; i<length/lengthUnit; i++) {
                number   = byte[1+lengthUnit*i]+byte[2+lengthUnit*i]*256;
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                
                NSNumber * spo2 = [NSNumber numberWithInt:byte[lengthUnit*i+9]];
                
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",spo2,@"manualSpo2Data",nil];//manualSpo2Data
                [arrayTemp addObject:dicData];
                
            }
            deviceData.dataType = ManualSpo2Data;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arrayManualSpo2Data":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
        }
            break;
        case CMD_GET_AUTOMATIC_SPO2_DATA:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            
            [arrayTemp removeAllObjects];
            int lengthUnit = 10;
            int number = 0;
            for (int i = 0; i<length/lengthUnit; i++) {
                number   = byte[1+lengthUnit*i]+byte[2+lengthUnit*i]*256;
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                
                NSNumber * spo2 = [NSNumber numberWithInt:byte[lengthUnit*i+9]];
                
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",spo2,@"automaticSpo2Data",nil];
                [arrayTemp addObject:dicData];
                
            }
            deviceData.dataType = AutomaticSpo2Data;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arrayAutomaticSpo2Data":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
        }
            break;
        case CMD_GET_TEMPERATURE_DATA:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int lengthUnit = 11;
            for (int i = 0; i<length/lengthUnit; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                NSNumber * temperature = [NSNumber numberWithInt:byte[lengthUnit*i+9]+byte[lengthUnit*i+10]*256];
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",@(temperature.intValue*0.1),@"temperature",nil];
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = TemperatureData;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arrayemperatureData":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
        }
            break;
        case CMD_GET_AXILLARY_TEMPERATURE_DATA:
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int lengthUnit = 11;
            for (int i = 0; i<length/lengthUnit; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                NSNumber * temperature = [NSNumber numberWithInt:byte[lengthUnit*i+9]+byte[lengthUnit*i+10]*256];
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",@(temperature.intValue*0.1),@"axillaryTemperature",nil];
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = AxillaryTemperatureData;
            if(isDelete==YES)
                deviceData.dicData =NULL;
            else
                deviceData.dicData = @{@"arrayAxillaryTemperatureData":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
        }
            break;
        case CMD_GET_ACTIVITY_DATA :
        {
            int length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int lengthUnit = 25;
            for (int i = 0; i<length/lengthUnit; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                NSString * strType = [NSString stringWithFormat:@"%d",byte[lengthUnit*i+9]];
                int HR = 0,ActivityTime =0,ActivityStep =0,ActivitySpeed = 0;
                float calories = 0,distance = 0;
                memcpy(&HR, byte+10+lengthUnit*i, 1);
                memcpy(&ActivityTime,byte+11+lengthUnit*i,2);
                memcpy(&ActivityStep,byte+13+lengthUnit*i,2);
                memcpy(&ActivitySpeed,byte+15+lengthUnit*i,2);
                memcpy(&calories,byte+17+lengthUnit*i,4);
                memcpy(&distance,byte+21+lengthUnit*i,4);
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",[NSNumber numberWithInt:strType.intValue],@"activityMode",[NSNumber numberWithInt:HR],@"heartRate",[NSNumber numberWithInt:ActivityTime],@"activeMinutes",[NSNumber numberWithInt:ActivityStep],@"step",[NSNumber numberWithFloat:calories],@"calories",[NSNumber numberWithFloat:distance],@"distance",@(ActivitySpeed%256),@"paceMinutes",@(ActivitySpeed/256),@"paceSeconds",nil];
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType = ActivityModeData;
            deviceData.dicData = @{@"arrayActivityModeData":arrayTemp};
            
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
            
        }
            break;
        case CMD_ENTER_ACTIVITY_MODE:
        {
            NSString * strStartTime = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[2],byte[3],byte[4],byte[5],byte[6],byte[7]];
            if(byte[2]==0)
            {
                deviceData.dataType = QuitActivityMode;
                deviceData.dicData = NULL;
            }
            else
            {
                deviceData.dataType = EnterActivityMode;
                deviceData.dicData = @{@"enterActivityModeSuccess":@(byte[1]==1?YES:NO),@"startTime":strStartTime};
            }
            
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_PACKAGE_DEVICE:
        {
            int Step =0, time =0;
            float Calories = 0;
            memcpy(&Step, byte+2,4);
            memcpy(&Calories, byte+6, 4);
            memcpy(&time, byte+10, 4);
            NSNumber * numberHR = [NSNumber numberWithInt:(byte[1]==0xff?0:byte[1])];
            NSNumber * numberStep = [NSNumber numberWithInt:Step];
            NSNumber * numberCalories = [NSNumber numberWithFloat:Calories];
            NSNumber * numberTime = [NSNumber numberWithInt:time];
            NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:numberHR,@"heartRate", numberStep,@"step",numberCalories,@"calories",numberTime,@"activeMinutes",nil];
            deviceData.dataType = DeviceSendDataToAPP;
            deviceData.dicData = dicData;
            deviceData.dataEnd = byte[1]==0xff?YES:NO;
        }
            break;
        case CMD_TAKEPHOTO_MODE:
        {
            deviceData.dataType = EnterTakePhotoMode;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_BACK_HOME:
        {
            deviceData.dataType = BackHomeView;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_FUNCTION_MODE:
        {
            if(byte[1]==2)
            {
                if(byte[2]==0)
                {
                    deviceData.dataType = StartTakePhoto;
                    deviceData.dicData = NULL;
                    deviceData.dataEnd = YES;
                }
                else if (byte[2]==2)
                {
                    deviceData.dataType = StopTakePhoto;
                    deviceData.dicData = NULL;
                    deviceData.dataEnd = YES;
                }
            }
            else if(byte[1]==4)
            {
                deviceData.dataType = FindMobilePhone;
                deviceData.dicData = NULL;
                deviceData.dataEnd = YES;
            }
        }
            break;
        case CMD_S0S:
        {
            deviceData.dataType = SOS;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_GET_HRV:
        {
            int  length = (int)bleData.length;
            NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
            [arrayTemp removeAllObjects];
            int lengthUnit = 15;
            for (int i = 0; i<length/lengthUnit; i++) {
                NSString * strDate  = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[lengthUnit*i+3],byte[lengthUnit*i+4],byte[lengthUnit*i+5],byte[lengthUnit*i+6],byte[lengthUnit*i+7],byte[lengthUnit*i+8]];
                int HRV = 0,Blood =0,HeartRate =0,Stress = 0,HighPressure =0 ,LowPressure = 0;
                memcpy(&HRV, byte+9+lengthUnit*i, 1);
                memcpy(&Blood,byte+10+lengthUnit*i,1);
                memcpy(&HeartRate,byte+11+lengthUnit*i,1);
                memcpy(&Stress,byte+12+lengthUnit*i,1);
                memcpy(&HighPressure,byte+13+lengthUnit*i,1);
                memcpy(&LowPressure,byte+14+lengthUnit*i,1);
                
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",[NSNumber numberWithInt:HRV],@"hrv",[NSNumber numberWithInt:Blood],@"vascularAging",[NSNumber numberWithInt:HeartRate],@"heartRate",[NSNumber numberWithInt:Stress],@"stress",[NSNumber numberWithInt:HighPressure],@"systolicBP",[NSNumber numberWithInt:LowPressure],@"diastolicBP",nil];
                [arrayTemp addObject:dicData];
            }
            deviceData.dataType  = HRVData;
            deviceData.dicData = @{@"arrayHrvData":arrayTemp};
            deviceData.dataEnd = length%lengthUnit==0?NO:YES;
        }
            break;
        case CMD_ECG_PPG_START:
        {
            deviceData.dataType = StartECG;
            deviceData.dicData = @{@"startStatus":@(byte[1])};
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_ECG_PPG_STOP:
        {
            deviceData.dataType = StopECG;
            deviceData.dicData = @{@"startStatus":@(byte[1])};
            deviceData.dataEnd = YES;
        }
            break;
        case CMD_PPG_ECG_RESULT:
        {
            if(byte[1]==3)
            {
            
                NSString * strDate = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[10],byte[11],byte[12],byte[13],byte[14],byte[15]];
                NSNumber * numberHRV = [NSNumber numberWithInt:byte[2]];
                NSNumber * numberBlood = [NSNumber numberWithInt:byte[3]];
                NSNumber * numberHR = [NSNumber numberWithInt:byte[4]];
                NSNumber * numberStress = [NSNumber numberWithInt:byte[5]];
                NSNumber * numberHighBP = [NSNumber numberWithInt:byte[6]];
                NSNumber * numberLowBP = [NSNumber numberWithInt:byte[7]];
                NSNumber * numberMood = [NSNumber numberWithInt:byte[8]];
                NSNumber * numberBr = [NSNumber numberWithInt:byte[9]];
                NSDictionary * dicData = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"date",@"---",@"blood",numberHR,@"heartRate",numberLowBP,@"---",numberHighBP,@"---",numberHRV,@"hrv",@"---",@"stress",numberMood,@"mood",@"---",@"breathingRate",nil];
                deviceData.dataType = ECG_Success_Result;
                deviceData.dicData = dicData;
                deviceData.dataEnd = YES;
            }
            else if(byte[1]==255)
            {
                deviceData.dataType = ECG_Status;
                deviceData.dicData = @{@"ecgAndPpgStatusData":@"don't move"};
                deviceData.dataEnd = NO;
            }
            else if(byte[1]==11)
            {
                deviceData.dataType = ECG_Status;
                deviceData.dicData = @{@"ecgAndPpgStatusData":@"no contact skin"};
                deviceData.dataEnd = NO;
            }
            else if(byte[1]==2||(byte[1]>=4&&byte[1]<=10))
            {
                deviceData.dataType = ECG_Failed;
                deviceData.dicData = NULL;
                deviceData.dataEnd = YES;
            }
            else
            {
                deviceData.dataType = ECG_Failed;
                deviceData.dicData = NULL;
                deviceData.dataEnd = NO;
            }
        }
            break;
        case CMD_ECG_HISTORY_DATA:
        {
            
            int length = (int)bleData.length;
            if((length==4&&byte[1]==0xff&&byte[2]==0xff)||(length==3&&byte[1]==0xff&&byte[2]==0xff)||isDelete==YES)
            {
                deviceData.dataType = ECG_HistoryData;
                deviceData.dicData = NULL;
                deviceData.dataEnd = YES;
            }
            else
            {
                int dataNumber  =  byte[2]*256+byte[1];
                if(dataNumber==0)
                {
                    NSString * strDate = [NSString stringWithFormat:@"20%02x.%02x.%02x %02x:%02x:%02x",byte[3],byte[4],byte[5],byte[6],byte[7],byte[8]];
                   int  HRV =  byte[11];
                   int  HeartRate = byte[12];
                   int  Mood = byte[13];
                    NSMutableArray * arrayECGData = [[NSMutableArray alloc] init];
                    for (int i = 0; i<(length-27)/2; i++)
                    {
                        short ecgData = 0;
                        memcpy(&ecgData, byte+27+i*2, 2);
                        [arrayECGData addObject:@(ecgData)];
                    }
                        
                    deviceData.dataType = ECG_HistoryData;
                    deviceData.dicData = @{@"dataNumber":@(dataNumber),@"strEcgDataStartTime":strDate,@"HRV":@(HRV),@"HeartRate":@(HeartRate),@"Mood":@(Mood),@"arrayEcgData":arrayECGData};
                    deviceData.dataEnd = NO;
                }
                else
                {
                    NSMutableArray * arrayECGData = [[NSMutableArray alloc] init];
                    for (int i = 0 ; i<(length-3)/2; i++) {
                        short ecgData = 0;
                        memcpy(&ecgData, byte+3+i*2, 2);
                        [arrayECGData addObject:@(ecgData)];
                    }
                    deviceData.dataType = ECG_HistoryData;
                    deviceData.dicData = @{@"dataNumber":@(dataNumber),@"arrayEcgData":arrayECGData};
                    deviceData.dataEnd = NO;
                }
            }
        }
            break;
        case CMD_ECG_RECEIVE:
        {
            int length = (int)bleData.length;
           NSMutableArray * arrayTemp = [[NSMutableArray alloc] init];
           [arrayTemp removeAllObjects];
           for (int i=1; i<=length-2; i+=2) {
               int raw = byte[i]*256 + byte[i+1];
               if( raw >= 32768 ) raw = raw - 65536;
               [arrayTemp addObject:[NSNumber numberWithInt:raw]];
           }
           deviceData.dataType = ECG_RawData;
           deviceData.dicData = @{@"arrayEcgData":arrayTemp};
           deviceData.dataEnd = NO;
        }
            break;
        case CMD_RR_INTERVAL:
        {
           
            if(isSet==YES){
                if(byte[2]==0&&(byte[1]==0||byte[1]==1))
                {
                    if(isSet==YES)
                        deviceData.dataType = openRRInterval;
                    else
                        deviceData.dataType = closeRRInterval;
                    deviceData.dicData = NULL;
                    deviceData.dataEnd = YES;
                }
                else
                {
                    deviceData.dataType = realtimeRRIntervalData;
                    deviceData.dicData = @{@"RRIntervalData":@(byte[2]*256+byte[1])};
                    deviceData.dataEnd = NO;
                }
            }
            else
            {
                deviceData.dataType = realtimePPIData;
                deviceData.dicData = @{@"PPI_Data":@(byte[2]*256+byte[1])};
                deviceData.dataEnd = NO;
            }
      
        }
            break;
        case CMD_PPG_DATA:
        {
            
            int dataLength = (int)bleData.length;
            int lengthUnit = 2;
            NSMutableArray * arrayTempPPGData = [[NSMutableArray alloc] init];
            for (int i = 0; i<(dataLength-3)/lengthUnit; i++) {
                int data =  byte[i*lengthUnit+3]*256+byte[i*lengthUnit+4];
                [arrayTempPPGData addObject:@(data)];
            }
            deviceData.dataType = realtimePPGData;
            deviceData.dicData = @{@"arrayPPGData":arrayTempPPGData};
            deviceData.dataEnd = NO;
        }
            break;
        case CMD_PPG_Measurement:
        {
            if(byte[2]==1)
            {
                if(byte[1]==0)
                    deviceData.dataType = ppgStartSucessed;
                else
                    deviceData.dataType = ppgStartFailed;
            }
            else if (byte[2]==2)
                deviceData.dataType = ppgResult;
            
            else if (byte[2]==3)
                deviceData.dataType = ppgStop;
            else if (byte[2]==4)
                deviceData.dataType = ppgMeasurementProgress;
            else
                deviceData.dataType = ppgQuit;
            
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
            
        }
            break;
        case CMD_CLEAR_ALL_DATA:
        {
            deviceData.dataType = clearAllHistoryData;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
        }
            break;
        default:
        {
            deviceData.dataType = DataError;
            deviceData.dicData = NULL;
            deviceData.dataEnd = YES;
            
        }
            break;
    }
    unLock = NO;
    isDelete = NO;
    isGet = NO;
    isSet = NO;
    return deviceData;
}
    
#pragma mark 日期转换
- (NSDate *)dateFromString:(NSString *)dateString WithStringFormat:(NSString*)strFormat{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:strFormat];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

//当前的日期的年份
-(NSInteger)GetYearFromDate:(NSDate*)date
{
   NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comps =[calender components:(  NSCalendarUnitYear) fromDate:date];
    return  [comps year];
}


//当前的日期的月份
-(NSInteger)GetMonthFromDate:(NSDate*)date
{
   NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comps =[calender components:(  NSCalendarUnitMonth) fromDate:date];
    return  [comps month];
}


//当前的日期的日
-(NSInteger)GetDayFromDate:(NSDate*)date
{
   NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comps =[calender components: NSCalendarUnitDay fromDate:date];
    return  [comps day];
}


@end
