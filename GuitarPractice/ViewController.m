//
//  ViewController.m
//  GuitarPractice
//
//  Created by Jeff Smith on 1/18/20.
//  Copyright © 2020 GSSI. All rights reserved.
//
// https://developers.google.com/youtube/v3/guides/ios_youtube_helper
//https://developers.google.com/youtube/v3/code_samples/apps-script#search_by_keyword
#import "ViewController.h"
#import "CCodeLibrary/NVPopoverTableView.h"
#import "CCodeLibrary/StringFunctions.h"
#import "EffectsViewController.h"

typedef NS_ENUM(NSInteger, SongTypes)
{
    SONG,
    YOUTUBEVIDEO,
};
@interface ViewAndStatus : NSObject
@property UIView *view;
@property BOOL status;
@end
@implementation ViewAndStatus
@synthesize view;
@synthesize status;

- (id)init
{
    self = [super init];
    return self;
}
@end

@interface ViewController ()
@property AVAudioSession* audioSession;
@property AVAudioPlayer *appSoundPlayer;
@property AVAudioPlayer *saveSoundPlayer;
@property AVAudioRecorder *appSoundRecorder;
@property MPMediaItem * currentSong;
@property int currentSongDuration;
@property NSURL *currentSongURL;
@property (nonatomic) MPMediaItemCollection      *userMediaItemCollection;
@property (nonatomic) MPMusicPlayerController    *musicPlayer;
@property MPMediaPickerController *picker;
@property int currentTime;
@property float beginTime;
@property float endTime;
@property float timerInterval;
@property int currentSongStartTime;
@property NSMutableArray<NSNumber*> *beginTimes;
@property NSMutableArray<NSNumber*> *endTimes;
@property NSMutableArray<NSNumber*> *linkPrefixes;
@property NSString *collectionsDirectory;
@property NSString *linksDirectory;
@property int currentLinkPrefix;
@property UIImage *image;
@property UIImage *currentImage;
@property NSString * currentSongTitle;
@property int numFilesForCurrentLink;
@property NSString *currentLinkFile;
@property int currentFileNum, currentNumFiles;
@property NVWebView * webView;
@property NSString *currentCollection;
@property NSString * currentYouTubeLink;
@property NSString * YouTubeName;
@property SongTypes currentSongType;
@property float currentYTTime;
@property BOOL startingNewVideo;
@property BOOL startingExistingVideo;
@property int clipEditStatus;
@property int currentSegment;
@property NSTimer *timer;
@property NSTimer *leadInTimer;
@property int maxLeadInTicks;
@property NSTimer *recordTimer;
@property float recordTime;
@property float maxRecordTime;
@property sqlite3nv *database;
@property (atomic) BOOL isOpen;
@property BOOL inLoop;
@property NSMutableArray *allViewsArray;
@property NSMutableArray *allViewsAndStatusArray;
@property UITapGestureRecognizer *tapGestureRecognizer;
@property int highlightPointNumber;
@property CGPoint highlightPoint1, highlightPoint2;
@property CGRect highlightRect;
@property int numHighlightLines;
@property BOOL inFullScreen;
@property SystemSoundID leadInTick;
@property BOOL recording;
@property int leadInCount;
@property NSString *playbackFile;
@property BOOL StopRecording;
@property BOOL recordingNewSong;
@property NSString *NewSongFile;
@property BOOL playerIsPlaying;
@property BOOL monOn;

@property NSMutableDictionary *recordSetting;
@property NSMutableDictionary *editedObject;
@property NSString *recorderFilePath;
@property AVAudioRecorder *recorder;

@property SystemSoundID soundID;
//@property(nonatomic,strong) AVAudioEngine *AVaudioEngine;
@property AudioEngine * audioEngine;

@end

@interface ViewController () <NVPopoverTableViewDelegate, NVWebViewDelegate>
@property NSData *imageData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
        [self setMusicPlayer: [MPMusicPlayerController applicationMusicPlayer]];
        
        // By default, an application music player takes on the shuffle and repeat modes
        //        of the built-in iPod app. Here they are both turned off.
        [_musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [_musicPlayer setRepeatMode: MPMusicRepeatModeNone];

    _timerInterval = 0.1;
    [self registerForMediaPlayerNotifications];

    //[self setupApplicationAudio];
    _beginTime = 86;
    [self setSliderValue:0];
    _currentSongTitle = @"";
    BOOL opened = [self open];
    [self close:opened];
    [self createCollection:@"Blues Guitar"];
    [self createCollection:@"Rock Guitar"];
    [self createCollection:@"Acoustic Guitar"];
    [self createCollection:@"Base Guitar"];
    [self createCollection:@"Ukulele"];
    [self createCollection:@"Songs"];
    _currentCollectionLabel.text = _currentCollection;

    _playbackFile = [NSTemporaryDirectory() stringByAppendingString:@"mixerOutput.caf"];
    self.playerView.delegate = self;
    [self createAllViewsArray];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [_ImageDisplay addGestureRecognizer:_tapGestureRecognizer];
    _tapGestureRecognizer.delegate = self;
    _numHighlightLines = 1;
    _inFullScreen = NO;
    _maxLeadInTicks = 2;
    _effectsArray = NSMutableArray.new;
    EffectsData *efdata = EffectsData.new;
    [efdata setTypeAndID:REVERB ID:0];
    efdata.wetDrySlider.value = 0;
    efdata.reverb.wetDryMix = 0;
    [_effectsArray addObject:efdata];
    NSString *soundFile = [NSString stringWithUTF8String:"///System/Library/Audio/UISounds/begin_record.caf"];
    NSURL *url = [NSURL URLWithString:soundFile];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &_leadInTick);

}
- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:_ImageDisplay];
    switch (_highlightPointNumber)
    {
        case 1:
            _highlightPoint1 = location;
            _highlightPointNumber++;
            [_imageHighlightInstructions setText:@"Tap end point"];
            break;
        case 2:
            _highlightPoint2 = location;
            _highlightRect = _ImageDisplay.frame;
            [self createHighlight:_highlightPoint1
                           point2:_highlightPoint2
                         numLines:_numHighlightLines
                           inView:_ImageDisplay
                         doUpdate:YES];
            break;
        default:
            break;
    }
    return;
}

-(void) createAllViewsArray
{
    _allViewsArray = NSMutableArray.new;
    [_allViewsArray addObject:_songTitleLable];
    [_allViewsArray addObject:_ImageDisplay];
    [_allViewsArray addObject:_fullScreenImageDisplay];
    [_allViewsArray addObject:_fullScreenButton];
    [_allViewsArray addObject:_fullScreenReturnButton];
    [_allViewsArray addObject:_playButton];
    [_allViewsArray addObject:_beginButton];
    [_allViewsArray addObject:_endButton];
    [_allViewsArray addObject:_playSegmentButton];
    [_allViewsArray addObject:_loopSegmentButton];
    [_allViewsArray addObject:_nextSegmentButton];
    [_allViewsArray addObject:_priorSegmentButton];
    [_allViewsArray addObject:_saveButton];
    [_allViewsArray addObject:_pauseButton];
    [_allViewsArray addObject:_selectPhotoButton];
    [_allViewsArray addObject:_saveImageButton];
    [_allViewsArray addObject:_cancelImageButton];
    [_allViewsArray addObject:_priorFileButton];
    [_allViewsArray addObject:_nextFileButton];
    [_allViewsArray addObject:_startTimeTitle];
    [_allViewsArray addObject:_startTimeMinutesTitle];
    [_allViewsArray addObject:_startTimeSecondsTitle];
    [_allViewsArray addObject:_startTimeMinutesInput];
    [_allViewsArray addObject:_startTimeSecondsInput];
    [_allViewsArray addObject:_startTimeMinutesStepper];
    [_allViewsArray addObject:_startTimeSecondsStepper];
    [_allViewsArray addObject:_startTimeSaveButton];
    [_allViewsArray addObject:_startTimeCancelButton];
    [_allViewsArray addObject:_currentCollectionLabel];
    [_allViewsArray addObject:_linkName];
    [_allViewsArray addObject:_linkNameLabel];
    [_allViewsArray addObject:_playerView];
    [_allViewsArray addObject:_linkURLField];
    [_allViewsArray addObject:_linkURLLabel];
    [_allViewsArray addObject:_pasteURLButton];
    [_allViewsArray addObject:_gotoYouTubeButton];
    [_allViewsArray addObject:_sliderTextLabel];
    [_allViewsArray addObject:_continueButton];
    [_allViewsArray addObject:_stepAheadButton];
    [_allViewsArray addObject:_stepBackButton];
    [_allViewsArray addObject:_clipButton];
    [_allViewsArray addObject:_tapToEditLabel];
    [_allViewsArray addObject:_cancelEditButton];
    [_allViewsArray addObject:_changeBeginButton];
    [_allViewsArray addObject:_changeEndButton];
    [_allViewsArray addObject:_numClipsLabel];
    [_allViewsArray addObject:_deleteClipButton];
    [_allViewsArray addObject:_slider];
    [_allViewsArray addObject:_addImageHighlightButton];
    [_allViewsArray addObject:_imageHighlightInstructions];
    [_allViewsArray addObject:_highlightLinesLabel];
    [_allViewsArray addObject:_highlightLinesStepper];
    [_allViewsArray addObject:_delaySwitch];
    [_allViewsArray addObject:_recordSwitch];
    [_allViewsArray addObject:_delayLabel];
    [_allViewsArray addObject:_recordLabel];

}
-(void) hideAllViews:(BOOL)hide
{
    if (hide)
    {
        _allViewsAndStatusArray = NSMutableArray.new;
        for (UIView *view in _allViewsArray)
        {
            ViewAndStatus *vands = ViewAndStatus.new;
            vands.view = view;
            vands.status = view.isHidden;
            [_allViewsAndStatusArray addObject:vands];
            [view setHidden:hide];
        }
    }
    else
    {
        for (ViewAndStatus *vands in _allViewsAndStatusArray)
        {
            [vands.view setHidden:vands.status];
        }
    }
}

- (void) playLeadInTick:(NSTimer *)timer
{
    _leadInCount++;
    if (_leadInCount > _maxLeadInTicks)
    {
        double recordTime = _endTime - _beginTime;
        [timer invalidate];
        [self startRecording:recordTime
                      toFile:_playbackFile];
        return;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fileName = @"test.wav";
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        NSURL* fileURL = [NSURL URLWithString:filePath];
        NSError *error=nil;
        NSMutableDictionary *recordSetting = NSMutableDictionary.new;

        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];

        [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

        
        BOOL st = [_appSoundRecorder initWithURL:fileURL settings:recordSetting error:&error];
        st = [_appSoundRecorder prepareToRecord];
        st = [_appSoundRecorder recordForDuration:recordTime];
    }
    else
        AudioServicesPlaySystemSound(_leadInTick);
}
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self playRecording:self.recorderFilePath];
    }];

    return;
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    return;
}

