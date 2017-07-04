//
//  Record.h
//  MAMapOfTracking
//
//  Created by 叶志强 on 2017/6/19.
//  Copyright © 2017年 CancerQ. All rights reserved.
//

#import <Foundation/Foundation.h>


@import CoreLocation;
@interface Record : NSObject

- (NSArray *)speedColors; //轨迹颜色

- (float)fineSpeed; //最后的速度（实时的速度）

- (NSString *)oneKilometerSpeed; //最后的速度（实时的速度）min/km

- (NSString *)startTimeHHss;  //开始时间

- (NSString *)endTimeHHss; // 结束时间

- (CLLocation *)startLocation; //开始位置

- (CLLocation *)endLocation; //结束位置

- (NSString *)totalDistanceKm; //总距离 单位千米

- (CLLocationDistance)totalDistance; // 距离 米

- (NSString *)averageSpeed; //平均速度

- (NSTimeInterval)totalDuration; // 总用时

- (NSString *)hSpeed; //最快速度

- (NSString *)minSpeed; //最慢速度

- (NSString *)maxPace; //最高配速

- (NSString *)minPace; //最低配速;

- (NSString *)avgPace; //平均配速

- (NSString *)createTime; //YYYYMMDDHHSS  年月日时分 算开始时间

- (NSString *)title;

- (NSString *)subTitle;

- (NSInteger)numOfLocations;

- (CLLocationCoordinate2D *)coordinates; //轨迹数量

- (void)startRecord;

- (void)endRecord;

- (void)addLocation:(CLLocation *)location;

- (void)pauseRecord:(CLLocation *)pauseLocation;

- (void)continueRecord:(CLLocation *)continueLocation;


@end
