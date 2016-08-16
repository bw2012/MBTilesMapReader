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

//@property NSCache *cache;
@property NSData* blank_data;

@end

@implementation TileOverlay{
    sqlite3 *connection;
}

- (id)init {
    //self.cache = [[NSCache alloc] init];
    
    CGSize size = CGSizeMake(128, 128);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.blank_data = UIImagePNGRepresentation(image);
    UIGraphicsEndImageContext();
    
    return [super init];
}


- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result {
    NSData* data = [self getBlob:path.z tile_column:path.x tile_row:path.y];
    
    if(data == nil) {
        data = self.blank_data;
    }

    //data = [self addDebugInfo:data path:path];
    
    result(data, nil);
}

- (void)openMbtilesData {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:self.mbtilesPath ofType:@"mbtiles"];
    NSLog(@"MBTiles path: %@", filePath);
    if (sqlite3_open([filePath UTF8String], &connection) == SQLITE_OK) {
        NSLog(@"MBTiles is ready");
    } else {
        NSLog(@"Error in opening MBTiles");
    }
}

- (NSData *)addDebugInfo:(NSData*)data path:(MKTileOverlayPath)path {
    UIImage *image=[UIImage imageWithData:data];
    
    CGSize size = self.tileSize;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(ctx, 1.0);
    CGContextStrokeRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    NSString *text = [NSString stringWithFormat:@"X=%d\nY=%d\nZ=%d",path.x,path.y,path.z];
    [text drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor blackColor]}];
    UIImage *tileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *tileData = UIImagePNGRepresentation(tileImage);

    return tileData;
}

- (NSData *)getBlob:(int)zoom_level tile_column:(int)tile_column tile_row:(int)tile_row {
    sqlite3_stmt* compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(connection, "SELECT tile_data FROM tiles WHERE zoom_level=? AND tile_column=? AND tile_row=?", -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        sqlite3_bind_int(compiledStatement, 1, zoom_level);     // zoom level
        sqlite3_bind_int(compiledStatement, 2, tile_column);    // tile_column
        sqlite3_bind_int(compiledStatement, 3, tile_row);       // tile_column
        
        if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            NSData* blob = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 0) length:sqlite3_column_bytes(compiledStatement, 0)];
            sqlite3_finalize(compiledStatement);
            return blob;
        }
    }
    return nil;
}

@end