- (void)playerView:(nonnull YTPlayerView *)playerView didPlayTime:(float)playTime
{
    _currentYTTime = playTime;
    [playerView duration: ^(double result,NSError *err) {

        self.currentSongDuration = result;
        NSString *mess = [NSString stringWithFormat:@"At time:%f with duration %i",playTime,self.currentSongDuration];
        NSLog (@"%@", mess);
        if (self.startingNewVideo)
        {
            self.startingNewVideo = NO;
            self.beginTime = self.currentYTTime;
            [self saveSongURL:self.currentYouTubeLink
                     forTitle:self.YouTubeName
                       ofType:YOUTUBEVIDEO
                     duration:self.currentSongDuration
                    startTime:self.currentYTTime];
            [self retrieveSong:self.YouTubeName setTimes:YES];
            self.slider.maximumValue = self.currentSongDuration;
            self.slider.minimumValue = 0;

        }
        self.currentSongTitle = self.YouTubeName;
        [self updateSongLabel];
   }];
/*    if (_inLoop && playTime > _endTime)
    {
        [self.playerView pauseVideo];
        [self.playerView seekToSeconds:_beginTime allowSeekAhead:YES];
        [self.playerView playVideo];
        [self setSliderValue:_beginTime];
    }
    else
        [self setSliderValue:playTime];*/
    if (self.startingExistingVideo)
    {
        self.startingExistingVideo = NO;
        [self.playerView pauseVideo];
    }
}
- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    NSLog (@"player state %i",state);
    switch (state)
    {
        case kYTPlayerStatePlaying:
            NSLog(@"Started playback");
            _playerIsPlaying = TRUE;
            break;
        case kYTPlayerStatePaused:
            NSLog(@"Paused playback");
            _playerIsPlaying = FALSE;
            break;
        case kYTPlayerStateEnded:
            NSLog(@"Ended playback");
            _playerIsPlaying = FALSE;
        default:
            break;
    }
}

-(BOOL) createCollection:(NSString *)name
{
    _currentCollection = name;
    [self open];
    [self close:TRUE];
    return TRUE;
}
- (void) setSliderValue:(float) value
{
    NSString *sliderText = [NSString stringWithFormat:@"%.1f",value];
    [_sliderTextLabel setText:sliderText];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self->_slider setValue:value];
        [self->_sliderTextLabel setText:sliderText];
    }];
}

-(void) setSliderRange
{
    NSString * sliderText = [NSString stringWithFormat:@"%.1f to %.1f",_beginTime,_endTime];
    [_sliderTextLabel setText:sliderText];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self->_sliderTextLabel setText:sliderText];
    }];


}
-(NSArray *) getAllCollections
{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *allCollections = [filemgr contentsOfDirectoryAtPath: _collectionsDirectory error: nil];
    NSArray *sorted = [allCollections sortedArrayUsingSelector:@selector(compare:)];
    return sorted;
}
- (IBAction) showMediaPicker
{

    _picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    
    _picker.delegate                        = self;
    _picker.allowsPickingMultipleItems    = NO;
    _picker.prompt                        = NSLocalizedString (@"Select a song", @"Prompt to user to choose some songs to play");
    _picker.showsCloudItems = NO;
    _picker.showsItemsWithProtectedAssets = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];

    [self presentViewController: _picker animated:YES completion:nil];
}

- (IBAction)selectSongTapped:(id)sender
{
    NSMutableArray *optionList = NSMutableArray.array;

    [optionList addObject:@"Add New Song"];
    [optionList addObject:@"Record New Song"];
    [optionList addObject:@"Add New YouTube Video"];
    [optionList addObject:@"________________________"];
    [self addSongsToList:optionList];
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:_currentCollection
                                                                     textArray:optionList
                                                                 includeCancel:YES];
    nvptv.identifier = @"Select Song";
    nvptv.allowsSubtitle = NO;
}

- (void)popoverTableViewDidCancel:(NVPopoverTableView *)popoverTableView
{
    [popoverTableView hide:YES];
}
- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
                 atIndex:(NSInteger)index
{
    if ([text isEqual:@"Add New Song"])
    {
        [popoverTableView hide:YES];
        [self addNewSong];
    }
    else if ([text isEqual:@"Record New Song"])
    {
        [popoverTableView hide:YES];
        [self recordNewSong];
    }
    else if ([text isEqual:@"Add New Collection"])
    {
        [popoverTableView hide:YES];
        [self addNewSong];
    }
    else if ([text isEqual:@"Add New YouTube Video"])
    {
        [_gotoYouTubeButton setHidden:NO];
        [popoverTableView hide:YES];
        [_linkURLField setHidden:NO];
        [_linkURLLabel setHidden:NO];
        [_linkName setHidden:NO];
        [_linkNameLabel setHidden:NO];
        [_playerView setHidden:YES];
        [_ImageDisplay setHidden:YES];
        [_addImageHighlightButton setHidden:YES];
        [_imageHighlightInstructions setHidden:YES];
        [_highlightLinesLabel setHidden:YES];
        [_highlightLinesStepper setHidden:YES];
        [_startTimeSaveButton setHidden:NO];
        [_startTimeCancelButton setHidden:NO];
        [_pasteURLButton setHidden:NO];
        
    }
    else if (stringBeginsWithString (popoverTableView.title,@"Verify Delete"))
    {
        [popoverTableView hide:YES];
        if ([text isEqual:@"Yes"])
        {
            [self deleteClip:_currentLinkPrefix];
        }
    }
    else if ([popoverTableView.identifier isEqual:@"Select Song"])
    {
        NSString * url = [self getSong:text];
        if (url)
        {
            [popoverTableView hide:YES];
            [_beginButton setEnabled:YES];
            [_endButton setEnabled:NO];
            if (_currentSongType == SONG)
            {
                _currentSongURL = [NSURL URLWithString:url];
                if (![self startNewSong])
                    showAlert(@"Unable to access this song");
            }
            else
            {
                _currentYouTubeLink = url;
                [self displayYouTubeVideo:_currentYouTubeLink];
            }
        }
    }
    else if ([popoverTableView.identifier isEqual:@"Select Collection"])
    {
        _currentCollection = text;
        _currentCollectionLabel.text = _currentCollection;
        [popoverTableView hide:YES];
        [self selectSongTapped:nil];
    }
}
- (void) addNewSong
{
    [_appSoundPlayer stop];
    [self setSliderValue:0];
    _inLoop = NO;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    [self showMediaPicker];
    [self setCurrentPositiion:NO];
}

- (void) recordNewSong
{
    NSError *error;
    _NewSongFile = [NSTemporaryDirectory() stringByAppendingString:@"newSongFile.caf"];
    [NSFileManager.defaultManager removeItemAtPath:_NewSongFile
                                             error:&error];
    NSURL *newSongURL = [NSURL URLWithString:_NewSongFile];
    _recordingNewSong = TRUE;
    [_continueButton setHidden:YES];
    [_pauseButton setHidden:NO];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    RecordSongViewController *recordSongVC = [storyboard instantiateViewControllerWithIdentifier:@"RecordSongViewController"];
    recordSongVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    recordSongVC.delegate = self;
    recordSongVC.currentSongURL = newSongURL;
    [self presentViewController:recordSongVC animated:YES completion:nil];
    return;

}
- (void) addNewYouTube
{
    [self displayYouTubeVideo:@"4QfDDsvoLi8?si"];
    
}

- (IBAction)nextSongTapped:(id)sender {
    NSString * url = [self getNextSong];
    if (url)
    {
        _currentSongURL = [NSURL URLWithString:url];
        [self startNewSong];
    }
    else
    {
        _currentSongTitle = @"";
        url = [self getNextSong];
        if (url)
        {
            _currentSongURL = [NSURL URLWithString:url];
            [self startNewSong];
        }
    }
}


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    // Apply the chosen songs to the music player's queue.
    //[self updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
    if (mediaItemCollection.items.count == 1)
    {
        _currentSong = mediaItemCollection.items[0];
        _currentSongTitle = _currentSong.title;
        _currentSongURL = [_currentSong valueForProperty:MPMediaItemPropertyAssetURL];
        _currentSongDuration = IDNINT(_currentSong.playbackDuration);
        NSString * url = [_currentSongURL absoluteString];
        if ([self startNewSong])
        {
            [self saveSongURL:url
                     forTitle:_currentSongTitle
                       ofType:SONG
                     duration:_currentSongDuration
                    startTime:0];
        }
        else
        {
            showAlert(@"Unable to access this song");
        }
    }
    [_picker dismissViewControllerAnimated:YES completion:nil] ;
    return;
}
void showAlert(NSString *text)
{
    [CRAPI.sharedInstance performSelector:@selector(showAlert:)
                               withObject:text
                               afterDelay:0.5];
}

- (void) startNewYouTubeVideo:(NSString *)URL
{
    _slider.maximumValue = _currentSongDuration;
    _slider.minimumValue = 0;
    _slider.continuous = YES;
    _currentTime = 0;
    _beginTime = _currentTime;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    _currentSegment = -1;
    _playButton.enabled=YES;
    _beginButton.enabled=YES;
    _endButton.enabled=YES;
    [self updateClipButtons];
    [_saveButton setEnabled:NO];
    _currentSongType = YOUTUBEVIDEO;
    _startingNewVideo = YES;
    if ([self displayYouTubeVideo:URL])
    {
        _startingExistingVideo =YES;
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(playTapped:) userInfo:nil repeats:NO];
    }
}
- (IBAction)pasteURLTapped:(id)sender {
    UIPasteboard *thePasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteboardString = thePasteboard.string;
    _linkURLField.text = pasteboardString;
    
}

- (IBAction)gotoYouTubeTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=g7xM4QD2v2s"]];
    
}

- (IBAction)continueTapped:(id)sender {
    BOOL rtn=FALSE;
    if (_currentSegment < 0)
    {
        _beginTime = _currentSongStartTime;
        _endTime = _currentSongDuration;
    }
    switch (_currentSongType)
    {
        case SONG:
            rtn = [_appSoundPlayer play];
            if (rtn)
            {
                [_continueButton setHidden:YES];
                [_pauseButton setHidden:NO];
                [_timer invalidate];
                _timer = [NSTimer scheduledTimerWithTimeInterval:_timerInterval target:self selector:@selector(checkTime:) userInfo:nil repeats:YES];
            }
            else
                showAlert(@"Unable to access this song");
            break;
        case YOUTUBEVIDEO:
            [_pauseButton setHidden:NO];
            [_continueButton setHidden:YES];
            [self.playerView playVideo];
            [_timer invalidate];
            _timer = [NSTimer scheduledTimerWithTimeInterval:_timerInterval target:self selector:@selector(checkTime:) userInfo:nil repeats:YES];
            break;
    }
}
- (IBAction)changeBeginTapped:(id)sender {
    [_stepBackButton setHidden:NO];
    [_stepAheadButton setHidden:NO];
    [_changeBeginButton setSelected:YES];
    [_changeEndButton setSelected:NO];
    _clipEditStatus = 1;
}

