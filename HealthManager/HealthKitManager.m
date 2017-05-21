//
//  HealthKitManager.m
//  HealthMDK
//
//  Created by 王晓睿 on 16/4/1.
//  Copyright © 2016年 王晓睿. All rights reserved.
//

#import "HealthKitManager.h"
#import "DataItem.h"

#import "DateUtils.h"
#import "HKHealthStore+AAPLExtensions.h"

static NSString *kUnknownString = @"Unknown";

@interface HealthKitManager ()

@property (nonatomic , assign) int stepCountValue;
@property (nonatomic , assign) double distanceValue;
@property (nonatomic , assign) int heartRateValue;

@property (nonatomic ,strong) CMPedometer *pedometer;
@property (strong, nonatomic) HKHealthStore *healthStore;

@property (strong, nonatomic) NSMutableArray* getMeDataArray;

@end

@implementation HealthKitManager
- (instancetype)init{
    self = [super init];
    if (self) {
        _healthStore = [[HKHealthStore alloc] init];
        
        _getMeDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (NSSet *)dataTypesToRead{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *runningType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKCharacteristicType *bloodType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
    
    return [NSSet setWithObjects:heightType, weightType, stepCountType,runningType, heartRateType, birthdayType, biologicalSexType, bloodType, nil];
}

- (NSSet *)dataTypesToWrite{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    return [NSSet setWithObjects:heightType, weightType, heartRateType, nil];
}

- (void)authorizeHealthKit{
    // 1. If the store is not available (for instance, iPad) return an error and don't go on.
    // 2. Set the types you want to read from HK Store
    // 3. Set the types you want to write to HK Store
    // 4. Request HealthKit authorization
    
    if([HKHealthStore isHealthDataAvailable]){
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
            //            [self.healthStore authorizationStatusForType:<#(nonnull HKObjectType *)#>];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the user interface based on the current user's health information.
                [self readProfile];
            });
            
        }];
    }
}

- (void)readProfile{
    NSError *error;
    
    // ======
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    if(nil != dateOfBirth){
        NSDate *now = [NSDate date];
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
        NSUInteger usersAge = [ageComponents year];
        
        [self.getMeDataArray addObject:[[DataItem alloc] dataItemWithName:@"Birth" valueName:[DateUtils getStringDateByDate:dateOfBirth] value:usersAge]];
    }else{
        [self.getMeDataArray addObject:[[DataItem alloc] dataItemWithName:@"Birth" valueName:kUnknownString value:0]];
    }
    
    // =====
    HKBiologicalSexObject* biologicalSex = [self.healthStore biologicalSexWithError:&error];
    if(nil != biologicalSex){
        NSString* valueName = kUnknownString;
        switch (biologicalSex.biologicalSex) {
            case HKBiologicalSexFemale:{
                valueName = @"Female";
                break;
            }
            case HKBiologicalSexMale:{
                valueName = @"Male";
                break;
            }
            default:
                break;
        }
        [self.getMeDataArray addObject:[[DataItem alloc] dataItemWithName:@"BiologicalSex" valueName:valueName value:biologicalSex.biologicalSex]];
    }else{
        [self.getMeDataArray addObject:[[DataItem alloc] dataItemWithName:@"BiologicalSex" valueName:kUnknownString value:0]];
    }
    
    // =======
    HKBloodTypeObject* bloodType = [self.healthStore bloodTypeWithError:&error];
    if(nil != bloodType){
        NSString* valueName = kUnknownString;
        switch (bloodType.bloodType) {
            case HKBloodTypeAPositive:{
                valueName = @"A+";
                break;
            }
            case HKBloodTypeANegative:{
                valueName = @"A-";
                break;
            }
            case HKBloodTypeBPositive:{
                valueName = @"B+";
                break;
            }
            case HKBloodTypeBNegative:{
                valueName = @"B-";
                break;
            }
            case HKBloodTypeABPositive:{
                valueName = @"AB+";
                break;
            }
            case HKBloodTypeABNegative:{
                valueName = @"AB-";
                break;
            }
            case HKBloodTypeOPositive:{
                valueName = @"O+";
                break;
            }
            case HKBloodTypeONegative:{
                valueName = @"O-";
                break;
            }
            default:
                break;
        }
        
        [self.getMeDataArray addObject:[[DataItem alloc] dataItemWithName:@"BloodType" valueName:valueName value:bloodType.bloodType]];
    }else{
        [self.getMeDataArray addObject:[[DataItem alloc] dataItemWithName:@"BloodType" valueName:kUnknownString value:0]];
    }
}

