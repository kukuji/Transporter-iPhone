//
// DataHelper.m
// kronos
//
// Created by Ljuba Miljkovic on 4/1/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "kronosAppDelegate.h"

@implementation DataHelper

+ (Stop *) bartStopWithName:(NSString *)bartStopTitle {

	// NSDate *startTime = [NSDate dateWithTimeIntervalSinceNow:0];

	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"title = %@ AND agency.shortTitle = %@", bartStopTitle, @"bart"]];

	NSError *error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];

	// NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:0];
	// NSTimeInterval duration =  [endTime timeIntervalSinceDate:startTime];


	if (1 == [results count]) {
		return([results objectAtIndex:0]);
	}

	return(nil);

}

+ (Agency *) agencyWithShortTitle:(NSString *)agencyShortTitle {

	// get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Agency" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortTitle=%@", agencyShortTitle];
	[request setPredicate:predicate];

	// Receive the results
	NSError *error;
	NSMutableArray *agencies = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	if (agencies == nil) {
		return(nil);
	}

	Agency *fetchedAgency = [agencies objectAtIndex:0];

	return(fetchedAgency);
}

+ (Route *) routeWithTag:(NSString *)routeTag inAgency:(Agency *)agency {

	NSPredicate *routeFilter = [NSPredicate predicateWithFormat:@"tag == %@", routeTag];

	NSArray *routes = [[agency.routes allObjects] filteredArrayUsingPredicate:routeFilter];

	if ([routes count] == 0) return(nil);
	Route *route = [routes objectAtIndex:0];
	return(route);

}

+ (Route *) routeWithTag:(NSString *)routeTag inAgencyWithShortTitle:(NSString *)agencyShortTitle {

	// get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	[request setPredicate:[NSPredicate predicateWithFormat:@"tag = %@ AND agency.shortTitle = %@", routeTag, agencyShortTitle]];

	// Receive the results
	NSError *error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];

	if (1 == [results count]) {
		return([results objectAtIndex:0]);
	}

	return(nil);

}

+ (Stop *) stopWithTag:(NSString *)stopTag inDirection:(Direction *)direction {
	for (Stop *stop in direction.stops)
		if ([stop.tag isEqualToString:stopTag])
			return(stop);
	return(nil);

}

+ (Agency *) agencyFromStop:(Stop *)stop {

	Route *route = [[stop.directions anyObject] route];
	Agency *agency = route.agency;

	return(agency);

}

+ (Direction *) directionWithTag:(NSString *)dirTag inRoute:(Route *)route {
	for (Direction *direction in route.directions)
		if ([direction.tag isEqualToString:dirTag]) return(direction);
	return(nil);
}

+ (NSArray *) bartDirectionsWithTitle:(NSString *)title {
	// get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the directions from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Direction" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title==%@", title];
	[request setPredicate:predicate];

	// Receive the results
	NSError *error;
	NSMutableArray *directions = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	if (directions == nil) {
		return(nil);
	}
	return(directions);
}

+ (NSArray *) directionTagsInRoute:(Route *)route thatMatchDirectionName:(NSString *)dirName directionTitle:(NSString *)dirTitle {

	NSMutableArray *matchedDirectionTags = [NSMutableArray array];

	for (Direction *direction in route.directions)
		if ([direction.name isEqualToString:dirName] && [direction.title isEqualToString:dirTitle]) [matchedDirectionTags addObject:direction.tag];
	return( (NSArray *)matchedDirectionTags );

}

+ (NSArray *) directionTagsThatMatchDirectionName:(NSString *)dirName directionTitle:(NSString *)dirTitle routeTag:(NSString *)routeTag forAgencyWithShortTitle:(NSString *)agencyShortTitle {
	// get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Direction" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@ AND title=%@ AND route.tag=%@ AND route.agency.shortTitle=%@", dirName, dirTitle, routeTag, agencyShortTitle];
	[request setPredicate:predicate];

	// Receive the results
	NSError *error;
	NSMutableArray *directions = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	if (directions == nil) {
		return(nil);
	}

	NSMutableArray *matchedDirectionTags = [NSMutableArray array];

	for (Direction *direction in directions) [matchedDirectionTags addObject:direction.tag];
	return( (NSArray *)matchedDirectionTags );
}

+ (Destination *) destinationForBARTStopTag:(NSString *)stopTag toStopTag:(NSString *)destinationStopTag {

	Stop *stop = [DataHelper stopWithTag:stopTag inAgencyWithShortTitle:@"bart"];

	Stop *destinationStop = [DataHelper stopWithTag:destinationStopTag inAgencyWithShortTitle:@"bart"];

	return([[Destination alloc] initWithDestinationStop:destinationStop forStop:stop]);

}

