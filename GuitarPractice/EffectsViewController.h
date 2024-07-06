//
//  EffectsViewController.h
//  GuitarPractice
//
//  Created by Jeff Smith on 6/29/24.
//  Copyright © 2024 GSSI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCodeLibrary/CCodeLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface EffectsViewController : UIViewController<NVPopoverTableViewDelegate>
- (IBAction)addReverbTapped:(id)sender;
- (IBAction)addDistortionTapped:(id)sender;
- (IBAction)volumeChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@end

NS_ASSUME_NONNULL_END
