//
//  RFMAdmobInterstitialAdapter.h
//  v3.1.4
//  Integrated with RFM iOS SDK v 4.1.0
//  Integrated with Admob iOS SDK :7.6.0
//
//  Header file for integrating RFM SDK with DFP/Admob SDK
//  RFM SDK will be triggered via DFP/Admob Custom Events
//
//  Created by The Rubicon Project on 2/12/16.
//  Copyright (c) Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GADCustomEventBanner.h>
#import <RFMAdSDK/RFMAdSDK.h>

@interface RFMAdmobInterstitialAdapter : NSObject  <GADCustomEventInterstitial, RFMAdDelegate>

@property (nonatomic, weak) id<GADCustomEventInterstitialDelegate> delegate;

@end
