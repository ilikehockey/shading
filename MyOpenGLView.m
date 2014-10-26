#import "MyOpenGLView.h"

@implementation MyOpenGLView

vec3_t add( vec3_t a, vec3_t b ) {
    vec3_t r;
    r.x=a.x+b.x;
    r.y=a.y+b.y;
    r.z=a.z+b.z;
    return r;
}

vec3_t sub( vec3_t a, vec3_t b ) {
    vec3_t r;
    r.x=a.x-b.x;
    r.y=a.y-b.y;
    r.z=a.z-b.z;
    return r;
}

vec3_t mul( vec3_t a, float s ) {
    vec3_t r;
    r.x = a.x * s;
    r.y = a.y * s;
    r.z = a.z * s;
    return r;
}

vec3_t cross( vec3_t a, vec3_t b ) {
    vec3_t r;
    r.x=a.y*b.z-a.z*b.y;
    r.y=a.z*b.x-a.x*b.z;
    r.z=a.x*b.y-a.y*b.x;
    return r;
}

- (void)awakeFromNib
{	
	eye.x = 0.0f;
	eye.y = 0.0f;
	eye.z = 1.0f;

    fps = 120.0f;
    timer = [[NSTimer scheduledTimerWithTimeInterval: 1/fps
											  target:self
											selector:@selector(step)
											userInfo:nil
											 repeats:YES] retain];
	
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode: NSModalPanelRunLoopMode];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)keyDown:(NSEvent *)event {
	if( [[event characters] isEqualToString:[NSString stringWithFormat:@" "]] )
		[NSApp terminate:nil];
}

- (void)prepareOpenGL {
	width = [self bounds].size.width;
	height = [self bounds].size.height;
	
	glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
	glViewport( 0, 0, width, height );
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho( -width/2, width/2, -height/2, height/2, -1, 1 );
}

- (void)drawRect:(NSRect)bounds {
	glClear(GL_COLOR_BUFFER_BIT);
	
	[self circleAtX:0 y:0 withRadius:min(height,width)/4];
	
	[[self openGLContext] flushBuffer];
	glFlush();
}

- (void)reshape {
	width = [self bounds].size.width;
	height = [self bounds].size.height;

	glViewport( 0, 0, width, height );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrtho( -width/2, width/2, -height/2, height/2, -1, 1 );
}

// input: OpenGL coordinates
- (void)setPixelAtX:(float)x
				  y:(float)y
			  withR:(GLfloat)r
				  g:(GLfloat)g
				  b:(GLfloat)b {
	glBegin( GL_POINTS ); {
		glColor3f( r, g, b );
		glVertex2f( x, y );
	} glEnd();
}

