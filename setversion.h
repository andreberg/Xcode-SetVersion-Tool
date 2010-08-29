//
//  setversion.h
//  setversion
//
//  Created by Andre Berg on 04.07.09.
//  Copyright 2008 Berg Media. All rights reserved.
//

#include <string.h>
#include <errno.h>
#include <err.h>

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

/*!
 * @function progname
 * @abstract Returns a program name based on the file name of the source file
 * @param    name description
 * @result   String with program name
 */
const char * progname(void);

/*!
 * @function printUsage
 * @abstract Shows program usage
 * @discussion Prints a precomposed and hardwired function internal const string
 * to the file descriptor supplied by user.
 * @param    filedesc the file descriptor to write to
 * @result   void
 */
void printUsage(FILE * filedesc);

/*!
 * @function printVersion
 * @abstract Shows program version
 * @discussion Prints a precomposed and hardwired function internal const string
 * to the file descriptor supplied by user.
 * @param    filedesc the file descriptor to write to
 * @result   void
 */
void printVersion(FILE * filedesc);