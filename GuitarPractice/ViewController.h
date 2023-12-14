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

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,AVAudioPlayerDelegate>

@property AVAudioSession* audioSession;
@property AVAudioPlayer *appSoundPlayer;
@property MPMediaItem * currentSong;
@property NSURL *currentSongURL;
@property (nonatomic) MPMediaItemCollection      *userMediaItemCollection;
@property (nonatomic) MPMusicPlayerController    *musicPlayer;
@property MPMediaPickerController *picker;
@property int currentTime;
@property int beginTime;
@property int endTime;
@property NSMutableArray<NSNumber*> *beginTimes;
@property NSMutableArray<NSNumber*> *endTimes;
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
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIButton *playSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *loopSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *nextSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *priorSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *currentPositionLabel;
- (IBAction)sliderExit:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

