//
//  BleSDK_Header.h
//  BleSDK
//
//  Created by yang sai on 2022/4/27.
//

#ifndef BleSDK_Header_h
#define BleSDK_Header_h


typedef NS_ENUM(NSInteger, DATATYPE) {
    GetDeviceTime = 0,
    SetDeviceTime = 1,
    GetPersonalInfo = 2,
    SetPersonalInfo = 3,
    GetDeviceInfo = 4,
    SetDeviceInfo = 5,
    SetDeviceID = 6,
    GetDeviceGoal = 7,
    SetDeviceGoal = 8,
    GetDeviceBattery = 9,
    GetDeviceMacAddress = 10,
    GetDeviceVersion = 11,
    FactoryReset = 12,
    MCUReset = 13,
    MotorVibration = 14,
    GetDeviceName = 15,
    SetDeviceName = 16,
    GetAutomaticMonitoring = 17,
    SetAutomaticMonitoring = 18,
    GetAlarmClock = 19,
    SetAlarmClock = 20,
    DeleteAllAlarmClock = 21,
    GetSedentaryReminder = 22,
    SetSedentaryReminder = 23,
    RealTimeStep = 24,
    TotalActivityData = 25,
    DetailActivityData = 26,
    DetailSleepData = 27,
    DynamicHR = 28,
    StaticHR = 29,
    ActivityModeData = 30,
    EnterActivityMode = 31,
    QuitActivityMode = 32,
    DeviceSendDataToAPP = 33,
    EnterTakePhotoMode = 34,
    StartTakePhoto = 35,
    StopTakePhoto = 36,
    BackHomeView = 37,
    HRVData = 38,
    GPSData = 39,
    SetSocialDistanceReminder = 40,
    GetSocialDistanceReminder = 41,
    AutomaticSpo2Data = 42,
    ManualSpo2Data = 43,
    FindMobilePhone = 44,
    TemperatureData = 45,
    AxillaryTemperatureData = 46,
    SOS  =  47,
    ECG_HistoryData = 48,
 
    StartECG = 49,
    StopECG  = 50,
    ECG_RawData = 51,
    ECG_Success_Result  = 52,
    ECG_Status  = 53,
    ECG_Failed =  54,
    DeviceMeasurement_HR =  55,
    DeviceMeasurement_HRV =  56,
    DeviceMeasurement_Spo2 =  57,
    unLockScreen = 58,
    lockScreen = 59,
    clickYesWhenUnLockScreen = 60,
    clickNoWhenUnLockScreen = 61,
    setWeather  =  62,
    openRRInterval  =  63,
    closeRRInterval  =  64,
    realtimeRRIntervalData  =  65,
    realtimePPIData  =  66,
    realtimePPGData  =  67,
    ppgStartSucessed = 68,
    ppgStartFailed = 69,
    ppgResult = 70,
    ppgStop = 71,
    ppgQuit = 72,
    ppgMeasurementProgress = 73,
    clearAllHistoryData = 74,
    SetNotify = 75,
    
    DataError =  255
};



typedef struct DeviceTime {
    int year;
    int month;
    int day;
    int hour;
    int minute;
    int second;
} MyDeviceTime;

typedef struct PersonalInfo {
    int gender;
    int age;
    int height;
    int weight;
    int stride;
} MyPersonalInfo;

typedef struct NotificationType {
    int call;
    int SMS;
    int wechat;
    int facebook;
    int instagram;
    int skype;
    int telegram;
    int twitter;
    int vkclient;
    int whatsapp;
    int qq;
    int In;
} MyNotificationType;

typedef struct DeviceInfo {
    int distanceUnit;
    int timeUnit;
    int wristOn;
    int temperatureUnit;
    int notDisturbMode;
    int ANCS;
    MyNotificationType notificationType;
    int baseHeartRate;
    int screenBrightness;
    int watchFaceStyle;
    int socialDistanceRemind;
    int language;
} MyDeviceInfo;




typedef struct Weeks {
    BOOL sunday;
    BOOL monday;
    BOOL Tuesday;
    BOOL Wednesday;
    BOOL Thursday;
    BOOL Friday;
    BOOL Saturday;
} MyWeeks;


/**
 AutomaticMonitoring
 mode:工作模式，0：关闭  1:时间段工作方式，2： 时间段内间隔工作方式
 startTime_Hour: 开始时间的小时
 startTime_Minutes: 开始时间的分钟
 endTime_Hour:
*/

typedef struct AutomaticMonitoring {
    int mode;
    int startTime_Hour;
    int startTime_Minutes;
    int endTime_Hour;
    int endTime_Minutes;
     MyWeeks weeks;
    int intervalTime;
    int dataType;// 1 means heartRate  2 means spo2  3 means temperature  4 means HRV
} MyAutomaticMonitoring;

typedef struct SedentaryReminder {
    int startTime_Hour;
    int startTime_Minutes;
    int endTime_Hour;
    int endTime_Minutes;
    MyWeeks weeks;
    int intervalTime;
    int leastSteps;
    int mode;
} MySedentaryReminder;

typedef struct AlarmClock {
    int openOrClose;
    int clockType;
    int endTime_Hour;
    int endTime_Minutes;
    int weeks;
    int intervalTime;
    int leastSteps;
    int mode;
} MyAlarmClock;

typedef struct BPCalibrationParameter {
    int gender;
    int age;
    int height;
    int weight;
    int BP_high;
    int BP_low;
    int heartRate;
} MyBPCalibrationParameter;


typedef struct WeatherParameter {
    int weatherType;
    int currentTemperature;
    int highestTemperature;
    int lowestTemperature;
    NSString * strCity;
} MyWeatherParameter;

typedef struct BreathParameter {
    int breathMode;
    int DurationOfBreathingExercise;
} MyBreathParameter;

typedef struct SocialDistanceReminder {
    char scanInterval;
    char scanTime;
    char signalStrength;
} MySocialDistanceReminder;

typedef struct Notifier {
    int type;
    NSString *info;
    NSString *title;
} MyNotifier;

typedef NS_ENUM(NSInteger, ACTIVITYMODE) {
    Run = 0,
    Cycling    = 1,
    Badminton = 2,
    Football    = 3,
    Tennis = 4,
    Yoga    = 5,
    Breath = 6,
    Dance    = 7,
    Basketball = 8,
    Walk    = 9,
    Workout    = 10,
    Cricket    = 11,
    Hiking    = 12,
    Aerobics    = 13,
    PingPong    = 14,
    RopeJump    = 15,
    SitUps    = 16,
    Volleyball    = 17
};

#endif /* BleSDK_Header_h */
