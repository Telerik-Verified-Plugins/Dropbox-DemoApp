/********* CDVDropbox.m Cordova Plugin Implementation *******/

#import "CDVDropbox.h"
#import <Dropbox/Dropbox.h>

@implementation CDVDropbox

- (void)pluginInitialize
{
    [super pluginInitialize];

    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];

    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
}

- (void)linkedAccounts:(CDVInvokedUrlCommand*)command
{
    NSArray *accounts = [[DBAccountManager sharedManager] linkedAccounts];

    if (accounts){

        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];

        for (DBAccount * account in accounts){
            [mutableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:account.userId, @"userId", nil]];
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: mutableArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
    }
}

- (void)linkAccount:(CDVInvokedUrlCommand*)command
{
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [[DBAccountManager sharedManager] linkFromController:rootViewController];

}

- (void)saveFile:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;

    NSDictionary* body = [command.arguments objectAtIndex:0];

    NSArray *paths = [body objectForKey:@"files"];
    NSString *folder = [body objectForKey:@"folder"];

    NSError *error = nil;

    for (NSString *path in paths){
        // normalize
        NSString *relativePath = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];

        NSString *fileName = [relativePath lastPathComponent];
        DBPath *newPath = nil;

        if (folder){
            DBPath *folderPath = [[DBPath root] childPath:folder];

            [[DBFilesystem sharedFilesystem] createFolder:folderPath error:&error];

            newPath = [folderPath childPath:fileName];
        }else{
            newPath = [[DBPath root] childPath:fileName];
        }

        DBFile *file = [[DBFilesystem sharedFilesystem] createFile:newPath error:&error];

        NSData *data = [[NSFileManager defaultManager] contentsAtPath:relativePath];

        [file writeData:data error:&error];

        if (error){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
    }

    if (!error){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@(YES), @"success", nil]];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}


@end
