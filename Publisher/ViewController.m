//
//  ViewController.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "ViewController.h"
#import "ViewModel.h"

@interface ViewController ()
@property (retain) NSVisualEffectView *blurView;
@property (retain) NSView *containerView;
@property (retain) NSTextField *textField;
@property (retain) NSButton *publishButton;
@property (retain) ViewModel *viewModel;
@end

@implementation ViewController

- (void)dealloc {
    [_blurView release];
    [_containerView release];
    [_textField release];
    [_publishButton release];
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
    [self setupContainerView];
    [self setupTextField];
    [self setupPublishButton];
    [self setupViewModel];
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

- (void)setupContainerView {
    NSView *containerView = [NSView new];
    
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:containerView];
    
    NSLayoutConstraint *topConstraint = [containerView.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.topAnchor constant:30.f];
    topConstraint.priority = NSLayoutPriorityDefaultHigh;
    
    NSLayoutConstraint *bottomConstraint = [containerView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor constant:-30.f];
    bottomConstraint.priority = NSLayoutPriorityDefaultHigh;
    
    [NSLayoutConstraint activateConstraints:@[
        topConstraint,
        [containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30.f],
        [containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30.f],
        bottomConstraint,
        [containerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    self.containerView = containerView;
    [containerView release];
}

- (void)setupTextField {
    NSTextField *textField = [NSTextField new];
    
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:textField];
    
    [NSLayoutConstraint activateConstraints:@[
        [textField.topAnchor constraintEqualToAnchor:self.containerView.topAnchor],
        [textField.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor],
        [textField.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor]
    ]];
    
    self.textField = textField;
    [textField release];
}

- (void)setupPublishButton {
    NSButton *publishButton = [NSButton new];
    
    publishButton.title = @"Publish!";
    publishButton.bezelStyle = NSBezelStyleRounded;
    publishButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:publishButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [publishButton.topAnchor constraintEqualToAnchor:self.containerView.topAnchor],
        [publishButton.leadingAnchor constraintEqualToAnchor:self.textField.trailingAnchor constant:30.f],
        [publishButton.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor],
        [publishButton.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor]
    ]];
    
    self.publishButton = publishButton;
    [publishButton release];
}

- (void)setupViewModel {
    ViewModel *viewModel = [ViewModel new];
    self.viewModel = viewModel;
}

@end
