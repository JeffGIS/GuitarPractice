//
//  RecordSongViewController.m
//  GuitarPractice
//
//  Created by Jeff Smith on 2/22/25.
//  Copyright © 2025 GSSI. All rights reserved.
//

#import "RecordSongViewController.h"
typedef NS_ENUM(NSInteger, AudioControllerState)
{
    stopped,
    playing,
    recording
};

@interface RecordSongViewController ()
@property AVAudioRecorder *recorder;
@property AVAudioSession *audioSession;
@property AudioControllerState state;
@property AVAudioPlayer *player;
@end

@implementation RecordSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAudioSession];
    [self setupRecorder];
    [self enableBuiltInMic];

    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)returnTapped:(id)sender {
    [_delegate RecordSongViewController:self didComplete:YES];

}

- (IBAction)stopTapped:(id)sender {
    if (_state == recording)
        [self stopRecording];
    else
        [self stopPlayback];
}

- (IBAction)playTapped:(id)sender {
    [self play];
}

- (IBAction)recordTapped:(id)sender {
    [self record];
}
-(void) setupAudioSession
{
/*    do {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
    } catch {
        fatalError("Failed to configure and activate session.")
    }*/
    NSError *err = nil;
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [_audioSession setPreferredInputOrientation:AVAudioStereoOrientationLandscapeRight error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    }
    [_audioSession setActive:YES error:&err];
}

-(BOOL) enableBuiltInMic
{
    NSError *err = nil;
    BOOL haveMic = FALSE;
    AVAudioSessionPortDescription *builtInMicInput=nil;
    // Find the built-in microphone input.
    for (AVAudioSessionPortDescription * input in _audioSession.availableInputs)
    {
        if (input.portType == AVAudioSessionPortBuiltInMic)
            builtInMicInput = input;
    }
    if (!builtInMicInput)
        return FALSE;
    
    [_audioSession setPreferredInput:builtInMicInput error:&err];
    if(err){
        NSLog(@"renableBuiltInMic: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return FALSE;
    }
    AVAudioSessionPortDescription *preferredInput = _audioSession.preferredInput;
    NSArray *dataSources = preferredInput.dataSources;
    AVAudioSessionDataSourceDescription *dataSource;
    for (AVAudioSessionDataSourceDescription *ds in dataSources)
    {
        if ([ds.dataSourceName isEqual:@"Front"])
            dataSource = ds;
    }
    NSArray *supportedPolarPatterns = dataSource.supportedPolarPatterns;
//          let newDataSource = dataSources.first(where: { $0.dataSourceName == option.dataSourceName }),
//          let supportedPolarPatterns = newDataSource.supportedPolarPatterns else {

    AVAudioSessionPolarPattern pp = supportedPolarPatterns[0];
    [dataSource setPreferredPolarPattern:AVAudioSessionPolarPatternStereo error:&err];
    if(err){
        NSLog(@"renableBuiltInMic: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return FALSE;
    }
    return TRUE;
}

-(void) setupRecorder
{
    NSError *err = nil;
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    // We can use kAudioFormatAppleIMA4 (4:1 compression) or kAudioFormatLinearPCM for nocompression
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    // We can use 44100, 32000, 24000, 16000 or 12000 depending on sound quality
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    
    // We can use 2(if using additional h/w) or 1 (iPhone only has one microphone)
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    // These settings are used if we are using kAudioFormatLinearPCM format
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [_audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    [_audioSession setPreferredOutputNumberOfChannels:2 error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:_currentSongURL settings:recordSetting error:&err];
    
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
    
    [_recorder setDelegate:self];
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
    
    
    BOOL audioHWAvailable = _audioSession.inputIsAvailable;
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
    
}
-(BOOL) record
{
    BOOL started = [_recorder record];
    _state = recording;
    return started;
}

// Stops recording and calls the completion callback when the recording finishes.
-(void) stopRecording
{
    [_recorder stop];
    _state = stopped;
}

-(BOOL) play
{
    NSError *err = nil;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL: _currentSongURL error:&err];
    if (err)
    {
        NSLog([err localizedDescription]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];

        return FALSE;
    }
    [_player setMeteringEnabled:TRUE];
    _player.delegate = self;
    [_player play];
    _state = playing;
    return TRUE;
}

-(void) stopPlayback
{
    [_player stop];
    _state = stopped;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    return;
}
@end
