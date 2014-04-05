//
//  JTSTextView.h
//  JSTTextView
//
//  Created by Jared Sinclair on 10/26/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JTSTextView;



// PROXIED TEXT VIEW DELEGATE ===============================================================================================

@protocol JTSTextViewDelegate <NSObject>
@optional

- (BOOL)textViewShouldBeginEditing:(JTSTextView *)textView;
- (BOOL)textViewShouldEndEditing:(JTSTextView *)textView;

- (void)textViewDidBeginEditing:(JTSTextView *)textView;
- (void)textViewDidEndEditing:(JTSTextView *)textView;

- (BOOL)textView:(JTSTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(JTSTextView *)textView;

- (void)textViewDidChangeSelection:(JTSTextView *)textView;

- (BOOL)textView:(JTSTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);
- (BOOL)textView:(JTSTextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);

@end



// JTSTextView INTERFACE PROPER ===============================================================================================

@interface JTSTextView : UIScrollView

- (instancetype)initWithFrame:(CGRect)frame textStorage:(NSTextStorage *)textStorage;

@property (weak, nonatomic) id <JTSTextViewDelegate> textViewDelegate;
@property (copy, nonatomic) NSAttributedString *attributedText;
@property (copy, nonatomic) NSString *text;

@property (assign, nonatomic) BOOL automaticallyAdjustsContentInsetForKeyboard; // Defaults to YES

@property (strong, nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) NSTextAlignment textAlignment;    // default is NSLeftTextAlignment
@property (assign, nonatomic) NSRange selectedRange;
@property (assign, nonatomic, getter=isEditable) BOOL editable;
@property (assign, nonatomic, getter=isSelectable) BOOL selectable; // toggle selectability, which controls the ability of the user to select content and interact with URLs & attachments
@property (assign, nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (assign, nonatomic) BOOL allowsEditingTextAttributes; // defaults to NO
@property (copy, nonatomic) NSDictionary *typingAttributes; // automatically resets when the selection changes

@property (strong, nonatomic) UIView *jts_inputView;
@property (strong, nonatomic) UIView *jts_inputAccessoryView;

@property (assign, nonatomic) BOOL clearsOnInsertion;
@property (strong, nonatomic, readonly) NSTextContainer *textContainer;
@property (assign, nonatomic) UIEdgeInsets textContainerInset;
@property (strong, nonatomic, readonly) NSLayoutManager *layoutManager;
@property (strong, nonatomic, readonly) NSTextStorage *textStorage;
@property (copy, nonatomic) NSDictionary *linkTextAttributes;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic) UITextAutocorrectionType autocorrectionType;
@property (assign, nonatomic) UITextSpellCheckingType spellCheckingType;
@property (assign, nonatomic) UIKeyboardType keyboardType;
@property (assign, nonatomic) UIKeyboardAppearance keyboardAppearance;
@property (assign, nonatomic) UIReturnKeyType returnKeyType;
@property (assign, nonatomic) BOOL enablesReturnKeyAutomatically;
@property (assign, nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

- (void)scrollRangeToVisible:(NSRange)range;
- (void)insertText:(NSString *)text;

@end




