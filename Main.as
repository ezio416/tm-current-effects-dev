/*
c 2023-05-04
m 2023-07-20
*/

const string BLUE   = "\\$09D";
const string CYAN   = "\\$2FF";
const string GRAY   = "\\$888";
const string GREEN  = "\\$0D2";
const string ORANGE = "\\$F90";
const string PURPLE = "\\$F0F";
const string RED    = "\\$F00";
const string WHITE  = "\\$FFF";
const string YELLOW = "\\$FF0";

string title = Icons::Bug + " Current Effects (dev)";
int start = 0;
int end = 10000;
int[] missingOffsets = {
    636, 644, 648, 712, 716, 720, 732, 736, 740, 748, 752, 756, 760, 764, 768, 772, 952, 956, 960, 964, 968, 972, 1020, 1024,
    1032, 1040, 1044, 1052, 1056, 1060, 1064, 1068, 1072, 1076, 1080, 1084, 1088, 1092, 1096, 1100, 1104, 1108, 1112, 1116,
    1120, 1124, 1128, 1132, 1136, 1140, 1148, 1152, 1156, 1160, 1164, 1188, 1192, 1200, 1204, 1208, 1212, 1216, 1220, 1224,
    1228, 1232, 1236, 1240, 1244, 1248, 1252, 1256, 1260, 1264, 1268, 1272, 1276, 1280, 1284, 1288, 1292, 1296, 1300, 1304,
    1308, 1312, 1316, 1320, 1324, 1328, 1332, 1336, 1340, 1344, 1348, 1352, 1356, 1360, 1364, 1368, 1372, 1376, 1380, 1384,
    1388, 1392, 1420, 1424, 1428, 1432, 1436, 1440, 1444, 1448, 1452, 1456, 1460, 1464, 1468, 1472, 1476, 1480, 1484, 1488
};

[Setting hidden]
bool windowOpen = false;

void RenderMenu() {
    if (UI::MenuItem(title))
        windowOpen = !windowOpen;
}

