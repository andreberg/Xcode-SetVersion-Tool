//
//  setversion.m
//  setversion
//
//  Created by Andre Berg on 03.07.09.
//  Copyright 2008 Berg Media. All rights reserved.
//

#include <string.h>
#include <errno.h>
#include <err.h>

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

// the following four (well, two really..) defines can be used to
// set a fractional build version which increases with each passing day...
#define DATE            ([[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%Y-%m-%d"] UTF8String])
#define DAYZERO         183
#define DAYNOW          [[NSCalendarDate calendarDate] dayOfYear]
#define SV_VERSION      (double)((DAYNOW-DAYZERO) * 1000) / 100000
#define SV_COMPILEDATE  [[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%Y%m%d"]\
cStringUsingEncoding:NSASCIIStringEncoding]

// ofc, nothing is stopping us from just using an invariant define :)
#define SV_VERSION_CONST     "0.5"
#define SV_NAME_CONST        "setversion"

#define strequal(a,b)	(!strcmp((a),(b)))


static NSString * kSVCFBundleVersionKey = @"CFBundleVersion";
static NSString * kSVCFBundleShortVersionStringKey = @"CFBundleShortVersionString";
static NSString * kSVCFBundleVersionTotalKey = @"CFBundleVersionTotal";

const char * progname(void) {
    
    const char * result = __FILE__;
    
    NSString * name = [[[NSString stringWithCString:(result) 
                                           encoding:NSUTF8StringEncoding] lastPathComponent] 
                                                stringByDeletingPathExtension];
    char buf[BUFSIZ];
    BOOL success = [name getCString:buf 
                          maxLength:BUFSIZ-1 
                           encoding:NSUTF8StringEncoding];
    
    //     NSLog(@"name = %@", name);
    //     NSLog(@"success = %s", success == YES ? "YES" : "NO");
    //     NSLog(@"buf = %s", buf);
    
    if (success) {
        result = buf;
    }
    
    return result;
}

void printUsage(FILE * filedesc) {
    
    const char usage[] = "\n"
    ""
    "   "SV_NAME_CONST" -- Xcode helper tool for updating property lists\n"
    "\n"
    "   Created by André Berg on %s.\n"                   
    "   Copyright 2009 Berg Media. All rights reserved.\n"
    "\n"
    "   USAGE: "SV_NAME_CONST" [-n <int threshold>] [-i <int increment>] <plist> -OR- \n"
    "          "SV_NAME_CONST" -k <key> <value> [<key> <value> ...]  <plist> \n"
    "\n"
    "       Typically used for updating keys contained by Info.plist\n"
    "       during a 'Run Script' build phase in Xcode.\n"
    "\n"
    "       In \"Set key\" mode (-k) you can specify as many key/value pairs\n"
    "       as you like, just make sure that they are really pairs.\n"
    "       Each <key> in <plist> will be set to <value> until no more pairs\n"
    "       are left.\n"
    "\n"
    "       NOTE: At the moment only values of type string, float/double, int/long\n"
    "       and BOOL (true/false) are supported! (YES/NO are string values treated as BOOL)\n"
    "\n"
    "       NOTE 2: If you supply real numbers, be aware that those are subject to\n"
    "       IEE754 FP inaccuracies, which happen in the conversion from string to real.\n"
    "       If you need exact numbers you might want to use a string instead.\n"
    "\n"
    "       In \"Increment\" mode (-n) you specify a number, which defines at what\n"
    "       intervals 'CFBundleShortVersionString' will be incremented by 0.1 or\n"
    "       by a user specifiable amount.\n"
    "\n"
    "       'CFBundleVersion' is automatically incremented by 1 each build and\n"
    "       whenever 'CFBundleVersion' is equal to <threshold>, the 'CFBundleShort-\n"
    "       VersionString' will be incremented by 0.1 or by whatever number was set\n"
    "       by -i <increment>.\n"
    "\n"
    "       Another key 'CFBundleVersionTotal' is set to the total amount of builds\n"
    "       since setversion was added to the build process.\n"
    "\n"
    "       NOTE: Default mode is \"Increment\" if no argument other than <plist>\n"
    "\n"
    "   OPTIONS:\n"
    "       -V, --version        Display version and exit\n"
    "\n"
    "       -h, --help           Display this help and exit\n"
    "\n"
    "        Note: If you want to see the plist printed to stdout before and\n"
    "              after manipulation, setenv \"NSDebugLevel\" to sth. greater than 0\n"
    "\n"
    "   EXAMPLES:\n"
    "\n"
    "       Default usage: Increment \"CFBundleVersion\" from Info.plist:\n"
    "\n"
    "       setversion Info.plist\n"
    "\n"
    "       Note: keep in mind that you can use any Xcode specific\n"
    "             variables from project/build settings here."
    "\n"
    "\n"
    "   DISCLAIMER:\n"
    "\n"
    "       This program comes with ABSOLUTELY NO WARRANTY\n"
    "       and is provided \"AS-IS\". USE AT YOUR OWN RISK!\n"
    "\n"
    "   LICENSE:\n"
    "\n"    
    "       Licensed under the Apache License, Version 2.0 (the \"License\");\n"
    "       you may not use this file except in compliance with the License.\n"            
    "       You may obtain a copy of the License at\n"
    "\n"
    "           http://www.apache.org/licenses/LICENSE-2.0\n"
    "\n"    
    "       Unless required by applicable law or agreed to in writing, software\n"
    "       distributed under the License is distributed on an \"AS IS\" BASIS,\n"
    "       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n"
    "       See the License for the specific language governing permissions and\n"
    "       limitations under the License.\n"
    "\n"
    "\n"
    "   SEE ALSO:\n"
    "       man plist(5)\n"
    "\n";
    
    fprintf(filedesc, usage, DATE);
}

