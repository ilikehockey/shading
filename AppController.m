#import "AppController.h"

@implementation AppController

- (void)awakeFromNib {
	
	[dLight removeItemWithTitle:@"dlight"];
	[pLight removeItemWithTitle:@"plight"];
	
	NSProcessInfo *proc = [NSProcessInfo processInfo];
	NSArray *args = [proc arguments];
	
	[glView setSphereDiffuseColor:[NSColor redColor]];
	[glView setSphereSpecularColor:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
	
	int i;
	for( i = 1; i < [args count]; i++ ) {
		
		/* process directional lights */
		if( [[args objectAtIndex:i] isEqualToString:@"-dl"] ) {
			
			float x = [[args objectAtIndex:i+1] floatValue];
			float y = [[args objectAtIndex:i+2] floatValue];
			float z = [[args objectAtIndex:i+3] floatValue];
			float r = [[args objectAtIndex:i+4] floatValue];
			float g = [[args objectAtIndex:i+5] floatValue];
			float b = [[args objectAtIndex:i+6] floatValue];
			
			[dirLightSliderX setFloatValue:x];
			[dirLightSliderY setFloatValue:y];
			[dirLightSliderZ setFloatValue:z];
			[dirLightSliderR setFloatValue:r];
			[dirLightSliderG setFloatValue:g];
			[dirLightSliderB setFloatValue:b];
			
			[dLight setEnabled:TRUE];
			[dirLightSliderX setEnabled:TRUE];
			[dirLightSliderY setEnabled:TRUE];
			[dirLightSliderZ setEnabled:TRUE];
			[dirLightSliderR setEnabled:TRUE];
			[dirLightSliderG setEnabled:TRUE];
			[dirLightSliderB setEnabled:TRUE];
			
			//NSLog( @"adding directional light at (%f,%f,%f) with color (%f,%f,%f)",	x, y, z, r, g, b );
			[glView addDirLightAtX:x y:y z:z withR:r g:g b:b];
			[dLight addItemWithTitle:[NSString stringWithFormat:@"light%i", [glView numDirLights]]];
			
			i += 6; // don't add 7 since the for loop adds one more after looping through
		} 
		/* process point lights */
		else if( [[args objectAtIndex:i] isEqualToString:@"-pl"] ) {
			float width = [glView bounds].size.width;
			float height = [glView bounds].size.height;
			float fac = min(height,width)/4;
			
			float x = [[args objectAtIndex:i+1] floatValue]*fac;
			float y = [[args objectAtIndex:i+2] floatValue]*fac;
			float z = [[args objectAtIndex:i+3] floatValue]*fac;
			float r = [[args objectAtIndex:i+4] floatValue];
			float g = [[args objectAtIndex:i+5] floatValue];
			float b = [[args objectAtIndex:i+6] floatValue];
			
			[pointLightSliderX setFloatValue:x];
			[pointLightSliderY setFloatValue:y];
			[pointLightSliderZ setFloatValue:z];
			[pointLightSliderR setFloatValue:r];
			[pointLightSliderG setFloatValue:g];
			[pointLightSliderB setFloatValue:b];
			
			[pLight setEnabled:TRUE];
			[pointLightSliderX setEnabled:TRUE];
			[pointLightSliderY setEnabled:TRUE];
			[pointLightSliderZ setEnabled:TRUE];
			[pointLightSliderR setEnabled:TRUE];
			[pointLightSliderG setEnabled:TRUE];
			[pointLightSliderB setEnabled:TRUE];
			
			//NSLog( @"adding point light at (%f,%f,%f) with color (%f,%f,%f)",	x, y, z, r, g, b );
			[glView addPointLightAtX:x y:y z:z withR:r g:g b:b];
			
			[pLight addItemWithTitle:[NSString stringWithFormat:@"light%i", [glView numPointLights]]];
			
			i += 6; // don't add 7 since the for loop adds one more after looping through
		}
		else if( [[args objectAtIndex:i] isEqualToString:@"-sp"] ) {
			float specVal = [[args objectAtIndex:i+1] floatValue];
			[glView updateSphereSpecularity:specVal];
			[sphereSpecSlider setFloatValue:specVal];
			[sphereSpecSlider setEnabled:YES];
			i++;
		}
		else if( [[args objectAtIndex:i] isEqualToString:@"-ka"] ) {
			float r = [[args objectAtIndex:i+1] floatValue];
			float g = [[args objectAtIndex:i+2] floatValue];
			float b = [[args objectAtIndex:i+3] floatValue];
			NSColor *color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0f];
			[glView setSphereAmbientColor:color];
			[sphereAmbientColor setColor:color];
			i++;
		}
		else if( [[args objectAtIndex:i] isEqualToString:@"-kd"] ) {
			float r = [[args objectAtIndex:i+1] floatValue];
			float g = [[args objectAtIndex:i+2] floatValue];
			float b = [[args objectAtIndex:i+3] floatValue];
			NSColor *color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0f];
			[glView setSphereDiffuseColor:color];
			[sphereDiffuseColor setColor:color];
			i++;
		}
		else if( [[args objectAtIndex:i] isEqualToString:@"-ks"] ) {
			float r = [[args objectAtIndex:i+1] floatValue];
			float g = [[args objectAtIndex:i+2] floatValue];
			float b = [[args objectAtIndex:i+3] floatValue];
			NSColor *color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0f];
			[glView setSphereSpecularColor:color];
			[sphereSpecularColor setColor:color];
			i++;
		}
		else if( [[args objectAtIndex:i] isEqualToString:@"-shader"] ) {
			NSString *shader = [args objectAtIndex:i+1];
			if( [shader isEqualToString:@"phong"] ) {
				[shaderType selectItemAtIndex:0];
				[self updateShaderType:nil];
			}
			else if( [shader isEqualToString:@"toon"] ) {
				[shaderType selectItemAtIndex:1];
				[self updateShaderType:nil];
			}
			else if( [shader isEqualToString:@"sss"] ) {
				[shaderType selectItemAtIndex:2];
				[self updateShaderType:nil];
			}
			i++;
		}
	}
	//NSLog( @"numDirLights: %i", [glView numDirLights] );
	//NSLog( @"numPointLights: %i", [glView numPointLights] );
	
	[self updateDirLightSliders:nil];
	[self updatePointLightSliders:nil];
}

