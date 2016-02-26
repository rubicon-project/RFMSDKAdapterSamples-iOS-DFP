//
//  InterstitialViewController.m
//  DFPInterstitialExample
//
//  Created by The Rubicon Project on 2/12/16.
//  Copyright (c) Rubicon Project. All rights reserved.
//

@import GoogleMobileAds;

#import "InterstitialViewController.h"
#import <RFMAdSDK/RFMAdSDK.h>
#import "RFMPopoverViewController.h"

#define RFM_FASTLANE_REQUEST_KEY_KV @"fastlane key value"

@interface InterstitialViewController () <GADAppEventDelegate, GADInterstitialDelegate, RFMFastLaneDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) DFPInterstitial *interstitial;
@property(nonatomic, strong) DFPRequest *dfpRequest;

- (IBAction)getAd:(UIButton *)sender;
- (IBAction)infoButtonClicked:(UIButton *)sender;

@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showIndicator:NO];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getAd:(UIButton *)sender {
    
    // Replace this ad unit ID with your own ad unit ID.
    NSString *adUnitId = self.requestFastLane ? @"/5300653/DND_IOS_FLINTERSTITIAL_PROD" : @"/5300653/DND_IOS_ADPINTERSTITIAL_PROD";
    self.interstitial = [[DFPInterstitial alloc] initWithAdUnitID:adUnitId];
    self.interstitial.delegate = self;
    self.dfpRequest = [[DFPRequest alloc] init];
//    self.dfpRequest.testDevices = @[kDFPSimulatorID];
    [self showIndicator:YES];
    
    if(self.requestFastLane) {
        // fastlane request
        self.fastlaneRequest.rfmAdType = RFM_ADTYPE_INTERSTITIAL;
//        self.fastlaneRequest.fetchOnlyVideoAds = YES;
        RFMFastLane *fastLane = [[RFMFastLane alloc] initWithAdView:self.view delegate:self];
        [fastLane preFetchAdWithParams:self.fastlaneRequest];
    } else {
        self.dfpRequest.customTargeting = nil;
        [self.interstitial loadRequest:self.dfpRequest];
    }
    
    // hide navigation bar so that it doesn't block the close button
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)interstitial:(GADInterstitial *)interstitial
  didReceiveAppEvent:(NSString *)name
            withInfo:(NSString *)info
{
    NSLog(@"Ad Delegate: Event: %@, info: %@",name,info);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad;
{
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }
    [self showIndicator:NO];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%@", [error description]);
    [self showIndicator:NO];
    // show navigation bar again to make settings accessible
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    // show navigation bar again to make settings accessible
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - FastLane

- (void)didReceiveFastLaneAdInfo:(NSDictionary *)adInfo
{
    NSLog(@"Received Fastlane Ad Info: %@", adInfo);
    NSString *settingsJSON = [self valueForUserDefaultsKey:RFM_FASTLANE_REQUEST_KEY_KV];
    NSMutableDictionary *settingsAdInfo = nil;
    if(settingsJSON && settingsJSON.length > 0) {
        settingsAdInfo = [NSJSONSerialization JSONObjectWithData:[settingsJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:nil];
    }
    if(settingsAdInfo && settingsAdInfo.count > 0 && [settingsAdInfo.allKeys.firstObject length] > 0) {
        NSLog(@"using custom targeting to fast lane DFP request from settings instead of from response.");
        self.dfpRequest.customTargeting = settingsAdInfo;
    } else {
        self.dfpRequest.customTargeting = adInfo;
    }
    
    NSLog(@"Final Fastlane Ad Info: %@", self.dfpRequest.customTargeting);
    // pass through fastlane info as custom targeting dictionary
    
    [self.interstitial loadRequest:self.dfpRequest];
}

- (void)didFailToReceiveFastLaneAdWithReason:(NSString *)errorReason
{
    NSLog(@"Failed to receive Fastlane Ad Info: %@", errorReason);
    [self showIndicator:NO];
    
    NSLog(@"Sending regular waterfall request without fastlane info.");
    [self.interstitial loadRequest:self.dfpRequest];
}

#pragma mark - Info Button

- (IBAction)infoButtonClicked:(UIButton *)sender {
    
    NSString *mopubSDKVer = [GADRequest sdkVersion];
    NSString *rfmSDKVer = [RFMAdView rfmSDKVersion];
    
    if (NSClassFromString(@"UIAlertController") != nil) {
        //make and use a UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SDK Info"
                                                                                 message:[NSString stringWithFormat:@"DFP SDK: %@\nRFM SDK: %@",mopubSDKVer,rfmSDKVer]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController
                           animated:YES completion:nil ];
    }
    else {
        //make and use a UIAlertView
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SDK Info"
                                                            message:[NSString stringWithFormat:@"DFP SDK: %@\nRFM SDK: %@",mopubSDKVer,rfmSDKVer]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

#pragma mark - Activity
-(void)showIndicator:(BOOL)show{
    if (show) {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }else{
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}

@end
