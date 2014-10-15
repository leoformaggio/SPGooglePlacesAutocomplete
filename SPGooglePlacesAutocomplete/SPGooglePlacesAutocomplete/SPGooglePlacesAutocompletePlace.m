//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"
#import "SPGooglePlacesPlaceDetailQuery.h"
#import "SPGooglePlace.h"

@interface SPGooglePlacesAutocompletePlaceTerm()
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, strong) NSString *value;
@end

@implementation SPGooglePlacesAutocompletePlaceTerm

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [super init];
	if (self) {
		self.offset = [[dictionary valueForKey:@"offset"] unsignedIntegerValue];
		self.value = [dictionary valueForKey:@"value"];
	}
	return self;
}

+ (NSArray *)objectsFromDictionaries:(NSArray *)dictionaries {
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[dictionaries count]];
	for (NSDictionary *dictionary in dictionaries) {
		SPGooglePlacesAutocompletePlaceTerm *term = [[SPGooglePlacesAutocompletePlaceTerm alloc] initWithDictionary:dictionary];
		[array addObject:term];
	}
	return array;
}

@end

@interface SPGooglePlacesAutocompletePlace()
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSString *reference;
@property (nonatomic, retain, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, retain, readwrite) NSArray *terms;
@property (nonatomic, retain, readwrite) NSString *title;
@property (nonatomic, retain, readwrite) NSString *subtitle;
@property (nonatomic, readwrite) SPGooglePlacesAutocompletePlaceType type;
@end

@implementation SPGooglePlacesAutocompletePlace

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary apiKey:(NSString *)apiKey {
	NSArray *terms = [SPGooglePlacesAutocompletePlaceTerm objectsFromDictionaries:placeDictionary[@"terms"]];
    SPGooglePlacesAutocompletePlace *place = [[self alloc] init];
	SPGooglePlacesAutocompletePlaceTerm *term = terms.firstObject;
	NSMutableArray *values = [[terms valueForKeyPath:@"value"] mutableCopy];
	[values removeObject:values.firstObject];
	NSString *detail = [values componentsJoinedByString:@", "];
    place.name = placeDictionary[@"description"];
    place.reference = placeDictionary[@"reference"];
    place.identifier = placeDictionary[@"id"];
	place.terms = terms;
	place.title = term.value;
	place.subtitle = detail;
    place.type = SPPlaceTypeFromDictionary(placeDictionary);
	place.key = apiKey;
    return place;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Reference: %@, Identifier: %@, Type: %@",
            self.name, self.reference, self.identifier, SPPlaceTypeStringForPlaceType(self.type)];
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)resolveEstablishmentPlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    SPGooglePlacesPlaceDetailQuery *query = [[SPGooglePlacesPlaceDetailQuery alloc] initWithApiKey:self.key];
    query.reference = self.reference;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            NSString *addressString = placeDictionary[@"formatted_address"];
            [[self geocoder] geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    block(nil, nil, error);
                } else {
                    CLPlacemark *placemark = [placemarks onlyObject];
                    block(placemark, self.name, error);
                }
            }];
        }
    }];
}

- (void)resolveGecodePlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    [[self geocoder] geocodeAddressString:self.name completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            CLPlacemark *placemark = [placemarks onlyObject];
            block(placemark, self.name, error);
        }
    }];
}

- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    if (self.type == SPPlaceTypeGeocode) {
        // Geocode places already have their address stored in the 'name' field.
        [self resolveGecodePlaceToPlacemark:block];
    } else {
        [self resolveEstablishmentPlaceToPlacemark:block];
    }
}

- (void)resolveToGooglePlace:(SPGooglePlacesPlaceResultBlock)block {
	SPGooglePlacesPlaceDetailQuery *query = [[SPGooglePlacesPlaceDetailQuery alloc] initWithApiKey:self.key];
	query.reference = self.reference;
	[query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
		SPGooglePlace *place = nil;
		if (!error) {
			place = [[SPGooglePlace alloc] initWithDictionary:placeDictionary];
			place.title = self.title;
			place.subtitle = self.subtitle;
		}
		if (block) block(place, error);
	}];
}

@end
