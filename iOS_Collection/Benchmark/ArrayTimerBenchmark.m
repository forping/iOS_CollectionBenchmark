//
//  ArrayTimerBenchmark.m
//  iOS_Collection
//
//  Created by 金医桥 on 2020/12/16.
//

#import "ArrayTimerBenchmark.h"
#import "ThreadSafeMutableDictionary.h"

@implementation ArrayTimerBenchmark

- (void)startBenchmark{
    [self sortingBenchmark];
//    [self arrayInsertionTimes];
    
//    [self arrayBenchmark];
//
//    [self filteringArrayBenchmark];
    
    
}


/// 插入和删除测试
- (void)arrayInsertionTimes {
//    NSMutableArray *insertAtEndTimes = [NSMutableArray array];
//    NSMutableArray *insertAtBeginningTimes = [NSMutableArray array];
//    NSMutableArray *insertRandomTimes = [NSMutableArray array];
//
//    NSMutableArray *deleteBeginning = [NSMutableArray array];
//    NSMutableArray *deleteEnd = [NSMutableArray array];
//    NSMutableArray *deleteRandom = [NSMutableArray array];

    const NSUInteger numberOfRuns = 100000;
    const NSUInteger addsPerRun   = 2;

    printf("操作数量: %g [run %tu]", (double)numberOfRuns, addsPerRun);
    printf("\n");
    
    double insertAtEndTime = 0, insertAtBeginningTime = 0, insertRandomTime = 0, deleteBeginningTime = 0, deleteEndTime = 0, deleteRandomTime = 0;
    
    
    @autoreleasepool {
        NSMutableArray *array = [NSMutableArray array];
        insertAtEndTime = PerformAndTrackTimeMultiple(^{
            for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
                [array addObject:EntryForIDX(idx)];
            }
        }, addsPerRun);
//            [insertAtEndTimes addObject:@(add_time)];
        
    }

    @autoreleasepool {
        NSMutableArray *array = [NSMutableArray array];
        insertAtBeginningTime = PerformAndTrackTimeMultiple(^{
            for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
                [array insertObject:EntryForIDX(idx) atIndex:0];
//            [insertAtBeginningTimes addObject:@(add_time)];
            }
        }, addsPerRun);
    }

    @autoreleasepool {
        NSMutableArray *array = [NSMutableArray array];
        insertRandomTime = PerformAndTrackTimeMultiple(^{
            for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
            
                [array insertObject:EntryForIDX(idx) atIndex:(NSUInteger)arc4random_uniform((u_int32_t)array.count)];
            
//            [insertRandomTimes addObject:@(add_time)];
            }
        }, addsPerRun);
    }

    // Deletion Tests
    @autoreleasepool {
        NSMutableArray *array = [NSMutableArray array];
        for (NSUInteger subIdx = 0; subIdx < addsPerRun; subIdx++) {
            for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
                [array addObject:EntryForIDX(idx)];
            }
        }
        
        @autoreleasepool {
            // Prepare array
            NSMutableArray *deleteBeginningArray = [array mutableCopy];
            deleteBeginningTime = PerformAndTrackTimeMultiple(^{
                for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
                
                    [deleteBeginningArray removeObjectAtIndex:0];
                
//                [deleteBeginning addObject:@(add_time)];
                }
            }, addsPerRun);
        }

        @autoreleasepool {
            NSMutableArray *deleteEndArray = [array mutableCopy];
            deleteEndTime = PerformAndTrackTimeMultiple(^{
                for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
                
                    [deleteEndArray removeLastObject];
                
//                [deleteEnd addObject:@(add_time)];
                }
            }, addsPerRun);
        }

        @autoreleasepool {
            NSMutableArray *deleteRandomArray = [array mutableCopy];
            deleteRandomTime = PerformAndTrackTimeMultiple(^{
                for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
                
                    [deleteRandomArray removeObjectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)deleteRandomArray.count)];
                
//                [deleteRandom addObject:@(add_time)];
                }
            }, addsPerRun);
        }
    }

    if (insertAtEndTime)        printf("NSMutableArray 尾部添加元素 :      %f [ms]\n", insertAtEndTime/1E6);
    if (insertAtBeginningTime)      printf("NSMutableArray 头部添加元素:      %f [ms]\n", insertAtBeginningTime/1E6);
    
    if (insertRandomTime)        printf("NSMutableArray 随机添加元素:      %f [ms]\n", insertRandomTime/1E6);
    if (deleteBeginningTime)      printf("NSMutableArray 头部删除元素:      %f [ms]\n", deleteBeginningTime/1E6);
    
    if (deleteEndTime) printf("NSMutableArray 尾部删除元素:      %f [ms]\n", deleteEndTime/1E6);
    
    if (deleteRandomTime) printf("NSMutableArray 随机删除元素:      %f [ms]\n", deleteRandomTime/1E6);
   
    printf("\n");
    
    // Write CSV
