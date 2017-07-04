# MAMapOfTracking
使用高德地图实现路径绘制及重播
### 实现
#### 1.绘制
```obj
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
```
通过代理获取的坐标的传入Record模型中，这里的模型是一个Demo的模型，你们可以根据自己的实际情况定义
mutablePolyline和mutableView相当于画笔和画板，没错这样去理解（大概就是这个意思）获取到的点在地图变成线 

#### 2.播放
播放这里使用mutablePolyline和MAMutablePolylineRenderer *mutableView  是一个能提供有多种颜色的画板去理解，读取之前保存的记录  (我之前实际项目是保存在数据库中的) 这里主要是播放速度和播放点的
控制

```obj
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
```
获取保存的当前坐标点和上一个点的动画时间
>动画时间 = 距离 / (播放速度*播放倍数)

```obj
 for(MAAnnotationMoveAnimation *animation in [self.myLocation allMoveAnimations]) {
        if ([animation.name isEqualToString:kUserLoctionAnimatedKey]) {
               [animation cancel];
        }
  }
```
使用上述的方法去取消动画，如果对方向有要求的记录一下停止之前的方向然后再试下
```obj
self.myLocation.movingDirection = self.heading;
```
以上就是整个绘制和播放了
