//
//  Record.m
//  MAMapOfTracking
//
//  Created by 叶志强 on 2017/6/19.
//  Copyright © 2017年 CancerQ. All rights reserved.
//

#import "Record.h"

@interface Record (){
    NSMutableArray *__speedColors;
}
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic, assign) double pauseTime;
@property (nonatomic, assign) double continueTime;

@property (nonatomic, assign) double totalPauseDistance;
@property (nonatomic, strong) CLLocation *pauseLocation;
@property (nonatomic, strong) CLLocation *continueLocation;

@property (nonatomic, assign) double fastestSpeedPace;
@property (nonatomic, assign) double slowestSpeedPace;

@property (nonatomic, assign) double fastestSpeed;
@property (nonatomic, assign) double slowestSpeed;

@property (nonatomic, strong) NSMutableArray *locationsArray;

@property (nonatomic, assign) double distance;

@property (nonatomic, strong) NSDate *paceTime;

@property (nonatomic, assign) CLLocationCoordinate2D * coords;

@property (nonatomic, assign) double lastPauseInterval;

@property (nonatomic, assign) double totalPauseInterval;

@property (nonatomic, assign) BOOL pauseed;

@property (nonatomic, assign) double currentTime;

@property (nonatomic, strong) NSMutableArray *coordinatesStore; //轨迹点

@property (nonatomic, assign) int unitsKm;

@property (nonatomic, strong) NSMutableArray *mutPerKmLocations;

@property (nonatomic, copy, readwrite) NSString *stepNumber; //步数

@end

@implementation Record

- (float)fineSpeed{
    return self.currentTime;
}

- (NSString *)oneKilometerSpeed{
    if (self.fineSpeed <= 0) {
        return @"0";
    }
    int oneKilometerSpeed = 1000 / self.fineSpeed;
    return [NSString stringWithFormat:@"%d'%d\"",oneKilometerSpeed/60,oneKilometerSpeed%60];
}//最后的速度（实时的速度）min/km

- (NSTimeInterval)lastPauseInterval{
    return self.continueTime - self.pauseTime;
}

- (NSString *)averageSpeed{
    if (self.totalDuration <= 0) {
        return @"0";
    }
    return [NSString stringWithFormat:@"%.2f", self.totalDistance/self.totalDuration];
}


- (NSString *)maxPace{
    return [NSString stringWithFormat:@"%d'%d\"",(int)self.fastestSpeedPace/60,(int)self.fastestSpeedPace%60];
}//最高配速

- (NSString *)minPace{
    return [NSString stringWithFormat:@"%d'%d\"",(int)self.slowestSpeedPace/60,(int)self.slowestSpeedPace%60];
}//最低配速;

- (NSString *)avgPace{
    if (self.totalDuration <= 0 && self.totalDuration > 2592000) { //2592000为30天秒数
        return @"0";
    }
    float totalMinute = self.totalDuration / 60;
    float totalKilometer = self.totalDistance / 1000;
    float avgPace = totalMinute/totalKilometer;
    int minute = avgPace;
    int second = (avgPace - minute) * 60;
    return [NSString stringWithFormat:@"%d'%d\"",minute, second];
}//平均配速

- (NSString *)startTimeHHss{
    return [self.startTime stringWithFormat:@"yyyyMMddHHmmss"];
}

- (NSString *)endTimeHHss{
    return [self.endTime stringWithFormat:@"yyyyMMddHHmmss"];
}

- (NSString *)hSpeed{
    return [NSString stringWithFormat:@"%.2f",self.fastestSpeed];
}

- (NSString *)minSpeed{
    return [NSString stringWithFormat:@"%.2f",self.slowestSpeed];
}

- (NSString *)createTime{
    return  [self.startTime stringWithFormat:@"yyyyMMddHHmmss"];
}

- (CLLocation *)startLocation
{
    return [self.locationsArray firstObject];
}

- (CLLocation *)endLocation
{
    return [self.locationsArray lastObject];
}

- (NSString *)title
{
    return [self.startTime stringWithFormat:@"yyyy-MM-dd HH:mm"];
}

- (NSString *)subTitle
{
    return [NSString stringWithFormat:@"point:%ld, distance: %.2fm, duration: %.2fs", self.locationsArray.count, [self totalDistance], [self totalDuration]];
}