//    NSMutableString *csvExport = [NSMutableString string];
//    [csvExport appendString:@"Insert at beginning, Insert at end, Insert random, Delete beginning, Delete end, Delete random\n"];
//    for (NSUInteger idx = 0; idx < numberOfRuns; idx++) {
//        [csvExport appendFormat:@"%.2f, %.2f, %.2f, %.2f, %.2f, %.2f\n", [insertAtBeginningTimes[idx] floatValue], [insertAtEndTimes[idx] floatValue], [insertRandomTimes[idx] floatValue], [deleteBeginning[numberOfRuns-idx-1] floatValue], [deleteEnd[numberOfRuns-idx-1] floatValue], [deleteRandom[numberOfRuns-idx-1] floatValue]];
//    }

//    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//    if (![csvExport writeToFile:[documentPath stringByAppendingPathComponent:@"array-benchmark.csv"] atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
//        NSLog(@"Failed to write benchmark file.");
//    }else {
//        NSLog(@"Benchmark written.");
//    }
}











/// 创建数组带不带预估容量的时间差距
- (void)arrayAddBenchmark{
    
    [@[@(10000), @(100000), @(1000000), @(10000000), @(20000000)] enumerateObjectsUsingBlock:^(NSNumber *entriesNumber, NSUInteger runCount, BOOL *stop) {
        
        NSUInteger entries = entriesNumber.unsignedIntegerValue;
        printf("操作数量: %g [run %tu]", (double)entries, runCount+1);
        printf("\n");
        
        double array_add_time = 0,array_add_with_capacity_time = 0;
        const NSUInteger skipCount = 1;

        @autoreleasepool {
            NSMutableArray *array = [NSMutableArray array];
            NSNull *null = NSNull.null;
            array_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [array addObject:null];
                }
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    array[idx] = EntryForIDX(idx);
                }
            });
        }
        @autoreleasepool {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:entries];
            NSNull *null = NSNull.null;
            array_add_with_capacity_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [array addObject:null];
                }
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    array[idx] = EntryForIDX(idx);
                }
            });
        }
        
        if (array_add_time)        printf("NSMutableArray 添加元素 :      %f [ms]\n", array_add_time/1E6);
        if (array_add_with_capacity_time)      printf("NSMutableArray Capacity 添加元素:      %f [ms]\n", array_add_with_capacity_time/1E6);
        printf("\n");
    }];
}


