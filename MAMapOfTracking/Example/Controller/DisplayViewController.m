
//
//  DisplayViewController.m
//  iOS_2D_RecordPath
//
//  Created by PC on 15/8/3.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import "DisplayViewController.h"
#import "MAMutablePolylineRenderer.h"
#import "Record.h"
#import "MySlider.h"

@interface DisplayViewController()<MAMapViewDelegate>

@property (nonatomic, strong) Record *record;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAAnimatedAnnotation *myLocation;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) double averageSpeed;

/**
 *  播放进度控制的核心
 */
@property (nonatomic, assign) NSInteger currentLocationIndex;

@property (nonatomic, strong) MAMultiPolyline *mutablePolyline;

@property (nonatomic, strong) MAMutablePolylineRenderer *mutableView;


/**
 *  方向
 */
@property (nonatomic, assign) double heading;

/**
 *  播放倍数 实现不同的播放速度
 */
@property (nonatomic, assign) NSInteger multiple;

@property (nonatomic, strong) MySlider *playSlier;

@end

NSString *const kUserLoctionAnimatedKey = @"kUserLoctionAnimatedKey";
@implementation DisplayViewController


#pragma mark - Utility

- (void)showRoute
{
    if (self.record == nil || [self.record numOfLocations] == 0)
    {
        NSLog(@"invaled route");
    }
    
    MAPointAnnotation *startPoint = [[MAPointAnnotation alloc] init];
    startPoint.coordinate = [self.record startLocation].coordinate;
    startPoint.title = @"起点";
    [self.mapView addAnnotation:startPoint];
    
    MAPointAnnotation *endPoint = [[MAPointAnnotation alloc] init];
    endPoint.coordinate = [self.record endLocation].coordinate;
    endPoint.title = @"终点";
    [self.mapView addAnnotation:endPoint];
    
    //TODO: - 添加公里的序号
    /*
    NSMutableArray *annotations = [NSMutableArray new];
    [self.record.perKmlocationsArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PerKulometerPoint *annotation = [[PerKulometerPoint alloc] init];
        annotation.coordinate = self.record.perKmLocations[idx];
        annotation.labelText = [NSString stringWithFormat:@"%lu",idx+1];
        [annotations addObject:annotation];
        [self.mapView addAnnotation:annotation];
    }];
    self.KmAnnotations = annotations.copy;
    */
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.record.numOfLocations; i++)
    {
        NSValue *value = [NSValue valueWithMAMapPoint:MAMapPointForCoordinate(self.record.coordinates[i])];
        [mutableArray addObject:value];
    }
    
    NSMutableArray * indexes = [NSMutableArray array];
    for (int i = 0; i < self.record.numOfLocations; i++)
    {
        @autoreleasepool
        {
            [indexes addObject:@(i)];
        }
    }
    
    self.mutablePolyline = [MAMultiPolyline polylineWithCoordinates:self.record.coordinates count:self.record.numOfLocations drawStyleIndexes:indexes];
    
    [self.mapView addOverlay:self.mutablePolyline];
    
    const CGFloat screenEdgeInset = 50;
    UIEdgeInsets inset = UIEdgeInsetsMake(screenEdgeInset, screenEdgeInset, 200 , screenEdgeInset);
    [self.mapView setVisibleMapRect:self.mutablePolyline.boundingMapRect edgePadding:inset animated:NO];
    
    /**
     *  可以根据平均速度来计算播放速度 。。。或者给一个固定的播放速度
     */
    self.averageSpeed = [self.record totalDistance] / [self.record totalDuration];
}

#pragma mark - Interface

- (void)setRecord:(Record *)record
{
    _record = record;
}

