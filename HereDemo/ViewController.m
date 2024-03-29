//
//  ViewController.m
//  HereDemo
//
//  Created by Melike Sardogan on 15.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

#import "ViewController.h"

@import NMAKit;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView *mapView;


@end

@implementation ViewController {
    NSMutableArray<NMAMapMarker*>* _mapMarkers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapMarkers = [NSMutableArray array];
    
    //set geo center
    NMAGeoCoordinates *geoCoordCenter =
    [[NMAGeoCoordinates alloc] initWithLatitude:40.93567 longitude:29.15507];
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    self.mapView.copyrightLogoPosition = NMALayoutPositionBottomCenter;
    
    //set zoom level
    self.mapView.zoomLevel = 13.2;
    
    
    
    // register for position changes
//    if ([[NMAPositioningManager sharedPositioningManager] startPositioning]) {
//        // Register to positioning manager notifications
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(positionDidUpdate) name:NMAPositioningManagerDidUpdatePositionNotification
//                                                   object:[NMAPositioningManager sharedPositioningManager]];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(didLosePosition) name: NMAPositioningManagerDidLosePositionNotification
//                                                   object:[NMAPositioningManager sharedPositioningManager]];
//    }
    // Set position indicator visible. Also starts position updates.
    self.mapView.positionIndicator.visible = YES;
    
}

// Handle NMAPositioningManagerDidUpdatePositionNotification
- (void)positionDidUpdate
{
    NMAGeoPosition *position = [[NMAPositioningManager sharedPositioningManager] currentPosition];
    [_mapView setGeoCenter:position.coordinates
             withAnimation:NMAMapAnimationLinear];
    
    
    
    // Update label text based on received position.
    self.label.text = [NSString stringWithFormat:
                       @" Type: %@\n Coordinate: %.6f, %.6f\n Altitude: %.1f\n ",
                       @"Unknown",
                       position.coordinates.latitude,
                       position.coordinates.longitude,
                       position.coordinates.altitude];
    
    // Update position indicator position.
    [_mapView setGeoCenter:position.coordinates
             withAnimation:NMAMapAnimationLinear];
}

// Handle NMAPositioningManagerDidLosePositionNotification
- (void)didLosePosition
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NMAPositioningManager sharedPositioningManager] stopPositioning];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NMAPositioningManagerDidUpdatePositionNotification
                                                  object:[NMAPositioningManager sharedPositioningManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NMAPositioningManagerDidLosePositionNotification
                                                  object:[NMAPositioningManager sharedPositioningManager]];
}

- (IBAction)getCurrentLocation:(id)sender {
    
    [self positionDidUpdate];
}

//- (void)createRoute
//{
//    // Create an NSMutableArray to add two stops
//    NSMutableArray* stops = [[NSMutableArray alloc] initWithCapacity:4];
//    
//    // START: 4350 Still Creek Dr
//    NMAGeoCoordinates* hereBurnaby =
//    [[NMAGeoCoordinates alloc] initWithLatitude:40.93567 longitude:29.15507];
//    // END: Langley BC
//    NMAGeoCoordinates* langley =
//    [[NMAGeoCoordinates alloc] initWithLatitude:49.0736 longitude:-122.559549];
//    [stops addObject:hereBurnaby];
//    [stops addObject:langley];
//    
//    // Create an NMARoutingMode, then set it to find the fastest car route without going on Highway.
//    NMARoutingMode* routingMode =
//    [[NMARoutingMode alloc] initWithRoutingType:NMARoutingTypeFastest
//                                  transportMode:NMATransportModeCar
//                                 routingOptions:NMARoutingOptionAvoidHighway];
//    
//    // Initialize the NMACoreRouter
//    if ( !self.router )
//    {
//        self.router = [[NMACoreRouter alloc] init];
//    }
//    
//    // Trigger the route calculation
//    [self.router calculateRouteWithStops:stops routingMode:routingMode
//                         completionBlock:^(NMARouteResult *routeResult, NMARoutingError error) {
//                             
//                             // If the route was calculated successfully
//                             if (!error && routeResult && routeResult.routes.count > 0)
//                             {
//                                 NMARoute* route = [routeResult.routes objectAtIndex:0];
//                                 // Render the route on the map
//                                 NMAMapRoute* mapRoute = [NMAMapRoute mapRouteWithRoute:route];
//                                 [mapView addMapObject:mapRoute];
//                                 
//                                 // To see the entire route, we orientate the map view accordingly
//                                 [mapView setBoundingBox:route.boundingBox
//                                           withAnimation:NMAMapAnimationLinear];
//                             }
//                             else if (error)
//                             {
//                                 // Display a message indicating route calculation failure
//                             }
//                         }];
//    
//}


- (IBAction)createRoute:(id)sender {
    
    NMAGeoCoordinates *geoCoordCenter = [[NMAGeoCoordinates alloc] initWithLatitude:41.000144 longitude:29.099402];

    NMAMapMarker *altemiraMark = [NMAMapMarker mapMarkerWithGeoCoordinates:geoCoordCenter image:[UIImage imageNamed:@"logo.png"]];
    
    [self.mapView addMapObject:altemiraMark];
    
    [_mapMarkers addObject:altemiraMark];
    
    
    [self navigateToMarkers];
}

-(void)navigateToMarkers {
    // find max and min latitudes and longitudes in order to calculate
    // geo bounding box so then we can mapView->setBoundingBox(geoBox, ...) to it.
    double minLat = 90.0;
    double minLon = 180.0;
    double maxLat = -90.0;
    double maxLon = -180.0;
    
    for (NMAMapMarker* marker in _mapMarkers) {
        NMAGeoCoordinates* coordinate = marker.coordinates;
        
        double latitude = coordinate.latitude;
        double longitude = coordinate.longitude;
        
        minLat = fmin(minLat, latitude);
        minLon = fmin(minLon, longitude);
        maxLat = fmax(maxLat, latitude);
        maxLon = fmax(maxLon, longitude);
    }
    
    NMAGeoBoundingBox* box = [NMAGeoBoundingBox geoBoundingBoxWithTopLeft:[NMAGeoCoordinates geoCoordinatesWithLatitude:maxLat longitude:minLon]
                                                              bottomRight:[NMAGeoCoordinates geoCoordinatesWithLatitude:minLat longitude:maxLon]];
    CGFloat padding = 50;
    [[self mapView] setBoundingBox:box
                        insideRect:CGRectMake(padding, padding, self.mapView.bounds.size.width - padding * 2, self.mapView.bounds.size.height - padding * 2)
                     withAnimation:NMAMapAnimationLinear];
    
    self.mapView.zoomLevel = 13.2;
}

@end