+ (Stop *) stopWithTag:(NSString *)stopTag inAgencyWithShortTitle:(NSString *)agencyShortTitle {

	// get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag=%@ AND agency.shortTitle=%@", stopTag, agencyShortTitle];
	[request setPredicate:predicate];

	// Receive the results
	NSError *error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];

	if (1 == [results count]) {
		return([results objectAtIndex:0]);
	}

	return(nil);
}

+ (NSArray *) stopsWithTags:(NSArray *)stopTags inAgency:(Agency *)agency {
    // get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"agency=%@ AND tag in %@", agency, stopTags];
	[request setPredicate:predicate];
    
	// Receive the results
	NSError *error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    return results;
}

// return the stop objects given its tag and agency
+ (Stop *) stopWithTag:(NSString *)stopTag inAgency:(Agency *)agency {

	// get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag=%@ AND agency=%@", stopTag, agency];
	[request setPredicate:predicate];

	// Receive the results
	NSError *error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];

	if (1 == [results count]) {
		return([results objectAtIndex:0]);
	}

	return(nil);
}

+ (void) saveStopObjectIDInUserDefaults:(Stop *)stop {

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSURL *stopURI = [[stop objectID] URIRepresentation];
	NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:stopURI];
	[userDefaults setObject:uriData forKey:@"stopURIData"];

	[userDefaults synchronize];


}

+ (void) saveDirectionIDInUserDefaults:(Direction *)direction forKey:(NSString *)key {

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSURL *directionURI = [[direction objectID] URIRepresentation];
	NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:directionURI];
	[userDefaults setObject:uriData forKey:key];


}

+ (CLLocation *) locationOfStop:(Stop *)stop {

	return([[CLLocation alloc] initWithLatitude:[stop.lat doubleValue] longitude:[stop.lon doubleValue]]);
}

// returns an array with the closest stop
+ (NSMutableArray *) findClosestStopsFromLocation:(CLLocation *)location amongStops:(NSArray *)stops count:(int)number {

	NSMutableDictionary *stopsByDistance = [[NSMutableDictionary alloc] init];

	// create a dictionary of stops where the key is the distance from the location
	for (Stop *stop in stops) {

		NSNumber *stopDistance = @([location distanceFromLocation:[self locationOfStop:stop]]);

		[stopsByDistance setObject:stop forKey:stopDistance];

	}
	// sort an array of keys (distances)
	NSMutableArray *distances = [NSMutableArray arrayWithArray:[stopsByDistance allKeys]];

	NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
	[distances sortUsingDescriptors:@[sorter]];

	NSMutableArray *closestStops = [NSMutableArray array];

	// crate and array of the n closest stops
	for (int i = 0; i < number; i++) [closestStops addObject:[stopsByDistance objectForKey:[distances objectAtIndex:i]]];

	return(closestStops);

}

+ (NSArray *) uniqueRoutesForStop:(Stop *)stop {

	NSMutableArray *routes = [NSMutableArray array];

	for (Direction *direction in stop.directions)

		if (![routes containsObject:direction.route]) [routes addObject:direction.route];
	// sort otherDirections by route
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	[routes sortUsingDescriptors:@[sortDescriptor]];

	return( (NSArray *)routes );
}

#pragma mark -
#pragma mark FlurryAnalytics

+ (NSDictionary *) dictionaryFromStop:(Stop *)stop {

	NSArray *keys = @[@"agencyShortTitle", @"tag", @"title"];
	NSArray *objects = @[[[DataHelper agencyFromStop:stop] shortTitle], stop.tag, stop.title];

	return([NSDictionary dictionaryWithObjects:objects forKeys:keys]);

}

+ (NSDictionary *) dictionaryFromRoute:(Route *)route {

	NSArray *keys = @[@"agencyShortTitle", @"tag"];
	NSArray *objects = @[route.agency.shortTitle, route.tag];

	return([NSDictionary dictionaryWithObjects:objects forKeys:keys]);

}

#pragma mark -
#pragma mark Static Maps GEO-TO X-Y code

+ (int) xCoordinateFromLongitude:(CGFloat)lon {

	double offset = 268435456;
	double radius = offset / M_PI;

	return( round(offset + radius * lon * M_PI / 180) );

}

+ (int) yCoordinateFromLatitude:(CGFloat)lat {

	double offset = 268435456;
	double radius = offset / M_PI;

	return( round(offset - radius * log( ( 1 + sin(lat * M_PI / 180) ) / ( 1 - sin(lat * M_PI / 180) ) ) / 2) );

}

@end
