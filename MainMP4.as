/*
c 2023-10-22
m 2023-10-22
*/

#if MP4

int visStart = 0;
int visEnd = 10000;

void RenderMP4() {
    UI::Begin(title, windowOpen, UI::WindowFlags::None);
    UI::BeginTabBar("tabs");
        if (UI::BeginTabItem("CSceneVehicleVisState offsets")) {
            try {
                CTrackMania@ app = cast<CTrackMania@>(GetApp());

                CGamePlayground@ playground = cast<CGamePlayground@>(app.CurrentPlayground);
                if (playground is null)
                    throw("null playground");

                CGameScene@ scene = cast<CGameScene@>(app.GameScene);
                if (scene is null)
                    throw("null scene");

                CMwNod@[] allVis = VehicleStateMP4::GetAllVis(scene);

                UI::BeginTabBar("vis-offset-tabs");
                    for (uint i = 0; i < allVis.Length; i++) {
                        CMwNod@ vis = allVis[i];

                        if (UI::BeginTabItem("vis_" + i)) {
                            visStart = UI::InputInt("vis offset start", visStart);
                            visEnd = UI::InputInt("vis offset end", visEnd);
                            if (visStart < 0) visStart = 0;
                            if (visStart >= visEnd) visEnd = visStart + 1;

                            if (UI::BeginTable(i + "-offset-table", 2, UI::TableFlags::ScrollY)) {
                                UI::TableSetupScrollFreeze(0, 1);
                                UI::TableSetupColumn("offset", UI::TableColumnFlags::WidthFixed, 80);
                                UI::TableSetupColumn("value");
                                UI::TableHeadersRow();

                                UI::ListClipper clipper((visEnd - visStart) / offsetSkip);
                                while (clipper.Step()) {
                                    for (int j = clipper.DisplayStart; j < clipper.DisplayEnd; j++) {
                                        int offset = visStart + (j * offsetSkip);

                                        UI::TableNextRow();
                                        UI::TableNextColumn();
                                        // if (missingVisOffsets.Find(offset) > -1 || offset > 1516 || (offset > 144 && offset < 620) || offset < 140)
                                        //     UI::Text(RED + offset);
                                        // else
                                            UI::Text(tostring(offset));

                                        UI::TableNextColumn();
                                        try {
                                            // UI::Text(Round(Dev::GetOffsetInt8(state, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetUint8(state, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetInt16(state, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetUint16(state, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetInt32(state, offset), 0));
                                            UI::Text(Round(Dev::GetOffsetUint32(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetInt64(state, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetUint64(state, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetFloat(state, offset)));
                                            // UI::Text(RoundVec3(Dev::GetOffsetVec3(state, offset)));
                                        } catch {
                                            UI::Text(RED + getExceptionInfo());
                                        }
                                    }
                                }
                                UI::EndTable();
                            }
                            UI::EndTabItem();
                        }
                    }
                UI::EndTabBar();
            } catch {
                UI::Text("oopsie: " + getExceptionInfo());
            }
            UI::EndTabItem();
        }
    UI::EndTabBar();
    UI::End();
}

#endif