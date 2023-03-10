//
//  DataManagedObject.h
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManagedObject : NSManagedObject
@property (retain) NSString *text;
@property (retain) NSDate *timestamp;
@end

NS_ASSUME_NONNULL_END
