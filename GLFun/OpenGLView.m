//
//  OpenGLView.m
//  GLFun
//
//  Created by yolanda yuan on 7/3/2017.
//  Copyright © 2017 yolanda yuan. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView

+ (Class)layerClass {
    // 只有 [CAEAGLLayer class] 类型的layer才支持在其上绘制openGL的内容
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self compileShaders];
    [self setupVBOs];
    [self render];
}

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1,-1,0},{1,0,0,1}},
    {{1,1,0},{0,1,0,1}},
    {{-1,1,0},{0,0,1,0}},
    {{-1,-1,0},{0,0,0}}
};

const GLubyte Indices[] = {
    0,1,2,
    2,3,0
};

- (void)setupVBOs {
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType{
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if(!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    //create a OpenGL object to represent the shader.
    //When you call this function you need to pass in a shaderType to indicate whether it’s a fragment or vertex shader.
    GLuint shaderHandle = glCreateShader(shaderType);
    
    //give OpenGL the source code for this shader.
    //convert the source code from an NSString to a C-string.
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    
    if(compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
}

- (void)compileShaders {
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}

- (void)setupLayer {
    self.eaglLayer = (CAEAGLLayer *) self.layer;
    self.eaglLayer.opaque = YES;
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    self.context = [[EAGLContext alloc] initWithAPI:api];
    if(!self.context) {
        NSLog(@"Failed to initialize OpenGL2.0 context.");
        exit(1);
    }
    if(![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"Failed to set current OpenGL context.");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)render {
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float)*3));
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
