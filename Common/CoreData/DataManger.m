//
//  DataManger.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "DataManger.h"
#import "DataManagedObject.h"

@interface DataManger ()
@property (readonly) NSEntityDescription *entityDescription;
@end

@implementation DataManger

+ (DataManger *)sharedInstance {
    static DataManger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [DataManger new];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupQueue];
        [self setupContainer];
        [self setupContext];
        [self addObserver];
    }
    
    return self;
}

- (void)dealloc {
    [_container release];
    [_context release];
    [_queue cancelAllOperations];
    [_queue release];
    [super dealloc];
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceUtility;
    [_queue release];
    _queue = [queue retain];
}

- (void)setupContainer {
    [self.queue addBarrierBlock:^{
        NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel new];
        managedObjectModel.entities = @[self.entityDescription];
        
        NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"DataContainer" managedObjectModel:managedObjectModel];
        [managedObjectModel release];
        
        NSArray<NSURL *> *desktopURLs = [NSFileManager.defaultManager URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask];
        NSURL * _Nullable desktopURL = desktopURLs.firstObject;
        NSAssert(desktopURL, @"Unexpected!");
        NSURL *dbURL = [[[desktopURL URLByAppendingPathComponent:@"CoreDataXPC" isDirectory:YES] URLByAppendingPathComponent:@"DataContainer" isDirectory:NO] URLByAppendingPathExtension:@"sqlite"];
        
        NSPersistentStoreDescription *persistentStoreDescription = [[NSPersistentStoreDescription alloc] initWithURL:dbURL];
#if PUBLISHER_APP
        persistentStoreDescription.readOnly = NO;
#elif RECEIVER_APP
        persistentStoreDescription.readOnly = YES;
#endif
        
        container.persistentStoreDescriptions = @[persistentStoreDescription];
        [persistentStoreDescription release];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull persistentStoreDescription, NSError * _Nullable error) {
            if (error) {
                [NSException raise:NSInternalInconsistencyException format:@"%@", error];
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        [_container release];
        _container = [container retain];
        [container release];
    }];
}

- (void)setupContext {
    [self.queue addBarrierBlock:^{
        NSManagedObjectContext *context = self.container.newBackgroundContext;
        NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        context.mergePolicy = mergePolicy;
        [mergePolicy release];
        
        [_context release];
        _context = [context retain];
    }];
}

- (void)addObserver {
    [self.queue addBarrierBlock:^{
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(triggeredContextDidSaveNotification:)
                                                   name:NSManagedObjectContextObjectsDidChangeNotification
                                                 object:self.context];
    }];
}

- (NSEntityDescription *)entityDescription {
    NSEntityDescription *entityDescription = [NSEntityDescription new];
    
    entityDescription.name = NSStringFromClass(DataManagedObject.class);
    entityDescription.managedObjectClassName = NSStringFromClass(DataManagedObject.class);
    
    NSAttributeDescription *textAttributeDescription = [NSAttributeDescription new];
    textAttributeDescription.name = @"text";
    textAttributeDescription.attributeType = NSStringAttributeType;
    textAttributeDescription.optional = NO;
    
    NSAttributeDescription *timestampAttributeDescription = [NSAttributeDescription new];
    timestampAttributeDescription.name = @"timestamp";
    timestampAttributeDescription.attributeType = NSDateAttributeType;
    textAttributeDescription.optional = NO;
    
    entityDescription.properties = @[
        textAttributeDescription,
        timestampAttributeDescription
    ];
    
    [textAttributeDescription release];
    [timestampAttributeDescription release];
    
    return [entityDescription autorelease];
}

- (void)triggeredContextDidSaveNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSMutableDictionary *changes = [NSMutableDictionary new];
    [userInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSSet<DataManagedObject *> class]]) {
            NSMutableArray *URIRepresentations = [NSMutableArray new];
            [obj enumerateObjectsUsingBlock:^(DataManagedObject * _Nonnull obj, BOOL * _Nonnull stop) {
                [URIRepresentations addObject:obj.objectID.URIRepresentation];
            }];
            changes[key] = URIRepresentations;
            [URIRepresentations release];
        } else {
            changes[key] = obj;
        }
    }];
    
    [changes release];
}

@end
