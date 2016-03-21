//
//  ICFoldFlowLayout.m
//
//  Created by itchyCat on 16/3/15.
//  Copyright © 2016年 itchyCat321. All rights reserved.
//

#import "ICFoldFlowLayout.h"
#import "ICFoldCell.h"

#define IC_CELL_SECOND  0.3
#define IC_CELL_THIRD   0.7
#define IC_CELL_HEIGHT  400
#define IC_RECT_RANGE   1300

#define IC_LABEL_FIRST     CGPointMake(20, 20)
#define IC_LABEL_X_SECOND  IC_CELL_WIDTH/2.0-foldCell.ic_titleLabel.frame.size.width/2.0
#define IC_LABEL_Y_SECOND  foldCell.frame.size.height/2.0-foldCell.ic_titleLabel.frame.size.height/2.0


#define IC_CELL_WIDTH   IC_UISCREEN_BOUNDS_WIDTH
#define IC_UISCREEN_BOUNDS_WIDTH   [UIScreen mainScreen].bounds.size.width
#define IC_UISCREEN_BOUNDS_HEIGHT  [UIScreen mainScreen].bounds.size.height


@interface ICFoldFlowLayout()

//item个数
@property(nonatomic)NSUInteger itemCount;
@property(nonatomic,strong)NSMutableAttributedString *attributes_str;


//每次屏幕上第二三个item的实时变化的高度
@property(nonatomic,assign)CGFloat height_secondItem;

@property(nonatomic,assign)CGFloat height_thirdItem;

@end

@implementation ICFoldFlowLayout
{
    //    记录第二三个item的初始变化高度
    CGFloat lastHeight_secondItem;
    CGFloat lastHeight_thirdItem;

}
//    通过模拟view给定 初始化应该有的高度
-(NSArray *)getHeight_ModelView
{
    UIView * modelView = [[UIView alloc]initWithFrame:CGRectMake(0, IC_CELL_WIDTH, IC_CELL_WIDTH, IC_CELL_HEIGHT/2.0)];
    
    modelView.layer.anchorPoint = CGPointMake(0.5, 0);
    
    CATransform3D rotation = CATransform3DIdentity;
    rotation.m34 = -1/500.0;
    CGFloat angle_second = -M_PI_2 * IC_CELL_SECOND;
    
    rotation = CATransform3DRotate(rotation,angle_second, 1, 0, 0);
    
    [modelView.layer setTransform:rotation];
    
    //    初始 第二个item的高度
    CGFloat height_second = modelView.frame.size.height * 2;
    
    lastHeight_secondItem = height_second;
    
    //    继续旋转相应的角度
    CGFloat angle_third = -M_PI_2 * (IC_CELL_THIRD-IC_CELL_SECOND);
    
    rotation = CATransform3DRotate(rotation,angle_third, 1, 0, 0);
    
    [modelView.layer setTransform:rotation];
    
    //    初始 第三个item的高度
    CGFloat height_third = modelView.frame.size.height * 2;
    
    lastHeight_thirdItem = height_third;
    
    return @[@(height_second),@(height_third)];

}
//    设置这些初值
-(void)getItemsHeight_original
{
    self.height_secondItem = [[[self getHeight_ModelView] objectAtIndex:0]floatValue];
    
    self.height_thirdItem = [[[self getHeight_ModelView] objectAtIndex:1] floatValue];

}


-(void)prepareLayout
{
    [super prepareLayout];
    self.itemSize = CGSizeMake(IC_CELL_WIDTH, IC_CELL_HEIGHT);
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
}

