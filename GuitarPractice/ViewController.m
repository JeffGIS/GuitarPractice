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
typedef NS_ENUM(NSInteger, ControlTypes)
{
    CTBUTTON,
    CTFILLEDBUTTON,
    CTLABEL,
    CTVIEW,
    CTTEXTFIELD,
    CTSLIDER,
    CTSWITCH,
    CTSTEPPER,
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

@interface ImageAndTime : NSObject
@property long imageID;
@property int fromTime;
@property int toTime;
@property int leftMargin;
@property int rightMargin;
@end
@implementation ImageAndTime
@synthesize imageID;
@synthesize fromTime;
@synthesize toTime;
@synthesize leftMargin;
@synthesize rightMargin;
- (id)init
{
    self = [super init];
    return self;
}
@end


@interface BarMarker : NSObject
@property long markerID;
@property int markerNum;
@property long clipID;
@property double fromTime;
@property double toTime;
@property int  beginLine;
@property int  endLine;
@property double pctAlongClip;
@property double pctAlongBeginLine;
@property double pctAlongEndLine;
@property UILabel *label;
@end
@implementation BarMarker
@synthesize markerID;
@synthesize markerNum;
@synthesize clipID;
@synthesize fromTime;
@synthesize toTime;
@synthesize beginLine;
@synthesize endLine;
@synthesize pctAlongClip;
@synthesize pctAlongBeginLine;
@synthesize pctAlongEndLine;
@synthesize label;

- (id)init
{
    self = [super init];
    self.label = UILabel.new;
    return self;
}
@end

@interface ViewController ()
@property AVAudioSession* audioSession;
@property AVAudioPlayer *appSoundPlayer;
@property AVAudioPlayer *saveSoundPlayer;
@property AVAudioRecorder *appSoundRecorder;
@property NSInteger currentPracticeGroupID;
@property MPMediaItem * currentSong;
@property int currentSongDuration;
@property NSURL *currentSongURL;
@property (nonatomic) MPMediaItemCollection      *userMediaItemCollection;
@property (nonatomic) MPMusicPlayerController    *musicPlayer;
@property MPMediaPickerController *picker;
@property float currentTime;
@property (nonatomic)double beginTime;
@property (nonatomic)double endTime;
@property float timerInterval;
@property int currentSongStartTime;
@property NSMutableArray<NSNumber*> *clipIDs;
@property NSMutableArray<NSNumber*> *beginTimes;
@property NSMutableArray<NSNumber*> *endTimes;
@property NSMutableArray<NSNumber*> *barsInClip;
@property NSArray<ImageAndTime*> *images;
@property NSString *recordingsDirectory;
@property NSString *imagesDirectory;
@property UIImage *image;
@property (nonatomic)long currentImageID;
@property UIImage *currentImage;
@property NSString * currentSongTitle;
@property int numFilesForCurrentLink;
@property int currentClipID;
@property int currentFileNum, currentNumFiles;
@property NVWebView * webView;
@property NSString *currentCollection;
@property long currentCollectionID;
@property NSString * currentYouTubeLink;
@property NSString * YouTubeName;
@property SongTypes currentSongType;
@property float currentYTTime;
@property BOOL startingNewVideo;
@property BOOL startingExistingVideo;
@property int clipEditStatus;
@property int currentClip;
@property NSTimer *timer;
@property NSTimer *leadInTimer;
@property int maxLeadInTicks;
@property NSTimer *recordTimer;
@property NSTimer *buttonTimer;
@property float recordTime;
@property float maxRecordTime;
@property sqlite3nv *database;
@property (atomic) BOOL isOpen;
@property BOOL inLoop;
@property NSMutableArray *allControlArraysArray;
@property NSMutableArray *allViewsArray, *allButtonsArray, *allFilledButtonsArray, *allLabelsArray, *allTextFieldsArray, *allSteppersArray, *allSlidersArray, *allSwitchArray;
@property NSMutableArray *allViewsAndStatusArray;
@property NSMutableArray <UIFont*>*filledButtonTitleFontArray,*filledButtonSubTitleFontArray;
@property UITapGestureRecognizer *tapGestureRecognizer;
@property UITapGestureRecognizer *tapGestureRecognizerFullScreen;
@property UITapGestureRecognizer *tapBarMarker;
@property UILongPressGestureRecognizer *longPressRecognizerFullScreen;
@property BOOL haveStartLocation;
@property int highlightPointNumber;
@property CGPoint highlightPoint1, highlightPoint2;
@property CGRect highlightRect;
@property int numHighlightLines, savedNumHighlightLines;
@property BOOL inTimeTest;
@property float clipEndTime,clipStartTime;
@property int numBarsInClip;
@property BOOL creatingBarMarkers;
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
@property int numTrackLines, savedNumTrackLines;
@property float trackLineSpacing, savedTrackLineSpacing;
@property UILabel *trackLabel;
@property LPDPOINT trackPoints, savedTrackPoints;
@property LPDOUBLE trackLineWidths, savedTrackLineWidths;
@property double totTrackLineWidth, savedTotTrackLineWidth;
@property double distToFirstTrack, savedDistToFirstTrack;
@property CGPoint trackLineBasePoint, savedTrackLineBasePoint;
@property NSString *instrument;
@property NSString *tuning;
@property float imageStartAt, imageEndAt;
@property BOOL inAddImageMode;
@property NSMutableDictionary *recordSetting;
@property NSMutableDictionary *editedObject;
@property NSString *recorderFilePath;
@property AVAudioRecorder *recorder;
@property BOOL adjustingLeftMargin;
@property int leftMargin, rightMargin;
@property HANDLE hTranImageToView, hTranViewToImage;
@property UILabel *leftMarginMarker, *rightMarginMarker;
@property CGRect savePlaySegmentFrame, saveLoopSegmentFrame, saveSliderTextLabelFrame;
@property double tempHighlightPCT1, tempHighlightPCT2;
@property int tempHighlightNumLines;
@property (nonatomic) int playbackSpeed;
@property CGPoint tempHighlightImagePoint1, tempHighlightImagePoint2;
@property BOOL haveTempHighlight;
@property int tempClipStatus;
@property float tempClipStart, tempClipEnd;
@property float saveClipStart, saveClipEnd;
@property NSMutableArray *barMarkers;
@property UIPanGestureRecognizer *panBarMarker;
@property UIPanGestureRecognizer *dragClipMarker;
@property BarMarker *selectedBarMarker;
@property UILabel *clipMarker;
@property SystemSoundID soundID;
@property float widthFactor;
//@property(nonatomic,strong) AVAudioEngine *AVaudioEngine;
@property AudioEngine * audioEngine;
@property int keepGoing;
@property float loopDelay;
@property CAShapeLayer *highlightLayer;

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
    _instrument = @"6 String Electric";
    _tuning = @"Standard";
    _currentCollection = @"All Practice Groups";
    _currentCollectionLabel.text = _currentCollection;

    _playbackFile = [NSTemporaryDirectory() stringByAppendingString:@"mixerOutput.caf"];
    self.playerView.delegate = self;
    [self createAllViewsArray];
    _hTranImageToView = _hTranViewToImage = 0;
    //_ImageDisplay.backgroundColor = [UIColor grayColor];
//    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
//    [_ImageDisplay addGestureRecognizer:_tapGestureRecognizer];
    _tapGestureRecognizerFullScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFullScreenTapFrom:)];
    [_fullScreenImageDisplay addGestureRecognizer:_tapGestureRecognizerFullScreen];
    _longPressRecognizerFullScreen = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    //_longPressRecognizerFullScreen.minimumPressDuration = 2;
    [_fullScreenImageDisplay addGestureRecognizer:_longPressRecognizerFullScreen];

    _tapGestureRecognizer.delegate = self;
    self.currentImageID = -1;
    _numHighlightLines = 0;
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
    _playbackSpeed = 10;
    CGRect b = self.view.bounds;
    _barMarkers = NSMutableArray.new;
    _panBarMarker = nil;
    return;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int top = self.view.safeAreaInsets.top;
    CGRect b = self.view.bounds;
    return;
}
- (void) viewDidAppear:(BOOL)animated
{
    static BOOL first = TRUE;
    [super viewDidAppear:animated];
    if (first)
        [self adjustControls];
    first = FALSE;
    return;
}
- (void) adjustControls
{

    int top = self.view.safeAreaInsets.top;
    CGRect b = self.view.bounds;
    UIEdgeInsets ei = self.view.safeAreaInsets;
    RECT FromRect, ToRect;
    FromRect.left = 0;
    FromRect.top = 20;
    FromRect.right = 1366;
    FromRect.bottom = 1024;
    ToRect.left = b.origin.x + ei.left;
    ToRect.top = b.origin.y + ei.top;
    ToRect.bottom = b.origin.y + b.size.height - ei.bottom;
    ToRect.right = b.origin.x + b.size.width - ei.right;
    HANDLE hTranScreen = STRANRect(&FromRect, &ToRect);
    _widthFactor = (float)(ToRect.right - ToRect.left) / (float)(FromRect.right - FromRect.left);
    float heightFactor = (float)(ToRect.bottom - ToRect.top) / (float)(FromRect.bottom - FromRect.top);
/*    BOOL saveControls = NO;
    if (saveControls)
    {
        NSError *error=nil;
        NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"ControlsDatabase.slt"];
        [NSFileManager.defaultManager removeItemAtPath:filePath
                                                 error:&error];
        _isOpen = !SQLOK(__FILE__,__LINE__,SQLite_Open(filePath.UTF8String, &_database), _database);
        NSString *cmd = @"CREATE TABLE IF NOT EXISTS CONTROLS ('ControlID' INTEGER PRIMARY KEY,'ControlNum' INT,'Type' INT,'OriginX' FLOAT, 'OriginY' FLOAT, 'Width' FLOAT,'HEIGHT' FLOAT, 'TEXTSIZE' FLOAT);";
        BOOL rtn = [self executeCmd:cmd];
        SQLOK(__FILE__,__LINE__,SQLite_Close(&_database),_database);
*/
      //  allViewsArray, *allButtonsArray, *allLabelsArray, *allTextFieldsArray, *allSteppersArray, *allSlidersArray, *allSwitchArray
        ControlTypes type=CTBUTTON;
    CGRect frame;
    RECT fromRect, toRect;
    float textHeight;
    type=CTVIEW;
for (UIView *view in _allViewsArray)
{
    frame = view.frame;
    fromRect = CGRectToRect(frame);
    toRect = TranRect(&fromRect, hTranScreen);
    frame = RECTtoCGRect(toRect);
    [view setFrame:frame];

}
    type = CTFILLEDBUTTON;
    _filledButtonTitleFontArray = NSMutableArray.new;
    _filledButtonSubTitleFontArray = NSMutableArray.new;
    for (UIButton *button in _allFilledButtonsArray)
     {
         frame = button.frame;
         fromRect = CGRectToRect(frame);
         toRect = TranRect(&fromRect, hTranScreen);
         frame = RECTtoCGRect(toRect);
         UIFont *font = button.titleLabel.font.copy;
         float fontSize = font.pointSize;
         fontSize *= heightFactor;
         font = [font fontWithSize:fontSize];
         [_filledButtonTitleFontArray addObject:font];
         [button.titleLabel setFont:font.copy];
         font = button.subtitleLabel.font.copy;
         fontSize = font.pointSize;
         fontSize *= heightFactor;
         font = [font fontWithSize:fontSize];
         [_filledButtonSubTitleFontArray addObject:font];
         [button.subtitleLabel setFont:font.copy];
         [button.subtitleLabel setAdjustsFontSizeToFitWidth:YES];
         [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
         //[button setContentScaleFactor:0.2];
         button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
         [button setFrame:frame];

     }
    type = CTBUTTON;
    for (UIButton *button in _allButtonsArray)
     {
         frame = button.frame;
         fromRect = CGRectToRect(frame);
         toRect = TranRect(&fromRect, hTranScreen);
         frame = RECTtoCGRect(toRect);
         UIFont *font = button.titleLabel.font;
         float fontSize = font.pointSize;
         fontSize *= heightFactor;
         font = [font fontWithSize:fontSize];
         [button.titleLabel setFont:font];
         [button.subtitleLabel setAdjustsFontSizeToFitWidth:YES];
         [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
         button.autoresizingMask = UIViewAutoresizingNone;
         button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
         [button setFrame:frame];
     }
type=CTLABEL;
    for (UILabel *label in _allLabelsArray)
    {
        frame = label.frame;
        fromRect = CGRectToRect(frame);
        toRect = TranRect(&fromRect, hTranScreen);
        frame = RECTtoCGRect(toRect);
        label.adjustsFontSizeToFitWidth = YES;
        [label setFrame:frame];

    }
        type=CTTEXTFIELD;
        for (UITextField *tf in _allTextFieldsArray)
        {
            frame = tf.frame;
            fromRect = CGRectToRect(frame);
            toRect = TranRect(&fromRect, hTranScreen);
            frame = RECTtoCGRect(toRect);
            [tf setFrame:frame];

        }
        type=CTSTEPPER;
        for (UIStepper *stepper in _allSteppersArray)
        {
            frame = stepper.frame;
            fromRect = CGRectToRect(frame);
            toRect = TranRect(&fromRect, hTranScreen);
            frame = RECTtoCGRect(toRect);
            [stepper setFrame:frame];

        }
        type=CTSLIDER;
        for (UISlider *slider in _allSlidersArray)
        {
            frame = slider.frame;
            fromRect = CGRectToRect(frame);
            toRect = TranRect(&fromRect, hTranScreen);
            frame = RECTtoCGRect(toRect);
            [slider setFrame:frame];

        }
        type=CTSWITCH;
        for (UISwitch *sw in _allSwitchArray)
        {
            frame = sw.frame;
            fromRect = CGRectToRect(frame);
            toRect = TranRect(&fromRect, hTranScreen);
            frame = RECTtoCGRect(toRect);
            [sw setFrame:frame];

        }
//        uploadToCloud(filePath, NO);
        
//    }
    
    CGRect imageRect = _ImageDisplay.frame;
    CGRect selfRect = self.view.frame;
    [self.playerView setFrame:imageRect];
    int newWidth = selfRect.size.width - imageRect.origin.x;
    int newHeight = selfRect.size.height - imageRect.origin.y;
    imageRect.size.width = newWidth;
    imageRect.size.height = newHeight;
    imageRect.size.width -= 2;
    imageRect.size.height -= 2;
    [_imageFrame setFrame:imageRect];
    imageRect.origin.x += 2;
    imageRect.origin.y += 2;
    imageRect.size.width -= 4;
    imageRect.size.height -= 4;
    [_ImageDisplay setFrame:imageRect];
    [_ImageDisplay removeFromSuperview];
    [self.view addSubview:_ImageDisplay];
    frame = _monitorButton.frame;
    frame = _effectsButton.frame;
    frame = _tunerButton.frame;
    CloseTRANS2(&hTranScreen);

}

- (void) resetFilledFonts
{
    return;
    int i = 0;
    for (UIButton *button in _allFilledButtonsArray)
     {
         UIFont *font = _filledButtonTitleFontArray[i];
         float size = font.pointSize;
         UIFont *currentFont = button.titleLabel.font;
         font = [currentFont fontWithSize:size];
         [button.titleLabel setFont:font.copy];
         font = _filledButtonSubTitleFontArray[i];
         [button.subtitleLabel setFont:font.copy];
         [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
         [button.subtitleLabel setAdjustsFontSizeToFitWidth:YES];
         i++;
     }
}
- (void) setBeginTime:(double)beginTime
{
    _beginTime = beginTime;
    return;
}
- (void) setEndTime:(double)endTime
{
    _endTime = endTime;
    return;
}

- (void) setCurrentImageID:(long)currentImageID
{
    _currentImageID = currentImageID;
    return;
}
- (void) handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (_panBarMarker || _tempClipStatus > 0)
        return;
    [self stopTapped:nil];
    if (recognizer.state == 3)
    {
        CGPoint location = [recognizer locationInView:_fullScreenImageDisplay];
        NSLog (@"Long press at:%.1f %.1f  state=%i",location.x,location.y,(int)recognizer.state);
        _haveStartLocation = YES;
        _beginTime = [self barBeginTime:location
                             pctAtBegin:&_tempHighlightPCT1];
    }
    return;

}
- (void) handleFullScreenTapFrom: (UITapGestureRecognizer *)recognizer
{
    if (_panBarMarker || _tempClipStatus > 0)
        return;
    if (!_haveStartLocation && !_numBarsInClip)
        return;
    [self stopTapped:nil];
    CGPoint location = [recognizer locationInView:_fullScreenImageDisplay];
    NSLog (@"Tap at:%.1f %.1f]",location.x,location.y);
    if (!_haveStartLocation)
        _beginTime = [self barBeginTime:location
                             pctAtBegin:&_tempHighlightPCT1];
    _endTime = [self barEndTime:location
                     pctAtEnd:&_tempHighlightPCT2];
    _haveStartLocation = NO;
    _tempClipStatus = -1;
    //_tempHighlightPCT1 = max(0,(_beginTime - _clipStartTime) /(_clipEndTime - _clipStartTime));
    //_tempHighlightPCT2 = min (1,(_endTime - _clipStartTime) /(_clipEndTime - _clipStartTime));
    [self saveTrackData];
    [self createTempHighlight:_tempHighlightPCT1
                        toPCT:_tempHighlightPCT2];
    [self restoreTrackData];
    return;
}

- (CGPoint) pointAtPCT:(double)pct
             andOffset:(double)offset
           onTrackLine:(int)online
{
    CGPoint rtn = {0,0};
    DPOINT pt = _trackPoints[online*2];
    double dist = pct * _trackLineWidths[online];
    pt.x += dist;
    pt.y -= offset;
    rtn = DPointToCGPoint(pt);
    return rtn;
}

- (CGPoint) PointOnTrackLinesAtPCT:(double)pct
                         andOffset:(double)off
                            onLine:(int*)atLine
                       atPCTOnLine:(double*)pctOnLine;
{
    CGPoint rtn = {0,0};
    
    double dist = pct * _totTrackLineWidth;
    int online = 0;
    double tlw = _trackLineWidths[online];
    while (dist > _trackLineWidths[online])
    {
        tlw = _trackLineWidths[online];
        if (online >= _numTrackLines - 1)
            break;
        else
        {
            dist -=  _trackLineWidths[online];
            online++;
        }
    }
    DPOINT pt = _trackPoints[online*2];
    pt.x += dist;
    pt.y -= off;
    double pctAlongLine = dist/_trackLineWidths[online];
    *pctOnLine = pctAlongLine;
    *atLine = online;
    rtn = DPointToCGPoint(pt);
    return rtn;
}
- (void) createTempHighlight:(float)fromPCT
                      toPCT:(float)toPCT
{
    int atLine1, atLine2;
    double pctAlongLine1, pctAlongLine2;
    CGPoint fromPt = [self PointOnTrackLinesAtPCT:fromPCT
                                         andOffset:_trackLineSpacing
                                            onLine:&atLine1
                                      atPCTOnLine:&pctAlongLine1];
    CGPoint toPt = [self PointOnTrackLinesAtPCT:toPCT
                                        andOffset:0
                                         onLine:&atLine2
                                    atPCTOnLine:&pctAlongLine2];
    _tempHighlightNumLines = atLine2 - atLine1 + 1;
    CGRect viewFrame = [self imageRectInView:_fullScreenImageDisplay];
    CGRect imageFrame = CGRectMake(0,0,  _fullScreenImageDisplay.image.size.width, _fullScreenImageDisplay.image.size.height);
    HANDLE hTranImageToView = STRANCGRect (imageFrame,viewFrame);
    HANDLE hTranViewToImage = STRANCGRect (viewFrame,imageFrame);
    _tempHighlightImagePoint1 = TranCGPoint(fromPt, hTranViewToImage);
    _tempHighlightImagePoint2 = TranCGPoint(toPt, hTranViewToImage);
    [self createHighlight:_tempHighlightImagePoint1
                   point2:_tempHighlightImagePoint2
                 numLines:_tempHighlightNumLines
                   inView:_fullScreenImageDisplay
                    hTran:hTranImageToView
                 doUpdate:NO];
    CloseTRANS2 (&hTranImageToView);
    CloseTRANS2 (&hTranViewToImage);
    _haveTempHighlight = YES;
}
- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    if (_panBarMarker)
        return;
    CGPoint location = [recognizer locationInView:_ImageDisplay];
    switch (_highlightPointNumber)
    {
        case 1:
            _highlightPoint1 = location;
            _highlightPointNumber++;
            [_imageHighlightInstructions setText:@"Drag the green dot to the bottom of the tab at the end of the clip"];
            break;
        case 2:
        {
            UIImageView *view = _ImageDisplay;
            _highlightPoint2 = location;
            _highlightRect = _ImageDisplay.frame;
            CGRect viewFrame = [self imageRectInView:_ImageDisplay];
            CGRect imageFrame = CGRectMake(0,0,  view.image.size.width, view.image.size.height);
            HANDLE hTranImageToView = STRANCGRect (imageFrame,viewFrame);
            HANDLE hTranViewToImage = STRANCGRect (viewFrame,imageFrame);
            CGPoint imagePoint1 = TranCGPoint(_highlightPoint1,hTranViewToImage);
            CGPoint imagePoint2 = TranCGPoint(_highlightPoint2,hTranViewToImage);
            [self createHighlight:imagePoint1
                           point2:imagePoint2
                         numLines:_numHighlightLines
                           inView:_ImageDisplay
                            hTran:hTranImageToView
                         doUpdate:YES];
            CloseTRANS2 (&hTranImageToView);
            CloseTRANS2 (&hTranViewToImage);
            [_imageHighlightInstructions setText:@""];
        }
            break;
        default:
            break;
    }
    return;
}

- (void) clearBarMarkers:(BOOL)screenOnly
{
    for (BarMarker *barMarker in _barMarkers)
    {
        [barMarker.label removeFromSuperview];
    }
    if (_panBarMarker)
    {
        [_panBarMarker cancelsTouchesInView];
        [_panBarMarker setEnabled:NO];
        [_panBarMarker setDelegate:nil];
        [_ImageDisplay removeGestureRecognizer:_panBarMarker];
        _panBarMarker = nil;
    }
    if (_tapBarMarker)
    {
        [_tapBarMarker cancelsTouchesInView];
        [_tapBarMarker setEnabled:NO];
        [_tapBarMarker setDelegate:nil];
        [_ImageDisplay removeGestureRecognizer:_tapBarMarker];
        _tapBarMarker = nil;
    }
    if (screenOnly)
        return;
    _barMarkers = NSMutableArray.new;
}
- (void) createBarMarkers:(int)numMarkers
{
    [self clearBarMarkers:NO];
    _selectedBarMarker = nil;
    if (!_numTrackLines)
        return;
    float offset = _trackLineSpacing;
    [_addImageButton setHidden:YES];

    _creatingBarMarkers = TRUE;
    double pct = 0;
    int atLine;
    double pctInc = 1.0/(numMarkers);
    float startTime = _clipStartTime;
    float timeInc = (_clipEndTime - _clipStartTime)/numMarkers;
    numMarkers++;
    for (int i = 0;i<numMarkers;i++)
    {
        double pctAlongLine = 0;
        CGPoint pt = [self PointOnTrackLinesAtPCT:pct
                                        andOffset:offset
                                           onLine:&atLine
                                      atPCTOnLine:&pctAlongLine];
        BarMarker *barMarker = BarMarker.new;
        barMarker.markerNum = i+1;
        barMarker.pctAlongClip = pct;
        barMarker.pctAlongBeginLine = pctAlongLine;
        barMarker.beginLine = atLine;
        barMarker.fromTime = startTime;
        if (barMarker.markerNum < numMarkers)
            startTime += timeInc;
        barMarker.toTime = startTime;
        [_barMarkers addObject:barMarker];
        pct += pctInc;
    }
    return;
}

- (void)editBarMarkers
{
    [self displayBarTimeButtons:YES];
    float offset = _trackLineSpacing;
    _tapBarMarker = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barMarkerDragged:)];
    [_ImageDisplay addGestureRecognizer:_tapBarMarker];

    _panBarMarker = UIPanGestureRecognizer.new;
    [_panBarMarker addTarget:self action:@selector(barMarkerDragged:)];
    [_ImageDisplay addGestureRecognizer:_panBarMarker];
    for (BarMarker *bm in _barMarkers)
    {
        [bm.label setText:[NSString stringWithFormat:@"%i",bm.markerNum]];
        bm.label.numberOfLines = 2;
        bm.label.lineBreakMode = UILineBreakModeCharacterWrap;
        bm.label.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.0 alpha:1];
        CGPoint pt = [self pointAtPCT:bm.pctAlongBeginLine
                            andOffset:offset
                          onTrackLine:bm.beginLine];
        CGRect frame = CGRectMake(pt.x,pt.y,9,offset);
        [bm.label setFrame:frame];
        [_ImageDisplay addSubview:bm.label];
    }

}

