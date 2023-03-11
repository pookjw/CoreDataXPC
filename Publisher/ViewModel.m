//
//  ViewModel.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "ViewModel.h"
#import "DataManager.h"
#import "DataManagedObject.h"

@interface ViewModel ()
@end

@implementation ViewModel

- (void)publishWithText:(NSString *)text completionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    [DataManager.sharedInstance.queue addBarrierBlock:^{
        NSManagedObjectContext *context = DataManager.sharedInstance.context;
        DataManagedObject *dataManagedObject = [[DataManagedObject alloc] initWithContext:context];
        dataManagedObject.text = text;
        
        NSDate *timestamp = [NSDate new];
        dataManagedObject.timestamp = timestamp;
        [timestamp release];
        
        NSError * _Nullable __autoreleasing error = nil;
        [context obtainPermanentIDsForObjects:@[dataManagedObject] error:&error];
        if (error) {
            completionHandler(error);
            return;
        }
        
        [dataManagedObject release];
        
        [context performBlockAndWait:^{
            NSError * _Nullable __autoreleasing error = nil;
            [context save:&error];
            completionHandler(error);
        }];
    }];
}

@end
