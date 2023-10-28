//
//  ViewController.m
//  GuitarPractice
//
//  Created by Jeff Smith on 1/18/20.
//  Copyright © 2020 GSSI. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

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
    [_slider setValue:0];
 
}

- (IBAction) showMediaPicker: (id) senderx {

    _picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    
    _picker.delegate                        = self;
    _picker.allowsPickingMultipleItems    = NO;
    _picker.prompt                        = NSLocalizedString (@"Select a song", @"Prompt to user to choose some songs to play");
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];

    [self presentModalViewController: _picker animated: YES];
}


- (IBAction)selectSongTapped:(id)sender {
    [_appSoundPlayer stop];
    [_slider setValue:0];
    _inLoop = NO;
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    [self showMediaPicker:sender];
    [self setCurrentPositiion:NO];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    // Apply the chosen songs to the music player's queue.
    //[self updatePlayerQueueWithMediaCollection: mediaItemCollection];

    if (mediaItemCollection.items.count == 1)
    {
        _currentSong = mediaItemCollection.items[0];
        
        _songTitleLable.text = _currentSong.title;
        _currentSongURL = [_currentSong valueForProperty:MPMediaItemPropertyAssetURL];
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: _currentSongURL error:nil];
         _appSoundPlayer = newPlayer;
        
         // "Preparing to play" attaches to the audio hardware and ensures that playback
         //        starts quickly when the user taps Play
         [_appSoundPlayer prepareToPlay];
         [_appSoundPlayer setVolume: 1.0];
         [_appSoundPlayer setDelegate: self];
        _slider.maximumValue = _currentSong.playbackDuration;
        _slider.minimumValue = 0;
        _slider.continuous = NO;
        _currentTime = _appSoundPlayer.currentTime;
        _beginTime = _currentTime;
        _beginTimes = NSMutableArray.new;
        _endTimes = NSMutableArray.new;
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
        [self retrieveSong:_currentSong.title];

    }
    [_picker dismissViewControllerAnimated:YES completion:nil] ;
    return;
}
- (IBAction)playTapped:(id)sender {
    [_appSoundPlayer stop];
    _appSoundPlayer.currentTime = 0;
    _inLoop = NO;
    _beginTime = 0;
    _endTime = _currentSong.playbackDuration;
    [self setCurrentPositiion:YES];
}

- (IBAction)markEndTapped:(id)sender {
    _endTime = _appSoundPlayer.currentTime;
    NSNumber *bTime = [NSNumber numberWithInt:_beginTime];
    NSNumber *eTime = [NSNumber numberWithInt:_endTime];
    [_endTimes addObject:eTime];
    [_beginTimes addObject:bTime];
    _currentSegment = (int)_endTimes.count - 1;
    [self setCurrentPositiion:NO];
    BOOL opened = [self open];
    NSString *cmd = [NSString stringWithFormat:@"INSERT INTO Songs VALUES('%@',%i,%i)",_currentSong.title,_beginTime,_endTime];
    [self executeCmd:cmd];
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
        [_slider setValue:_beginTime];
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
    _beginTime = _appSoundPlayer.currentTime;
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
    [_slider setValue:_appSoundPlayer.currentTime];
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
    [_appSoundPlayer stop];
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
        [self setCurrentPositiion:YES];

    }
}

- (IBAction)nextSegmentTapped:(id)sender {
    if (_currentSegment + 1 < _beginTimes.count)
    {
        _currentSegment++;
        _inLoop = NO;
        _beginTime = (int)_beginTimes[_currentSegment].integerValue;
        _endTime = (int)_endTimes[_currentSegment].integerValue;
        [self setCurrentPositiion:YES];

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
    if (!_isOpen)
    {
        NSString *documentsDirectory = UserDefaults.defaults.localFilePath;
        NSString *songDB = [NSString stringWithFormat:@"%@/songs.slt",documentsDirectory];
        _isOpen = !SQLOK(__FILE__,__LINE__,SQLite_Open(songDB.UTF8String, &_database), _database);
        NSLog(@"Database open");
        
        long fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:songDB                                                                  error:nil].fileSize;
        
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
    NSString * cmd = @"CREATE TABLE IF NOT EXISTS SONGS ('Title' CHAR(256),'StartTime' INT,'EndTime' INT,  PRIMARY KEY (Title,StartTime))";
    
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
    
    NSString *query = [NSString stringWithFormat:@"SELECT StartTime,EndTime FROM SONGS WHERE Title = '%@' ORDER BY StartTime",title];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    _beginTimes = NSMutableArray.new;
    _endTimes = NSMutableArray.new;
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        int beginTime = sqlite3_column_int(statement, 0);
        int endTime = sqlite3_column_int(statement, 1);
        NSNumber *bTime = [NSNumber numberWithInt:beginTime];
        NSNumber *eTime = [NSNumber numberWithInt:endTime];
        [_endTimes addObject:eTime];
        [_beginTimes addObject:bTime];
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);

    [self close:opened];
    _currentSegment = 0;
    [self setCurrentPositiion:NO];
}
- (IBAction)sliderExit:(id)sender {
    _beginTime = _slider.value;
    [self setCurrentPositiion:YES];
}
@end
