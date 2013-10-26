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



// PROXIED TEXT STORAGE DELEGATE ===============================================================================================

@protocol JTSTextViewTextStorageDelegate <NSObject>
@optional

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta NS_AVAILABLE_IOS(7_0);

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta NS_AVAILABLE_IOS(7_0);

@end



// JTSTextView INTERFACE PROPER ===============================================================================================

@interface JTSTextView : UIScrollView

@property (weak, nonatomic) id <JTSTextViewDelegate> textViewDelegate;
@property (weak, nonatomic) id <JTSTextViewTextStorageDelegate> textStorageDelegate;
@property (copy, nonatomic) NSAttributedString *attributedText;
@property (copy, nonatomic) NSString *text;

// @property (assign, nonatomic) BOOL automaticallyAdjustsContentInsetForKeyboard;
// Defaults to YES
@property (assign, nonatomic) BOOL automaticallyAdjustsContentInsetForKeyboard;

@end
