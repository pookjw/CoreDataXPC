//
//  CollectionViewItem.h
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Cocoa/Cocoa.h>
#import "DataManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

static NSUserInterfaceItemIdentifier const NSUserInterfaceItemIdentifierCollectionViewItem = @"NSUserInterfaceItemIdentifierCollectionViewItem";

@interface CollectionViewItem : NSCollectionViewItem
- (void)configureWithDataManagedObject:(DataManagedObject *)dataManagedObject;
@end

NS_ASSUME_NONNULL_END
