//
//  DataManger.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "DataManger.h"

@interface DataManger ()

@end

@implementation DataManger

+ (DataManger *)sharedInstance {
    static DataManger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [DataManger new];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
