//
//  RecordSongViewController.m
//  GuitarPractice
//
//  Created by Jeff Smith on 2/22/25.
//  Copyright © 2025 GSSI. All rights reserved.
//

#import "RecordSongViewController.h"

@interface RecordSongViewController ()

@end

@implementation RecordSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)returnTapped:(id)sender {
    [_delegate RecordSongViewController:self didComplete:YES];

}
@end