#pragma mark - mapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if([annotation isEqual:self.myLocation]) {
        
        static NSString *annotationIdentifier = @"myLcoationIdentifier";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        annotationView.image = GetImage(@"userPosition");
        annotationView.canShowCallout               = YES;
        annotationView.draggable                    = NO;
        return annotationView;
    }
    //TODO: - 每公里的标志
    /*
    if ([annotation isKindOfClass:[PerKulometerPoint class]]) {
        static NSString *customReuseIndetifier = @"PerKilometerLabel";
        PerKilometerLabel *annotationView = (PerKilometerLabel *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[PerKilometerLabel alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
        }
        annotationView.labelText = ((PerKulometerPoint *)annotation).labelText;
        
        return annotationView;
    }*/
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *indetifier = @"beginAndEnd";
        MAAnnotationView *poiAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:indetifier];
        
        if (poiAnnotationView == nil) {
            poiAnnotationView = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:indetifier];
        }
        
        UIImage *image = GetImage(@"startPoint");
        
        if (annotation.coordinate.latitude == self.record.coordinates[self.record.numOfLocations-1].latitude && annotation.coordinate.longitude == self.record.coordinates[self.record.numOfLocations-1].longitude) {
            image = [UIImage imageNamed:@"endPoint"];
        }
        poiAnnotationView.image = image;
        poiAnnotationView.centerOffset = CGPointMake(0, -image.size.height * 0.5);
        poiAnnotationView.canShowCallout = YES;
        return poiAnnotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if (overlay == self.mutablePolyline)
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 6.f;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.miterLimit = 5.f;
        polylineRenderer.strokeColors = self.record.speedColors;
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    return nil;
}



#pragma mark - Action

- (void)actionPlayAndStop
{
    if (self.record == nil)
    {
        return;
    }
    
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying)
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_stop.png"];
        if (self.myLocation == nil)
        {
            self.myLocation = [[MAAnimatedAnnotation alloc] init];
            self.myLocation.title = @"CancerQ biubiubiu~";
            self.myLocation.coordinate = [self.record startLocation].coordinate;
            
            [self.mapView addAnnotation:self.myLocation];
        }
        
        [self animateToNextCoordinate];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
        
        MAAnnotationView *view = [self.mapView viewForAnnotation:self.myLocation];
        
        if (view != nil)
        {
            [view.layer removeAllAnimations];
        }
    }
}

- (void)animateToNextCoordinate
{
    if (self.myLocation == nil)
    {
        return;
    }
    
    CLLocationCoordinate2D *coordinates = [self.record coordinates];
    if (self.currentLocationIndex == [self.record numOfLocations] )
    {
        self.currentLocationIndex = 0;
        [self actionPlayAndStop];
        return;
    }
    
    CLLocationCoordinate2D nextCoord = coordinates[self.currentLocationIndex];
    CLLocationCoordinate2D preCoord = self.currentLocationIndex == 0 ? nextCoord : self.myLocation.coordinate;
    
    self.heading = [self coordinateHeadingFrom:preCoord To:nextCoord];
    CLLocationDistance distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(nextCoord), MAMapPointForCoordinate(preCoord));
    NSTimeInterval duration = distance / (self.averageSpeed * 1000 * self.multiple);
    
    CLLocationCoordinate2D coords[2];
    coords[0] = preCoord;
    coords[1] = nextCoord;
    
    
    @weakify(self)
    [self.myLocation addMoveAnimationWithKeyCoordinates:coords count:2 withDuration:duration + 0.01 withName:kUserLoctionAnimatedKey completeCallback:^(BOOL isFinished) {
        @strongify(self)
        self.currentLocationIndex ++;
        self.playSlier.value = (float)self.currentLocationIndex/[self.record numOfLocations];
        if (isFinished) {
            [self animateToNextCoordinate];
        }
    }];
    self.myLocation.movingDirection = self.heading;
}

//计算方向
- (double)coordinateHeadingFrom:(CLLocationCoordinate2D)head To:(CLLocationCoordinate2D)rear
{
    if (!CLLocationCoordinate2DIsValid(head) || !CLLocationCoordinate2DIsValid(rear))
    {
        return 0.0;
    }

    double delta_lat_y = rear.latitude - head.latitude;
    double delta_lon_x = rear.longitude - head.longitude;
    
    if (fabs(delta_lat_y) < 0.000001)
    {
        return delta_lon_x < 0.0 ? 270.0 : 90.0;
    }
    
    double heading = atan2(delta_lon_x, delta_lat_y) / M_PI * 180.0;
    
    if (heading < 0.0)
    {
        heading += 360.0;
    }
    return heading;
}

#pragma mark - Initialazation

