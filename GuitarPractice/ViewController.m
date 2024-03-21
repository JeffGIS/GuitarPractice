//
//  ViewController.m
//  GuitarPractice
//
//  Created by Jeff Smith on 1/18/20.
//  Copyright © 2020 GSSI. All rights reserved.
//

#import "ViewController.h"
#import "CCodeLibrary/NVPopoverTableView.h"
#import "CCodeLibrary/StringFunctions.h"

typedef NS_ENUM(NSInteger, SongTypes)
{
    SONG,
    YOUTUBEVIDEO,
};

@interface ViewController ()
@property AVAudioSession* audioSession;
@property AVAudioPlayer *appSoundPlayer;
@property MPMediaItem * currentSong;
@property int currentSongDuration;
@property NSURL *currentSongURL;
@property (nonatomic) MPMediaItemCollection      *userMediaItemCollection;
@property (nonatomic) MPMusicPlayerController    *musicPlayer;
@property MPMediaPickerController *picker;
@property int currentTime;
@property int beginTime;
@property int endTime;
@property NSMutableArray<NSNumber*> *beginTimes;
@property NSMutableArray<NSNumber*> *endTimes;
@property NSMutableArray<NSNumber*> *linkPrefixes;
@property NSString *collectionsDirectory;
@property NSString *linksDirectory;
@property int currentLinkPrefix;
@property UIImage *currentImage;
@property NSString * currentSongTitle;
@property int numFilesForCurrentLink;
@property NSString *currentLinkFile;
@property int currentFileNum, currentNumFiles;
@property NVWebView * webView;
@property NSString *currentCollection;
@property NSString * currentYouTubeLink;
@property SongTypes currentSongType;
@property float currentYTTime;
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


    [self registerForMediaPlayerNotifications];

    [self setupApplicationAudio];
    _beginTime = 86;
    [_currentPositionLabel setText:@""];
    [self setSliderValue:0];
    _currentCollection = @"Songs";
    _currentCollectionLabel.text = _currentCollection;
    _currentSongTitle = @"";
    BOOL opened = [self open];
    [self close:opened];
    [self createCollection:@"Blues Guitar"];
    [self createCollection:@"Rock Guitar"];
    [self createCollection:@"Acoustic Guitar"];
    [self createCollection:@"Base Guitar"];
    [self createCollection:@"Ukulele"];
    self.playerView.delegate = self;
}
- (void)playerView:(nonnull YTPlayerView *)playerView didPlayTime:(float)playTime
{
    _currentYTTime = playTime;
    NSString *mess = [NSString stringWithFormat:@"At time:%f",playTime];
    NSLog (mess);
}
- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state)
    {
        case kYTPlayerStatePlaying:
            NSLog(@"Started playback");

            break;
        case kYTPlayerStatePaused:
            NSLog(@"Paused playback");
            break;
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
- (void) setSliderValue:(int) value
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self->_slider setValue:value];
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
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];

    [self presentViewController: _picker animated:YES completion:nil];
}

- (IBAction)selectSongTapped:(id)sender
{
    NSMutableArray *optionList = NSMutableArray.array;

    [optionList addObject:@"Add New Song"];
    [optionList addObject:@"Add New YouTube Video"];
    [optionList addObject:@"________________________"];
    [self addSongsToList:optionList];
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:@"Songs"
                                                                     textArray:optionList
                                                                 includeCancel:YES];
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
    if ([text isEqual:@"Add New Collection"])
    {
        [popoverTableView hide:YES];
        [self addNewSong];
    }
    if ([text isEqual:@"Add New YouTube Video"])
    {
        [popoverTableView hide:YES];
        [self displayYouTubeVideo:@"www.youtube.com"];

    }
    else if ([popoverTableView.title isEqual:@"Songs"])
    {
        NSString * url = [self getSong:text];
        if (url)
        {
            [popoverTableView hide:YES];
            if (_currentSongType == SONG)
            {
                _currentSongURL = [NSURL URLWithString:url];
                [self startNewSong];
            }
            else
            {
                _currentYouTubeLink = url;
                [self displayYouTubeVideo:_currentYouTubeLink];
            }
        }
    }
    else if ([popoverTableView.title isEqual:@"Collections"])
    {
        _currentCollection = text;
        _currentCollectionLabel.text = _currentCollection;
        [popoverTableView hide:YES];
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

- (void) addNewYouTube
{
    
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
        _currentSongDuration = _currentSong.playbackDuration;
        NSString * url = [_currentSongURL absoluteString];
        [self saveSongURL:url
                 forTitle:_currentSongTitle
                     ofType:SONG
                 duration:_currentSongDuration];
        [self startNewSong];

    }
    [_picker dismissViewControllerAnimated:YES completion:nil] ;
    return;
}

