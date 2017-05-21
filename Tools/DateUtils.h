//
//  DateUtils.h
//  SJB
//
//  Created by sheng yinpeng on 13-7-10.
//  Copyright (c) 2013年 sheng yinpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

// NSDate转NSString
+ (NSString*)getStringDateByDate:(NSDate*)date;
// NSDate转NSString(带格式的转换:@"yyyy-MM-dd HH:mm:ss")
+ (NSString*)getStringDateByDate:(NSDate *)date dateFormat:(NSString*)string;
// 当前系统时间
+ (NSString*)getCurrentSystemDate;
// 获取当天0时0分0秒
+ (NSDate*)getCurrentDayZeroDateByCurrentDate:(NSDate *)currentDate;
// 获取第二天0时0分0秒
+ (NSDate*)getNextDayZeroDateByCurrentDate:(NSDate *)currentDate;

@end
