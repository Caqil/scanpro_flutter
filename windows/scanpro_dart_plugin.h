#ifndef FLUTTER_PLUGIN_SCANPRO_DART_PLUGIN_H_
#define FLUTTER_PLUGIN_SCANPRO_DART_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace scanpro_dart {

class ScanproDartPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ScanproDartPlugin();

  virtual ~ScanproDartPlugin();

  // Disallow copy and assign.
  ScanproDartPlugin(const ScanproDartPlugin&) = delete;
  ScanproDartPlugin& operator=(const ScanproDartPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace scanpro_dart

#endif  // FLUTTER_PLUGIN_SCANPRO_DART_PLUGIN_H_
