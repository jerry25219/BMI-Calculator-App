//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_dynamic_icon_plus/FlutterDynamicIconPlusPlugin.h>)
#import <flutter_dynamic_icon_plus/FlutterDynamicIconPlusPlugin.h>
#else
@import flutter_dynamic_icon_plus;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterDynamicIconPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterDynamicIconPlusPlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
}

@end
