//
//  EffectsViewController.h
//  GuitarPractice
//
//  Created by Jeff Smith on 6/29/24.
//  Copyright © 2024 GSSI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EffectsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *reverbSwitch1;
- (IBAction)reverbSwitchChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *reverbSwitch2;
@property (weak, nonatomic) IBOutlet UISwitch *reverbSwitch3;

@end

NS_ASSUME_NONNULL_END
