//
//  UIImageView+Network.h
//
//  Adapted by Rafael Reis (@orafaelreis)
//  Originally created by Soroush Khanlou (@khanlou)
//

#import <UIKit/UIKit.h>

@interface UIImageView(Network)

@property (nonatomic, copy) NSURL *imageURL;

- (void) loadImageFromURL:(NSURL*)url placeholderImage:(UIImage*)placeholder;

@end