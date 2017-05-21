//
//  DataItem.h
//  AIHealthDemo
//
//  Created by shengyp on 15-8-24.
//  Copyright (c) 2015年 shengyp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataItem : NSObject

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *valueName;
@property (nonatomic, readonly) double value;

- (instancetype)dataItemWithName:(NSString *)name valueName:(NSString*)valueName value:(double)value;

@end