- (void)barMarkerDragged:(UIPanGestureRecognizer *)gesture
{
    static DPOINT lastPoint;
    CGPoint pt = [gesture locationInView:_ImageDisplay];
    DPOINT curLoc = CGPointToDPOINT(pt);
    switch (gesture.state)
    {
        case UIGestureRecognizerStateEnded:
            NSLog (@"Ended");
            if (gesture != _tapBarMarker)
                break;
        case UIGestureRecognizerStateBegan:
        {
            NSLog (@"Began");
            if (_selectedBarMarker)
                [_selectedBarMarker.label setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:0.0 alpha:0.5]];
            CGFloat minDist = MAXFLOAT;
            lastPoint = curLoc;
            for (BarMarker* marker in _barMarkers)
            {
                DPOINT barLoc;
                barLoc.x = marker.label.frame.origin.x;
                barLoc.y = marker.label.frame.origin.y + marker.label.frame.size.height * 0.75;
                float dist = ldistpp (&curLoc,&barLoc);
                if (dist < minDist)
                {
                    minDist = dist;
                    _selectedBarMarker = marker;
                }
            }
            if (_selectedBarMarker)
            {
                [_selectedBarMarker.label setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:0.0 alpha:0.5]];
                [_selectedBarMarker.label setBackgroundColor:UIColor.redColor];
                [self updateSliderText:_selectedBarMarker.fromTime];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog (@"Changed");
            float xdiff = curLoc.x - lastPoint.x;
            CGRect frame = _selectedBarMarker.label.frame;
            frame.origin.x += xdiff;
            if ((curLoc.y - (frame.origin.y + frame.size.height) > _trackLineSpacing) && _selectedBarMarker.beginLine < _numTrackLines)
            {
                frame.origin.y += _trackLineSpacing;
                _selectedBarMarker.beginLine++;
            }
            else if (((frame.origin.y + frame.size.height) - curLoc.y  > _trackLineSpacing) && _selectedBarMarker.beginLine > 0)
            {
                frame.origin.y -= _trackLineSpacing;
                _selectedBarMarker.beginLine--;
            }
            float pct = [self pctInClip:frame.origin];
            float newTime = _clipStartTime + pct * (_clipEndTime - _clipStartTime);
            _selectedBarMarker.fromTime = newTime;
            [_selectedBarMarker.label setFrame:frame];
            [self updateSliderText:_selectedBarMarker.fromTime];
            lastPoint = curLoc;
        }
            break;
        default:
            NSLog (@"State:%i",(int)gesture.state);
            break;
    }
}

- (void)clipMarkerDragged:(UIPanGestureRecognizer *)gesture
{
    static DPOINT lastPoint;
    CGPoint pt = [gesture locationInView:_ImageDisplay];
    DPOINT curLoc = CGPointToDPOINT(pt);
    switch (gesture.state)
    {
        case UIGestureRecognizerStateEnded:
            NSLog (@"Ended");
            switch (_highlightPointNumber)
            {
                case 1:
                    _highlightPoint1 = _clipMarker.center;
                    _highlightPointNumber++;
                    _clipMarker.backgroundColor = UIColor.greenColor;
                    CGPoint center;
                    center.x = _ImageDisplay.frame.size.width / 2;
                    center.y = _ImageDisplay.frame.size.height /2;

                    _clipMarker.center = center;
                    [_imageHighlightInstructions setText:@"Drag the green dot to the bottom of the tab at the end of the clip"];
                    break;
                case 2:
                {
                    UIImageView *view = _ImageDisplay;
                    _highlightPoint2 = _clipMarker.center;
                    _highlightRect = _ImageDisplay.frame;
                    CGRect viewFrame = [self imageRectInView:_ImageDisplay];
                    CGRect imageFrame = CGRectMake(0,0,  view.image.size.width, view.image.size.height);
                    HANDLE hTranImageToView = STRANCGRect (imageFrame,viewFrame);
                    HANDLE hTranViewToImage = STRANCGRect (viewFrame,imageFrame);
                    CGPoint imagePoint1 = TranCGPoint(_highlightPoint1,hTranViewToImage);
                    CGPoint imagePoint2 = TranCGPoint(_highlightPoint2,hTranViewToImage);
                    [self createHighlight:imagePoint1
                                   point2:imagePoint2
                                 numLines:_numHighlightLines
                                   inView:_ImageDisplay
                                    hTran:hTranImageToView
                                 doUpdate:YES];
                    CloseTRANS2 (&hTranImageToView);
                    CloseTRANS2 (&hTranViewToImage);
                    [_imageHighlightInstructions setText:@""];
                    if (_dragClipMarker)
                    {
                        [_dragClipMarker cancelsTouchesInView];
                        [_dragClipMarker setEnabled:NO];
                        [_dragClipMarker setDelegate:nil];
                        [_ImageDisplay removeGestureRecognizer:_dragClipMarker];
                        _dragClipMarker = nil;
                    }
                    if (_clipMarker)
                        [_clipMarker removeFromSuperview];                                 }
                    break;
            }
        case UIGestureRecognizerStateBegan:
        {
            NSLog (@"Began");
            lastPoint = curLoc;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog (@"Changed");
            float xdiff = curLoc.x - lastPoint.x;
            float ydiff = curLoc.y - lastPoint.y;
            CGPoint newCenter = _clipMarker.center;
            newCenter.x += xdiff;
            newCenter.y += ydiff;
            _clipMarker.center = newCenter;
            lastPoint = curLoc;
        }
            break;
        default:
            NSLog (@"State:%i",(int)gesture.state);
            break;
    }
}