- (void)circleAtX:(float)x
				y:(float)y
	   withRadius:(float)r {
	
	vec3_t norm;
	float dot;
	
	vec3_t light;
	vec3_t point;
	vec3_t pixelColor;
	vec3_t ref;
	
	int i, j, w, n;
	float z;
	int torusRadius = 50;

	glBegin( GL_POINTS ); {
		for( i = -r ; i <= r ; i ++ ) {
			if( objectType == SPHERE || objectType == TORUS )
				w = (int)(sqrtf(r*r-i*i)+0.5f);
			else if( objectType == PLANE )
				w = r;
			for( j = -w ; j <= w ; j ++ ) {
				if( objectType == SPHERE )
					z = sqrtf(r*r-(x+j)*(x+j)-(y+i)*(y+i));
				else if( objectType == PLANE )
					z = 0.0f;
				else if( objectType == TORUS ) {
					z = sqrtf( torusRadius*torusRadius - pow((r - sqrtf( (x+j)*(x+j) + (y+i)*(y+i) )),2) );
				}
					
				
				pixelColor.r = sphereAmbientColor.r;
				pixelColor.g = sphereAmbientColor.g;
				pixelColor.b = sphereAmbientColor.b;
				
				point.x = x+j;
				point.y = y+i;
				point.z = z;
				
				if( objectType == SPHERE ) {
					norm.x = point.x/r;
					norm.y = point.y/r;
					norm.z = point.z/r;
				}
				else if( objectType == TORUS ) {
					norm.x = point.x/r;
					norm.y = point.y/r;
					norm.z = point.z/r;
				}
				
				if( shaderType == SSS || objectType == PLANE ) {
					norm.x = 0;
					norm.y = 0;
					norm.z = 1;
				}
				
				/* process directional lights */
				for( n = 0 ; n < numDirLights ; n++ ) {
					light = dirLights[n].pos;
					
					/* diffuse */
					light = mul(light,-1);
					NORMALIZE(light);
					dot = DOT(light,norm);
					dot = max(dot,0);
					
					switch( shaderType ) {
						case PHONG:
						case SSS:
							pixelColor.r += dot*sphereDiffuseColor.r*dirLights[n].color.r;
							pixelColor.g += dot*sphereDiffuseColor.g*dirLights[n].color.g;
							pixelColor.b += dot*sphereDiffuseColor.b*dirLights[n].color.b;
							break;
						case TOON:
							if( dot > 0.98f ) {
								pixelColor.r += 0.98f*sphereDiffuseColor.r*dirLights[n].color.r;
								pixelColor.g += 0.98f*sphereDiffuseColor.g*dirLights[n].color.g;
								pixelColor.b += 0.98f*sphereDiffuseColor.b*dirLights[n].color.b;
							}
							else if( dot > 0.5f ) {
								pixelColor.r += 0.5f*sphereDiffuseColor.r*dirLights[n].color.r;
								pixelColor.g += 0.5f*sphereDiffuseColor.g*dirLights[n].color.g;
								pixelColor.b += 0.5f*sphereDiffuseColor.b*dirLights[n].color.b;
							}
							else if( dot > 0.25f ) {
								pixelColor.r += 0.25f*sphereDiffuseColor.r*dirLights[n].color.r;
								pixelColor.g += 0.25f*sphereDiffuseColor.g*dirLights[n].color.g;
								pixelColor.b += 0.25f*sphereDiffuseColor.b*dirLights[n].color.b;
							}
							else {
								pixelColor.r += 0.1f*sphereDiffuseColor.r*dirLights[n].color.r;
								pixelColor.g += 0.1f*sphereDiffuseColor.g*dirLights[n].color.g;
								pixelColor.b += 0.1f*sphereDiffuseColor.b*dirLights[n].color.b;
							}
							break;
						default:
							break;
					};

					
					/* specular */
					if( sphereSpecularity != 0 ){
						ref = mul(norm,dot);
						ref = mul(ref,2);
						ref = sub(ref,light);
						NORMALIZE(ref);
						dot = DOT(ref,eye);
						dot = max(dot,0);
						dot = pow(dot,sphereSpecularity);

						switch( shaderType ) {
							case PHONG:
							case SSS:
								pixelColor.r += dot*sphereSpecularColor.r;
								pixelColor.g += dot*sphereSpecularColor.g;
								pixelColor.b += dot*sphereSpecularColor.b;
								break;
							case TOON:
								if( dot > 0.98f ) {
									pixelColor.r += sphereSpecularColor.r;
									pixelColor.g += sphereSpecularColor.g;
									pixelColor.b += sphereSpecularColor.b;
								}
								break;
							default:
								break;
						};
					}
				}
				
				/* process point lights */
				for( n = 0 ; n < numPointLights ; n++ ) {
					light = pointLights[n].pos;
					light = sub(light,point);
					
					/* diffuse */
					NORMALIZE(light);
					dot = DOT(light,norm);
					dot = max(dot,0);
					
					switch( shaderType ) {
						case PHONG:
						case SSS:
							pixelColor.r += dot*sphereDiffuseColor.r*pointLights[n].color.r;
							pixelColor.g += dot*sphereDiffuseColor.g*pointLights[n].color.g;
							pixelColor.b += dot*sphereDiffuseColor.b*pointLights[n].color.b;
							break;
						case TOON:
							if( dot > 0.98f ) {
								pixelColor.r += 0.98f*sphereDiffuseColor.r*pointLights[n].color.r;
								pixelColor.g += 0.98f*sphereDiffuseColor.g*pointLights[n].color.g;
								pixelColor.b += 0.98f*sphereDiffuseColor.b*pointLights[n].color.b;
							}
							else if( dot > 0.5f ) {
								pixelColor.r += 0.5f*sphereDiffuseColor.r*pointLights[n].color.r;
								pixelColor.g += 0.5f*sphereDiffuseColor.g*pointLights[n].color.g;
								pixelColor.b += 0.5f*sphereDiffuseColor.b*pointLights[n].color.b;
							}
							else if( dot > 0.25f ) {
								pixelColor.r += 0.25f*sphereDiffuseColor.r*pointLights[n].color.r;
								pixelColor.g += 0.25f*sphereDiffuseColor.g*pointLights[n].color.g;
								pixelColor.b += 0.25f*sphereDiffuseColor.b*pointLights[n].color.b;
							}
							else {
								pixelColor.r += 0.1f*sphereDiffuseColor.r*pointLights[n].color.r;
								pixelColor.g += 0.1f*sphereDiffuseColor.g*pointLights[n].color.g;
								pixelColor.b += 0.1f*sphereDiffuseColor.b*pointLights[n].color.b;
							}
							break;
						default:
							break;
					};
					
					/* specular */
					if( sphereSpecularity != 0 ) {
						ref = mul(norm,dot);
						ref = mul(ref,2);
						ref = sub(ref,light);
						NORMALIZE(ref);
						dot = DOT(ref,eye);
						dot = max(dot,0);
						dot = pow(dot,sphereSpecularity);
						
						switch( shaderType ) {
							case PHONG:
							case SSS:
								pixelColor.r += dot*sphereSpecularColor.r;
								pixelColor.g += dot*sphereSpecularColor.g;
								pixelColor.b += dot*sphereSpecularColor.b;
								break;
							case TOON:
								if( dot > 0.98f ) {
									pixelColor.r += sphereSpecularColor.r;
									pixelColor.g += sphereSpecularColor.g;
									pixelColor.b += sphereSpecularColor.b;
								}
								break;
							default:
								break;
						};
					}
				}
				
				[self setPixelAtX:x+j 
								y:y+i 
							withR:pixelColor.r
								g:pixelColor.g
								b:pixelColor.b];
			}
		}
	} glEnd();
}

