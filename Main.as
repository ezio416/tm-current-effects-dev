/*
c 2023-05-04
m 2023-11-21
*/

int offsetSkip = 4;
string title = Icons::Bug + " Current Effects (dev)";

[Setting hidden]
bool windowOpen = false;

[Setting name="Offset Data Type"]
DataType offsetDataType = DataType::Int8;

void RenderMenu() {
    if (UI::MenuItem(title))
        windowOpen = !windowOpen;
}

void RenderInterface() {
    if (!windowOpen) return;

#if TMNEXT
    Render2020();
#elif MP4
    RenderMP4();
#endif
}