void printVersion(FILE * filedesc) {
    
    fprintf(filedesc, "%s v%s (%s)\n", SV_NAME_CONST, SV_VERSION_CONST, SV_COMPILEDATE);
}


int main (int argc, char * const argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableDictionary * plistDict;
    
    OSErr err = noErr;
    int DEBUG = DEBUG_LEVEL_PRODUCTION;
    
    BOOL setkeyMode = NO;
    
    @try {
        char * dbglevel = getenv("NSDebugLevel");
        if (dbglevel) {
            DEBUG = atoi(dbglevel);
        }
    }
    @catch (NSException * e) {
        // do nothing...
    }

    NSInteger arg;
    NSInteger threshold = 100;
    NSInteger increment_ = 100;
    
    while ( (arg = getopt(argc, argv, "Vhn:i:k")) != -1) {
        switch (arg) {
            case 'V':
                printVersion(stdout);
                [pool drain];
                exit(EXIT_SUCCESS);
                break;
            case 'h':
                printUsage(stdout);
                [pool drain];
                exit(EXIT_SUCCESS);
                break;
            case 'n':
                threshold = (NSInteger)(strtol(optarg, NULL, 10));
                break;
            case 'i':
                increment_ = (NSInteger)(strtod(optarg, NULL) * 1000);
                break;
            case 'k':
                setkeyMode = YES;
                break;
            case '?':
                fprintf(stderr, "Error: Invalid argument\n");
                [pool drain];
                exit(EXIT_FAILURE);
                break;
            default:
                printUsage(stdout);
                [pool drain];
                exit(EXIT_FAILURE);
                break;
        }
    }
    
    argc -= optind;
    argv += optind;
    
    if (!argc > 0) {
        fprintf(stderr, "Error: At the very least, a path to a Plist file must be specified.\n       Type \""SV_NAME_CONST" -h\" for help. Aborting...\n");
        [pool drain];
        exit(EXIT_FAILURE);
    }
    
    NSString * plistArg = [NSString stringWithCString:argv[argc-1]];       
    NSString * plistBefore = [NSString string];
    NSString * plistAfter = [NSString string];
    
    // try to read the plist file at the user supplied path 
    plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistArg];
    plistBefore = [plistDict descriptionInStringsFileFormat];
    
    // plist file couldn't be read, so log error and give up...
    if(!plistDict) {
        err = ENOENT;
        fprintf(stderr, "Error: Can't read plist file at path '%s'. %s (%d).\n", [plistArg UTF8String], strerror(err), err);
        [pool drain];
        exit(EXIT_FAILURE);
    } else {
        argc -= 1;
    }

    if (setkeyMode == YES) {
        
        // make a copy of the ARGV array with the last item,
        // which should be the plist path, chopped off...
        const char * argv2[argc];
        for (int i = 0; i < argc; i++) {
            argv2[i] = argv[i];
        }
        
        // handle key/value pairs
        while (argc > 0 && argv != NULL) {
            
            NSString * keyArg = [NSString stringWithCString:argv[0] encoding:NSUTF8StringEncoding];
            NSString * valueArg = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
            
            @try {
                // wonky way of detecting a real
                if (strnstr(argv[1], ".", strlen(argv[1])) != NULL) {
                    double dnum = (strtod(argv[1], NULL));
                    if (dnum != 0 && (errno != EINVAL || errno != ERANGE)) {
                        [plistDict setObject:[NSNumber numberWithDouble:dnum] 
                                      forKey:keyArg];
                    }
                } else {
                    long lnum = (strtol(argv[1], NULL, 10));
                    if (lnum != 0 && (errno != EINVAL || errno != ERANGE)) {
                        [plistDict setObject:[NSNumber numberWithLong:lnum] 
                                      forKey:keyArg];
                    } else {
                        // we do not handle YES/NO here as plists seem to set YES or NO
                        // as string value
                        if ([valueArg isEqualToString:@"true"]) {
                            [plistDict setObject:[NSNumber numberWithBool:YES] forKey:keyArg];
                        } else if ([valueArg isEqualToString:@"false"]) {
                            [plistDict setObject:[NSNumber numberWithBool:NO] forKey:keyArg];
                        } else {
                            [plistDict setObject:valueArg forKey:keyArg];
                        }    
                    }
                }
            }
            @catch (NSException * e) {
                NSLog(@"Conversion to plist object failed, because %@.", [e reason]);
            }

            argc -= 2;
            argv += 2;
        }
        
    } else { // increment version mode
        @try {
            
            NSInteger oldRev = [[plistDict valueForKey:kSVCFBundleVersionKey] intValue];
            NSInteger totalRev = [[plistDict valueForKey:kSVCFBundleVersionTotalKey] intValue];
            NSInteger newRev = oldRev + 1;
            
            if (totalRev == 0) {
                totalRev = newRev;
            } else {
                totalRev += 1;
            }
            
            // also set a total counter which will not the reset
            // for whatever purposes... could be fun :) (*hey look 3000th build coming up!*)
            [plistDict setObject:[NSNumber numberWithInt:totalRev] forKey:kSVCFBundleVersionTotalKey];
            
            // read out short CF Bundle version string...
            NSString * shortVersionString = [plistDict valueForKey:kSVCFBundleShortVersionStringKey];
            
            // if CFBundleShortVersionString is missing, set it to a default value
            if (shortVersionString == nil) {
                [plistDict setObject:@"1.0" forKey:kSVCFBundleShortVersionStringKey];
                shortVersionString = @"1.0";
            } 
            
            // ...now increment it
            if (newRev >= threshold) {
                
                NSInteger incrFieldWidth = ([[NSString stringWithFormat:@"%i", increment_] length]);
                
                char shortVersionCString[16];
                float shortVersion = (((strtod([shortVersionString UTF8String], NULL) * 1000) + increment_) / 1000);
                
                snprintf(shortVersionCString, 16, "%.*f", incrFieldWidth, shortVersion);
                
                if (DEBUG) {
                    NSLog(@"shortVersion: before = %@, after = %s\n", shortVersionString, shortVersionCString);
                }

                [plistDict setObject:[NSString stringWithFormat:@"%s", shortVersionCString] forKey:kSVCFBundleShortVersionStringKey];
                
                // reset the counter
                [plistDict setObject:@"0" forKey:kSVCFBundleVersionKey];
            } else {
                [plistDict setObject:[NSString stringWithFormat:@"%d", newRev] forKey:kSVCFBundleVersionKey];
            }
        }
        @catch (NSException * e) {
            NSLog(@"*** Exception: %@ reason: %@, in %s ***", [e name], [e reason], __PRETTY_FUNCTION__);
        }
    }
    
    plistAfter = [plistDict descriptionInStringsFileFormat];
    
    if (DEBUG) {
        NSLog(@"%@ before:\n%@\n", plistArg, plistBefore);
        NSLog(@"%@ after:\n%@\n", plistArg, plistAfter);
    }
    
    // write to plist at user supplied path
    if(![plistDict writeToFile:plistArg atomically:YES]){
        err = EIO;
        fprintf(stderr, "Error: Can't write plist file at path '%s'. %s (%d)\n", [plistArg UTF8String], strerror(err), err);
        [pool drain];
        exit(EXIT_FAILURE);            
    }
    
    [pool drain];
    return EXIT_SUCCESS;
    
}
