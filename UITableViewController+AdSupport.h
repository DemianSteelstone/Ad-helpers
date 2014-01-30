//
//  UITableViewController+AdSupport.h
//  VideoDownloader
//
//  Created by Evgeny Rusanov on 26.10.12.
//  Copyright (c) 2012 Kain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (AdSupport)

-(void)addAdBanner:(NSString*)iphone ipadIdentifier:(NSString*)ipad;
-(void)removeAdBanner;

-(void)addUpgradeObserver:(NSString*)notificationName;

@end
