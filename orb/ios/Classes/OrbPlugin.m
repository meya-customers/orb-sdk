#import "OrbPlugin.h"
#if __has_include(<orb/orb-Swift.h>)
#import <orb/orb-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "orb-Swift.h"
#endif

@implementation OrbPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOrbPlugin registerWithRegistrar:registrar];
}
@end