- (IBAction)updateSphereAmbientColor:(id)sender {
	[glView setSphereAmbientColor:[sphereAmbientColor color]];
}

- (IBAction)updateSphereDiffuseColor:(id)sender {
	[glView setSphereDiffuseColor:[sphereDiffuseColor color]];
}

- (IBAction)updateSphereSpecularColor:(id)sender {
	[glView setSphereSpecularColor:[sphereSpecularColor color]];
}

- (IBAction)updateSphereSpecularity:(id)sender {
	[glView updateSphereSpecularity:[sphereSpecSlider floatValue]];
}

/* process directional light controls */
- (IBAction)addDirLight:(id)sender {
	int numLights = [glView numDirLights];
	if( numLights < 5 ) {
		[dLight setEnabled:TRUE];
		[dirLightSliderX setFloatValue:0.0f];
		[dirLightSliderY setFloatValue:0.0f];
		[dirLightSliderZ setFloatValue:1.0f];
		[dirLightSliderR setFloatValue:1.0f];
		[dirLightSliderG setFloatValue:1.0f];
		[dirLightSliderB setFloatValue:1.0f];
		[dirLightSliderX setEnabled:TRUE];
		[dirLightSliderY setEnabled:TRUE];
		[dirLightSliderZ setEnabled:TRUE];
		[dirLightSliderR setEnabled:TRUE];
		[dirLightSliderG setEnabled:TRUE];
		[dirLightSliderB setEnabled:TRUE];
		[sphereSpecSlider setEnabled:YES];
		[glView addDirLightAtX:0.0f y:0.0f z:1.0f withR:1.0f g:1.0f b:1.0f];
		[dLight addItemWithTitle:[NSString stringWithFormat:@"light%i", [glView numDirLights]]];
		[dLight selectItemAtIndex:[glView numDirLights]-1];
	}
}

- (IBAction)updateDirLightSliders:(id)sender {
	
	vec3_t pos = [glView posOfDirLightNum:[dLight indexOfSelectedItem]];
	vec3_t color = [glView colorOfDirLightNum:[dLight indexOfSelectedItem]];
	
	[dirLightSliderX setFloatValue:pos.x];
	[dirLightSliderY setFloatValue:pos.y];
	[dirLightSliderZ setFloatValue:pos.z];
	[dirLightSliderR setFloatValue:color.r];
	[dirLightSliderG setFloatValue:color.g];
	[dirLightSliderB setFloatValue:color.b];
}

- (IBAction)updateDirLightX:(id)sender
{
	[glView updateDirLightNum:[dLight indexOfSelectedItem] withX:[dirLightSliderX floatValue]];
}

