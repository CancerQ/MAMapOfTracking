//
//  Const_Basic.h
//  MVVMMedicalGuestPro
//
//  Created by 叶志强 on 2016/10/28.
//  Copyright © 2016年 MVVMMedicalGuestPro. All rights reserved.
//

///------------------
/// Speedy Definitive
///------------------

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR_TEST YES   //判断是否在模拟器还是真机运行
#else
#define SIMULATOR_TEST NO
#endif

#define isDeBugLog 1

#if (DEBUG && isDeBugLog)
#define DEBUGLOG(format, ...) do {\
fprintf(stderr, "-----------------------------------------\n");             \
fprintf(stderr, "File: %s\nFunc: %s\nLine: %d / Time: [%s]\n",         \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__func__, __LINE__, __TIME__);                                              \
fprintf(stderr, "Format:\n %s \n",                                          \
[[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);            \
fprintf(stderr, "-----------------------------------------\n\n");           \
} while (0)

#define _po(o) DEBUGLOG(@"%@", (o))
#define _pn(o) DEBUGLOG(@"%d", (o))
#define _pf(o) DEBUGLOG(@"%f", (o))
#define _ps(o) DEBUGLOG(@"CGSize: {%.0f, %.0f}", (o).width, (o).height)
#define _pr(o) DEBUGLOG(@"CGRect: {{%.0f, %.0f}, {%.0f, %.0f}}", (o).origin.x, (o).origin.y, (o).size.width, (o).size.height)

#define SAOBJ(obj)  DEBUGLOG(@"%s: %@", #obj, [(obj) description])

#define MARK    DEBUGLOG(@"\nMARK: %s, %d", __PRETTY_FUNCTION__, __LINE__)
#else
#define DEBUGLOG(format, ...) nil
#endif

#define StringIsEmpty(x) (x == nil || [x isEqualToString:@""])
#define ArrayIsEmpty(x) (x == nil || [x count] == 0)

#define GetImage(imageName) [UIImage imageNamed:imageName]

#ifndef AlertShowMsg
#define AlertShowMsg(msg, title) {UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title?:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];[alertView show];}
#endif

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

///--------
/// AppInfo
///--------

#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define APP_BUNDLE_ID [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];

///--------------
/// SystemVersion
///--------------

#ifndef SystemVersion
#define SystemVersion [UIDevice systemVersion]
#endif

#ifndef iOS7Later
#define iOS7Later (SystemVersion >= 7)
#endif

#ifndef iOS8Later
#define iOS8Later (SystemVersion >= 8)
#endif

#ifndef iOS9Later
#define iOS9Later (SystemVersion >= 9)
#endif

#ifndef iOS10Later
#define iOS10Later (SystemVersion >= 10)
#endif

#ifndef iOS11Later
#define iOS11Later (SystemVersion >= 11)
#endif

///------------
/// AppDelegate
///------------
#define SharedAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

///----------------------
/// Persistence Directory
///----------------------

#define DOCUMENT_DIRECTORY NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
#define CACHES_DIRECTORY NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

///-----------------
/// Width and Height
///-----------------

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6sPlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6plusLarge ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO)

///------
/// Color
///------

#define RGB_255(r, g, b) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define RGBAlpha_255(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HexRGBAlpha(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

//主题底色
#define ThemeColor RGB_255(242, 242, 242)
//主题色绿
#define ThemeColorGreen RGB_255(97, 206, 81)
//主题蓝色
#define ThemeColorBlue RGB_255(69, 147, 254)
//cell分割线颜色
#define SystemCellSeparatorViewColor RGB_255(198, 198, 204)

//按钮颜色
#define BtnColorNormal HexRGB(0x4eafa6)
#define BtnColorHighlight HexRGB(0x4eafa6)
#define BtnColorDisenable HexRGB(0xbcbcbc)
#define BtnTitleColorNormal [UIColor whiteColor]
//视图颜色
#define BackGroundColor HexRGB(0xefefef)
#define GrayLineColor HexRGB(0xefefef)
#define GreenBorderColor HexRGB(0x4eafa6)
#define GreenLineColor HexRGB(0x4eafa6)

#define CommonGreenColor HexRGB(0x61CE51)
#define PagerProgressColor HexRGB(0x61CE51)
//文字颜色
#define CommonBlackTitleColor HexRGB(0x333333)
#define NoteTitleRedColor HexRGB(0xd91136)
#define PagerTitleSelectColor HexRGB(0x333333)
#define NavRightTitleGrayColor RGB_255(102, 102, 102)


