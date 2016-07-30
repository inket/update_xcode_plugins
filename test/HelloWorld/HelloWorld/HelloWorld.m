//
//  HelloWorld.m
//  HelloWorld
//
//  Created by inket on 30/7/16.
//
//

#import "HelloWorld.h"

@implementation HelloWorld

+ (void)pluginDidLoad:(NSBundle *)plugin {
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        NSLog(@"HelloWorld plugin loaded!");

        NSString* path = [@"~/Desktop/success" stringByExpandingTildeInPath];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
}

@end