- (IBAction)updateDirLightY:(id)sender
{
	[glView updateDirLightNum:[dLight indexOfSelectedItem] withY:[dirLightSliderY floatValue]];
}

- (IBAction)updateDirLightZ:(id)sender
{
	[glView updateDirLightNum:[dLight indexOfSelectedItem] withZ:[dirLightSliderZ floatValue]];
}

- (IBAction)updateDirLightR:(id)sender
{	
	[glView updateDirLightNum:[dLight indexOfSelectedItem] withR:[dirLightSliderR floatValue]];
}

- (IBAction)updateDirLightG:(id)sender
{
	[glView updateDirLightNum:[dLight indexOfSelectedItem] withG:[dirLightSliderG floatValue]];
}

- (IBAction)updateDirLightB:(id)sender
{
	[glView updateDirLightNum:[dLight indexOfSelectedItem] withB:[dirLightSliderB floatValue]];
}

/* process point light controls */
- (IBAction)addPointLight:(id)sender {
	int numLights = [glView numPointLights];
	if( numLights < 5 ) {
		[pLight setEnabled:TRUE];
		[pointLightSliderX setFloatValue:0.0f];
		[pointLightSliderY setFloatValue:0.0f];
		[pointLightSliderZ setFloatValue:1000.0f];
		[pointLightSliderR setFloatValue:1.0f];
		[pointLightSliderG setFloatValue:1.0f];
		[pointLightSliderB setFloatValue:1.0f];
		[pointLightSliderX setEnabled:TRUE];
		[pointLightSliderY setEnabled:TRUE];
		[pointLightSliderZ setEnabled:TRUE];
		[pointLightSliderR setEnabled:TRUE];
		[pointLightSliderG setEnabled:TRUE];
		[pointLightSliderB setEnabled:TRUE];
		[sphereSpecSlider setEnabled:YES];
		[glView addPointLightAtX:0.0f y:0.0f z:1000.0f withR:1.0f g:1.0f b:1.0f];
		[pLight addItemWithTitle:[NSString stringWithFormat:@"light%i", [glView numPointLights]]];
		[pLight selectItemAtIndex:[glView numPointLights]-1];
	}
}

- (IBAction)updatePointLightSliders:(id)sender {
	
	vec3_t pos = [glView posOfPointLightNum:[pLight indexOfSelectedItem]];
	vec3_t color = [glView colorOfPointLightNum:[pLight indexOfSelectedItem]];
	
	[pointLightSliderX setFloatValue:pos.x];
	[pointLightSliderY setFloatValue:pos.y];
	[pointLightSliderZ setFloatValue:pos.z];
	[pointLightSliderR setFloatValue:color.r];
	[pointLightSliderG setFloatValue:color.g];
	[pointLightSliderB setFloatValue:color.b];
}

- (IBAction)updatePointLightX:(id)sender
{
	[glView updatePointLightNum:[pLight indexOfSelectedItem] withX:[pointLightSliderX floatValue]];
}

- (IBAction)updatePointLightY:(id)sender
{
	[glView updatePointLightNum:[pLight indexOfSelectedItem] withY:[pointLightSliderY floatValue]];
}

- (IBAction)updatePointLightZ:(id)sender
{
	[glView updatePointLightNum:[pLight indexOfSelectedItem] withZ:[pointLightSliderZ floatValue]];
}

- (IBAction)updatePointLightR:(id)sender
{	
	[glView updatePointLightNum:[pLight indexOfSelectedItem] withR:[pointLightSliderR floatValue]];
}

- (IBAction)updatePointLightG:(id)sender
{
	[glView updatePointLightNum:[pLight indexOfSelectedItem] withG:[pointLightSliderG floatValue]];
}

- (IBAction)updatePointLightB:(id)sender
{
	[glView updatePointLightNum:[pLight indexOfSelectedItem] withB:[pointLightSliderB floatValue]];
}

- (IBAction)updateShaderType:(id)sender {
	switch( [shaderType indexOfSelectedItem] ) {
		case 0: // phong
			[glView setCurrentShaderTo:PHONG];
			break;
		case 1: // toon
			[glView setCurrentShaderTo:TOON];
			break;
		case 2:
			[glView setCurrentShaderTo:SSS];
		default:
			break;
	};
}

- (IBAction)updateObjectType:(id)sender {
	[glView setObjectType:[objectType indexOfSelectedItem]];
}

- (IBAction)dumpCommand:(id)sender {
	[glView dumpCommand];
}

@end
