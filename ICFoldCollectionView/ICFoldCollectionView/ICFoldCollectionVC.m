//
//  ICFoldCollectionVC.m
//
//  Created by itchyCat on 16/3/15.
//  Copyright © 2016年 itchyCat321. All rights reserved.
//

#import "ICFoldCollectionVC.h"
#import "ICFoldCell.h"
@interface ICFoldCollectionVC ()<UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)NSArray * menuItems;
@end

@implementation ICFoldCollectionVC

static NSString * const reuseIdentifier = @"foldCell";

-(NSArray *)menuItems
{
    
    if (!_menuItems) {
        
        NSString *ic_paths = [[NSBundle mainBundle]pathForResource:@"MenuItems" ofType:@"plist"];
        
        _menuItems = [NSArray arrayWithContentsOfFile:ic_paths];
        
    }
    return _menuItems;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(375, 400);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menuItems.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ICFoldCell *cell = (ICFoldCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    

    [cell configureForMenuItem:self.menuItems[indexPath.row] atIndex:indexPath.row];

    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//
    [self say_somethingAtItemIndex:indexPath.row];
}
-(void) say_somethingAtItemIndex:(NSInteger)index{
//   懒得写了
    NSLog(@"useMp3");
}


@end