- (void) startNewYouTubeVideo
{
    _slider.maximumValue = _currentSongDuration;
    _slider.minimumValue = 0;
    _slider.continuous = NO;
    _currentTime = 0;
    _beginTime = _currentTime;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    _currentSegment = 0;
    _playButton.enabled=YES;
    _beginButton.enabled=YES;
    _endButton.enabled=YES;
    _playSegmentButton.enabled=YES;
    _loopSegmentButton.enabled=YES;
    _nextSegmentButton.enabled=YES;
    _priorSegmentButton.enabled=YES;
    _stopButton.enabled=YES;
    _saveButton.enabled=YES;

    [self selectYouTubeVideo:_currentYouTubeLink];

}
- (void) startNewSong
{
    _songTitleLable.text = _currentSongTitle;

    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: _currentSongURL error:nil];
     _appSoundPlayer = newPlayer;
   
     // "Preparing to play" attaches to the audio hardware and ensures that playback
     //        starts quickly when the user taps Play
     [_appSoundPlayer prepareToPlay];
     [_appSoundPlayer setVolume: 1.0];
     [_appSoundPlayer setDelegate: self];
    _slider.maximumValue = _currentSongDuration;
    _slider.minimumValue = 0;
    _slider.continuous = NO;
    _currentTime = _appSoundPlayer.currentTime;
    _beginTime = _currentTime;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    _currentSegment = 0;
    _playButton.enabled=YES;
    _beginButton.enabled=YES;
    _endButton.enabled=YES;
    _playSegmentButton.enabled=YES;
    _loopSegmentButton.enabled=YES;
    _nextSegmentButton.enabled=YES;
    _priorSegmentButton.enabled=YES;
    _stopButton.enabled=YES;
    _saveButton.enabled=YES;
    _selectPhotoButton.enabled=YES;
    _selectYouTubeVideoButton.enabled=YES;
    [self retrieveSong:_currentSongTitle];
    [self playTapped:nil];

}
- (IBAction)playTapped:(id)sender {
    if (_currentSongType == SONG)
    {
        [_appSoundPlayer stop];
        _appSoundPlayer.currentTime = 0;
        _inLoop = NO;
        _beginTime = 0;
        _endTime = _currentSongDuration;
        [self setCurrentPositiion:YES];
    }
    else
        [_playerView playVideo];

}

