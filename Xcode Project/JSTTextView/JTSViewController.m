//
//  JTSViewController.m
//  JSTTextView
//
//  Created by Jared Sinclair on 10/26/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import "JTSViewController.h"

#import "JTSTextView.h"

@interface JTSViewController ()

@property (strong, nonatomic) JTSTextView *textView;

@end

@implementation JTSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JTSTextView *textView = [[JTSTextView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:textView];
    [self setTextView:textView];
    
    [self.textView setText:@"Me and my dad make models of clipper ships. Clipper ships sail on the ocean. Clipper ships never sail on rivers or lakes. I like clipper ships because they are fast. Clipper ships have lots of sails and are made of wood. "];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Toggle Keyboard" style:UIBarButtonItemStyleDone target:self action:@selector(toggle:)];
}

- (void)toggle:(id)sender {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    } else {
        [self.textView becomeFirstResponder];
    }
}

@end
