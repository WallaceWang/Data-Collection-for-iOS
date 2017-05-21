/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Contains shared helper methods on HKHealthStore that are specific to Fit's use cases.
            
*/

#import "HKHealthStore+AAPLExtensions.h"

@implementation HKHealthStore (AAPLExtensions)
/*
 要从Store中读取特征之外的信息你需要使用一条查询。查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标。为了读取身体素质信息，你需要创建一条HKSampleQuery。
 
 要创建一条查询，你需要：
 
 指明你需要查询的信息的种类（例如：身高或者体重）
 一个可选的NSPredicate来指明查询条件（例如起止日期），以及一个NSSortDescriptors数组，来告诉Store怎么样将结果排序。
 一旦你有了一条查询，就可以调用HKHealthStore的executeQuery()方法来获得结果。
 
 - (void)aapl_statisticsQuantitySampleType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate option:(HKStatisticsOptions)options completion:(void (^) (HKQuantity *quantity, NSError *error))completion
 */

- (void)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *, NSError *))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        if (completion) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            HKQuantity *quantity = quantitySample.quantity;
            
            completion(quantity, error);
        }
    }];
    
    [self executeQuery:query];
}


- (void)aapl_statisticsQuantitySampleType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate option:(HKStatisticsOptions)options completion:(void (^) (HKQuantity *quantity, NSError *error))completion{
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:options completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *quantity = result.sumQuantity;
        if (!quantity) {
            if(completion){
                completion(nil, error);
            }
            
            return ;
        }
        
        if(completion){
            completion(quantity, error);
        }
        
    }];
    
    [self executeQuery:query];
}

@end