-(void) createAllViewsArray
{
    _allViewsArray = NSMutableArray.new;
    [_allViewsArray addObject:self.playerView];
    [_allViewsArray addObject:_ImageDisplay];
    [_allViewsArray addObject:_imageFrame];
    [_allViewsArray addObject:_fullScreenImageDisplay];
    [_allViewsArray addObject:_playerView];

    _allFilledButtonsArray = NSMutableArray.new;
    [_allFilledButtonsArray addObject:_playbackSpeedButton];

    _allButtonsArray = NSMutableArray.new;
    [_allButtonsArray addObject:_fullScreenButton];
    [_allButtonsArray addObject:_fullScreenReturnButton];
    [_allButtonsArray addObject:_playSegmentButton];
    [_allButtonsArray addObject:_loopSegmentButton];
    [_allButtonsArray addObject:_selectCollectionButton];
    [_allButtonsArray addObject:_playButton];
    [_allButtonsArray addObject:_beginButton];
    [_allButtonsArray addObject:_endButton];
    [_allButtonsArray addObject:_nextClipButton];
    [_allButtonsArray addObject:_priorClipButton];
    [_allButtonsArray addObject:_saveButton];
    [_allButtonsArray addObject:_pauseButton];
    [_allButtonsArray addObject:_addImageButton];
    [_allButtonsArray addObject:_saveImageButton];
    [_allButtonsArray addObject:_cancelImageButton];
    [_allButtonsArray addObject:_startTimeSaveButton];
    [_allButtonsArray addObject:_startTimeCancelButton];
    [_allButtonsArray addObject:_pasteURLButton];
    [_allButtonsArray addObject:_gotoYouTubeButton];
    [_allButtonsArray addObject:_continueButton];
    [_allButtonsArray addObject:_stepAheadButton];
    [_allButtonsArray addObject:_stepBackButton];
    [_allButtonsArray addObject:_clipButton];
    [_allButtonsArray addObject:_cancelEditButton];
    [_allButtonsArray addObject:_changeBeginButton];
    [_allButtonsArray addObject:_changeEndButton];
    [_allButtonsArray addObject:_deleteClipButton];
    [_allButtonsArray addObject:_tunerButton];
    [_allButtonsArray addObject:_playbackSpeedDecreaseButton];
    [_allButtonsArray addObject:_playbackSpeedIncreaseButton];
    [_allButtonsArray addObject:_tempClipButton];
    [_allButtonsArray addObject:_monitorButton];
    [_allButtonsArray addObject:_effectsButton];
    [_allButtonsArray addObject:_imageStartAtButton];
    [_allButtonsArray addObject:_imageEndAtButton];
    [_allButtonsArray addObject:_marginDecreaseButton];
    [_allButtonsArray addObject:_marginIncreaseButton];
    [_allButtonsArray addObject:_marginSelectionButton];
    [_allButtonsArray addObject:_nextSongButton];
    [_allButtonsArray addObject:_selectSongButton];
    [_allButtonsArray addObject:_tempClipEditButton];
    [_allButtonsArray addObject:_decreaseTempButton];
    [_allButtonsArray addObject:_increaseTempButton];

    _allLabelsArray = NSMutableArray.new;
    [_allLabelsArray addObject:_songTitleLabel];
    [_allLabelsArray addObject:_numClipsLabel];
    [_allLabelsArray addObject:_currentCollectionLabel];
    [_allLabelsArray addObject:_startTimeTitle];
    [_allLabelsArray addObject:_startTimeMinutesTitle];
    [_allLabelsArray addObject:_startTimeSecondsTitle];
    [_allLabelsArray addObject:_linkNameLabel];
    [_allLabelsArray addObject:_linkURLLabel];
    [_allLabelsArray addObject:_sliderTextLabel];
    [_allLabelsArray addObject:_tapToEditLabel];
    [_allLabelsArray addObject:_imageHighlightInstructions];
    [_allLabelsArray addObject:_highlightLinesLabel];
    [_allLabelsArray addObject:_highlightBarsLabel];
    [_allLabelsArray addObject:_delayLabel];
    [_allLabelsArray addObject:_recordLabel];

    _allTextFieldsArray = NSMutableArray.new;
    [_allTextFieldsArray addObject:_startTimeMinutesInput];
    [_allTextFieldsArray addObject:_startTimeSecondsInput];
    [_allTextFieldsArray addObject:_linkName];
    [_allTextFieldsArray addObject:_linkURLField];

    _allSteppersArray = NSMutableArray.new;
    [_allSteppersArray addObject:_startTimeMinutesStepper];
    [_allSteppersArray addObject:_startTimeSecondsStepper];
    [_allSteppersArray addObject:_highlightLinesStepper];
    [_allSteppersArray addObject:_highlightBarsStepper];

    _allSlidersArray = NSMutableArray.new;
    [_allSlidersArray addObject:_slider];
    [_allSlidersArray addObject:_monitorVolumeSlider];
    
    _allSwitchArray = NSMutableArray.new;
    [_allSwitchArray addObject:_delaySwitch];
    [_allSwitchArray addObject:_recordSwitch];

    _allControlArraysArray = NSMutableArray.new;
    [_allControlArraysArray addObject:_allViewsArray];
    [_allControlArraysArray addObject:_allFilledButtonsArray];
    [_allControlArraysArray addObject:_allButtonsArray];
    [_allControlArraysArray addObject:_allLabelsArray];
    [_allControlArraysArray addObject:_allTextFieldsArray];
    [_allControlArraysArray addObject:_allSteppersArray];
    [_allControlArraysArray addObject:_allSlidersArray];
    [_allControlArraysArray addObject:_allSwitchArray];

}
-(void) hideAllViews:(BOOL)hide
{
    if (hide)
    {
        _allViewsAndStatusArray = NSMutableArray.new;
        for (NSMutableArray *array in _allControlArraysArray)
        {
            for (UIView *view in array)
            {
                ViewAndStatus *vands = ViewAndStatus.new;
                vands.view = view;
                vands.status = view.isHidden;
                [_allViewsAndStatusArray addObject:vands];
                [view setHidden:hide];
            }
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
            [_continueButton setHidden:YES];
            [_pauseButton setHidden:NO];

            _playerIsPlaying = TRUE;
            break;
        case kYTPlayerStatePaused:
            NSLog(@"Paused playback");
            [_continueButton setHidden:NO];
            [_pauseButton setHidden:YES];
            _playerIsPlaying = FALSE;
            break;
        case kYTPlayerStateEnded:
            NSLog(@"Ended playback");
            _playerIsPlaying = FALSE;
            break;
        case kYTPlayerStateBuffering:
            NSLog(@"Buffering");
            _playerIsPlaying = FALSE;
            break;
        case kYTPlayerStateUnstarted:
            NSLog(@"Unstarted");
            [self pauseVideoAfterTime:0.5];
            _playerIsPlaying = FALSE;
            break;
        case kYTPlayerStateCued:
            NSLog(@"Qued playback");
            break;
        default:
            ii=1;
            break;
    }
}
-(void) doPauseVideo:(NSTimer*)time
{
    [self.playerView pauseVideo];
}

-(void) pauseVideoAfterTime:(float)time
{
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(doPauseVideo:) userInfo:nil repeats:NO];
}

-(BOOL) createCollection:(NSString *)name
                   under:(long)parentID
{
    _currentCollection = name;
    int type = 1;
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO COLLECTIONS (Title,Parent,Type)  VALUES('%@',%li,%i)",name,parentID,type];
    [self executeCmd:cmd];
    
    [self close:opened];

    return TRUE;
}

- (double) pctInClip:(CGPoint)location
{
    DPOINT atPoint = CGPointToDPOINT (location);
    DPOINT intPoint;
    int leftOrRight;
    double minDist = DBL_MAX;
    double alongLine = 0;
    double totLen = 0;
    int nearLine = 0;
    for (int onLine = 0;onLine < _numTrackLines;onLine++)
    {
        if (GetPerpendicularIntersect (&atPoint,&_trackPoints[onLine * 2],&intPoint,TRUE,&leftOrRight))
        {
            if (leftOrRight == RIGHT)//RIGHT because coord system is down is increasing y
            {
                double offDist = ldistpp (&atPoint,&intPoint);
                if (offDist <= minDist)
                {
                    minDist = offDist;
                    nearLine = onLine;
                    alongLine = ldistpp (&intPoint,&_trackPoints[onLine * 2]);
                }
            }
        }
    }
    for (int i = 0; i < _numTrackLines; i++)
    {
        if (i < nearLine)
            alongLine += _trackLineWidths[i];
        totLen += _trackLineWidths[i];
    }
    double pctAlongLine = alongLine / totLen;

    return pctAlongLine;
}

- (double) timeAlongLineInClip:(CGPoint)location
                        onLine:(int *)pOnLine
                         inBar:(int *) pinBar
                   atPCTinClip:(double *)atPCT
{
    double rtn = 0;
    double pct = 0;
    int onLine;
    int markerNum = 0;
    BarMarker *bar = nil;
    double pctOnLine = [self pctAlongLineInClip:location onLine:&onLine];
    
    if (_barMarkers.count < 1)
    {
        rtn = pctOnLine * (_clipEndTime - _clipStartTime) + _clipStartTime;
    }
    else
    {
        for (BarMarker *bm in _barMarkers)
        {
            if (bm.endLine >= onLine && bm.beginLine <= onLine)
            {
                double totBarDist = [self totDistInBar:bm];
                double distInBar = [self barDistAtPctInBarLine:pctOnLine
                                                      onLine:onLine
                                                       inBar:bm];
                if (distInBar < 0 || distInBar > totBarDist)
                    continue;
                double pctInBar = distInBar / totBarDist;
                rtn = bm.fromTime + pctInBar * [self totTimeInBar:bm];
                markerNum = bm.markerNum;
                double distInPreviousBars = [self distInPrevBars:markerNum];
                pct = (distInPreviousBars + distInBar)/_totTrackLineWidth;
                break;
            }
        }
    }
    *pOnLine = onLine;
    *pinBar = markerNum;
    *atPCT = pct;
    return rtn;
}

- (void) computeDistToFirstTrack
{
    _distToFirstTrack = 0;
    if (_barMarkers.count <= 1)
        return;
    BarMarker * bm = _barMarkers[0];
    int onLine = bm.beginLine;
    DPOINT tp = _trackPoints[onLine*2];
    DPOINT pt = tp;
    float tw = _trackLineWidths[onLine] * bm.pctAlongBeginLine;
    pt.x += tw;
    _distToFirstTrack = ldistp (tp,pt);
    return;
}

-(double) distInPrevBars:(int)marker
{
    [self computeDistToFirstTrack];
    double dist = _distToFirstTrack;
    for (BarMarker *bm in _barMarkers)
    {
        if (bm.markerNum < marker)
        {
            double totBarDist = [self totDistInBar:bm];
            dist += totBarDist;
        }
    }
    return dist;
}
-(double) barDistAtPctInBarLine:(double)pctOnLine
                        onLine:(int)onLine
                       inBar:(BarMarker *)bm
{
    double rtn = -1;
    
    double lineLen = _trackLineWidths[bm.beginLine];
    double distToStart = bm.pctAlongBeginLine * lineLen;
    if (bm.beginLine == bm.endLine)
    {
        if (pctOnLine < bm.pctAlongBeginLine || pctOnLine > bm.pctAlongEndLine)
            rtn = -1;
        else
        {
            double distToLoc = _trackLineWidths[bm.beginLine] * pctOnLine;
            rtn = distToLoc - distToStart;
        }
    }
    else
    {
        if (onLine == bm.beginLine)
        {
            if (pctOnLine < bm.pctAlongBeginLine)
                rtn = -1;
            else
                rtn = pctOnLine * _trackLineWidths[onLine] - distToStart;
        }
        else
        {
            double distAlongLine1 = bm.pctAlongBeginLine * _trackLineWidths[bm.beginLine];
            double totBarDist = lineLen - distAlongLine1;
            int line = bm.beginLine + 1;
            while (line < bm.endLine && line != onLine)
            {
                line++;
                totBarDist += _trackLineWidths[line];
            }
            if (line == onLine)
            {
                if (line != bm.endLine || pctOnLine <= bm.pctAlongEndLine)
                    rtn = totBarDist + pctOnLine * _trackLineWidths[line];
            }
        }
    }
    return rtn;
}

- (double) totDistInBar:(BarMarker *)bm
{
    double totBarDist = 0;
    double lineLen = _trackLineWidths[bm.beginLine];
    double distAlongLine1 = bm.pctAlongBeginLine * lineLen;
    if (bm.beginLine == bm.endLine)
        totBarDist = bm.pctAlongEndLine * lineLen - distAlongLine1;
    else
    {
        totBarDist = lineLen - distAlongLine1;
        int line = bm.beginLine + 1;
        while (line < bm.endLine)
        {
            line++;
            totBarDist += _trackLineWidths[line];
        }
        if (line == bm.endLine)
            totBarDist += bm.pctAlongEndLine * _trackLineWidths[line];
    }
    return totBarDist;
}
- (double) totTimeInBar:(BarMarker *)bm
{
    double time = bm.toTime - bm.fromTime;
    
    return time;
}
- (double) pctAlongLineInClip:(CGPoint)location
                       onLine:(int *)pOnLine
{
    DPOINT atPoint = CGPointToDPOINT (location);
    DPOINT intPoint;
    int leftOrRight;
    double minDist = DBL_MAX;
    double alongLine = 0;
    double totLen = 0;
    int nearLine = 0;
    float pctAlongLine = 0;
    for (int onLine = 0;onLine < _numTrackLines;onLine++)
    {
        if (GetPerpendicularIntersect (&atPoint,&_trackPoints[onLine * 2],&intPoint,TRUE,&leftOrRight))
        {
            if (leftOrRight == RIGHT)//RIGHT because coord system is down is increasing y
            {
                double offDist = ldistpp (&atPoint,&intPoint);
                if (offDist <= minDist)
                {
                    minDist = offDist;
                    nearLine = onLine;
                    alongLine = ldistpp (&intPoint,&_trackPoints[onLine * 2]);
                    pctAlongLine = alongLine / _trackLineWidths[onLine];
                }
            }
        }
    }
    *pOnLine = nearLine;
    return pctAlongLine;
}
- (double) barBeginTime:(CGPoint)location
            pctAtBegin:(double*) pctAtBegin
{
    double rtn = 0;
    double pct = [self pctInClip:location];
    rtn = pct * (_clipEndTime - _clipStartTime) + _clipStartTime;
    if (_numBarsInClip)
    {
        int onLine, inBar;
        BarMarker *bm;
        rtn = [self timeAlongLineInClip:location
                                 onLine:&onLine
                                  inBar:&inBar
                            atPCTinClip:&pct];
        if (inBar > 0)
        {
            bm = _barMarkers[inBar-1];
            rtn = bm.fromTime;
            double distInPreviousBars = [self distInPrevBars:inBar];
            pct = distInPreviousBars/_totTrackLineWidth;
        }
    }
    else if (pct > 0 && pct < 1)
        pct = 0;
    *pctAtBegin = pct;
    return rtn;
}
- (double) barEndTime:(CGPoint)location
          pctAtEnd:(double*)pctAtEnd
{
    double rtn = 0;
    double pct = [self pctInClip:location];
    rtn = pct * (_clipEndTime - _clipStartTime) + _clipStartTime;
    if (_numBarsInClip)
    {
        int onLine, inBar;
        BarMarker *bm;
        rtn = [self timeAlongLineInClip:location
                                 onLine:&onLine
                                  inBar:&inBar
                            atPCTinClip:&pct];
        if (inBar > 0)
        {
            bm = _barMarkers[inBar-1];
            rtn = bm.toTime;
            double distInPreviousBars = [self distInPrevBars:inBar+1];
            pct = distInPreviousBars/_totTrackLineWidth;
        }
    }
    else if (pct > 0 && pct < 1)
        pct = 1;
    *pctAtEnd = pct;
    return rtn;
}
- (void) setSliderValue:(double) value
{
    static BOOL useBarMarkers = TRUE;
    static double debugValue = 221.35;
    double inValue = value;
    
//    if (!_keepGoing)
//        return;
//    _keepGoing--;
    value *= 10;
    value = IDNINT(value);
    value /= 10;
//    if (value >= debugValue)
//        _keepGoing = 0;
    NSLog (@"%f,%f,%f",value,_slider.minimumValue,_slider.maximumValue);
    CGPoint pt={0,0};
    if (_inTimeTest)
    {
        useBarMarkers = FALSE;
        UIColor *color = UIColor.redColor;

        if ((value < _selectedBarMarker.fromTime && (_selectedBarMarker.fromTime - value) < 0.15) ||
            (value > _selectedBarMarker.fromTime && (value - _selectedBarMarker.fromTime) < 0.15))
        {
            color = UIColor.blueColor;
        }
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self->_selectedBarMarker.label setBackgroundColor:color];
        }];

        
    }
    if (_trackLabel)
    {
        if (_creatingBarMarkers || !_barMarkers || _barMarkers.count < 2)
            useBarMarkers = FALSE;
        if (useBarMarkers)
        {
            float cs = _clipStartTime;
            float ce = _clipEndTime;

            int index = 0;
            for (BarMarker * bm in _barMarkers)
            {
                if (value >= bm.fromTime && value <= bm.toTime)
                {
                    double pctInBar = (value - bm.fromTime)/(bm.toTime - bm.fromTime);
                    if (pctInBar > 0.5)
                        ii = 1;
                    if (bm.markerNum == _barMarkers.count)
                        ii = 1;
                    double lineLen = _trackLineWidths[bm.beginLine];
                    double distAlongLine1 = bm.pctAlongBeginLine * lineLen;
                    double totBarDist;
                    if (bm.beginLine == bm.endLine)
                        totBarDist = bm.pctAlongEndLine * lineLen - distAlongLine1;
                    else
                        totBarDist = lineLen - distAlongLine1;
                    int line = bm.beginLine + 1;
                    while (line < bm.endLine)
                    {
                        line++;
                        totBarDist += _trackLineWidths[line];
                    }
                    if (line == bm.endLine)
                        totBarDist += bm.pctAlongEndLine * _trackLineWidths[line];
                    double distInBar = totBarDist * pctInBar;
                    CGPoint barStartPoint;
                    if (bm.beginLine == bm.endLine)
                    {
                        barStartPoint = DPointToCGPoint(_trackPoints[bm.beginLine * 2]);
                        barStartPoint.x += distAlongLine1;
                        barStartPoint.x += distInBar;
                    }
                    else
                    {
                        int line = bm.beginLine;
                        lineLen = _trackLineWidths[line] - distAlongLine1;
                        double remDist = distInBar;
                        if (remDist < lineLen)
                        {
                            barStartPoint = DPointToCGPoint(_trackPoints[line * 2]);
                            barStartPoint.x += (distAlongLine1 + remDist);
                            double x1 = barStartPoint.x + _trackLineBasePoint.x;
                            double x2 = self.view.frame.origin.x + self.view.frame.size.width;
                            if (x1 > x2)
                                ii = 1;
                        }
                        else
                        {
                            if (_keepGoing > 1001)
                                _keepGoing = 6;
                            remDist -= lineLen;
                            line++;
                            while (line < bm.endLine)
                            {
                                if (remDist <= _trackLineWidths[line])
                                    break;
                                remDist -= _trackLineWidths[line];
                                line++;
                            }
                            barStartPoint = DPointToCGPoint(_trackPoints[line * 2]);
                            barStartPoint.x += remDist;
                            double x1 = barStartPoint.x + _trackLineBasePoint.x;
                            double x2 = self.view.frame.origin.x + self.view.frame.size.width;
                            if (x1 > x2)
                                ii = 1;

                        }
                    }
                    pt = barStartPoint;

                    double x1 = barStartPoint.x + _trackLineBasePoint.x;
                    double x2 = self.view.frame.origin.x + self.view.frame.size.width;
                    if (x1 > x2)
                        ii = 1;
                    pt.x += _trackLineBasePoint.x;
                    pt.y += _trackLineBasePoint.y;
                    if (pt.x > self.view.frame.origin.x + self.view.frame.size.width)
                        ii = 1;
                    break;
                }
                index++;
            }
        }
        else if (_numTrackLines && (_clipEndTime - _clipStartTime) > 0)
        {
            int onLine = 0;
            double pctAlongClip = (value - _clipStartTime)/(_clipEndTime - _clipStartTime);
            double distAlongClip = pctAlongClip * _totTrackLineWidth;
            double distAlongLines = _trackLineWidths[0];
            
            for (int i = 0;i<_numTrackLines-1;i++)
            {
                if (distAlongClip > distAlongLines)
                {
                    double d = _trackLineWidths[i];
                    distAlongClip -= d;
                    distAlongLines = _trackLineWidths[i+1];
                    onLine++;
                }
            }
            pt = DPointToCGPoint(_trackPoints[onLine * 2]);
            pt.x += distAlongClip;
            pt.x += _trackLineBasePoint.x;
            pt.y += _trackLineBasePoint.y;
            if (pt.x < 0)
                ii = 1;
        }
    }
    if (!_inAddImageMode)
    {
        long imageToLoad = 0;
        for (ImageAndTime *iat in _images)
        {
            if (value >= iat.fromTime && value < iat.toTime)
            {
                imageToLoad = iat.imageID;
                _leftMargin = iat.leftMargin;
                _rightMargin = iat.rightMargin;
            }
        }
        if (imageToLoad && imageToLoad != _currentImageID)
        {
            NSString *fileName = [NSString stringWithFormat:@"%@/%li.png",_imagesDirectory,imageToLoad];
            _image = [UIImage imageWithContentsOfFile:fileName];
            self.currentImageID = imageToLoad;
            if (_inFullScreen)
            {
                [self displayClipAddButtons:NO];
                [_fullScreenImageDisplay setImage:_image];
                [_fullScreenImageDisplay setHidden:NO];
                [_highlightLinesLabel setHidden:YES];
                [_highlightLinesStepper setHidden:YES];
                [_imageHighlightInstructions setHidden:YES];
                [self displayHighlightForClip:_currentClipID inView:_fullScreenImageDisplay];
            }
            else
            {
                [self displayClipAddButtons:YES];
                [_ImageDisplay setImage:_image];
                [_ImageDisplay setHidden:NO];
                [_fullScreenReturnButton setHidden:YES];
                [self displayHighlightForClip:_currentClipID inView:_ImageDisplay];
            }
        }
        /*
        else if (!imageToLoad && _currentImageID > -1)
        {
            self.currentImageID = -1;
            [_ImageDisplay setImage:nil];
            [self displayClipAddButtons:NO];
            [_ImageDisplay setHidden:NO];
            [_fullScreenButton setHidden:YES];
            [self removeHighlightFromView:_ImageDisplay];
        }
        else if (!imageToLoad)
        {
            [_fullScreenImageDisplay setHidden:YES];
            [_ImageDisplay setHidden:NO];
            [_fullScreenButton setHidden:YES];
        }*/
            
    }
    [self.slider setValue:value];
    NSString *sliderText = [NSString stringWithFormat:@"%.1f",value];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self.sliderTextLabel setText:sliderText];
        if (self.trackLabel && self.numTrackLines)
            self.trackLabel.center = pt;
        ii = 1;
    }];
    return;
}

