//
//  OpenGLView.h
//  GLFun
//
//  Created by yolanda yuan on 7/3/2017.
//  Copyright © 2017 yolanda yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView

@property (nonatomic) CAEAGLLayer* eaglLayer;
@property (nonatomic) EAGLContext* context;
@property (nonatomic) GLuint colorRenderBuffer;
@property (nonatomic) GLuint frameBuffer;

- (void)setupLayer;

@end
