//
//  ViewModel.h
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> DataSource;

@interface ViewModel : NSObject
@property (retain, readonly) NSFetchedResultsController *fetchedResultsController;
- (void)fetchWithDataSource:(DataSource *)dataSource;
@end

NS_ASSUME_NONNULL_END