-(void) setSliderRange
{
    NSString * sliderText = [NSString stringWithFormat:@"%.1f to %.1f",_beginTime,_endTime];
    [_sliderTextLabel setText:sliderText];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self.sliderTextLabel setText:sliderText];
    }];
}
-(NSArray *) getAllCollectionsUnder:(long) parentCollectionID
{
    NSMutableArray *rtn = NSMutableArray.new;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT CollectionID,Title,Type FROM COLLECTIONS WHERE Parent = %li ORDER BY(Title)",parentCollectionID];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        long cid = sqlite3_column_int64(statement, 0);
        LPSTR title = (LPSTR)sqlite3_column_text(statement, 1);
        int type = sqlite3_column_int(statement, 2);
        NSString *str = [NSString stringWithFormat:@"%s|%i|%li",title,type,cid];
        [rtn addObject:str];
   }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    return rtn;
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
    else if ([text isEqual:@"All Practice Groups"])
    {
        _currentCollection = text;
        [popoverTableView hide:YES];
        NSMutableArray *optionList = NSMutableArray.array;
        
        [self addSongsToList:optionList];
        NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                          delegate:self
                                                                             title:_currentCollection
                                                                         textArray:optionList
                                                                     includeCancel:YES];
        nvptv.identifier = @"Select Song";
        nvptv.allowsSubtitle = NO;
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
        [self displayImageHighlightButtons:NO];
        [_startTimeSaveButton setHidden:NO];
        [_startTimeCancelButton setHidden:NO];
        [_pasteURLButton setHidden:NO];
        
    }
    else if (stringBeginsWithString (popoverTableView.title,@"Verify Delete"))
    {
        [popoverTableView hide:YES];
        if ([text isEqual:@"Yes"])
        {
            [self deleteClip:_currentClipID];
        }
    }
    else if ([popoverTableView.identifier isEqual:@"Select Song"])
    {
        {
            NSString * url = [self getSong:text];
            if (url)
            {
                [popoverTableView hide:YES];
                if (_currentSongType == SONG)
                {
                    _images = [self getImagesForPracticeGroup:_currentPracticeGroupID];
                    _currentSongURL = [NSURL URLWithString:url];
                    if (![self startNewSong])
                        showAlert(@"Unable to access this song");
                }
                else
                {
                    _images = NSMutableArray.new;
                    _currentYouTubeLink = url;
                    [self displayYouTubeVideo:_currentYouTubeLink];
                }
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
    _clipIDs = NSMutableArray.new;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _barsInClip = NSMutableArray.new;
    _images = NSMutableArray.new;
    [self showMediaPicker];
    //[self setCurrentPositiion:NO];
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
        if ([self testNewSong])
        {
            [self saveSongURL:url
                     forTitle:_currentSongTitle
                       ofType:SONG
                     duration:_currentSongDuration
                    startTime:0];
            [self getSongWithTitle:_currentSongTitle];
            [self startNewSong];
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
    _clipIDs = NSMutableArray.new;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _barsInClip = NSMutableArray.new;
    _images = NSMutableArray.new;
    _currentClip = -1;
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
        [self updateClipButtons];
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
    _keepGoing = TRUE;
    if (_currentClip < 0)
    {
        _beginTime = _currentSongStartTime;
    }
    if (sender)
        self.endTime = _currentSongDuration;
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
            [_playerView setHidden:NO];
            [_ImageDisplay setHidden:YES];
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
    _currentTime = _appSoundPlayer.currentTime;

    _beginTime = _currentTime;
    _clipEditStatus = 1;
}

- (IBAction)changeEndTapped:(id)sender {
    [_stepBackButton setHidden:NO];
    [_stepAheadButton setHidden:NO];
    [_changeBeginButton setSelected:NO];
    [_changeEndButton setSelected:YES];
    _currentTime = _appSoundPlayer.currentTime;

    _endTime = _currentTime;
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
    
    if (_currentSongType == SONG)
        _endTime = _appSoundPlayer.currentTime;
    else
        _endTime = _currentYTTime;
    _numBarsInClip = 1;
    _numHighlightLines = 0;
    NSNumber *bTime = [NSNumber numberWithInt:_beginTime];
    NSNumber *eTime = [NSNumber numberWithInt:_endTime];
    NSNumber *nBars = [NSNumber numberWithInt:_numBarsInClip];
    [_endTimes addObject:eTime];
    [_beginTimes addObject:bTime];
    [_barsInClip addObject:nBars];
    _currentClip = (int)_endTimes.count - 1;
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO CLIPS (PracticeGroupID,STARTTIME,ENDTIME,BARS) VALUES(%li,%i,%i,%i)",(long)_currentPracticeGroupID,IDNINT(10*_beginTime),IDNINT(10*_endTime),_numBarsInClip];
    [self executeCmd:cmd];
    
    [self close:opened];
    _beginTime = _endTime;
    [self retrieveSong:_currentPracticeGroupID setTimes:NO];
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

-(void) computeBarPctOnLine:(BarMarker*) marker
{
    int onLine = marker.beginLine;
    if (onLine < _numTrackLines)
    {
        DPOINT tp = _trackPoints[onLine*2];
        float tw = _trackLineWidths[onLine];
        CGPoint pt = marker.label.frame.origin;
        double pct = (pt.x - tp.x)/_trackLineWidths[onLine];
        pct = max (0,pct);
        pct = min (1,pct);
        marker.pctAlongBeginLine = pct;
    }
    return;
}
- (void) saveBarMarkers
{
    _creatingBarMarkers = FALSE;

    if (!_barMarkers || !_barMarkers.count)
        return;
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM SUBCLIPS WHERE CLIPID = %i",_currentClipID];
    [self executeCmd:cmd];
    //reset image margins
/*    int minx = INT_MAX;
    int maxx = INT_MIN;
    for (BarMarker* marker in _barMarkers)
    {
        CGPoint pt = marker.label.frame.origin;
        pt = TranCGPoint(pt,_hTranViewToImage);
        minx = min (minx,pt.x);
        maxx = max (maxx,pt.x);
    }
    _leftMargin = minx;
    _rightMargin = maxx;
    cmd = [NSString stringWithFormat:@"UPDATE IMAGES SET LEFTMARGIN=%i,RIGHTMARGIN=%i WHERE IMAGEID=%li",_leftMargin,_rightMargin,_currentImageID];
    [self executeCmd:cmd];
*/
    //recompute clip highlight
    [self displayHighlightForClip:_currentClipID inView:_ImageDisplay];

    for (BarMarker* marker in _barMarkers)
    {
        [self computeBarPctOnLine:marker];
        NSString *cmd = [NSString stringWithFormat:@"INSERT INTO SUBCLIPS ('ClipID','StartTime','EndTime','Line','PCTAlongLine','PCTAlongClip') VALUES(%i,%f,%f,%i,%f,%f)",_currentClipID,marker.fromTime,marker.toTime,marker.beginLine,marker.pctAlongBeginLine,marker.pctAlongClip];
        [self executeCmd:cmd];
    }
    [self close:opened];
    return;
}

- (void) loadBarMarkers:(int)clipID
{
    [self clearBarMarkers:NO];
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM SUBCLIPS WHERE CLIPID = %i",clipID];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    int n=1;
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        BarMarker *bm = BarMarker.new;
        int i = 0;
        bm.markerID = sqlite3_column_int(statement,  i++);
        bm.markerNum = n;
        bm.clipID = sqlite3_column_int(statement,  i++);
        bm.fromTime = sqlite3_column_double(statement, i++);
        bm.toTime = sqlite3_column_double(statement, i++);
        bm.beginLine = sqlite3_column_int(statement,  i++);
        bm.pctAlongBeginLine = sqlite3_column_double(statement, i++);
        bm.pctAlongClip = sqlite3_column_double(statement, i++);
        if (n > 1)
        {
            int index = n - 2;
            BarMarker *bmPrev = _barMarkers[index];
            bmPrev.toTime = bm.fromTime - 0.05;
            bmPrev.endLine = bm.beginLine;
            bmPrev.pctAlongEndLine = bm.pctAlongBeginLine - 0.001;
        }
        [_barMarkers addObject:bm];
        n++;
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    if (_barMarkers.count > 0)
    {
        BarMarker * bm =_barMarkers[0];
        double minTime = bm.fromTime;
        bm = _barMarkers.lastObject;
        double maxTime = bm.toTime;
        bm.fromTime = maxTime;
        NSNumber *bTime = [NSNumber numberWithInt:IDNINT(minTime*10)];
        NSNumber *eTime = [NSNumber numberWithInt:IDNINT(maxTime*10)];
        _beginTimes[_currentClip] = bTime;
        _endTimes[_currentClip] = eTime;
        int index = bm.markerNum - 2;
        if (index > -1)
        {
            bm = _barMarkers[index];
            bm.toTime = maxTime;
        }
        _clipEndTime = maxTime;
    }


}
- (IBAction) barTimeIncreaseDown:(id)sender
{
    _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(barTimeIncreaseTapped:) userInfo:nil repeats:YES];

}
- (IBAction) barTimeDecreaseDown:(id)sender
{
    _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(barTimeDecreaseTapped:) userInfo:nil repeats:YES];

}
- (IBAction)barTimeIncreaseTapped:(id)sender
{
    if (_buttonTimer && sender != _buttonTimer)
    {
        NSLog (@"barTimeIncrease up");
        [_buttonTimer invalidate];
        _buttonTimer = 0;
    }

    if (_selectedBarMarker)
    {
        _selectedBarMarker.fromTime += 0.1;
        [self updateSliderText:_selectedBarMarker.fromTime];

    }
}
- (IBAction)barTimeDecreaseTapped:(id)sender
{
    if (_buttonTimer && sender != _buttonTimer)
    {
        NSLog (@"barTimeDecrease up");
        [_buttonTimer invalidate];
        _buttonTimer = 0;
    }

     if (_selectedBarMarker && _selectedBarMarker.fromTime >= 0.1)
    {
        _selectedBarMarker.fromTime -= 0.1;
        [self updateSliderText:_selectedBarMarker.fromTime];
    }
}

- (IBAction)barTimeTestTapped:(id)sender
{
    if (_selectedBarMarker)
    {
        float startTime = max (0,_selectedBarMarker.fromTime - 3);
        float endTime = _selectedBarMarker.fromTime + 3;
        _inTimeTest = YES;
        _beginTime = startTime;
        _endTime = endTime;
        [self playSegmentTapped:nil];
    }
}

- (IBAction)saveTapped:(id)sender {
    _clipEditStatus = 0;
    [self displayImageHighlightButtons:NO];
    [self saveBarMarkers];
    [self clearBarMarkers:NO];
    [self displayBarTimeButtons:NO];
    [self displayClipAddButtons:YES];
    [self displayClipSelectButtons:YES];
    [self displayClipEditButtons:NO];
    [_addImageButton setHidden:YES];
    [_playbackSpeedButton setHidden:YES];
    [_playbackSpeedDecreaseButton setHidden:YES];
    [_playbackSpeedIncreaseButton setHidden:YES];

    [self playSegmentButton:NO];
    [self loopSegmentButton:NO];

    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE CLIPS SET STARTTIME=%i,ENDTIME=%i, BARS=%i WHERE CLIPID=%i",IDNINT(10*_beginTime),IDNINT(10*_endTime),_numBarsInClip,_currentClipID];
    [self executeCmd:cmd];
    [self close:opened];
    [_appSoundPlayer stop];

    [self retrieveSong:_currentPracticeGroupID setTimes:NO];
    [self setCurrentPositiion:NO];

}


- (IBAction)cancelEditTapped:(id)sender {
    _clipEditStatus = 0;
    [_beginButton setHidden:NO];
    [_endButton setHidden:NO];
    [self displayImageHighlightButtons:NO];
    [self clearBarMarkers:NO];

    [self displayBarTimeButtons:NO];
    [self displayClipEditButtons:NO];
    [_addImageButton setHidden:YES];
    [_priorClipButton setHidden:NO];
    [_nextClipButton setHidden:NO];
    [self playSegmentButton:NO];
    [self loopSegmentButton:NO];

    [self setCurrentPositiion:NO];
}

- (IBAction)clipButtonTapped:(id)sender {
    [_timer invalidate];
    _timer = nil;
    [self displayClipAddButtons:NO];
    [self displayClipEditButtons:YES];
    [self displayImageHighlightButtons:YES];
    [self displayClipPlayButtons:NO];
    [self displayClipSelectButtons:NO];
    [_highlightBarsStepper setValue:_numBarsInClip];
    [_highlightLinesStepper setValue:_numHighlightLines];
    NSString *label = [NSString stringWithFormat:@"Lines: %i",_numHighlightLines];
    [_highlightLinesLabel setText:label];
    label = [NSString stringWithFormat:@"Bars: %i",_numBarsInClip];
    [_highlightBarsLabel setText:label];

    [_addImageButton setHidden:_currentSongType != SONG];
     if (_currentSongType == SONG)
    {
        [_appSoundPlayer pause];
        [_appSoundPlayer setCurrentTime:0];
        [self setCurrentPositiion:NO];
        [self setSliderRange];
    }
    else
    {
        [self.playerView pauseVideo];
        [self setSliderRange];
    }
    [_tapToEditLabel setHidden:YES];
    NSString *labelText = [NSString stringWithFormat:@"Edit Clip %i",_currentClip+1];
    [_clipButton setTitle:labelText forState:UIControlStateNormal];
    if (!_barMarkers || _barMarkers.count < 1)
        [self createBarMarkers:_numBarsInClip];
    [self editBarMarkers];

    _clipEditStatus = 1;
    
}
- (BOOL) testNewSong
{
    NSError *error = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: _currentSongURL error:&error];
    if (error)
    {
        NSLog(@"Player ERROR: %@", error.localizedDescription);
        return FALSE;
    }
    newPlayer = nil;
    return TRUE;
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
    _clipIDs = NSMutableArray.new;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _barsInClip = NSMutableArray.new;
    _currentClip = -1;
    self.currentImageID = -1;
    _currentClipID = -1;
    [self displayClipAddButtons:NO];
    [self removeHighlightFromView:_ImageDisplay];
    [self retrieveSong:_currentPracticeGroupID setTimes:YES];
    [_clipButton setTitle:@"" forState:UIControlStateNormal];
    [self updateClipButtons];
    //[_tapToEditLabel setHidden:YES];
    //[self playTapped:nil];
    return TRUE;
}
- (IBAction)playTapped:(id)sender {
    _inLoop = NO;
    _currentClip = -1;
    _beginTime = _currentSongStartTime;
    _endTime = _currentSongDuration;
    [self updateClipButtons];
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
        [_appSoundPlayer setCurrentTime:0];
        [self setCurrentPositiion:YES];
    }
    else
    {
        [self.ImageDisplay setHidden:YES];
        [self.playerView setHidden:NO];
        [self.playerView pauseVideo];
        [self.playerView seekToSeconds:_currentSongStartTime allowSeekAhead:YES];
    }
    [self playSegmentButton:NO];
    [self loopSegmentButton:NO];
    [self continueTapped:nil];
}