/// 不同类型数据添加元素和随机访问元素
- (void)arrayBenchmark{
    [@[@(10000), @(100000), @(1000000), @(10000000), @(20000000)] enumerateObjectsUsingBlock:^(NSNumber *entriesNumber, NSUInteger runCount, BOOL *stop) {
        
        NSUInteger entries = entriesNumber.unsignedIntegerValue;
        printf("操作数量: %g [run %tu]", (double)entries, runCount+1);
        printf("\n");
        
        NSMutableSet *randomAccessNumbers = [NSMutableSet set];
        for (NSUInteger accessIdx = 0; accessIdx < entries/100; accessIdx++) {
            [randomAccessNumbers addObject:@(arc4random_uniform((u_int32_t)entries))];
        }
            
        // 步长
        const NSUInteger skipCount = 1;
        // 定义一些时间
        double  array_add_time = 0, cfArray_add_time = 0, pointerArray_add_time = 0;
        double array_rac_time = 0, cfArray_rac_time = 0, pointerArray_rac_time = 0;

        // Needs to be filled with nil - can't have NULL entries.
        @autoreleasepool {
            NSMutableArray *array = [NSMutableArray array];
            NSNull *null = NSNull.null;
            array_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [array addObject:null];
                }
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    array[idx] = EntryForIDX(idx);
                }
            });
            array_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused id object = array[idx];
                }];
            });
        }

        @autoreleasepool {
            CFMutableArrayRef arrayRef = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
            cfArray_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    CFArrayAppendValue(arrayRef, kCFNull);
                }
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    CFArraySetValueAtIndex(arrayRef, idx, (__bridge const void *)(EntryForIDX(idx)));
                }
            });
            cfArray_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused id object = CFArrayGetValueAtIndex(arrayRef, idx);
                }];
            });
        }

        @autoreleasepool {
            if (entries <= 1e4) {
                NSPointerArray *pointerArray = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsStrongMemory];
                [pointerArray setCount:entries];
                pointerArray_add_time = PerformAndTrackTime(^{
                    for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                        [pointerArray insertPointer:(__bridge void *)(EntryForIDX(idx)) atIndex:idx];
                    }
                });
                pointerArray_rac_time = PerformAndTrackTime(^{
                    [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                        __unused NSUInteger idx = number.unsignedIntegerValue;
                        __unused void *object = [pointerArray pointerAtIndex:idx];
                    }];
                });
            }
        }
        
        if (array_add_time)        printf("NSMutableArray 添加元素 :      %f [ms]\n", array_add_time/1E6);
        if (cfArray_add_time)      printf("CFMutableArray 添加元素:      %f [ms]\n", cfArray_add_time/1E6);
        
        if (array_rac_time)        printf("NSMutableArray 随机读取元素:      %f [ms]\n", array_rac_time/1E6);
        if (cfArray_rac_time)      printf("CFMutableArray 随机读取元素:      %f [ms]\n", cfArray_rac_time/1E6);
        
        if (pointerArray_add_time) printf("NSPointerArray 添加元素:      %f [ms]\n", pointerArray_add_time/1E6);
        
        if (pointerArray_rac_time) printf("NSPointerArray 随机读取元素:      %f [ms]\n", pointerArray_rac_time/1E6);
       
        printf("\n");
    }];
}

///遍历筛选
- (void)filteringArrayBenchmark {
    // Create random array
    
    [@[@(10000),@(10000000)] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSUInteger const numberOfEntries = [obj unsignedIntegerValue];
        
        printf("操作数量: %g [run %tu]", (double)numberOfEntries, idx+1);

        
        NSMutableArray *randomArray = [NSMutableArray array];
        // 添加元素
        for (NSUInteger idx = 0; idx < numberOfEntries; idx++) {
            [randomArray addObject:[NSString stringWithFormat:@"%tu", arc4random_uniform(500000)]];
        }
        // 筛选的block
        BOOL (^testObj)(id obj) = ^BOOL(id obj) {
            return [obj integerValue] < 10;
        };


        double filter1 = PerformAndTrackTime(^{
            NSIndexSet *indexes = [randomArray indexesOfObjectsWithOptions:0 passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return testObj(obj);
            }];
            __unused NSArray *filteredArray1 = [randomArray objectsAtIndexes:indexes];
        });

        double filter1_rec = PerformAndTrackTime(^{
            NSIndexSet *indexes = [randomArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return testObj(obj);
            }];
            __unused NSArray *filteredArray1 = [randomArray objectsAtIndexes:indexes];
        });

        double filter2 = PerformAndTrackTime(^{
            __unused NSArray *filteredArray2 = [randomArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
                return testObj(obj);
            }]];
        });

        double filter3 = PerformAndTrackTime(^{
            NSMutableArray *mutableArray = [NSMutableArray array];
            [randomArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (testObj(obj)) {
                    [mutableArray addObject:obj];
                }
            }];
            __unused NSArray *filteredArray3 = [mutableArray copy];
        });

        double filter4 = PerformAndTrackTime(^{
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (id obj in randomArray) {
                if (testObj(obj)) {
                    [mutableArray addObject:obj];
                }
            }
            __unused NSArray *filteredArray4 = [mutableArray copy];
        });

        double filter5 = PerformAndTrackTime(^{
            NSMutableArray *mutableArray = [NSMutableArray array];
            NSEnumerator *enumerator = [randomArray objectEnumerator];
            id obj = nil;
            while ((obj = [enumerator nextObject]) != nil) {
                if (testObj(obj)) {
                    [mutableArray addObject:obj];
                }
            }
            __unused NSArray *filteredArray5 = [mutableArray copy];
        });

        double filter6 = PerformAndTrackTime(^{
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (NSUInteger idx = 0; idx < randomArray.count; idx++) {
                id obj = randomArray[idx];
                if (testObj(obj)) {
                    [mutableArray addObject:obj];
                }
            }
            __unused NSArray *filteredArray6 = [mutableArray copy];
        });

        printf("\n");
        printf("NSMutableArray indexesOfObjects遍历筛选  :      %f [ms]\n", filter1/1E6);
        printf("NSMutableArray indexesOfObjects-concurrent遍历筛选  :      %f [ms]\n", filter1_rec/1E6);
        printf("NSMutableArray filteredArrayUsingPredicate遍历筛选  :      %f [ms]\n", filter2/1E6);
        printf("NSMutableArray enumerateObjectsUsingBlock 遍历筛选  :      %f [ms]\n", filter3/1E6);
        printf("NSMutableArray for in 遍历筛选  :      %f [ms]\n", filter4/1E6);
        printf("NSMutableArray objectEnumerator 遍历筛选  :      %f [ms]\n", filter5/1E6);
        printf("NSMutableArray objectAtIndex 遍历筛选  :      %f [ms]\n", filter6/1E6);
        
        printf("\n");
    }];
}

