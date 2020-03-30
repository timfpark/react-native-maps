//
//  AIRMapLocalTileOverlay.m
//  Pods-AirMapsExplorer
//
//  Created by Peter Zavadsky on 04/12/2017.
//

#import "AIRMapLocalTileOverlay.h"

@interface AIRMapLocalTileOverlay ()

@end

@implementation AIRMapLocalTileOverlay

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result {
    NSMutableString *tileFilePath = [self.URLTemplate mutableCopy];
    [tileFilePath replaceOccurrencesOfString: @"{x}" withString:[NSString stringWithFormat:@"%li", (long)path.x] options:0 range:NSMakeRange(0, tileFilePath.length)];
    [tileFilePath replaceOccurrencesOfString:@"{y}" withString:[NSString stringWithFormat:@"%li", (long)path.y] options:0 range:NSMakeRange(0, tileFilePath.length)];
    [tileFilePath replaceOccurrencesOfString:@"{z}" withString:[NSString stringWithFormat:@"%li", (long)path.z] options:0 range:NSMakeRange(0, tileFilePath.length)];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tileFilePath]) {
        NSData* tile = [NSData dataWithContentsOfFile:tileFilePath];
        result(tile,nil);
    } else {
        NSString *tileUrlString = [NSString stringWithFormat:@"https://map.trailguru.app/tile/%ld/%ld/%ld", path.z, path.x, path.y];
        NSURL *tileUrl = [NSURL URLWithString:tileUrlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:tileUrl];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (result) result(data, connectionError);
            if (!connectionError) {
                NSMutableString* tileFileDirectory = [self.URLTemplate mutableCopy];
                [tileFileDirectory replaceOccurrencesOfString: @"{z}" withString:[NSString stringWithFormat:@"%li", (long)path.z] options:0 range:NSMakeRange(0, tileFileDirectory.length)];
                [tileFileDirectory replaceOccurrencesOfString: @"{x}" withString:[NSString stringWithFormat:@"%li", (long)path.x] options:0 range:NSMakeRange(0, tileFileDirectory.length)];
                [tileFileDirectory replaceOccurrencesOfString: @"{y}" withString:@"" options:0 range:NSMakeRange(0, tileFileDirectory.length)];
                if (![[NSFileManager defaultManager] fileExistsAtPath:tileFileDirectory])
                    [[NSFileManager defaultManager] createDirectoryAtPath:tileFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];

                [[NSFileManager defaultManager] createFileAtPath:tileFilePath contents:data attributes:nil];
            }
        }];
    }
}

@end
