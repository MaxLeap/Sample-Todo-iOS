//
//  MLAnalytics.h
//  MaxLeap
//
//  Created by Sun Jin on 7/10/14.
//  Copyright (c) 2014 iLegendsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 MLAnalytics provides methods to logging user behavior to analytics backend.<br>
 <br>
 Events for Session starting and session ending are logged automatically when app enter foreground or background.
 */
@interface MLAnalytics : NSObject

#pragma mark -

/**
 *  Set the timeout for expiring a MaxLeap session.
 *
 *  This is an optional method that sets the time the app may be in the background before
 *  starting a new session upon resume.  The default value for the session timeout is 0
 *  seconds in the background.
 *
 *  @param seconds The time in seconds to set the session timeout to.
 */
+ (void)setSessionContinueSeconds:(int)seconds;

#pragma mark -
/** @name Custom Event Analytics */

/*!
 Tracks the occurrence of a custom event and reports to MaxLeap backend.
 
 @param name The name of the custom event.
 */
+ (void)trackEvent:(NSString *)name;

/**
 *  Tracks the occurrence of a custom event and reports to MaxLeap backend.
 *
 *  @param name  The name of the custom event.
 *  @param count The number of this event occurred.
 */
+ (void)trackEvent:(NSString *)name count:(int)count;

/**
 *  Tracks the occurrence of a custom event with additional parameters.<br>
 *
 *  Event parameters can be used to provide additional information about the event. The parameters is a dictionary containing Key-Value pairs of parameters. Keys and values should be NSStrings.<br>
 *
 *  The following is a sample to track a purchase with additional parameters:<br>
 *
 *  @code
 *  NSDictionary *parameters = @{@"productName": @"iPhone 6s",
 *                               @"productCategory": @"electronics"};
 *  [MLAnalytics trackEvent:@"productPurchased" parameters:parameters];
 *  @endcode
 *
 *  @param name       The name of the custom event.
 *  @param parameters The dictionary of additional information for this event.
 */
+ (void)trackEvent:(NSString *)name parameters:(NSDictionary<NSString*, NSString*> *)parameters;

/**
 *  Tracks the occurrence of a custom event with additional parameters.<br>
 *
 *  Event parameters can be used to provide additional information about the event. The parameters is a dictionary containing Key-Value pairs of parameters. Keys and values should be NSStrings.<br>
 *
 *  The following is a sample to track a purchase with additional parameters:<br>
 *
 *  @code
 *  NSDictionary *parameters = @{@"productName": @"iPhone 6s",
 *                               @"productCategory": @"electronics"};
 *  [MLAnalytics trackEvent:@"productPurchased" parameters:parameters];
 *  @endcode
 *
 *  @param name       The name of the custom event.
 *  @param parameters The dictionary of additional information for this event.
 *  @param count      The number of this event occurred.
 */
+ (void)trackEvent:(NSString *)name parameters:(NSDictionary<NSString*, NSString*> *)parameters count:(int)count;

#pragma mark -
/** @name Page View Analytics */

/**
 *  Tracks the duration of view displayed.
 *
 *  Tracks the beginning of view display.
 *
 *  @param pageName The name of the page.
 */
+ (void)beginLogPageView:(NSString *)pageName;

/**
 *  Tracks the duration of view displayed.
 *
 *  Tracks the ending of view display.
 *
 *  @param pageName The name of the page.
 */
+ (void)endLogPageView:(NSString *)pageName;

@end