//TODO: - 这里是播放进度的控制 和视频播放功能类似 需要过搬项目的代码有点多，改的地方有点多我放弃了，有这方面的需求的可以参考一下
- (void)initPlaySlier{
    self.playSlier = [MySlider new];
    [self.playSlier setThumbImage:GetImage(@"icon_playwhite") forState:UIControlStateNormal];
    [self.playSlier setThumbImage:GetImage(@"icon_playwhite") forState:UIControlStateHighlighted];
    self.playSlier.minimumTrackTintColor = [UIColor whiteColor];
    self.playSlier.maximumTrackTintColor = HexRGB(0xCCCCCC);
//    self.playSlier.playDuration = [NSString stringWithFormat:@"%d",self.record.playDuration] ;
//    @weakify(self)
//    [self.playSlier touchWithValue:^(float value) {
//        @strongify(self)
//        self.currentLocationIndex = value * [self.record numOfLocations];
//        self.playSlier.value = value;
//        for(MAAnnotationMoveAnimation *animation in [self.myLocation allMoveAnimations]) {
//            if ([animation.name isEqualToString:kUserLoctionAnimatedKey]) {
//                [animation cancel];
//            }
//        }
//        self.myLocation.movingDirection = self.heading;
//        self.myLocation.coordinate = [self.record coordinates][self.currentLocationIndex];
//        if (self.sportRecordPlayView.isPlaying) {
//            [self animateToNextCoordinate];
//        }
//    }];
//    //
//    [self.playSlier bk_addEventHandler:^(MySlider *sender) {
//        @strongify(self)
//        float value = sender.value;
//        self.currentLocationIndex = value * [self.record numOfLocations];
//        
//        self.myLocation.coordinate = [self.record coordinates][self.currentLocationIndex];
//    } forControlEvents:UIControlEventValueChanged];
//    
//    
//    [self.playSlier bk_addEventHandler:^(id sender) {
//        NSLog(@"离开控件");
//        @strongify(self)
//        for(MAAnnotationMoveAnimation *animation in [self.myLocation allMoveAnimations]) {
//            if ([animation.name isEqualToString:kUserLoctionAnimatedKey]) {
//                [animation cancel];
//            }
//        }
//        self.myLocation.movingDirection = self.heading;
//        self.myLocation.coordinate = [self.record coordinates][self.currentLocationIndex];
//        if (self.isPlaying) {
//            self.isPlaying = NO;
//            [self actionPlayAndStop];
//        }
//    } forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.playSlier bk_addEventHandler:^(id sender) {
//        @strongify(self)
//        if (self.sportRecordPlayView.isPlaying) {
//            self.isPlaying = YES;
//            [self actionPlayAndStop];
//        }
//    } forControlEvents:UIControlEventTouchDown];
//    
//    
//    //    [self.playSlier bk_addEventHandler:^(id sender) {
//    //        NSLog(@"%@",sender);
//    //    } forControlEvents:UIControlEventTouchDragInside];
//    
//    [self.view addSubview:self.playSlier];
//    [self.playSlier mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.sportRecordPlayView);
//        make.left.equalTo(self.sportRecordPlayView);
//        make.bottom.equalTo(self.sportRecordPlayView.mas_top).offset(-30);
//        make.height.offset(20);
//    }];
}

- (void)initSpeedChangeView{
//TODO: - 播放倍数的改变
//    self.speedChangeView = [[SpeedChangeView alloc]init];
//    @weakify(self)
//    [self.speedChangeView setDidSpeedLevel:^(NSInteger multiple) {
//        @strongify(self)
//        self.multiple = multiple;
//    }];
//    [self.view addSubview:self.speedChangeView];
//    
//    [self.speedChangeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view).offset(5);
//        make.bottom.equalTo(self.playSlier.mas_top).offset(-20);
//        make.width.offset(175);
//        make.height.offset(42);
//    }];
}

- (void)initToolBar
{
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionPlayAndStop)];
    self.navigationItem.rightBarButtonItem = playItem;
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)initVariates
{
    self.isPlaying = NO;
    self.currentLocationIndex = 0;
    self.averageSpeed = 2;
    self.multiple = 1;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Display";
    
    [self initMapView];
    
    [self initToolBar];
    
    [self showRoute];
    
    [self initVariates];
}

@end
