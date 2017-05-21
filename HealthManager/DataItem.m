//
//  DataItem.m
//  AIHealthDemo
//
//  Created by shengyp on 15-8-24.
//  Copyright (c) 2015年 shengyp. All rights reserved.
//

#import "DataItem.h"

@interface DataItem ()

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSString *valueName;
@property (nonatomic, readwrite) double value;

@end

@implementation DataItem

- (instancetype)dataItemWithName:(NSString *)name valueName:(NSString*)valueName value:(double)value{
    DataItem *dataItem = [[DataItem alloc] init];
    
    dataItem.name = name;
    dataItem.valueName = valueName;
    dataItem.value = value;
    
    return dataItem;
}

@end
