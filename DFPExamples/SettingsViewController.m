//
//  SettingsViewController.m
//  DFPBannerExample
//
//  Created by The Rubicon Project on  2/15/16.
//  Copyright (c) Rubicon Project. All rights reserved.
//

#import "SettingsViewController.h"
#import "RFMPopoverViewController.h"
#import <RFMAdSDK/RFMAdSDK.h>
#import "BannerViewController.h"
#import "InterstitialViewController.h"


#define POPOVER_MARGIN_LEFT 10.0f

// change these settings if running iOS 7.x
// these settings will always be loaded by default in iOS 7.x
//
// banner defaults
#define FASTLANE_REQUEST_DEFAULT_BANNER_SERVER @"http://mrp.rubiconproject.com/"
#define FASTLANE_REQUEST_DEFAULT_BANNER_APPID @"C6D20770BE6201330F5922000B2E019E"
#define FASTLANE_REQUEST_DEFAULT_BANNER_PUBID @"111315"
#define FASTLANE_REQUEST_DEFAULT_BANNER_ENABLED YES
#define FASTLANE_REQUEST_DEFAULT_BANNER_KV @"{\n \"\" : \"\"\n}"

// change these settings if running iOS 7.x
// these settings will always be loaded by default in iOS 7.x
//
// interstitial defaults
#define FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_SERVER @"http://mrp.rubiconproject.com/"
#define FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_APPID @"55E44D80BE6401330F5A22000B2E019E"
#define FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_PUBID @"111315"
#define FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_ENABLED YES
#define FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_KV @"{\n \"\" : \"\"\n}"
// ********************* //

#define RFM_FASTLANE_REQUEST_KEY_ENABLED @"fastlane enabled"
#define RFM_FASTLANE_REQUEST_KEY_SERVER @"fastlane server"
#define RFM_FASTLANE_REQUEST_KEY_APPID @"fastlane app_id"
#define RFM_FASTLANE_REQUEST_KEY_PUBID @"fastlane pub_id"
#define RFM_FASTLANE_REQUEST_KEY_KV @"fastlane key value"

@interface SettingsViewController () <RFMPopoverViewControllerDelegate, UITextViewDelegate>

@end

@implementation SettingsViewController {
    RFMPopoverViewController *_customPopoverController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isBanner = [self class] == [BannerViewController class];
    BOOL isInterstitial = [self class] == [InterstitialViewController class];
    
    NSString *defaultServer = isBanner && !isInterstitial ? FASTLANE_REQUEST_DEFAULT_BANNER_SERVER : FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_SERVER;
    NSString *defaultAppId = isBanner && !isInterstitial ? FASTLANE_REQUEST_DEFAULT_BANNER_APPID : FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_APPID;
    NSString *defaultPubId = isBanner && !isInterstitial ? FASTLANE_REQUEST_DEFAULT_BANNER_PUBID : FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_PUBID;
    BOOL defaultFastlaneEnabled = isBanner && !isInterstitial ? FASTLANE_REQUEST_DEFAULT_BANNER_ENABLED : FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_ENABLED;
    NSString *defaultKV = isBanner && !isInterstitial ? FASTLANE_REQUEST_DEFAULT_BANNER_KV : FASTLANE_REQUEST_DEFAULT_INTERSTITIAL_KV;
    
    NSString *serverKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_SERVER, NSStringFromClass([self class])];
    NSString *appIdKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_APPID, NSStringFromClass([self class])];
    NSString *pubIdKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_PUBID, NSStringFromClass([self class])];
    NSString *kvKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_KV, NSStringFromClass([self class])];
    
    // version check for popover support
    if([self versionSupportsPopover]) {
        // seed the request values, if nil
        NSString *server = [self valueForUserDefaultsKey:serverKey] ? [self valueForUserDefaultsKey:serverKey] : defaultServer;
        NSString *appId = [self valueForUserDefaultsKey:appIdKey] ? [self valueForUserDefaultsKey:appIdKey] : defaultAppId;
        NSString *pubId = [self valueForUserDefaultsKey:pubIdKey] ? [self valueForUserDefaultsKey:pubIdKey] : defaultPubId;
        NSString *extraAdInfo = [self valueForUserDefaultsKey:kvKey];
        NSString *fastlaneEnabledKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_ENABLED, NSStringFromClass([self class])];
        
        // popover supported so load user defaults
        if(extraAdInfo == nil || extraAdInfo.length == 0) {
            [self saveUserDefaultsKey:kvKey value:defaultKV];
        }
        if([[NSUserDefaults standardUserDefaults] objectForKey:fastlaneEnabledKey]) {
            _requestFastLane = [[NSUserDefaults standardUserDefaults] boolForKey:fastlaneEnabledKey];
        } else {
            _requestFastLane = defaultFastlaneEnabled;
        }
        
        self.fastlaneRequest = [[RFMAdRequest alloc] initRequestWithServer:server
                                                                  andAppId:appId
                                                                  andPubId:pubId];
    } else {
        // popover not supported so fallback to constants
        [self saveUserDefaultsKey:kvKey value:defaultKV];
        _requestFastLane = defaultFastlaneEnabled;
        self.fastlaneRequest = [[RFMAdRequest alloc] initRequestWithServer:defaultServer
                                                                  andAppId:defaultAppId
                                                                  andPubId:defaultPubId];
    }
}

