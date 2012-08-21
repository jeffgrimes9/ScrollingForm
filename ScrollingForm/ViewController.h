//
//  ViewController.h
//  ScrollingForm
//
//  Created by Jeff Grimes on 8/21/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
@private
    NSArray *options;
    NSTimer *timer;
    NSString *optionsFirstText;
    BOOL formIncomplete;
    int activeFieldHeight;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *submitButton;
@property (nonatomic, retain) UITextField *activeField;
@property (nonatomic, retain) IBOutlet UITextField *dateField;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UITextField *pickerField;
@property (nonatomic, retain) IBOutlet UITextField *numberField;

- (IBAction)submitButtonPressed;

@end