- (IBAction)changeEndTapped:(id)sender {
    [_stepBackButton setHidden:NO];
    [_stepAheadButton setHidden:NO];
    [_changeBeginButton setSelected:NO];
    [_changeEndButton setSelected:YES];
    _clipEditStatus = 2;
}

- (IBAction)stepAheadTapped:(id)sender {
    switch (_clipEditStatus)
    {
        case 1:
            _beginTime += 0.1;
            break;
        case 2:
            _endTime += 0.1;
            break;
    }
    [_saveButton setEnabled:YES];
    
    [self setSliderRange];
}

- (IBAction)stepBackTapped:(id)sender {
    switch (_clipEditStatus)
    {
        case 1:
            _beginTime -= 0.1;
            break;
        case 2:
            _endTime -= 0.1;
            break;
    }
    [_saveButton setEnabled:YES];
    
    [self setSliderRange];
}
- (IBAction)markBeginTapped:(id)sender {
    if (_currentSongType == SONG)
        _beginTime = _appSoundPlayer.currentTime;
    else
        _beginTime = _currentYTTime;
    [_endButton setEnabled:YES];
    [_endButton setHidden:NO];
    _tapToEditLabel.text = @"Tap Mark End to End the Clip";

}
- (IBAction)markEndTapped:(id)sender
{
    _tapToEditLabel.text = @"Tap Mark Begin to Add a Clip";

    _currentLinkPrefix = -1;
    if (_currentSongType == SONG)
        _endTime = _appSoundPlayer.currentTime;
    else
        _endTime = _currentYTTime;
    NSNumber *bTime = [NSNumber numberWithInt:_beginTime];
    NSNumber *eTime = [NSNumber numberWithInt:_endTime];
    [_endTimes addObject:eTime];
    [_beginTimes addObject:bTime];
    _currentSegment = (int)_endTimes.count - 1;
    BOOL opened = [self open];
    NSString *title2 = [_currentSongTitle stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO CLIPS (TITLE,STARTTIME,ENDTIME) VALUES('%@',%i,%i)",title2,IDNINT(10*_beginTime),IDNINT(10*_endTime)];
    [self executeCmd:cmd];
    NSString *query = [NSString stringWithFormat:@"SELECT ID FROM CLIPS WHERE Title = '%@' AND STARTTIME = %i AND ENDTIME = %i",title2,IDNINT(10*_beginTime),IDNINT(10*_endTime)];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        _currentLinkPrefix = sqlite3_column_int(statement, 0);
        NSNumber *linkPrefix = [NSNumber numberWithInt:_currentLinkPrefix];
        [_linkPrefixes addObject:linkPrefix];
        _numFilesForCurrentLink = 0;
        
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
    
    [self close:opened];
    _beginTime = _endTime;
    [self retrieveSong:title2 setTimes:NO];
    [self updateNumClipsLabel];
    [self updateClipButtons];
    
}


- (IBAction)tunerButtonTapped:(id)sender {
    [self launchTuner];
    
}
- (void)launchTuner
{
    NSError *error;
    NSString *tunerURL = @"NVTuner://";
    NSString *instrument = @"6 String Guitar";
    NSString *tuning = @"Standard";
    NSString *capo = @"None";
    NSString *tunerParms = [NSString stringWithFormat:@"%@:%@:%@",instrument,tuning,capo];
    [SharedDefaults.defaults saveString:@"RiffMaster:" forKey:@"TunerSourceApplication"];
    [SharedDefaults.defaults saveString:instrument forKey:@"TunerInstrument"];
    [SharedDefaults.defaults saveString:tuning forKey:@"TunerTuning"];
    [SharedDefaults.defaults saveString:capo forKey:@"TunerCapo"];
    NSString *path = UserDefaults.defaults.sharedFilePath;
    NSString *file = [path stringByAppendingPathComponent:@"TunerParms.txt"];
    NSURL *url = [NSURL fileURLWithPath:file];
    if ([tunerParms writeToURL:url atomically:TRUE encoding:NSUTF8StringEncoding error:&error])
    {
        NSDictionary *optionsDict = NSDictionary.new;
        
        if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:tunerURL]])
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:tunerURL] options:optionsDict completionHandler:nil];
        else
        {
            //tunerURL = @"https://itunes.apple.com/us/app/newvision-flyover/id1105410284";

            if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:tunerURL]])
                [UIApplication.sharedApplication openURL:[NSURL URLWithString:tunerURL] options:optionsDict completionHandler:nil];
            
            else
            {
                NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                                  delegate:self
                                                                     title:@"RiffMaster cannot launch NVTuner App"
                                                           buttonTextArray:@[@"OK"]
                                                          destructiveIndex:0];
                
                alert.identifier = @"CannotLaunchTunerApp";
            }
        }

    }
    else
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:self
                                                             title:[NSString stringWithFormat:@"RiffMaster cannot write tuner parameter file\n%@",error.localizedDescription]
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
    }
    
    
    
    //NSFileManager *filemgr = [NSFileManager defaultManager];

    //NSURL *url = [filemgr.containerURL(forSecurityApplicationGroupIdentifier: @"group.com.gssi.appgroup")];
}
- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:TRUE];
    return;
}

- (IBAction)monitorVolumeChanged:(UISlider*)sender {
    [_audioEngine setOutputVolume:sender.value];
}

- (IBAction)saveTapped:(id)sender {
    _clipEditStatus = 0;
    [_beginButton setHidden:NO];
    [_endButton setHidden:NO];
    [_changeEndButton setHidden:YES];
    [_changeBeginButton setHidden:YES];
    [_saveButton setEnabled:NO];
    [_cancelEditButton setEnabled:NO];
    [_saveButton setHidden:YES];
    [_cancelEditButton setHidden:YES];
    [_deleteClipButton setHidden:YES];
    [_selectPhotoButton setHidden:YES];
    [_priorSegmentButton setHidden:NO];
    [_nextSegmentButton setHidden:NO];
    [_playSegmentButton setHidden:NO];
    [_loopSegmentButton setHidden:NO];

    BOOL opened = [self open];
    NSString *title2 = [_currentSongTitle stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE CLIPS SET STARTTIME=%i,ENDTIME=%i WHERE ID=%i",IDNINT(10*_beginTime),IDNINT(10*_endTime),_currentLinkPrefix];
    [self executeCmd:cmd];
    [self retrieveSong:title2 setTimes:NO];

}


- (IBAction)cancelEditTapped:(id)sender {
    _clipEditStatus = 0;
    [_beginButton setHidden:NO];
    [_endButton setHidden:NO];
    [_changeEndButton setHidden:YES];
    [_changeBeginButton setHidden:YES];
    [_saveButton setEnabled:NO];
    [_cancelEditButton setEnabled:NO];
    [_saveButton setHidden:YES];
    [_cancelEditButton setHidden:YES];
    [_deleteClipButton setHidden:YES];
    [_selectPhotoButton setHidden:YES];
    [_priorSegmentButton setHidden:NO];
    [_nextSegmentButton setHidden:NO];
    [_playSegmentButton setHidden:NO];
    [_loopSegmentButton setHidden:NO];

    [self setCurrentPositiion:NO];
}

- (IBAction)clipButtonTapped:(id)sender {
    [_timer invalidate];
    _timer = nil;
    [_loopSegmentButton setSelected:NO];
    [_playSegmentButton setSelected:NO];
    [_beginButton setHidden:YES];
    [_endButton setHidden:YES];
    [_changeEndButton setHidden:NO];
    [_changeBeginButton setHidden:NO];
    [_changeBeginButton setSelected:NO];
    [_changeEndButton setSelected:NO];
    [_cancelEditButton setEnabled:YES];
    [_cancelEditButton setHidden:NO];
    [_saveButton setHidden:NO];
    [_saveButton setEnabled:YES];
    [_deleteClipButton setEnabled:YES];
    [_selectPhotoButton setHidden:NO];
    [_priorSegmentButton setHidden:YES];
    [_nextSegmentButton setHidden:YES];
    [_playSegmentButton setHidden:YES];
    [_loopSegmentButton setHidden:YES];
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer pause];
        _appSoundPlayer.currentTime = 0;
        [self setCurrentPositiion:NO];
        [self setSliderRange];
    }
    else
    {
        [self.playerView pauseVideo];
        [self setSliderRange];
    }
    [_tapToEditLabel setHidden:YES];
    NSString *labelText = [NSString stringWithFormat:@"Edit Clip %i",_currentSegment+1];
    [_clipButton setTitle:labelText forState:UIControlStateNormal];
    _clipEditStatus = 1;
    
}

- (BOOL) startNewSong
{
    [self updateSongLabel];
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *error = nil;
    
/*
    // *** create AVAsset using URL ***
    AVAsset *asset = [AVAsset assetWithURL:_currentSongURL];

    // *** Create AVPlayerItem using AVAsset ***
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];

    // *** Initialise AVPlayer ***
    AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:playerItem];

    // *** Add AVPlayer to ViewController ***
    AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    avPlayerLayer.frame = CGRectMake(500, 500, 320, 480);
    [avPlayerLayer setBackgroundColor:[UIColor grayColor].CGColor];
    [self.view.layer addSublayer:avPlayerLayer];

    // *** Start Playback ***
    [avPlayer play];
    return TRUE;
    // *** Register for playback end notification ***
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[avPlayer currentItem]];

    // *** Register observer for events of AVPlayer status ***
    [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    return TRUE;
    
    AVPlayer *avp = AVPlayer.new;
    [avp initWithURL:_currentSongURL];
    [avp play];
    return TRUE;
    */
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: _currentSongURL error:&error];
    if (error)
    {
        NSLog(@"Player ERROR: %@", error.localizedDescription);
        return FALSE;
    }
     _appSoundPlayer = newPlayer;
   
     // "Preparing to play" attaches to the audio hardware and ensures that playback
     //        starts quickly when the user taps Play
     [_appSoundPlayer prepareToPlay];
     [_appSoundPlayer setVolume: 1.0];
     [_appSoundPlayer setDelegate: self];
    _slider.maximumValue = _currentSongDuration;
    _slider.minimumValue = 0;
    _slider.continuous = YES;
    _currentTime = _appSoundPlayer.currentTime;
    _beginTime = _currentTime;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    _currentSegment = -1;
    [_playButton setEnabled:YES];
    [_beginButton setEnabled:YES];
    [_endButton setHidden:YES];
    [self updateClipButtons];
    [_saveButton setEnabled:NO];
    _selectPhotoButton.enabled=YES;
    _selectYouTubeVideoButton.enabled=YES;
    [self retrieveSong:_currentSongTitle setTimes:YES];
    [_clipButton setTitle:@"" forState:UIControlStateNormal];
    [_clipButton setHidden:YES];
    //[_tapToEditLabel setHidden:YES];
    //[self playTapped:nil];
    return TRUE;
}
- (IBAction)playTapped:(id)sender {
    _inLoop = NO;
    _currentSegment = -1;
    _beginTime = _currentSongStartTime;
    _endTime = _currentSongDuration;
    [self updateClipButtons];
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
        _appSoundPlayer.currentTime = 0;
        [self setCurrentPositiion:YES];
    }
    else
    {
        [self.playerView pauseVideo];
        [self.playerView seekToSeconds:_currentSongStartTime allowSeekAhead:YES];
    }
    [_loopSegmentButton setSelected:NO];
    [_playSegmentButton setSelected:NO];
    [self continueTapped:nil];
}

