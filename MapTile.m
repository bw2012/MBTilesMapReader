//
//  MapTile.m
//  MG
//
//  Created by zak on 22/01/16.
//  Copyright © 2016 zak. All rights reserved.
//

#import "MapTile.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#include <sqlite3.h>




//==============================================================================================================
// tiles
//==============================================================================================================

@interface TileOverlay ()

@property NSCache *cache;
@property NSOperationQueue *operationQueue;

@end

@implementation TileOverlay{
    sqlite3_stmt *compiledStatement;
}


- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result {   
    NSData *data = [self getBlob:path.z tile_column:path.x tile_row:path.y];
    if(data == Nil){
        NSLog(@"tile not found -> %d %d %d", path.z, path.x, path.y);
    }
    
    result(data, nil);
}

- (void)openMbtilesData {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:self.mbtilesPath ofType:@"mbtiles"];
    NSLog(@"MBTiles path: %@", filePath);
    sqlite3 *newDBconnection;
    if (sqlite3_open([filePath UTF8String], &newDBconnection) == SQLITE_OK) {
        //sqlite3_stmt *compiledStatement;
        
        BOOL prepareStatementResult = sqlite3_prepare_v2(newDBconnection, "SELECT tile_data FROM tiles WHERE zoom_level=? AND tile_column=? AND tile_row=?", -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            NSLog(@"MBTiles is ready");
        }
    } else {
        NSLog(@"Error in opening MBTiles");
    }
}

- (NSData *)getBlob:(int)zoom_level tile_column:(int)tile_column tile_row:(int)tile_row {
    
    sqlite3_bind_int(compiledStatement, 1, zoom_level);     // zoom level
    sqlite3_bind_int(compiledStatement, 2, tile_column);    // tile_column
    sqlite3_bind_int(compiledStatement, 3, tile_row);       // tile_column
    
    if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
        NSData* blob = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 0) length:sqlite3_column_bytes(compiledStatement, 0)];
        //ßNSLog(@"data -> %d", blob.length);
        sqlite3_reset(compiledStatement);
        
        return blob;
    }

    return nil;
}

@end

