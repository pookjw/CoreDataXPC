//
//  CoreDataXPCProtocol.h
//  CoreDataXPC
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CoreDataXPCProtocol <NSObject>
- (void)input_objectsDidChange:(NSDictionary<NSString *, NSURL *> *)changes;
- (void)output_objectsDidChange:(NSDictionary<NSString *, NSURL *> *)changes;
- (void)ready;
@end
NS_ASSUME_NONNULL_END
