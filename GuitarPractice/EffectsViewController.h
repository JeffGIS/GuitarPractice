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
#import "AudioEngine.h"

NS_ASSUME_NONNULL_BEGIN
@class EffectsViewController;

typedef NS_ENUM(NSInteger, EffectsReturnStatus)
{
    DID_COMPLETE,
    DID_CANCEL,
    DID_CLEAR,
    DID_UPDATE
};


@protocol EffectsViewControllerDelegate <NSObject>

- (void)EffectsViewController:(EffectsViewController *)controller
                    didReturn:(EffectsReturnStatus)status;

@end

@interface EffectsViewController : UIViewController<NVPopoverTableViewDelegate>
@property (nonatomic, weak) id <EffectsViewControllerDelegate> delegate;
- (IBAction)addReverbTapped:(id)sender;
- (IBAction)addDistortionTapped:(id)sender;
- (IBAction)volumeChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addReverbButton;
@property (weak, nonatomic) IBOutlet UIButton *addDistortionButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
- (IBAction)clearButtonTapped:(id)sender;
- (IBAction)returnButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;
@property NSMutableArray *effectsArray;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property AudioEngine * audioEngine;
@end

NS_ASSUME_NONNULL_END
