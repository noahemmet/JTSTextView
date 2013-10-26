JTSTextView
===========

A sane alternative to UITextView (since UITextView is broken beyond repair in iOS 7).

## UITextView is Broken on iOS 7

UITextView is utterly broken on iOS 7. The number and severity of the bugs are beyond the scope of this little README, but anyone who's dealt with UITextView yet will know what I mean. Here's the gist of what's wrong with UITextView on iOS 7:

- The internal calculations for contentSize are often wrong. Things like showing/hiding the keyboard or even just moving the cursor can cause the contentSize to change inexplicably, sometimes so much that scrolling is disabled improperly.

- The text view will not keep the text entry caret visible when breaking into new lines.

- Using attributed strings (whether via setAttributedText or via the new NSTextStorageDelegate protocol) causes even more math to be wrong. The CGRect returned from caretRectForPosition is wrong anywhere from one to 5 times (!) before returning the correct rect *after each keystroke*. This means that Greg Pierce's really clever UITextView gist simply can't work if you also need attributed strings.

## How Does JTSTextView Work?

JTSTextView is an otherwise vanilla UIScrollView, except it manages a private UITextView subview. This private text view is of a fixed height (10,000 points) and it has its scrolling disabled. By using a fixed height and disabling scrolling, this bypasses all the bad math that otherwise breaks UITextView.

To make JTSTextView useful, it has a bunch of public properties and methods that mimic the properties, methods, and delegate protocols of UITextView proper.

## Using JTSTextView

To use JTSTextView, you should pretty much be able to do a drop-in replacement for all your UITextView code. There are a few differences, but on the whole *it just works*.

## What About That 10,000 Points High Thing?

Glad you brought that up. The technique used by JTSTextView means that it is *not* able to support really long runs of text (like blog posts). But for things like email clients, Twitter clients, App.net clients, et cetera, 10,000 points is most like more than enough space. If you're brave, you should try editing that size to 100,000 or more. I have no idea what the performance effects would be, but lemme know.

## One More Thing

Oh yeah: JTSTextView also automatically manages changing its bottom content inset in response to keyboard visibility changes. Finally! If you don't want this, just set `automaticallyAdjustsContentInsetForKeyboard` to NO.