- (void)getUsersHeight:(void (^) (DataItem *))dataItem{
    // Fetch user's default height unit in inches.
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitCentimeter;
    
    NSString *heightUnitString = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
    NSString* name = [NSString stringWithFormat:@"Height (%@)", heightUnitString];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        
        DataItem *itemTemp = [[DataItem alloc] dataItemWithName:name valueName:kUnknownString value:0];
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
        }else {
            // Determine the height in the required unit.
            double usersHeight = [mostRecentQuantity doubleValueForUnit:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixCenti]];
            
            NSString* valueName = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterDecimalStyle];
            
            itemTemp = [[DataItem alloc] dataItemWithName:name valueName:valueName value:usersHeight];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dataItem(itemTemp);
        });
    }];
}

- (void)getUsersWeight:(void (^) (DataItem *))dataItem{
    // Fetch the user's default weight unit in pounds.
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    massFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitKilogram;
    NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
    
    NSString* name = [NSString stringWithFormat:@"Weight (%@)", weightUnitString];
    
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        DataItem *itemTemp = [[DataItem alloc] dataItemWithName:name valueName:kUnknownString value:0];
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
        }else {
            // Determine the weight in the required unit.
            HKUnit *weightUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
            double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            
            NSString *valueName = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterDecimalStyle];
            
            itemTemp = [[DataItem alloc] dataItemWithName:name valueName:valueName value:usersWeight];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dataItem(itemTemp);
        });
    }];
}


- (void)getUsersSteps:(void (^) (DataItem *))dataItem{
    // Fetch user's default height unit in inches.
    NSString* name = [NSString stringWithFormat:@"Steps (%@)", @"count"];
    
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSDate *startDate = [DateUtils getCurrentDayZeroDateByCurrentDate:[NSDate date]];
    NSDate *endDate = [DateUtils getNextDayZeroDateByCurrentDate:startDate];
    
    // Create the query
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    [self.healthStore aapl_statisticsQuantitySampleType:quantityType predicate:predicate option:HKStatisticsOptionCumulativeSum completion:^(HKQuantity *quantity, NSError *error) {
        
        DataItem* itemTemp = [[DataItem alloc] dataItemWithName:name valueName:kUnknownString value:0];
        
        if(quantity){
            double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
            NSString *valueName = [NSNumberFormatter localizedStringFromNumber:@(value) numberStyle:NSNumberFormatterNoStyle];
            itemTemp = [[DataItem alloc] dataItemWithName:name valueName:valueName value:value];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dataItem(itemTemp);
        });
    }];
}


- (void)getUsersDistanceWalkingRunning:(void (^) (DataItem *))dataItem{
    
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    NSString *distanceUnitString = [lengthFormatter unitStringFromValue:10 unit:NSLengthFormatterUnitKilometer];
    NSString *name = [NSString stringWithFormat:@"Distance (%@)", distanceUnitString];
    
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    NSDate *startDate = [DateUtils getCurrentDayZeroDateByCurrentDate:[NSDate date]];
    NSDate *endDate = [DateUtils getNextDayZeroDateByCurrentDate:startDate];
    
    // Create the query
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    [self.healthStore aapl_statisticsQuantitySampleType:quantityType predicate:predicate option:HKStatisticsOptionCumulativeSum completion:^(HKQuantity *quantity, NSError *error) {
        DataItem* itemTemp = [[DataItem alloc] dataItemWithName:name valueName:kUnknownString value:0];
        
        if(quantity){
            double value = [quantity doubleValueForUnit:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixMega]];
            NSString *valueName = [NSNumberFormatter localizedStringFromNumber:@(value) numberStyle:NSNumberFormatterDecimalStyle];
            
            itemTemp = [[DataItem alloc] dataItemWithName:name valueName:valueName value:value];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dataItem(itemTemp);
        });
    }];
}

