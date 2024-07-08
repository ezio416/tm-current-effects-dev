// c 2023-10-22
// m 2023-01-11

#if TMNEXT

int visStart = 0;
int visEnd = 10000;
int[] knownVisOffsets = {
    140, 144, 316, 320, 324, 328, 336, 348, 352, 356, 360, 364, 368, 372, 376, 380, 384, 388, 392, 396, 400, 404, 420, 424, 432, 440, 442, 443,
    472, 476, 480, 484, 488, 489, 492, 496, 500, 504, 508, 512,  // FL
    516, 520, 524, 528, 532, 533, 536, 540, 544, 548, 552, 556,  // FR
    560, 564, 568, 572, 576, 577, 580, 584, 588, 592, 596, 600,  // RR
    604, 608, 612, 616, 620, 621, 624, 628, 632, 636, 640, 644,  // RL
    672, 676, 680, 684, 688, 692, 696, 700, 704, 708, 712, 724, 732, 740, 744, 840, 864, 868, 872, 876, 1084, 1092, 1096, 1112, 1168, 1172,
    1176, 1180, 1184, 1188, 1192, 1196, 1200, 1204, 1208, 1212, 1216, 1220, 1224, 1228, 1240, 1244, 1248, 1252, 1256, 1260, 1264, 1268, 1272,
    1400, 1404, 1448, 1452, 1508, 1512, 1520, 1532
};
int[] observedVisOffsets = {
    1116, 1120, 1408, 1412, 1416, 1420, 1432, 1436, 1440, 1444
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

                        if (UI::BeginTabItem(i + "_" + model.Id.GetName())) {
                            if (UI::BeginTable(i + "-value-table", 4, UI::TableFlags::ScrollY)) {
                                UI::TableSetupColumn("offset(s)", UI::TableColumnFlags::WidthFixed, 145);
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

    ret.InsertLast(String4(316, "uint32", "TimeInMap?",      RoUnd(Dev::GetOffsetUint32(vis, 316))));
    ret.InsertLast(String4(732, "float",  "TurboTime",         Round(Dev::GetOffsetFloat (vis, 732), 2)));
    ret.InsertLast(String4(740, "uint32", "LastRespawn?",      RoUnd(Dev::GetOffsetUint32(vis, 740))));
    ret.InsertLast(String4(1084, "Int32", "FrontImpact?",       Round(Dev::GetOffsetInt32 (vis, 1084))));

    // 1116 some absolute value of speed
    // 1120 impact

    ret.InsertLast(String4(1240, "float", "FLIcing01",           Round(Dev::GetOffsetFloat (vis, 1240))));
    ret.InsertLast(String4(1244, "float", "FRIcing01",           Round(Dev::GetOffsetFloat (vis, 1244))));
    ret.InsertLast(String4(1248, "float", "RRIcing01",           Round(Dev::GetOffsetFloat (vis, 1248))));
    ret.InsertLast(String4(1252, "float", "RLIcing01",           Round(Dev::GetOffsetFloat (vis, 1252))));
    ret.InsertLast(String4(1256, "float", "FLSlipCoef",          Round(Dev::GetOffsetFloat (vis, 1256))));
    ret.InsertLast(String4(1260, "float", "FRSlipCoef",          Round(Dev::GetOffsetFloat (vis, 1260))));
    ret.InsertLast(String4(1264, "float", "RRSlipCoef",          Round(Dev::GetOffsetFloat (vis, 1264))));
    ret.InsertLast(String4(1268, "float", "RLSlipCoef",          Round(Dev::GetOffsetFloat (vis, 1268))));
    ret.InsertLast(String4(1272, "float", "InputGasPedal",       Round(Dev::GetOffsetFloat (vis, 1272), 0)));
    ret.InsertLast(String4(1532, "float", "TimeMovingForward?",  Round(Dev::GetOffsetInt32 (vis, 1532))));

    return ret;
}

String4[] GetKnownPlayerValues(CSmPlayer@ player) {
    String4[] ret;
    if (player is null) return ret;

    // ret.InsertLast(String4(388,  "float",  "InputSteerDirection",        Round(Dev::GetOffsetFloat   (player, 388),  0)));
    // ret.InsertLast(String4(392,  "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 392),  0)));
    // ret.InsertLast(String4(396,  "float",  "InputBrakePedal",            Round(Dev::GetOffsetFloat   (player, 396),  0)));
    // ret.InsertLast(String4(420,  "float",  "InputSteerDirection",        Round(Dev::GetOffsetFloat   (player, 420),  0)));
    // ret.InsertLast(String4(424,  "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 424),  0)));
    // ret.InsertLast(String4(428,  "float",  "InputBrakePedal",            Round(Dev::GetOffsetFloat   (player, 428),  0)));
    // ret.InsertLast(String4(468,  "int32",  "SpawnIndex",                 Round(Dev::GetOffsetInt32   (player, 468),  0)));
    // ret.InsertLast(String4(544,  "int32",  "EndTime",                    Round(Dev::GetOffsetInt32   (player, 544),  0)));
    // ret.InsertLast(String4(860,  "float",  "GetLinearHue",               Round(Dev::GetOffsetFloat   (player, 860),  6)));
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
    // ret.InsertLast(String4(3588, "vec3",   "Position",                   Round(Dev::GetOffsetVec3    (player, 3588), 3)));
    // ret.InsertLast(String4(3600, "vec3",   "Velocity",                   Round(Dev::GetOffsetVec3    (player, 3600), 3)));
    // ret.InsertLast(String4(3752, "vec3",   "Position",                   Round(Dev::GetOffsetVec3    (player, 3752), 3)));
    // ret.InsertLast(String4(3764, "vec3",   "AimDirection",               Round(Dev::GetOffsetVec3    (player, 3764), 3)));
    ret.InsertLast(String4(3784, "float",  "Upwardness",                 Round(Dev::GetOffsetFloat   (player, 3784), 3)));
    // ret.InsertLast(String4(3788, "float",  "FrontSpeed",                 Round(Dev::GetOffsetFloat   (player, 3788), 3)));
    // ret.InsertLast(String4(3792, "uint32", "DisplaySpeed",               Round(Dev::GetOffsetUint32  (player, 3792), 0)));
    // ret.InsertLast(String4(3796, "float",  "InputSteer",                 Round(Dev::GetOffsetFloat   (player, 3796), 1)));
    // ret.InsertLast(String4(3800, "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 3800), 0)));
    // ret.InsertLast(String4(3804, "uint32", "InputIsBraking",             Round(Dev::GetOffsetUint32  (player, 3804), 0)));
    // ret.InsertLast(String4(3808, "float",  "EngineRPM",                  Round(Dev::GetOffsetFloat   (player, 3808), 0)));
    // ret.InsertLast(String4(3812, "uint32", "EngineCurGear",              Round(Dev::GetOffsetUint32  (player, 3812), 0)));
    ret.InsertLast(String4(3816, "float",  "EngineTurboRatio",           Round(Dev::GetOffsetFloat   (player, 3816), 6)));
    // ret.InsertLast(String4(3824, "uint32", "WheelsContactCount",         Round(Dev::GetOffsetUint32  (player, 3824), 0)));
    // ret.InsertLast(String4(3828, "uint32", "WheelsSkiddingCount",        Round(Dev::GetOffsetUint32  (player, 3828), 0)));
    // ret.InsertLast(String4(3844, "uint32", "FlyingDuration",             Round(Dev::GetOffsetUint32  (player, 3844), 0)));
    // ret.InsertLast(String4(3856, "uint32", "SkiddingDuration",           Round(Dev::GetOffsetUint32  (player, 3856), 0)));
    // ret.InsertLast(String4(3860, "uint32", "HandicapNoGasDuration",      Round(Dev::GetOffsetUint32  (player, 3860), 0)));
    // ret.InsertLast(String4(3864, "uint32", "HandicapForceGasDuration",   Round(Dev::GetOffsetUint32  (player, 3864), 0)));
    // ret.InsertLast(String4(3868, "uint32", "HandicapNoBrakesDuration",   Round(Dev::GetOffsetUint32  (player, 3868), 0)));
    // ret.InsertLast(String4(3872, "uint32", "HandicapNoSteeringDuration", Round(Dev::GetOffsetUint32  (player, 3872), 0)));
    // ret.InsertLast(String4(3876, "uint32", "HandicapNoGripDuration",     Round(Dev::GetOffsetUint32  (player, 3876), 0)));
    // ret.InsertLast(String4(3880, "float",  "SkiddingDistance",           Round(Dev::GetOffsetFloat   (player, 3880), 3)));
    // ret.InsertLast(String4(3884, "float",  "FlyingDistance",             Round(Dev::GetOffsetFloat   (player, 3884), 3)));
    // ret.InsertLast(String4(3888, "float",  "Distance",                   Round(Dev::GetOffsetFloat   (player, 3888), 3)));
    // ret.InsertLast(String4(4116, "float",  "InputSteerDirection",        Round(Dev::GetOffsetFloat   (player, 4116), 0)));
    // ret.InsertLast(String4(4120, "float",  "InputGasPedal",              Round(Dev::GetOffsetFloat   (player, 4120), 0)));
    // ret.InsertLast(String4(4124, "float",  "InputBrakePedal",            Round(Dev::GetOffsetFloat   (player, 4124), 0)));

    /// 384, 416, 4112 key press?
    // 404, 436, 4132 mouse pos y?
    // 3572 cumulative rotation?
    // 3776, 3780 rotation radians?

    return ret;
}

#endif