- (void) saveSongURL:(NSString *)url
            forTitle:(NSString *)title
              ofType:(SongTypes)type
            duration:(int)duration
           startTime:(int)startTime
{
    BOOL opened = [self open];
    NSString *title2 = [title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SONGINFO (TITLE,TYPE,URL,DURATION,StartTime)VALUES('%@',%li,'%@',%i,%i)",title2,(long)type,url,duration,startTime];
    [self executeCmd:cmd];
    [self close:opened];
}

- (NSString *) getNextSong
{
    BOOL opened = [self open];
    NSString * rtn = nil;
    NSString *title2 = [_currentSongTitle stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *query = [NSString stringWithFormat:@"SELECT Title,Type,URL,Duration FROM SONGINFO WHERE Title > '%@'",title2];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR title = (LPSTR)sqlite3_column_text(statement, 0);
        LPSTR type = (LPSTR)sqlite3_column_text(statement, 1);
        LPSTR url = (LPSTR)sqlite3_column_text(statement, 2);
        rtn = [NSString stringWithFormat:@"%s",url];
        _currentSongTitle = [NSString stringWithFormat:@"%s",title];
        _currentSongDuration = sqlite3_column_int(statement, 3);
        _currentSongType = atoi (type);
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    NSString *link = @"https://www.youtube.com/watch?v=ztXYnp1i_3c&t=02m00s";

    [self displayWebLink:link];
    return rtn;
}
- (NSString *) getSong:(NSString *)title
{
    BOOL opened = [self open];
    NSString *title2 = [title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSString * rtn = nil;
    NSString *query = [NSString stringWithFormat:@"SELECT Title,Type, URL,Duration, startTime FROM SONGINFO WHERE Title = '%@'",title2];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR title = (LPSTR)sqlite3_column_text(statement, 0);
        _currentSongType = sqlite3_column_int(statement, 1);
        LPSTR url = (LPSTR)sqlite3_column_text(statement, 2);
        rtn = [NSString stringWithFormat:@"%s",url];
        _currentSongTitle = [NSString stringWithFormat:@"%s",title];
        [self updateSongLabel];
        _currentSongDuration = sqlite3_column_int(statement, 3);
        _currentSongStartTime = sqlite3_column_int(statement, 4);

    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    return rtn;
}

- (void) addSongsToList:(NSMutableArray *)array
{
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT Title,URL FROM SONGINFO"];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR title = (LPSTR)sqlite3_column_text(statement, 0);
        NSString *sTitle = [NSString stringWithCString:title];
        [array addObject:sTitle];
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    return;
}
-(void) setCurrentPositiion:(BOOL)doPlay
{
    int seconds = IDNINT(_endTime - _beginTime);
    NSString *labelText;
    labelText = @"";
    if (_currentSegment > -1 && !_inFullScreen)
    {
        float nseconds = _endTime - _beginTime;
        NSString * clipText = [NSString stringWithFormat:@"Clip %i of %lu (%.1f seconds)\nTap to Edit",_currentSegment+1,(unsigned long)_beginTimes.count,nseconds];
        [_clipButton setTitle:clipText forState:UIControlStateNormal];
        [_clipButton setHidden:NO];
        _tapToEditLabel.text = @"Tap to Edit";
        [_tapToEditLabel setHidden:NO];
    }
    else
    {
        [_clipButton setHidden:YES];
        _tapToEditLabel.text = @"Tap Mark Begin to Add a Clip";
        [self updateClipButtons];
        [_playSegmentButton setSelected:NO];
        [_loopSegmentButton setSelected:NO];
        [_tapToEditLabel setHidden:NO];
    }
    [self setSliderValue:_beginTime];
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
        if (_timer)
            [_timer invalidate];
        if (doPlay)
        {
            _appSoundPlayer.currentTime = _beginTime;
            _timer = [NSTimer scheduledTimerWithTimeInterval:_timerInterval target:self selector:@selector(checkTime:) userInfo:nil repeats:YES];
            [_appSoundPlayer play];
        }
    }
    else
    {
        [self.playerView pauseVideo];
        [self.playerView seekToSeconds:_beginTime allowSeekAhead:YES];
        if (doPlay)
            [self.playerView playVideo];
    }
}
long ConvertCoord (LPDPOINT DPoint, int from, int to)
{
    return 0;
}
int SQLOKpd(int sqlReturn, sqlite3nv *database, int method)
{
    return 0;
}

- (IBAction)playSegmentTapped:(id)sender {
    _inLoop = NO;
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
    }
    else
    {
        [self.playerView pauseVideo];
        [self.playerView seekToSeconds:_beginTime allowSeekAhead:YES];
    }
    if (_timer)
        [_timer invalidate];
    _timer = nil;
    [_loopSegmentButton setSelected:NO];
    if (_playSegmentButton.isSelected)
    {
        [_playSegmentButton setSelected:NO];
        [_pauseButton setHidden:YES];
        [_continueButton setHidden:NO];
    }
    else
    {
        _appSoundPlayer.currentTime = _beginTime;
        [_playSegmentButton setSelected:YES];
        [self continueTapped:nil];
    }
}
- (void)checkTime:(NSTimer*)timer
{
    if (!_timer)
        return;
    if (_currentSongType == SONG)
    {
        float stime = _appSoundPlayer.currentTime;
        if (_appSoundPlayer.currentTime >= _endTime)
        {
            if (_inLoop)
            {
                if (_appSoundPlayer.playing)
                {
                    [_appSoundPlayer stop];
                    [self setSliderValue:_endTime];
                }
                else
                {
                    [timer invalidate];
                    if (_recording)
                    {
                        _leadInCount = 0;
                        _leadInTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playLeadInTick:) userInfo:nil repeats:YES];
                    }
                    else
                    {
                        _inLoop = FALSE;
                        [self loopSegmentTapped:nil];
                    }
                }
            }
            else if (_playSegmentButton.isSelected)
            {
                if (_appSoundPlayer.playing)
                {
                    [_appSoundPlayer stop];
                    [self setSliderValue:_endTime];
                }
                [_playSegmentButton setSelected:NO];
                [_pauseButton setHidden:YES];
                [_continueButton setHidden:NO];
            }
        }
        else
        {
            if (_appSoundPlayer.playing)
                [self setSliderValue:_appSoundPlayer.currentTime];
        }
    }
    else
    {
        if (_inLoop && _currentYTTime >= _endTime)
        {
            if (_playerIsPlaying)
            {
                [self.playerView pauseVideo];
                [self setSliderValue:_endTime];
            }
            else
            {
                [timer invalidate];
                if (_recording)
                {
                    _leadInCount = 0;
                    _leadInTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playLeadInTick:) userInfo:nil repeats:YES];
                }
                else
                {
                    _inLoop = FALSE;
                    [self loopSegmentTapped:nil];
                }
            }
        }
        else
            [self setSliderValue:_currentYTTime];
    }
}
- (IBAction)stopTapped:(id)sender {
    if (_timer)
        [_timer invalidate];
    //_inLoop = NO;
    [_pauseButton setHidden:YES];
    [_continueButton setHidden:NO];
    if (_recordingNewSong)
    {
        _StopRecording = TRUE;
    }
    else if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
    }
    else
        [_playerView pauseVideo];

}
-(void) updateClipButtons
{
    [_priorSegmentButton setEnabled:NO];
    [_nextSegmentButton setEnabled:NO];
    [_playSegmentButton setEnabled:NO];
    [_loopSegmentButton setEnabled:NO];
    if (_currentSegment < 0)
    {
        [_nextSegmentButton setTitle:@"First Clip" forState:UIControlStateNormal];
        [_nextSegmentButton setEnabled:YES];
    }
    else
    {
        [_nextSegmentButton setTitle:@"Next Clip" forState:UIControlStateNormal];
        [_playSegmentButton setEnabled:YES];
        [_loopSegmentButton setEnabled:YES];
        if (_currentSegment > 0)
            [_priorSegmentButton setEnabled:YES];
        if (_currentSegment < (int)_beginTimes.count -1)
            [_nextSegmentButton setEnabled:YES];
    }
}
- (IBAction)priorSegmentTapped:(id)sender {
    [_deleteClipButton setEnabled:NO];

    if (_currentSegment > 0)
    {
        _currentSegment--;
        _inLoop = NO;
        _beginTime = (int)_beginTimes[_currentSegment].integerValue/10.0;
        _endTime = (int)_endTimes[_currentSegment].integerValue/10.0;
        _currentLinkPrefix = (int)_linkPrefixes[_currentSegment].integerValue;
        _currentFileNum = 1;
        _numFilesForCurrentLink = [self getNumFilesInPrefix:_currentLinkPrefix];
        [self setCurrentPositiion:YES];
        if (_numFilesForCurrentLink > 0)
            [self displayFileForClip:_currentLinkPrefix
                             fileNum:_currentFileNum
                            numFiles:_numFilesForCurrentLink];
        else
        {
            [_ImageDisplay setHidden:YES];
            [_fullScreenButton setHidden:YES];
            [_addImageHighlightButton setHidden:YES];
            [_imageHighlightInstructions setHidden:YES];
            [_highlightLinesLabel setHidden:YES];
            [_highlightLinesStepper setHidden:YES];
        }
        [self updateClipButtons];
        [self stopTapped:nil];
        [_loopSegmentButton setSelected:NO];
        [_playSegmentButton setSelected:NO];

    }
}

