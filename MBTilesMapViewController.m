//
//  ViewController.m
//  HG
//
//  Created by zak on 13/07/16.
//  Copyright © 2016 zak. All rights reserved.
//

#import "MBTilesMapViewController.h"
#import "MapTile.h"
#include <sqlite3.h>
#import "AppDelegate.h"


@interface MBTilesMapViewController ()

@end

@implementation MBTilesMapViewController{
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if([self getMbtilesPath] != nil){
        TileOverlay* overlay = [[TileOverlay alloc] init];
        overlay.mbtilesPath = [self getMbtilesPath];
        [overlay openMbtilesData];
        
        overlay.canReplaceMapContent = YES;
        [self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
        self.mapView.delegate = self;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay {
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    
    return nil;
}

- (NSString*) getMbtilesPath {
    return @"res/map";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
