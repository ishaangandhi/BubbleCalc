//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Ishaan Gandhi on 5/27/11.
//  Copyright 2011 Ishaan Gandhi Studios. All rights reserved.
//

#import "CalculatorViewController.h"


@implementation CalculatorViewController
@synthesize orientation, shouldPlaySound;

- (void)dealloc {
    [errorField release];
    [waitingOperation release];
    [backgroundImage release];
    [operationLabel release];
    [operationLabelLand release];
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.view = port;
    }
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.view = land;
    }
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.shouldPlaySound = [defaults boolForKey:@"play_sounds_preference"];
}

-(IBAction)AC {
    operand = 0;
    waitingOperand = 0;
    waitingOperation = nil;
    userIsInTheMiddleOfTypingANumber = NO;
    [operationLabel setText:@""];
    [operationLabelLand setText:@""];
    [screen setText:@"0"];
    [errorField setText:@""];
    [landScreen setText:@"0"];
    [landErrorField setText:@""];
}

-(IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [[sender titleLabel] text];
    [errorField setText:@""];
    [landErrorField setText:@""];
    if([[screen text] length] > 14 && userIsInTheMiddleOfTypingANumber) {
        [errorField setText:@"Maximum digits on screen"];
        [landErrorField setText:@"Maximum digits on screen"];
    }
    else {
        if (userIsInTheMiddleOfTypingANumber && [screen text] != @"0") {
            [screen setText:[[screen text] stringByAppendingString:digit]];
            [landScreen setText:[[landScreen text] stringByAppendingString:digit]];        
        }
        else {        
            if ([digit isEqualToString:@"00"])
                return;            
            [screen setText:digit];
            [landScreen setText:digit];
            userIsInTheMiddleOfTypingANumber = YES;
            
        }
    }
    if(self.shouldPlaySound) {
        NSLog(@"play sound");
    }else {
        NSLog(@"dont");
    }
    if(self.shouldPlaySound){
        //Get the filename of the sound file:
        NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/pop.wav"];
        
        //Get a URL for the sound file
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
        //Use audio sevices to create the sound
        AudioServicesCreateSystemSoundID((CFURLRef)filePath, &_popSound);
        //Use audio services to play the sound
        AudioServicesPlaySystemSound(_popSound); 
    }
}

-(IBAction)plusOrMinusPressed:(UIButton *)sender {
    NSString *firstDigit = [screen.text substringWithRange:NSMakeRange(0, 1)];
    if([firstDigit isEqualToString:@"-"]){
        [screen setText:[screen.text substringFromIndex:1]];
        [landScreen setText:[landScreen.text substringFromIndex:1]];
    }
    else {
        [screen setText:[@"-" stringByAppendingString:screen.text]];
        [landScreen setText:[@"-" stringByAppendingString:landScreen.text]];
    }
    
    if(self.shouldPlaySound){
        //Get the filename of the sound file:
        NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/pop.wav"];
        
        //Get a URL for the sound file
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
        //Use audio sevices to create the sound
        AudioServicesCreateSystemSoundID((CFURLRef)filePath, &_popSound);
        //Use audio services to play the sound
        AudioServicesPlaySystemSound(_popSound); 
    }
}

-(IBAction)operationPressed:(UIButton *)sender {
    [errorField setText:@""];
    [landErrorField setText:@""];
    if (userIsInTheMiddleOfTypingANumber) {
        operand = [[screen text] doubleValue];
        userIsInTheMiddleOfTypingANumber = NO;
    }
    
    NSString *operation = [[sender titleLabel] text];
    [operationLabel setText:operation];
    [operationLabelLand setText:operation];
    
    if([operation isEqual:@"√"]) {
        operand = sqrt(operand);
    }
    if([waitingOperation isEqual:@"^"]) {
        operand = pow(waitingOperand, operand);
    }
    if([waitingOperation isEqual:@"+"]) {
        operand = waitingOperand + operand;
    }
    if([waitingOperation isEqual:@"-"]) {
        operand = waitingOperand - operand;
    }
    if([waitingOperation isEqual:@"x"]) {
        operand = waitingOperand * operand;
    }
    if([waitingOperation isEqual:@"÷"]) {
        if (operand) {
            operand = waitingOperand / operand;
        } else {
            [errorField setText:@"Error: Cannot divide by 0"];
            [landErrorField setText:@"Error: Cannot divide by 0"];
        }
    }
    waitingOperation = operation;
    waitingOperand = operand;
    
    NSNumber* result = [NSNumber numberWithDouble:operand];
    
    NSNumberFormatter *fmtr = [[NSNumberFormatter alloc] init];
    [fmtr setNumberStyle:NSNumberFormatterDecimalStyle];
    [fmtr setMaximumFractionDigits:20];
    [fmtr setMaximumIntegerDigits:20];
    [fmtr setUsesGroupingSeparator:NO];
    
    [screen setText:[fmtr stringFromNumber:result]];
    [landScreen setText:[fmtr stringFromNumber:result]];
    [fmtr release];
    
    if(self.shouldPlaySound){
        //Get the filename of the sound file:
        NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/pop.wav"];
        
        //Get a URL for the sound file
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
        //Use audio sevices to create the sound
        AudioServicesCreateSystemSoundID((CFURLRef)filePath, &_popSound);
        //Use audio services to play the sound
        AudioServicesPlaySystemSound(_popSound); 
    }
}

-(IBAction)pointPressed {
    if(userIsInTheMiddleOfTypingANumber) {
        NSString *screenText = [screen text];
        BOOL points = NO;
        for (int i = 0; i < [screenText length]; i++) {
            if ([screenText characterAtIndex:i] == '.') {
                points = YES;
            }
        }
        if (points) {
            [errorField setText:@"Error: Decimal point already in operand"];
            [landErrorField setText:@"Error: Decimal point already in operand"];
        }
        else {
            [screen setText:[screenText stringByAppendingString:@"."]];
            [landScreen setText:[screenText stringByAppendingString:@"."]];
        }
    }
    else {
        [screen setText:@"0."];
        [landScreen setText:@"0."];
        userIsInTheMiddleOfTypingANumber = YES;
    }
}


- (void)viewDidUnload {
    [operationLabel release];
    operationLabel = nil;
    [operationLabelLand release];
    operationLabelLand = nil;
    [super viewDidUnload];
}
@end