- (void) loopSegmentButton:(BOOL) setSelected
{
    [_loopSegmentButton setSelected:setSelected];
}
- (void) playSegmentButton:(BOOL) setSelected
{
    [_playSegmentButton setSelected:setSelected];
}
- (void) saveSongURL:(NSString *)url
            forTitle:(NSString *)title
              ofType:(SongTypes)type
            duration:(int)duration
           startTime:(int)startTime
{
    BOOL opened = [self open];
    NSString *title2 = [title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PRACTICEGROUPS (TITLE,TYPE,URL,DURATION,StartTime,Instrument,Tuning)VALUES('%@',%li,'%@',%i,%i,'%@','%@')",title2,(long)type,url,duration,startTime,_instrument,_tuning];
    [self executeCmd:cmd];
    [self close:opened];
}

- (BOOL) getSongWithTitle:(NSString *)title
{
    BOOL rtn = TRUE;
    BOOL opened = [self open];
    NSString *title2 = [_currentSongTitle stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *query = [NSString stringWithFormat:@"SELECT PracticeGroupID,Title,Type,URL,Duration FROM PRACTICEGROUPS WHERE Title = '%@'",title2];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        rtn = TRUE;
        int i = 0;
        _currentPracticeGroupID = sqlite3_column_int64(statement, i++);
        LPSTR title = (LPSTR)sqlite3_column_text(statement,  i++);
        LPSTR type = (LPSTR)sqlite3_column_text(statement,  i++);
        LPSTR url = (LPSTR)sqlite3_column_text(statement,  i++);
        rtn = [NSString stringWithFormat:@"%s",url];
        _currentSongTitle = [NSString stringWithFormat:@"%s",title];
        _currentSongDuration = sqlite3_column_int(statement,  i++);
        _currentSongType = atoi (type);
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];

    return rtn;
}

- (NSString *) getNextSong
{
    BOOL opened = [self open];
    NSString * rtn = nil;
    NSString *title2 = [_currentSongTitle stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *query = [NSString stringWithFormat:@"SELECT Title,Type,URL,Duration FROM PRACTICEGROUPS WHERE Title > '%@'",title2];
    
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
- (NSString *)  getSong:(NSString *)title
{
    BOOL opened = [self open];
    NSString *title2 = [title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSString * rtn = nil;
    NSString *query = [NSString stringWithFormat:@"SELECT PracticeGroupID,Title,Type, URL,Duration, startTime FROM PRACTICEGROUPS WHERE Title = '%@'",title2];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int i = 0;
        _currentPracticeGroupID = sqlite3_column_int(statement, i++);
        LPSTR title = (LPSTR)sqlite3_column_text(statement, i++);
        _currentSongType = sqlite3_column_int(statement, i++);
        LPSTR url = (LPSTR)sqlite3_column_text(statement, i++);
        rtn = [NSString stringWithFormat:@"%s",url];
        _currentSongTitle = [NSString stringWithFormat:@"%s",title];
        [self updateSongLabel];
        _currentSongDuration = sqlite3_column_int(statement, i++);
        _currentSongStartTime = sqlite3_column_int(statement, i++);
        _currentTime = 0;
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    return rtn;
}

- (void) addSongsToList:(NSMutableArray *)array
{
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT PracticeGroupID,Title,URL FROM PRACTICEGROUPS ORDER BY (Title)"];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        long practiceGroupID = sqlite3_column_int64(statement, 1);
        LPSTR title = (LPSTR)sqlite3_column_text(statement, 1);
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

    if (_currentClip > -1 && !_inFullScreen)
    {
        float nseconds = _endTime - _beginTime;
        NSString * clipText = [NSString stringWithFormat:@"Clip %i of %lu (%.1f seconds)\nTap to Edit",_currentClip+1,(unsigned long)_beginTimes.count,nseconds];
        [_clipButton setTitle:clipText forState:UIControlStateNormal];
        [_clipButton setHidden:NO];
        _tapToEditLabel.text = [NSString stringWithFormat:@"Tap to edit Clip %i or tap Mark Begin to add a clip",_currentClip+1];;
        [_tapToEditLabel setHidden:NO];
    }
    else
    {
        [_clipButton setHidden:YES];
        _tapToEditLabel.text = @"Tap Mark Begin to add a clip";
        [self updateClipButtons];
        [self playSegmentButton:NO];
        [self loopSegmentButton:NO];
        [_tapToEditLabel setHidden:NO];
    }
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
        if (_timer)
            [_timer invalidate];
        if (doPlay)
        {
            [self setSliderValue:_beginTime];
            [_appSoundPlayer setCurrentTime:_beginTime];
            _timer = [NSTimer scheduledTimerWithTimeInterval:_timerInterval target:self selector:@selector(checkTime:) userInfo:nil repeats:YES];
            [_appSoundPlayer play];
        }
        else
            [_appSoundPlayer setCurrentTime:_slider.value];
    }
    else
    {
        [self.playerView pauseVideo];
        [self.playerView seekToSeconds:_beginTime allowSeekAhead:YES];
        if (doPlay)
        {
            [self setSliderValue:_beginTime];
            [self.playerView playVideo];
        }
    }
    return;
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
    _keepGoing = 1000;
    //self.currentImageID = -1;
    [_delayLabel setHidden:YES];
    [_delaySwitch setHidden:YES];
    [_recordLabel setHidden:YES];
    [_recordSwitch setHidden:YES];
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
    if (_playSegmentButton.isSelected)
    {
        [self playSegmentButton:NO];
        [_pauseButton setHidden:YES];
        [_continueButton setHidden:NO];
    }
    else
    {
        [_appSoundPlayer setCurrentTime:_beginTime];
        [self playSegmentButton:YES];
        [self loopSegmentButton:NO];
        if (!_tempClipStatus && !_inTimeTest)
            self.endTime = _clipEndTime;
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
                    else if (_loopDelay)
                    {
                        double delayTime = _endTime - _beginTime;
                        delayTime = (10.0 /_playbackSpeed) * delayTime;
                        _leadInTimer = [NSTimer scheduledTimerWithTimeInterval:delayTime target:self selector:@selector(initLoop) userInfo:nil repeats:NO];
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
                [self playSegmentButton:NO];
                [_pauseButton setHidden:YES];
                [_continueButton setHidden:NO];
                [timer invalidate];
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
    {
        if (_playerIsPlaying)
            [_playerView pauseVideo];
    }

}
-(void) updateClipButtons
{
    BOOL st = _beginTimes.count == 0;
    [_playSegmentButton setHidden:st];
    [_loopSegmentButton setHidden:st];
    [_nextClipButton setHidden:st];
    [_priorClipButton setHidden:st];
    if (_currentClip == 0)
        [_nextClipButton setTitle:@"First Clip" forState:UIControlStateNormal];
    else
        [_nextClipButton setTitle:@"Next Clip" forState:UIControlStateNormal];

    [_priorClipButton setEnabled:NO];
    [_nextClipButton setEnabled:NO];
    [self playSegmentButton:NO];
    [self loopSegmentButton:NO];
    if (_currentClip < 0 ||_beginTimes.count < 2)
    {
        [_nextClipButton setTitle:@"First Clip" forState:UIControlStateNormal];
        [_nextClipButton setEnabled:YES];
    }
    else
    {
        [_nextClipButton setTitle:@"Next Clip" forState:UIControlStateNormal];
    }
    if (_currentClip > 0)
        [_priorClipButton setEnabled:YES];
    if (_currentClip < (int)_beginTimes.count -1)
        [_nextClipButton setEnabled:YES];
    if (_currentClip < 0)
    {
        [self displayClipPlayButtons:NO];
    }
}
- (IBAction)priorClipTapped:(id)sender
{
    [_deleteClipButton setEnabled:NO];
    [self displayClipEditButtons:NO];
    if (_currentClip > 0)
    {
        _currentClip--;
        [self setupClip];
    }
}

- (IBAction)nextClipTapped:(id)sender {
    [_deleteClipButton setEnabled:NO];
    [self displayClipEditButtons:NO];

    if ([_nextClipButton.titleLabel.text isEqual:@"First Clip"])
        _currentClip = -1;
    if (_currentClip < (int)_beginTimes.count-1)
    {
        _currentClip++;
        [self setupClip];
    }
}
- (void) setupClip
{
    if (_currentClip < 0)
    {
        [_clipButton setHidden:YES];
        return;
    }
    _currentClipID = (int) _clipIDs[_currentClip].integerValue;
    [self loadBarMarkers:_currentClipID];
    _beginTime = (int)_beginTimes[_currentClip].integerValue/10.0;
    _endTime = (int)_endTimes[_currentClip].integerValue/10.0;
    _numBarsInClip = (int)_barsInClip[_currentClip].integerValue;
    _clipStartTime = _beginTime;
    _clipEndTime = _endTime;
    float nseconds = _endTime - _beginTime;
    NSString * clipText = [NSString stringWithFormat:@"Clip %i of %lu (%.1f seconds)\nTap to Edit",_currentClip+1,(unsigned long)_beginTimes.count,nseconds];
    [_clipButton setTitle:clipText forState:UIControlStateHighlighted];
    [_clipButton setSelected:NO];
    [_clipButton setHidden:NO];
    _tapToEditLabel.text = @"Tap to Edit";
    [_tapToEditLabel setHidden:NO];
    _inLoop = NO;
    _numTrackLines = 0;
    if ([self displayImageAtTime:_beginTime inGroup:_currentPracticeGroupID])
    {
        [_addImageButton setHidden:YES];
    }
    [self setCurrentPositiion:_currentSongType == SONG];
    [self updateClipButtons];
    [self stopTapped:nil];
    [self playSegmentButton:NO];
    [self loopSegmentButton:NO];

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
    }
    else
        [self initLoop];
    return;
}

-(void) initLoop
{
    if (_currentClip >= 0 && (int)_beginTimes.count > _currentClip)
    {
        _currentClipID = _clipIDs[_currentClip].integerValue;
        //_beginTime = (int)_beginTimes[_currentClip].integerValue/10.0;
        //_endTime = (int)_endTimes[_currentClip].integerValue/10.0;
        _numBarsInClip = _barsInClip[_currentClip].integerValue;
    }
    if (!_tempClipStatus)
        self.endTime = _clipEndTime;

    _inLoop = YES;
    [_pauseButton setHidden:NO];
    [_continueButton setHidden:YES];
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
        [_appSoundPlayer setCurrentTime:_beginTime];
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
    [self playSegmentButton:NO];
    [self loopSegmentButton:YES];
    [self setPlayAndRecordButtonLocation];
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
    static BOOL delete = FALSE;
    BOOL createTables = FALSE;
    NSError *error = nil;

    if (delete)
        createTables = TRUE;
    if (!_isOpen)
    {
        NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
        NSString *riffMasterDirectory = [NSString stringWithFormat:@"%@/RiffMaster",documentsDirectory];
        NSString *errorText = @"";
        _imagesDirectory = [NSString stringWithFormat:@"%@/Images",riffMasterDirectory];
        NSString *riffMasterDB = [NSString stringWithFormat:@"%@/RiffMaster.slt",riffMasterDirectory];
        _recordingsDirectory = [NSString stringWithFormat:@"%@/Recordings",riffMasterDirectory];
        if (delete)
        {
            [NSFileManager.defaultManager removeItemAtPath:riffMasterDirectory
                                                     error:&error];
            if (error)
                errorText = error.localizedDescription;
        }
        [NSFileManager.defaultManager createDirectoryAtPath:_imagesDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error];
            if (error)
                errorText = error.localizedDescription;
        [NSFileManager.defaultManager createDirectoryAtPath:_recordingsDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error];
            if (error)
                errorText = error.localizedDescription;

        _isOpen = !SQLOK(__FILE__,__LINE__,SQLite_Open(riffMasterDB.UTF8String, &_database), _database);
        NSLog(@"Music Database open");
        
        long fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:riffMasterDB
                                                                                  error:nil].fileSize;

        rtn = TRUE;
        if (createTables)
        {
            rtn = [self createDataBaseTables];
            [self createCollection:@"Blues Guitar" under:0];
            [self createCollection:@"Rock Guitar" under:0];
            [self createCollection:@"Acoustic Guitar" under:0];
            [self createCollection:@"Base Guitar" under:0];
            [self createCollection:@"Ukulele" under:0];

        }
        delete = FALSE;
        //[self testImages];
    }
    return rtn;
}

- (BOOL)createDataBaseTables
{
    BOOL rtn = TRUE;
    NSString * cmd = @"DROP TABLE PRACTICEGROUPS;";
    //rtn = [self executeCmd:cmd];
    cmd = @"DROP TABLE IMAGES;";
    //rtn = [self executeCmd:cmd];
    cmd = @"DROP TABLE CLIPS;";
    //rtn = [self executeCmd:cmd];
    cmd = @"DROP INDEX idx_subclips_clip;DROP TABLE SUBCLIPS";
    //rtn = [self executeCmd:cmd];
    cmd = @"DROP TABLE CLIPHIGHLIGHT;";
    //rtn = [self executeCmd:cmd];
    cmd = @"DROP TABLE EFFECTS;";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS SETTINGS ('Name' CHAR(256), 'IntValue' INT, 'FloatValue' FLOAT,'TextValue' CHAR(256));";
    rtn = [self executeCmd:cmd];
    
    cmd = @"CREATE TABLE IF NOT EXISTS COLLECTIONS ('CollectionID' INTEGER PRIMARY KEY,'Title' CHAR(256), 'Parent' INT, 'Type' INT);";
    rtn = [self executeCmd:cmd];
    
    cmd = @"CREATE TABLE IF NOT EXISTS PRACTICEGROUPS ('PracticeGroupID' INTEGER PRIMARY KEY,'Title' CHAR(256),'Type' INT,'StartTime' INT,'Duration' INT, 'URL' CHAR(1024), 'Instrument' CHAR(256),'Tuning' CHAR(256));";
    rtn = [self executeCmd:cmd];
    
    cmd = @"CREATE TABLE IF NOT EXISTS CLIPS ('CLIPID' INTEGER PRIMARY KEY,'PracticeGroupID' INT,'Type' INT,'StartTime' INT,'EndTime' INT, 'Bars' INT);CREATE INDEX IF NOT EXISTS idx_clips_pg ON CLIPS (PracticeGroupID);";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS SUBCLIPS ('SUBCLIPID' INTEGER PRIMARY KEY,'ClipID' INT,'StartTime' FLOAT,'EndTime' FLOAT,'Line' INT,'PCTAlongLine' FLOAT, 'PCTAlongClip' FLOAT);CREATE INDEX IF NOT EXISTS idx_subclips_clip ON SUBCLIPS (ClipID);";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS IMAGES ('IMAGEID' INTEGER PRIMARY KEY,'PracticeGroupID' INT,'FromTime' INT,'ToTime' INT, 'LeftMargin' INT, 'RightMargin' INT);CREATE INDEX IF NOT EXISTS idx_images_pg ON IMAGES (PracticeGroupID);";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS CLIPHIGHLIGHT ('ClipID' INT,'ImageID' INT,'NumLines' INT,'StartX' FLOAT,'StartY' FLOAT,'EndX' FLOAT,'EndY' FLOAT,'BoundsWidth' FLOAT ,'BoundsHeight' FLOAT,PRIMARY KEY (ClipID))";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS EFFECTS ('EFFECTSID' INTEGER PRIMARY KEY,'PracticeGroupID' INT, 'ClipID' INT,'EffectsName' CHAR(128), 'SequenceNum' INT,'EffectType' INT, 'EffectID' INT,'WetDryMix' INT,'PreSet' INT);CREATE INDEX IF NOT EXISTS idx_effects ON EFFECTS (PracticeGroupID);";
    //PracticeGroup 0 = overall default effects, -1 = named effects, -2 = default for instrument where ClipID = instrumentID
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS INSTRUMENTS ('INSTRUMENTID' INTEGER PRIMARY KEY,'Name' CHAR(128), 'Type' INT, 'Tuning' CHAR(12));";
    rtn = [self executeCmd:cmd];
    
    cmd = @"CREATE TABLE IF NOT EXISTS OTHERRESOURCES ('RESOURCEID' INTEGER PRIMARY KEY,'PracticeGroupID' INT, 'Name' CHAR(128), 'Type' INT, 'Path' CHAR(256));CREATE INDEX IF NOT EXISTS idx_resources_pg ON OTHERRESOURCES (PracticeGroupID);";
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

- (void) retrieveSong:(long)practiceGroupID
             setTimes:(BOOL)setTime
{
    BOOL opened = [self open];

    NSString *query = [NSString stringWithFormat:@"SELECT ClipID,StartTime,EndTime,Bars FROM CLIPS WHERE PracticeGroupID = %li ORDER BY StartTime",(long)_currentPracticeGroupID];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    _clipIDs = NSMutableArray.new;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _barsInClip = NSMutableArray.new;
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int clipid = sqlite3_column_int(statement, 0);
        int beginTime = sqlite3_column_int(statement, 1);
        int endTime = sqlite3_column_int(statement, 2);
        int numBars = sqlite3_column_int(statement, 3);
        NSNumber *cid = [NSNumber numberWithInt:clipid];
        NSNumber *bTime = [NSNumber numberWithInt:beginTime];
        NSNumber *eTime = [NSNumber numberWithInt:endTime];
        NSNumber *nBars = [NSNumber numberWithInt:numBars];
        [_clipIDs addObject:cid];
        [_endTimes addObject:eTime];
        [_beginTimes addObject:bTime];
        [_barsInClip addObject:nBars];
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    if (setTime)
    {
        _currentClip = -1;
        [self updateNumClipsLabel];
        [self setSliderValue:_beginTime];
        //_appSoundPlayer.currentTime = _beginTime;
        [_appSoundPlayer setCurrentTime:_beginTime];
        [self setCurrentPositiion:NO];
        [self newSongButtonSettings];
    }
}
- (void) deleteClip:(int)clipID
{
    BOOL opened = [self open];
    
    [self removeHighlightFromView:_ImageDisplay];
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM CLIPS WHERE CLIPID = %i",clipID];
    [self executeCmd:cmd];
    cmd = [NSString stringWithFormat:@"DELETE FROM SUBCLIPS WHERE CLIPID = %i",clipID];
    [self executeCmd:cmd];
    [self close:opened];
    [self deleteHighlightForClip:clipID];
    [self displayClipEditButtons:NO];
    [self displayClipAddButtons:YES];
    [self displayClipSelectButtons:YES];
    _currentClip--;
    [self retrieveSong:_currentPracticeGroupID setTimes:NO];
    [self updateNumClipsLabel];
    [self updateClipButtons];

}
-(void) updateNumClipsLabel
{
    NSString *clip = @"clips";
    NSString *image = @"images";
    if (_images.count == 1)
        image = @"image";
    if (_beginTimes.count == 1)
        clip = @"clip";
    NSString * clipText = [NSString stringWithFormat:@"%i seconds: %lu %@: %lu %@",_currentSongDuration,(unsigned long)_images.count,image,(unsigned long)_beginTimes.count,clip];
    [_numClipsLabel setText:clipText];
}

-(void) newSongButtonSettings
{
    BOOL st = _beginTimes.count == 0;
    [self displayClipSelectButtons:!st];
    [_priorClipButton setEnabled:_currentClip > 1];
    if (_currentClip <= 0)
        [_nextClipButton setTitle:@"First Clip" forState:UIControlStateNormal];
    else
        [_nextClipButton setTitle:@"Next Clip" forState:UIControlStateNormal];
    [_addImageButton setHidden:NO];
    [_pauseButton setHidden:YES];
    [_continueButton setHidden:NO];
    [_slider setHidden:NO];
    [_playButton setHidden:NO];
    [_sliderTextLabel setHidden:NO];
}

- (IBAction)sliderExit:(id)sender
{
//    NSLog (@"%f",_slider.value);
    [self setSliderValue:_slider.value];
    if (!_changeBeginButton.isHidden && _changeBeginButton.isEnabled &&_changeBeginButton.isSelected)
        _beginTime = _slider.value;
    else if (!_changeEndButton.isHidden && _changeEndButton.isEnabled && _changeEndButton.isSelected)
        _endTime = _slider.value;
    else
    {
        [self stopTapped:nil];
        _currentClip = -1;
    }
    [self setCurrentPositiion:NO];

}


- (IBAction)monitorTapped:(id)sender {
    //[self displayYouTubeVideo:@"www.youtube.com"];
    [self toggleMonitor];
}

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

- (IBAction)playbackSpeedDecrease:(id)sender
{
    if (_playbackSpeed > 1)
        _playbackSpeed--;
    [self displayPlaybackSpeed];
}

- (IBAction)increaseTempDown:(id)sender
{
    NSLog(@"Increase temp down");
    _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(increaseTempTapped:) userInfo:nil repeats:YES];

}

- (IBAction)decreaseTempDown:(id)sender
{
    NSLog(@"Decrease temp down");
    _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(decreaseTempTapped:) userInfo:nil repeats:YES];

}

- (IBAction)increaseTempTapped:(id)sender
{
    if (_buttonTimer && sender != _buttonTimer)
    {
        NSLog (@"Decrease temp up");
        [_buttonTimer invalidate];
        _buttonTimer = 0;
    }
    NSString *currentTitle = [_tempClipEditButton titleForState:UIControlStateNormal];
    float value=0;
    if ([currentTitle isEqual:@"From"])
    {
        _tempClipStart += 0.1;
        value = _tempClipStart;
    }
    else if ([currentTitle isEqual:@"To"])
    {
        _tempClipEnd += 0.1;
        value = _tempClipEnd;
    }
    _beginTime = _tempClipStart;
    _endTime = _tempClipEnd;
    NSString *sliderText = [NSString stringWithFormat:@"%.1f",value];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self.sliderTextLabel setText:sliderText];
    }];
}