- (IBAction)nextSegmentTapped:(id)sender {
    [_deleteClipButton setEnabled:NO];

    if (_currentSegment < (int)_beginTimes.count)
    {
        _currentSegment++;
        _beginTime = (int)_beginTimes[_currentSegment].integerValue/10.0;
        _endTime = (int)_endTimes[_currentSegment].integerValue/10.0;
        float nseconds = _endTime - _beginTime;
        NSString * clipText = [NSString stringWithFormat:@"Clip %i of %lu (%.1f seconds)\nTap to Edit",_currentSegment+1,(unsigned long)_beginTimes.count,nseconds];
        [_clipButton setTitle:clipText forState:UIControlStateHighlighted];
        [_clipButton setSelected:NO];
        [_clipButton setHidden:NO];
        _tapToEditLabel.text = @"Tap to Edit";
        [_tapToEditLabel setHidden:NO];
        _inLoop = NO;
        _currentLinkPrefix = (int)_linkPrefixes[_currentSegment].integerValue;
        _currentFileNum = 1;
        _numFilesForCurrentLink = [self getNumFilesInPrefix:_currentLinkPrefix];
        [self setCurrentPositiion:YES];
        if (_numFilesForCurrentLink > 0)
            [self displayFileForClip:_currentLinkPrefix
                             fileNum:_currentFileNum
                            numFiles:_numFilesForCurrentLink];
        else
        {
            [_ImageDisplay setHidden:YES];
            [_fullScreenButton setHidden:YES];
            [_addImageHighlightButton setHidden:YES];
            [_imageHighlightInstructions setHidden:YES];
        }
       [self updateClipButtons];
       [self stopTapped:nil];
       [_loopSegmentButton setSelected:NO];
       [_playSegmentButton setSelected:NO];

    }
}

- (IBAction)loopSegmentTapped:(id)sender
{
    if (_inLoop)
    {
        _inLoop = FALSE;
        if (_currentSongType == SONG)
        {
            [_appSoundPlayer stop];
        }
        else
        {
            [self.playerView pauseVideo];
        }
        [_loopSegmentButton setSelected:NO];
        [_playSegmentButton setSelected:NO];
        [_delayLabel setHidden:YES];
        [_delaySwitch setHidden:YES];
        [_recordLabel setHidden:YES];
        [_recordSwitch setHidden:YES];
        return;
    }
    if (_currentSegment >= 0 && (int)_beginTimes.count > _currentSegment)
    {
        _beginTime = (int)_beginTimes[_currentSegment].integerValue/10.0;
        _endTime = (int)_endTimes[_currentSegment].integerValue/10.0;
    }
    _inLoop = YES;
    [_pauseButton setHidden:NO];
    [_continueButton setHidden:YES];
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
        _appSoundPlayer.currentTime = _beginTime;
        [self setCurrentPositiion:YES];
    }
    else
    {
        _currentYTTime = _beginTime;
        [self.playerView pauseVideo];
        [self.playerView seekToSeconds:_beginTime allowSeekAhead:YES];
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timerInterval target:self selector:@selector(checkTime:) userInfo:nil repeats:YES];
        [self.playerView playVideo];
    }
    [_loopSegmentButton setSelected:YES];
    [_playSegmentButton setSelected:NO];
    [_delayLabel setHidden:NO];
    [_delaySwitch setHidden:NO];
    [_recordLabel setHidden:NO];
    [_recordSwitch setHidden:NO];
}

- (void) setupApplicationAudio {
    
    // Gets the file system path to the sound to play.
    //NSString *soundFilePath = [[NSBundle mainBundle]    pathForResource:    @"sound"
     //                                                   ofType:                @"caf"];


    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    // The AmbientSound category allows application audio to mix with Media Player
    // audio. The category also indicates that application audio should stop playing
    // if the Ring/Siilent switch is set to "silent" or the screen locks.
    //[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
/*
    // Use this code instead to allow the app sound to continue to play when the screen is locked.
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];

    UInt32 doSetProperty = 0;
    AudioSessionSetProperty (
        kAudioSessionProperty_OverrideCategoryMixWithOthers,
        sizeof (doSetProperty),
        &doSetProperty
    );
*/


    // Activates the audio session.
    
    NSError *activationError = nil;
    //[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    return;
    // Instantiates the AVAudioPlayer object, initializing it with the sound
}
// Invoked by the delegate of the media item picker when the user is finished picking music.
//        The delegate is either this class or the table view controller, depending on the
//        state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {

    // Configure the music player, but only if the user chose at least one song to play
    if (mediaItemCollection) {

        _userMediaItemCollection=nil;
        // If there's no playback queue yet...
        if (_userMediaItemCollection == nil) {
        
            // apply the new media item collection as a playback queue for the music player
            [self setUserMediaItemCollection: mediaItemCollection];
            [_musicPlayer setQueueWithItemCollection: _userMediaItemCollection];
            //[self setPlayedMusicOnce: YES];
            [_musicPlayer prepareToPlay];
            [_musicPlayer play];

        // Obtain the music player's state so it can then be
        //        restored after updating the playback queue.
        } else {

            // Take note of whether or not the music player is playing. If it is
            //        it needs to be started again at the end of this method.
            BOOL wasPlaying = NO;
            if (_musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
                wasPlaying = YES;
            }
            // Save the now-playing item and its current playback time.
            MPMediaItem *nowPlayingItem            = _musicPlayer.nowPlayingItem;
            NSTimeInterval currentPlaybackTime    = _musicPlayer.currentPlaybackTime;

            // Combine the previously-existing media item collection with the new one
            NSMutableArray *combinedMediaItems    = [[_userMediaItemCollection items] mutableCopy];
            NSArray *newMediaItems                = [mediaItemCollection items];
            [combinedMediaItems addObjectsFromArray: newMediaItems];
            
            [self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];

            // Apply the new media item collection as a playback queue for the music player.
            [_musicPlayer setQueueWithItemCollection: _userMediaItemCollection];
            
            // Restore the now-playing item and its current playback time.
            _musicPlayer.nowPlayingItem            = nowPlayingItem;
            _musicPlayer.currentPlaybackTime        = currentPlaybackTime;
            
            // If the music player was playing, get it playing again.
            if (wasPlaying) {
                [_musicPlayer play];
                
            }
            [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil] ;
            
        }

        // Finally, because the music player now has a playback queue, ensure that
        //        the music play/pause button in the Navigation bar is enabled.
        //navigationBar.topItem.leftBarButtonItem.enabled = YES;

       // [addOrShowMusicButton    setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
       //                         forState: UIControlStateNormal];
    }
}
// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
- (void) registerForMediaPlayerNotifications {

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver: self
                           selector: @selector (handle_NowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: _musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: _musicPlayer];

/*
    // This sample doesn't use libray change notifications; this code is here to show how
    //        it's done if you need it.
    [notificationCenter addObserver: self
                           selector: @selector (handle_iPodLibraryChanged:)
                               name: MPMediaLibraryDidChangeNotification
                             object: musicPlayer];
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
*/

    [_musicPlayer beginGeneratingPlaybackNotifications];
}

- (void) handle_PlaybackStateChanged:(id)from
{
    return;
}
- (void) handle_NowPlayingItemChanged:(id)from
{
    return;
}


- (void)close:(BOOL)opened
{
    if (opened && _isOpen)
    {
        NSLog(@"Music Database close");
        SQLOK(__FILE__,__LINE__,SQLite_Close(&_database),_database);
        _isOpen = NO;
    }
}
- (BOOL)open
{
    BOOL rtn = FALSE;
    BOOL delete = FALSE;
    NSError *error = nil;

    if (!_isOpen)
    {
        NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
        NSString *errorText = @"";
        if (error)
            errorText = error.localizedDescription;
        _collectionsDirectory = [NSString stringWithFormat:@"%@/Collections",documentsDirectory];
        NSString *songDB = [NSString stringWithFormat:@"%@/%@/songs.slt",_collectionsDirectory,_currentCollection];
        _linksDirectory = [NSString stringWithFormat:@"%@/%@/links",_collectionsDirectory,_currentCollection];
        if (delete)
            [NSFileManager.defaultManager removeItemAtPath:_collectionsDirectory
                                                     error:&error];
        [NSFileManager.defaultManager createDirectoryAtPath:_linksDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error];

        _isOpen = !SQLOK(__FILE__,__LINE__,SQLite_Open(songDB.UTF8String, &_database), _database);
        NSLog(@"Music Database open");
        
        long fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:songDB
                                                                                  error:nil].fileSize;
        
        rtn = TRUE;
        //if (!fileSize)
        {
            rtn = [self createSongsTable];
        }
    }
    return rtn;
}

- (BOOL)createSongsTable
{
    BOOL rtn = TRUE;
    NSString * cmd = @"DROP TABLE CLIPHIGHLIGHT;";
    //rtn = [self executeCmd:cmd];
    cmd = @"DROP TABLE SONGINFO;";
    //rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS CLIPS ('ID' INTEGER PRIMARY KEY,'Title' CHAR(256),'Type' INT,'StartTime' INT,'EndTime' INT, 'URL' CHAR(256));CREATE INDEX IF NOT EXISTS idx_clips_title ON CLIPS (Title);";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS CLIPHIGHLIGHT ('ClipID' INT,'NumLines' INT,'StartX' FLOAT,'StartY' FLOAT,'EndX' FLOAT,'EndY' FLOAT,'BoundsWidth' FLOAT ,'BoundsHeight' FLOAT,PRIMARY KEY (ClipID))";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS SONGINFO ('Title' CHAR(256),'Type' INT,'URL' CHAR(1024),'Duration' INT,  'StartTime' INT ,PRIMARY KEY (Title))";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS EFFECTS ('Title' CHAR(256),'Clip' INT, 'SequenceNum' INT,'Type' INT,'WetDryMix' INT,'PreSet' INT ,PRIMARY KEY (Title,Clip))";
    rtn = [self executeCmd:cmd];

    return rtn;
}

- (Bool)executeCmd:(NSString *)cmd
{
    Bool rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd.UTF8String, 0, 0, 0), _database);
    return rtn;
}

- (Bool)startTransaction
{
    Bool rtn = [self open];
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "BEGIN", 0, 0, 0), _database);
    return rtn;
}

- (void)commitTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "COMMIT", 0, 0, 0),_database);
}

