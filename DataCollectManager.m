//
//  DataCollectManager.m
//  DATACOLLECTMDK
//
//  Created by 王晓睿 on 16/6/23.
//  Copyright © 2016年 王晓睿. All rights reserved.
//

#import "DataCollectManager.h"
#import "HealthKitManager.h"
#import "DataItem.h"

@interface DataCollectManager(){
    HealthKitManager *healthKitManager;
    CMMotionManager *motionManager;
}

@end

@implementation DataCollectManager

+ (DataCollectManager *)shareManager
{
    static DataCollectManager *shareManager = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        shareManager = [[DataCollectManager alloc]init];
    });
    return shareManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        healthKitManager = [[HealthKitManager alloc]init];
        motionManager = [[CMMotionManager alloc]init];
    }
    return self;
}

// 健康数据相关代码
- (void)authorizeHealthKit
{
    [healthKitManager authorizeHealthKit];
}

- (void)getHealthData:(healthDataBlock)block
{
    [healthKitManager startPedometerWithCollectionData:^(NSDictionary *data) {
        block(data);
        NSLog(@"startPedometerWithCollectionData - %@",data);
    }];
}

- (void)getUntilNowHealthData:(collectionDataBlock)callBack
{
    __block NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [healthKitManager getUsersSteps:^(DataItem *item) {
        [dict setObject:[NSNumber numberWithInt: (int)item.value] forKey:@"step"];
    }];
    [healthKitManager getUsersDistanceWalkingRunning:^(DataItem *item) {
        [dict setObject:[NSNumber numberWithDouble:item.value] forKey:@"distance"];
    }];
    [healthKitManager getUsersDistanceWalkingRunning:^(DataItem *item) {
        [dict setObject:[NSNumber numberWithInt:(int)item.value] forKey:@"heartrate"];
    }];
    callBack(dict);
}

- (void)observeHealthDataLongTime:(collectionDataBlock)callBack
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [healthKitManager observeHealthQuantityType:HKQuantityTypeIdentifierStepCount collectionData:^(NSDictionary *data) {
        NSNumber *step = [data objectForKey:@"step"];
        [dict setObject:step forKey:@"step"];
    }];
    [healthKitManager observeHealthQuantityType:HKQuantityTypeIdentifierDistanceWalkingRunning collectionData:^(NSDictionary *data) {
        NSNumber *distance = [data objectForKey:@"disatace"];
        [dict setObject:distance forKey:@"distance"];
    }];
    [healthKitManager observeHealthQuantityType:HKQuantityTypeIdentifierHeartRate collectionData:^(NSDictionary *data) {
        NSNumber *heartrate = [data objectForKey:@"heartrate"];
        [dict setObject:heartrate forKey:@"heartrate"];
    }];
    
    callBack(dict);
    
}

// 陀螺仪相关代码
- (void)stopDeviceMotion
{
    [motionManager stopDeviceMotionUpdates];
}

- (void)startUpdatesWithInterval:(float)updateInterval deviceMotionGraphType:(DeviceMotionGraphType)type callBack:(gyroscopeDataBlock)block
{
    if ([motionManager isDeviceMotionAvailable] == YES) {
        [motionManager setDeviceMotionUpdateInterval:updateInterval];
        
        __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            
            if (error) {
                NSLog(@"startDeviceMotionUpdatesToQueue :: error: %@",[error debugDescription]);
                return ;
            }
            switch (type) {
                case kDeviceMotionGraphTypeAttitude:{
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.attitude.pitch] forKey:@"x"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.attitude.roll] forKey:@"y"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.attitude.yaw] forKey:@"z"];
                }
                    break;
                case kDeviceMotionGraphTypeRotationRate:{
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.rotationRate.x] forKey:@"x"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.rotationRate.y] forKey:@"y"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.rotationRate.z] forKey:@"z"];
                }
                    break;
                case kDeviceMotionGraphTypeGravity:{
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.gravity.x] forKey:@"x"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.gravity.y] forKey:@"y"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.gravity.z] forKey:@"z"];
                }
                    break;
                case kDeviceMotionGraphTypeUserAcceleration:{
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.x] forKey:@"x"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.y] forKey:@"y"];
                    [dictionary setObject:[NSNumber numberWithFloat:deviceMotion.userAcceleration.z] forKey:@"z"];
                }
                    break;
                default:
                    break;
            }
            
            block(dictionary);
        }];
        
    }else{
        NSLog(@"DeviceMotion is unavailable");
    }
}
@end
