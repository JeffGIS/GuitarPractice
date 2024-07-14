//
//  EffectsViewController.h
//  GuitarPractice
//
//  Created by Jeff Smith on 6/29/24.
//  Copyright © 2024 GSSI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectsData.h"
#import "CCodeLibrary/CCodeLibrary.h"

NS_ASSUME_NONNULL_BEGIN
@class EffectsViewController;

@protocol EffectsViewControllerDelegate <NSObject>

- (void)EffectsViewController:(EffectsViewController *)controller
                  didComplete:(BOOL)didCancel;

@end

@interface EffectsViewController : UIViewController<NVPopoverTableViewDelegate>
@property (nonatomic, weak) id <EffectsViewControllerDelegate> delegate;
- (IBAction)addReverbTapped:(id)sender;
- (IBAction)addDistortionTapped:(id)sender;
- (IBAction)volumeChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addReverbButton;
@property (weak, nonatomic) IBOutlet UIButton *addDistortionButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property NSMutableArray *effectsArray;
@end

NS_ASSUME_NONNULL_END