- (IBAction)decreaseTempTapped:(id)sender
{
    if (_buttonTimer && sender != _buttonTimer)
    {
        NSLog (@"Decrease temp up");
        [_buttonTimer invalidate];
        _buttonTimer = 0;
    }
    NSString *currentTitle = [_tempClipEditButton titleForState:UIControlStateNormal];
    float value=0;
    if ([currentTitle isEqual:@"From"])
    {
        _tempClipStart -= 0.1;
        value = _tempClipStart;
    }
    else if ([currentTitle isEqual:@"To"])
    {
        _tempClipEnd -= 0.1;
        value = _tempClipEnd;
    }
    _beginTime = _tempClipStart;
    _endTime = _tempClipEnd;
    [self updateSliderText:value];
}

-(void) updateSliderText:(float)value
{
    NSString *sliderText = [NSString stringWithFormat:@"%.1f",value];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self.sliderTextLabel setText:sliderText];
    }];

}
- (IBAction)tempClipEditButtonTapped:(id)sender
{
    NSString *currentTitle = [_tempClipEditButton titleForState:UIControlStateNormal];
    if ([currentTitle isEqual:@"Edit"])
    {
        [_tempClipEditButton setTitle:@"From" forState:UIControlStateNormal];
        [_decreaseTempButton setHidden:NO];
        [_increaseTempButton setHidden:NO];
    }
    else if ([currentTitle isEqual:@"From"])
        [_tempClipEditButton setTitle:@"To" forState:UIControlStateNormal];
    else if ([currentTitle isEqual:@"To"])
    {
        [_tempClipEditButton setTitle:@"Save" forState:UIControlStateNormal];
        [_decreaseTempButton setHidden:YES];
        [_increaseTempButton setHidden:YES];
    }
    else if ([currentTitle isEqual:@"Save"])
    {
        [_tempClipEditButton setHidden:YES];
    }
}

- (IBAction)playbackSpeedIncrease:(id)sender
{
    if (_playbackSpeed < 20)
        _playbackSpeed++;
    [self displayPlaybackSpeed];
}

- (IBAction)playbackSpeedReset:(id)sender
{
    if (_playbackSpeed == 10)
        return;
    _playbackSpeed = 10;
    [self resetFilledFonts];
    [self displayPlaybackSpeed];
}

- (void) displayPlaybackSpeed
{
    UIButtonConfiguration *config = _playbackSpeedButton.configuration;
    NSString *subTitle = @"Normal";
    if (_playbackSpeed != 10)
        subTitle = [NSString stringWithFormat:@"%i percent",IDNINT(_playbackSpeed*10)];
    config.subtitle = subTitle;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        self.playbackSpeedButton.configuration = config;
    }];
    [self setPlaybackSpeed:_playbackSpeed];
}

- (void) setPlaybackSpeed:(int)playbackSpeed
{
    BOOL restart = FALSE;
    if (_currentSongType == SONG)
    {
        if (_appSoundPlayer.playing)
            restart = TRUE;
        [_appSoundPlayer stop];
        if (playbackSpeed == 10)
            _appSoundPlayer.enableRate = NO;
        else
        {
            _appSoundPlayer.enableRate = YES;
            _appSoundPlayer.rate = playbackSpeed / 10.0;
        }
        if (restart)
            [_appSoundPlayer play];
    }
    else
    {
        [self.playerView pauseVideo];
        [self.playerView setPlaybackRate:playbackSpeed / 10.0];
        [self.playerView playVideo];
    }
}

- (IBAction)imageEndAtTapped:(id)sender
{
    if (sender)
        _imageEndAt = _slider.value;
    else
        _imageEndAt = _currentSongDuration;
    [_saveImageButton setEnabled:YES];
    UIButtonConfiguration *config = _imageEndAtButton.configuration;
    NSString *subTitle = _imageEndAtButton.configuration.subtitle;
    subTitle = [NSString stringWithFormat:@"%.1f",_imageEndAt];
    config.subtitle = subTitle;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        self.imageEndAtButton.configuration = config;
    }];
    if (_imageEndAt > 0 && _imageStartAt < _imageEndAt)
        [_saveImageButton setEnabled:YES];
    
}


- (IBAction)imageStartAtTapped:(id)sender
{
    if (sender)
        _imageStartAt = _slider.value;
    else
        _imageStartAt = 0;
    [_saveImageButton setEnabled:YES];
    UIButtonConfiguration *config = _imageStartAtButton.configuration;
    NSString *subTitle = _imageStartAtButton.configuration.subtitle;
    subTitle = [NSString stringWithFormat:@"%.1f",_imageStartAt];
    config.subtitle = subTitle;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        self.imageStartAtButton.configuration = config;
    }];
    
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
        [self presentViewController:effectsVC animated:NO completion:nil];
    }
    return;
}



-(void)meterLevel:(AVAudioPCMBuffer *)buffer callback:(void (^)(float))callback{
    //  [buffer setFrameLength:[buffer frameLength]];
    UInt32 inNumberFrames = buffer.frameLength;
    
    float LEVEL_LOWPASS_TRIG = 0.2;
    

}

- (IBAction)addImageTapped:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];

}

- (IBAction)cancelImagePicked:(id)sender {
    _inAddImageMode = NO;
    [self displayAddImageButtons:NO];
    [self clearMargins];
    [_ImageDisplay setImage:nil];
    [self displayClipAddButtons:NO];
    self.currentImageID = -1;
}
- (IBAction)marginSelectionTapped:(id)sender
{
    _adjustingLeftMargin = !_adjustingLeftMargin;
    if (_adjustingLeftMargin)
        [_marginSelectionButton setTitle:@"Set Left\n Margin" forState:UIControlStateNormal];
    else
        [_marginSelectionButton setTitle:@"Set Right\n  Margin" forState:UIControlStateNormal];


}

- (IBAction)touchMargin:(id)sender {
    NSLog (@"Touch");
    return;
}

- (IBAction)tempClipTapped:(id)sender
{
    if (_currentSongType == SONG)
        _currentTime = _appSoundPlayer.currentTime;
    else
        _currentTime = _currentYTTime + 0.15;
    switch (_tempClipStatus)
    {
    case 0://mark start
            _saveClipStart = _beginTime;
            _saveClipEnd = _endTime;
            _tempClipStart = _currentTime;
            [self setTempClipSubtitle:@"Mark End"];
            _tempClipStatus++;
        break;
    case 1://mark end
            _tempClipEnd = _currentTime;
            [self setTempClipSubtitle:@"Clear"];
            _tempClipStatus++;
            _beginTime = _tempClipStart;
            _endTime = _tempClipEnd;
            _tempHighlightPCT1 = (_tempClipStart - _clipStartTime)/(_clipEndTime - _clipStartTime);
            _tempHighlightPCT2 = (_tempClipEnd - _clipStartTime)/(_clipEndTime - _clipStartTime);
            _clipStartTime = _beginTime;
            _clipEndTime = _endTime;
            [_tempClipEditButton setTitle:@"Edit" forState:UIControlStateNormal];
            [_tempClipEditButton setHidden:NO];
            if (_numHighlightLines)
                [self createTempHighlight:_tempHighlightPCT1
                                    toPCT:_tempHighlightPCT2];
        break;
    case 2://reset
            [_tempClipEditButton setHidden:YES];
            [_decreaseTempButton setHidden:YES];
            [_increaseTempButton setHidden:YES];
            [self setTempClipSubtitle:@"Mark Start"];
            _tempClipStatus = 0;
            _beginTime = _saveClipStart;
            _endTime = _saveClipEnd;
            _clipStartTime = _beginTime;
            _clipEndTime = _endTime;

            _haveTempHighlight = NO;
            if (_numHighlightLines)
                [self displayHighlightForClip:_currentClipID
                                       inView:_fullScreenImageDisplay];

        break;
    }
}
- (void) setTempClipSubtitle:(NSString *)subTitle
{
    
    UIButtonConfiguration *config = _tempClipButton.configuration;
    switch (_tempClipStatus)
    {
        case 0:
            config.baseBackgroundColor = UIColor.brownColor;
            config.baseForegroundColor = UIColor.whiteColor;
            break;
        case 1:
            config.baseBackgroundColor = UIColor.redColor;
            config.baseForegroundColor = UIColor.whiteColor;
            break;
        case 2:
            config.baseBackgroundColor = UIColor.yellowColor;
            config.baseForegroundColor = UIColor.blackColor;
            break;
    }
    config.subtitle = subTitle;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        self.tempClipButton.configuration = config;
    }];
    
}

