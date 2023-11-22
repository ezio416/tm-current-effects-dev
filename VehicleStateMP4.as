/*
c 2023-10-22
m 2023-10-22
*/

// code taken from VehicleState plugin to give deeper access in MP4

#if MP4

namespace VehicleStateMP4 {
    uint VehiclesOffset = 0x38;

    bool CheckValidVehicles(CSceneMgrVehicleVisImpl@ mgr) {
        if (mgr is null)
            return false;

        // Ensure this is a valid pointer
        uint64 ptr = Dev::GetOffsetUint64(mgr, VehiclesOffset);
        if ((ptr & 0xF) != 0)
            return false;

        // Assume we can't have more than 1000 vehicles
        uint count = Dev::GetOffsetUint32(mgr, VehiclesOffset + 0x8);
        if (count > 1000)
            return false;

        return true;
    }

    // Get all vehicle vis states. Mostly used for debugging.
    array<CMwNod@> GetAllVis(CGameScene@ sceneVis) {
        array<CMwNod@> ret;

        CSceneMgrVehicleVisImpl@ mgr = GetVehicleVisManager(sceneVis);

        if (mgr !is null && CheckValidVehicles(mgr)) {
            uint vehiclesCount = GetVisCount(mgr);

            for (uint i = 0; i < vehiclesCount; i++)
                ret.InsertLast(GetVisNodAt(mgr, i));
        }

        return ret;
    }

    CSceneMgrVehicleVisImpl@ GetVehicleVisManager(CGameScene@ scene) {
        if (scene is null || scene.MgrVehicleVis is null)
            return null;

        return scene.MgrVehicleVis.Impl;
    }

    uint GetVisCount(CSceneMgrVehicleVisImpl@ mgr) {
        uint count = Dev::GetOffsetUint32(mgr, VehiclesOffset + 0x8);

        // Assume we cannot have more than 1000 vehicles
        return (count <= 1000) ? count : 0;
    }

    // Get the raw vehicle vis at a particular index. (Note: not a real CMwNod.)
    CMwNod@ GetVisNodAt(CSceneMgrVehicleVisImpl@ mgr, uint index) {
        if (index >= GetVisCount(mgr))
            return null;

        CMwNod@ vehicles = Dev::GetOffsetNod(mgr, VehiclesOffset);

        return Dev::GetOffsetNod(vehicles, index * 0x8);
    }
}

#endif