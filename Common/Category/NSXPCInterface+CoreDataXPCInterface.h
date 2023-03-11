//
//  NSXPCInterface+CoreDataXPCInterface.h
//  CoreDataXPC
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSXPCInterface (CoreDataXPCInterface)
+ (NSXPCInterface *)interfaceWithCoreDataXPC;
@end

NS_ASSUME_NONNULL_END
