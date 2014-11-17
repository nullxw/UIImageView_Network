//
//  UIImageView+Network.m
//
//  Adapted by Rafael Reis (@orafaelreis)
//  Originally created by Soroush Khanlou (@khanlou)
//
//

#import "UIImageView+Network.h"
#import <objc/runtime.h>

static char URL_KEY;


@implementation UIImageView(Network)

@dynamic imageURL;

- (void) loadImageFromURL:(NSURL*)url placeholderImage:(UIImage*)placeholder{
	self.imageURL = url;
	self.image = placeholder;

    NSString *file = [self cachePathFromImageUrl: url.absoluteString];
	NSData *cachedData = [self cachedImageOrNilAtPath: file];
	if (cachedData) {
        self.imageURL = nil;
        self.image = [UIImage imageWithData:cachedData];
        return;
	}

	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		NSData *data = [NSData dataWithContentsOfURL:url];

		UIImage *imageFromData = [UIImage imageWithData:data];

        [data writeToFile:file atomically:YES];//saving file

		if (imageFromData) {
			if ([self.imageURL.absoluteString isEqualToString:url.absoluteString]) {
				dispatch_sync(dispatch_get_main_queue(), ^{
					self.image = imageFromData;
				});
			}
		}
		self.imageURL = nil;
	});
}

- (void) setImageURL:(NSURL *)newImageURL {
	objc_setAssociatedObject(self, &URL_KEY, newImageURL, OBJC_ASSOCIATION_COPY);
}

- (NSURL*) imageURL {
	return objc_getAssociatedObject(self, &URL_KEY);
}


-(NSString* ) cachePathFromImageUrl :(NSString *) url{
    NSString *path = [NSString stringWithFormat:@"%@/Images", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *file = [url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	file = [file stringByReplacingOccurrencesOfString:@"\\" withString:@"_"];
	file = [file stringByReplacingOccurrencesOfString:@":" withString:@"_"];
	file = [NSString stringWithFormat:@"%@/%@", path, file];
    return file;
}


-(NSData*) cachedImageOrNilAtPath: (NSString *) file
{
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:file];
    if (exists){
        return [NSData dataWithContentsOfFile:file];
    }
    return nil;
}

@end