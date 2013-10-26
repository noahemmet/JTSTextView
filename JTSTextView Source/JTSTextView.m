//
//  JTSTextView.m
//  JSTTextView
//
//  Created by Jared Sinclair on 10/26/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import "JTSTextView.h"

@interface JTSTextView () <NSTextStorageDelegate, UITextViewDelegate>

@property (assign, nonatomic) CGRect currentKeyboardFrame;
@property (strong, nonatomic) UITextView *textView;
@property (assign, nonatomic) NSRange previousSelectedRange;
@property (assign, nonatomic) BOOL useLinearNextScrollAnimation;
@property (assign, nonatomic) BOOL ignoreNextTextSelectionAnimation;

@end

#define BOTTOM_PADDING 8.0f
#define SLOW_DURATION 0.4f
#define FAST_DURATION 0.2f

@implementation JTSTextView

- (void)dealloc {
    [self removeKeyboardNotifications];
}

- (id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    // Setup TextKit stack for the private text view.
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithString:@""];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.frame.size.width, 10000)];
    [layoutManager addTextContainer:container];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10000) textContainer:container];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.textView];
    self.textView.scrollEnabled = NO;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.showsVerticalScrollIndicator = NO;
    [self.textView.textStorage setDelegate:self];
    [self.textView setDelegate:self];
    
    NSDictionary *defaltAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    [self setAttributedText:[[NSAttributedString alloc] initWithString:@"Hello" attributes:defaltAttributes]];
    
    // Observes keyboard changes by default
    [self setAutomaticallyAdjustsContentInsetForKeyboard:YES];
    [self addKeyboardNotifications];
}

#pragma mark - These Are Why This Works

// The various method & delegate method implementations in this pragma marked section
// are why JTSTextView works. Edit these with extreme care.

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    // setContentOffset:animated: is called by UIScrollView inside its implementation
    // of scrollRectToVisible:animated:. The super implementation of
    // setContentOffset:animated: is jaggy when it's called multiple times in row.
    // Fuck that noise.
    // The following animation can be called multiple times in a row smoothly, with
    // one minor exception: we flip a dirty bit for "useLinearNextScrollAnimation"
    // for the scroll animation used when mimicking the long-press-and-drag-to-the-top-
    // or-bottom-edge-of-the-view with a selection caret animation.
    CGFloat duration;
    UIViewAnimationOptions options;
    if (self.useLinearNextScrollAnimation) {
        duration = (animated) ? SLOW_DURATION : 0;
        options = UIViewAnimationOptionCurveLinear
        | UIViewAnimationOptionBeginFromCurrentState
        | UIViewAnimationOptionOverrideInheritedDuration
        | UIViewAnimationOptionOverrideInheritedCurve;
    } else {
        duration = (animated) ? FAST_DURATION : 0;
        options = UIViewAnimationOptionCurveEaseInOut
        | UIViewAnimationOptionBeginFromCurrentState
        | UIViewAnimationOptionOverrideInheritedDuration
        | UIViewAnimationOptionOverrideInheritedCurve;
    }
    [self setUseLinearNextScrollAnimation:NO];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [super setContentOffset:contentOffset];
    } completion:nil];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // Update the content size in setFrame: (rather than layoutSubviews)
    // because self is a UIScrollView and we don't need to update the
    // content size every time the scroll view calls layoutSubviews,
    // which is often.
    
    // Set delay to YES to boot the scroll animation to the next runloop,
    // or else the scrollRectToVisible: call will be
    // cancelled out by the animation context in which setFrame: is
    // usually called.
    
    [self updateContentSize:YES delay:YES];
}

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    // Ignore the next animation that would otherwise be triggered by the cursor moving
    // to a new spot. We animate to chase after the cursor as you type via the updateContentSize:(BOOL)scrollToVisible
    // method. Most of the time, we want to also animate inside of textViewDidChangeSelection:, but only when
    // that change is a "true" text selection change, and not the implied change that occurs when a new character is
    // typed or deleted.
    [self setIgnoreNextTextSelectionAnimation:YES];
    
    if ([self.textStorageDelegate respondsToSelector:@selector(textStorage:willProcessEditing:range:changeInLength:)]) {
        [self.textStorageDelegate textStorage:textStorage willProcessEditing:editedMask range:editedRange changeInLength:delta];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateContentSize:YES delay:NO];
    if ([self.textViewDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.textViewDelegate textViewDidChange:self];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSRange selectedRange = textView.selectedRange;
    if (self.ignoreNextTextSelectionAnimation == YES) {
        [self setIgnoreNextTextSelectionAnimation:NO];
    } else {
        if (selectedRange.length == 0 || selectedRange.location < self.previousSelectedRange.location) {
            // Scroll to start caret
            CGRect caretRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.start];
            CGRect targetRect = CGRectInset(caretRect, -1.0f, -8.0f);
            [self setUseLinearNextScrollAnimation:YES];
            [self scrollRectToVisible:targetRect animated:YES];
        }
        else if (selectedRange.location > self.previousSelectedRange.location) {
            CGRect firstRect = [textView firstRectForRange:textView.selectedTextRange];
            CGFloat bottomVisiblePointY = self.contentOffset.y + self.frame.size.height - self.contentInset.top - self.contentInset.bottom;
            if (firstRect.origin.y > bottomVisiblePointY - firstRect.size.height*1.1) {
                // Scroll to start caret
                CGRect caretRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.start];
                CGRect targetRect = CGRectInset(caretRect, -1.0f, -8.0f);
                [self setUseLinearNextScrollAnimation:YES];
                [self scrollRectToVisible:targetRect animated:YES];
            }
        }
        else if (selectedRange.location == self.previousSelectedRange.location) {
            // Scroll to end caret
            CGRect caretRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
            CGRect targetRect = CGRectInset(caretRect, -1.0f, -8.0f);
            [self setUseLinearNextScrollAnimation:YES];
            [self scrollRectToVisible:targetRect animated:YES];
        }
    }
    [self setPreviousSelectedRange:selectedRange];
    if ([self.textViewDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.textViewDelegate textViewDidChangeSelection:self];
    }
}

