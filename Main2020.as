/*
c 2023-10-22
m 2023-11-21
*/

#if TMNEXT

int visStart = 0;
int visEnd = 10000;
int[] knownVisOffsets = {
    0140, 0144, 0316, 0320, 0324, 0328, 0336,
    0476, 0480, 0484, 0488,  // FL
    0520, 0524, 0528, 0532,  // FR
    0564, 0568, 0572, 0576,  // RR
    0608, 0612, 0616, 0620,  // RL
    0672, 0676, 0680, 0684, 0688, 0692, 0696, 0712, 0724, 0732, 0740, 0744, 0864, 0868, 0872, 0876
};

int playerStart = 0;
int playerEnd = 10000;
int[] missingPlayerOffsets = {
    400, 404, 408, 412, 416, 432, 436, 440, 444, 448, 452, 456, 460, 464, 468, 472, 476, 480, 484, 488, 492, 496, 500, 504,
    508, 512, 516, 520, 524, 528, 532, 536, 540, 872, 876, 880, 884, 888, 892, 896, 900, 916, 924, 3612, 3616, 3620, 3624, 3628,
    3632, 3636, 3640, 3644, 3648, 3652, 3656, 3660, 3664, 3668, 3672, 3676, 3680, 3684, 3688, 3692, 3696, 3700, 3704, 3708, 3712,
    3716, 3720, 3724, 3728, 3732, 3736, 3740, 3744, 3748, 3776, 3780, 3820, 3832, 3836, 3840, 3848, 3852
};