///-----
/// Font
///-----

#define FONT(size) [UIFont systemFontOfSize:size]

#define FontOfSize17 FONT(17.f)
#define FontOfSize16 FONT(16.f)
#define FontOfSize15 FONT(15.f)
#define FontOfSize14 FONT(14.f)
#define FontOfSize13 FONT(13.f)
#define FontOfSize12 FONT(12.f)

#define FontStandardOfNavigation FontOfSize17
#define FontStandardOfButton FontOfSize15
#define FontStandardOfLabel FontOfSize14

///-----------
/// Image Name
///-----------

#define LEFT_BACK_IMAGE_BLACK @"icon_left2"
#define LEFT_BACK_IMAGE_WHITE @"icon_left22"

///-----------
/// API Config
///-----------

#define isDebug 0
#if isDebug
#define API_BASE_URL      @""
#else
#define API_BASE_URL      @""
#endif

#define API_URL_INTERFACE_PATH @""
#define API_URL_DEFAULT_PATH [NSString stringWithFormat:@"%@/ ",API_URL_INTERFACE_PATH]
#define ApI_URL_PAY_PATH [NSString stringWithFormat:@"%@/ ",API_URL_INTERFACE_PATH]

#define API_VERSION_ARR [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] componentsSeparatedByString:@"."]

#define API_JOINT_URL [NSString stringWithFormat:@"%@%@%@.%@",API_BASE_URL,API_URL_DEFAULT_PATH,API_VERSION_ARR[0],API_VERSION_ARR[1]]

///------
/// Block
///------

typedef void (^VoidBlock)();
typedef BOOL (^BoolBlock)();
typedef int  (^IntBlock) ();
typedef id   (^IDBlock)  ();

typedef void (^VoidBlock_int)(int);
typedef BOOL (^BoolBlock_int)(int);
typedef int  (^IntBlock_int) (int);
typedef id   (^IDBlock_int)  (int);

typedef void (^VoidBlock_string)(NSString *);
typedef BOOL (^BoolBlock_string)(NSString *);
typedef int  (^IntBlock_string) (NSString *);
typedef id   (^IDBlock_string)  (NSString *);

typedef void (^VoidBlock_id)(id);
typedef BOOL (^BoolBlock_id)(id);
typedef int  (^IntBlock_id) (id);
typedef id   (^IDBlock_id)  (id);

///---------------------
/// Tripartite Of Key
///---------------------

/**
 *  高德地图Kkey
 */
extern NSString *const MAMapServicesKey;

///---------------------
/// App Foundation Const
///---------------------

extern const NSInteger FirstGetCodeTime;
extern const NSInteger SecondGetCodeTime;

extern const CGFloat NavigationViewHeight;

extern const CGFloat CornerRadius6;
extern const CGFloat CornerRadius3;
extern const CGFloat BorderWidth05;
extern const CGFloat BorderWidth1;

///------------
/// SAMKeychain
///------------

extern NSString *const ServiceName;
extern NSString *const RawLogin;
extern NSString *const Password;
extern NSString *const AccessToken;

///------------
/// PREFS
///------------
extern NSString *const PREFS_OF_BundleIdentifier; //对应的app设置界面
extern NSString *const PREFS_OF_LOCATION_SERVICES; //对应的定位权限设置界面

///------------------
/// NSUserDefaultsKey
///------------------
extern NSString *const SportSetsSaveData; //连接并保存过的设备
extern NSString *const SportSetsBoundData; //保存未解绑过的的设备数据
extern NSString *const LastSportSelectDic; //保存最后一次的运动类型
extern NSString *const FirstLaunch;//保存是否是第一次使用APP
///------------------
/// NSNotificationName
///------------------

extern NSString *const SportRecordSaveSuccessKey;
extern NSString *const StepResetKey;//步数凌晨重置

///---------------------
/// JX_GCDTimerManagerKey
///---------------------

extern NSString *const TntervalHaveRateCount; //心率时间间隔时间
extern NSString *const GetHaveRateCountDelay; // 心率延迟获取
extern NSString *const TextFieldConsecutiveInputUpdate; //输入间隔
extern NSString *const GeneralSportProgress; //通用运动
//extern NSString *const GetMomentStepReset;//步数凌晨重置
extern NSString *const SportBeforeCountBackwards; //运动开始前倒数
extern NSString *const FakeRateShowInScreen; //其它运动的假心率的显示
