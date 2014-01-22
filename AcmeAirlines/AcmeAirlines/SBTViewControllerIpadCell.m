/*
 * © Copyright IBM Corp. 2013
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

//  This is collection cell to be showed in the main view

#import "SBTViewControllerIpadCell.h"
#import "SBTAcmeConstant.h"

@implementation SBTViewControllerIpadCell

@synthesize imageView, titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *patternImage = [UIImage imageNamed:@"slideNavBG.png"];
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
        
        float width = self.contentView.frame.size.width;
        //float height = self.contentView.frame.size.height;
        float margin = 5;
        self.imageView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.imageView.frame = CGRectMake(margin, margin, width-2*margin, 200);
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, self.imageView.frame.origin.y + self.imageView.frame.size.height, width-2*margin, 40)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:TEXT_SIZE_IPAD];
        //self.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
