//
//  TimerBenchmark.h
//  iOS_Collection
//
//  Created by 金医桥 on 2020/12/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT double PerformAndTrackTime(dispatch_block_t block);
FOUNDATION_EXPORT inline id EntryForIDX(NSUInteger idx);
FOUNDATION_EXPORT CFStringRef CF_RETURNS_NOT_RETAINED RawKeyDescription(const void *value);
FOUNDATION_EXPORT Boolean RawEqual(const void *val1, const void *val2);
FOUNDATION_EXPORT CFHashCode RawHash(const void *value);
FOUNDATION_EXPORT CFDictionaryKeyCallBacks RawKeyDictionaryCallbacks;
FOUNDATION_EXPORT NSInteger alphabeticSort(id string1, id string2, void *reverse);
FOUNDATION_EXPORT NSInteger localizedCaseInsensitiveCompareSort(id string1, id string2, void *context);
FOUNDATION_EXPORT double PerformAndTrackTimeMultiple(dispatch_block_t block, NSUInteger runs);

@interface TimerBenchmark : NSObject

- (void)startBenchmark;


@end

NS_ASSUME_NONNULL_END