- (void) retrieveSong:(NSString*)title
             setTimes:(BOOL)setTime
{
    BOOL opened = [self open];
    NSString *title2 = [title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSString *query = [NSString stringWithFormat:@"SELECT StartTime,EndTime,ID FROM CLIPS WHERE Title = '%@' ORDER BY StartTime",title2];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int beginTime = sqlite3_column_int(statement, 0);
        int endTime = sqlite3_column_int(statement, 1);
        int rowid = sqlite3_column_int(statement, 2);
        NSNumber *bTime = [NSNumber numberWithInt:beginTime];
        NSNumber *eTime = [NSNumber numberWithInt:endTime];
        NSNumber *linkPrefix = [NSNumber numberWithInt:rowid];
        [_endTimes addObject:eTime];
        [_beginTimes addObject:bTime];
        [_linkPrefixes addObject:linkPrefix];
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    if (setTime)
    {
        _currentSegment = -1;
        [self updateNumClipsLabel];
        [self setCurrentPositiion:NO];
        /*        if (_beginTimes.count)
        {
            _beginTime = (int)_beginTimes[0].integerValue/10.0;
            _endTime = (int)_endTimes[0].integerValue/10.0;
        }
        
        if (_linkPrefixes.count > 0)
            _currentLinkPrefix = _linkPrefixes[0].intValue;
        else
            _currentLinkPrefix = 0;
        _numFilesForCurrentLink = [self getNumFilesInPrefix:_currentLinkPrefix];
        if (_numFilesForCurrentLink > 0)
            [self displayFileForLink:_currentLinkPrefix
                             fileNum:1
                            numFiles:_numFilesForCurrentLink];
        [self updateNumClipsLabel];
        [self setCurrentPositiion:NO];*/
    }
}
- (void) deleteClip:(int)clipID
{
    BOOL opened = [self open];
    NSString *title2 = [_currentSongTitle stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM CLIPS WHERE ID = %i",clipID];
    [self executeCmd:cmd];
    [self close:opened];
    [self retrieveSong:title2 setTimes:NO];
    [self updateNumClipsLabel];
    [self updateClipButtons];
    [_saveButton setEnabled:NO];
    [_cancelEditButton setEnabled:NO];
    [_deleteClipButton setEnabled:NO];
    _currentSegment--;
    [self retrieveSong:title2 setTimes:NO];

}
-(void) updateNumClipsLabel
{
    NSString * clipText = [NSString stringWithFormat:@"%i seconds: %lu clips",_currentSongDuration,(unsigned long)_beginTimes.count];
    if (_beginTimes.count == 1)
        clipText = [NSString stringWithFormat:@"%i seconds: %lu clip",_currentSongDuration,(unsigned long)_beginTimes.count];
    [_numClipsLabel setText:clipText];

}
- (IBAction)sliderExit:(id)sender {
    if (!_changeBeginButton.isHidden && _changeBeginButton.isEnabled &&_changeBeginButton.isSelected)
        _beginTime = _slider.value;
    else if (!_changeEndButton.isHidden && _changeEndButton.isEnabled && _changeEndButton.isSelected)
        _endTime = _slider.value;
    else
    {
        [self stopTapped:nil];
        _currentSegment = -1;
    }
    [self setCurrentPositiion:NO];

}


- (IBAction)monitorTapped:(id)sender {
    //[self displayYouTubeVideo:@"www.youtube.com"];
    [self toggleMonitor];
}
/*
- (void) testMonitorx
{
    //_audioController = [[AudioController alloc] init];
    static BOOL monOn = FALSE;
    if (monOn)
    {
        [AudioController closeAudioController];
        monOn = FALSE;
    }
    else
    {
        [AudioController initAudioController];
        [AudioController playButtonPressed];
        monOn = TRUE;
    }
    return;
}*/
- (void) toggleMonitor
{
    //_audioController = [[AudioController alloc] init];
    if (_monOn)
    {
        NSError *error;
        [_monitorButton setSelected:NO];
        [_audioEngine closeSession];
        _audioEngine = nil;
        _monOn = FALSE;
    }
    else
    {
        [_monitorButton setSelected:YES];
        [self startMonitor];
        _monOn = TRUE;
    }
    return;
}

- (void) startMonitor
{
    NSError *error=nil;
    //_audioEngine = [AudioEngine initWithEffectsArray:_effectsArray];
    _audioEngine = AudioEngine.new;
    _audioEngine.effectsArray = _effectsArray;
    [_audioEngine setUpSession];

    //AVAudioEngine *engine = [_audioEngine getEngine];

    //[engine prepare];
    //[engine startAndReturnError:&error];
    //[_audioEngine togglePlayer];
    return;
}
- (IBAction)effectsTapped:(id)sender {
    
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
        EffectsViewController *effectsVC = [storyboard instantiateViewControllerWithIdentifier:@"EffectsViewController"];
        effectsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        effectsVC.delegate = self;
        effectsVC.effectsArray = _effectsArray;
        effectsVC.audioEngine = _audioEngine;
        [self presentViewController:effectsVC animated:YES completion:nil];
    }
    return;
}

- (void) startMonitor3
{
    NSError *error=nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:(AVAudioSessionCategoryOptionAllowBluetooth )
                                           error:&error];
//
    [audioSession setActive:YES error:&error];
    _audioEngine = [[AVAudioEngine alloc] init];

    AVAudioEngine *engine = _audioEngine;
    AVAudioInputNode *mic = [engine inputNode];
    mic.volume = 1;
    AVAudioOutputNode *speaker = [engine outputNode];

    //[engine reset];
    [engine prepare];
    
    AVAudioMixerNode *mainMixer = engine.mainMixerNode;
    [engine connect:mic to:mainMixer format:nil];

    AVAudioFormat *mixerOutputFormat = [mainMixer outputFormatForBus:0];
    AVAudioPlayerNode *playerNodeForMixer = [[AVAudioPlayerNode alloc] init];
    
    AVAudioUnitReverb *reverb = [[AVAudioUnitReverb alloc]init];
    reverb.wetDryMix = 50;

//    [reverb loadFactoryPreset:AVAudioUnitReverbPresetCathedral];
    [engine attachNode:reverb];
    [engine attachNode:playerNodeForMixer];
    [engine connect:playerNodeForMixer to:reverb format:mixerOutputFormat];
    
    // connect the reverb effect to mixer input bus 0
   // [engine connect:reverb to:mainMixer fromBus:0 toBus:0 format:mixerOutputFormat];
    [engine startAndReturnError:&error];
    return;
/*
    
    AVAudioPlayerNode *playerNodeForMonitor = [[AVAudioPlayerNode alloc] init];
    [engine attachNode:playerNodeForMonitor];
    
    AVAudioMixerNode *audioMixer = [[AVAudioMixerNode alloc] init];
    [engine attachNode:audioMixer];
    
    AVAudioPlayerNode *playerNodeForOutput = [[AVAudioPlayerNode alloc] init];
    [engine attachNode:playerNodeForOutput];
    
    AVAudioMixerNode *micMixer = [[AVAudioMixerNode alloc] init];
    [engine attachNode:micMixer];
    
    
    AVAudioInputNode *mic = [engine inputNode];
    [engine connect:mic to:micMixer format:[mic inputFormatForBus:0]];
    [engine connect:micMixer to:audioMixer format:mixerOutputFormat];
    [engine connect:playerNodeForMixer to:audioMixer format:mixerOutputFormat];
    
    [engine connect:playerNodeForMonitor to:micMixer format:mixerOutputFormat];
    
    
//    [engine connect:mic to:mainMixer format:mixerOutputFormat];
    [engine connect:playerNodeForOutput to:mainMixer format:mixerOutputFormat];
    [engine connect:playerNodeForMonitor to:mainMixer format:mixerOutputFormat];

    AVAudioFile *bgAudioFile = [[AVAudioFile alloc] initForReading:self.bgMusicURL error:&error];
    
    __weak DEKaraokeController *weakSelf = self;
    [playerNodeForMixer scheduleFile:bgAudioFile atTime:nil completionHandler:^{
        [playerNodeForOutput stop];
        [weakSelf stop];
        if (musicFinishCallback != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
               musicFinishCallback();
            });
           
        }
    }];
    
    [playerNodeForOutput scheduleFile:bgAudioFile atTime:nil completionHandler:nil];
    
    
    
    
    
    
    AVAudioFormat *tapFormat = [audioMixer outputFormatForBus:0];
    
    AVAudioFile *outputFile = [[AVAudioFile alloc] initForWriting:self.outputURL settings:
                               [tapFormat settings] error:&error];
    
    [audioMixer installTapOnBus:0 bufferSize:4096 format:tapFormat
                          block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
                              NSError *error;
                              BOOL success = NO;
                              
                              success = [outputFile writeFromBuffer:buffer error:&error];
                              NSAssert(success, @"error writing buffer data to file, %@", [error localizedDescription]);
                          }];
    
    self.audioMixer = audioMixer;
    
    [micMixer installTapOnBus:0 bufferSize:4096 format:tapFormat
                        block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
                            [weakSelf meterLevel:buffer callback:powerLevelChangedCallback];
                            
                        }];
    
    
    
    [engine reset];
    [engine prepare];
    [engine startAndReturnError:&error];
    
    [playerNodeForMixer play];
    [playerNodeForMonitor play];
    [playerNodeForOutput play];
    
    self.isRunning = YES;
    
  */
   
}



-(void)meterLevel:(AVAudioPCMBuffer *)buffer callback:(void (^)(float))callback{
    //  [buffer setFrameLength:[buffer frameLength]];
    UInt32 inNumberFrames = buffer.frameLength;
    
    float LEVEL_LOWPASS_TRIG = 0.2;
    

}

- (IBAction)selectPhoto:(id)sender {
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];


}

- (IBAction)cancelImagePicked:(id)sender {
    [_saveImageButton setHidden:YES];
    [_cancelImageButton setHidden:YES];
    [_ImageDisplay setImage:nil];
}

- (int) getNextFileInPrefix:(int)prefix
{
    int rtn = 1;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *allLinks = [filemgr contentsOfDirectoryAtPath: _linksDirectory error: nil];
    NSString *prefixText = [NSString stringWithFormat:@"%i",prefix];
    for (NSString *file in allLinks)
    {
        NSString *beforeText = textBefor(file, @"_");
        if ([beforeText isEqual:prefixText])
            rtn++;
    }
    return rtn;
}

