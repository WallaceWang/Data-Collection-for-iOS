//
//  DateUtils.m
//  SJB
//
//  Created by sheng yinpeng on 13-7-10.
//  Copyright (c) 2013年 sheng yinpeng. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

// NSDate转NSString
+ (NSString*)getStringDateByDate:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSString* dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

// NSDate转NSString(带格式的转换:@"yyyy-MM-dd HH:mm:ss")
+ (NSString*)getStringDateByDate:(NSDate *)date dateFormat:(NSString*)string
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:string];
    NSString* dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

// 当前系统时间
+ (NSString*)getCurrentSystemDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
    if(nil == dateString){
        dateString = @"1900-01-01 00:00:00";
    }
    return dateString;
}

+ (NSDate*)getCurrentDayZeroDateByCurrentDate:(NSDate *)currentDate
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* components = [cal components:(NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    return [cal dateFromComponents:components];
}

+ (NSDate*)getNextDayZeroDateByCurrentDate:(NSDate *)currentDate
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    return [cal dateByAddingUnit:NSCalendarUnitDay value:1 toDate:currentDate options:0];
}

@end