- (RFMPopoverViewController*)customPopoverController
{
    if(!_customPopoverController) {
        _customPopoverController = [[RFMPopoverViewController alloc] init];
        _customPopoverController.delegate = self;
        UIView *settingsBarButton = [self.navigationController.navigationBar.subviews objectAtIndex:2];
        _customPopoverController.sourceView = settingsBarButton;
        _customPopoverController.sourceRect = CGRectMake(CGRectGetMidX(settingsBarButton.bounds), CGRectGetMaxY(settingsBarButton.bounds), 0, 0);
        _customPopoverController.preferredContentSize = CGSizeMake(300, 200);
        _customPopoverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        _customPopoverController.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];;
    }
    return _customPopoverController;
}

#pragma mark - check for popover support

- (BOOL)versionSupportsPopover
{
    return [UIPopoverPresentationController class];
}

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSString *kvKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_KV, NSStringFromClass([self class])];
    [self saveUserDefaultsKey:kvKey value:textView.text];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

#pragma mark - Settings Popover

- (IBAction)tappedSettings:(id)sender
{
    // version check for popover support
    if(![self versionSupportsPopover])
        return;
        
    [self presentViewController:self.customPopoverController animated:YES completion:^{
        [_customPopoverController insertContentIntoPopover:^(RFMPopoverViewController *popover, UIScrollView *contentView, CGSize contentSize, CGPoint contentOrigin) {
            _settingsContentView = contentView;
//            CGFloat originX = contentOrigin.x;
            CGFloat originY = contentOrigin.y;
            CGFloat width = contentSize.width;
//            CGFloat height = contentSize.height;
            
            // fastlane switch
            CGRect fastLaneSwitchFrame = CGRectMake(width - width/3, originY, 51.0f, 31.0f);
            UISwitch *fastLaneSwitch = [[UISwitch alloc] initWithFrame:fastLaneSwitchFrame];
            fastLaneSwitch.on = _requestFastLane;
            [contentView addSubview:fastLaneSwitch];
            CGRect fastLaneLabelFrame = CGRectMake(POPOVER_MARGIN_LEFT, originY, (width/3) * 2, 31.0f);
            UILabel *fastlaneLabel = [[UILabel alloc] initWithFrame:fastLaneLabelFrame];
            fastlaneLabel.text = @"FastLane";
            [fastLaneSwitch addTarget:self
                               action:@selector(toggleFastLane:)
                     forControlEvents:UIControlEventValueChanged];
            [contentView addSubview:fastlaneLabel];
            
            
            // host
            NSString *serverKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_SERVER, NSStringFromClass([self class])];
            UITextField *serverTextfield = [self createTextFieldForRequestWithPlaceholder:serverKey];
            serverTextfield.frame = CGRectMake(POPOVER_MARGIN_LEFT, 20.0f, contentSize.width - (POPOVER_MARGIN_LEFT * 2), 31.0f);
            serverTextfield.text = self.fastlaneRequest.rfmAdServer;
            [contentView addSubview:serverTextfield];
            
            // app id
            NSString *appIdKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_APPID, NSStringFromClass([self class])];
            UITextField *appIdTextfield = [self createTextFieldForRequestWithPlaceholder:appIdKey];
            appIdTextfield.frame = CGRectMake(POPOVER_MARGIN_LEFT, 20.0f * 2, contentSize.width - (POPOVER_MARGIN_LEFT * 2), 31.0f);
            appIdTextfield.text = self.fastlaneRequest.rfmAdAppId;
            [contentView addSubview:appIdTextfield];
            
            // pub id
            NSString *pubIdKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_PUBID, NSStringFromClass([self class])];
            UITextField *pubIdTextfield = [self createTextFieldForRequestWithPlaceholder:pubIdKey];
            pubIdTextfield.frame = CGRectMake(POPOVER_MARGIN_LEFT, 20.0f * 3, contentSize.width - (POPOVER_MARGIN_LEFT * 2), 31.0f);
            pubIdTextfield.text = self.fastlaneRequest.rfmAdPublisherId;
            [contentView addSubview:pubIdTextfield];
            
            NSString *kvKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_KV, NSStringFromClass([self class])];
            UITextView *kvTextView = [[UITextView alloc] initWithFrame:CGRectMake(POPOVER_MARGIN_LEFT, 21.0f * 4, contentSize.width - (POPOVER_MARGIN_LEFT * 2), 60.0f)];
            kvTextView.delegate = self;
            kvTextView.layer.borderWidth = 1.0f;
            kvTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            kvTextView.text = [self valueForUserDefaultsKey:kvKey];
            kvTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            kvTextView.autocorrectionType = UITextAutocorrectionTypeNo;
            [contentView addSubview:kvTextView];
        }];
    }];
}

