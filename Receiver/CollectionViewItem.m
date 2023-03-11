//
//  CollectionViewItem.m
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "CollectionViewItem.h"
#import "NSTextField+ApplyLabelStyle.h"

@interface CollectionViewItem ()

@end

@implementation CollectionViewItem

- (void)loadView {
    NSView *view = [NSView new];
    self.view = view;
    [view release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextField];
}

- (void)configureWithDataManagedObject:(DataManagedObject *)dataManagedObject {
    self.textField.stringValue = dataManagedObject.text ? dataManagedObject.text : @"";
}

- (void)setupTextField {
    NSTextField *textField = [NSTextField new];
    [textField applyLabelStyle];
    textField.font = [NSFont systemFontOfSize:20.f];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:textField];
    [NSLayoutConstraint activateConstraints:@[
        [textField.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [textField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [textField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [textField.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.textField = textField;
    [textField release];
}

@end
