//
//  SPGoogleGeocoder.h
//  ondeparar
//
//  Created by Leonardo Formaggio on 7/25/14.
//  Copyright (c) 2014 OndeParar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGooglePlace.h"

@interface SPGoogleGeocoder : NSObject {
	NSURLConnection *_googleConnection;
	NSMutableData *_responseData;
}

@property (nonatomic, strong) NSString *APIKey;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, assign) BOOL sensor;

- (id)initWithAPIKey:(NSString *)APIKey;
- (void)geocodeAddressString:(NSString *)address completion:(void (^)(SPGooglePlace *place, NSError *error))completion;

@end
