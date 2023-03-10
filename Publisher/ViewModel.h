//
//  ViewModel.h
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewModel : NSObject
- (void)publishWithText:(NSString *)text completionHandler:(void (^)(NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
