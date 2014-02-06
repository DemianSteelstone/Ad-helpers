//
//  AdmobCustomEvent.m
//  VideoDownloader
//
//  Created by Evgeny Rusanov on 06.02.14.
//  Copyright (c) 2014 Macsoftex. All rights reserved.
//

#import "AdmobCustomEvent.h"

@implementation AdmobCustomEvent
{
    GADBannerView *banner;
    
    id context;
}

-(void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    GADAdSize gadSize = GADAdSizeFromCGSize(size);
    
    banner = [[GADBannerView alloc] initWithAdSize:gadSize];
    banner.adUnitID = info[@"publisher_id"];
    banner.delegate = self;
    banner.rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    banner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
    [banner loadRequest:request];
    
    context = self;
}

-(void)end
{
    context = nil;
}

#pragma mark - GADDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self.delegate bannerCustomEvent:self didLoadAd:bannerView];
    
    __weak typeof(self) pself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [pself end];
    });
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
    
    __weak typeof(self) pself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [pself end];
    });
}

@end
