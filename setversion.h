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
 * @fn builddate
 * Strip hyphens from a date.
 * @param isodate YYYY-MM-DD date string
 * @return YYYYMMDD date string
 */
char * builddate(char * restrict isodate);

/*!
 * @fn progname
 * Returns a program name based on the file name of the source file
 * @param    name description
 * @return   String with program name
 */
const char * progname(void);

/*!
 * @fn printUsage
 * Show program usage
 * @discussion Prints a precomposed usage string to the file descriptor supplied by user.
 * @param    filedesc the file descriptor to write to
 * @return   void
 */
void printUsage(FILE * filedesc);

/*!
 * @fn printVersion
 * Show program version
 * @discussion Prints a precomposed version string to the file descriptor supplied by user.
 * @param    filedesc the file descriptor to write to
 * @return   void
 */
void printVersion(FILE * filedesc);

