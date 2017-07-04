//
//  PerKilometerLabel.m
//  SportApp
//
//  Created by 叶志强 on 2017/4/20.
//  Copyright © 2017年 hwb. All rights reserved.
//

#import "PerKilometerLabel.h"

@interface PerKilometerLabel ()
@property (nonatomic, strong) UILabel *labe;
@end

@implementation PerKilometerLabel

- (void)setLabelText:(NSString *)labelText{
    
    self.labe.text = labelText;
    _labelText = labelText;
}

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, 12 , 15);
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        imageView.image = [UIImage imageNamed:@"icon_qs"];
        
        self.labe = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 12, 9)];
        
        self.labe.font = FONT(9);
        
        [self addSubview:imageView];
        
        [self addSubview:self.labe];
        
        self.labe.textAlignment =NSTextAlignmentCenter;
    }
    
    return self;
}
@end
