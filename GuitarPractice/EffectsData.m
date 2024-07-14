//
//  EffectsData.m
//  GuitarPractice
//
//  Created by Jeff Smith on 7/14/24.
//  Copyright © 2024 GSSI. All rights reserved.
//

#import "EffectsData.h"

@implementation EffectsData
@synthesize type;
@synthesize effectID;
@synthesize distortion;
@synthesize reverb;
@synthesize wetDrySlider;
@synthesize pregainSlider;
- (id)init
{
    self = [super init];
    self.distortion = [[AVAudioUnitDistortion alloc] init];
    [self.distortion loadFactoryPreset:AVAudioUnitDistortionPresetMultiBrokenSpeaker];
    self.reverb =  AVAudioUnitReverb.new;
    self.wetDrySlider = UISlider.new;
    self.wetDrySlider.minimumValue = 0;
    self.wetDrySlider.maximumValue = 100;
    self.wetDrySlider.value = 50;
    [self.wetDrySlider addTarget:self
                          action:@selector(wetDrySliderValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    self.pregainSlider = UISlider.new;
    self.pregainSlider.minimumValue = -80;
    self.pregainSlider.maximumValue = 20;
    self.pregainSlider.value = -6;
    self.typeLabel = UILabel.new;
    self.nameLabel = UILabel.new;
    [self.distortion setBypass:NO];
    [self.distortion setPreGain:0];
    [self.distortion setWetDryMix:0];
    return self;
}
- (void) wetDrySliderValueChanged:(id)sender
{
    if (self.type == REVERB)
        [self.reverb setWetDryMix:self.wetDrySlider.value];
    else
        [self.distortion setWetDryMix:self.wetDrySlider.value];

    return;
}
- (void) pregainSliderValueChanged:(id)sender
{
    if (self.type == DISTORTION)
        [self.distortion setPreGain:self.pregainSlider.value];

    return;
}
@end

