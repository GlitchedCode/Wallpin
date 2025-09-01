#include "config.h"
#include <glib.h>
#include <stdlib.h>
#include <stdio.h>

WallPinConfig *load_config(void) {
    WallPinConfig *config = g_new0(WallPinConfig, 1);
    GKeyFile *key_file = g_key_file_new();
    
    // Default values
    config->refresh_rate = 10;
    config->columns = 4;
    config->randomize = TRUE;
    // set default pictures dir, otherwise home 
    config->assets_dir = g_strdup_printf("%s/Pictures", getenv("HOME"));


    const char *config_file_path = get_config_file_path(); // Dynamic path determination

    if (g_key_file_load_from_file(key_file, config_file_path, G_KEY_FILE_NONE, NULL)) {
        // Try to read values from config file
        config->refresh_rate = g_key_file_get_integer(key_file, "Display", "refresh_rate", NULL);
        config->animation_speed = (double)g_key_file_get_integer(key_file, "Display", "animation_speed", NULL) / 1000.0;
        if (config->animation_speed == 0) config->animation_speed = 0.3; // default speed
        config->columns = g_key_file_get_integer(key_file, "Display", "columns", NULL);
        config->randomize = g_key_file_get_boolean(key_file, "Display", "randomize", NULL);
        config->assets_dir = g_key_file_get_string(key_file, "Paths", "assets_dir", NULL);
    }

    g_key_file_free(key_file);
    return config;
}
