//
//  WapStartCustomEvent.m
//  VideoDownloader
//
//  Created by Evgeny Rusanov on 29.01.14.
//  Copyright (c) 2014 Macsoftex. All rights reserved.
//

#import "WapStartCustomEvent.h"

@implementation WapStartCustomEvent
{
    WPBannerView *banner;
    
    id context;
}


-(void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{    
    WPBannerRequestInfo *requestInfo = [[WPBannerRequestInfo alloc] initWithApplicationId:[info[@"app_id"] integerValue]];
    
    banner = [[WPBannerView alloc] initWithBannerRequestInfo:requestInfo];
    banner.showCloseButton = NO;
    banner.delegate = self;
    banner.autoupdateTimeout = 0;
    
    CGRect frame = CGRectZero;
    frame.size = size;
    banner.frame = frame;
    
    [banner reloadBanner];
    
    context = self;
}

-(void)end
{
    context = nil;
}

- (void) bannerViewInfoLoaded:(WPBannerView *) bannerView
{
    banner.hidden = NO;
    [self.delegate bannerCustomEvent:self didLoadAd:bannerView];
    
    __weak typeof(self) pself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [pself end];
    });
}

- (void) bannerViewInfoDidFailWithError:(WPBannerInfoLoaderErrorCode) errorCode
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
    
    __weak typeof(self) pself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [pself end];
    });
}

@end
