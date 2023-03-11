//
//  XPCHelperProtocol.h
//  CoreDataXPC
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPCHelperProtocol <NSObject>
- (void)objectsDidChange:(NSDictionary<NSString *, NSURL *> *)changes withReply:(void (^)(void))reply;
@end

NS_ASSUME_NONNULL_END
