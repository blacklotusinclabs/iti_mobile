/*
     File: PaintingView.h
 Abstract: The class responsible for the finger painting. The class wraps the 
 CAEAGLLayer from CoreAnimation into a convenient UIView subclass. The view 
 content is basically an EAGL surface you render your OpenGL scene into.
  Version: 1.11
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CONSTANTS:

#define kBrushOpacity		(1.0 / 4.0)
#define kBrushPixelStep		3
#define kBrushScale			2
#define kLuminosity			0.75
#define kSaturation			1.0

// Structs...
typedef struct Color {
    float red;
    float green;
    float blue;
    float alpha;
} Color;

typedef struct Line {
    CGPoint start;
    CGPoint end;
    Color color;
} Line;

//CLASS INTERFACES:

@class PublicationViewController;

@interface PaintingView : UIView
{
@private
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
	
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
	
	GLuint	brushTexture;
	CGPoint	location;
	CGPoint	previousLocation;
	Boolean	firstTouch;
	Boolean needsErase;	
    BOOL active;
    
    IBOutlet UIView *overlayedView;
    IBOutlet PublicationViewController *publicationController;
    UISwipeGestureRecognizer *forwardRecognizer;
	UISwipeGestureRecognizer *backwardRecognizer;
	UITapGestureRecognizer *tapRecognizer;
    
    NSMutableArray *paths;
    IBOutlet UIView *penView;
    Color currentColor;
    
    IBOutlet UIButton *ltYellow; 
    IBOutlet UIButton *ltRed; 
    IBOutlet UIButton *ltBlue; 
    IBOutlet UIButton *ltGreen; 
    IBOutlet UIButton *yellow; 
    IBOutlet UIButton *red; 
    IBOutlet UIButton *blue; 
    IBOutlet UIButton *green; 
    IBOutlet UIButton *erase; 
    IBOutlet UIButton *stop; 
}

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;
@property(nonatomic, assign) BOOL active;
@property(nonatomic, readonly) NSMutableArray *paths;

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)opacity;
- (void)setBrushClearColor;

- (void)erase;
- (void)clear;
- (void)activate;
- (void)deactivate;
- (void) playback:(NSMutableArray*)recordedPaths;
- (void) replayPathsForCurrentPage;

- (IBAction) lightYellow: (id)sender;
- (IBAction) lightRed: (id)sender;
- (IBAction) lightBlue: (id)sender;
- (IBAction) lightGreen: (id)sender;
- (IBAction) yellow: (id)sender;
- (IBAction) red: (id)sender;
- (IBAction) green: (id)sender;
- (IBAction) blue: (id)sender;

- (void) selectColorButton: (id)button;
- (void) addRecognizers;
- (void) removeRecognizers;
@end
