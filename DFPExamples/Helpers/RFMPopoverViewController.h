//
//  RFMPopover.h
//  RFMPopover
//
//  Created by The Rubicon Project on 2/9/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RFMPopoverViewControllerDelegate <NSObject>

- (void)dismissPopover;

@end

@interface RFMPopoverViewController : UIViewController

@property (nonatomic, weak) id <RFMPopoverViewControllerDelegate> delegate;
@property (nonatomic, assign) UIPopoverArrowDirection permittedArrowDirections;
@property (nonatomic, weak) UIView *sourceView;
@property (nonatomic, assign) CGRect sourceRect;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSArray *passthroughViews;
@property (nonatomic, assign) UIEdgeInsets popoverLayoutMargins;

- (void)insertContentIntoPopover:(void (^)(RFMPopoverViewController *popover, UIScrollView *contentView, CGSize contentSize, CGPoint contentOrigin))content;

@end
