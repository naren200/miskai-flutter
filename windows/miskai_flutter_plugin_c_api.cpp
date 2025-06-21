#include "include/miskai_flutter/miskai_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "miskai_flutter_plugin.h"

void MiskaiFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  miskai_flutter::MiskaiFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
