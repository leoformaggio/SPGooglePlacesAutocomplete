//
//  SPGooglePlacesAutocompleteViewController.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <MapKit/MapKit.h>

@class SPGooglePlacesAutocompleteQuery;

@interface SPGooglePlacesAutocompleteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate> {
    NSArray *_searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *_searchQuery;
    MKPointAnnotation *_selectedPlaceAnnotation;
    
    BOOL _shouldBeginEditing;
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;

@end