- (void)step {
	[self setNeedsDisplay:YES];
}

- (void)setSphereAmbientColor:(NSColor *)color {
	sphereAmbientColor.r = [color redComponent];
	sphereAmbientColor.g = [color greenComponent];
	sphereAmbientColor.b = [color blueComponent];
}

- (void)setSphereDiffuseColor:(NSColor *)color {
	sphereDiffuseColor.r = [color redComponent];
	sphereDiffuseColor.g = [color greenComponent];
	sphereDiffuseColor.b = [color blueComponent];
}

- (void)setSphereSpecularColor:(NSColor *)color {
	sphereSpecularColor.r = [color redComponent];
	sphereSpecularColor.g = [color greenComponent];
	sphereSpecularColor.b = [color blueComponent];
}

- (float)sphereSpecularity {
	return sphereSpecularity;
}
- (void)updateSphereSpecularity:(float)specVal {
	sphereSpecularity = specVal;
}

/* directional lights */
- (int)numDirLights {
	return numDirLights;
}

- (void)addDirLightAtX:(float)x
					 y:(float)y
					 z:(float)z
				 withR:(float)r
					 g:(float)g
					 b:(float)b {
	dirLights[ numDirLights ].pos.x = x;
	dirLights[ numDirLights ].pos.y = y;
	dirLights[ numDirLights ].pos.z = z;
	dirLights[ numDirLights ].color.r = r;
	dirLights[ numDirLights ].color.g = g;
	dirLights[ numDirLights ].color.b = b;
	numDirLights++;
}

- (void)updateDirLightNum:(int)lightNum withX:(float)x {
	dirLights[lightNum].pos.x = x;
}
- (void)updateDirLightNum:(int)lightNum withY:(float)y {
	dirLights[lightNum].pos.y = y;
}
- (void)updateDirLightNum:(int)lightNum withZ:(float)z {
	dirLights[lightNum].pos.z = z;
}
- (void)updateDirLightNum:(int)lightNum withR:(float)r {
	dirLights[lightNum].color.r = r;
}
- (void)updateDirLightNum:(int)lightNum withG:(float)g {
	dirLights[lightNum].color.g = g;
}
- (void)updateDirLightNum:(int)lightNum withB:(float)b {
	dirLights[lightNum].color.b = b;
}