- (CLLocationDistance)totalDistance
{
    CLLocationDistance distance = 0;
    
    if (self.locationsArray.count > 1)
    {
        CLLocation *currentLocation = [self.locationsArray firstObject];
        for (CLLocation *location in self.locationsArray)
        {
            distance += [location distanceFromLocation:currentLocation];
            currentLocation = location;
        }
    }
    if ((distance - self.totalPauseDistance) <= 0) {
        return distance;
    }
    return distance - self.totalPauseDistance;
}

- (NSString *)totalDistanceKm{
    if (self.totalDistance <=0 ) {
        return @"0";
    }
    return [NSString stringWithFormat:@"%.2f", self.totalDistance/1000];
}

- (NSTimeInterval)totalDuration
{
    return (int)([self.endTime timeIntervalSinceDate:self.startTime] - self.totalPauseInterval);
}

- (NSInteger)numOfLocations;
{
    return self.locationsArray.count;
}

- (NSArray<CLLocation *> *)perKmLocations{
    return self.mutPerKmLocations.copy;
}

#pragma mark -
#pragma mark - Public (公有方法)
- (void)startRecord{
    _startTime = [NSDate date];
    _paceTime = _startTime;
    _endTime = _startTime;
}

- (void)endRecord{
    _endTime = [NSDate date];
    self.totalPauseDistance += [(CLLocation *)[self.locationsArray lastObject] distanceFromLocation:self.pauseLocation];
}

- (void)addLocation:(CLLocation *)location
{
    _endTime = [NSDate date];
    /*
    [[StepSampleManage shareManage] getStepFromDate:_startTime toDate:_endTime withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        if (!error) {
            self.stepNumber = pedometerData.numberOfSteps?[NSString stringWithFormat:@"%@",pedometerData.numberOfSteps]:@"0";
        }
        else{
            self.stepNumber = self.stepNumber?:@"0";
        }
    }];*/
    
    //判断当前速度是否大于最大速度 是赋值最大值
    if (location.speed > self.fastestSpeed) {
        self.fastestSpeed = location.speed;
        //如果最小速度为0时 赋值最小值
        if (self.slowestSpeed == 0) {
            self.slowestSpeed = location.speed;
        }
    }
    //判断当前速度是否小于最小值速度 是赋值最小值
    if (location.speed < self.slowestSpeed) {
        self.slowestSpeed = location.speed;
    }
    
    self.currentTime = location.speed;
    
    [self.locationsArray addObject:location];
    
    self.distance = self.totalDistance;
    //如果距离大于1公里的时候开始做判断
    if (self.totalDistance > (1000 * self.unitsKm)) {
        //获取当前1公里花费的时间
        
        double currentSpeedPace = [[NSDate date] timeIntervalSinceDate:self.paceTime];
        currentSpeedPace -= self.lastPauseInterval;
        if (currentSpeedPace > self.slowestSpeedPace) {
            self.slowestSpeedPace = currentSpeedPace;
            
            if (self.fastestSpeedPace == 0) {
                self.fastestSpeedPace = currentSpeedPace;
            }
        }
        
        if (currentSpeedPace < self.fastestSpeedPace) {
            self.fastestSpeedPace = currentSpeedPace;
        }
        self.unitsKm ++;
        self.paceTime = [NSDate date];
        
        //在每1公里的时候讲这个点存入数组
        [self.mutPerKmLocations addObject:location];
    }
}

- (void)pauseRecord:(CLLocation *)pauseLocation{
    if (!self.pauseed) {
        self.pauseTime = [NSDate date].timeIntervalSince1970;
        self.pauseLocation = pauseLocation;
        self.endTime = [NSDate date];
    }
    self.pauseed = YES;
}

- (void)continueRecord:(CLLocation *)continueLocation{
    if (self.pauseed) {
        self.continueTime = [NSDate date].timeIntervalSince1970;
        self.totalPauseInterval += self.lastPauseInterval;
        self.continueLocation = continueLocation;
        self.totalPauseDistance += [self.continueLocation distanceFromLocation:self.pauseLocation];
    }
    self.pauseed = NO;
}

- (CLLocationCoordinate2D *)coordinates
{
    if (self.coords != NULL)
    {
        free(self.coords);
        self.coords = NULL;
    }
    
    self.coords = (CLLocationCoordinate2D *)malloc(self.locationsArray.count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < self.locationsArray.count; i++)
    {
        CLLocation *location = self.locationsArray[i];
        self.coords[i] = location.coordinate;
    }
    
    return self.coords;
}

- (NSArray *)speedColors{
    return __speedColors.copy;
}


