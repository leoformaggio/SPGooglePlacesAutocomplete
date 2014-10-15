//
//  SPGoogleGeocoder.m
//  ondeparar
//
//  Created by Leonardo Formaggio on 7/25/14.
//  Copyright (c) 2014 OndeParar. All rights reserved.
//

#import "SPGoogleGeocoder.h"
#import "SPGooglePlacesAutocompleteUtilities.h"

@interface SPGoogleGeocoder()
@property (nonatomic, copy) void (^resultBlock)(SPGooglePlace *place, NSError *error);
@end

@implementation SPGoogleGeocoder

- (id)initWithAPIKey:(NSString *)APIKey
{
	self = [super init];
	if (self) {
		self.APIKey = APIKey;
	}
	return self;
}

- (NSURL *)googleURLWithAddress:(NSString *)address {
    NSString *URLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=%@&sensor=%@", address, self.APIKey, SPBooleanStringForBool(self.sensor)];
    if (self.language) {
        URLString = [URLString stringByAppendingFormat:@"&language=%@", self.language];
    }
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *URL = [NSURL URLWithString:URLString];
    return URL;
}

- (void)cleanup {
    _googleConnection = nil;
    _responseData = nil;
    self.resultBlock = nil;
}

- (void)cancelOutstandingRequests {
    [_googleConnection cancel];
    [self cleanup];
}

- (void)geocodeAddressString:(NSString *)address completion:(void (^)(SPGooglePlace *, NSError *))completion {
	if (SPIsEmptyString(address) && completion) {
        // Empty input string. Don't even bother hitting Google.
        completion(nil, nil);
        return;
    }
    
    [self cancelOutstandingRequests];
    self.resultBlock = completion;
    
	NSURL *URL = [self googleURLWithAddress:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    _googleConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    _responseData = [[NSMutableData alloc] init];
}

#pragma mark -
#pragma mark NSURLConnection Delegate

- (void)failWithError:(NSError *)error {
    if (self.resultBlock != nil) {
        self.resultBlock(nil, error);
    }
    [self cleanup];
}

- (void)succeedWithPlaces:(NSArray *)places {
	SPGooglePlace *place = [[SPGooglePlace alloc] initWithDictionary:places.firstObject];
    if (self.resultBlock != nil) {
        self.resultBlock(place, nil);
    }
    [self cleanup];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == _googleConnection) {
        [_responseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connnection didReceiveData:(NSData *)data {
    if (connnection == _googleConnection) {
        [_responseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == _googleConnection) {
        [self failWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == _googleConnection) {
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
        if (error) {
            [self failWithError:error];
            return;
        }
        if ([response[@"status"] isEqualToString:@"ZERO_RESULTS"]) {
            [self succeedWithPlaces:@[]];
            return;
        }
        if ([response[@"status"] isEqualToString:@"OK"]) {
            [self succeedWithPlaces:response[@"results"]];
            return;
        }
        
        // Must have received a status of OVER_QUERY_LIMIT, REQUEST_DENIED or INVALID_REQUEST.
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: response[@"status"]};
        [self failWithError:[NSError errorWithDomain:@"com.spoletto.googleplaces" code:kGoogleAPINSErrorCode userInfo:userInfo]];
    }
}

@end