- (void) saveSongURL:(NSString *)url
            forTitle:(NSString *)title
              ofType:(SongTypes)type
            duration:(int)duration
{
    BOOL opened = [self open];
    NSString *title2 = [title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SONGINFO (TITLE,TYPE,URL,DURATION)VALUES('%@',%i,'%@',%i)",title2,type,url,duration];
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
        LPSTR title = sqlite3_column_text(statement, 0);
        LPSTR type = sqlite3_column_text(statement, 1);
        LPSTR url = sqlite3_column_text(statement, 2);
        rtn = [NSString stringWithFormat:@"%s",url];
        _currentSongTitle = [NSString stringWithFormat:@"%s",title];
        _currentSongDuration = sqlite3_column_int(statement, 3);
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
    NSString *query = [NSString stringWithFormat:@"SELECT Title,Type, URL,Duration FROM SONGINFO WHERE Title = '%@'",title2];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR title = sqlite3_column_text(statement, 0);
        _currentSongType = sqlite3_column_int(statement, 1);
        LPSTR url = sqlite3_column_text(statement, 2);
        rtn = [NSString stringWithFormat:@"%s",url];
        _currentSongTitle = [NSString stringWithFormat:@"%s",title];
        _currentSongDuration = sqlite3_column_int(statement, 3);

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
        LPSTR title = sqlite3_column_text(statement, 0);
        NSString *sTitle = [NSString stringWithCString:title];
        [array addObject:sTitle];
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    return;
}
- (IBAction)markEndTapped:(id)sender
{
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
    [self setCurrentPositiion:NO];
    BOOL opened = [self open];
    NSString *title2 = [_currentSongTitle stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO CLIPS (TITLE,STARTTIME,ENDTIME) VALUES('%@',%i,%i)",title2,_beginTime,_endTime];
    [self executeCmd:cmd];
    NSString *query = [NSString stringWithFormat:@"SELECT ID FROM CLIPS WHERE Title = '%@' AND STARTTIME = %i AND ENDTIME = %i",title2,_beginTime,_endTime];
    
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
 
}

-(void) setCurrentPositiion:(BOOL)doPlay
{
    NSString * label = [NSString stringWithFormat:@"%i of %i",_currentSegment+1,(int)_endTimes.count];
    if (!_endTimes.count)
        label = @"";
    [_currentPositionLabel setText:label];
    if (doPlay)
    {
        [_appSoundPlayer stop];
        _appSoundPlayer.currentTime = _beginTime;
        [self setSliderValue:_beginTime];
        if (_timer)
            [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTime:) userInfo:nil repeats:YES];
        [_appSoundPlayer play];
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
- (IBAction)markBeginTapped:(id)sender {
    if (_currentSongType == SONG)
        _beginTime = _appSoundPlayer.currentTime;
    else
        _beginTime = _currentYTTime;
}

- (IBAction)playSegmentTapped:(id)sender {
    [_appSoundPlayer stop];
    _appSoundPlayer.currentTime = _beginTime;
    _inLoop = NO;
    [_appSoundPlayer play];
    if (_timer)
        [_timer invalidate];
    _timer = nil;
}
- (void)checkTime:(NSTimer*)timer
{
    [self setSliderValue:_appSoundPlayer.currentTime];
    if (_inLoop && _appSoundPlayer.currentTime >= _endTime)
    {
        [timer invalidate];
        [self loopSegmentTapped:nil];
    }
}
- (IBAction)stopTapped:(id)sender {
    if (_timer)
        [_timer invalidate];
    _inLoop = NO;
    if (_currentSongType == SONG)
        [_appSoundPlayer stop];
    else
        [_playerView pauseVideo];
}

- (IBAction)saveTapped:(id)sender {
}

- (IBAction)priorSegmentTapped:(id)sender {
    if (_currentSegment > 0)
    {
        _currentSegment--;
        _inLoop = NO;
        _beginTime = (int)_beginTimes[_currentSegment].integerValue;
        _endTime = (int)_endTimes[_currentSegment].integerValue;
        _currentLinkPrefix = (int)_linkPrefixes[_currentSegment].integerValue;
        _numFilesForCurrentLink = [self getNumFilesInPrefix:_currentLinkPrefix];
        [self setCurrentPositiion:YES];
        if (_numFilesForCurrentLink > 0)
            [self displayFileForLink:_linkPrefixes[0].intValue
                            numFiles:_numFilesForCurrentLink];

    }
}

- (IBAction)nextSegmentTapped:(id)sender {
    if (_currentSegment + 1 < _beginTimes.count)
    {
        _currentSegment++;
        _inLoop = NO;
        _beginTime = (int)_beginTimes[_currentSegment].integerValue;
        _endTime = (int)_endTimes[_currentSegment].integerValue;
        _currentLinkPrefix = (int)_linkPrefixes[_currentSegment].integerValue;
        _numFilesForCurrentLink = [self getNumFilesInPrefix:_currentLinkPrefix];
        [self setCurrentPositiion:YES];
        if (_numFilesForCurrentLink > 0)
            [self displayFileForLink:_linkPrefixes[0].intValue
                            numFiles:_numFilesForCurrentLink];

    }
}

- (IBAction)loopSegmentTapped:(id)sender {
    [_appSoundPlayer stop];
    _appSoundPlayer.currentTime = _beginTime;
    _inLoop = YES;
    [self setCurrentPositiion:YES];
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
        NSLog(@"PropertyList Database close");
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
        NSLog(@"Database open");
        
        long fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:songDB
                                                                                  error:nil].fileSize;
        
        rtn = TRUE;
        if (!fileSize)
        {
            rtn = [self createSongsTable];
        }
    }
    return rtn;
}

- (BOOL)createSongsTable
{
    BOOL rtn = TRUE;
    NSString * cmd = @"DROP TABLE CLIPS;DROP TABLE SONGINFO;";
    //rtn = [self executeCmd:cmd];
    
    cmd = @"CREATE TABLE IF NOT EXISTS CLIPS ('ID' INTEGER PRIMARY KEY,'Title' CHAR(256),'Type' INT,'StartTime' INT,'EndTime' INT, 'URL' CHAR(256));CREATE INDEX IF NOT EXISTS idx_clips_title ON CLIPS (Title,StartTime);";
    rtn = [self executeCmd:cmd];

    cmd = @"CREATE TABLE IF NOT EXISTS SONGINFO ('Title' CHAR(256),'Type' INT,'URL' CHAR(1024),'Duration' INT,  PRIMARY KEY (Title))";
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
    _currentSegment = 0;
    if (_linkPrefixes.count > 0)
        _currentLinkPrefix = _linkPrefixes[0].intValue;
    else
        _currentLinkPrefix = 0;
    _numFilesForCurrentLink = [self getNumFilesInPrefix:_currentLinkPrefix];
    if (_numFilesForCurrentLink > 0)
        [self displayFileForLink:_linkPrefixes[0].intValue
                        numFiles:_numFilesForCurrentLink];


    [self setCurrentPositiion:NO];
}
- (IBAction)sliderExit:(id)sender {
    _beginTime = _slider.value;
    [self setCurrentPositiion:YES];
}


- (IBAction)selectYouTubeVideo:(id)sender {
    [self displayYouTubeVideo:@"www.youtube.com"];
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

-(void) displayFileForLink:(int)fileNum
                  numFiles:(int)numFiles
{
    NSString *fileName = [NSString stringWithFormat:@"%@/%i_%i.png",_linksDirectory,_currentLinkPrefix,fileNum];
    UIImage *image = [UIImage imageWithContentsOfFile:fileName];
    [_ImageDisplay setImage:image];
    [_priorFileButton setHidden:YES];
    [_nextFileButton setHidden:YES];
    if (fileNum > 1)
        [_priorFileButton setHidden:NO];
    if (fileNum < numFiles)
        [_nextFileButton setHidden:NO];
    _currentFileNum = fileNum;
    _currentNumFiles = numFiles;
    return;
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
    [self displayFileForLink:_currentFileNum-1
                    numFiles:_currentNumFiles];
}

- (IBAction)nextFileTapped:(id)sender {
    [self displayFileForLink:_currentFileNum+1
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
        nvptv.allowsSubtitle = NO;
    }

    
}

- (IBAction)saveYouTubeTapped:(id)sender {
    
    [self showHideStartTime:NO
                   withName:YES];

    int startTimeMinutes = _startTimeMinutesInput.text.intValue;
    int startTimeSeconds = _startTimeSecondsInput.text.intValue;
    NSString *linkName = _linkName.text;
    [self saveSongURL:_currentYouTubeLink 
             forTitle:linkName
               ofType:YOUTUBEVIDEO
             duration:0];
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
- (void) displayYouTubeVideo:(NSString *) link
{
    _slider.maximumValue = _currentSongDuration;
    _slider.minimumValue = 0;
    _slider.continuous = NO;
    _currentTime = 0;
    _beginTime = _currentTime;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    _linkPrefixes = NSMutableArray.new;
    _currentSegment = 0;
    _playButton.enabled=YES;
    _beginButton.enabled=YES;
    _endButton.enabled=YES;
    _playSegmentButton.enabled=YES;
    _loopSegmentButton.enabled=YES;
    _nextSegmentButton.enabled=YES;
    _priorSegmentButton.enabled=YES;
    _stopButton.enabled=YES;
    _saveButton.enabled=YES;

    [_playerView setHidden:NO];
    link = textAfter(link, @"=");
    [self.playerView loadWithVideoId:link];
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
    if (withName)
    {
        [_linkNameLabel setHidden:showHide];
        [_linkName setHidden:showHide];
    }
}
@end
