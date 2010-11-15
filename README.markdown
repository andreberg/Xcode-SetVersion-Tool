

	setversion -- Xcode helper tool for updating property lists

	Created by André Berg on 2009-07-27.
	Copyright 2009-2010 Berg Media. All rights reserved.

	USAGE: setversion [-n <int threshold>] [-i <int increment>] <plist> -OR- 
	       setversion -k <key> <value> [<key> <value> ...]  <plist> 

	    Typically used for updating keys contained by Info.plist
	    during a 'Run Script' build phase in Xcode.

	    In "Set key" mode (-k) you can specify as many key/value pairs
	    as you like, just make sure that they are really pairs.
	    Each <key> in <plist> will be set to <value> until no more pairs
	    are left.

	    Note: At the moment only values of type String, Number (Real or Integer),
        Boolean (true/false or YES/NO) and Date (format: YYYY-MM-DD HH:MM:SS ±HHMM)
        are supported! Currently unsupported: Dictionary, Array and Data.

	    In "Increment" mode (-n) you specify a number, which defines at what
	    intervals 'CFBundleShortVersionString' will be incremented by 0.1 or
	    by a user specifiable amount.

	    'CFBundleVersion' is automatically incremented by 1 each build and
	    whenever 'CFBundleVersion' is equal to <threshold>, the 'CFBundleShort-
	    VersionString' will be incremented by 0.1 or by whatever number was set
	    by -i <increment>.

	    Another key 'CFBundleVersionTotal' is set to the total amount of builds
	    since setversion was added to the build process.

	    Note: Default mode is "Increment" if no argument other than <plist>

	OPTIONS:
	    -V, --version        Display version and exit

	    -h, --help           Display this help and exit

	     Note: If you want to see the plist printed to stdout before and
	           after manipulation, setenv "NSDebugLevel" to sth. greater than 0

	EXAMPLES:

	    Default usage: Increment "CFBundleVersion" from Info.plist:

	    setversion Info.plist

	    Note: keep in mind that you can use any Xcode specific
	          variables from project/build settings here.

	DISCLAIMER:

	    This program comes with ABSOLUTELY NO WARRANTY
	    and is provided "AS-IS". USE AT YOUR OWN RISK!

	LICENSE:

	    Licensed under the Apache License, Version 2.0 (the "License");
	    you may not use this file except in compliance with the License.
	    You may obtain a copy of the License at

	        http://www.apache.org/licenses/LICENSE-2.0

	    Unless required by applicable law or agreed to in writing, software
	    distributed under the License is distributed on an "AS IS" BASIS,
	    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	    See the License for the specific language governing permissions and
	    limitations under the License.


	SEE ALSO:
	    man plist(5)


