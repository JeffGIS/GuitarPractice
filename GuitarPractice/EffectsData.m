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
    return self;
}

- (void) setTypeAndID:(EffectType)type
                   ID:(int) effectID
{
    self.type = type;
    self.effectID = effectID;
    if (type == REVERB)
    {
        self.reverb = AVAudioUnitReverb.new;
        [self.reverb loadFactoryPreset:effectID];
    }
    else
    {
        self.distortion = AVAudioUnitDistortion.new;
        [self.distortion loadFactoryPreset:effectID];
    }

}
- (void)dealloc
{
    return;
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

- (void) initEffect
{
    if (self.type == REVERB)
        self.reverb =  AVAudioUnitReverb.new;
    else if (self.type == DISTORTION)
        self.distortion = AVAudioUnitDistortion.new;
}
- (void) deallocEffect
{
    if (self.type == REVERB)
        self.reverb = nil;
    else if (self.type == DISTORTION)
        self.distortion = nil;
}
@end

