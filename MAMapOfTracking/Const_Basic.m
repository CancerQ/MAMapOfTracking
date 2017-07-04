//
//  Const_Basic.m
//  MVVMMedicalGuestPro
//
//  Created by 叶志强 on 2016/10/28.
//  Copyright © 2016年 MVVMMedicalGuestPro. All rights reserved.
//

#import <UIKit/UIKit.h>

///---------------------
/// Tripartite Of Key
///---------------------

/**
 *  高德地图Key
 */
NSString *const MAMapServicesKey = @"5b5e1d83492ca20464efb58ede8061c9";

///---------------------
/// App Foundation Const
///---------------------
const NSInteger FirstGetCodeTime = 60;
const NSInteger SecondGetCodeTime = 120;

const CGFloat NavigationViewHeight = 64;

const CGFloat CornerRadius6 = 6;
const CGFloat CornerRadius3 = 3;
const CGFloat BorderWidth05 = 0.5;
const CGFloat BorderWidth1 = 1;

///------------
/// SAMKeychain
///------------

NSString *const ServiceName;
NSString *const RawLogin;
NSString *const Password;
NSString *const AccessToken;

///------------
/// PREFS
///------------
NSString *const PREFS_OF_BundleIdentifier = @"com.yj-health.SportApp";
NSString *const PREFS_OF_LOCATION_SERVICES = @"LOCATION_SERVICES"; //对应的定位权限设置界面

///------------------
/// NSUserDefaultsKey
///------------------
NSString *const SportSetsBoundData = @"SportSetsBoundData"; //保存未解绑过的的设备数据
NSString *const SportSetsSaveData = @"SportSetsSaveData";
NSString *const LastSportSelectDic = @"LastSportSelectDic"; //保存最后一次的运动类型
NSString *const FirstLaunch = @"FirstLaunch";
///------------------
/// NSNotificationName
///------------------

NSString *const SportRecordSaveSuccessKey = @"SportRecordSaveSuccessKey";
NSString *const StepResetKey = @"StepResetKey";//步数凌晨重置

///---------------------
/// JX_GCDTimerManagerKey
///---------------------
NSString *const TntervalHaveRateCount = @"TntervalHaveRateCount";
NSString *const GetHaveRateCountDelay = @"GetHaveRateCountDelay";
NSString *const TextFieldConsecutiveInputUpdate = @"TextFieldConsecutiveInputUpdate";
NSString *const GeneralSportProgress = @"GeneralSportProgress";
//NSString *const GetMomentStepReset = @"GetMomentStepReset";
NSString *const SportBeforeCountBackwards = @"SportBeforeCountBackwards";
NSString *const FakeRateShowInScreen = @"FakeRateShowInScreen";