- (IBAction)marginDecreaseButtonDown:(id)sender
{
    NSLog(@"Decrease button down");
    _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(marginDecreaseButtonTapped:) userInfo:nil repeats:YES];

}
- (IBAction)marginIncreaseButtonDown:(id)sender
{
    NSLog(@"Increase button down");
    _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(marginIncreaseButtonTapped:) userInfo:nil repeats:YES];
}


- (IBAction)marginIncreaseButtonTapped:(id)sender
{
    if (_buttonTimer && sender != _buttonTimer)
    {
        NSLog (@"Increase temp up");
        [_buttonTimer invalidate];
        _buttonTimer = 0;
    }
    NSLog (@"Release");
    [self adjustMargin:1];
}
- (IBAction)marginDecreaseButtonTapped:(id)sender
{
    if (_buttonTimer && sender != _buttonTimer)
    {
        NSLog (@"Decrease temp up");
        [_buttonTimer invalidate];
        _buttonTimer = 0;
    }
    [self adjustMargin:-1];
}
- (void)adjustMargin:(int) amount
{
    [_saveImageButton setEnabled:YES];
    if (_adjustingLeftMargin)
        _leftMargin += amount;
    else
        _rightMargin += amount;
    [self displayMargins];
}

- (void) clearMargins
{
    if (_leftMarginMarker)
        [_leftMarginMarker removeFromSuperview];
    if (_rightMarginMarker)
        [_rightMarginMarker removeFromSuperview];

}
- (void)displayMargins
{
    CGPoint imagePoint1, imagePoint2;
    [self clearMargins];
    if (!_leftMarginMarker)
    {
        _leftMarginMarker = UILabel.new;
        _leftMarginMarker.backgroundColor = UIColor.greenColor;
    }
    if (!_rightMarginMarker)
    {
        _rightMarginMarker = UILabel.new;
        _rightMarginMarker.backgroundColor = UIColor.greenColor;
    }
    imagePoint1.x = _leftMargin;
    imagePoint1.y = 0;
    imagePoint2 = imagePoint1;
    imagePoint2.y = _ImageDisplay.image.size.height;
    CGPoint viewPoint1 = TranCGPoint(imagePoint1,_hTranImageToView);
    CGPoint viewPoint2 = TranCGPoint(imagePoint2,_hTranImageToView);
    CGRect frame = CGRectMake(viewPoint1.x, viewPoint1.y, 2, viewPoint2.y - viewPoint1.y);
    [_leftMarginMarker setFrame:frame];
    [_ImageDisplay addSubview:_leftMarginMarker];
    imagePoint1.x = _rightMargin;
    imagePoint1.y = 0;
    imagePoint2 = imagePoint1;
    imagePoint2.y = _ImageDisplay.image.size.height;
    viewPoint1 = TranCGPoint(imagePoint1,_hTranImageToView);
    viewPoint2 = TranCGPoint(imagePoint2,_hTranImageToView);
    frame = CGRectMake(viewPoint1.x, viewPoint1.y, 2, viewPoint2.y - viewPoint1.y);
    [_rightMarginMarker setFrame:frame];
    [_ImageDisplay addSubview:_rightMarginMarker];

}
-(BOOL) displayImageAtTime:(int)time
                  inGroup:(long)practiceGroup
{
    BOOL rtn = FALSE;
    long imageToLoad = 0;
    for (ImageAndTime *iat in _images)
    {
        if (time >= iat.fromTime && time < iat.toTime)
        {
            imageToLoad = iat.imageID;
            _leftMargin = iat.leftMargin;
            _rightMargin = iat.rightMargin;
        }
    }
    if (imageToLoad && imageToLoad != _currentImageID)
    {
        NSString *fileName = [NSString stringWithFormat:@"%@/%li.png",_imagesDirectory,imageToLoad];
        _image = [UIImage imageWithContentsOfFile:fileName];
        self.currentImageID = imageToLoad;
        [_ImageDisplay setImage:_image];
        [self displayClipAddButtons:YES];
        [_ImageDisplay setHidden:NO];
        [_fullScreenButton setHidden:NO];
        [_highlightLinesLabel setHidden:YES];
        [_highlightLinesStepper setHidden:YES];
        [_imageHighlightInstructions setHidden:YES];
        [self displayHighlightForClip:_currentClipID inView:_ImageDisplay];
        rtn = TRUE;
    }
    else if (!imageToLoad && _currentImageID > -1)
    {
        self.currentImageID = -1;
        [_ImageDisplay setImage:nil];
        [self displayClipAddButtons:NO];
        [_ImageDisplay setHidden:NO];
        [self removeHighlightFromView:_ImageDisplay];

    }
    else if (imageToLoad)
        [self displayHighlightForClip:_currentClipID inView:_ImageDisplay];
    [_addImageButton setHidden:YES];

    return rtn;
}

-(NSArray *) getImagesForPracticeGroup:(long)practiceGroup
{
    NSMutableArray *images = NSMutableArray.new;
    BOOL opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT ImageID, FromTime,ToTime, LeftMargin, RightMargin FROM IMAGES WHERE PracticeGroupID=%li ORDER BY FromTime",practiceGroup];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int i = 0;
        long imageID = sqlite3_column_int64(statement, i++);
        int fromTime = sqlite3_column_int(statement, i++);
        int toTime = sqlite3_column_int(statement, i++);
        int leftMargin = sqlite3_column_int(statement, i++);
        int rightMargin = sqlite3_column_int(statement, i++);
        ImageAndTime *imageAndTime = ImageAndTime.new;
        imageAndTime.fromTime = fromTime;
        imageAndTime.toTime = toTime;
        imageAndTime.imageID = imageID;
        imageAndTime.leftMargin = leftMargin;
        imageAndTime.rightMargin = rightMargin;
        [images addObject:imageAndTime];
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
    
    [self close:opened];
    return images;
}