- (UITextField*)createTextFieldForRequestWithPlaceholder:(NSString*)placeholder
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.placeholder = placeholder;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.font = [UIFont systemFontOfSize:12];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    return textField;
}

- (void)dismissPopover
{
    NSString *serverKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_SERVER, NSStringFromClass([self class])];
    NSString *appIdKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_APPID, NSStringFromClass([self class])];
    NSString *pubIdKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_PUBID, NSStringFromClass([self class])];
    
    [self dismissViewControllerAnimated:NO completion:^{
        for (UIView *view in [self.settingsContentView subviews]) {
            if ([view isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)view;
                if([textField.placeholder isEqualToString:serverKey]) {
                    [self saveUserDefaultsKey:serverKey value:textField.text];
                    self.fastlaneRequest.rfmAdServer = textField.text;
                } else if([textField.placeholder isEqualToString:appIdKey]) {
                    [self saveUserDefaultsKey:appIdKey value:textField.text];
                    self.fastlaneRequest.rfmAdAppId = textField.text;
                } else if([textField.placeholder isEqualToString:pubIdKey]) {
                    [self saveUserDefaultsKey:pubIdKey value:textField.text];
                    self.fastlaneRequest.rfmAdPublisherId = textField.text;
                }
            } else if ([view isKindOfClass:[UITextView class]]) {
                NSString *kvKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_KV, NSStringFromClass([self class])];
                [self saveUserDefaultsKey:kvKey value:[(UITextView*)view text]];
            }
        }
        _customPopoverController = nil;
    }];
}

- (IBAction)toggleFastLane:(id)sender
{
    _requestFastLane = [sender isOn];
    NSString *fastlaneEnabledKey = [NSString stringWithFormat:@"%@ %@", RFM_FASTLANE_REQUEST_KEY_ENABLED, NSStringFromClass([self class])];
    [[NSUserDefaults standardUserDefaults] setBool:_requestFastLane forKey:fastlaneEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"toggle fastlane: %d", _requestFastLane);
}

#pragma mark - NSUserDefaults persistence of last settings

- (NSString*)valueForUserDefaultsKey:(NSString*)key
{
    NSString* value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    return value;
}

- (void)saveUserDefaultsKey:(NSString*)key
                      value:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
