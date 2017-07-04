//
//  RouteDrawViewController.m
//  MAMapOfTracking
//
//  Created by 叶志强 on 2017/6/19.
//  Copyright © 2017年 CancerQ. All rights reserved.
//

#import "RouteDrawViewController.h"
#import "MAMutablePolyline.h"
#import "MAMutablePolylineRenderer.h"
#import "StatusView.h"
#import "Record.h"
#import "FileHelper.h"
#import "SystemInfoView.h"
#import "PerKilometerLabel.h"
#import "PerKulometerPoint.h"
#import "TipView.h"
#import "RecordViewController.h"

@interface RouteDrawViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView                 *mapView;

@property (nonatomic, strong) StatusView                *statusView;

@property (nonatomic, strong) SystemInfoView            *systemInfoView;

@property (nonatomic, strong) TipView                   *tipView;

@property (nonatomic, strong) MAMutablePolyline         *mutablePolyline;

@property (nonatomic, strong) MAMutablePolylineRenderer *mutableView;

@property (nonatomic, strong) MAMultiPolyline           *sportEndPolyline;

@property (nonatomic, strong) Record                    *currentRecord;

@property (nonatomic, strong) NSMutableArray            *locationsArray;

@property (nonatomic, assign) BOOL                      isRecording;

@property (nonatomic, assign) BOOL                      existStartPointed;

@property (nonatomic, strong) UIButton                  *locationBtn;

@property (nonatomic, strong) UIImage                   *imageLocated;

@property (nonatomic, strong) UIImage                   *imageNotLocate;


@end

@implementation RouteDrawViewController

#pragma mark -
#pragma mark - LazyLoad (懒加载)

- (MAMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, NavigationViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        _mapView.showsScale = NO;
        _mapView.rotateCameraEnabled = NO;
        _mapView.showsCompass = NO;
        _mapView.showsUserLocation = NO;
        _mapView.distanceFilter = 10;
        _mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _mapView.delegate = self;
        [_mapView setZoomLevel:16 animated:YES];
    }
    return _mapView;
}
#pragma mark -
#pragma mark - Lifecycle (生命周期)
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.mapView];
    
    [self setTitle:@"轨迹绘制"];
    
    [self initNavigationBar];
    
    [self initOverlay];
    
    [self initStatusView];
    
    [self initSystemInfoView];
    
    [self initTipView];
    
    [self initLocationButton];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.mapView addOverlay:self.mutablePolyline];
    
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}

#pragma mark - Handle Action

- (void)actionRecordAndStop
{
    self.isRecording = !self.isRecording;
    
    if (self.isRecording)
    {
        [self.mapView setZoomLevel:19 animated:YES];
        [self.tipView showTip:@"Start recording"];
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"icon_stop.png"];
        
        if (self.currentRecord == nil)
        {
            self.currentRecord = [[Record alloc] init];
        }
    }
    else
    {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
        [self.tipView showTip:@"has stoppod recording"];
    }
}

- (void)actionClear
{
    self.isRecording = NO;
    [self.locationsArray removeAllObjects];
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
    [self.tipView showTip:@"has stoppod recording"];
    [self saveRoute];
    
    [self.mutablePolyline removeAllPoints];
    
    [self.mutableView referenceDidChange];
}

- (void)actionLocation
{
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone];
    }
    else
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow];
    }
}

- (void)actionShowList
{
    UIViewController *recordController = [[RecordViewController alloc] initWithNibName:nil bundle:nil];
    recordController.title = @"Records";
    
    [self.navigationController pushViewController:recordController animated:YES];
}

#pragma mark -
#pragma mark - Private (私有方法)

- (void)saveRoute
{
    if (self.currentRecord == nil)
    {
        return;
    }
    
    NSString *name = self.currentRecord.title;
    NSString *path = [FileHelper filePathWithName:name];
    
    [NSKeyedArchiver archiveRootObject:self.currentRecord toFile:path];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    self.currentRecord = nil;
    
    self.existStartPointed = NO;
}

- (void)initStatusView
{
    self.statusView = [[StatusView alloc] initWithFrame:CGRectMake(5, 35, 150, 150)];
    
    [self.view addSubview:self.statusView];
}

- (void)initSystemInfoView
{
    self.systemInfoView = [[SystemInfoView alloc] initWithFrame:CGRectMake(5, 35 + 150 + 10, 150, 140)];
    
    [self.view addSubview:self.systemInfoView];
}

