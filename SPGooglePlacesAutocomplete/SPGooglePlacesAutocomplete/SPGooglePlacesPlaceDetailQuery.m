//
//  SPGooglePlacesPlaceDetailQuery.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/18/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesPlaceDetailQuery.h"

@interface SPGooglePlacesPlaceDetailQuery()
@property (nonatomic, copy, readwrite) SPGooglePlacesPlaceDetailResultBlock resultBlock;
@end

@implementation SPGooglePlacesPlaceDetailQuery

- (id)initWithApiKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        // Setup default property values.
        self.sensor = YES;
        self.key = apiKey;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Query URL: %@", [self googleURLString]];
}

- (NSString *)googleURLString {
    NSMutableString *url = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=%@&key=%@",
                            self.reference, SPBooleanStringForBool(self.sensor), self.key];
    if (self.language) {
        [url appendFormat:@"&language=%@", self.language];
    }
    return url;
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

- (void)fetchPlaceDetail:(SPGooglePlacesPlaceDetailResultBlock)block {
	if (!self.key) {
		return;
	}
	
    [self cancelOutstandingRequests];
    self.resultBlock = block;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self googleURLString]]];
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

- (void)succeedWithPlace:(NSDictionary *)placeDictionary {
    if (self.resultBlock != nil) {
        self.resultBlock(placeDictionary, nil);
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
        if ([[response objectForKey:@"status"] isEqualToString:@"OK"]) {
            [self succeedWithPlace:[response objectForKey:@"result"]];
        }
                
        // Must have received a status of UNKNOWN_ERROR, ZERO_RESULTS, OVER_QUERY_LIMIT, REQUEST_DENIED or INVALID_REQUEST.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[response objectForKey:@"status"] forKey:NSLocalizedDescriptionKey];
        [self failWithError:[NSError errorWithDomain:@"com.spoletto.googleplaces" code:kGoogleAPINSErrorCode userInfo:userInfo]];
    }
}

@end
