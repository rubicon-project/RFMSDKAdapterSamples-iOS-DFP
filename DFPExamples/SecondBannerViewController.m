//
//  SecondBannerViewController.m
//  DFPBannerExample
//
//  Created by The Rubicon Project on 2/12/15.
//  Copyright (c) Rubicon Project. All rights reserved.
//

#import "SecondBannerViewController.h"
@import GoogleMobileAds;

@interface SecondBannerViewController () <GADAppEventDelegate, GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet DFPBannerView *bannerView;
- (IBAction)getAd:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SecondBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self showIndicator:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getAd:(UIButton *)sender {
  
  
    // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = @"/6499/example/banner";
  self.bannerView.backgroundColor = [UIColor darkGrayColor];
  self.bannerView.rootViewController = self;
  self.bannerView.appEventDelegate = self;
  self.bannerView.delegate = self;
  DFPRequest *request = [[DFPRequest alloc] init];
    // request.testDevices = @[kDFPSimulatorID];
  [self showIndicator:YES];

  [self.bannerView loadRequest:request];
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
