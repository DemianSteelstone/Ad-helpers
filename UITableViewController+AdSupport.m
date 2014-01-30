//
//  UITableViewController+AdSupport.m
//  VideoDownloader
//
//  Created by Evgeny Rusanov on 26.10.12.
//  Copyright (c) 2012 Kain. All rights reserved.
//

#import "UITableViewController+AdSupport.h"
#import <QuartzCore/QuartzCore.h>

#import <objc/runtime.h>

#import "MPAdView.h"

const void *TableViewKey = &TableViewKey;
const void *BannerKey = &BannerKey;
const void *BannerLoadedKey = &BannerLoadedKey;

@interface UITableViewController() <MPAdViewDelegate>

@end

@implementation UITableViewController (AdSupport)

-(UITableView*)tableView
{
    if ([self.view isKindOfClass:[UITableView class]])
        return (UITableView*)[self view];
    
    UITableView *table = objc_getAssociatedObject(self, TableViewKey);
    
    return table;
}

-(MPAdView*)bannerView
{
    return objc_getAssociatedObject(self, BannerKey);
}

-(BOOL)bannerLoaded
{
    return [objc_getAssociatedObject(self, BannerLoadedKey) boolValue];
}

-(void)addAdBanner:(NSString*)iphone ipadIdentifier:(NSString*)ipad
{
    NSString *identifier;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad && ipad.length)
        identifier = ipad;
    else
        identifier = iphone;
    
    if ([self.view isKindOfClass:[UITableView class]])
    {
        UITableView *t = self.tableView;
        CGRect tableRect = self.view.bounds;
        tableRect.origin.y = 0;
        UIView *v = [[UIView alloc] initWithFrame:tableRect];
        v.backgroundColor = [UIColor clearColor];
        v.autoresizingMask = self.view.autoresizingMask;
//        v.layer.borderColor = [UIColor blueColor].CGColor;
//        v.layer.borderWidth = 2.f;
        
        t.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        t.layer.borderColor = [UIColor greenColor].CGColor;
//        t.layer.borderWidth = 2.f;
        t.frame = tableRect;
        
        self.view = v;
        [self.view addSubview:t];
        objc_setAssociatedObject(self, TableViewKey, t, OBJC_ASSOCIATION_ASSIGN);
        
        CGRect bannerRect = CGRectZero;
        bannerRect.origin.y = CGRectGetHeight(self.view.bounds);
        
        CGSize size;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            size = CGSizeMake(468, 60);
        else
            size = MOPUB_BANNER_SIZE;
        MPAdView *banner = [[MPAdView alloc] initWithAdUnitId:identifier size:size];
        banner.delegate = self;
        banner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self.view insertSubview:banner atIndex:0];
        objc_setAssociatedObject(self, BannerKey, banner, OBJC_ASSOCIATION_ASSIGN);
        
        [self reload:banner];
        
        [self setFramesForNotLoadedBanner:banner];
    }
}

-(void)reload:(MPAdView*)banner
{
    objc_setAssociatedObject(self, BannerLoadedKey, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN);
    
    [banner loadAd];
}

-(void)removeAdBanner
{
    MPAdView *banner = [self bannerView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setFramesForNotLoadedBanner:banner];
                     } completion:^(BOOL finished) {
                         [banner removeFromSuperview];
                     }];
}

-(void)addUpgradeObserver:(NSString*)notificationName
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upgradeComplete:)
                                                 name:notificationName
                                               object:nil];
}

-(void)upgradeComplete:(NSNotification*)n
{
    [self removeAdBanner];
}

-(void)setFramesForLoadedBanner:(MPAdView*)banner
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setFramesForLoadedBannerWithoutAnimation:banner];
    }];
    
    [banner.superview bringSubviewToFront:banner];
}

-(void)setFramesForLoadedBannerWithoutAnimation:(MPAdView*)banner
{
    CGRect bannerRect = banner.frame;
    CGSize size = [banner adContentViewSize];
    bannerRect.size = size;
    
    if (UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
    {
        UITableView *tableView = [self tableView];
        CGRect tableFrame = tableView.bounds;
        tableFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(bannerRect);
        self.tableView.frame = tableFrame;
    }
    
    bannerRect.origin.x = (self.view.frame.size.width - bannerRect.size.width)*0.5;
    
    bannerRect.origin.y = self.view.frame.size.height - bannerRect.size.height;
    banner.frame = bannerRect;
}

-(void)setFramesForNotLoadedBanner:(MPAdView*)banner
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setFramesForNotLoadedBannerWithoutAnimation:banner];
    }];
}

-(void)setFramesForNotLoadedBannerWithoutAnimation:(MPAdView*)banner
{
    CGRect bannerRect = banner.frame;
    CGSize size = [banner adContentViewSize];
    bannerRect.size = size;
    bannerRect.origin.y = self.view.frame.size.height;
    bannerRect.origin.x = (self.view.frame.size.width - bannerRect.size.width)*0.5;
    banner.frame = bannerRect;
    
    self.tableView.frame = self.view.bounds;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    MPAdView *banner = [self bannerView];
    
    if ([self bannerLoaded])
        [self setFramesForLoadedBanner:banner];
    else
        [self setFramesForNotLoadedBanner:banner];
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return [[UIApplication sharedApplication].delegate window].rootViewController;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    if (![self bannerLoaded])
        [self setFramesForNotLoadedBannerWithoutAnimation:view];
    
    objc_setAssociatedObject(self, BannerLoadedKey, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);
    
    [self setFramesForLoadedBanner:view];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    objc_setAssociatedObject(self, BannerLoadedKey, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN);
    
    [self setFramesForNotLoadedBanner:view];
    
    [self reload:view];
}

@end
