//
//  SPGooglePlacesAutocompletePlace.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "SPGooglePlacesAutocompleteUtilities.h"
#import "SPGooglePlace.h"

@interface SPGooglePlacesAutocompletePlaceTerm : NSObject

@property (nonatomic, assign, readonly) NSUInteger offset;
@property (nonatomic, strong, readonly) NSString *value;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)objectsFromDictionaries:(NSArray *)dictionaries;

@end

@interface SPGooglePlacesAutocompletePlace : NSObject {
    CLGeocoder *_geocoder;
}

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary apiKey:(NSString *)apiKey;

/*!
 Contains the human-readable name for the returned result. For establishment results, this is usually the business name.
 */
@property (nonatomic, retain, readonly) NSString *name;

/*!
 Contains the primary 'type' of this place (i.e. "establishment" or "gecode").
 */
@property (nonatomic, readonly) SPGooglePlacesAutocompletePlaceType type;

/*!
 Contains a unique token that you can use to retrieve additional information about this place in a Place Details request. You can store this token and use it at any time in future to refresh cached data about this Place, but the same token is not guaranteed to be returned for any given Place across different searches.
 */
@property (nonatomic, retain, readonly) NSString *reference;

/*!
 Contains a unique stable identifier denoting this place. This identifier may not be used to retrieve information about this place, but can be used to consolidate data about this Place, and to verify the identity of a Place across separate searches.
 */
@property (nonatomic, retain, readonly) NSString *identifier;

/*!
 Your application's API key. This key identifies your application for purposes of quota management. Visit the APIs Console to select an API Project and obtain your key. Maps API for Business customers must use the API project created for them as part of their Places for Business purchase. Defaults to kGoogleAPIKey.
 */
@property (nonatomic, strong, readonly) NSString *key;

/*!
 Contains an array of terms identifying each section of the returned description (a section of the description is generally terminated with a comma). Each entry in the array has a value field, containing the text of the term, and an offset field, defining the start position of this term in the description, measured in Unicode characters.
*/
@property (nonatomic, retain, readonly) NSArray *terms;

/*!
 Resolves the place to a CLPlacemark, issuing  Google Place Details request if needed.
 */
- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block;

/*!
 Resolves the place to a CLPlacemark, issuing  Google Place Details request if needed.
 */
- (void)resolveToGooglePlace:(SPGooglePlacesPlaceResultBlock)block;

/*!
 Convenience property for configuring textLabel on UITableViewCell.
 */
@property (nonatomic, retain, readonly) NSString *title;

/*!
 Convenience property for configuring detailTextLabel on UITableViewCell.
 */
@property (nonatomic, retain, readonly) NSString *subtitle;

@end
