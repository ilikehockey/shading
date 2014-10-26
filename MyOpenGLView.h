#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

//#include "Vector.h"

#define min(a,b) (a>b?b:a)
#define max(a,b) (a>b?a:b)

#define PI 3.14159265

#include <math.h>

#define DOT(a,b) ((a.x*b.x)+(a.y*b.y)+(a.z*b.z))
#define LENGTH(a) (sqrtf(a.x*a.x+a.y*a.y+a.z*a.z))
#define NORMALIZE(a) {float l=1/LENGTH(a);a.x*=l;a.y*=l;a.z*=l;}

typedef struct vec3 {
    union {
        struct { float x, y, z; };
        struct { float r, g, b; };
    };
} vec3_t;

typedef struct vec4 {
    union {
        struct { float x, y, z, w; };
        struct { float r, g, b, a; };
    };
} vec4_t;

vec3_t add( vec3_t a, vec3_t b );
vec3_t sub( vec3_t a, vec3_t b );
vec3_t mul( vec3_t a, float s );
vec3_t cross( vec3_t a, vec3_t b );

typedef struct light {
	vec3_t pos;
	vec3_t color;
} light_t;

typedef enum { PHONG, TOON, SSS } shader_t;
typedef enum { SPHERE, PLANE, TORUS } shape_t;

@interface MyOpenGLView : NSOpenGLView
{
	float width, height;
	float fps;
	NSTimer *timer;
	
	int numDirLights;
	light_t dirLights[5];
	
	int numPointLights;
	light_t pointLights[5];
	
	vec3_t eye;
	
	vec3_t sphereAmbientColor;
	vec3_t sphereDiffuseColor;
	vec3_t sphereSpecularColor;
	
	float sphereSpecularity;
	
	shader_t shaderType;
	shape_t objectType;
}

- (void)setPixelAtX:(float)x
				  y:(float)y
			  withR:(GLfloat)r
				  g:(GLfloat)g
				  b:(GLfloat)b;

- (void)circleAtX:(float)x
				y:(float)y
	   withRadius:(float)r;

- (void)step;

- (void)setSphereAmbientColor:(NSColor *)color;
- (void)setSphereDiffuseColor:(NSColor *)color;
- (void)setSphereSpecularColor:(NSColor *)color;

- (float)sphereSpecularity;
- (void)updateSphereSpecularity:(float)specVal;

/* directional lights */
- (int)numDirLights;

- (void)addDirLightAtX:(float)x
					 y:(float)y
					 z:(float)z
				 withR:(float)r
					 g:(float)g
					 b:(float)b;

- (void)updateDirLightNum:(int)lightNum withX:(float)x;
- (void)updateDirLightNum:(int)lightNum withY:(float)y;
- (void)updateDirLightNum:(int)lightNum withZ:(float)z;
- (void)updateDirLightNum:(int)lightNum withR:(float)r;
- (void)updateDirLightNum:(int)lightNum withG:(float)g;
- (void)updateDirLightNum:(int)lightNum withB:(float)b;

- (vec3_t)posOfDirLightNum:(int)lightNum;
- (vec3_t)colorOfDirLightNum:(int)lightNum;

/* point lights */
- (int)numPointLights;

- (void)addPointLightAtX:(float)x
					   y:(float)y
					   z:(float)z
				   withR:(float)r
					   g:(float)g
					   b:(float)b;

- (void)updatePointLightNum:(int)lightNum withX:(float)x;
- (void)updatePointLightNum:(int)lightNum withY:(float)y;
- (void)updatePointLightNum:(int)lightNum withZ:(float)z;
- (void)updatePointLightNum:(int)lightNum withR:(float)r;
- (void)updatePointLightNum:(int)lightNum withG:(float)g;
- (void)updatePointLightNum:(int)lightNum withB:(float)b;

- (vec3_t)posOfPointLightNum:(int)lightNum;
- (vec3_t)colorOfPointLightNum:(int)lightNum;

- (void)setCurrentShaderTo:(shader_t)shdr;
- (void)setObjectType:(int)index;

- (void)dumpCommand;

@end