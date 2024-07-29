//
//  EffectsData.h
//  GuitarPractice
//
//  Created by Jeff Smith on 7/14/24.
//  Copyright © 2024 GSSI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EffectType)
{
    REVERB,
    DISTORTION,
};

@interface EffectsData : NSObject
@property EffectType type;
@property int effectID;
@property (nullable) AVAudioUnitDistortion   *distortion;
@property (nullable) AVAudioUnitReverb       *reverb;
@property UISlider *wetDrySlider;
@property UISlider *pregainSlider;
@property UILabel *typeLabel;
@property UILabel *nameLabel;
@property int wetDryValue, pregainValue;

- (void) initEffect;
- (void) setTypeAndID:(EffectType)type
                   ID:(int) effectID;
- (void) deallocEffect;

@end

NS_ASSUME_NONNULL_END
