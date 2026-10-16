#include <errno.h>
#include <gtk/gtk.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static bool write_all(int fd, const void *buffer, size_t size) {
    const char *cursor = buffer;

    while (size > 0) {
        ssize_t written = write(fd, cursor, size);
        if (written < 0 && errno == EINTR)
            continue;
        if (written <= 0)
            return false;

        cursor += written;
        size -= (size_t)written;
    }

    return true;
}

static void set_filters(const char *filters, GtkWidget *dialog) {
    if (filters == NULL || filters[0] == '\0')
        return;

    char *groups = strdup(filters);
    char *groupState = NULL;

    for (char *group = strtok_r(groups, "|", &groupState); group != NULL;
         group = strtok_r(NULL, "|", &groupState)) {
        char *separator = strchr(group, ';');
        if (separator == NULL)
            continue;

        *separator = '\0';
        GtkFileFilter *filter = gtk_file_filter_new();
        if (group[0] != '\0')
            gtk_file_filter_set_name(filter, group);

        char *extensionState = NULL;
        for (char *extension = strtok_r(separator + 1, ",", &extensionState);
             extension != NULL;
             extension = strtok_r(NULL, ",", &extensionState)) {
            if (extension[0] == '*') {
                gtk_file_filter_add_pattern(filter, extension);
            } else {
                char *pattern = g_strdup_printf("*.%s", extension);
                gtk_file_filter_add_pattern(filter, pattern);
                g_free(pattern);
            }
        }

        gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dialog), filter);
    }

    free(groups);
}

static void prepare_dialog(GtkWidget *dialog, const char *directory, const char *filters) {
    gtk_window_set_keep_above(GTK_WINDOW(dialog), TRUE);
    gtk_window_set_position(GTK_WINDOW(dialog), GTK_WIN_POS_CENTER);
    if (directory != NULL && directory[0] != '\0')
        gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(dialog), directory);
    set_filters(filters, dialog);
    gtk_window_present(GTK_WINDOW(dialog));
}

static char *open_panel(const char *title, const char *directory, const char *filters,
                        bool multiselect, GtkFileChooserAction action) {
    GtkWidget *dialog = gtk_file_chooser_dialog_new(
        title, NULL, action, "_Cancel", GTK_RESPONSE_CANCEL, "_Open", GTK_RESPONSE_ACCEPT, NULL);
    gtk_file_chooser_set_select_multiple(GTK_FILE_CHOOSER(dialog), multiselect);
    prepare_dialog(dialog, directory, filters);

    char *result = NULL;
    if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_ACCEPT) {
        if (multiselect) {
            GString *paths = g_string_new(NULL);
            GSList *filenames = gtk_file_chooser_get_filenames(GTK_FILE_CHOOSER(dialog));
            for (GSList *item = filenames; item != NULL; item = item->next) {
                if (paths->len > 0)
                    g_string_append_c(paths, 28);
                g_string_append(paths, item->data);
                g_free(item->data);
            }
            g_slist_free(filenames);
            result = g_string_free(paths, FALSE);
        } else {
            result = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
        }
    }

    gtk_widget_destroy(dialog);
    while (gtk_events_pending())
        gtk_main_iteration();

    return result != NULL ? result : strdup("");
}

static char *save_panel(const char *directory, const char *defaultName, const char *filters) {
    GtkWidget *dialog = gtk_file_chooser_dialog_new(
        "Save File", NULL, GTK_FILE_CHOOSER_ACTION_SAVE, "_Cancel", GTK_RESPONSE_CANCEL,
        "_Save", GTK_RESPONSE_ACCEPT, NULL);
    gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(dialog), TRUE);
    gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(dialog), defaultName);
    prepare_dialog(dialog, directory, filters);

    char *result = NULL;
    if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_ACCEPT)
        result = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));

    gtk_widget_destroy(dialog);
    while (gtk_events_pending())
        gtk_main_iteration();

    return result != NULL ? result : strdup("");
}

int main(int argc, char **argv) {
    char *result = NULL;

    if (argc >= 2 && gtk_init_check(NULL, NULL)) {
        if (strcmp(argv[1], "DialogOpenFolderPanel") == 0 && argc >= 5) {
            result = open_panel(argv[2], argv[3], "", argv[4][0] == '1',
                                GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER);
        } else if (strcmp(argv[1], "DialogOpenFilePanel") == 0 && argc >= 6) {
            result = open_panel(argv[2], argv[3], argv[4], argv[5][0] == '1',
                                GTK_FILE_CHOOSER_ACTION_OPEN);
        } else if (strcmp(argv[1], "DialogSaveFilePanel") == 0 && argc >= 6) {
            result = save_panel(argv[3], argv[4], argv[5]);
        }
    }

    if (result == NULL)
        result = strdup("");

    size_t size = strlen(result);
    bool succeeded = write_all(STDOUT_FILENO, &size, sizeof(size)) &&
                     write_all(STDOUT_FILENO, result, size);
    g_free(result);
    return succeeded ? 0 : 1;
}