-(NSUInteger)itemCount
{
    if (!_itemCount) {
        
        _itemCount = [self.collectionView numberOfItemsInSection:0];
        //  只会被设置一次
        [self getItemsHeight_original];

    }
    return  _itemCount;
}
-(CGSize)collectionViewContentSize
{
//    设定应有的内容尺寸
    return  CGSizeMake(IC_UISCREEN_BOUNDS_WIDTH, IC_UISCREEN_BOUNDS_HEIGHT+(self.itemCount-1)*IC_CELL_HEIGHT);
    
}
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //    目前滚动的位置
    CGFloat scroll_y = self.collectionView.contentOffset.y;
    //    正在展开的item cellheight作为每轮的固定滚动距离
    CGFloat current_item = floorf(scroll_y/IC_CELL_HEIGHT) + 1;
    //    当前位置 相对固定滚动距离取余
    CGFloat  current_mod = fmodf(scroll_y, IC_CELL_HEIGHT);
    //    获取当前位置百分比
    CGFloat current_percent = ABS(current_mod/IC_CELL_HEIGHT);
    if    (scroll_y < 0) {
     //   考虑滚动负数的情况
          current_percent = 1 - current_percent;
    }
     //   获取相应的rect里的item
    CGRect correct_Rect;
    if (current_item == 0) {
        correct_Rect = CGRectMake(0, 0, IC_CELL_WIDTH, IC_RECT_RANGE);
    }
    else{
        correct_Rect = CGRectMake(0, (current_item-1)*IC_CELL_HEIGHT-100, IC_CELL_WIDTH,IC_RECT_RANGE);
    }
     NSArray * array = [super layoutAttributesForElementsInRect:correct_Rect];
     NSArray * array_copy = [[NSArray alloc] initWithArray:array copyItems:YES];
        for ( UICollectionViewLayoutAttributes *attributes in array_copy)
        {
            NSInteger row=attributes.indexPath.row;

            ICFoldCell * fix_foldCell;
            
            _attributes_str = [fix_foldCell.ic_titleLabel.attributedText mutableCopy];
          
            if ([[self.collectionView cellForItemAtIndexPath:attributes.indexPath]isKindOfClass:[ICFoldCell class]])
            {
            
                fix_foldCell = (ICFoldCell *)[self.collectionView cellForItemAtIndexPath:attributes.indexPath];
                _attributes_str = [[NSMutableAttributedString alloc]initWithAttributedString:fix_foldCell.ic_titleLabel.attributedText];

                
            }
            

            // 不会变的item
            if(row < current_item)
            {
                //    cell没有初始化的时候 让cell初始化后 对imageview布局 这里就忽略了
                if (fix_foldCell)
                {
                    
                    [self rotation_imageViewWithPercent:current_percent atCell:fix_foldCell atIndex:0];
                    
                }
                
                attributes.frame = CGRectMake(0, IC_CELL_HEIGHT*row, IC_CELL_WIDTH,IC_CELL_HEIGHT);
            
            }
            // 第一个展开的item
            else if (row == current_item)
            {
                if (fix_foldCell)
                {
                    self.height_secondItem = [self rotation_imageViewWithPercent:current_percent atCell:fix_foldCell atIndex:1];
                }
                
                attributes.frame = CGRectMake(0, IC_CELL_HEIGHT*row, IC_CELL_WIDTH,self.height_secondItem);
 
            }
            // 第二个展开的item
            else if (row == current_item + 1)
            {
                if (fix_foldCell)
                {
                    self.height_thirdItem = [self rotation_imageViewWithPercent:current_percent atCell:fix_foldCell atIndex:2];
                }
                
                attributes.frame = CGRectMake(0, IC_CELL_HEIGHT*row-(IC_CELL_HEIGHT-self.height_secondItem), IC_CELL_WIDTH,self.height_thirdItem);
                
            }
            
            else{}

        }
    
    return array_copy;
    
}

