InstanceTimer.Database = {};
InstanceTimer.Database.persistentSave = {};

local run = {
    instance = "",
    class = "",
    segments = {
        233,
        432,
        9732;
    };
    segmentNames = {
        "First Boss",
        "Second Boss",
        "Third Boss"
    };
    finalTime = 8973;
};

local loaded = false;

function InstanceTimer.Database.IsLoaded()
    return loaded;
end

function InstanceTimer.Database.GetRun(instance, class)
    return nil; -- TODO: Implement
end

function InstanceTimer.Database.IsRunVaild(instance, class, segments, segmentNames, finalTime)
    return false; -- TODO: Implement
end

function InstanceTimer.Database.SaveRun(instance, class, segments, segmentNames, finalTime)
    if not InstanceTimer.Database.IsRunVaild(instance, class, segments, segmentNames, finalTime) then
        return -1; -- INVALID_RUN
    end -- TODO: Implement
end
