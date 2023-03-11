//
//  ViewModel.m
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "ViewModel.h"
#import "DataManager.h"
#import "DataManagedObject.h"

@interface ViewModel () <NSFetchedResultsControllerDelegate>
@property (retain) DataSource *dataSource;
@property (retain) DataManager *dataManager;
@end

@implementation ViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self setupDataManager];
        [self setupFetchedResultsController];
    }
    
    return self;
}

- (void)dealloc {
    [_dataSource release];
    [_dataManager release];
    [_fetchedResultsController release];
    [super dealloc];
}

- (void)fetchWithDataSource:(DataSource *)dataSource {
    self.dataSource = dataSource;
    
    NSError * _Nullable __autoreleasing error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        [NSException raise:NSInternalInconsistencyException format:@"%@", error];
        return;
    }
}

- (void)setupDataManager {
    DataManager *dataManager = DataManager.sharedInstance;
    self.dataManager = dataManager;
}

- (void)setupFetchedResultsController {
    NSFetchRequest *fetchRequest = [DataManagedObject fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    [sortDescriptor release];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.dataManager.context
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    
    fetchedResultsController.delegate = self;
    [_fetchedResultsController release];
    _fetchedResultsController = [fetchedResultsController retain];
    [fetchedResultsController release];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
    }];
}

@end