void Render2020() {
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

                        // print(Round(state.AirBrakeNormed) + " " + Round(state.WingsOpenNormed));

                        if (UI::BeginTabItem(i + "_" + model.Id.GetName())) {
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
                                        UI::Text((knownVisOffsets.Find(offset) == -1 ? RED : "") + offset);

                                        UI::TableNextColumn();
                                        try {
                                            switch (offsetDataType) {
                                                case DataType::Int8:   UI::Text(Round(Dev::GetOffsetInt8(vis, offset)));   break;
                                                case DataType::Uint8:  UI::Text(Round(Dev::GetOffsetUint8(vis, offset)));  break;
                                                case DataType::Int16:  UI::Text(Round(Dev::GetOffsetInt16(vis, offset)));  break;
                                                case DataType::Uint16: UI::Text(Round(Dev::GetOffsetUint16(vis, offset))); break;
                                                case DataType::Int32:  UI::Text(Round(Dev::GetOffsetInt32(vis, offset)));  break;
                                                case DataType::Uint32: UI::Text(Round(Dev::GetOffsetUint32(vis, offset))); break;
                                                case DataType::Int64:  UI::Text(Round(Dev::GetOffsetInt64(vis, offset)));  break;
                                                case DataType::Uint64: UI::Text(Round(Dev::GetOffsetUint64(vis, offset))); break;
                                                case DataType::Float:  UI::Text(Round(Dev::GetOffsetFloat(vis, offset)));  break;
                                                case DataType::Vec3:   UI::Text(Round(Dev::GetOffsetVec3(vis, offset)));   break;
                                                default: UI::Text("unknown type");
                                            }
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
                CSmArenaClient@ playground = cast<CSmArenaClient@>(app.CurrentPlayground);
                if (playground is null)
                    throw("no-playground");

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

                                String4[] knownValues = GetKnownVisValues(vis);

                                for (uint j = 0; j < knownValues.Length; j++) {
                                    String4@ kv = @knownValues[j];
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

        if (UI::BeginTabItem("my vis")) {
            try {
                CTrackMania@ app = cast<CTrackMania@>(GetApp());
                CSmArenaClient@ playground = cast<CSmArenaClient@>(app.CurrentPlayground);
                if (playground is null) throw("no-playground");

                ISceneVis@ scene = cast<ISceneVis@>(app.GameScene);
                if (scene is null) throw("no-scene");

                CSceneVehicleVis@ vis;
                CSmPlayer@ player = cast<CSmPlayer@>(playground.GameTerminals[0].GUIPlayer);
                if (player !is null) {
                    @vis = VehicleState::GetVis(scene, player);
                } else {
                    @vis = VehicleState::GetSingularVis(scene);
                }
                if (vis is null) throw("no-vis");

                if (UI::BeginTable("value-table", 4, UI::TableFlags::ScrollY)) {
                    UI::TableSetupColumn("offset(s)", UI::TableColumnFlags::WidthFixed, 120);
                    UI::TableSetupColumn("type", UI::TableColumnFlags::WidthFixed, 80);
                    UI::TableSetupColumn("variable");
                    UI::TableSetupColumn("value");
                    UI::TableHeadersRow();

                    String4[] knownValues = GetKnownVisValues(vis);

                    for (uint j = 0; j < knownValues.Length; j++) {
                        String4@ kv = @knownValues[j];
                        UI::TableNextRow();
                        UI::TableNextColumn(); UI::Text(kv.offset);
                        UI::TableNextColumn(); UI::Text(kv.type);
                        UI::TableNextColumn(); UI::Text(kv.name);
                        UI::TableNextColumn(); UI::Text(kv.value);
                    }
                    UI::EndTable();
                }
            } catch {
                UI::Text("oopsie: " + getExceptionInfo());
            }
            UI::EndTabItem();
        }

        if (UI::BeginTabItem("my script")) {
            try {
                auto app = cast<CTrackMania@>(GetApp());
                auto playground = cast<CSmArenaClient@>(app.CurrentPlayground);
                if (playground is null) throw("no-playground");

                auto scene = cast<ISceneVis@>(app.GameScene);
                if (scene is null) throw("no-scene");

                // CSceneVehicleVis@ vis;
                auto player = cast<CSmPlayer@>(playground.GameTerminals[0].GUIPlayer);
                auto script = cast<CSmScriptPlayer>(player.ScriptAPI);
                // if (player !is null) {
                //     @vis = VehicleState::GetVis(scene, player);
                // } else {
                //     @vis = VehicleState::GetSingularVis(scene);
                // }
                // if (vis is null) throw("no-vis");

                if (UI::BeginTable("script-table", 2, UI::TableFlags::ScrollY)) {
                    UI::TableSetupColumn("variable");
                    UI::TableSetupColumn("value");
                    UI::TableHeadersRow();

                    UI::TableNextRow();
                    UI::TableNextColumn();
                    UI::Text("HandicapNoGasDuration");
                    UI::TableNextColumn();
                    UI::Text(tostring(script.HandicapNoGasDuration));

                    UI::TableNextRow();
                    UI::TableNextColumn();
                    UI::Text("HandicapForceGasDuration");
                    UI::TableNextColumn();
                    UI::Text(tostring(script.HandicapForceGasDuration));

                    UI::TableNextRow();
                    UI::TableNextColumn();
                    UI::Text("HandicapNoBrakesDuration");
                    UI::TableNextColumn();
                    UI::Text(tostring(script.HandicapNoBrakesDuration));

                    UI::TableNextRow();
                    UI::TableNextColumn();
                    UI::Text("HandicapNoSteeringDuration");
                    UI::TableNextColumn();
                    UI::Text(tostring(script.HandicapNoSteeringDuration));

                    UI::TableNextRow();
                    UI::TableNextColumn();
                    UI::Text("HandicapNoGripDuration");
                    UI::TableNextColumn();
                    UI::Text(tostring(script.HandicapNoGripDuration));

                    UI::EndTable();
                }
            } catch {
                UI::Text("oopsie: " + getExceptionInfo());
            }
            UI::EndTabItem();
        }

        if (UI::BeginTabItem("CSmPlayer offsets")) {
            try {
                auto app = cast<CTrackMania@>(GetApp());
                auto playground = cast<CSmArenaClient@>(app.CurrentPlayground);
                if (playground is null) throw("no-playground");
                auto player = cast<CSmPlayer@>(playground.Arena.Players[0]);
                // auto script = cast<CSmScriptPlayer@>(player.ScriptAPI);

                playerStart = UI::InputInt("player offset start", playerStart);
                playerEnd = UI::InputInt("player offset end", playerEnd);
                if (playerStart < 0) playerStart = 0;
                if (playerStart >= playerEnd) playerEnd = playerStart + 1;

                if (UI::BeginTable("player-offset-table", 2, UI::TableFlags::ScrollY)) {
                    UI::TableSetupScrollFreeze(0, 1);
                    UI::TableSetupColumn("offset", UI::TableColumnFlags::WidthFixed, 80);
                    UI::TableSetupColumn("value");
                    UI::TableHeadersRow();

                    UI::ListClipper clipper((playerEnd - playerStart) / offsetSkip);
                    while (clipper.Step()) {
                        for (int j = clipper.DisplayStart; j < clipper.DisplayEnd; j++) {
                            int offset = visStart + (j * offsetSkip);

                            UI::TableNextRow();
                            UI::TableNextColumn();
                            string offsetColor = "";
                            if (
                                missingPlayerOffsets.Find(offset) > -1 ||
                                offset < 388 ||
                                (offset > 544 && offset < 860) ||
                                (offset > 944 && offset < 3144) ||
                                (offset > 3144 && offset < 3588) ||
                                (offset > 3888 && offset < 4116) ||
                                offset > 4124
                            ) offsetColor = RED;
                            UI::Text(offsetColor + offset);

                            UI::TableNextColumn();
                            try {
                                // UI::Text(Round(Dev::GetOffsetInt8(player, offset), 0));
                                // UI::Text(Round(Dev::GetOffsetUint8(player, offset), 0));

                                // UI::Text(Round(Dev::GetOffsetInt16(player, offset), 0));
                                // UI::Text(Round(Dev::GetOffsetUint16(player, offset), 0));

                                // UI::Text(Round(Dev::GetOffsetInt32(player, offset), 0));
                                // UI::Text(Round(Dev::GetOffsetUint32(player, offset), 0));
                                UI::Text(Round(Dev::GetOffsetFloat(player, offset)));

                                // UI::Text(Round(Dev::GetOffsetInt64(player, offset), 0));
                                // UI::Text(Round(Dev::GetOffsetUint64(player, offset), 0));
                                // UI::Text(Round(Dev::GetOffsetDouble(player, offset)));

                                // UI::Text(Round(Dev::GetOffsetVec3(player, offset)));
                            } catch {
                                UI::Text(RED + getExceptionInfo());
                            }
                        }
                    }
                    UI::EndTable();
                }
            } catch {
                UI::Text("oopsie: " + getExceptionInfo());
            }
            UI::EndTabItem();
        }

        if (UI::BeginTabItem("player values")) {
            try {
                auto app = cast<CTrackMania@>(GetApp());
                auto playground = cast<CSmArenaClient@>(app.CurrentPlayground);
                if (playground is null) throw("no-playground");
                auto player = cast<CSmPlayer@>(playground.Arena.Players[0]);

                if (UI::BeginTable("player-value-table", 4, UI::TableFlags::ScrollY)) {
                    UI::TableSetupColumn("offset(s)", UI::TableColumnFlags::WidthFixed, 120);
                    UI::TableSetupColumn("type", UI::TableColumnFlags::WidthFixed, 80);
                    UI::TableSetupColumn("variable");
                    UI::TableSetupColumn("value");
                    UI::TableHeadersRow();

                    auto knownValues = GetKnownPlayerValues(player);

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
            } catch {
                UI::Text("oopsie: " + getExceptionInfo());
            }
            UI::EndTabItem();
        }
    UI::EndTabBar();
    UI::End();
}

String4[] GetKnownVisValues(CSceneVehicleVis@ vis) {
    String4[] ret;
    if (vis is null)
        return ret;

    ret.InsertLast(String4(140, "float",  "GetLinearHue",       Round(Dev::GetOffsetFloat (vis, 140))));
    ret.InsertLast(String4(144, "float",  "GetLinearHue",       Round(Dev::GetOffsetFloat (vis, 144))));
    ret.InsertLast(String4(316, "uint32", "TimeInMap?",         Round(Dev::GetOffsetUint32(vis, 316))));
    ret.InsertLast(String4(320, "float",  "InputSteer",         Round(Dev::GetOffsetFloat (vis, 320))));
    ret.InsertLast(String4(324, "float",  "InputGasPedal",      Round(Dev::GetOffsetFloat (vis, 324), 0)));
    ret.InsertLast(String4(328, "float",  "InputBrakePedal",    Round(Dev::GetOffsetFloat (vis, 328), 0)));
    ret.InsertLast(String4(336, "int32",  "InputIsBraking",     Round(Dev::GetOffsetInt32 (vis, 336))));

    // vec3 x = Dev::GetOffsetVec3(vis, 652);
    // vec3 y = Dev::GetOffsetVec3(vis, 664);
    // vec3 z = Dev::GetOffsetVec3(vis, 676);
    // vec3 LeftDirection;
    // LeftDirection.x = x.x;
    // LeftDirection.y = y.x;
    // LeftDirection.z = z.x;
    // ret.InsertLast(String4("652,664,676", "vec3", "LeftDirection", Round(LeftDirection, 3)));
    // vec3 WorldCarUp;
    // WorldCarUp.x = x.y;
    // WorldCarUp.y = y.y;
    // WorldCarUp.z = z.y;
    // ret.InsertLast(String4("656,668,680", "vec3", "WorldCarUp", Round(WorldCarUp, 3)));
    // vec3 AimDirection;
    // AimDirection.x = x.z;
    // AimDirection.y = y.z;
    // AimDirection.z = z.z;
    // ret.InsertLast(String4("660,672,684", "vec3", "AimDirection", Round(AimDirection, 3)));

    // ret.InsertLast(String4(688, "vec3", "Position", Round(Dev::GetOffsetVec3(vis, 688), 3)));
    // ret.InsertLast(String4(700, "vec3", "WorldVel", Round(Dev::GetOffsetVec3(vis, 700), 3)));
    // ret.InsertLast(String4(724, "float", "FrontSpeed", Round(Dev::GetOffsetFloat(vis, 724), 3)));
    // ret.InsertLast(String4(728, "float", "SideSpeed", Round(Dev::GetOffsetFloat(vis, 728), 3)));
    // int ContactState1 = Dev::GetOffsetInt8(vis, 744);
    // ret.InsertLast(String4(744, "int8", "ContactState1", Round(ContactState1, 0) + " " + ContactState1Name(ContactState1)));
    // int ContactState2 = Dev::GetOffsetInt8(vis, 746);
    // ret.InsertLast(String4(746, "int8", "ContactState2", Round(ContactState2, 0) + " " + ContactState2Name(ContactState2)));
    // ret.InsertLast(String4(747, "int8", "IsTurbo", Round(Dev::GetOffsetInt8(vis, 747), 0)));  // 0-1 for self, 4-5 for replays

    ret.InsertLast(String4(472, "float",  "FLDamperLen",        Round(Dev::GetOffsetFloat(vis, 472), 4)));
    ret.InsertLast(String4(476, "float",  "FLWheelRot",         Round(Dev::GetOffsetFloat(vis, 476))));
    ret.InsertLast(String4(480, "float",  "FLWheelRotSpeed",    Round(Dev::GetOffsetFloat(vis, 480))));
    ret.InsertLast(String4(484, "float",  "FLSteerAngle",       Round(Dev::GetOffsetFloat(vis, 484))));
    int FLGroundContactMaterial = Dev::GetOffsetInt8(vis, 488);
    ret.InsertLast(String4(488, "int8", "FLGroundContactMaterial", Round(FLGroundContactMaterial, 0) + " " + MaterialName(FLGroundContactMaterial)));
    // int FLGroundContactEffect = Dev::GetOffsetInt8(vis, 793);
    // ret.InsertLast(String4(793, "int8", "FLGroundContactEffect", Round(FLGroundContactEffect, 0) + " " + EffectName(FLGroundContactEffect)));
    // ret.InsertLast(String4(796, "float", "FLSlipCoef", Round(Dev::GetOffsetFloat(vis, 796))));
    // ret.InsertLast(String4(800, "float", "FLDirt", Round(Dev::GetOffsetFloat(vis, 800))));
    // ret.InsertLast(String4(804, "float", "FLIcing01", Round(Dev::GetOffsetFloat(vis, 804))));
    // ret.InsertLast(String4(808, "float", "FLTireWear01", Round(Dev::GetOffsetFloat(vis, 808), 3)));
    // ret.InsertLast(String4(812, "float", "FLBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 812))));
    // int FLFalling = Dev::GetOffsetInt8(vis, 816);
    // ret.InsertLast(String4(816, "int8", "FLFalling", Round(FLFalling, 0) + " " + FallingName(FLFalling)));

    ret.InsertLast(String4(516, "float",  "FRDamperLen",        Round(Dev::GetOffsetFloat(vis, 516), 4)));
    ret.InsertLast(String4(520, "float",  "FRWheelRot",         Round(Dev::GetOffsetFloat(vis, 520))));
    ret.InsertLast(String4(524, "float",  "FRWheelRotSpeed",    Round(Dev::GetOffsetFloat(vis, 524))));
    ret.InsertLast(String4(528, "float",  "FRSteerAngle",       Round(Dev::GetOffsetFloat(vis, 528))));
    int FRGroundContactMaterial = Dev::GetOffsetInt8(vis, 532);
    ret.InsertLast(String4(532, "int8", "FRGroundContactMaterial", Round(FRGroundContactMaterial, 0) + " " + MaterialName(FRGroundContactMaterial)));
    // int FRGroundContactEffect = Dev::GetOffsetInt8(vis, 837);
    // ret.InsertLast(String4(837, "int8", "FRGroundContactEffect", Round(FRGroundContactEffect, 0) + " " + EffectName(FRGroundContactEffect)));
    // ret.InsertLast(String4(840, "float", "FRSlipCoef", Round(Dev::GetOffsetFloat(vis, 840))));
    // ret.InsertLast(String4(844, "float", "FRDirt", Round(Dev::GetOffsetFloat(vis, 844))));
    // ret.InsertLast(String4(848, "float", "FRIcing01", Round(Dev::GetOffsetFloat(vis, 848))));
    // ret.InsertLast(String4(852, "float", "FRTireWear01", Round(Dev::GetOffsetFloat(vis, 852), 3)));
    // ret.InsertLast(String4(856, "float", "FRBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 856))));
    // int FRFalling = Dev::GetOffsetInt8(vis, 860);
    // ret.InsertLast(String4(860, "int8", "FRFalling", Round(FRFalling, 0) + " " + FallingName(FRFalling)));

    ret.InsertLast(String4(560, "float",  "RRDamperLen",        Round(Dev::GetOffsetFloat(vis, 560), 4)));
    ret.InsertLast(String4(564, "float",  "RRWheelRot",         Round(Dev::GetOffsetFloat(vis, 564))));
    ret.InsertLast(String4(568, "float",  "RRWheelRotSpeed",    Round(Dev::GetOffsetFloat(vis, 568))));
    ret.InsertLast(String4(572, "float",  "RRSteerAngle",       Round(Dev::GetOffsetFloat(vis, 572))));
    int RRGroundContactMaterial = Dev::GetOffsetInt8(vis, 576);
    ret.InsertLast(String4(576, "int8", "RRGroundContactMaterial", Round(RRGroundContactMaterial, 0) + " " + MaterialName(RRGroundContactMaterial)));
    // int RRGroundContactEffect = Dev::GetOffsetInt8(vis, 881);
    // ret.InsertLast(String4(881, "int8", "RRGroundContactEffect", Round(RRGroundContactEffect, 0) + " " + EffectName(RRGroundContactEffect)));
    // ret.InsertLast(String4(884, "float", "RRSlipCoef", Round(Dev::GetOffsetFloat(vis, 884))));
    // ret.InsertLast(String4(888, "float", "RRDirt", Round(Dev::GetOffsetFloat(vis, 888))));
    // ret.InsertLast(String4(892, "float", "RRIcing01", Round(Dev::GetOffsetFloat(vis, 892))));
    // ret.InsertLast(String4(896, "float", "RRTireWear01", Round(Dev::GetOffsetFloat(vis, 896), 3)));
    // ret.InsertLast(String4(900, "float", "RRBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 900))));
    // int RRFalling = Dev::GetOffsetInt8(vis, 904);
    // ret.InsertLast(String4(904, "int8", "RRFalling", Round(RRFalling, 0) + " " + FallingName(RRFalling)));

    ret.InsertLast(String4(604, "float",  "RLDamperLen",        Round(Dev::GetOffsetFloat(vis, 604), 4)));
    ret.InsertLast(String4(608, "float",  "RLWheelRot",         Round(Dev::GetOffsetFloat(vis, 608))));
    ret.InsertLast(String4(612, "float",  "RLWheelRotSpeed",    Round(Dev::GetOffsetFloat(vis, 612))));
    ret.InsertLast(String4(616, "float",  "RLSteerAngle",       Round(Dev::GetOffsetFloat(vis, 616))));
    int RLGroundContactMaterial = Dev::GetOffsetInt8(vis, 620);
    ret.InsertLast(String4(620, "int8", "RLGroundContactMaterial", Round(RLGroundContactMaterial, 0) + " " + MaterialName(RLGroundContactMaterial)));
    // int RLGroundContactEffect = Dev::GetOffsetInt8(vis, 925);
    // ret.InsertLast(String4(925, "int8", "RLGroundContactEffect", Round(RLGroundContactEffect, 0) + " " + EffectName(RLGroundContactEffect)));
    // ret.InsertLast(String4(928, "float", "RLSlipCoef", Round(Dev::GetOffsetFloat(vis, 928))));
    // ret.InsertLast(String4(932, "float", "RLDirt", Round(Dev::GetOffsetFloat(vis, 932))));
    // ret.InsertLast(String4(936, "float", "RLIcing01", Round(Dev::GetOffsetFloat(vis, 936))));
    // ret.InsertLast(String4(940, "float", "RLTireWear01", Round(Dev::GetOffsetFloat(vis, 940), 3)));
    // ret.InsertLast(String4(944, "float", "RLBreakNormedCoef", Round(Dev::GetOffsetFloat(vis, 944))));
    // int RLFalling = Dev::GetOffsetInt8(vis, 948);
    // ret.InsertLast(String4(948, "int8", "RLFalling", Round(RLFalling, 0) + " " + FallingName(RLFalling)));

    ret.InsertLast(String4(672, "uint32", "LastTurboLevel",     Round(Dev::GetOffsetUint32(vis, 672))));
    ret.InsertLast(String4(676, "int32",  "ReactorBoostLvl",    Round(Dev::GetOffsetInt32 (vis, 676))));
    ret.InsertLast(String4(680, "int32",  "ReactorBoostType",   Round(Dev::GetOffsetInt32 (vis, 680))));
    ret.InsertLast(String4(684, "float",  "ReactorFinalTimer",  Round(Dev::GetOffsetFloat (vis, 684), 2)));
    ret.InsertLast(String4(688, "vec3",   "ReactorAirControl",  Round(Dev::GetOffsetVec3  (vis, 688), 0)));
    // ret.InsertLast(String4(1004, "vec3", "WorldCarUp", Round(Dev::GetOffsetVec3(vis, 1004), 3)));
    ret.InsertLast(String4(712, "float",  "EngineRPM",          Round(Dev::GetOffsetFloat (vis, 712), 0)));
    ret.InsertLast(String4(724, "int32",  "CurGear",            Round(Dev::GetOffsetInt32 (vis, 724))));
    ret.InsertLast(String4(732, "float",  "TurboTime",          Round(Dev::GetOffsetFloat (vis, 732), 2)));
    ret.InsertLast(String4(740, "uint32", "LastRespawn?",       Round(Dev::GetOffsetUint32(vis, 740), 0)));

    ret.InsertLast(String4(744, "int32",  "HandicapSum",        Round(Dev::GetOffsetInt32 (vis, 744))));
    // 1    slow-mo lvl 1
    // 2    slow-mo lvl 2-4
    // 256  engine off
    // 512  forced accel
    // 1024 no brakes
    // 1536 forced accel + no brakes
    // 2048 no steering
    // 4096 no grip

    // ret.InsertLast(String4(1144, "float", "GroundDist", Round(Dev::GetOffsetFloat(vis, 1144))));
    ret.InsertLast(String4(864, "float",  "SimulationTimeCoef", Round(Dev::GetOffsetFloat(vis, 864))));
    ret.InsertLast(String4(868, "float",  "BulletTimeNormed",   Round(Dev::GetOffsetFloat(vis, 868))));
    // ret.InsertLast(String4(1176, "float", "AirBrakeNormed", Round(Dev::GetOffsetFloat(vis, 1176))));  // where did this go?
    ret.InsertLast(String4(872, "float",  "WingsOpenNormed",    Round(Dev::GetOffsetFloat(vis, 872))));  // in API as AirBrakeNormed
    ret.InsertLast(String4(876, "float",  "SpoilerOpenNormed",  Round(Dev::GetOffsetFloat(vis, 876))));
    // float WaterImmersionCoef = Dev::GetOffsetFloat(vis, 1396);
    // if (WaterImmersionCoef < 0) WaterImmersionCoef = 0;
    // ret.InsertLast(String4(1396, "float", "WaterImmersionCoef", Round(WaterImmersionCoef)));
    // float WaterOverDistNormed = Dev::GetOffsetFloat(vis, 1400);
    // if (WaterOverDistNormed < 0) WaterOverDistNormed = 0;
    // ret.InsertLast(String4(1400, "float", "WaterOverDistNormed", Round(WaterOverDistNormed)));
    // ret.InsertLast(String4(1404, "vec3", "WaterOverSurfacePos", Round(Dev::GetOffsetVec3(vis, 1404), 3)));
    // ret.InsertLast(String4(1416, "float", "WetnessValue01", Round(Dev::GetOffsetFloat(vis, 1416))));
    // ret.InsertLast(String4(1492, "vec3", "Position", Round(Dev::GetOffsetVec3(vis, 1492), 3)));
    // ret.InsertLast(String4(1504, "vec3", "WorldVel", Round(Dev::GetOffsetVec3(vis, 1504), 3)));
    // ret.InsertLast(String4(1516, "uint8", "Resets/Respawns?", Round(Dev::GetOffsetUint8(vis, 1516), 0)));  // artificially increases with respawns

    // 121 start accelerating?
    // 409 race time?
    // 617 race time?
    // 1562 wheels burning?
    // 1690,1738 is braking?
    // 1820 total forward movement holding gas?

    return ret;
}

string ContactState1Name(int contactId) {
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

string ContactState2Name(int contactId) {
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
        case 15: return "bouncy";
        case 16: return "no brakes";
        case 17: return "cruise control";
        case 20: return "null";
        default: return "unknown";
    }
}

string FallingName(int FallingId) {
    switch (FallingId) {
        case 0: return "air";
        case 2: return "sinking";
        case 4: return "ground";
        case 6: return "water";
        default: return "unknown";
    }
}

string MaterialName(int materialId) {
    switch (materialId) {
        case 0:  return "air/water/road";  // Concrete
        case 2:  return "penalty";  // Grass
        case 3:  return "blue ice";  // Ice
        case 4:  return "deco";  // Metal
        case 5:  return "sand";
        case 6:  return "dirt";
        case 9:  return "road border";  // Rubber
        case 14: return "wood";
        case 16: return "road";  // Asphalt
        case 21: return "snow";
        case 22: return "fabric";  // ResonantMetal
        case 32: return "signage";  // MetalTrans
        case 55: return "blue ice (alt)";  // TechMagnetic
        case 62: return "magnet";  // TechSuperMagnetic
        case 64: return "fast magnet";  // TechMagneticAccel
        case 74: return "ice";  // RoadIce
        case 75: return "sausage";  //RoadSynthetic
        case 76: return "grass";  // Green
        case 77: return "plastic";
        default: return "unknown";
    }
}

String4[] GetKnownPlayerValues(CSmPlayer@ player) {
    String4[] ret;
    if (player is null) return ret;

    ret.InsertLast(String4(388,  "float",  "InputSteerDirection",        Round(Dev::GetOffsetFloat   (player, 388),  0)));
    ret.InsertLast(String4(392,  "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 392),  0)));
    ret.InsertLast(String4(396,  "float",  "InputBrakePedal",            Round(Dev::GetOffsetFloat   (player, 396),  0)));
    ret.InsertLast(String4(420,  "float",  "InputSteerDirection",        Round(Dev::GetOffsetFloat   (player, 420),  0)));
    ret.InsertLast(String4(424,  "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 424),  0)));
    ret.InsertLast(String4(428,  "float",  "InputBrakePedal",            Round(Dev::GetOffsetFloat   (player, 428),  0)));
    ret.InsertLast(String4(468,  "int32",  "SpawnIndex",                 Round(Dev::GetOffsetInt32   (player, 468),  0)));
    ret.InsertLast(String4(544,  "int32",  "EndTime",                    Round(Dev::GetOffsetInt32   (player, 544),  0)));
    ret.InsertLast(String4(860,  "float",  "GetLinearHue",               Round(Dev::GetOffsetFloat   (player, 860),  6)));
    ret.InsertLast(String4(864,  "uint8",  "DossardNumber1",             Round(Dev::GetOffsetUint8   (player, 864),  0)));
    ret.InsertLast(String4(865,  "uint8",  "DossardNumber2",             Round(Dev::GetOffsetUint8   (player, 865),  0)));
    ret.InsertLast(String4(866,  "uint8",  "DossardTrigram1",            Round(Dev::GetOffsetUint8   (player, 866),  0)));
    ret.InsertLast(String4(867,  "uint8",  "DossardTrigram2",            Round(Dev::GetOffsetUint8   (player, 867),  0)));
    ret.InsertLast(String4(868,  "uint8",  "DossardTrigram3",            Round(Dev::GetOffsetUint8   (player, 868),  0)));
    ret.InsertLast(String4(904,  "uint32", "ArmorMax",                   Round(Dev::GetOffsetUint32  (player, 904),  0)));
    ret.InsertLast(String4(908,  "uint32", "ArmorGain",                  Round(Dev::GetOffsetUint32  (player, 908),  0)));
    ret.InsertLast(String4(912,  "float",  "ArmorPower",                 Round(Dev::GetOffsetFloat   (player, 912),  3)));
    ret.InsertLast(String4(920,  "uint32", "ArmorReplenishGain",         Round(Dev::GetOffsetUint32  (player, 920),  0)));
    ret.InsertLast(String4(928,  "float",  "StaminaMax",                 Round(Dev::GetOffsetFloat   (player, 928),  3)));
    ret.InsertLast(String4(932,  "float",  "StaminaGain",                Round(Dev::GetOffsetFloat   (player, 932),  3)));
    ret.InsertLast(String4(936,  "float",  "StaminaPower",               Round(Dev::GetOffsetFloat   (player, 936),  3)));
    ret.InsertLast(String4(940,  "float",  "SpeedPower",                 Round(Dev::GetOffsetFloat   (player, 940),  3)));
    ret.InsertLast(String4(944,  "float",  "JumpPower",                  Round(Dev::GetOffsetFloat   (player, 944),  3)));
    ret.InsertLast(String4(3144, "uint32", "StartTime",                  Round(Dev::GetOffsetUint32  (player, 3144), 0)));
    ret.InsertLast(String4(3588, "vec3",   "Position",                   Round(Dev::GetOffsetVec3    (player, 3588), 3)));
    ret.InsertLast(String4(3600, "vec3",   "Velocity",                   Round(Dev::GetOffsetVec3    (player, 3600), 3)));
    ret.InsertLast(String4(3752, "vec3",   "Position",                   Round(Dev::GetOffsetVec3    (player, 3752), 3)));
    ret.InsertLast(String4(3764, "vec3",   "AimDirection",               Round(Dev::GetOffsetVec3    (player, 3764), 3)));
    ret.InsertLast(String4(3784, "float",  "Upwardness",                 Round(Dev::GetOffsetFloat   (player, 3784), 3)));
    ret.InsertLast(String4(3788, "float",  "FrontSpeed",                 Round(Dev::GetOffsetFloat   (player, 3788), 3)));
    ret.InsertLast(String4(3792, "uint32", "DisplaySpeed",               Round(Dev::GetOffsetUint32  (player, 3792), 0)));
    ret.InsertLast(String4(3796, "float",  "InputSteer",                 Round(Dev::GetOffsetFloat   (player, 3796), 1)));
    ret.InsertLast(String4(3800, "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 3800), 0)));
    ret.InsertLast(String4(3804, "uint32", "InputIsBraking",             Round(Dev::GetOffsetUint32  (player, 3804), 0)));
    ret.InsertLast(String4(3808, "float",  "EngineRPM",                  Round(Dev::GetOffsetFloat   (player, 3808), 0)));
    ret.InsertLast(String4(3812, "uint32", "EngineCurGear",              Round(Dev::GetOffsetUint32  (player, 3812), 0)));
    ret.InsertLast(String4(3816, "float",  "EngineTurboRatio",           Round(Dev::GetOffsetFloat   (player, 3816), 6)));
    ret.InsertLast(String4(3824, "uint32", "WheelsContactCount",         Round(Dev::GetOffsetUint32  (player, 3824), 0)));
    ret.InsertLast(String4(3828, "uint32", "WheelsSkiddingCount",        Round(Dev::GetOffsetUint32  (player, 3828), 0)));
    ret.InsertLast(String4(3844, "uint32", "FlyingDuration",             Round(Dev::GetOffsetUint32  (player, 3844), 0)));
    ret.InsertLast(String4(3856, "uint32", "SkiddingDuration",           Round(Dev::GetOffsetUint32  (player, 3856), 0)));
    ret.InsertLast(String4(3860, "uint32", "HandicapNoGasDuration",      Round(Dev::GetOffsetUint32  (player, 3860), 0)));
    ret.InsertLast(String4(3864, "uint32", "HandicapForceGasDuration",   Round(Dev::GetOffsetUint32  (player, 3864), 0)));
    ret.InsertLast(String4(3868, "uint32", "HandicapNoBrakesDuration",   Round(Dev::GetOffsetUint32  (player, 3868), 0)));
    ret.InsertLast(String4(3872, "uint32", "HandicapNoSteeringDuration", Round(Dev::GetOffsetUint32  (player, 3872), 0)));
    ret.InsertLast(String4(3876, "uint32", "HandicapNoGripDuration",     Round(Dev::GetOffsetUint32  (player, 3876), 0)));
    ret.InsertLast(String4(3880, "float",  "SkiddingDistance",           Round(Dev::GetOffsetFloat   (player, 3880), 3)));
    ret.InsertLast(String4(3884, "float",  "FlyingDistance",             Round(Dev::GetOffsetFloat   (player, 3884), 3)));
    ret.InsertLast(String4(3888, "float",  "Distance",                   Round(Dev::GetOffsetFloat   (player, 3888), 3)));
    ret.InsertLast(String4(4116, "float",  "InputSteerDirection",        Round(Dev::GetOffsetFloat   (player, 4116), 0)));
    ret.InsertLast(String4(4120, "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 4120), 0)));
    ret.InsertLast(String4(4124, "float",  "InputBrakePedal",            Round(Dev::GetOffsetFloat   (player, 4124), 0)));
    // ret.InsertLast(String4(, , , ));
    // ret.InsertLast(String4(, , , ));
    // ret.InsertLast(String4(, , , ));
    // ret.InsertLast(String4(, , , ));
    // ret.InsertLast(String4(, , , ));

    /// 384, 416, 4112 key press?
    // 404, 436, 4132 mouse pos y?
    // 3572 cumulative rotation?
    // 3776, 3780 rotation radians?

    return ret;
}

#endif