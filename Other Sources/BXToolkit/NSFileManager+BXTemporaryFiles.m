/* 
 Boxer is copyright 2010-2011 Alun Bestor and contributors.
 Boxer is released under the GNU General Public License 2.0. A full copy of this license can be
 found in this XCode project at Resources/English.lproj/GNU General Public License.txt, or read
 online at [http://www.gnu.org/licenses/gpl-2.0.txt].
 */


#import "NSFileManager+BXTemporaryFiles.h"
#import <errno.h>

NSString * const BXTemporaryFilesErrorDomain = @"BXTemporaryFilesErrorDomain";

@implementation NSFileManager (BXTemporaryFiles)

- (NSString *) createTemporaryDirectoryWithPrefix: (NSString *)namePrefix error: (NSError **)outError
{
	//Append a mkdtemp()-ready filename pattern in the standard temporary directory, using the specified name prefix
	NSString *nameFormat = [namePrefix stringByAppendingPathExtension: @"XXXXXXXX"];
	NSString *pathFormat = [NSTemporaryDirectory() stringByAppendingPathComponent: nameFormat];
	
	//TODO: catch if NSTemporaryDirectory() returned nil
	
	//Create a character buffer for the path format, which will be rewritten
	CFIndex maxTemplateLength = CFStringGetMaximumSizeOfFileSystemRepresentation((CFStringRef)pathFormat);
	
	char template[maxTemplateLength];
	CFStringGetFileSystemRepresentation((CFStringRef)pathFormat, template, maxTemplateLength);
	
	//Now, actually create the temporary directory. This will write the generated filename back into the buffer.
	char * result = mkdtemp(template);
	
	//An error occurred when generating the temporary directory, record the error number returned
	//TODO: match the errors generated by createDirectoryAtPath:error:
	if (result == NULL)
	{
		if (outError) *outError = [NSError errorWithDomain: BXTemporaryFilesErrorDomain code: errno userInfo: nil];
		return nil;
	}
	
	//Otherwise, return the final generated path
	NSString *finalPath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation: template length: strlen(template)];
	return finalPath;
}

@end