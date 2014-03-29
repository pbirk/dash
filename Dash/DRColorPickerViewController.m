//
//  DRColorPickerViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/12/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRColorPickerViewController.h"

@interface DRColorPickerViewController () {
}
@property (strong, nonatomic) NSArray *colors;

@end

@implementation DRColorPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colors = @[[UIColor blackColor],
                    [UIColor whiteColor],
                    [UIColor redColor],
                    [UIColor greenColor],
                    [UIColor blueColor],
                    [UIColor cyanColor],
//                    [UIColor magentaColor],
                    [UIColor colorWithRed:0.700 green:0.000 blue:0.400 alpha:1.000],
                    ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OffCell" forIndexPath:indexPath];
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
        UIColor *color = self.colors[indexPath.row];
        cell.backgroundColor = cell.backgroundView.backgroundColor = color;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.bleService) {
        [self.bleService setEyeColor:self.colors[indexPath.row]];
    }
}

@end
