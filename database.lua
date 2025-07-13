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

local frameLoadListener = CreateFrame("FRAME", "InstanceTimerDatabaseLoadListenerFrame");
frameLoadListener:RegisterEvent("ADDON_LOADED");
function frameLoadListener:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "InstanceTimer" then
        if InstanceTimerSaved == nil then
            print("Welcome to InstanceTimer! => " .. tostring(arg1));
            InstanceTimerSaved = true;
        else
            print("Welcome *back*! => " .. tostring(arg1));
        end
    end
end
frameLoadListener:SetScript("OnEvent", frameLoadListener.OnEvent);
