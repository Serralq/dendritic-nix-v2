#ifndef STANDALONE_FILE_BROWSER_LIBRARY_H
#define STANDALONE_FILE_BROWSER_LIBRARY_H

#include <stdbool.h>

typedef void (*callbackFunc)(const char *);

void DialogInit(void);

const char *DialogOpenFilePanel(const char *, const char *, const char *, bool);
const char *DialogOpenFolderPanel(const char *, const char *, bool);
const char *DialogSaveFilePanel(const char *, const char *, const char *, const char *);

void DialogOpenFilePanelAsync(const char *, const char *, const char *, bool, callbackFunc);
void DialogOpenFolderPanelAsync(const char *, const char *, bool, callbackFunc);
void DialogSaveFilePanelAsync(const char *, const char *, const char *, const char *, callbackFunc);

#endif
