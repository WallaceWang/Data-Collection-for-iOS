//
//  DataCollectManager.h
//  DATACOLLECTMDK
//
//  Created by 王晓睿 on 16/6/23.
//  Copyright © 2016年 王晓睿. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DeviceMotionGraphType) {
    kDeviceMotionGraphTypeAttitude = 0,// 空间位置角度
    kDeviceMotionGraphTypeRotationRate,// 旋转角速度
    kDeviceMotionGraphTypeGravity,// 重力加速度
    kDeviceMotionGraphTypeUserAcceleration// 直线加速度
};

typedef void(^healthDataBlock)(NSDictionary *healthDataDict);
typedef void(^gyroscopeDataBlock)(NSDictionary *gyroscopeDataDict);

@interface DataCollectManager : NSObject


+ (DataCollectManager *)shareManager;

// 获取健康数据权限，appDelegate程序启动时调用
- (void)authorizeHealthKit;
// 获取健康数据（距离、步数、心跳）
- (void)getHealthData:(healthDataBlock)block;
// 获取三轴陀螺仪角度，updateInterval采集频率，建议写成0.2,type是指明要采集陀螺仪的哪组数据
- (void)startUpdatesWithInterval:(float)updateInterval deviceMotionGraphType:(DeviceMotionGraphType)type callBack:(gyroscopeDataBlock)block;
// 停止采集陀螺仪数据
- (void)stopDeviceMotion;

@end
