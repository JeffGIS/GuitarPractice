//
//  EffectsViewController.m
//  GuitarPractice
//
//  Created by Jeff Smith on 6/29/24.
//  Copyright © 2024 GSSI. All rights reserved.
//

#import "EffectsViewController.h"

@interface EffectsViewController ()
@property NSArray *distortions;
@property NSArray *reverbs;
@end

@implementation EffectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _distortions = @[@"DrumsBitBrush"
                     ,@"DrumsBufferBeats"
                     ,@"DrumsLoFi"
                     ,@"MultiBrokenSpeaker"
                     ,@"MultiCellphoneConcert"
                     ,@"MultiDecimated1"
                     ,@"MultiDecimated2"
                     ,@"MultiDecimated3"
                     ,@"MultiDecimated4"
                     ,@"MultiDistortedFunk"
                     ,@"MultiDistortedCubed"
                     ,@"MultiDistortedSquared"
                     ,@"MultiEcho1"
                     ,@"MultiEcho2"
                     ,@"MultiEchoTight1"
                     ,@"MultiEchoTight2"
                     ,@"MultiEverythingIsBroken"
                     ,@"SpeechAlienChatter"
                     ,@"SpeechCosmicInterference"
                     ,@"SpeechGoldenPi"
                     ,@"SpeechRadioTower"
                     ,@"SpeechWaves"];
    _reverbs = @[@"SmallRoom"
                 ,@"MediumRoom"
                 ,@"LargeRoom"
                 ,@"MediumHall"
                 ,@"LargeHall"
                 ,@"Plate"
                 ,@"MediumChamber"
                 ,@"LargeChamber"
                 ,@"Cathedral"
                 ,@"LargeRoom2"
                 ,@"MediumHall2"
                 ,@"MediumHall3"
                 ,@"LargeHall2"];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)reverbSwitchChanged:(id)sender {
}
@end