-(CGFloat)rotation_imageViewWithPercent:(CGFloat)percent atCell:(ICFoldCell *)foldCell atIndex:(NSInteger)index
{
    CGFloat angle_up;
    CGFloat angle_down;
    CGFloat angle_regular_f = IC_CELL_SECOND;
    CGFloat angle_regular_s = IC_CELL_THIRD-IC_CELL_SECOND;
    CGPoint original_label;
    CGFloat size_label;



    switch (index) {
        case 0:{
            angle_up = 0;
            angle_down = 0;
            
            size_label = 15;
            
            [_attributes_str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size_label] range:NSMakeRange(0, [_attributes_str length])];
            foldCell.ic_titleLabel.attributedText = _attributes_str;
           [foldCell.ic_titleLabel sizeToFit];

            
            original_label = IC_LABEL_FIRST;

            break;
               }
        case 1:{
            // 初始的状态是-90度 和 90度

            angle_up = -M_PI_2 * angle_regular_f * (1 - MIN(1, percent));
            angle_down = M_PI_2 * angle_regular_f * (1 - MIN(1, percent));
            
            size_label = 15 * (1 - MIN(1, percent)) + 15;
            
            [_attributes_str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size_label] range:NSMakeRange(0, [_attributes_str length])];
            foldCell.ic_titleLabel.attributedText = _attributes_str;
            [foldCell.ic_titleLabel sizeToFit];

            
            float movex_label = (IC_LABEL_X_SECOND - IC_LABEL_FIRST.x) * (1 - MIN(1, percent)) + IC_LABEL_FIRST.x;
            float movey_label = (IC_LABEL_Y_SECOND - IC_LABEL_FIRST.y) * (1 - MIN(1, percent)) + IC_LABEL_FIRST.y;
            
            original_label = CGPointMake(movex_label, movey_label);

            
            
            break;
               }
        case 2:{
            
            angle_up =  -M_PI_2 * angle_regular_f - M_PI_2 * (1 - MIN(1, percent)) * angle_regular_s;
            angle_down = M_PI_2 * angle_regular_f + M_PI_2 * (1 - MIN(1, percent)) * angle_regular_s;
            
            size_label = 30;
            
            [_attributes_str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size_label] range:NSMakeRange(0, [_attributes_str length])];
            foldCell.ic_titleLabel.attributedText = _attributes_str;
            [foldCell.ic_titleLabel sizeToFit];

            
            original_label = CGPointMake(IC_LABEL_X_SECOND, IC_LABEL_Y_SECOND);

            break;
               }
            
        default:
            break;
    }
    
    CATransform3D rotation_up = CATransform3DIdentity;
    rotation_up.m34 = -1/500.0;
    CATransform3D rotation_down = CATransform3DIdentity;
    rotation_down.m34 = -1/500.0;


    rotation_up = CATransform3DRotate(rotation_up, angle_up, 1, 0, 0);
    rotation_down = CATransform3DRotate(rotation_down, angle_down, 1, 0, 0);
    
    [foldCell.ic_imageView_up.layer setTransform:rotation_up];
    [foldCell.ic_imageView_down.layer setTransform:rotation_down];
    
    CGRect rect = foldCell.ic_titleLabel.frame;
    rect.origin = original_label;
    foldCell.ic_titleLabel.frame = rect;
    
    CGFloat current_Height = foldCell.ic_imageView_up.frame.size.height * 2;
    //    每次变换 记得downview的高度随着item高度变化而变化
    
    //     这里往上移1个元素 修复当不上移时 造成的 小黑条
    foldCell.ic_imageView_down.layer.position = CGPointMake(IC_CELL_WIDTH/2.0, current_Height-1);
    
    return foldCell.ic_imageView_up.frame.size.height * 2;

}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    //   简单的回到相应的目标位置 不做速率判断了
    CGFloat scroll_item = floorf((proposedContentOffset.y -IC_CELL_HEIGHT/2.0) / IC_CELL_HEIGHT) + 1;
    
    CGPoint fixProsedContextOffset = CGPointMake(proposedContentOffset.x, scroll_item * IC_CELL_HEIGHT);
   
 
    return fixProsedContextOffset;

}

@end
