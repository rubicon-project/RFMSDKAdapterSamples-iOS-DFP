//
//  RFMAdmobInterstitialAdapter.m
//  v3.1.4
//  Integrated with RFM iOS SDK v 4.1.0
//  Integrated with Admob iOS SDK :7.6.0
//
//  Source file for integrating RFM SDK with DFP/Admob SDK
//  RFM SDK will be triggered via DFP/Admob Custom Events
//
//  Created by The Rubicon Project on 2/12/16.
//  Copyright (c) Rubicon Project. All rights reserved.
//

#import "RFMAdmobInterstitialAdapter.h"

////RFM Placement Settings
#define RFM_SERVER_NAME @"http://mrp.rubiconproject.com/" //Replace this value with your RFM placement server name
#define RFM_PLACEMENT_PUB_ID  @"111008" //Replace this value with your RFM placement pub id


#define RFM_ADAPTER_VER_KEY @"adp_version"
#define RFM_DFP_ADAPTER_VER @"dfp_adp_3.1.4"

@interface RFMAdmobInterstitialAdapter()

@property (nonatomic, strong) RFMAdView *rfmAdView;

@end

@implementation RFMAdmobInterstitialAdapter {
    UIViewController *_rootViewController;
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request
{
    //    // Use the parameters and self.delegate to make a interstitial request to your
    //    // ad network. Remember to set this class to be your interstitial’s delegate.
    //    NSLog(@"RFM Adapter custom event :appId: %@, width %f, ht %f",serverParameter,adSize.size.width,adSize.size.height);
    
    if(_rfmAdView == nil)
    {
        _rfmAdView = [RFMAdView createInterstitialAdWithDelegate:self];
    }
    
    //Request parameter configuration
    RFMAdRequest *adRequest = [[RFMAdRequest alloc]
                               initRequestWithServer:RFM_SERVER_NAME
                               andAppId:serverParameter
                               andPubId:RFM_PLACEMENT_PUB_ID];
    
    adRequest.rfmAdType = RFM_ADTYPE_INTERSTITIAL;
//    adRequest.fetchOnlyVideoAds = YES;
//    adRequest.rfmAdTestAdId = @"29343";
//    adRequest.rfmAdMode = @"test";
    /*----BEGIN OPTIONAL RFM TARGETING INFO -------*/
    //Uncomment all the targeting information that needs to be passed on to RFM
    
    // Optional targeting info for ad request
    // Add your own K-Vs to this dictionary for RFM targeting.
    adRequest.targetingInfo = @{RFM_ADAPTER_VER_KEY:RFM_DFP_ADAPTER_VER};
    //
    //  // The following location paramters, if set, provide extra information
    //  // for the ad request.
    //  adRequest.locationLatitude = 0;
    //  adRequest.locationLongitude = 0;
    //
    //  //Optional: Set string @"ip" for allowing ip based location detection.
    //
    //  adRequest.allowLocationDetectType = @"none";//Check RFM SDK for valid settings
    //
    //  //These optional parameters allow set additional adview configuration parameters
    //
    //  //When the ad is in landing view mode, set the transparency with which
    //  //your background application is visible along the edges and corners of the landing
    //  //view. The default value for this setting is 0.6.
    //  adRequest.landingViewAlpha = 0.6;
    //
    //
    //  //These optional parameters should be implemented only during testing phase
    //
    //  //This optional parameter specifies the mode in which requests are
    //  //handled. The current supported values are as follows –
    //  //“test” – Test Mode, impressions are not counted
    //
    //   adRequest.rfmAdMode = @"test";
    //
    //  //This optional parameter only renders a specific ad.
    //  //This setting should only be implemented for test accounts
    //  //while testing the performance of a particular ad.
    //  //Return @"0" if you want this setting to be ignored by the SDK
    //  adRequest.rfmAdTestAdId = @"0";
    
    /*----END OPTIONAL RFM TARGETING INFO -------*/
    
    
    
    
    if(![_rfmAdView requestFreshAdWithRequestParams:adRequest]){
        [self reportAdFailureToAdmob:@"RFM Request Denied"];
    }
}

-( void)dealloc{
    _rfmAdView.delegate = nil;
    
}


-(void)reportAdFailureToAdmob:(NSString *)failReason{
    if (self.delegate) {
        
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(failReason, nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(failReason, nil),
                                   };
        NSError *error = [NSError errorWithDomain:@"com.rfm.dfp.adapter"
                                             code:-101
                                         userInfo:userInfo];
        
        [self.delegate customEventInterstitial:self didFailAd:error];
    }
}

#pragma mark - RFM SDK Callbacks

//The View controller which originated ad request.
//For best results, please return the view controller whose content view covers full
//screen(apart from tabbar,nav bar and status bar. If the view controller which
//requested for ads does not have full screen access then return the parent view controller
//which has full screen access.
- (UIViewController *)viewControllerForRFMModalView {
    return _rootViewController;
}

- (UIView *)rfmAdSuperView {
    return _rootViewController.view;
}

#pragma mark -
#pragma mark RFM SDK Optional Notification Methods
// Sent when an ad request has been made to the Server. Useful for checking the
// request URL.
-(void)didRequestAd:(RFMAdView *)adView withUrl:(NSString *)requestUrlString{
    
}

// Admob SDK will call this method when the publisher intends to present an interstitial ad
- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    _rootViewController = rootViewController;
    if(_rfmAdView.shouldPrecache) {
        // or should this if-block be in didReceiveAd callback?
        if(_rfmAdView.canDisplayCachedAd) {
            [self.delegate customEventInterstitialWillPresent:self];
            [_rfmAdView showCachedAd];
            [rootViewController.view addSubview:_rfmAdView];
        } else {
            [self reportAdFailureToAdmob:@"could not present root view controller"];
        }
    } else {
        [self.delegate customEventInterstitialWillPresent:self];
        [rootViewController.view addSubview:_rfmAdView];
    }
}