- (vec3_t)posOfDirLightNum:(int)lightNum {
	return dirLights[lightNum].pos;
}

- (vec3_t)colorOfDirLightNum:(int)lightNum {
	return dirLights[lightNum].color;
}

/* point lights */
- (int)numPointLights {
	return numPointLights;
}

- (void)addPointLightAtX:(float)x
					   y:(float)y
					   z:(float)z
				   withR:(float)r
					   g:(float)g
					   b:(float)b {
	pointLights[ numPointLights ].pos.x = x;
	pointLights[ numPointLights ].pos.y = y;
	pointLights[ numPointLights ].pos.z = z;
	pointLights[ numPointLights ].color.r = r;
	pointLights[ numPointLights ].color.g = g;
	pointLights[ numPointLights ].color.b = b;
	numPointLights++;
}

- (void)updatePointLightNum:(int)lightNum withX:(float)x {
	pointLights[lightNum].pos.x = x;
}
- (void)updatePointLightNum:(int)lightNum withY:(float)y {
	pointLights[lightNum].pos.y = y;
}
- (void)updatePointLightNum:(int)lightNum withZ:(float)z {
	pointLights[lightNum].pos.z = z;
}
- (void)updatePointLightNum:(int)lightNum withR:(float)r {
	pointLights[lightNum].color.r = r;
}
- (void)updatePointLightNum:(int)lightNum withG:(float)g {
	pointLights[lightNum].color.g = g;
}
- (void)updatePointLightNum:(int)lightNum withB:(float)b {
	pointLights[lightNum].color.b = b;
}

- (vec3_t)posOfPointLightNum:(int)lightNum {
	return pointLights[lightNum].pos;
}

- (vec3_t)colorOfPointLightNum:(int)lightNum {
	return pointLights[lightNum].color;
}

- (void)setCurrentShaderTo:(shader_t)shdr {
	shaderType = shdr;
}

- (void)setObjectType:(int)index {
	switch( index ) {
		case SPHERE:
			objectType = SPHERE;
			break;
		case PLANE:
			objectType = PLANE;
			break;
		case TORUS:
			objectType = TORUS;
		default:
			break;
	};
}

- (void)dumpCommand {
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"./hw2 "];
	int n;
	
	[cmd appendFormat:@"-ka %1.1f %1.1f %1.1f ", sphereAmbientColor.r, sphereAmbientColor.g, sphereAmbientColor.b];
	[cmd appendFormat:@"-kd %1.1f %1.1f %1.1f ", sphereDiffuseColor.r, sphereDiffuseColor.g, sphereDiffuseColor.b];
	[cmd appendFormat:@"-ks %1.1f %1.1f %1.1f ", sphereSpecularColor.r, sphereSpecularColor.g, sphereSpecularColor.b];
	[cmd appendFormat:@"-sp %1.1f ", sphereSpecularity];
	
	for( n = 0 ; n < numDirLights ; n++ ) {
		[cmd appendFormat:@"-dl %1.1f %1.1f %1.1f %1.1f %1.1f %1.1f ", dirLights[n].pos.x,
													dirLights[n].pos.y,
													dirLights[n].pos.z,
													dirLights[n].color.r,
													dirLights[n].color.g,
													dirLights[n].color.b];
	}
	float fac = min(height,width)/4;
	for( n = 0 ; n < numPointLights ; n++ ) {
		[cmd appendFormat:@"-pl %1.1f %1.1f %1.1f %1.1f %1.1f %1.1f ", 
			pointLights[n].pos.x/fac,
			pointLights[n].pos.y/fac,
			pointLights[n].pos.z/fac,
			pointLights[n].color.r,
			pointLights[n].color.g,
			pointLights[n].color.b];
	}

	NSString *shader;
	switch( shaderType ) {
		case PHONG:
			shader = [NSString stringWithFormat:@"phong"];
			break;
		case TOON:
			shader = [NSString stringWithFormat:@"toon"];
			break;
		case SSS:
			shader = [NSString stringWithFormat:@"sss"];
			break;
		default:
			break;
	};
	[cmd appendFormat:@"-shader %@", shader];
	
	NSLog( @"%@", cmd );
}

@end