+ (UIColor *)getColorForSpeed:(float)speed{
    float realSpeed = speed;
    const float lowSpeedTh = 0.5f;
    const float highSpeedTh = 6.5f;
    const CGFloat warmHue = 0.02f; //偏暖色
    const CGFloat coldHue = 0.4f; //偏冷色
    if (speed > highSpeedTh) {
        realSpeed = highSpeedTh;
    }
    else if (speed < lowSpeedTh){
        realSpeed = lowSpeedTh;
    }
    
    float hue = coldHue - (realSpeed - lowSpeedTh)*(coldHue - warmHue)/(highSpeedTh - lowSpeedTh);
    return [UIColor colorWithHue:hue saturation:1.f brightness:1.f alpha:1.f];
}

#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
        self.locationsArray = [aDecoder decodeObjectForKey:@"locations"];
        __speedColors = [NSMutableArray new];
        
        for (CLLocation *location in self.locationsArray) {
            [__speedColors addObject:[[self class] getColorForSpeed:location.speed]] ;
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.locationsArray forKey:@"locations"];
}

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _locationsArray = [[NSMutableArray alloc] init];
        _coordinatesStore = [[NSMutableArray alloc] init];
        _unitsKm = 1;
        _mutPerKmLocations = [[NSMutableArray alloc] init];
        _stepNumber = @"0";
        [self startRecord];
    /*
        [[StepSampleManage shareManage] startDeviceActivityState];
        
        FMDatabaseQueue *aqueue = [[FMDB_EX sharedDBManager]databaseQueue];
        
        __block NSString *astrength;
        [aqueue inDatabase:^(FMDatabase *db) {
            FMResultSet *set = [db executeQuery:@"select strength,warmup from SP_SPORTS_PRESCR where userid = ?",USERID];
            while ([set next]) {
                astrength = [set stringForColumn:@"strength"];
            }
            [set close];
        }];
     
        if (!StringIsEmpty(astrength)) {
            if ([astrength containsString:@"~"]) {
                NSArray *arr = [astrength componentsSeparatedByString:@"~"];
                self.db_MaxHR = [arr[1] floatValue]/0.8;
            }else if ([astrength containsString:@"～"]){
                NSArray *arr = [astrength componentsSeparatedByString:@"～"];
                self.db_MaxHR = [arr[1] floatValue]/0.8;
            }
            
        }else{
            NSInteger maxHR = AGE;
            if (maxHR <= 0 ) {
                self.db_MaxHR =  ceil(206.9);
            }
            if (AGE > 100) {
                self.db_MaxHR =  ceil(206.9-0.67*100);
            }
            self.db_MaxHR =  ceil(206.9-0.67 * maxHR);
        }
        
        @weakify(self)
        [[EZonSetManager shareManager] startUpdateHeartRateRealTimeWithHaveRateBlock:^(NSInteger haveRate) {
            @strongify(self)
            !self.haveRateBlock?:self.haveRateBlock(haveRate);
            if (haveRate>=self.minBlankHR && haveRate<=self.maxBlankHR) {
                if (!self.isBlankHR){
                    self.isBlankHR = YES;
                    self.isNormalHR = NO;
                    self.isFastHR = NO;
                }
            }
            if (haveRate<self.minBlankHR) {
                if (!self.isNormalHR) {
                    self.isNormalHR = YES;
                    self.isFastHR = NO;
                    self.isBlankHR = NO;
                }
            }
            if (haveRate>self.maxBlankHR) {
                if (!self.isFastHR) {
                    self.isFastHR = YES;
                    self.isNormalHR = NO;
                    self.isBlankHR = NO;
                }
            }
            if (haveRate > self.maxHaveRate) {
                self.maxHaveRate = haveRate;
                
                if (self.minHaveRate == 0) {
                    self.minHaveRate = haveRate;
                }
            }
            if (haveRate < self.minHaveRate) {
                self.minHaveRate = haveRate;
            }
            if (haveRate !=0 ) {
                [self.realTimeHeartRatesArray addObject:@(haveRate)];
            }
            if (self.realTimeHeartRatesArray.count == 20) {
                NSInteger avgRate = 0;
                for (NSNumber *hr in self.realTimeHeartRatesArray) {
                    avgRate += hr.integerValue;
                }
                avgRate = avgRate/self.realTimeHeartRatesArray.count;
                [self.realTimeHeartRatesArray removeAllObjects];
                [self.haveRates addObject:@(avgRate)];
                [self.generalRecord addHaveRate:avgRate];
            }
        }];
     */
    }
    return self;
}
@end

