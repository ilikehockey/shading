#import <Cocoa/Cocoa.h>
#import "MyOpenGLView.h"

@interface AppController : NSObject
{
    IBOutlet MyOpenGLView *glView;
	
	IBOutlet NSColorWell *sphereAmbientColor;
	IBOutlet NSColorWell *sphereDiffuseColor;
	IBOutlet NSColorWell *sphereSpecularColor;
	
	IBOutlet NSSlider *sphereSpecSlider;
	
	IBOutlet NSButton *dirLightAdd;
	IBOutlet NSPopUpButton *dLight;
    IBOutlet NSSlider *dirLightSliderX;
    IBOutlet NSSlider *dirLightSliderY;
    IBOutlet NSSlider *dirLightSliderZ;
	IBOutlet NSSlider *dirLightSliderR;
    IBOutlet NSSlider *dirLightSliderG;
    IBOutlet NSSlider *dirLightSliderB;
	
	IBOutlet NSButton *pointLightAdd;
	IBOutlet NSPopUpButton *pLight;
    IBOutlet NSSlider *pointLightSliderX;
    IBOutlet NSSlider *pointLightSliderY;
    IBOutlet NSSlider *pointLightSliderZ;
	IBOutlet NSSlider *pointLightSliderR;
    IBOutlet NSSlider *pointLightSliderG;
    IBOutlet NSSlider *pointLightSliderB;
	
	IBOutlet NSPopUpButton *shaderType;
	IBOutlet NSPopUpButton *objectType;
}
- (IBAction)updateSphereAmbientColor:(id)sender;
- (IBAction)updateSphereDiffuseColor:(id)sender;
- (IBAction)updateSphereSpecularColor:(id)sender;

- (IBAction)updateSphereSpecularity:(id)sender;

- (IBAction)addDirLight:(id)sender;
- (IBAction)updateDirLightSliders:(id)sender;
- (IBAction)updateDirLightX:(id)sender;
- (IBAction)updateDirLightY:(id)sender;
- (IBAction)updateDirLightZ:(id)sender;
- (IBAction)updateDirLightR:(id)sender;
- (IBAction)updateDirLightG:(id)sender;
- (IBAction)updateDirLightB:(id)sender;

- (IBAction)addPointLight:(id)sender;
- (IBAction)updatePointLightSliders:(id)sender;
- (IBAction)updatePointLightX:(id)sender;
- (IBAction)updatePointLightY:(id)sender;
- (IBAction)updatePointLightZ:(id)sender;
- (IBAction)updatePointLightR:(id)sender;
- (IBAction)updatePointLightG:(id)sender;
- (IBAction)updatePointLightB:(id)sender;

- (IBAction)updateShaderType:(id)sender;
- (IBAction)updateObjectType:(id)sender;

- (IBAction)dumpCommand:(id)sender;
@end
