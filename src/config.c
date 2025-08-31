#include "config.h"
#include <glib.h>
#include <stdio.h>

WallPinConfig *load_config(void) {
    WallPinConfig *config = g_new0(WallPinConfig, 1);
    GKeyFile *key_file = g_key_file_new();
    
    // Default values
    config->refresh_rate = 10;
    config->animation_speed = 500;
    config->columns = 4;
    // set default pictures dir, otherwise home 
    config->assets_dir = g_strdup_printf("%s/Pictures", getenv("HOME"));


    const char *config_file_path = get_config_file_path(); // Dynamic path determination

    if (g_key_file_load_from_file(key_file, config_file_path, G_KEY_FILE_NONE, NULL)) {
        // Try to read values from config file
        config->refresh_rate = g_key_file_get_integer(key_file, "Display", "refresh_rate", NULL);
        config->animation_speed = g_key_file_get_integer(key_file, "Display", "animation_speed", NULL);
        config->columns = g_key_file_get_integer(key_file, "Display", "columns", NULL);
        config->assets_dir = g_key_file_get_string(key_file, "Paths", "assets_dir", NULL);
    }

    g_key_file_free(key_file);
    return config;
}
