//
//  SPGooglePlace.h
//  ondeparar
//
//  Created by Leonardo Formaggio on 8/11/14.
//  Copyright (c) 2014 OndeParar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SPGooglePlaceAddressComponent : NSObject

@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSArray *types;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface SPGooglePlace : NSObject <MKAnnotation>

@property (nonatomic, strong) NSArray *addressComponents;
@property (nonatomic, strong) NSString *formattedAddress;

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) MKCoordinateRegion bounds;
@property (nonatomic, assign) MKCoordinateRegion viewport;
@property (nonatomic, strong) NSString *locationType;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) NSArray *types;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)ISOCountryCode;
- (NSString *)country;
- (NSString *)streetNumber;
- (NSString *)route; // Street
- (NSString *)neighborhood;
- (NSString *)locality; // City
- (NSString *)administrativeAreaLevel2;
- (NSString *)administrativeAreaLevel1; // State
- (NSString *)administrativeAreaLevel1Short;
- (NSString *)postalCode;

@end
