//
//  ViewController.m
//  iOS_Collection
//
//  Created by 金医桥 on 2020/12/16.
//

#import "ViewController.h"

#import "ArrayTimerBenchmark.h"
#import "DictionaryTimerBenchmark.h"
#import "SetTimerBenchmark.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [SetTimerBenchmark new];
}


@end
