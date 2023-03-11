//
//  main.m
//  PublisherXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>
#import "ServiceDelegate.h"

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    ServiceDelegate *delegate = [ServiceDelegate new];
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    [listener activate];
    [delegate release];
    
    [pool release];
    return EXIT_FAILURE;
}
