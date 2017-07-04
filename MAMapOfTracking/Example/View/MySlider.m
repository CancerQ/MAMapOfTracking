//
//  MySlider.m
//  SportApp
//
//  Created by 叶志强 on 2017/4/25.
//  Copyright © 2017年 hwb. All rights reserved.
//

#import "MySlider.h"

@interface MySlider ()
@property (nonatomic, copy) void (^valueBlock)(float);
@property (nonatomic, strong, readwrite) UILabel *valueLabe;
@end
@implementation MySlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
    
}

- (void)commonInit{
    self.valueLabe = [UILabel new];
    self.valueLabe.textColor = [UIColor whiteColor];
    self.valueLabe.text = @"00:00:00";
    [self addSubview:self.valueLabe];
    
//    [self.valueLabe mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self);
//        make.top.equalTo(self.mas_bottom).offset(0);
//    }];
}

- (MySlider *)touchWithValue:(void (^)(float))handle{
    [self setValueBlock:^(float value) {
        handle(value);
    }];
    return self;
}

- (void)setValue:(float)value{
    NSString *playTime = [NSString stringWithFormat:@"%d", (int)([self.playDuration integerValue] * value)] ;
//    self.valueLabe.text = playTime.yz_switchSecondToTime;
    [super setValue:value];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect t = [self trackRectForBounds: [self bounds]];
    float v = [self minimumValue] + ([[touches anyObject] locationInView: self].x - t.origin.x - 4.0) * (([self maximumValue]-[self minimumValue]) / (t.size.width - 8.0));
    [self setValue: v];
    !self.valueBlock?:self.valueBlock(v);
    [super touchesBegan: touches withEvent: event];
}

@end
