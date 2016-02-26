//
//  RFMPopover.m
//  RFMPopover
//
//  Created by The Rubicon Project on 2/9/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import "RFMPopoverViewController.h"

@interface RFMPopoverViewController () <UIPopoverPresentationControllerDelegate>

@end

@implementation RFMPopoverViewController {
    UIScrollView *_scrollView;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.popoverPresentationController.delegate = self;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Add content

- (void)insertContentIntoPopover:(void (^)(RFMPopoverViewController *popover, UIScrollView *contentView, CGSize contentSize, CGPoint contentOrigin))content {
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat width = CGRectGetWidth(self.popoverPresentationController.frameOfPresentedViewInContainerView);
    CGFloat height = CGRectGetHeight(self.popoverPresentationController.frameOfPresentedViewInContainerView) - 44.0f;
    CGSize popoverSize = CGSizeMake(width, height);
    CGPoint popoverOrigin = CGPointMake(0, 44.0f);

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(originX, originY, width, 44.0f)];
    NSArray* toolbarItems = @[
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                            target:self
                                                                            action:@selector(dismiss)]
                              ];
    [toolbar setItems:toolbarItems];
    [self.view addSubview:toolbar];
    
    CGRect popoverFrame = CGRectMake(popoverOrigin.x, popoverOrigin.y, popoverSize.width, popoverSize.height);
    _scrollView.frame = popoverFrame;
    [self.view addSubview:_scrollView];
    
    if(_backgroundColor) {
        _scrollView.backgroundColor = _backgroundColor;
    }
    
    content(self, _scrollView, popoverSize, CGPointMake(0,0));
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in _scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    _scrollView.contentSize = contentRect.size;
}

#pragma mark - UI Interactions

- (void)dismiss {
    [self.delegate dismissPopover];
    [_scrollView removeFromSuperview];
    _scrollView = nil;
}

#pragma mark - Popover Presentation Controller Delegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    self.popoverPresentationController.sourceView = self.sourceView;
    self.popoverPresentationController.sourceRect = self.sourceRect;
    self.contentSize = self.popoverPresentationController.preferredContentSize;
    
    popoverPresentationController.permittedArrowDirections = self.permittedArrowDirections;
    popoverPresentationController.passthroughViews = self.passthroughViews;
    popoverPresentationController.backgroundColor = self.backgroundColor ? self.backgroundColor : [UIColor whiteColor];
    popoverPresentationController.popoverLayoutMargins = UIEdgeInsetsEqualToEdgeInsets(self.popoverLayoutMargins, UIEdgeInsetsZero) == YES ? UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f) : self.popoverLayoutMargins ;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return NO;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [self dismiss];
}

#pragma mark - Adaptive Presentation Controller Delegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
                                                               traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}


@end
