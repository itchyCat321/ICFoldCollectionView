//
//  ICFoldCell.m
//
//  Created by itchyCat on 16/3/15.
//  Copyright © 2016年 itchyCat321. All rights reserved.
//

#import "ICFoldCell.h"
#define IC_CELL_ANGLE_MAXDISTANCE 800.0
#define IC_CELL_HEIGHT  400
#define IC_CELL_WIDTH  self.frame.size.width
#define IC_CELL_SECOND 0.3
#define IC_CELL_THIRD 0.7
#define IC_LABEL_FIRST     CGPointMake(20, 20)
#define IC_LABEL_X_SECOND  IC_CELL_WIDTH/2.0-self.ic_titleLabel.frame.size.width/2.0
#define IC_LABEL_Y_SECOND  self.frame.size.height/2.0-self.ic_titleLabel.frame.size.height/2.0
@interface ICFoldCell ()

@property(nonatomic)BOOL alreadyInit_ImageView;
@property(nonatomic,strong)NSMutableAttributedString *attributes_str;
@end
@implementation ICFoldCell
-(void)init_ImageViewPostionAtIndex:(NSInteger)index
{

    CGFloat angle_up;
    CGFloat angle_down;
    CGFloat angle_regular_f = IC_CELL_SECOND;
    CGFloat angle_regular_s = IC_CELL_THIRD-IC_CELL_SECOND;
    CGPoint original_label;
    CGFloat size_label;
   
    


   //判断进来的index
    switch (index)
    {
            
        case 0:
        {
            angle_up = 0;
            angle_down = 0;
            size_label = 15;

            [_attributes_str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size_label] range:NSMakeRange(0, [_attributes_str length])];
            self.ic_titleLabel.attributedText = _attributes_str;
            [self.ic_titleLabel sizeToFit];

            original_label = IC_LABEL_FIRST;
            
            break;
  
        }
        case 1:
        {
            angle_up = -M_PI_2 * angle_regular_f;
            angle_down = M_PI_2 * angle_regular_f;
            size_label = 30;


            original_label = CGPointMake(IC_LABEL_X_SECOND, IC_LABEL_Y_SECOND);

            break;
        }
        case 2:
        {
            angle_up = -M_PI_2 * angle_regular_f - M_PI_2 * angle_regular_s;
            angle_down = M_PI_2 * angle_regular_f + M_PI_2 * angle_regular_s;
            size_label = 30;

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

    [self.ic_imageView_up.layer setTransform:rotation_up];
    [self.ic_imageView_down.layer setTransform:rotation_down];
    

    CGRect rect = self.ic_titleLabel.frame;
    rect.origin = original_label;
    self.ic_titleLabel.frame = rect;
    
    //    第二个item的imageview初始化变化后 关上方法
    self.alreadyInit_ImageView = (index == 2) ? true : false;

}
-(void)initSubViews
{
    
    if (!_ic_imageView_up)
    {

        _ic_imageView_up = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, IC_CELL_WIDTH, IC_CELL_HEIGHT/2.0)];

        _ic_imageView_up.contentMode = UIViewContentModeScaleAspectFill;
        _ic_imageView_up.layer.anchorPoint = CGPointMake(0.5, 0);
        _ic_imageView_up.layer.position = CGPointMake(IC_CELL_WIDTH/2.0, 0);
        _ic_imageView_up.layer.shouldRasterize = YES;
        _ic_imageView_up.clipsToBounds = YES;
        
        [self addSubview:_ic_imageView_up];

        _ic_imageView_down = [[UIImageView alloc]initWithFrame:CGRectMake(0,self.frame.size.height/2.0 , IC_CELL_WIDTH, IC_CELL_HEIGHT/2.0 )];
        
        _ic_imageView_down.contentMode = UIViewContentModeScaleAspectFill;
        _ic_imageView_down.layer.anchorPoint = CGPointMake(0.5, 1);
        _ic_imageView_down.layer.position = CGPointMake(IC_CELL_WIDTH/2.0, self.frame.size.height - 1);
        _ic_imageView_down.layer.shouldRasterize = YES;
        _ic_imageView_down.clipsToBounds = YES;
        
        [self addSubview:_ic_imageView_down];
        
        _ic_titleLabel = [[UILabel alloc]init];
        _ic_titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

        [self addSubview:_ic_titleLabel];
        
   }
}
-(void)configureForMenuItem:(NSDictionary *)menuItem atIndex:(NSUInteger )index
{
    
    _attributes_str = [[NSMutableAttributedString alloc]initWithString: menuItem[@"title"]];
    
    NSDictionary *attributes_dic = @{NSStrokeWidthAttributeName:@3,NSStrokeColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:30.0]};
    
    [_attributes_str setAttributes:attributes_dic range:NSMakeRange(0, [_attributes_str length])];
    
    
  
    //  初始化 子视图
    [self initSubViews];
    
    self.ic_titleLabel.attributedText = _attributes_str;
    //  自适应
    [self.ic_titleLabel sizeToFit];
    
    //  只改变初始化 显示 的cell 的imageview的 transfrom变换

    (!self.alreadyInit_ImageView && (index == 0 || index == 1 || index == 2)) ? [self init_ImageViewPostionAtIndex:index]:nil;
    // 异步加载这个图片
    self.ic_imageView_up.image = [[self load_ImageMenuItem:menuItem AtIndex:index]objectAtIndex:0 ];
    self.ic_imageView_down.image = [[self load_ImageMenuItem:menuItem AtIndex:index]objectAtIndex:1];
    



}

-(NSArray *)load_ImageMenuItem:(NSDictionary *)menuItem AtIndex:(NSUInteger )index
{

    static NSCache *cache = nil;

    if (!cache)
    {
        cache = [[NSCache alloc] init];
    }

    NSArray * images = [cache objectForKey:@(index)];
    //  获取的images 有占位符 就直接返回
    if (images)
    {
        return [images isKindOfClass:[NSNull class]] ? nil: images;
    }
    [cache setObject:[NSNull null] forKey:@(index)];

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        NSString *imagePath = menuItem[@"image"];

        UIImage *image_up = [UIImage imageNamed:imagePath];

        CGSize sz_up = CGSizeMake(image_up.size.width, image_up.size.height/2.0);

        UIGraphicsBeginImageContextWithOptions(sz_up, NO, 0);

        [image_up drawAtPoint:CGPointZero];

        image_up = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

        UIImage *image_down = [UIImage imageNamed:imagePath];

        CGSize sz_down=CGSizeMake(image_down.size.width, image_down.size.height/2.0);

        UIGraphicsBeginImageContextWithOptions(sz_down, NO, 0);
        //   将imagedown绘制开始在 上下文-height的位置
        [image_down drawAtPoint:CGPointMake(0,-sz_down.height)];

        image_down = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^{
            //   缓冲裁剪的两张上下的图片
            NSArray *images = @[image_up,image_down];

            [cache setObject:images forKey:@(index)];

            self.ic_imageView_up.image = image_up;
            self.ic_imageView_down.image = image_down;

        });
    });

    return nil;
}




@end