// 排序 和 查找
- (void)sortingBenchmark {
    // Create random array
    NSUInteger const numberOfEntries = 1000000;
    NSMutableArray *randomArray = [NSMutableArray array];
    for (NSUInteger idx = 0; idx < numberOfEntries; idx++) {
        [randomArray addObject:[NSString stringWithFormat:@"%tu", arc4random_uniform(500000)]];
    }

    
    double sort1 = PerformAndTrackTime(^{
        [randomArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    });

    double sort2 = PerformAndTrackTime(^{
        [randomArray sortedArrayUsingFunction:localizedCaseInsensitiveCompareSort context:NULL];
    });

    NSComparator caseInsensitiveComparator = ^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCaseInsensitiveCompare:obj2];
    };

    double sort3 = PerformAndTrackTime(^{
        [randomArray sortedArrayWithOptions:0 usingComparator:caseInsensitiveComparator];
    });
    
    double sort4 = PerformAndTrackTime(^{
        [randomArray sortedArrayWithOptions:NSSortConcurrent usingComparator:caseInsensitiveComparator];
    });

    NSLog(@"排序 %tu 个元素. selector: %.2f[ms] function: %.2f[ms] block: %.2f[ms].block-Concurrent: %.2f[ms].", randomArray.count, sort1/1E6, sort2/1E6, sort3/1E6, sort4/1E6);
    

    NSArray *sortedArray = [randomArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSUInteger const searchNumberOfEntries = numberOfEntries/1000;

    double contains1 = PerformAndTrackTime(^{
        for (NSUInteger idx = 0; idx < searchNumberOfEntries; idx++) {
            [sortedArray indexOfObject:randomArray[idx]];
        }
    });

    double contains2 = PerformAndTrackTime(^{
        for (NSUInteger idx = 0; idx < searchNumberOfEntries; idx++) {
            [sortedArray indexOfObject:randomArray[idx] inSortedRange:NSMakeRange(0, numberOfEntries) options:NSBinarySearchingFirstEqual usingComparator:caseInsensitiveComparator];
        }
    });

    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:sortedArray];
    double contains3 = PerformAndTrackTime(^{
        for (NSUInteger idx = 0; idx < searchNumberOfEntries; idx++) {
            [orderedSet indexOfObject:randomArray[idx]];
        }
    });

    NSLog(@"查找 %tu 个元素. 遍历: %.2f[ms]. 二分: %.2f[ms] NSOrderedSet: %.2f[ms]", searchNumberOfEntries, contains1/1E6, contains2/1E6, contains3/1E6);
}




@end
