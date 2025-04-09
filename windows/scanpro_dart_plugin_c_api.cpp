#include "include/scanpro_dart/scanpro_dart_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "scanpro_dart_plugin.h"

void ScanproDartPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  scanpro_dart::ScanproDartPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