-(void) displayFileForClip:(int)clipID
                   fileNum:(int)fileNum
                  numFiles:(int)numFiles
{
    NSString *fileName = [NSString stringWithFormat:@"%@/%i_%i.png",_linksDirectory,clipID,fileNum];
    _image = [UIImage imageWithContentsOfFile:fileName];
    [_ImageDisplay setImage:_image];
    [_ImageDisplay setHidden:NO];
    [_fullScreenButton setHidden:NO];
    [_addImageHighlightButton setHidden:NO];
    [_highlightLinesLabel setHidden:YES];
    [_highlightLinesStepper setHidden:YES];
    [_imageHighlightInstructions setHidden:YES];
    [_priorFileButton setHidden:YES];
    [_nextFileButton setHidden:YES];
    if (fileNum > 1)
        [_priorFileButton setHidden:NO];
    if (fileNum < numFiles)
        [_nextFileButton setHidden:NO];
    _currentFileNum = fileNum;
    _currentNumFiles = numFiles;
    [self displayHighlightForLink:clipID
                           inView:_ImageDisplay];
    return;
}
-(CGRect)imageRectInView:(UIImageView*)view
{
    CGRect rtn={0};
    CGRect b = view.bounds;
    CGRect f = view.frame;
    double iw = view.image.size.width;
    double ih = view.image.size.height;
    double vw = view.bounds.size.width;
    double vh = view.bounds.size.height;
    float csf = view.contentScaleFactor;
    int cm = view.contentMode;
    CGRect cs = view.contentStretch;
    
    double wfactor = vw / iw;
    double hfactor = vh / ih;
    if (wfactor < hfactor)
    {
        rtn.size.width = vw;
        rtn.size.height = ih * wfactor;
        rtn.origin.x = 0;
        rtn.origin.y = (vh - rtn.size.height) / 2;
    }
    else
    {
        rtn.size.width = iw * hfactor;;
        rtn.size.height = vh;
        rtn.origin.y = 0;
        rtn.origin.x = (vw - rtn.size.width) / 2;
    }
    return rtn;
}
- (BOOL) displayHighlightForLink:(int)clipID
                          inView:(UIImageView*) view
{
    [self removeHighlightFromView:view];
    BOOL rtn = FALSE;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT NumLines,StartX,StartY,EndX,EndY,BoundsWidth,BoundsHeight FROM CLIPHIGHLIGHT WHERE ClipID=%i",clipID];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int i = 0;
        CGPoint imagePoint1, imagePoint2;
        float w, h;
        int numLines = sqlite3_column_int(statement, i++);
        imagePoint1.x = sqlite3_column_double(statement, i++);
        imagePoint1.y = sqlite3_column_double(statement, i++);
        imagePoint2.x = sqlite3_column_double(statement, i++);
        imagePoint2.y = sqlite3_column_double(statement, i++);
        w = sqlite3_column_double(statement, i++);
        h = sqlite3_column_double(statement, i++);
        CGRect viewFrame = [self imageRectInView:view];
        CGRect imageFrame = CGRectMake(0,0,  view.image.size.width, view.image.size.height);
        HANDLE hTranRect = STRANCGRect (imageFrame,viewFrame);
        DPOINT dPoint = CGPointToDPOINT(imagePoint1);
        DPOINT dPoint1 = TranPoint (&dPoint,hTranRect);
        dPoint = CGPointToDPOINT(imagePoint2);
        DPOINT dPoint2 = TranPoint (&dPoint,hTranRect);
        CloseTRANS2 (&hTranRect);
        CGPoint viewPoint1 = DPointToCGPoint(dPoint1);
        CGPoint viewPoint2 = DPointToCGPoint(dPoint2);
        [self createHighlight:viewPoint1 point2:viewPoint2 numLines:numLines inView:view doUpdate:NO];
        rtn = TRUE;
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    return rtn;
}
- (IBAction)fullScreenTapped:(id)sender {
    [self hideAllViews:YES];
    _inFullScreen = YES;
    [_fullScreenImageDisplay setImage:_image];
    [_fullScreenImageDisplay setHidden:NO];
    [_fullScreenReturnButton setHidden:NO];
    [_monitorButton setHidden:YES];
    [_monitorVolumeSlider setHidden:YES];
    [_effectsButton setHidden:YES];
    [self displayHighlightForLink:_currentLinkPrefix inView:_fullScreenImageDisplay];
}

- (IBAction)deleteClipTapped:(id)sender {
    [self verifyDelete:1];
}

- (IBAction)addImageHighlightTapped:(id)sender {
    [_imageHighlightInstructions setHidden:NO];
    [_imageHighlightInstructions setText:@"Tap start point"];
    [_highlightLinesLabel setHidden:NO];
    [_highlightLinesStepper setHidden:NO];

    _highlightPointNumber = 1;
}

- (IBAction)highlightLinesChanged:(id)sender {
    _numHighlightLines = _highlightLinesStepper.value;
    NSString *label = [NSString stringWithFormat:@"Lines: %i",_numHighlightLines];
    [_highlightLinesLabel setText:label];
}

- (IBAction)delayChanged:(id)sender {
}

- (IBAction)recordChanged:(id)sender {
    _recording = _recordSwitch.on;
}
-(void) frameToPoints:(CGRect)frame
               points:(CGPoint*)points
{
    points[0] = frame.origin;
    points[1] = frame.origin;
    points[1].x += frame.size.width;
    points[2] = frame.origin;
    points[2].x += frame.size.width;
    points[2].y += frame.size.height;
    points[3] = frame.origin;;
    points[3].y += frame.size.height;

}
-(void) removeHighlightFromView:(UIView *)view
{
    for (CALayer *layer in view.layer.sublayers)
    {
        [layer removeFromSuperlayer];
    }
}
-(void) createHighlight:(CGPoint)point1
                 point2:(CGPoint)point2
               numLines:(int)numLines
                 inView:(UIImageView *)view
               doUpdate:(BOOL)update
{
    CGPoint point={0,0};
    CGFloat w = view.bounds.size.width;
    CGFloat h = view.bounds.size.height;
    int iw = view.image.size.width;
    int ih = view.image.size.height;
    float scale = view.image.scale;
    CGPoint framePoints[4];
    [self frameToPoints:view.frame
                 points:(CGPoint *)framePoints];
    [self removeHighlightFromView:view];
    UIBezierPath *highlightPath = UIBezierPath.new;
    [highlightPath moveToPoint: point];
    point.x = w;
    [highlightPath addLineToPoint:point];
    point.y = h;
    [highlightPath addLineToPoint:point];
    point.x = 0;
    [highlightPath addLineToPoint:point];
    point.y = 0;
    [highlightPath addLineToPoint:point];
    point = point1;
    [highlightPath moveToPoint: point];
    if (numLines == 1)
    {
        point.y = point2.y;
        [highlightPath addLineToPoint: point];
        [highlightPath addLineToPoint:point2];
        point = point1;
        point.x = point2.x;
        [highlightPath addLineToPoint: point];
        [highlightPath addLineToPoint: point1];
    }
    else
    {
        CGPoint points[8];
        int lineHeight = (point2.y - point1.y)/numLines;
        points[0] = point1;
        point.x = w;
        points[1] = point;
        point.y = point2.y - lineHeight;
        points[2] = point;
        point.x = point2.x;
        points[3] = point;
        point.y = point2.y;
        points[4] = point;
        point.x = 0;
        points[5] = point;
        point.y = point1.y + lineHeight;
        points[6] = point;
        point.x = point1.x;
        points[7] = point;
        for (int i=7;i>0;i--)
            [highlightPath addLineToPoint: points[i]];
    }
    [highlightPath closePath];
    CAShapeLayer *highlightLayer = CAShapeLayer.layer;
    highlightLayer.path = highlightPath.CGPath;
    highlightLayer.fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
    [view.layer addSublayer:highlightLayer];

    if (update)
    {
        CGRect viewFrame = [self imageRectInView:view];
        CGRect imageFrame = CGRectMake (0,0,view.image.size.width,view.image.size.height);
        HANDLE hTranRect = STRANCGRect (viewFrame,imageFrame);
        DPOINT dPoint = CGPointToDPOINT(point1);
        DPOINT dPoint1 = TranPoint (&dPoint,hTranRect);
        dPoint = CGPointToDPOINT(point2);
        DPOINT dPoint2 = TranPoint (&dPoint,hTranRect);
        CloseTRANS2 (&hTranRect);
        CGPoint imagePoint1 = DPointToCGPoint(dPoint1);
        CGPoint imagePoint2 = DPointToCGPoint(dPoint2);

        BOOL opened = [self open];
        NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CLIPHIGHLIGHT VALUES(%i,%i,%f,%f,%f,%f,%f,%f);",
                         _currentLinkPrefix,numLines,imagePoint1.x,imagePoint1.y,imagePoint2.x,imagePoint2.y,w,h];
        BOOL rtn = [self executeCmd:cmd];
        [self close:opened];
    }
}
- (IBAction)fullScreenReturnButtonTapped:(id)sender {
    [self hideAllViews:NO];
    _inFullScreen = NO;
    [_fullScreenImageDisplay setHidden:YES];
    [_fullScreenReturnButton setHidden:YES];
    [_monitorButton setHidden:NO];
    [_monitorVolumeSlider setHidden:NO];
    [_effectsButton setHidden:NO];

}

- (int) getNumFilesInPrefix:(int)prefix
{
    int rtn = 0;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *allLinks = [filemgr contentsOfDirectoryAtPath: _linksDirectory error: nil];
    NSString *prefixText = [NSString stringWithFormat:@"%i",prefix];
    for (NSString *file in allLinks)
    {
        NSString *beforeText = textBefor(file, @"_");
        if ([beforeText isEqual:prefixText])
            rtn++;
    }
    return rtn;
}
- (NSString *) getFileInPrefix:(int)prefix
                  fileInPrefix:(int)fileInPrefix
{
    NSString *rtn = nil;

    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *allLinks = [filemgr contentsOfDirectoryAtPath: _linksDirectory error: nil];
    NSString *prefixText = [NSString stringWithFormat:@"%i",prefix];
    NSString *fileInPrefixText = [NSString stringWithFormat:@"%i",fileInPrefix];
    for (NSString *file in allLinks)
    {
        NSString *name = textBefor(file, @".");
        NSString *beforeText = textBefor(name, @"_");
        NSString *afterText = textAfter(name, @"_");
        if ([beforeText isEqual:prefixText] && [afterText isEqual:fileInPrefixText])
            rtn = file;
    }
    return rtn;
}

- (IBAction)saveImagePicked:(id)sender
{
    int fileInPrefix = [self getNextFileInPrefix:_currentLinkPrefix];
    NSString *fileName = [NSString stringWithFormat:@"%@/%i_%i.png",_linksDirectory,_currentLinkPrefix,fileInPrefix];
    [UIImagePNGRepresentation(_currentImage) writeToFile:fileName atomically:YES];
    [_saveImageButton setHidden:YES];
    [_cancelImageButton setHidden:YES];
    [_ImageDisplay setImage:nil];
}

- (IBAction)priorFileTapped:(id)sender {
    [self displayFileForClip:_currentLinkPrefix
                     fileNum:_currentFileNum-1
                    numFiles:_currentNumFiles];
}

