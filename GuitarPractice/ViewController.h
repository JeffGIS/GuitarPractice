//
//  ViewController.h
//  GuitarPractice
//
//  Created by Jeff Smith on 1/18/20.
//  Copyright © 2020 GSSI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CCodeLibrary/CCodeLibrary.h"

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,AVAudioPlayerDelegate,UIImagePickerControllerDelegate>

@property int currentSegment;
@property NSTimer *timer;
@property sqlite3nv *database;
@property (atomic) BOOL isOpen;
@property BOOL inLoop;


- (IBAction)selectSongTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLable;
- (IBAction)nextSongTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)markEndTapped:(id)sender;
- (IBAction)markBeginTapped:(id)sender;
- (IBAction)playSegmentTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)loopSegmentTapped:(id)sender;
- (IBAction)nextSegmentTapped:(id)sender;
- (IBAction)priorSegmentTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *ImageDisplay;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIButton *playSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *loopSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *nextSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *priorSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *selectSongButton;
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *selectYouTubeVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *saveImageButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelImageButton;
@property (weak, nonatomic) IBOutlet UIButton *priorFileButton;
@property (weak, nonatomic) IBOutlet UIButton *nextFileButton;
@property (weak, nonatomic) IBOutlet UILabel *startTimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *startTimeMinutesTitle;
@property (weak, nonatomic) IBOutlet UILabel *startTimeSecondsTitle;
@property (weak, nonatomic) IBOutlet UITextField *startTimeMinutesInput;
@property (weak, nonatomic) IBOutlet UITextField *startTimeSecondsInput;
@property (weak, nonatomic) IBOutlet UIStepper *startTimeMinutesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *startTimeSecondsStepper;
@property (weak, nonatomic) IBOutlet UIButton *startTimeSaveButton;
@property (weak, nonatomic) IBOutlet UIButton *startTimeCancelButton;
@property (weak, nonatomic) IBOutlet UILabel *currentCollectionLabel;
- (IBAction)startTimeCancelTapped:(id)sender;
- (IBAction)saveYouTubeTapped:(id)sender;
- (IBAction)selectCollectionTapped:(id)sender;
- (IBAction)nextFileTapped:(id)sender;
- (IBAction)priorFileTapped:(id)sender;
- (IBAction)saveImagePicked:(id)sender;
- (IBAction)cancelImagePicked:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)selectYouTubeVideo:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *currentPositionLabel;
- (IBAction)sliderExit:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

