//
//  SetTimerBenchmark.m
//  iOS_Collection
//
//  Created by 金医桥 on 2020/12/16.
//

#import "SetTimerBenchmark.h"

@implementation SetTimerBenchmark

- (void)startBenchmark{
//    [self performanceOfInitWithCountOnSet];
    [self testIndexSetAndSetPerformance];
    
}


- (void)testIndexSetAndSetPerformance {
    [@[@(10000), @(100000), @(1000000), @(10000000), @(20000000)] enumerateObjectsUsingBlock:^(NSNumber *entriesNumber, NSUInteger runCount, BOOL *stop) {
        @autoreleasepool {
            NSUInteger entries = entriesNumber.unsignedIntegerValue;
            NSLog(@"操作数量: %g [run %tu]", (double)entries, runCount+1);
            NSLog(@"\n");

            NSMutableSet *randomAccessNumbers = [NSMutableSet set];
            for (NSUInteger accessIdx = 0; accessIdx < entries/100; accessIdx++) {
                [randomAccessNumbers addObject:@(arc4random_uniform((u_int32_t)entries))];
            }
            // 添加
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            double indexSetPerf = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    [indexSet addIndex:number.unsignedIntegerValue];
                }];
            });
            // 查找
            double setIndexRAC = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    [indexSet containsIndex:number.unsignedIntegerValue];
                }];
            });
            
            // 添加
            NSMutableSet *set = [NSMutableSet set];
            double setPerf = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger index = number.unsignedIntegerValue;
                    [set addObject:number];
                }];
            });

            // 查找
            double setRAC = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger index = number.unsignedIntegerValue;
                    [set containsObject:number];
                }];
            });

            NSLog(@"添加: NSIndexSet: %f [ms]. NSSet: %f [ms]", indexSetPerf/1E6, setPerf/1E6);
            NSLog(@"随机访问:  NSIndexSet: %f [ms]. NSSet: %f [ms]", setIndexRAC/1E6, setRAC/1E6);
            NSLog(@"\n");
        
        }
    }];
}


- (void)performanceOfInitWithCountOnSet {
    NSUInteger const numberOfEntries = 1000000;
    NSUInteger const runCount = 5;

    printf("操作数量: %g [run %tu]", (double)numberOfEntries, runCount);
    printf("\n");

    
//     先生成字符串,防止产生性能差异
    NSMutableSet *randomSet = [NSMutableSet setWithCapacity:numberOfEntries];
    for (NSUInteger idx = 0; idx < numberOfEntries; idx++) {
        [randomSet addObject:EntryForIDX(idx)];
    }

    double no_count = PerformAndTrackTimeMultiple(^{
        NSMutableSet *randomSet = [NSMutableSet set];
        for (NSUInteger idx = 0; idx < numberOfEntries; idx++) {
            [randomSet addObject:EntryForIDX(idx)];
        }
    }, 5);

    double with_count = PerformAndTrackTimeMultiple(^{
        NSMutableSet *randomSet = [NSMutableSet setWithCapacity:numberOfEntries];
        for (NSUInteger idx = 0; idx < numberOfEntries; idx++) {
            [randomSet addObject:EntryForIDX(idx)];
        }
    }, 5);

    if (no_count)        printf("NSMutableSet 添加元素 :      %f [ms]\n", no_count/1E6);
    if (with_count)      printf("NSMutableSet Capacity 添加元素:      %f [ms]\n", with_count/1E6);
}


@end
