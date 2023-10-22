/*
c 2023-10-22
m 2023-10-22
*/

#if MP4

int visStart = 0;
int visEnd = 10000;
int[] knownVisOffsets = {
    0000, 1216, 1220, 1228, 1248, 1252, 1256, 1260, 1264, 1268, 1272, 1276, 1280, 1284, 1288, 1292, 1296, 1320, 1324, 1336,
    1340, 1344, 1348, 1352, 1356, 1360, 1364, 1372,  // FL
    1376, 1380, 1384, 1388, 1392, 1396, 1400, 1408,  // FR
    1412, 1416, 1420, 1424, 1428, 1432, 1436, 1444,  // RR
    1448, 1452, 1456, 1460, 1464, 1468, 1472, 1480,  // RL
    1512, 1524, 1584, 2084, 2096, 2108
};

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

                            if (visStart < 0)
                                visStart = 0;
                            if (visStart >= visEnd)
                                visEnd = visStart + 1;

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
                                        UI::Text(((knownVisOffsets.Find(offset) < 0) ? RED : "") + offset);

                                        UI::TableNextColumn();
                                        try {
                                            // UI::Text(Round(Dev::GetOffsetInt8(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetUint8(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetInt16(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetUint16(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetInt32(vis, offset), 0));
                                            UI::Text(Round(Dev::GetOffsetUint32(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetInt64(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetUint64(vis, offset), 0));
                                            // UI::Text(Round(Dev::GetOffsetFloat(vis, offset)));
                                            // UI::Text(RoundVec3(Dev::GetOffsetVec3(vis, offset)));
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

        if (UI::BeginTabItem("vis values")) {
            try {
                CTrackMania@ app = cast<CTrackMania@>(GetApp());

                CGamePlayground@ playground = cast<CGamePlayground@>(app.CurrentPlayground);
                if (playground is null)
                    throw("null playground");

                CGameScene@ scene = cast<CGameScene@>(app.GameScene);
                if (scene is null)
                    throw("null scene");

                CMwNod@[] allVis = VehicleStateMP4::GetAllVis(scene);

                UI::BeginTabBar("vis-value-tabs");
                    for (uint i = 0; i < allVis.Length; i++) {
                        CMwNod@ vis = allVis[i];

                        if (UI::BeginTabItem("vis_" + i)) {
                            if (UI::BeginTable(i + "-value-table", 4, UI::TableFlags::ScrollY)) {
                                UI::TableSetupColumn("offset(s)", UI::TableColumnFlags::WidthFixed, 150);
                                UI::TableSetupColumn("type", UI::TableColumnFlags::WidthFixed, 80);
                                UI::TableSetupColumn("variable");
                                UI::TableSetupColumn("value");
                                UI::TableHeadersRow();

                                String4[] knownValues = GetKnownVisValues(vis);

                                for (uint j = 0; j < knownValues.Length; j++) {
                                    String4@ kv = @knownValues[j];
                                    UI::TableNextRow();
                                    UI::TableNextColumn();
                                    UI::Text(kv.offset);

                                    UI::TableNextColumn();
                                    UI::Text(kv.type);

                                    UI::TableNextColumn();
                                    UI::Text(kv.name);

                                    UI::TableNextColumn();
                                    UI::Text(kv.value);
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

String4[] GetKnownVisValues(CMwNod@ vis) {
    String4[] ret;

    if (vis is null)
        return ret;

    ret.InsertLast(String4(0000, "uint",  "EntityId",                 Round(Dev::GetOffsetUint32(vis, 0))));
    ret.InsertLast(String4(1216, "float", "InputSteer",               Round(Dev::GetOffsetFloat (vis, 1216))));
    ret.InsertLast(String4(1220, "float", "InputGasPedal",            Round(Dev::GetOffsetFloat (vis, 1220))));
    ret.InsertLast(String4(1228, "bool",  "InputIsBraking",           Round(Dev::GetOffsetUint32(vis, 1228) == 1)));
    ret.InsertLast(String4(1248, "iso4",  "Location",                 Round(Dev::GetOffsetIso4  (vis, 1248))));

    vec3 x = Dev::GetOffsetVec3(vis, 1248);
    vec3 y = Dev::GetOffsetVec3(vis, 1260);
    vec3 z = Dev::GetOffsetVec3(vis, 1272);
    vec3 LeftDirection;
    LeftDirection.x = x.x;
    LeftDirection.y = y.x;
    LeftDirection.z = z.x;
    ret.InsertLast(String4("1248,1260,1272", "vec3", "LeftDirection", Round(LeftDirection)));
    vec3 WorldCarUp;
    WorldCarUp.x = x.y;
    WorldCarUp.y = y.y;
    WorldCarUp.z = z.y;
    ret.InsertLast(String4("1252,1264,1276", "vec3", "WorldCarUp",    Round(WorldCarUp)));
    vec3 AimDirection;
    AimDirection.x = x.z;
    AimDirection.y = y.z;
    AimDirection.z = z.z;
    ret.InsertLast(String4("1256,1268,1280", "vec3", "AimDirection",  Round(AimDirection)));

    ret.InsertLast(String4(1284, "vec3",  "Position",                 Round(Dev::GetOffsetVec3  (vis, 1284))));
    ret.InsertLast(String4(1296, "vec3",  "WorldVel",                 Round(Dev::GetOffsetVec3  (vis, 1296))));
    ret.InsertLast(String4(1320, "float", "FrontSpeed",               Round(Dev::GetOffsetFloat (vis, 1320))));
    ret.InsertLast(String4(1324, "float", "SideSpeed",                Round(Dev::GetOffsetFloat (vis, 1324))));
    ret.InsertLast(String4(1336, "bool",  "IsGroundContact",          Round(Dev::GetOffsetUint32(vis, 1336) == 1)));

    ret.InsertLast(String4(1340, "float", "FLDamperLen",              Round(Dev::GetOffsetFloat (vis, 1340))));
    ret.InsertLast(String4(1344, "float", "FLWheelRot",               Round(Dev::GetOffsetFloat (vis, 1344))));
    ret.InsertLast(String4(1348, "float", "FLWheelRotSpeed",          Round(Dev::GetOffsetFloat (vis, 1348))));
    ret.InsertLast(String4(1352, "float", "FLSteerAngle",             Round(Dev::GetOffsetFloat (vis, 1352))));
    uint FLGroundContactMaterial = Dev::GetOffsetUint32(vis, 1356);
    ret.InsertLast(String4(1356, "uint",  "FLGroundContactMaterial",  Round(FLGroundContactMaterial) + " \\$G" + tostring(CAudioSourceSurface::ESurfId(FLGroundContactMaterial))));
    ret.InsertLast(String4(1360, "bool",  "FLGroundContact",          Round(Dev::GetOffsetFloat(vis, 1360) == 1)));
    ret.InsertLast(String4(1364, "float", "FLSlipCoef",               Round(Dev::GetOffsetFloat(vis, 1364))));
    ret.InsertLast(String4(1372, "bool",  "FLIsWet",                  Round(Dev::GetOffsetFloat(vis, 1372) == 1)));

    ret.InsertLast(String4(1376, "float", "FRDamperLen",              Round(Dev::GetOffsetFloat (vis, 1376))));
    ret.InsertLast(String4(1380, "float", "FRWheelRot",               Round(Dev::GetOffsetFloat (vis, 1380))));
    ret.InsertLast(String4(1384, "float", "FRWheelRotSpeed",          Round(Dev::GetOffsetFloat (vis, 1384))));
    ret.InsertLast(String4(1388, "float", "FRSteerAngle",             Round(Dev::GetOffsetFloat (vis, 1388))));
    uint FRGroundContactMaterial = Dev::GetOffsetUint32(vis, 1392);
    ret.InsertLast(String4(1392, "uint",  "FRGroundContactMaterial",  Round(FRGroundContactMaterial) + " \\$G" + tostring(CAudioSourceSurface::ESurfId(FRGroundContactMaterial))));
    ret.InsertLast(String4(1396, "bool",  "FRGroundContact",          Round(Dev::GetOffsetFloat(vis, 1396) == 1)));
    ret.InsertLast(String4(1400, "float", "FRSlipCoef",               Round(Dev::GetOffsetFloat(vis, 1400))));
    ret.InsertLast(String4(1408, "bool",  "FRIsWet",                  Round(Dev::GetOffsetFloat(vis, 1408) == 1)));

    ret.InsertLast(String4(1412, "float", "RRDamperLen",              Round(Dev::GetOffsetFloat (vis, 1412))));
    ret.InsertLast(String4(1416, "float", "RRWheelRot",               Round(Dev::GetOffsetFloat (vis, 1416))));
    ret.InsertLast(String4(1420, "float", "RRWheelRotSpeed",          Round(Dev::GetOffsetFloat (vis, 1420))));
    ret.InsertLast(String4(1424, "float", "RRSteerAngle",             Round(Dev::GetOffsetFloat (vis, 1424))));
    uint RRGroundContactMaterial = Dev::GetOffsetUint32(vis, 1428);
    ret.InsertLast(String4(1428, "uint",  "RRGroundContactMaterial",  Round(RRGroundContactMaterial) + " \\$G" + tostring(CAudioSourceSurface::ESurfId(RRGroundContactMaterial))));
    ret.InsertLast(String4(1432, "bool",  "RRGroundContact",          Round(Dev::GetOffsetFloat(vis, 1432) == 1)));
    ret.InsertLast(String4(1436, "float", "RRSlipCoef",               Round(Dev::GetOffsetFloat(vis, 1436))));
    ret.InsertLast(String4(1444, "bool",  "RRIsWet",                  Round(Dev::GetOffsetFloat(vis, 1444) == 1)));

    ret.InsertLast(String4(1448, "float", "RLDamperLen",              Round(Dev::GetOffsetFloat (vis, 1448))));
    ret.InsertLast(String4(1452, "float", "RLWheelRot",               Round(Dev::GetOffsetFloat (vis, 1452))));
    ret.InsertLast(String4(1456, "float", "RLWheelRotSpeed",          Round(Dev::GetOffsetFloat (vis, 1456))));
    ret.InsertLast(String4(1460, "float", "RLSteerAngle",             Round(Dev::GetOffsetFloat (vis, 1460))));
    uint RLGroundContactMaterial = Dev::GetOffsetUint32(vis, 1464);
    ret.InsertLast(String4(1464, "uint",  "RLGroundContactMaterial",  Round(RLGroundContactMaterial) + " \\$G" + tostring(CAudioSourceSurface::ESurfId(RLGroundContactMaterial))));
    ret.InsertLast(String4(1468, "bool",  "RLGroundContact",          Round(Dev::GetOffsetFloat(vis, 1468) == 1)));
    ret.InsertLast(String4(1472, "float", "RLSlipCoef",               Round(Dev::GetOffsetFloat(vis, 1472))));
    ret.InsertLast(String4(1480, "bool",  "RLIsWet",                  Round(Dev::GetOffsetFloat(vis, 1480) == 1)));

    ret.InsertLast(String4(1512, "float", "RPM",                      Round(Dev::GetOffsetFloat (vis, 1512), 0)));
    ret.InsertLast(String4(1524, "uint",  "CurGear",                  Round(Dev::GetOffsetUint32(vis, 1524))));
    ret.InsertLast(String4(1584, "uint",  "ActiveEffects",            Round(Dev::GetOffsetUint32(vis, 1584))));
    ret.InsertLast(String4(2084, "bool",  "TurboActive",              Round(Dev::GetOffsetFloat (vis, 2084) == 1)));
    ret.InsertLast(String4(2096, "float", "TurboPercent",             Round(Dev::GetOffsetFloat (vis, 2096))));
    ret.InsertLast(String4(2108, "float", "GearPercent",              Round(Dev::GetOffsetFloat (vis, 2108))));

    // ret.InsertLast(String4(, "", "", Round(Dev::GetOffset(vis, ))));
    // ret.InsertLast(String4(, "", "", Round(Dev::GetOffset(vis, ))));
    // ret.InsertLast(String4(, "", "", Round(Dev::GetOffset(vis, ))));
    // ret.InsertLast(String4(, "", "", Round(Dev::GetOffset(vis, ))));

    return ret;
}

#endif