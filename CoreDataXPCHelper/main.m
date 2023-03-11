//
//  main.m
//  CoreDataXPCHelper
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>
#import "HelperDelegate.h"
#import "XPCServiceName.h"

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    HelperDelegate *delegate = [HelperDelegate new];
    NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:kHelperXPCMachServiceName];
    listener.delegate = delegate;
    [listener activate];
    [NSRunLoop.currentRunLoop run];
    [delegate release];
    [listener release];
    
    [pool release];
    return EXIT_FAILURE;
}
