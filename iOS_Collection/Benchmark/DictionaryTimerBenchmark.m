//
//  DictionaryTimerBenchmark.m
//  iOS_Collection
//
//  Created by 金医桥 on 2020/12/16.
//

#import "DictionaryTimerBenchmark.h"
#import "DictKey.h"

@implementation DictionaryTimerBenchmark

- (void)startBenchmark{
    [self cfDictionaryKeyCopyTest];
//    [self sharedKeySetForKeysBenchmark];
//    [self dictionaryAddBenchmark];
    
//    [self filteringDictionaryBenchmark];
    
}

// CFMutableDictionary 会不会copykey, 只有Test3 和 Test4 会 copy
- (void)cfDictionaryKeyCopyTest {
    CFMutableDictionaryRef dictRef = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    DictKey *obj = [DictKey new];

    // Setting via Core Foundation does not invoke copyWithZone: on the object.
    CFDictionarySetValue(dictRef, (__bridge const void *)(obj), CFSTR("Test1"));

    // Casting to NSMutableDictionary will call copy.
    ((__bridge NSMutableDictionary *)dictRef)[obj] = @"test2";

    CFRelease(dictRef);

    // Will always copy keys.
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    CFDictionarySetValue((__bridge CFMutableDictionaryRef)(mutableDict), (__bridge const void *)(obj), CFSTR("Test3"));
    mutableDict[obj] = @"Test4";
    
}





- (void)dictionaryAddBenchmark{
    
    [@[@(10000), @(100000), @(1000000), @(10000000), @(20000000)] enumerateObjectsUsingBlock:^(NSNumber *entriesNumber, NSUInteger runCount, BOOL *stop) {
        
        NSUInteger entries = entriesNumber.unsignedIntegerValue;
        printf("操作数量: %g [run %tu]", (double)entries, runCount+1);
        printf("\n");
        
        double dictionary_add_time = 0,dictionary_add_with_capacity_time = 0;
        const NSUInteger skipCount = 1;

        @autoreleasepool {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSNull *null = NSNull.null;
            dictionary_add_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [dict setObject:null forKey:@(idx)];
                }
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    dict[@(idx)] = EntryForIDX(idx);
                }
            });
        }
        @autoreleasepool {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:entries];
            NSNull *null = NSNull.null;
            dictionary_add_with_capacity_time = PerformAndTrackTime(^{
                for (NSUInteger idx = 0; idx < entries; idx++) {
                    [dict setObject:null forKey:@(idx)];
                }
                for (NSUInteger idx = 0; idx < entries; idx+=skipCount) {
                    dict[@(idx)] = EntryForIDX(idx);
                }
            });
        }
        
        if (dictionary_add_time)        printf("NSMutableDictionary 添加元素 :      %f [ms]\n", dictionary_add_time/1E6);
        if (dictionary_add_with_capacity_time)      printf("NSMutableDictionary Capacity 添加元素:      %f [ms]\n", dictionary_add_with_capacity_time/1E6);
        printf("\n");
    }];
}



// 测试 sharedKeySetForKeys
- (void)sharedKeySetForKeysBenchmark{
    id sharedKeySet = [NSDictionary sharedKeySetForKeys:@[@1, @2, @3]]; // 返回 NSSharedKeySet
    NSMutableDictionary *test = [NSMutableDictionary dictionaryWithSharedKeySet:sharedKeySet];
    test[@4] = @"First element (not in the shared key set, but will work as well)";
    NSDictionary *immutable = [test copy];
    NSParameterAssert(immutable.count == 1);
    ((NSMutableDictionary *)immutable)[@5] = @"Adding objects to an immutable collection should throw an exception.";
    NSParameterAssert(immutable.count == 2);
}

// 测试字典的过滤
- (void)filteringDictionaryBenchmark {
    @autoreleasepool {
        // Create random dictionary
        NSUInteger const numberOfEntries = 1000000;
        NSMutableDictionary *randomDict = [NSMutableDictionary dictionary];
        for (NSUInteger idx = 0; idx < numberOfEntries; idx++) {
            randomDict[@(idx)] = [NSString stringWithFormat:@"%tu", arc4random_uniform(500000)];
        }

        BOOL (^testObj)(id obj) = ^BOOL(id obj) {
            return [obj integerValue] < 10;
        };

        double filter1 = PerformAndTrackTimeMultiple(^{
            NSSet *matchingKeys = [randomDict keysOfEntriesWithOptions:0 passingTest:^BOOL(id key, id obj, BOOL *stop) {
                return testObj(obj);
            }];
            NSArray *keys = matchingKeys.allObjects;
            NSArray *values = [randomDict objectsForKeys:keys notFoundMarker:NSNull.null];
            __unused NSDictionary *filteredDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        }, 3);

        double filter2 = PerformAndTrackTimeMultiple(^{
            NSArray *keys = [randomDict keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
                return testObj(obj);
            }].allObjects;
            __unused NSDictionary *filteredDictionary2 = [NSDictionary dictionaryWithObjects:[randomDict objectsForKeys:keys notFoundMarker:NSNull.null] forKeys:keys];
        }, 3);

        double filter3 = PerformAndTrackTimeMultiple(^{
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
            [randomDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (testObj(obj)) {
                    mutableDictionary[key] = obj;
                }
            }];
            __unused NSDictionary *filteredDictionary3 = [mutableDictionary copy];
        }, 3);

        double filter4 = PerformAndTrackTimeMultiple(^{
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
            for (id key in randomDict) {
                id obj = randomDict[key];
                if (testObj(obj)) {
                    mutableDictionary[key] = obj;
                }
            }
            __unused NSDictionary *filteredDictionary4 = [mutableDictionary copy];
        }, 3);

        double filter5 = PerformAndTrackTimeMultiple(^{
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
            id __unsafe_unretained *objects = (id __unsafe_unretained *)malloc(sizeof(id) * numberOfEntries);
            id __unsafe_unretained *keys = (id __unsafe_unretained *)(malloc(sizeof(id) * numberOfEntries));
            [randomDict getObjects:objects andKeys:keys count:numberOfEntries];
            for (int i = 0; i < numberOfEntries; i++) {
                id obj = objects[i];
                id key = keys[i];
                if (testObj(obj)) {
                    mutableDictionary[key] = obj;
                }
            }
            free(objects);
            free(keys);
            __unused NSDictionary *filteredDictionary5 = [mutableDictionary copy];
        }, 3);

        double filter6 = PerformAndTrackTimeMultiple(^{
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
            NSEnumerator *enumerator = [randomDict keyEnumerator];
            id key = nil;
            while ((key = [enumerator nextObject]) != nil) {
                id obj = randomDict[key];
                if (testObj(obj)) {
                    mutableDictionary[key] = obj;
                }
            }
            __unused NSDictionary *filteredDictionary6 = [mutableDictionary copy];
        }, 3);

        printf("\n");
        printf("keysOfEntriesWithOptions 遍历筛选  :      %f [ms]\n", filter1/1E6);
        printf("keysOfEntriesWithOptions (concurrent)遍历筛选  :      %f [ms]\n", filter2/1E6);
        printf("enumerateKeysAndObjectsUsingBlock 遍历筛选  :      %f [ms]\n", filter3/1E6);
        printf("NSFastEnumeration 遍历筛选  :      %f [ms]\n", filter4/1E6);
        printf("getObjects 遍历筛选  :      %f [ms]\n", filter5/1E6);
        printf("NSEnumeration 遍历筛选  :      %f [ms]\n", filter6/1E6);
        
        printf("\n");
    }
}





@end
