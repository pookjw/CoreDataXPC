//
//  NSXPCInterface+CoreDataXPCInterface.m
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "NSXPCInterface+CoreDataXPCInterface.h"
#import "CoreDataXPCProtocol.h"

@implementation NSXPCInterface (CoreDataXPCInterface)

+ (NSXPCInterface *)interfaceWithCoreDataXPC {
    NSXPCInterface *result = [NSXPCInterface interfaceWithProtocol:@protocol(CoreDataXPCProtocol)];
    
    [result setClasses:[NSSet setWithArray:@[NSDictionary.class, NSArray.class, NSString.class, NSURL.class]]
           forSelector:@selector(input_objectsDidChange:)
         argumentIndex:0
               ofReply:NO];
    
    [result setClasses:[NSSet setWithArray:@[NSDictionary.class, NSArray.class, NSString.class, NSURL.class]]
           forSelector:@selector(output_objectsDidChange:)
         argumentIndex:0
               ofReply:NO];
    
    return result;
}

@end