#pragma mark - Text View Mimicry

- (BOOL)becomeFirstResponder {
    BOOL didBecome = [self.textView becomeFirstResponder];
    [self simpleScrollToCaret];
    return didBecome;
}

- (BOOL)isFirstResponder {
    return [self.textView isFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.textView resignFirstResponder];
}

- (NSString *)text {
    return self.textView.text;
}

- (void)setText:(NSString *)text {
    [self.textView setText:text];
}

- (NSAttributedString *)attributedText {
    return self.textView.attributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self.textView setAttributedText:attributedText];
}

#pragma mark - Text View Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldChange = YES;
    if ([self.textViewDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        shouldChange = [self.textViewDelegate textView:self shouldChangeTextInRange:range replacementText:text];
    }
    return shouldChange;
}

#pragma mark - Text Storage Delegate 

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    if ([self.textStorageDelegate respondsToSelector:@selector(textStorage:didProcessEditing:range:changeInLength:)]) {
        [self.textStorageDelegate textStorage:textStorage didProcessEditing:editedMask range:editedRange changeInLength:delta];
    }
}

#pragma mark - Keyboard Changes

- (void)simpleScrollToCaret {
    CGRect caretRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
    [self scrollRectToVisible:CGRectInset(caretRect, -1.0f, -8.0f) animated:YES];
}

- (void)addKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.automaticallyAdjustsContentInsetForKeyboard) {
        NSValue *frameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect targetKeyboardFrame = CGRectZero;
        [frameValue getValue:&targetKeyboardFrame];
        
        // Convert from window coordinates to my coordinates
        targetKeyboardFrame = [self.superview convertRect:targetKeyboardFrame fromView:nil];
        
        [self setCurrentKeyboardFrame:targetKeyboardFrame];
        [self updateBottomContentInset:targetKeyboardFrame];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.automaticallyAdjustsContentInsetForKeyboard) {
        [self setCurrentKeyboardFrame:CGRectZero];
        [self updateBottomContentInset:CGRectZero];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    if (self.automaticallyAdjustsContentInsetForKeyboard) {
        NSValue *frameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect targetKeyboardFrame = CGRectZero;
        [frameValue getValue:&targetKeyboardFrame];
        
        // Convert from window coordinates to my coordinates
        targetKeyboardFrame = [self.superview convertRect:targetKeyboardFrame fromView:nil];
        
        [self setCurrentKeyboardFrame:targetKeyboardFrame];
        [self updateBottomContentInset:targetKeyboardFrame];
    }
}

- (void)updateBottomContentInset:(CGRect)keyboardFrame {
    CGRect intersection = CGRectIntersection(self.frame, keyboardFrame);
    UIEdgeInsets insets = self.contentInset;
    insets.bottom = intersection.size.height;
    [self setContentInset:insets];
}

- (void)updateContentSize:(BOOL)scrollToVisible delay:(CGFloat)delay {
    CGRect boundingRect = [self.textView.layoutManager usedRectForTextContainer:self.textView.textContainer];
    [self setContentSize:CGSizeMake(self.frame.size.width, boundingRect.size.height + 16.0f)];
    if (scrollToVisible) {
        if (delay) {
            __weak JTSTextView *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setUseLinearNextScrollAnimation:NO];
                [weakSelf simpleScrollToCaret];
            });
        } else {
            [self setUseLinearNextScrollAnimation:NO];
            [self simpleScrollToCaret];
        }
    }
}

@end








