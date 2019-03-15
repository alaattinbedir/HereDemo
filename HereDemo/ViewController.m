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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set geo center
    NMAGeoCoordinates *geoCoordCenter =
    [[NMAGeoCoordinates alloc] initWithLatitude:40.93567 longitude:29.15507];
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    self.mapView.copyrightLogoPosition = NMALayoutPositionBottomCenter;
    
    //set zoom level
    self.mapView.zoomLevel = 13.2;
    
    
    
    // register for position changes
    if ([[NMAPositioningManager sharedPositioningManager] startPositioning]) {
        // Register to positioning manager notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(positionDidUpdate) name:NMAPositioningManagerDidUpdatePositionNotification
                                                   object:[NMAPositioningManager sharedPositioningManager]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLosePosition) name: NMAPositioningManagerDidLosePositionNotification
                                                   object:[NMAPositioningManager sharedPositioningManager]];
    }
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


@end