-(void) displayFileForClip:(int)clipID
                   fileNum:(int)fileNum
                  numFiles:(int)numFiles
{
    NSString *fileName = [NSString stringWithFormat:@"%@/%i_%i.png",_imagesDirectory,clipID,fileNum];
    _image = [UIImage imageWithContentsOfFile:fileName];
    [_ImageDisplay setImage:_image];
    [self displayClipAddButtons:YES];
    [_ImageDisplay setHidden:NO];
    [_fullScreenButton setHidden:NO];
    [self displayImageHighlightButtons:NO];
    _currentFileNum = fileNum;
    _currentNumFiles = numFiles;
    [self displayHighlightForClip:clipID
                           inView:_ImageDisplay];
    return;
}
-(CGRect)imageRectInView:(UIImageView*)view
{
    CGRect rtn={0};
    CGRect b = view.bounds;
    CGRect f = view.frame;
    float bo = view.image.baselineOffsetFromBottom;
    UIEdgeInsets x = view.image.alignmentRectInsets;
    double iw = view.image.size.width;
    double ih = view.image.size.height;
    double vw = view.bounds.size.width;
    double vh = view.bounds.size.height;
    float csf = view.contentScaleFactor;
    UIViewContentMode cm = view.contentMode;
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
- (BOOL) displayHighlightForClip:(int)clipID
                          inView:(UIImageView*) view
{
    [self removeHighlightFromView:view];
    if (clipID < 0)
    {
        [self removeHighlightFromView:view];
        return FALSE;
    }
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
        HANDLE hTranImageToView = STRANCGRect (imageFrame,viewFrame);
        [self createHighlight:imagePoint1
                       point2:imagePoint2
                     numLines:numLines
                       inView:view
                        hTran:hTranImageToView
                     doUpdate:NO];
        CloseTRANS2 (&hTranImageToView);
        rtn = TRUE;
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    if (_haveTempHighlight)
    {
        [self createTempHighlight:_tempHighlightPCT1
                            toPCT:_tempHighlightPCT2];

    }
    return rtn;
}

- (BOOL) deleteHighlightForClip:(int) clipID
{
    BOOL st = FALSE;
    BOOL opened = [self open];
    
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM CLIPHIGHLIGHT WHERE CLIPID = %i",clipID];
    [self executeCmd:cmd];
    [self close:opened];

    return st;
}
-(void) createTransforms:(UIImageView*)view
{
    CGRect viewFrame = [self imageRectInView:view];
    CGRect imageFrame = CGRectMake(0,0,  view.image.size.width, view.image.size.height);

    CloseTRANS2 (&_hTranImageToView);
    CloseTRANS2 (&_hTranViewToImage);
    _hTranImageToView = STRANCGRect (imageFrame,viewFrame);
    _hTranViewToImage = STRANCGRect (viewFrame,imageFrame);

}
- (IBAction)fullScreenTapped:(id)sender {
    [self hideAllViews:YES];
    _inFullScreen = YES;
    CGRect frame = _imageFrame.frame;
    frame.origin.x = 0;
    frame.size.width = self.view.frame.size.width;
    frame.origin.y += 16;
    frame.size.height -= 16;
    [_imageFrame setHidden:YES];
    [_ImageDisplay setHidden:YES];
    if (_currentSongType == SONG)
    {
        [_fullScreenImageDisplay setFrame:frame];
        [_fullScreenImageDisplay setImage:_image];
        [self displayClipAddButtons:NO];
        [_fullScreenImageDisplay setHidden:NO];
        [self createTransforms:_fullScreenImageDisplay];
        [self.playerView setHidden:YES];
    }
    else
    {
        [self.playerView setFrame:frame];
        [self.playerView setHidden:NO];
        [_fullScreenImageDisplay setHidden:YES];
    }
    [_selectCollectionButton setHidden:YES];
    [_songTitleLabel setHidden:YES];
    [_numClipsLabel setHidden:YES];
    [_currentCollectionLabel setHidden:YES];
    
    [_fullScreenReturnButton setHidden:NO];
    _saveSliderTextLabelFrame = _sliderTextLabel.frame;
    frame = _fullScreenButton.frame;
    frame.origin.y += frame.size.height + 2;
    frame.size.height = _sliderTextLabel.frame.size.height;
    [_sliderTextLabel setFrame:frame];
    [_sliderTextLabel setHidden:NO];
    [_monitorButton setHidden:YES];
    [_monitorVolumeSlider setHidden:YES];
    [_effectsButton setHidden:YES];
    [_playbackSpeedButton setHidden:NO];
    [_playbackSpeedDecreaseButton setHidden:NO];
    [_playbackSpeedIncreaseButton setHidden:NO];
    [_tempClipButton setHidden:NO];
    frame = _playSegmentButton.frame;
    _savePlaySegmentFrame = frame;
    frame.origin.x = frame.size.width/2;
    frame.origin.y = 20;
    [_playSegmentButton setFrame:frame];

    [_playSegmentButton setHidden:NO];
    frame = _loopSegmentButton.frame;
    _saveLoopSegmentFrame = frame;
    frame.origin.x = _playSegmentButton.frame.origin.x + _savePlaySegmentFrame.size.width + 100 * _widthFactor;
    frame.origin.y = 20;
    [_loopSegmentButton setFrame:frame];
    [_recordLabel setHidden:YES];
    [_recordSwitch setHidden:YES];
    [_loopSegmentButton setHidden:NO];
    [self displayHighlightForClip:_currentClipID
                           inView:_fullScreenImageDisplay];
}
- (void) setPlayAndRecordButtonLocation
{
    CGRect frame = _playSegmentButton.frame;
    frame.origin.x += frame.size.width / 2 - _delayLabel.frame.size.width/2;
    frame.origin.y += frame.size.height + 6;
    frame.size.height = _delayLabel.frame.size.height;
    frame.size.width = _delayLabel.frame.size.width;
    [_delayLabel setFrame:frame];
    frame.origin.x += _delayLabel.frame.size.width + 8;
    [_delaySwitch setFrame:frame];
    
    frame = _loopSegmentButton.frame;
    frame.origin.x += frame.size.width / 2 - _recordLabel.frame.size.width/2;
    frame.origin.y += frame.size.height + 6;
    frame.size.height = _recordLabel.frame.size.height;
    frame.size.width = _recordLabel.frame.size.width;
    [_recordLabel setFrame:frame];
    frame.origin.x += _recordLabel.frame.size.width + 8;
    [_recordSwitch setFrame:frame];

}
- (IBAction)deleteClipTapped:(id)sender {
    [self verifyDelete:1];
}

- (void)displayImageHighlightButtons:(BOOL)show
{
    [_imageHighlightInstructions setHidden:!show];
    [_highlightLinesLabel setHidden:!show];
    [_highlightLinesStepper setHidden:!show];
    [_highlightBarsLabel setHidden:!show];
    [_highlightBarsStepper setHidden:!show];
    [_imageHighlightInstructions setText:@""];

    _highlightPointNumber = 1;
    if (show)
        ii=1;
}

- (void) displayAddImageButtons:(BOOL)show
{
    show = !show;
    [_saveImageButton setHidden:show];
    [_cancelImageButton setHidden:show];
    [_imageEndAtButton setHidden:show];
    [_imageStartAtButton setHidden:show];
    [_marginIncreaseButton setHidden:show];
    [_marginDecreaseButton setHidden:show];
    [_marginSelectionButton setHidden:show];
}
- (void) displayClipPlayButtons:(BOOL)show
{
    show = !show;
    [_playSegmentButton setHidden:show];
    [_loopSegmentButton setHidden:show];
}
- (void) displayClipAddButtons:(BOOL)show
{
    if (show)
    {
        [_beginButton setEnabled:YES];
        [_endButton setEnabled:NO];
    }
    show = !show;
    [_clipButton setHidden:show];
    [_beginButton setHidden:show];
    [_endButton setHidden:show];
    [_tapToEditLabel setHidden:show];
}
- (void) displayClipSelectButtons:(BOOL)show
{
    show = !show;
    [_priorClipButton setHidden:show];
    [_nextClipButton setHidden:show];
    [_playSegmentButton setHidden:show];
    [_loopSegmentButton setHidden:show];
}
- (void) displayClipEditButtons:(BOOL)show
{
    show = !show;
    [_changeEndButton setHidden:show];
    [_changeBeginButton setHidden:show];
    [_changeBeginButton setSelected:show];
    [_changeEndButton setSelected:show];
    [_cancelEditButton setEnabled:!show];
    [_cancelEditButton setHidden:show];
    [_saveButton setHidden:show];
    [_saveButton setEnabled:!show];
    [_deleteClipButton setHidden:show];
    [_deleteClipButton setEnabled:!show];
    [_highlightBarsStepper setHidden:show];
    [_highlightBarsLabel setHidden:show];
    [_highlightLinesLabel setHidden:show];
    [_highlightLinesStepper setHidden:show];

}

- (void) displayBarTimeButtons:(BOOL)show
{
    show = !show;
    [_barTimeTestButton setHidden:show];
    [_barTimeDecreaseButton setHidden:show];
    [_barTimeIncreaseButton setHidden:show];
}

- (void) displayPlaybackSpeedButtons:(BOOL)show
{
    show = !show;
    [_playbackSpeedButton setHidden:show];
    [_playbackSpeedDecreaseButton setHidden:show];
    [_playbackSpeedIncreaseButton setHidden:show];
}

- (IBAction)highlightLinesChanged:(id)sender {
    [self clearBarMarkers:NO];
    _numHighlightLines = _highlightLinesStepper.value;
    NSString *label = [NSString stringWithFormat:@"Lines: %i",_numHighlightLines];
    [_highlightLinesLabel setText:label];
    [_imageHighlightInstructions setText:@"Drag the red dot to the top of the tab at the start of the clip"];
    _highlightPointNumber = 1;
    if (_dragClipMarker)
    {
        [_dragClipMarker cancelsTouchesInView];
        [_dragClipMarker setEnabled:NO];
        [_dragClipMarker setDelegate:nil];
        [_ImageDisplay removeGestureRecognizer:_dragClipMarker];
        _dragClipMarker = nil;
    }
    if (_clipMarker)
        [_clipMarker removeFromSuperview];
    _dragClipMarker = UIPanGestureRecognizer.new;
    [_dragClipMarker addTarget:self action:@selector(clipMarkerDragged:)];
    _dragClipMarker.delegate = self;
    [_ImageDisplay addGestureRecognizer:_dragClipMarker];
    _clipMarker = UILabel.new;
    _clipMarker.backgroundColor = UIColor.redColor;
    CGPoint center;
    center.x = _ImageDisplay.frame.size.width / 2;
    center.y = _ImageDisplay.frame.size.height /2;
    _clipMarker.frame = CGRectMake(center.x,center.y, 15, 15);
    [_ImageDisplay addSubview:_clipMarker];

}
- (IBAction)highlightBarsChanged:(id)sender {
    _numBarsInClip = _highlightBarsStepper.value;
    NSString *label = [NSString stringWithFormat:@"Bars: %i",_numBarsInClip];
    [_highlightBarsLabel setText:label];
    [self createBarMarkers:_numBarsInClip];
    [self editBarMarkers];
}

- (IBAction)delayChanged:(id)sender {
    _loopDelay = _delaySwitch.on;
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
    if (_highlightLayer)
    {
        _highlightLayer.path = nil;
        [_highlightLayer removeFromSuperlayer];
        _highlightLayer = nil;
    }
    if (_trackLabel)
    {
        [_trackLabel removeFromSuperview];
        _trackLabel = nil;
    }

    if (_trackPoints)
    {
        free (_trackPoints);
        free (_trackLineWidths);
    }
    _trackPoints = 0;
    _trackLineWidths = 0;
    _numTrackLines = 0;

}

-(void) saveTrackData
{
    _savedNumTrackLines = _numTrackLines;
    _savedNumHighlightLines = _numHighlightLines;
    _savedTrackPoints = (LPDPOINT)malloc (sizeof(DPOINT)*_numTrackLines*2 + 4);
    memmove (_savedTrackPoints,_trackPoints,sizeof(DPOINT)*_numTrackLines*2 + 4);
    _savedTrackLineWidths = (LPDOUBLE)malloc (sizeof(double)*_numTrackLines + 4);
    memmove (_savedTrackLineWidths,_trackLineWidths,sizeof(double)*_numTrackLines + 4);
    _savedTrackLineSpacing = _trackLineSpacing;
    _savedTotTrackLineWidth = _totTrackLineWidth;
    _savedTrackLineBasePoint = _trackLineBasePoint;
    _savedDistToFirstTrack = _distToFirstTrack;
    return;
}

- (void) restoreTrackData
{
    _numTrackLines = _savedNumTrackLines;
    _numHighlightLines = _savedNumHighlightLines;
    if (_trackPoints)
        free (_trackPoints);
    _trackPoints = (LPDPOINT)malloc (sizeof(DPOINT)*_numTrackLines*2 + 4);
    memmove (_trackPoints,_savedTrackPoints,sizeof(DPOINT)*_numTrackLines*2 + 4);
    if (_trackLineWidths)
        free (_trackLineWidths);
    _trackLineWidths = (LPDOUBLE)malloc (sizeof(double)*_numTrackLines + 4);
    memmove (_trackLineWidths,_savedTrackLineWidths,sizeof(double)*_numTrackLines + 4);
    _trackLineSpacing = _savedTrackLineSpacing;
    _totTrackLineWidth = _savedTotTrackLineWidth;
    _trackLineBasePoint = _savedTrackLineBasePoint;
    _distToFirstTrack = _savedDistToFirstTrack;
    return;
}
-(void) createHighlight:(CGPoint)imagePoint1
                 point2:(CGPoint)imagePoint2
               numLines:(int)numLines
                 inView:(UIImageView *)view
                  hTran:(HANDLE)hTranImageToView
               doUpdate:(BOOL)update
{
    UIViewContentMode am = view.contentMode;
    if (am == UIViewContentModeScaleAspectFill)
        am = 0;
    [self removeHighlightFromView:view];
    CGRect viewRect = view.bounds;
    CGRect imageRect = [self imageRectInView:view];
    CGFloat vw = viewRect.size.width;
    CGFloat vh = viewRect.size.height;
    CGFloat iw = view.image.size.width;
    iw = _rightMargin;
    CGFloat ih = view.image.size.height;
    int np = 0;
    CGPoint viewPoint1 = TranCGPoint(imagePoint1, hTranImageToView);
    CGPoint viewPoint2 = TranCGPoint(imagePoint2, hTranImageToView);
    _numTrackLines = numLines;
    _numHighlightLines = numLines;
    _trackPoints = (LPDPOINT)malloc (sizeof(DPOINT)*_numTrackLines*2 + 4);
    _trackLineWidths = (LPDOUBLE)malloc (sizeof(double)*_numTrackLines + 4);
    int lineHeight = (imagePoint2.y - imagePoint1.y)/numLines;
    _trackLineSpacing = (viewPoint2.y - viewPoint1.y)/numLines;
    CGPoint pt = imagePoint1;
    pt.y += lineHeight;
    _trackPoints[np++] = CGPointToDPOINT(pt);
    if (numLines == 1)
    {
        pt.x = imagePoint2.x;
        _trackPoints[np++] = CGPointToDPOINT(pt);
    }
    else
    {
        pt.x = iw;
        _trackPoints[np++] = CGPointToDPOINT(pt);
        for (int i = 1;i<numLines-1;i++)
        {
            pt.x = _leftMargin;
            pt.y += lineHeight;
            _trackPoints[np++] = CGPointToDPOINT(pt);
            pt.x = iw;
            _trackPoints[np++] = CGPointToDPOINT(pt);
        }
        pt.x = _leftMargin;
        pt.y  = imagePoint2.y;
        _trackPoints[np++] = CGPointToDPOINT(pt);
        _trackPoints[np++] = CGPointToDPOINT(imagePoint2);
    }
    for (int i=0;i<np;i++)
    {
        DPOINT tp = _trackPoints[i];
        _trackPoints[i] = TranPoint (&tp,hTranImageToView);
        tp = _trackPoints[i];
        ii = 1;
    }

    CGPoint vpoint={0,0};
    CGPoint ipoint={0,0};
    CGPoint framePoints[4];
    [self frameToPoints:view.frame
                 points:(CGPoint *)framePoints];
    UIBezierPath *highlightPath = UIBezierPath.new;
    [highlightPath moveToPoint: vpoint];
    vpoint.x = vw;
    [highlightPath addLineToPoint:vpoint];
    vpoint.y = vh;
    [highlightPath addLineToPoint:vpoint];
    vpoint.x = 0;
    [highlightPath addLineToPoint:vpoint];
    vpoint.y = 0;
    [highlightPath addLineToPoint:vpoint];
    vpoint = TranCGPoint (imagePoint1,hTranImageToView);
    [highlightPath moveToPoint: vpoint];
    if (numLines == 1)
    {
        ipoint = imagePoint1;
        ipoint.y = imagePoint2.y;
        vpoint = TranCGPoint (ipoint,hTranImageToView);
        [highlightPath addLineToPoint: vpoint];
        ipoint = imagePoint2;
        vpoint = TranCGPoint (ipoint,hTranImageToView);
        [highlightPath addLineToPoint:vpoint];
        ipoint = imagePoint1;
        ipoint.x = imagePoint2.x;
        vpoint = TranCGPoint (ipoint,hTranImageToView);
        [highlightPath addLineToPoint:vpoint];
        ipoint = imagePoint1;
        vpoint = TranCGPoint (ipoint,hTranImageToView);
        [highlightPath addLineToPoint: vpoint];
    }
    else
    {
        CGPoint points[8];
        ipoint = imagePoint1;
        points[0] = ipoint;
        ipoint.x = iw;
        points[1] = ipoint;
        ipoint.y = imagePoint2.y - lineHeight;
        points[2] = ipoint;
        ipoint.x = imagePoint2.x;
        points[3] = ipoint;
        ipoint.y = imagePoint2.y;
        points[4] = ipoint;
        ipoint.x = _leftMargin;
        points[5] = ipoint;
        ipoint.y = imagePoint1.y + lineHeight;
        points[6] = ipoint;
        ipoint.x = imagePoint1.x;
        points[7] = ipoint;
        for (int i=7;i>0;i--)
        {
            vpoint = TranCGPoint (points[i],hTranImageToView);
            [highlightPath addLineToPoint:vpoint];
        }
    }
    [highlightPath closePath];
    _highlightLayer = CAShapeLayer.new;
    _highlightLayer.path = highlightPath.CGPath;
    _highlightLayer.fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
    [view.layer addSublayer:_highlightLayer];
    
    if (_trackLabel)
        [_trackLabel removeFromSuperview];
    _trackLabel = UILabel.new;
    _trackLabel.frame = CGRectMake(0,0,50,50);
    _trackLabel.backgroundColor = UIColor.clearColor;//[UIColor colorWithRed:0.1 green:0.9 blue:0.1 alpha:0.5];
    _trackLabel.textColor = UIColor.greenColor;
    _trackLabel.font =[UIFont boldSystemFontOfSize:40];
    _trackLabel.adjustsFontSizeToFitWidth = YES;
    _trackLabel.textAlignment = NSTextAlignmentCenter;
   
    _trackLabel.text = @"^";
    CGPoint pt2 = view.frame.origin;
    _trackLineBasePoint = pt2;
    pt2.x += _trackPoints[0].x;
    pt2.y += _trackPoints[0].y;
    [self.view addSubview:_trackLabel];
    _trackLabel.center = pt2;
    _totTrackLineWidth = 0;
    for (int i = 0;i<_numTrackLines;i++)
    {
        _trackLineWidths[i] = ldistp(_trackPoints[i*2], _trackPoints[i*2+1]);
        _totTrackLineWidth += _trackLineWidths[i];
    }
    if (update)
    {
        BOOL opened = [self open];
        NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CLIPHIGHLIGHT VALUES(%i,%li,%i,%f,%f,%f,%f,%f,%f);",
                         _currentClipID,_currentImageID,numLines,imagePoint1.x,imagePoint1.y,imagePoint2.x,imagePoint2.y,iw,ih];
        BOOL rtn = [self executeCmd:cmd];
        [self close:opened];
    }
    if (_totTrackLineWidth == 0)
        ii = 1;
}
-(void) displayTrack
{
    if (_numTrackLines < 1)
        return;
    
    return;
}
- (IBAction)fullScreenReturnButtonTapped:(id)sender {
    [self hideAllViews:NO];
    _inFullScreen = NO;
    if (_currentSongType == YOUTUBEVIDEO)
    {
        CGRect frame = _ImageDisplay.frame;
        [self.playerView setFrame:frame];
        [self.playerView setHidden:NO];
    }
    else
    {
        [self.playerView setHidden:YES];       
        [_imageFrame setHidden:NO];
        [_ImageDisplay setHidden:NO];
    }
    [_selectCollectionButton setHidden:NO];
    [_songTitleLabel setHidden:NO];
    [_numClipsLabel setHidden:NO];
    [_currentCollectionLabel setHidden:NO];
    
    [_fullScreenImageDisplay setHidden:YES];
    [_fullScreenReturnButton setHidden:YES];
    [_monitorButton setHidden:NO];
    [_tunerButton setHidden:NO];
    [_monitorVolumeSlider setHidden:NO];
    [_effectsButton setHidden:NO];
    [_playSegmentButton setFrame:_savePlaySegmentFrame];
    [_loopSegmentButton setFrame:_saveLoopSegmentFrame];
    [_sliderTextLabel setFrame:_saveSliderTextLabelFrame];
    [self setPlayAndRecordButtonLocation];
    [_playbackSpeedButton setHidden:YES];
    [_playbackSpeedDecreaseButton setHidden:YES];
    [_playbackSpeedIncreaseButton setHidden:YES];

    _haveTempHighlight = NO;
    [self setupClip];
    [self displayHighlightForClip:_currentClipID inView:_ImageDisplay];

}

- (IBAction)saveImagePicked:(id)sender
{
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO IMAGES (PracticeGroupID,FromTime,ToTime, LeftMargin, RightMargin) VALUES(%li,%.1f,%.1f,%i,%i)",(long)_currentPracticeGroupID,_imageStartAt,_imageEndAt,_leftMargin,_rightMargin];
    [self executeCmd:cmd];

    NSString *query = @"SELECT MAX(IMAGEID) FROM IMAGES";
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        self.currentImageID = sqlite3_column_int64(statement, 0);
    }
    else
        self.currentImageID = 0;
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
    
    NSString *path = [NSString stringWithFormat:@"%@/%li.png",_imagesDirectory,_currentImageID];
    BOOL st = [UIImagePNGRepresentation(_currentImage) writeToFile:path atomically:YES];
    [self close:opened];

    [self displayAddImageButtons:NO];

    [_ImageDisplay setImage:nil];
    [self displayClipAddButtons:NO];

    self.currentImageID = -1;
    CloseTRANS2 (&_hTranImageToView);
    CloseTRANS2 (&_hTranViewToImage);

    _images = [self getImagesForPracticeGroup:_currentPracticeGroupID];
    _inAddImageMode = NO;
    [self updateNumClipsLabel];
    
    [self clearMargins];
}
-(void) testImages
{
    BOOL opened = [self open];

    NSString *query = @"SELECT * FROM IMAGES";
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int i=0;
        long currentImageID = sqlite3_column_int64(statement, i++);
        long pgID = sqlite3_column_int64(statement, i++);
        float ft = sqlite3_column_double(statement, i++);
        float tt = sqlite3_column_double(statement, i++);
        i++;
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
    
    [self close:opened];

}

- (IBAction)selectCollectionTapped:(id)sender {
{
        NSMutableArray *optionList = NSMutableArray.array;

    [optionList addObject:@"Add New Collection"];
    [optionList addObject:@"All Practice Groups"];
        [optionList addObject:@"________________________"];
    NSArray *collections = [self getAllCollectionsUnder:_currentCollectionID];
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
    NSString *title = [NSString stringWithFormat:@"Verify Delete of Clip %i",_currentClip+1];
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
    [_songTitleLabel setText:label];
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
    [_ImageDisplay setHidden:NO];
    [self displayAddImageButtons:YES];
    [self displayClipAddButtons:NO];
    [_saveImageButton setEnabled:NO];
    _imageStartAt = _imageEndAt = 0;
    [self imageEndAtTapped:nil];
    [self imageStartAtTapped:nil];
    [self removeHighlightFromView:_ImageDisplay];
    _adjustingLeftMargin = YES;
    _leftMargin = 0;
    _rightMargin = _currentImage.size.width;
    [_marginSelectionButton setTitle:@"Set Left\nMargin" forState:UIControlStateNormal];
    [self createTransforms:_ImageDisplay];

    _inAddImageMode = YES;
    return;
}
- (BOOL) displayYouTubeVideo:(NSString *) link
{
    [self hideAllViews:YES];
    _slider.maximumValue = _currentSongDuration;
    _slider.minimumValue = 0;
    _slider.continuous = YES;
    _currentTime = 0;
    _beginTime = _currentTime;
    _clipIDs = NSMutableArray.new;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _barsInClip = NSMutableArray.new;
    _currentClip = -1;
    _currentClipID = -1;
    [self removeHighlightFromView:_ImageDisplay];
    [_playButton setEnabled:YES];
    [_beginButton setEnabled:YES];
    [_endButton setEnabled:YES];
    [_playSegmentButton setEnabled:YES];
    [_loopSegmentButton setEnabled:YES];
    [_nextClipButton setEnabled:YES];
    [_priorClipButton setEnabled:YES];
    [_fullScreenButton setHidden:NO];
    [_saveButton setEnabled:NO];
    [_ImageDisplay setHidden:YES];
    [_tunerButton setHidden:NO];
    _YouTubeName = _currentSongTitle;
    [self retrieveSong:_currentPracticeGroupID
              setTimes:YES];
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
    if (_inLoop)
        [self initLoop];
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
    [controller dismissViewControllerAnimated:NO completion:nil];
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
