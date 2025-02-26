//
//  RecordSongViewController.h
//  GuitarPractice
//
//  Created by Jeff Smith on 2/22/25.
//  Copyright © 2025 GSSI. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Foundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@class RecordSongViewController;

@protocol RecordSongViewControllerDelegate <NSObject>

- (void)RecordSongViewController:(RecordSongViewController *)controller
                  didComplete:(BOOL)didCancel;

@end

@interface RecordSongViewController : UIViewController <AVAudioPlayerDelegate,AVAudioRecorderDelegate>
@property (nonatomic, weak) id <RecordSongViewControllerDelegate> delegate;
@property NSURL *currentSongURL;
- (IBAction)recordTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)returnTapped:(id)sender;
@property NSString * recorderFilePath;
@end

NS_ASSUME_NONNULL_END
