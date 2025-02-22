//
//  RecordSongViewController.h
//  GuitarPractice
//
//  Created by Jeff Smith on 2/22/25.
//  Copyright © 2025 GSSI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RecordSongViewController;

@protocol RecordSongViewControllerDelegate <NSObject>

- (void)RecordSongViewController:(RecordSongViewController *)controller
                  didComplete:(BOOL)didCancel;

@end

@interface RecordSongViewController : UIViewController
@property (nonatomic, weak) id <RecordSongViewControllerDelegate> delegate;
- (IBAction)returnTapped:(id)sender;

@end

NS_ASSUME_NONNULL_END