- (void)initTipView
{
    self.locationsArray = [[NSMutableArray alloc] init];
    
    self.tipView = [[TipView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height*0.95, self.view.bounds.size.width, self.view.bounds.size.height*0.05)];
    
    [self.view addSubview:self.tipView];
}

- (void)initNavigationBar
{
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionRecordAndStop)];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(actionClear)];
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list"] style:UIBarButtonItemStylePlain target:self action:@selector(actionShowList)];
    
    NSArray *array = [[NSArray alloc] initWithObjects:listButton, clearButton, nil];
    self.navigationItem.rightBarButtonItems = array;
    
    self.isRecording = NO;
}

- (void)initOverlay
{
    self.mutablePolyline = [[MAMutablePolyline alloc] initWithPoints:@[]];
}

- (void)initLocationButton
{
    self.imageLocated = [UIImage imageNamed:@"location_yes.png"];
    self.imageNotLocate = [UIImage imageNamed:@"location_no.png"];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds)*0.8, 50, 50)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor whiteColor];
    self.locationBtn.layer.cornerRadius = 5;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    
    [self.view addSubview:self.locationBtn];
}



#pragma mark -
#pragma mark - Protocol conformance (协议代理)

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    if (!updatingLocation) {
        return;
    }
    
    if (self.isRecording)
    {
        //传感器活动状态
//        BOOL deviceActivity  = ([StepSampleManage shareManage].deviceActivityState != SADeviceActivityStateNotMoving && [StepSampleManage shareManage].deviceActivityState != SADeviceActivityStateUnknown);
//        if (SIMULATOR_TEST) {
//            deviceActivity = YES;
//        }
        BOOL deviceActivity = YES;
        if (userLocation.location.horizontalAccuracy < 40 && userLocation.location.horizontalAccuracy > 0 && deviceActivity)
        {

            if (self.currentRecord.totalDistance >= 100 && !self.existStartPointed) {
                MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
                annotation.coordinate = self.currentRecord.coordinates[0];
                [mapView addAnnotation:annotation];
                self.existStartPointed = YES;
            }
        
            [self.locationsArray addObject:userLocation.location];
            
            NSLog(@"date: %@,now :%@",userLocation.location.timestamp,[NSDate date]);
            [self.tipView showTip:[NSString stringWithFormat:@"has got %ld locations",self.locationsArray.count]];
            
            [self.currentRecord addLocation:userLocation.location];
        
            [self.mutablePolyline appendPoint:MAMapPointForCoordinate(userLocation.location.coordinate)];
            
            [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
            
            [self.mutableView referenceDidChange];
        }
    }
#ifdef DEBUG
    [self.statusView showStatusWith:userLocation.location];
#endif
}


- (void)mapView:(MAMapView *)mapView  didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
        [self.mapView setZoomLevel:16 animated:YES];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[PerKulometerPoint class]]) {
        static NSString *customReuseIndetifier = @"PerKilometerLabel";
        PerKilometerLabel *annotationView = (PerKilometerLabel *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[PerKilometerLabel alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            // must set to NO, so we can show the custom callout view.
        }
        annotationView.labelText = ((PerKulometerPoint *)annotation).labelText;
        
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *indetifier = @"beginAndEnd";
        MAAnnotationView *anVC = [mapView dequeueReusableAnnotationViewWithIdentifier:indetifier];
        
        if (anVC == nil) {
            anVC = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:indetifier];
        }
        
        UIImage *image = GetImage(@"startPoint");
        
        if (annotation.coordinate.latitude == self.currentRecord.coordinates[self.currentRecord.numOfLocations-1].latitude && annotation.coordinate.longitude == self.currentRecord.coordinates[self.currentRecord.numOfLocations-1].longitude) {
            image = [UIImage imageNamed:@"endPoint"];
        }
        anVC.image = image;
        anVC.centerOffset = CGPointMake(0, -image.size.height * 0.5);
        return anVC;
    }
    return nil;
}
#pragma mark - 划线
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MAMutablePolyline class]])
    {
        MAMutablePolylineRenderer *polylineRenderer = [[MAMutablePolylineRenderer alloc] initWithMutablePolyline:overlay];
        polylineRenderer.lineWidth = 6.0;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType = kMALineCapRound;
        polylineRenderer.miterLimit = 1.f;
        _mutableView = polylineRenderer;
        return polylineRenderer;
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
