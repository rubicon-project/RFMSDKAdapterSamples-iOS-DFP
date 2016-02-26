//
//  SettingsViewController.h
//  DFPBannerExample
//
//  Created by The Rubicon Project on  2/15/16.
//  Copyright (c) Rubicon Project. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFMPopoverViewController, RFMAdRequest;

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) RFMAdRequest *fastlaneRequest;
@property (nonatomic, strong) UIScrollView *settingsContentView;
@property (nonatomic, strong, readonly) RFMPopoverViewController *customPopoverController;
@property (nonatomic, assign) BOOL requestFastLane;

- (NSString*)valueForUserDefaultsKey:(NSString*)key;
- (void)saveUserDefaultsKey:(NSString*)key
                      value:(NSString*)value;

- (IBAction)tappedSettings:(id)sender;
- (IBAction)toggleFastLane:(id)sender;

@end
