//
//  PublisherXPCManager.h
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PublisherXPCManager : NSObject
@property (class, retain, readonly) PublisherXPCManager *sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)run;
@end

NS_ASSUME_NONNULL_END
