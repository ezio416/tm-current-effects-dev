/*
c 2023-05-04
m 2023-10-22
*/

int offsetSkip = 4;
string title = Icons::Bug + " Current Effects (dev)";

[Setting hidden]
bool windowOpen = false;

void RenderMenu() {
    if (UI::MenuItem(title))
        windowOpen = !windowOpen;
}

void Render() {
    if (!windowOpen) return;

#if TMNEXT
    Render2020();
#elif MP4
    RenderMP4();
#endif
}