// Sent just before dismissing an interstitial ad
- (void)willDismissInterstitialFromAd:(RFMAdView *)adView
{
    [self.delegate customEventInterstitialWillDismiss:self];
}

// Sent just after dismissing an interstitial ad
- (void)didDismissInterstitial
{
    [self.delegate customEventInterstitialDidDismiss:self];
}

// Sent when an ad request failed to load an ad.This is a good opportunity to
// remove the adview from superview if it has been added
// Note that if backfill is enabled, failure will be returned only if there are
// no Mobsmith Ads and AdMob also failed to render a valid ad.
// If Mobsmith failed to get an ad from mobsmith server, but found a backfill ad
// on AdMob, the delegate will receive didReceiveAd: notification.
- (void)didFailToReceiveAd:(RFMAdView *)adView reason:(NSString *)errorReason{
    
    [self reportAdFailureToAdmob:errorReason];
}

// Sent when an ad request loaded an ad; this is a good opportunity to add
// this view to the hierachy, if it has not yet been added.
- (void)didReceiveAd:(RFMAdView *)adView
{
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

// Sent if the application will enter background (user touched home button, or clicked
// a button which triggered another application and sent the current application in
// background) while the ad interstitial was still loading.
// Prior to calling this function, RFMAdView will stop loading the interstitial
//
// Recommendation for publishers: We recommend that you handle this delegate callback
// and remove the RFMAdView instance from superview when you receive this callback.
- (void)adViewDidStopLoadingAndEnteredBackground:(RFMAdView *)adView{
    [adView removeFromSuperview];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

#pragma mark - Adapter Helpers

+(BOOL) isRfmSystemVersionGreaterThanOrEqualTo:(NSString *)versionString {
    return ([[[UIDevice currentDevice] systemVersion] compare:versionString options:NSNumericSearch] != NSOrderedAscending);
}




@end
