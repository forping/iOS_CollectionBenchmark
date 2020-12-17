//
//  TimerBenchmark.m
//  iOS_Collection
//
//  Created by 金医桥 on 2020/12/16.
//

#import "TimerBenchmark.h"
#import "ThreadSafeMutableDictionary.h"

#include <mach/mach_time.h>

double PerformAndTrackTimeMultiple(dispatch_block_t block, NSUInteger runs) {
    // Calculate the median result
    double time = 0;
    for (NSUInteger runIndex = 0; runIndex < runs; runIndex++) {
        time += PerformAndTrackTime(block);
    }

    return time/runs;
}

// 基准功能。 返回时间（以纳秒为单位）。 （nsec / 1E9 =秒）
double PerformAndTrackTime(dispatch_block_t block) {
    uint64_t startTime = mach_absolute_time();
    block();
    uint64_t endTime = mach_absolute_time();

    // 经过的时间:mach time
    uint64_t elapsedTime = endTime - startTime;

    //将mach time单位转换为纳秒
    static double ticksToNanoseconds = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
    });
    
    // 获得纳秒
    double elapsedTimeInNanoseconds = elapsedTime * ticksToNanoseconds;
    //NSLog(@"seconds: %f", elapsedTimeInNanoseconds/1E9);// 获得秒
    //printf(".");
    return elapsedTimeInNanoseconds;
}

inline id EntryForIDX(NSUInteger idx) {
    char buf[100];
    // 将可变参数 “…” 按照format的格式格式化为字符串，然后再将其拷贝至str中。
    snprintf(buf, 100, "%tu", idx);
    return @(buf);
}


CFStringRef CF_RETURNS_NOT_RETAINED RawKeyDescription(const void *value) {return (__bridge CFStringRef)[NSString stringWithFormat:@"%c", (UniChar)value];}
Boolean RawEqual(const void *val1, const void *val2) {return val1 == val2; }
// Multiplying by 31 (prime) gives us a lot better hash, resulting in a 4x performance increase.
CFHashCode RawHash(const void *value) { return (CFHashCode)value * 31;}
CFDictionaryKeyCallBacks RawKeyDictionaryCallbacks = {0, NULL, NULL, RawKeyDescription, RawEqual, RawHash };

static int count = 0;
NSInteger alphabeticSort(id string1, id string2, void *reverse)
{
    count++;

    if (*(BOOL *)reverse == YES) {
        return [string2 localizedCaseInsensitiveCompare:string1];
    }
    return [string1 localizedCaseInsensitiveCompare:string2];
}


NSInteger localizedCaseInsensitiveCompareSort(id string1, id string2, void *context) {
    return [string1 localizedCaseInsensitiveCompare:string2];
}
































@implementation TimerBenchmark

- (id)init {
    if (self = [super init]) {
        [self startBenchmark];
    }
    return self;
}

- (void)startBenchmark{
    [self collectionBenchmark];

}





