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
@property int rowHeight;
@property int rowGap;
@property int typeWidth;
@property int nameWidth;
@property int sliderWidth;
@property int rowLeft;

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
- (IBAction)volumeChanged:(id)sender {
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
    efdata.type = type;
    efdata.effectID = effectID;
    
    [_effectsArray addObject:efdata];
    [self removeEffects];
    [self displayEffects];
}
-(void) removeEffectTapped:(UIButton *)button
{
    
}

- (void) removeEffects
{
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
}
- (void) displayEffects
{
    _rowLeft = _addReverbButton.frame.origin.x;
    _rowHeight = 40;
    _rowGap = 20;
    _typeWidth = 160;
    _nameWidth = 450;
    _sliderWidth = 230;
    _currentRowY = _addReverbButton.frame.origin.y + _rowHeight * 2 + _rowGap;
    for (EffectsData *efdata in _effectsArray)
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
            efdata.pregainSlider.frame = CGRectMake(_rowLeft + _typeWidth + _nameWidth + _sliderWidth + _sliderWidth / 8, _currentRowY, _sliderWidth, _rowHeight);
            [self.view addSubview:efdata.pregainSlider];
        }
        //[efdata.wetDrySlider removeFromSuperview];
        _currentRowY += _rowHeight + _rowGap;
    }
/*    typeLabel.text = @"Reverb:";
    typeLabel.frame = CGRectMake(_rowLeft, _currentRowY, _typeWidth, _rowHeight);
    [self.view addSubview:typeLabel];
    UILabel *nameLabel = UILabel.new;
    nameLabel.text = @"Reverb:";
    nameLabel.frame = CGRectMake(_rowLeft + _typeWidth, _currentRowY, _nameWidth, _rowHeight);
    [self.view addSubview:typeLabel];
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
    removeButton.frame = CGRectMake(0.0, 0.0, 480.0, 60.0);
    removeButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    [removeButton setTitleColor:UserDefaults.defaults.appleBlue forState:UIControlStateNormal];
    [removeButton setTitleColor:UserDefaults.defaults.appleGray forState:UIControlStateHighlighted];
    [self.view addSubview:removeButton];
    
    [removeButton addTarget:self
                     action:@selector(removeEffectTapped:)
         forControlEvents:UIControlEventTouchUpInside];
   
*/ _currentRowY += _rowHeight + _rowGap;
}
@end
