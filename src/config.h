#ifndef CONFIG_H
#define CONFIG_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// Function to dynamically determine the CONFIG_FILE path
static inline const char* get_config_file_path(void) {
    const char *home = getenv("HOME");
    const char *xdg_config_home = getenv("XDG_CONFIG_HOME");

    if (xdg_config_home && strlen(xdg_config_home) > 0) {
        static char config_path[512];
        snprintf(config_path, sizeof(config_path), "%s/wallpin/settings.ini", xdg_config_home);
        return config_path;
    } else if (home && strlen(home) > 0) {
        static char config_path[512];
        snprintf(config_path, sizeof(config_path), "%s/.config/wallpin/settings.ini", home);
        return config_path;
    } else {
        return "./settings.ini"; // Fallback in case HOME is not set
    }
}

// Configuration settings structure
typedef struct {
    int     refresh_rate;      // Image refresh rate in seconds
    int     animation_speed;   // Transition animation speed
    int     columns;          // Number of columns in the grid
    char*   assets_dir;    // Directory for images
} WallPinConfig;

// Function declarations
WallPinConfig *load_config(void);
void save_config(WallPinConfig *config);

#endif // CONFIG_H
