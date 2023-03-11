//
//  DataManger.h
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject
@property (class, retain, readonly) DataManager *sharedInstance;
@property (retain, readonly) NSPersistentContainer *container; // only accessed by operations on self.queue
@property (retain, readonly) NSManagedObjectContext *context; // only accessed by operations on self.queue
@property (retain, readonly) NSOperationQueue *queue;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
