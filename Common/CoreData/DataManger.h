//
//  DataManger.h
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManger : NSObject
@property (class, retain, readonly) DataManger *sharedInstance;
@property (retain, readonly) NSPersistentContainer *container;
@property (retain, readonly) NSManagedObjectContext *context;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
