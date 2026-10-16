#define _GNU_SOURCE

#include "library.h"

#include <errno.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/wait.h>
#include <unistd.h>

extern char _binary_dialog_start[];
extern char _binary_dialog_end[];

static char *dialogExecutablePath;

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

static bool read_all(int fd, void *buffer, size_t size) {
    char *cursor = buffer;

    while (size > 0) {
        ssize_t count = read(fd, cursor, size);
        if (count < 0 && errno == EINTR)
            continue;
        if (count <= 0)
            return false;

        cursor += count;
        size -= (size_t)count;
    }

    return true;
}

static char *empty_result(void) {
    return strdup("");
}

void DialogInit(void) {
    int fd = syscall(__NR_memfd_create, "mate-engine-file-dialog", MFD_CLOEXEC);
    if (fd < 0)
        return;

    size_t size = (size_t)(_binary_dialog_end - _binary_dialog_start);
    if (!write_all(fd, _binary_dialog_start, size)) {
        close(fd);
        return;
    }

    if (asprintf(&dialogExecutablePath, "/proc/self/fd/%d", fd) < 0) {
        dialogExecutablePath = NULL;
        close(fd);
    }
}

static const char *runSubprocess(const char **args) {
    if (dialogExecutablePath == NULL)
        return empty_result();

    args[0] = "mate-engine-file-dialog";

    int pipeFd[2];
    if (pipe(pipeFd) < 0)
        return empty_result();

    pid_t pid = fork();
    if (pid < 0) {
        close(pipeFd[0]);
        close(pipeFd[1]);
        return empty_result();
    }

    if (pid == 0) {
        close(pipeFd[0]);
        if (dup2(pipeFd[1], STDOUT_FILENO) < 0)
            _exit(126);
        close(pipeFd[1]);
        execv(dialogExecutablePath, (char *const *)args);
        perror("Mate Engine file dialog");
        _exit(127);
    }

    close(pipeFd[1]);

    size_t size = 0;
    char *result = NULL;
    bool readSucceeded = read_all(pipeFd[0], &size, sizeof(size));
    if (readSucceeded && size <= SIZE_MAX - 1) {
        result = malloc(size + 1);
        if (result != NULL) {
            readSucceeded = read_all(pipeFd[0], result, size);
            result[size] = '\0';
        }
    }

    close(pipeFd[0]);

    int status = 0;
    if (waitpid(pid, &status, 0) < 0 || !WIFEXITED(status) || WEXITSTATUS(status) != 0)
        readSucceeded = false;

    if (!readSucceeded || result == NULL) {
        free(result);
        return empty_result();
    }

    return result;
}

const char *DialogOpenFilePanel(const char *title, const char *directory, const char *extension,
                                bool multiselect) {
    const char *args[] = {NULL, "DialogOpenFilePanel", title, directory, extension,
                          multiselect ? "1" : "0", NULL};
    return runSubprocess(args);
}

const char *DialogOpenFolderPanel(const char *title, const char *directory, bool multiselect) {
    const char *args[] = {NULL, "DialogOpenFolderPanel", title, directory,
                          multiselect ? "1" : "0", NULL};
    return runSubprocess(args);
}

const char *DialogSaveFilePanel(const char *title, const char *directory, const char *defaultName,
                                const char *filters) {
    const char *args[] = {NULL, "DialogSaveFilePanel", title, directory, defaultName, filters, NULL};
    return runSubprocess(args);
}

void DialogOpenFilePanelAsync(const char *title, const char *directory, const char *extension,
                              bool multiselect, callbackFunc callback) {
    callback(DialogOpenFilePanel(title, directory, extension, multiselect));
}

void DialogOpenFolderPanelAsync(const char *title, const char *directory, bool multiselect,
                                callbackFunc callback) {
    callback(DialogOpenFolderPanel(title, directory, multiselect));
}

void DialogSaveFilePanelAsync(const char *title, const char *directory, const char *defaultName,
                              const char *filters, callbackFunc callback) {
    callback(DialogSaveFilePanel(title, directory, defaultName, filters));
}
