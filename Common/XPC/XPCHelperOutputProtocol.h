//
//  XPCHelperOutputProtocol.h
//  CoreDataXPC
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPCHelperOutputProtocol <NSObject>
- (void)output_objectsDidChange:(NSDictionary<NSString *, NSURL *> *)changes;
@end

NS_ASSUME_NONNULL_END