- (IBAction)nextFileTapped:(id)sender {
    [self displayFileForClip:_currentLinkPrefix
                     fileNum:_currentFileNum+1
                    numFiles:_currentNumFiles];

}

- (IBAction)selectCollectionTapped:(id)sender {
{
        NSMutableArray *optionList = NSMutableArray.array;

        [optionList addObject:@"Add New Collection"];
        [optionList addObject:@"________________________"];
        NSArray *collections = [self getAllCollections];
        for (NSString * name in collections)
        {
            [optionList addObject:name];
        }
        
        
        NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                          delegate:self
                                                                             title:@"Collections"
                                                                         textArray:optionList
                                                                     includeCancel:YES];
        nvptv.identifier = @"Select Collection";
        nvptv.allowsSubtitle = NO;
    }

    
}
- (void) verifyDelete:(int)type
{
    NSMutableArray *optionList = NSMutableArray.array;
    
    [optionList addObject:@"Yes"];
    [optionList addObject:@"No"];
    NSString *title = [NSString stringWithFormat:@"Verify Delete of Clip %i",_currentSegment+1];
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:title
                                                                     textArray:optionList
                                                                 includeCancel:NO];
    nvptv.allowsSubtitle = NO;
}

- (void) updateSongLabel
{
    NSString * label = [_currentSongTitle stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
    [_songTitleLable setText:label];
}

- (IBAction)saveYouTubeTapped:(id)sender {
    
    [self showHideStartTime:NO
                   withName:YES];

    int startTimeMinutes = _startTimeMinutesInput.text.intValue;
    int startTimeSeconds = _startTimeSecondsInput.text.intValue;
    _YouTubeName = _linkName.text;
    _currentSongTitle = _YouTubeName;
    [self updateSongLabel];
    [_gotoYouTubeButton setHidden:YES];
    NSString *linkURL = _linkURLField.text;
    [self startNewYouTubeVideo:linkURL];
    return;
}

- (IBAction)startTimeCancelTapped:(id)sender {
    [self showHideStartTime:NO
                   withName:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    NSURL *url = [info valueForKey:@"UIImagePickerControllerImageURL"];
    _imageData = [NSData dataWithContentsOfURL:url];
    _currentImage = [UIImage imageWithData:_imageData];
    [_ImageDisplay setImage:_currentImage];
    [_saveImageButton setHidden:NO];
    [_cancelImageButton setHidden:NO];
    return;
}
- (BOOL) displayYouTubeVideo:(NSString *) link
{
    _slider.maximumValue = _currentSongDuration;
    _slider.minimumValue = 0;
    _slider.continuous = YES;
    _currentTime = 0;
    _beginTime = _currentTime;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    _currentSegment = -1;
    _playButton.enabled=YES;
    _beginButton.enabled=YES;
    _endButton.enabled=YES;
    _playSegmentButton.enabled=YES;
    _loopSegmentButton.enabled=YES;
    _nextSegmentButton.enabled=YES;
    _priorSegmentButton.enabled=YES;
    [_saveButton setEnabled:NO];
    _YouTubeName = _currentSongTitle;
    [self retrieveSong:_currentSongTitle   setTimes:YES];
    [_playerView setHidden:NO];
    link = textAfterLastChar(link, @"/");
    NSString *subLink = textBefore(link, @"=");
    BOOL rtn;
    if (subLink.length > 0)
    {
        _currentYouTubeLink = subLink;
        rtn = [self.playerView loadWithVideoId:subLink];
    }
    else
    {
        _currentYouTubeLink = link;
        rtn = [self.playerView loadWithVideoId:link];
    }
    return rtn;
}

- (void) displayWebLink:(NSString *) link
{
    _ImageDisplay.backgroundColor = UIColor.whiteColor;
    _webView = [NVWebView showWebViewInView:_ImageDisplay
                                            urlString:link
                                         withDelegate:self];
    _webView.backgroundColor = UIColor.yellowColor;
    _webView.returnButton.titleLabel.backgroundColor = UIColor.clearColor;
    _webView.saveLinkButton.titleLabel.backgroundColor = UIColor.clearColor;
    _webView.webView.configuration.allowsInlineMediaPlayback = true;
    [_webView showSaveLinkButton];
}

- (BOOL)webViewDidReturn:(NVWebView *)webView
                    link:(NSString *)linktext
{
    [webView hide:TRUE];
    return TRUE;
}
- (BOOL)webViewDidReturn:(NVWebView *)webView
                    withCurrentURL:(NSString *)linktext
{
    [_webView setURL:@""];
    _webView = nil;
    [self showHideStartTime:YES withName:YES];
    _currentYouTubeLink = linktext;
    return TRUE;
//Slow blues https://www.youtube.com/watch?v=g7xM4QD2v2s
}

-(void) showHideStartTime:(BOOL)showHide
                 withName:(BOOL)withName
{
    showHide = !showHide;
    [_startTimeTitle setHidden:showHide];
    [_startTimeMinutesTitle setHidden:showHide];
    [_startTimeSecondsTitle setHidden:showHide];
    [_startTimeMinutesInput setHidden:showHide];
    [_startTimeSecondsInput setHidden:showHide];
    [_startTimeMinutesStepper setHidden:showHide];
    [_startTimeSecondsStepper setHidden:showHide];
    [_startTimeSaveButton setHidden:showHide];
    [_startTimeCancelButton setHidden:showHide];
    if (showHide)
        [self.view endEditing:YES];
    if (withName)
    {
        [_linkNameLabel setHidden:showHide];
        [_linkName setHidden:showHide];
    }
}
- (void)startRecording:(double)recordTime
                toFile:(NSString*) toFile
{
    _StopRecording = FALSE;
    [self startMonitor];
    [_audioEngine startRecordingMixerOutput:toFile];
    _maxRecordTime = recordTime;
    _recordTime = 0;
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkRecordTimer:) userInfo:nil repeats:YES];
}
- (void) checkRecordTimer:(NSTimer *)timer
{
    if (_maxRecordTime > 0)
    {
        _recordTime += 0.1;
        if (_recordTime >= _maxRecordTime)
        {
            [_recordTimer invalidate];
            [self stopRecording];
            [self playRecording:_playbackFile];
        }
    }
    else
    {
        if (_StopRecording)
        {
            [_recordTimer invalidate];
            [self stopRecording];
            [_audioEngine setOutputVolume:1];
            [self playRecording:_NewSongFile];
        }
    }
}


- (void)startRecordingx:(double)recordTime
{
    BOOL st = YES;
    NSError *err = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    //[audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    //[audioSession setPreferredOutputNumberOfChannels:2 error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    _recordSetting = [[NSMutableDictionary alloc] init];
    
    // We can use kAudioFormatAppleIMA4 (4:1 compression) or kAudioFormatLinearPCM for nocompression
    [_recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];

    // We can use 44100, 32000, 24000, 16000 or 12000 depending on sound quality
    [_recordSetting setValue:[NSNumber numberWithFloat:32000.0] forKey:AVSampleRateKey];
    
    // We can use 2(if using additional h/w) or 1 (iPhone only has one microphone)
    [_recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    // These settings are used if we are using kAudioFormatLinearPCM format
    //[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    //[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    
    // Create a new dated file
    //NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSString *caldate = [now description];
//    recorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, caldate] retain];
    _recorderFilePath = [NSString stringWithFormat:@"%@/MySound.caf", DOCUMENTS_FOLDER];
    
    NSLog(@"recorderFilePath: %@",_recorderFilePath);
    
    NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }
    
    err = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:_recordSetting error:&err];
    
    if(!_recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [_recorder setDelegate:self];
    st = [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    // start recording
    [_recorder recordForDuration:(NSTimeInterval) recordTime];
    
    //statusMsg.text = @"Recording...";
    //progressView.progress = 0.0;
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
}

- (void) stopRecording
{
    NSError * error = nil;
    
    [_audioEngine stopRecordingMixerOutput];
    AVAudioEngine *engine = [_audioEngine getEngine];
    [engine stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:&error];
}

- (IBAction)stopRecordingx:(id)sender;
{
    [_recorder stop];
    
    //[timer invalidate];
    //statusMsg.text = @"Stopped";
    //progressView.progress = 1.0;
    
    //NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
//    NSError *err = nil;
//    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
//    if(!audioData)
//        NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
//    [editedObject setValue:[NSData dataWithContentsOfURL:url] forKey:@"editedFieldKey"];
//
//    //[recorder deleteRecording];
//
//
//    NSFileManager *fm = [NSFileManager defaultManager];
//
//    err = nil;
//    [fm removeItemAtPath:[url path] error:&err];
//    if(err)
//        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
    
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (_saveSoundPlayer)
    {
        _appSoundPlayer = _saveSoundPlayer;
    }
    [self loopSegmentTapped:nil];
}
- (BOOL)playRecording:(NSString *) path
{
    NSError *error;
    long fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:path
                                                                              error:nil].fileSize;

    NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:&error];
    if (error)
    {
        NSLog(@"Player ERROR: %@", error.localizedDescription);
        return FALSE;
    }
    _saveSoundPlayer = _appSoundPlayer;
    _appSoundPlayer = newPlayer;
    [_appSoundPlayer prepareToPlay];
    [_appSoundPlayer setVolume: 1.0];
    [_appSoundPlayer setDelegate: self];

    [_appSoundPlayer play];

    return TRUE;
    /*
    if(_soundID)
    {
        AudioServicesDisposeSystemSoundID(_soundID);
    }
    
    //Get a URL for the sound file
    NSURL *filePath = [NSURL fileURLWithPath:_recorderFilePath isDirectory:NO];
    
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(filePath), &_soundID);
    
    //Use audio services to play the sound
    //statusMsg.text = @"Playing";
    AudioServicesPlaySystemSound(_soundID);
     */
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) EffectsViewController:(EffectsViewController *)controller didReturn:(EffectsReturnStatus)status
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch (status)
    {
        case DID_COMPLETE:
            break;
        case DID_CLEAR:
        {
            EffectsData *efdata = EffectsData.new;
            [efdata setTypeAndID:REVERB ID:0];
            efdata.wetDrySlider.value = 0;
            efdata.reverb.wetDryMix = 0;
            [_effectsArray addObject:efdata];
            
            [self effectsTapped:nil];
        }
            break;
        case DID_UPDATE:
            [self effectsTapped:nil];
            break;
        case DID_CANCEL:
            break;
    }
    [_monitorButton setSelected:YES];
    if (_monOn)
        [self toggleMonitor];
    [self toggleMonitor];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EffectsSegue"])
    {
        EffectsViewController *containerViewController = segue.destinationViewController;
        containerViewController.delegate = self;
        containerViewController.effectsArray = _effectsArray;
    }
}


@end
