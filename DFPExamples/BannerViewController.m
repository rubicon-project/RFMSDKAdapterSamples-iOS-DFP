//
//  ViewController.m
//  DFPBannerExample
//
//  Created by The Rubicon Project on 2/12/15.
//  Copyright (c) Rubicon Project. All rights reserved.

@import GoogleMobileAds;

#import "BannerViewController.h"
#import <RFMAdSDK/RFMAdSDK.h>

#define RFM_FASTLANE_REQUEST_KEY_KV @"fastlane key value"

@interface BannerViewController ()<GADAppEventDelegate, GADBannerViewDelegate, RFMFastLaneDelegate, UITextViewDelegate>

  /// The DFP banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *bannerView;
@property(nonatomic, strong) DFPRequest *dfpRequest;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)getAd:(UIButton *)sender;
- (IBAction)infoButtonClicked:(UIButton *)sender;

@end

@implementation BannerViewController

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
    NSString *adUnitId = self.requestFastLane ? @"/5300653/DND_IOS_FLBANNER_PROD" : @"/5300653/DND_IOS_ADPBANNER_PROD";
    self.bannerView.adUnitID = adUnitId;
    self.bannerView.backgroundColor = [UIColor darkGrayColor];
    self.bannerView.rootViewController = self;
    self.bannerView.appEventDelegate = self;
    self.bannerView.delegate = self;
    self.dfpRequest = [[DFPRequest alloc] init];
    //     self.dfpRequest.testDevices = @[kDFPSimulatorID];
    [self showIndicator:YES];

    if(self.requestFastLane) {
        // fastlane request
        //        self.fastlaneRequest.fetchOnlyVideoAds = YES;
        RFMFastLane *fastLane = [[RFMFastLane alloc] initWithAdView:self.bannerView delegate:self];
        [fastLane preFetchAdWithParams:self.fastlaneRequest];
    } else {
        self.dfpRequest.customTargeting = nil;
        [self.bannerView loadRequest:self.dfpRequest];
    }
}

- (void)adView:(GADBannerView *)banner
didReceiveAppEvent:(NSString *)name
      withInfo:(NSString *)info
{
  NSLog(@"Ad Delegate: Event: %@, info: %@",name,info);
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
  NSLog(@"Banner Delegate: Failed: %@",error.description);
  [self showIndicator:NO];

}

-(void)adViewDidReceiveAd:(GADBannerView *)view{
  NSLog(@"Banner Delegate: Succeeded");
  [self showIndicator:NO];

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

    [self.bannerView loadRequest:self.dfpRequest];
}

- (void)didFailToReceiveFastLaneAdWithReason:(NSString *)errorReason
{
    NSLog(@"Failed to receive Fastlane Ad Info: %@", errorReason);
    [self showIndicator:NO];

    NSLog(@"Sending regular waterfall request without fastlane info.");
    [self.bannerView loadRequest:self.dfpRequest];
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
