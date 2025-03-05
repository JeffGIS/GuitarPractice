//
//  EffectsViewController.m
//  GuitarPractice
//
//  Created by Jeff Smith on 6/29/24.
//  Copyright © 2024 GSSI. All rights reserved.
//

#import "EffectsViewController.h"
#import "ViewController.h"

@interface EffectsViewController ()
@property NSArray *distortions;
@property NSArray *reverbs;
@property int currentRowY;
@property int labelRowY;
@property int rowHeight;
@property int rowGap;
@property int typeWidth;
@property int nameWidth;
@property int sliderWidth;
@property int rowLeft;
@property UILabel *wetDryMixLabel;
@property UILabel *pregainLabel;

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

- (void) viewWillAppear:(BOOL)animated
{
    [self displayEffects];
    return;
}
- (IBAction)volumeChanged:(UISlider*)sender
{
    [_audioEngine setOutputVolume:sender.value];
    return;
}

- (IBAction)addDistortionTapped:(id)sender {
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:@"Distortions"
                                                                     textArray:_distortions
                                                                 includeCancel:YES];
    nvptv.allowsSubtitle = NO;

}

- (IBAction)addReverbTapped:(id)sender {
    NVPopoverTableView *nvptv = [NVPopoverTableView showPopoverTableViewInView:self.view
                                                                      delegate:self
                                                                         title:@"Reverbs"
                                                                     textArray:_reverbs
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
    if ([popoverTableView.title isEqual:@"Reverbs"])
    {
        UILabel *typeLabel = UILabel.new;
        typeLabel.text = @"Reverb:";
        [self addEffect:REVERB
                     ID:index];
    }
    else
    {
        [self addEffect:DISTORTION
                     ID:index];

    }
    [popoverTableView hide:YES];
}

-(void) addEffect:(EffectType)type
               ID:(int)effectID
{
    EffectsData *efdata = EffectsData.new;
    [efdata setTypeAndID:type
                      ID:effectID];
    [_effectsArray addObject:efdata];
    [_delegate EffectsViewController:self didReturn:DID_UPDATE];
}
-(void) removeEffectTapped:(UIButton *)button
{
    
}

- (void) wetDrySliderValueChanged:(id)sender
{
    return;
}

- (void) removeEffects
{
    [_wetDryMixLabel removeFromSuperview];
    [_pregainLabel removeFromSuperview];
    for (EffectsData *efdata in _effectsArray)
    {
        [efdata.typeLabel removeFromSuperview];
        [efdata.nameLabel removeFromSuperview];
        [efdata.wetDrySlider removeFromSuperview];
        if (efdata.type == DISTORTION)
        {
            [efdata.pregainSlider removeFromSuperview];
        }
    }
    _wetDryMixLabel = 0;
    _pregainLabel = 0;
}
- (void) displayEffects
{
    BOOL first = TRUE;
    _rowLeft = _addReverbButton.frame.origin.x;
    _rowHeight = 40;
    _rowGap = 20;
    _typeWidth = 160;
    _nameWidth = 450;
    _sliderWidth = 230;
    _currentRowY = _addReverbButton.frame.origin.y + _rowHeight * 2 + _rowGap;
    _labelRowY = _currentRowY;
    for (EffectsData *efdata in _effectsArray)
    {
        if (first)
        {
            first = FALSE;
        }
        else
        {
            efdata.typeLabel.frame = CGRectMake(_rowLeft, _currentRowY, _typeWidth, _rowHeight);
            efdata.nameLabel.frame = CGRectMake(_rowLeft + _typeWidth, _currentRowY, _nameWidth, _rowHeight);
            if (efdata.type == REVERB)
                efdata.typeLabel.text = @"Reverb:";
            else
                efdata.typeLabel.text = @"Distortion:";
            [efdata.typeLabel setHidden:NO];
            efdata.typeLabel.textColor = UIColor.blackColor;
            efdata.typeLabel.backgroundColor = UIColor.whiteColor;
            efdata.typeLabel.font = [UIFont systemFontOfSize: 32];
            [self.view addSubview:efdata.typeLabel];
            //efdata.typeLabel.center = CGPointMake(self.view.frame.size.width / 2,self.view.frame.size.height / 2);
            if (efdata.type == REVERB)
                efdata.nameLabel.text = _reverbs[efdata.effectID];
            else
                efdata.nameLabel.text = _distortions[efdata.effectID];
            efdata.nameLabel.backgroundColor = UIColor.grayColor;
            [self.view addSubview:efdata.nameLabel];
            efdata.nameLabel.textColor = UIColor.blackColor;
            efdata.nameLabel.backgroundColor = UIColor.whiteColor;
            efdata.nameLabel.font = [UIFont systemFontOfSize: 32];
            efdata.wetDrySlider.frame = CGRectMake(_rowLeft + _typeWidth + _nameWidth, _currentRowY, _sliderWidth, _rowHeight);
            [self.view addSubview:efdata.wetDrySlider];
            if (efdata.type == DISTORTION)
            {
                [self addSliderLabel:DISTORTION];
                efdata.pregainSlider.frame = CGRectMake(_rowLeft + _typeWidth + _nameWidth + _sliderWidth + _sliderWidth / 8, _currentRowY, _sliderWidth, _rowHeight);
                [self.view addSubview:efdata.pregainSlider];
            }
            else
                [self addSliderLabel:REVERB];
            //[efdata.wetDrySlider removeFromSuperview];
        }
        _currentRowY += _rowHeight + _rowGap;
    }
   
}
-(void) addSliderLabel:(EffectType)type
{
    if (!_wetDryMixLabel)
    {
        _wetDryMixLabel = UILabel.new;
        _wetDryMixLabel.frame = CGRectMake(_rowLeft + _typeWidth + _nameWidth, _labelRowY, _sliderWidth, _rowHeight);
        _wetDryMixLabel.backgroundColor = UIColor.clearColor;
        _wetDryMixLabel.textColor = UIColor.blackColor;
        _wetDryMixLabel.font =[UIFont systemFontOfSize: 20];
        _wetDryMixLabel.adjustsFontSizeToFitWidth = YES;
        _wetDryMixLabel.textAlignment = NSTextAlignmentCenter;
        _wetDryMixLabel.numberOfLines = 1;
        _wetDryMixLabel.text = @"Wet/Dry Mix";
        [self.view  addSubview:_wetDryMixLabel];
    }
    if (type == DISTORTION && !_pregainLabel)
    {
        _pregainLabel = UILabel.new;
        _pregainLabel.frame = CGRectMake(_rowLeft + _typeWidth + _nameWidth + _sliderWidth + _sliderWidth / 8, _labelRowY, _sliderWidth, _rowHeight);
        _pregainLabel.backgroundColor = UIColor.clearColor;
        _pregainLabel.textColor = UIColor.blackColor;
        _pregainLabel.font =[UIFont systemFontOfSize: 20];
        _pregainLabel.adjustsFontSizeToFitWidth = YES;
        _pregainLabel.textAlignment = NSTextAlignmentCenter;
        _pregainLabel.numberOfLines = 1;
        _pregainLabel.text = @"Pregain";
        [self.view  addSubview:_pregainLabel];
    }

}
- (IBAction)returnButtonTapped:(id)sender
{
    [_delegate EffectsViewController:self didReturn:DID_COMPLETE];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [_delegate EffectsViewController:self didReturn:DID_CANCEL];
}

- (IBAction)clearButtonTapped:(id)sender {
    [_effectsArray removeAllObjects];
    [_delegate EffectsViewController:self didReturn:DID_CLEAR];
}
@end