void Render() {
    if (!windowOpen) return;

    UI::Begin(title, windowOpen, UI::WindowFlags::None);
    UI::BeginTabBar("tabs");
        if (UI::BeginTabItem("CSceneVehicleVis offsets")) {
            try {
                auto app = cast<CTrackMania@>(GetApp());
                auto playground = cast<CSmArenaClient@>(app.CurrentPlayground);
                if (playground is null) throw("no-playground");
                // auto player = cast<CSmPlayer@>(playground.Arena.Players[0]);
                // auto script = cast<CSmScriptPlayer@>(player.ScriptAPI);
                // auto sequence = playground.UIConfigs[0].UISequence;
                // auto serverInfo = cast<CTrackManiaNetworkServerInfo@>(app.Network.ServerInfo);

                CSceneVehicleVis@[] allVis = VehicleState::GetAllVis(app.GameScene);
                UI::BeginTabBar("vis-offset-tabs");
                    for (uint i = 0; i < allVis.Length; i++) {
                        CSceneVehicleVis@ vis = allVis[i];
                        CPlugVehicleVisModel@ model = vis.Model;
                        // CSceneVehicleVisState@ state = vis.AsyncState;

                        if (UI::BeginTabItem(i + "_" + model.Id.GetName())) {
                            start = UI::InputInt("offset start", start);
                            end = UI::InputInt("offset end", end);
                            if (start < 0) start = 0;
                            if (start >= end) end = start + 1;

                            if (UI::BeginTable(i + "-offset-table", 2, UI::TableFlags::ScrollY)) {
                                UI::TableSetupScrollFreeze(0, 1);
                                UI::TableSetupColumn("offset", UI::TableColumnFlags::WidthFixed, 80);
                                UI::TableSetupColumn("value");
                                UI::TableHeadersRow();

                                UI::ListClipper clipper((end - start) / 4);
                                while (clipper.Step()) {
                                    for (int j = clipper.DisplayStart; j < clipper.DisplayEnd; j++) {
                                        int offset = start + (j * 4);

                                        UI::TableNextRow();
                                        UI::TableNextColumn();
                                        if (missingOffsets.Find(offset) > -1 || offset > 1516 || (offset > 144 && offset < 620) || offset < 140)
                                            UI::Text(RED + offset);
                                        else
                                            UI::Text("" + offset);

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

        if (UI::BeginTabItem("CSceneVehicleVis values")) {
            try {
                auto app = cast<CTrackMania@>(GetApp());
                auto playground = cast<CSmArenaClient@>(app.CurrentPlayground);
                if (playground is null) throw("no-playground");

                CSceneVehicleVis@[] allVis = VehicleState::GetAllVis(app.GameScene);
                UI::BeginTabBar("vis-value-tabs");
                    for (uint i = 0; i < allVis.Length; i++) {
                        CSceneVehicleVis@ vis = allVis[i];
                        CPlugVehicleVisModel@ model = vis.Model;

                        if (UI::BeginTabItem(i + " " + model.Id.GetName())) {
                            if (UI::BeginTable(i + "-value-table", 4, UI::TableFlags::ScrollY)) {
                                UI::TableSetupColumn("offset(s)", UI::TableColumnFlags::WidthFixed, 120);
                                UI::TableSetupColumn("type", UI::TableColumnFlags::WidthFixed, 80);
                                UI::TableSetupColumn("variable");
                                UI::TableSetupColumn("value");
                                UI::TableHeadersRow();

                                auto knownValues = GetKnownValues(vis);

                                for (uint j = 0; j < knownValues.Length; j++) {
                                    auto kv = @knownValues[j];
                                    UI::TableNextRow();
                                    UI::TableNextColumn(); UI::Text(kv.offset);
                                    UI::TableNextColumn(); UI::Text(kv.type);
                                    UI::TableNextColumn(); UI::Text(kv.name);
                                    UI::TableNextColumn(); UI::Text(kv.value);
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

string ContactState1Name(uint contactId) {
    switch (contactId) {
        case 0:  return "air";
        case 8:  return "ground";
        case 16: return "top contact + wheels";
        case 24: return "top contact";
        case 40: return "wheels burning";
        case 56: return "top contact + wheels burning";
        default: return "unknown";
    }
}

string ContactState2Name(uint contactId) {
    switch (contactId) {
        case -64: return "air";
        case -63: return "falling";
        case -48: return "ground";
        case -40: return "reactor ground";
        default:  return "unknown";
    }
}

string EffectName(int effectId) {
    switch (effectId) {
        case 0:  return "nothing";
        case 1:  return "yellow booster";
        case 2:  return "red booster";
        case 3:  return "roulette booster";
        case 4:  return "engine off";
        case 5:  return "no grip";
        case 6:  return "no steering";
        case 7:  return "forced acceleration";
        case 8:  return "reset";
        case 9:  return "slow-mo";
        case 10: return "yellow bumper";
        case 11: return "red bumper";
        case 12:
        case 18: return "yellow reactor";
        case 13: return "fragile";
        case 14:
        case 19: return "red reactor";
        case 16: return "no brakes";
        case 17: return "cruise control";
        default: return "unknown";
    }
}

string GroundWaterName(int GroundWaterId) {
    switch (GroundWaterId) {
        case 0: return "air";
        case 2: return "sinking";
        case 4: return "ground";
        case 6: return "water";
        default: return "unknown";
    }
}

string MaterialName(int materialId) {
    switch (materialId) {
        case 0:  return "air/water/road";
        case 2:  return "penalty";
        case 3:  return "blue ice";
        case 4:  return "deco";
        case 5:  return "sand";
        case 6:  return "dirt";
        case 9:  return "road border";
        case 16: return "road";
        case 14: return "wood";
        case 21: return "snow";
        case 22: return "fabric";
        case 32: return "signage";
        case 55: return "blue ice (alt)";
        case 62: return "magnet";
        case 64: return "fast magnet";
        case 74: return "ice";
        case 75: return "sausage";
        case 76: return "grass";
        case 77: return "plastic";
        default: return "unknown";
    }
}

string Round(float num, uint precision = 6) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + Text::Format("%." + precision + "f", Math::Abs(num)) + "\\$G";
}

string RoundVec3(vec3 vec, uint precision = 6) {
    return Round(vec.x, precision) + " , " + Round(vec.y, precision) + " , " + Round(vec.z, precision);
}

class String4 {
    string offset;
    string type;
    string name;
    string value;

    String4() { }
    String4(const string &in o, const string &in t, const string &in n, const string &in v) {
        offset = o;
        type = t;
        name = n;
        value = v;
    }
    String4(uint o, const string &in t, const string &in n, const string &in v) {
        offset = "" + o;
        type = t;
        name = n;
        value = v;
    }
}

String4[] GetKnownValues(CSceneVehicleVis@ vis) {
    String4[] ret;
    if (vis is null) return ret;

    ret.InsertLast(String4(140, "float", "GetLinearHue", Round(Dev::GetOffsetFloat(vis, 140))));
    ret.InsertLast(String4(620, "uint32", "TimeInMap?", Round(Dev::GetOffsetUint32(vis, 620), 0)));
    ret.InsertLast(String4(624, "float", "InputSteer", Round(Dev::GetOffsetFloat(vis, 624), 1)));
    ret.InsertLast(String4(628, "float", "InputGasPedal", Round(Dev::GetOffsetFloat(vis, 628), 0)));
    ret.InsertLast(String4(632, "float", "InputBrakePedal", Round(Dev::GetOffsetFloat(vis, 632), 0)));
    ret.InsertLast(String4(640, "int32", "InputIsBraking", Round(Dev::GetOffsetInt32(vis, 640), 0)));
    vec3 LeftDirection;
    LeftDirection.x = Dev::GetOffsetFloat(vis, 652);
    LeftDirection.y = Dev::GetOffsetFloat(vis, 664);
    LeftDirection.z = Dev::GetOffsetFloat(vis, 676);
    ret.InsertLast(String4("652,664,676", "vec3", "LeftDirection", RoundVec3(LeftDirection, 3)));
    vec3 WorldCarUp;
    WorldCarUp.x = Dev::GetOffsetFloat(vis, 656);
    WorldCarUp.y = Dev::GetOffsetFloat(vis, 668);
    WorldCarUp.z = Dev::GetOffsetFloat(vis, 680);
    ret.InsertLast(String4("656,668,680", "vec3", "WorldCarUp", RoundVec3(WorldCarUp, 3)));
    vec3 AimDirection;
    AimDirection.x = Dev::GetOffsetFloat(vis, 660);
    AimDirection.y = Dev::GetOffsetFloat(vis, 672);
    AimDirection.z = Dev::GetOffsetFloat(vis, 684);
    ret.InsertLast(String4("660,672,684", "vec3", "AimDirection", RoundVec3(AimDirection, 3)));
    ret.InsertLast(String4(688, "vec3", "Position", RoundVec3(Dev::GetOffsetVec3(vis, 688), 3)));
    ret.InsertLast(String4(700, "vec3", "WorldVel", RoundVec3(Dev::GetOffsetVec3(vis, 700), 3)));
    ret.InsertLast(String4(724, "float", "FrontSpeed", Round(Dev::GetOffsetFloat(vis, 724), 3)));
    ret.InsertLast(String4(728, "float", "SideSpeed", Round(Dev::GetOffsetFloat(vis, 728), 3)));
    int ContactState1 = Dev::GetOffsetInt8(vis, 744);
    ret.InsertLast(String4(744, "int8", "ContactState1", Round(ContactState1, 0) + " " + ContactState1Name(ContactState1)));
    int ContactState2 = Dev::GetOffsetInt8(vis, 746);
    ret.InsertLast(String4(746, "int8", "ContactState2", Round(ContactState2, 0) + " " + ContactState2Name(ContactState2)));
    ret.InsertLast(String4(747, "int8", "IsTurbo", Round(Dev::GetOffsetInt8(vis, 747), 0)));

    ret.InsertLast(String4(776, "float", "FLDamperLen", Round(Dev::GetOffsetFloat(vis, 776), 4)));
    ret.InsertLast(String4(780, "float", "FLWheelRot", Round(Dev::GetOffsetFloat(vis, 780))));
    ret.InsertLast(String4(784, "float", "FLWheelRotSpeed", Round(Dev::GetOffsetFloat(vis, 784), 3)));
    ret.InsertLast(String4(788, "float", "FLSteerAngle", Round(Dev::GetOffsetFloat(vis, 788), 3)));
    int FLGroundContactMaterial = Dev::GetOffsetInt8(vis, 792);
    ret.InsertLast(String4(792, "int8", "FLGroundContactMaterial", Round(FLGroundContactMaterial, 0) + " " + MaterialName(FLGroundContactMaterial)));
    int FLGroundContactEffect = Dev::GetOffsetInt8(vis, 793);
    ret.InsertLast(String4(793, "int8", "FLGroundContactEffect", Round(FLGroundContactEffect, 0) + " " + EffectName(FLGroundContactEffect)));
    ret.InsertLast(String4(796, "float", "FLSlipCoef", Round(Dev::GetOffsetFloat(vis, 796))));
    ret.InsertLast(String4(800, "float", "FLDirt", Round(Dev::GetOffsetFloat(vis, 800))));
    ret.InsertLast(String4(804, "float", "FLIcing01", Round(Dev::GetOffsetFloat(vis, 804))));
    ret.InsertLast(String4(808, "float", "FLTireWear01", Round(Dev::GetOffsetFloat(vis, 808), 3)));
    ret.InsertLast(String4(812, "float", "FLBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 812))));
    int FLGroundWater = Dev::GetOffsetInt8(vis, 816);
    ret.InsertLast(String4(816, "int8", "FLGroundWater", Round(FLGroundWater, 0) + " " + GroundWaterName(FLGroundWater)));

    ret.InsertLast(String4(820, "float", "FRDamperLen", Round(Dev::GetOffsetFloat(vis, 820), 4)));
    ret.InsertLast(String4(824, "float", "FRWheelRot", Round(Dev::GetOffsetFloat(vis, 824))));
    ret.InsertLast(String4(828, "float", "FRWheelRotSpeed", Round(Dev::GetOffsetFloat(vis, 828), 3)));
    ret.InsertLast(String4(832, "float", "FRSteerAngle", Round(Dev::GetOffsetFloat(vis, 832), 3)));
    int FRGroundContactMaterial = Dev::GetOffsetInt8(vis, 836);
    ret.InsertLast(String4(836, "int8", "FRGroundContactMaterial", Round(FRGroundContactMaterial, 0) + " " + MaterialName(FRGroundContactMaterial)));
    int FRGroundContactEffect = Dev::GetOffsetInt8(vis, 837);
    ret.InsertLast(String4(837, "int8", "FRGroundContactEffect", Round(FRGroundContactEffect, 0) + " " + EffectName(FRGroundContactEffect)));
    ret.InsertLast(String4(840, "float", "FRSlipCoef", Round(Dev::GetOffsetFloat(vis, 840))));
    ret.InsertLast(String4(844, "float", "FRDirt", Round(Dev::GetOffsetFloat(vis, 844))));
    ret.InsertLast(String4(848, "float", "FRIcing01", Round(Dev::GetOffsetFloat(vis, 848))));
    ret.InsertLast(String4(852, "float", "FRTireWear01", Round(Dev::GetOffsetFloat(vis, 852), 3)));
    ret.InsertLast(String4(856, "float", "FRBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 856))));
    int FRGroundWater = Dev::GetOffsetInt8(vis, 860);
    ret.InsertLast(String4(860, "int8", "FRGroundWater", Round(FRGroundWater, 0) + " " + GroundWaterName(FRGroundWater)));

    ret.InsertLast(String4(864, "float", "RRDamperLen", Round(Dev::GetOffsetFloat(vis, 864), 4)));
    ret.InsertLast(String4(868, "float", "RRWheelRot", Round(Dev::GetOffsetFloat(vis, 868))));
    ret.InsertLast(String4(872, "float", "RRWheelRotSpeed", Round(Dev::GetOffsetFloat(vis, 872), 3)));
    ret.InsertLast(String4(876, "float", "RRSteerAngle", Round(Dev::GetOffsetFloat(vis, 876), 3)));
    int RRGroundContactMaterial = Dev::GetOffsetInt8(vis, 880);
    ret.InsertLast(String4(880, "int8", "RRGroundContactMaterial", Round(RRGroundContactMaterial, 0) + " " + MaterialName(RRGroundContactMaterial)));
    int RRGroundContactEffect = Dev::GetOffsetInt8(vis, 881);
    ret.InsertLast(String4(881, "int8", "RRGroundContactEffect", Round(RRGroundContactEffect, 0) + " " + EffectName(RRGroundContactEffect)));
    ret.InsertLast(String4(884, "float", "RRSlipCoef", Round(Dev::GetOffsetFloat(vis, 884))));
    ret.InsertLast(String4(888, "float", "RRDirt", Round(Dev::GetOffsetFloat(vis, 888))));
    ret.InsertLast(String4(892, "float", "RRIcing01", Round(Dev::GetOffsetFloat(vis, 892))));
    ret.InsertLast(String4(896, "float", "RRTireWear01", Round(Dev::GetOffsetFloat(vis, 896), 3)));
    ret.InsertLast(String4(900, "float", "RRBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 900))));
    int RRGroundWater = Dev::GetOffsetInt8(vis, 904);
    ret.InsertLast(String4(904, "int8", "RRGroundWater", Round(RRGroundWater, 0) + " " + GroundWaterName(RRGroundWater)));

    ret.InsertLast(String4(908, "float", "RLDamperLen", Round(Dev::GetOffsetFloat(vis, 908), 4)));
    ret.InsertLast(String4(912, "float", "RLWheelRot", Round(Dev::GetOffsetFloat(vis, 912))));
    ret.InsertLast(String4(916, "float", "RLWheelRotSpeed", Round(Dev::GetOffsetFloat(vis, 916), 3)));
    ret.InsertLast(String4(920, "float", "RLSteerAngle", Round(Dev::GetOffsetFloat(vis, 920), 3)));
    int RLGroundContactMaterial = Dev::GetOffsetInt8(vis, 924);
    ret.InsertLast(String4(924, "int8", "RLGroundContactMaterial", Round(RLGroundContactMaterial, 0) + " " + MaterialName(RLGroundContactMaterial)));
    int RLGroundContactEffect = Dev::GetOffsetInt8(vis, 925);
    ret.InsertLast(String4(925, "int8", "RLGroundContactEffect", Round(RLGroundContactEffect, 0) + " " + EffectName(RLGroundContactEffect)));
    ret.InsertLast(String4(928, "float", "RLSlipCoef", Round(Dev::GetOffsetFloat(vis, 928))));
    ret.InsertLast(String4(932, "float", "RLDirt", Round(Dev::GetOffsetFloat(vis, 932))));
    ret.InsertLast(String4(936, "float", "RLIcing01", Round(Dev::GetOffsetFloat(vis, 936))));
    ret.InsertLast(String4(940, "float", "RLTireWear01", Round(Dev::GetOffsetFloat(vis, 940), 3)));
    ret.InsertLast(String4(944, "float", "RLBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 944))));
    int RLGroundWater = Dev::GetOffsetInt8(vis, 948);
    ret.InsertLast(String4(948, "int8", "RLGroundWater", Round(RLGroundWater, 0) + " " + GroundWaterName(RLGroundWater)));

    ret.InsertLast(String4(976, "uint32", "LastTurboLevel", Round(Dev::GetOffsetUint32(vis, 976), 0)));
    ret.InsertLast(String4(980, "int32", "ReactorLevel", Round(Dev::GetOffsetInt32(vis, 980), 0)));
    ret.InsertLast(String4(984, "int32", "ReactorType", Round(Dev::GetOffsetInt32(vis, 984), 0)));
    ret.InsertLast(String4(988, "float", "ReactorFinalCountdown", Round(Dev::GetOffsetFloat(vis, 988), 1)));
    ret.InsertLast(String4(992, "vec3", "ReactorAirControl", RoundVec3(Dev::GetOffsetVec3(vis, 992), 0)));
    ret.InsertLast(String4(1004, "vec3", "WorldCarUp", RoundVec3(Dev::GetOffsetVec3(vis, 1004), 3)));
    ret.InsertLast(String4(1016, "float", "EngineRPM", Round(Dev::GetOffsetFloat(vis, 1016), 0)));
    ret.InsertLast(String4(1028, "int32", "EngineCurGear", Round(Dev::GetOffsetInt32(vis, 1028), 0)));
    ret.InsertLast(String4(1036, "float", "TurboTime", Round(Dev::GetOffsetFloat(vis, 1036), 2)));
    ret.InsertLast(String4(1044, "uint32", "RaceStartTime", Round(Dev::GetOffsetUint32(vis, 1044), 0)));

    ret.InsertLast(String4(1048, "int32", "HandicapSum", Round(Dev::GetOffsetInt32(vis, 1048), 0)));
    // 1    slow-mo lvl 1
    // 2    slow-mo lvl 2-4
    // 256  engine off
    // 512  forced accel
    // 1024 no brakes
    // 1536 forced accel + no brakes
    // 2048 no steering
    // 4096 no grip

    ret.InsertLast(String4(1144, "float", "GroundDist", Round(Dev::GetOffsetFloat(vis, 1144))));
    ret.InsertLast(String4(1168, "float", "SimulationTimeCoef", Round(Dev::GetOffsetFloat(vis, 1168))));
    ret.InsertLast(String4(1172, "float", "BulletTimeNormed", Round(Dev::GetOffsetFloat(vis, 1172))));
    ret.InsertLast(String4(1176, "float", "AirBrakeNormed", Round(Dev::GetOffsetFloat(vis, 1176))));
    ret.InsertLast(String4(1180, "float", "SpoilerOpenNormed", Round(Dev::GetOffsetFloat(vis, 1180))));
    ret.InsertLast(String4(1184, "float", "WingsOpenNormed", Round(Dev::GetOffsetFloat(vis, 1184))));
    float WaterImmersionCoef = Dev::GetOffsetFloat(vis, 1396);
    if (WaterImmersionCoef < 0) WaterImmersionCoef = 0;
    ret.InsertLast(String4(1396, "float", "WaterImmersionCoef", Round(WaterImmersionCoef)));
    float WaterOverDistNormed = Dev::GetOffsetFloat(vis, 1400);
    if (WaterOverDistNormed < 0) WaterOverDistNormed = 0;
    ret.InsertLast(String4(1400, "float", "WaterOverDistNormed", Round(WaterOverDistNormed)));
    ret.InsertLast(String4(1404, "vec3", "WaterOverSurfacePos", RoundVec3(Dev::GetOffsetVec3(vis, 1404), 3)));
    ret.InsertLast(String4(1416, "float", "WetnessValue01", Round(Dev::GetOffsetFloat(vis, 1416))));
    ret.InsertLast(String4(1492, "vec3", "Position", RoundVec3(Dev::GetOffsetVec3(vis, 1492), 3)));
    ret.InsertLast(String4(1504, "vec3", "WorldVel", RoundVec3(Dev::GetOffsetVec3(vis, 1504), 3)));
    ret.InsertLast(String4(1516, "uint8", "Resets/Respawns?", Round(Dev::GetOffsetUint8(vis, 1516), 0)));  // articificially increases with respawns

    // 121 start accelerating?
    // 409 race time?
    // 617 race time?
    // 1562 wheels burning?
    // 1690,1738 is braking?
    // 1820 total forward movement holding gas?

    return ret;
}