- (void)storeHeartBeatsAtMinute:(double)beats startDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(BOOL success, NSError* error))completion{
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]
                                            doubleValue:beats];
    
    HKQuantitySample *quantitySample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:startDate endDate:endDate];
    
    [self.healthStore saveObject:quantitySample withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion){
                completion(success, error);
            }
        });
    }];
}

- (void)getUsersHeartRate:(void (^) (DataItem *))dataItem{
    
    NSString* name = [NSString stringWithFormat:@"HeartRate (%@)", [[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] unitString]];
    
    HKQuantityType *heartType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:heartType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        DataItem* itemTemp = [[DataItem alloc] dataItemWithName:name valueName:kUnknownString value:0];
        if(!mostRecentQuantity){
            
        }else{
            HKUnit *stepUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
            double userStep = [mostRecentQuantity doubleValueForUnit:stepUnit];
            
            NSString *valueName = [NSNumberFormatter localizedStringFromNumber:@(userStep) numberStyle:NSNumberFormatterNoStyle];
            
            itemTemp = [[DataItem alloc] dataItemWithName:name valueName:valueName value:userStep];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dataItem(itemTemp);
        });
    }];
    
}

// 长时间变化
- (void)observeHealthQuantityType:(NSString *)identifier collectionData:(collectionDataBlock)callBack
{
    HKSampleType *sampleType = [HKObjectType quantityTypeForIdentifier:identifier];
    
    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:sampleType predicate:nil updateHandler:^(HKObserverQuery *query,HKObserverQueryCompletionHandler completionHandler, NSError *error) {
        if (error) {
            
            // Perform Proper Error Handling Here...
            NSLog(@"*** An error occured while setting up the stepCount observer. %@ ***",
                  error.localizedDescription);
            abort();
        }
        __block NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        
        if ([identifier isEqualToString:HKQuantityTypeIdentifierStepCount]) {
            [self getUsersSteps:^(DataItem *item) {
                
                //                 self.stepCount.text = [NSString stringWithFormat:@"%@:%@",item.name,item.valueName];
                [dict setObject:[NSNumber numberWithInt: (int)item.value] forKey:@"step"];
                callBack(dict);
                NSLog(@"stepCount changed!");
            }];
        }
        
        if ([identifier isEqualToString:HKQuantityTypeIdentifierDistanceWalkingRunning]){
            
            [self getUsersDistanceWalkingRunning:^(DataItem *item) {
                //                 self.distance.text = [NSString stringWithFormat:@"%@:%@",item.name,item.valueName];
                [dict setObject:[NSNumber numberWithInt: item.value] forKey:@"distance"];
                callBack(dict);
                NSLog(@"distance changed!");
            }];
            
        }
        
        if ([identifier isEqualToString:HKQuantityTypeIdentifierHeartRate]) {
            [self getUsersHeartRate:^(DataItem *item) {
                //                 self.heartRate.text = [NSString stringWithFormat:@"%@:%@",item.name,item.valueName];
                [dict setObject:[NSNumber numberWithInt: (int)item.value] forKey:@"heartrate"];
                callBack(dict);
                NSLog(@"heartRate changed!");
            }];
        }
        
    }];
    
    [self.healthStore executeQuery:query];
    
}

// 短时间变化
- (void)startPedometerWithCollectionData:(collectionDataBlock)callBack
{
    if (nil == self.pedometer) {
        self.pedometer = [[CMPedometer alloc]init];
    }
    
    if(CMPedometer.isStepCountingAvailable && CMPedometer.isDistanceAvailable){
        
        NSDate *startDate = [self getCurrentDayZeroDateByCurrentDate:[NSDate date]];
        
        __block NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [self.pedometer startPedometerUpdatesFromDate:startDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            
            [dict setObject:pedometerData.numberOfSteps forKey:@"step"];
            [dict setObject:pedometerData.distance forKey:@"distance"];
            callBack(dict);
        }];
        [self observeHealthQuantityType:HKQuantityTypeIdentifierHeartRate collectionData:^(NSDictionary *data) {
            NSNumber *heartrate = [data objectForKey:@"heartrate"];
            [dict setObject:heartrate forKey:@"heartrate"];
            callBack(dict);
        }];
    }    
}

- (NSDate*)getCurrentDayZeroDateByCurrentDate:(NSDate *)currentDate
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* components = [cal components:(NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    return [cal dateFromComponents:components];
}

@end
