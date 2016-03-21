//
//  ICFoldCell.h
//
//  Created by itchyCat on 16/3/15.
//  Copyright © 2016年 itchyCat321. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ICFoldCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView * ic_imageView_up;
@property(nonatomic,strong)UIImageView * ic_imageView_down;
@property(nonatomic,strong)UILabel * ic_titleLabel;


//@property(nonatomic,weak)IBOutlet UILabel *ic_label;
-(void)configureForMenuItem:(NSDictionary *)menuItem atIndex:(NSUInteger )index;
@end
