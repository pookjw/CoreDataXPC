//
//  ViewController.m
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "ViewController.h"
#import "ViewModel.h"
#import "CollectionViewItem.h"

@interface ViewController ()
@property (retain) NSVisualEffectView *blurView;
@property (retain) NSScrollView *scrollView;
@property (retain) NSCollectionView *collectionView;
@property (retain) ViewModel *viewModel;
@end

@implementation ViewController

- (void)dealloc {
    [_blurView release];
    [_scrollView release];
    [_collectionView release];
    [_viewModel release];
    [super dealloc];
}

- (void)loadView {
    NSView *view = [NSView new];
    self.view = view;
    [view release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVisualEffectView];
    [self setupScrollView];
    [self setupCollectionView];
    [self setupViewModel];
    [self loadDataSource];
}

- (void)setupVisualEffectView {
    NSVisualEffectView *blurView = [NSVisualEffectView new];
    
    blurView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:blurView];
    [NSLayoutConstraint activateConstraints:@[
        [blurView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [blurView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [blurView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [blurView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.blurView = blurView;
    [blurView release];
}

- (void)setupScrollView {
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.drawsBackground = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.scrollView = scrollView;
    [scrollView release];
}

- (void)setupCollectionView {
    NSCollectionView *collectionView = [[NSCollectionView alloc] initWithFrame:self.view.bounds];
    collectionView.collectionViewLayout = [self createCollectionViewLayout];
    [collectionView registerClass:CollectionViewItem.class forItemWithIdentifier:NSUserInterfaceItemIdentifierCollectionViewItem];
    
    self.scrollView.documentView = collectionView;
    self.collectionView = collectionView;
    [collectionView release];
}

- (void)setupViewModel {
    ViewModel *viewModel = [ViewModel new];
    self.viewModel = viewModel;
    [viewModel release];
}

- (void)loadDataSource {
    NSFetchedResultsController *fetchedResultsController = self.viewModel.fetchedResultsController;
    
    DataSource *dataSource = [[DataSource alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSManagedObjectID * _Nonnull itemIdentifier) {
        CollectionViewItem *item = [collectionView makeItemWithIdentifier:NSUserInterfaceItemIdentifierCollectionViewItem forIndexPath:indexPath];
        DataManagedObject *dataManagedObject = [fetchedResultsController objectAtIndexPath:indexPath];
        
        [item configureWithDataManagedObject:dataManagedObject];
        return item;
    }];
    
    [self.viewModel fetchWithDataSource:dataSource];
    [dataSource release];
}

- (NSCollectionViewCompositionalLayout *)createCollectionViewLayout {
    NSCollectionViewCompositionalLayoutConfiguration *configuration = [NSCollectionViewCompositionalLayoutConfiguration new];
    configuration.scrollDirection = NSCollectionViewScrollDirectionVertical;
    
    NSCollectionViewCompositionalLayout *collectionViewLayout = [[NSCollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment> _Nonnull envrionment) {
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                                          heightDimension:[NSCollectionLayoutDimension estimatedDimension:20.f]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        
        NSCollectionLayoutSize *groupSize = itemSize;
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:groupSize subitems:@[item]];
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        return section;
    } 
                                                                                                                       configuration:configuration];
    
    [configuration release];
    return [collectionViewLayout autorelease];
}

@end
