//
//  HealthKitManager.h
//  HealthMDK
//
//  Created by 王晓睿 on 16/4/1.
//  Copyright © 2016年 王晓睿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>


typedef void(^collectionDataBlock)(NSDictionary *data);

@class DataItem;

@interface HealthKitManager : NSObject

// appDelegate程序启动时调用
- (void)authorizeHealthKit;

// get方法 查询当前的数据不会动态变化
//- (void)getUsersHeight:(void (^) (DataItem *))dataItem;

//- (void)getUsersWeight:(void (^) (DataItem *))dataItem;

- (void)getUsersSteps:(void (^) (DataItem *))dataItem;

- (void)getUsersDistanceWalkingRunning:(void (^) (DataItem *))dataItem;

- (void)getUsersHeartRate:(void (^) (DataItem *))dataItem;

- (void)storeHeartBeatsAtMinute:(double)beats startDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(BOOL success, NSError* error))completion;

- (void)observeHealthQuantityType:(NSString *)identifier collectionData:(collectionDataBlock)callBack;

- (void)startPedometerWithCollectionData:(collectionDataBlock)callBack;
@end
