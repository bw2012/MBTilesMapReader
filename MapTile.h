//
//  MapTile.h
//  MG
//
//  Created by zak on 22/01/16.
//  Copyright © 2016 zak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


//==============================================================================================================
// tiles
//==============================================================================================================
@interface TileOverlay : MKTileOverlay

@property NSString* mbtilesPath;

- (void)openMbtilesData;

@end