- (void)collectionBenchmark {
    [@[@(10000), @(100000), @(1000000), @(10000000), @(20000000)] enumerateObjectsUsingBlock:^(NSNumber *entriesNumber, NSUInteger runCount, BOOL *stop) {
        NSUInteger entries = entriesNumber.unsignedIntegerValue;
        printf("操作数量: %g [run %tu]", (double)entries, runCount+1);
        
        
        NSMutableSet *randomAccessNumbers = [NSMutableSet set];
        for (NSUInteger accessIdx = 0; accessIdx < entries/100; accessIdx++) {
            [randomAccessNumbers addObject:@(arc4random_uniform((u_int32_t)entries))];
        }
            
        // 步长
        const NSUInteger skipCount = 1;
        // 定义一些时间
        double dict_add_time = 0, dict_ts_add_time = 0, cfDict_add_time = 0, cache_add_time = 0, array_add_time = 0, cfArray_add_time = 0, pointerArray_add_time = 0, maptable_add_time = 0, ordered_set_add_time = 0, set_add_time = 0, hashtable_add_time = 0;
        double dict_rac_time = 0, dict_ts_rac_time = 0, cfDict_rac_time = 0, cache_rac_time = 0, array_rac_time = 0, cfArray_rac_time = 0, pointerArray_rac_time = 0, maptable_rac_time = 0, ordered_set_rac_time = 0, set_rac_time = 0, hashtable_rac_time = 0;
        double set_contains_time = 0, hashtable_contains_time = 0, set_iteration_time = 0, hashtable_iteration_time = 0;

        // 字典添加时间/随机访问时间
        @autoreleasepool {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            dict_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    dictionary[@(idx)] = EntryForIDX(idx);
                }
            });
            dict_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused id object = dictionary[number];
                }];
            });
        }

        // Fonudation 字典
        @autoreleasepool {
            NSMutableDictionary *dictionary = [ThreadSafeMutableDictionary dictionary];
            dict_ts_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    dictionary[@(idx)] = EntryForIDX(idx);
                }
            });
            dict_ts_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused id object = dictionary[number];
                }];
            });
        }
        
        // CoreFoundation 字典
        @autoreleasepool {
            CFMutableDictionaryRef dictionaryRef = CFDictionaryCreateMutable(NULL, 0, &RawKeyDictionaryCallbacks, &kCFTypeDictionaryValueCallBacks);
            cfDict_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    CFDictionarySetValue(dictionaryRef, (void *)idx, (__bridge const void *)(EntryForIDX(idx)));
                }
            });
            cfDict_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused const void *object = CFDictionaryGetValue(dictionaryRef, (void *)idx);
                }];
            });
        }

        // cache
        @autoreleasepool {
            NSCache *cache = [NSCache new];
            cache_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    [cache setObject:EntryForIDX(idx) forKey:@(idx)];
                }
            });
            cache_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused id object = [cache objectForKey:@(idx)];
                }];
            });
        }

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

        @autoreleasepool {
            NSMapTable *mapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsObjectPersonality valueOptions:NSPointerFunctionsObjectPersonality capacity:0];
            maptable_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    [mapTable setObject:EntryForIDX(idx) forKey:@(idx)];
                }
            });
            maptable_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused id object = [mapTable objectForKey:number];
                }];
            });
        }

        @autoreleasepool {
            NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
            ordered_set_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [orderedSet addObject:EntryForIDX(idx)];
                }
            });
            ordered_set_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    __unused id object = [orderedSet objectAtIndex:idx];
                }];
            });
        }

        @autoreleasepool {
            NSMutableSet *set = [NSMutableSet set];
            set_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [set addObject:EntryForIDX(idx)];
                }
            });
            set_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    [set anyObject];
                }];
            });
            set_contains_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    [set containsObject:number];
                }];
            });
            set_iteration_time = PerformAndTrackTime(^{
                for (NSString *obj in set) {
                    // nothing
                }
            });

        }

        @autoreleasepool {
            NSHashTable *hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
            hashtable_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [hashTable addObject:EntryForIDX(idx)];
                }
            });
            hashtable_rac_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    __unused NSUInteger idx = number.unsignedIntegerValue;
                    [hashTable anyObject];
                }];
            });
            hashtable_contains_time = PerformAndTrackTime(^{
                [randomAccessNumbers enumerateObjectsUsingBlock:^(NSNumber *number, BOOL *stop) {
                    [hashTable containsObject:number];
                }];
            });
            hashtable_iteration_time = PerformAndTrackTime(^{
                for (NSString *obj in hashTable) {
                    // nothing
                }
            });
        }

        printf("\n");
        if (dict_add_time)         printf("Adding Elements to NSMutableDictionary: %f [ms]\n", dict_add_time/1E6);
        if (dict_ts_add_time)      printf("Adding Elements to ThreadSafeMutableDictionary: %f [ms]\n", dict_ts_add_time/1E6);
        if (cfDict_add_time)       printf("Adding Elements to CFMutableDictionary: %f [ms]\n", cfDict_add_time/1E6);
        if (cache_add_time)        printf("Adding Elements to NSCache:             %f [ms]\n", cache_add_time/1E6);
        if (array_add_time)        printf("Adding Elements to NSMutableArray:      %f [ms]\n", array_add_time/1E6);
        if (cfArray_add_time)      printf("Adding Elements to CFMutableArray:      %f [ms]\n", cfArray_add_time/1E6);
        if (ordered_set_add_time)  printf("Adding Elements to NSMutableOrderedSet: %f [ms]\n", ordered_set_add_time/1E6);
        if (set_add_time)          printf("Adding Elements to NSMutableSet:        %f [ms]\n", set_add_time/1E6);
        if (hashtable_add_time)    printf("Adding Elements to NSHashTable:         %f [ms]\n", hashtable_add_time/1E6);
        if (pointerArray_add_time) printf("Adding Elements to NSPointerArray:      %f [ms]\n", pointerArray_add_time/1E6);
        if (maptable_add_time)     printf("Adding Elements to NSMapTable:          %f [ms]\n", maptable_add_time/1E6);
        printf("\n");
        if (dict_rac_time)         printf("Random Access for  NSMutableDictionary: %f [ms]\n", dict_rac_time/1E6);
        if (dict_ts_rac_time)      printf("Random Access for  ThreadSafeMutableDictionary: %f [ms]\n", dict_ts_rac_time/1E6);
        if (cfDict_rac_time)       printf("Random Access for  CFMutableDictionary: %f [ms]\n", cfDict_rac_time/1E6);
        if (cache_rac_time)        printf("Random Access for  NSCache:             %f [ms]\n", cache_rac_time/1E6);
        if (array_rac_time)        printf("Random Access for  NSMutableArray:      %f [ms]\n", array_rac_time/1E6);
        if (cfArray_rac_time)      printf("Random Access for  CFMutableArray:      %f [ms]\n", cfArray_rac_time/1E6);
        if (ordered_set_rac_time)  printf("Random Access for  NSMutableOrderedSet: %f [ms]\n", ordered_set_rac_time/1E6);
        if (set_rac_time)          printf("Random Access for  NSMutableSet:        %f [ms]\n", set_rac_time/1E6);
        if (hashtable_rac_time)    printf("Random Access for  NSHashTable:         %f [ms]\n", hashtable_rac_time/1E6);
        if (pointerArray_rac_time) printf("Random Access for  NSPointerArray:      %f [ms]\n", pointerArray_rac_time/1E6);
        if (maptable_rac_time)     printf("Random Access for  NSMapTable:          %f [ms]\n", maptable_rac_time/1E6);
        printf("\n");
        if (set_contains_time)     printf("containsObject: for NSMutableSet:      %f [ms]\n", set_contains_time/1E6);
        if (hashtable_contains_time) printf("containsObject: for NSHashTable:       %f [ms]\n", hashtable_contains_time/1E6);
        if (set_iteration_time)     printf("NSFastEnumeration for NSMutableSet:     %f [ms]\n", set_iteration_time/1E6);
        if (hashtable_iteration_time) printf("NSFastEnumeration for NSHashTable:    %f [ms]\n", hashtable_iteration_time/1E6);
        printf("\n");
    }];
}








@end
