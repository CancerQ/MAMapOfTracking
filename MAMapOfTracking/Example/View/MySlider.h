//
//  MySlider.h
//  SportApp
//
//  Created by 叶志强 on 2017/4/25.
//  Copyright © 2017年 hwb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySlider : UISlider

@property (nonatomic, strong, readonly) UILabel *valueLabe;
@property (nonatomic, strong) NSString *playDuration;

- (MySlider *)touchWithValue:(void (^) (float value))handle;
    
@end
