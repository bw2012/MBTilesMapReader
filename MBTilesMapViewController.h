//
//  ViewController.h
//  HG
//
//  Created by zak on 13/07/16.
//  Copyright © 2016 zak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MBTilesMapViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

