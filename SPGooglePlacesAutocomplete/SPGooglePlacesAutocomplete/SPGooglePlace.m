//
//  SPGooglePlace.m
//  ondeparar
//
//  Created by Leonardo Formaggio on 8/11/14.
//  Copyright (c) 2014 OndeParar. All rights reserved.
//

#import "SPGooglePlace.h"

@implementation SPGooglePlaceAddressComponent

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		self.longName = dictionary[@"long_name"];
		self.shortName = dictionary[@"short_name"];
		self.types = dictionary[@"types"];
	}
	return self;
}

@end

@implementation SPGooglePlace

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self && dictionary) {
		NSMutableArray *addressComponents = [[NSMutableArray alloc] init];
		for (NSDictionary *item in dictionary[@"address_components"]) {
			SPGooglePlaceAddressComponent *component = [[SPGooglePlaceAddressComponent alloc] initWithDictionary:item];
			[addressComponents addObject:component];
		}
		self.addressComponents = addressComponents;
		
		NSDictionary *geometry = dictionary[@"geometry"];
		CLLocationDegrees lat = [geometry[@"location"][@"lat"] doubleValue];
		CLLocationDegrees lng = [geometry[@"location"][@"lng"] doubleValue];
		self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
		self.locationType = geometry[@"location_type"];
		
		CLLocationDegrees boundsNorthEastLat = [geometry[@"bounds"][@"northeast"][@"lat"] doubleValue];
		CLLocationDegrees boundsNorthEastLng = [geometry[@"bounds"][@"northeast"][@"lng"] doubleValue];
		CLLocationDegrees boundsSouthWestLat = [geometry[@"bounds"][@"southwest"][@"lat"] doubleValue];
		CLLocationDegrees boundsSouthWestLng = [geometry[@"bounds"][@"southwest"][@"lng"] doubleValue];
		CLLocationCoordinate2D boundsCenter = CLLocationCoordinate2DMake((boundsNorthEastLat + boundsSouthWestLat) / 2, (boundsNorthEastLng + boundsSouthWestLng) / 2);
		MKCoordinateSpan boundsSpan = MKCoordinateSpanMake(boundsNorthEastLat - boundsSouthWestLat, boundsNorthEastLng - boundsSouthWestLng);
		self.bounds = MKCoordinateRegionMake(boundsCenter, boundsSpan);
		
		CLLocationDegrees viewportNorthEastLat = [geometry[@"viewport"][@"northeast"][@"lat"] doubleValue];
		CLLocationDegrees viewportNorthEastLng = [geometry[@"viewport"][@"northeast"][@"lng"] doubleValue];
		CLLocationDegrees viewportSouthWestLat = [geometry[@"viewport"][@"southwest"][@"lat"] doubleValue];
		CLLocationDegrees viewportSouthWestLng = [geometry[@"viewport"][@"southwest"][@"lng"] doubleValue];
		CLLocationCoordinate2D viewportCenter = CLLocationCoordinate2DMake((viewportNorthEastLat + viewportSouthWestLat) / 2, (viewportNorthEastLng + viewportSouthWestLng) / 2);
		MKCoordinateSpan viewportSpan = MKCoordinateSpanMake(viewportNorthEastLat - viewportSouthWestLat, viewportNorthEastLng - viewportSouthWestLng);
		self.viewport = MKCoordinateRegionMake(viewportCenter, viewportSpan);
		
		self.formattedAddress = dictionary[@"formatted_address"];
		self.types = dictionary[@"types"];
	}
	return self;
}

- (NSString *)ISOCountryCode
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"country\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.shortName;
}

- (NSString *)country
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"country\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.longName;
}

- (NSString *)streetNumber
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"street_number\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.longName;
}

- (NSString *)route
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"route\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.shortName;
}

- (NSString *)neighborhood
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"neighborhood\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.longName;
}

- (NSString *)locality
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"locality\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.longName;
}

- (NSString *)administrativeAreaLevel2
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"administrative_area_level_2\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.longName;
}

- (NSString *)administrativeAreaLevel1
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"administrative_area_level_1\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.longName;
}

- (NSString *)administrativeAreaLevel1Short
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"administrative_area_level_1\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.shortName;
}

- (NSString *)postalCode
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"types CONTAINS \"postal_code\""];
	SPGooglePlaceAddressComponent *component = [self.addressComponents filteredArrayUsingPredicate:predicate].firstObject;
	return component.longName;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
	return self.location.coordinate;
}

@end
