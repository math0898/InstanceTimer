InstanceTimer.Database = {};
InstanceTimer.Database.persistentSave = {};

local VERSION = "1.1";
local MAX_HISTORY_PER_DUNGEON = 50; -- Maximum number of runs to keep in history per dungeon/class

-- WoW Class List (English class names used by the game API)
local VALID_CLASSES = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT",
    "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID", "DEMONHUNTER", "EVOKER"
};

local loaded = false;

-- Initialize the saved variables structure if it doesn't exist
local function InitializeSavedVariables()
    if InstanceTimerSaved == nil then
        InstanceTimerSaved = {};
    end
    
    if InstanceTimerSaved.Version == nil then
        InstanceTimerSaved.Version = VERSION;
    end
    
    -- Data structure:
    -- InstanceTimerSaved.Data[dungeonName][className] = {
    --     personalBest = { finalTime = number, segments = {}, segmentNames = {}, date = string },
    --     bestSegments = { [segmentName] = number },
    --     history = { { finalTime = number, segments = {}, segmentNames = {}, date = string }, ... }
    -- }
    if InstanceTimerSaved.Data == nil then
        InstanceTimerSaved.Data = {};
    end
end

function InstanceTimer.Database.IsLoaded()
    return loaded;
end

-- Get the personal best run for a specific dungeon and class
function InstanceTimer.Database.GetRun(instance, class)
    if InstanceTimerSaved == nil or InstanceTimerSaved.Data == nil then
        return nil;
    end
    
    if InstanceTimerSaved.Data[instance] == nil then
        return nil;
    end
    
    if InstanceTimerSaved.Data[instance][class] == nil then
        return nil;
    end
    
    return InstanceTimerSaved.Data[instance][class].personalBest;
end

-- Get best segment time for a specific segment in a dungeon/class combination
function InstanceTimer.Database.GetBestSegment(instance, class, segmentName)
    if InstanceTimerSaved == nil or InstanceTimerSaved.Data == nil then
        return nil;
    end
    
    if InstanceTimerSaved.Data[instance] == nil then
        return nil;
    end
    
    if InstanceTimerSaved.Data[instance][class] == nil then
        return nil;
    end
    
    if InstanceTimerSaved.Data[instance][class].bestSegments == nil then
        return nil;
    end
    
    return InstanceTimerSaved.Data[instance][class].bestSegments[segmentName];
end

-- Get run history for a specific dungeon and class
function InstanceTimer.Database.GetHistory(instance, class)
    if InstanceTimerSaved == nil or InstanceTimerSaved.Data == nil then
        return {};
    end
    
    if InstanceTimerSaved.Data[instance] == nil then
        return {};
    end
    
    if InstanceTimerSaved.Data[instance][class] == nil then
        return {};
    end
    
    return InstanceTimerSaved.Data[instance][class].history or {};
end

-- Validate that a run has all required data
function InstanceTimer.Database.IsRunValid(instance, class, segments, segmentNames, finalTime)
    -- Check for nil values
    if instance == nil or instance == "" then
        return false;
    end
    
    if class == nil or class == "" then
        return false;
    end
    
    if finalTime == nil or finalTime <= 0 then
        return false;
    end
    
    -- Validate class is a valid WoW class
    local validClass = false;
    for _, validClassName in ipairs(VALID_CLASSES) do
        if validClassName == class then
            validClass = true;
            break;
        end
    end
    if not validClass then
        return false;
    end
    
    -- Segments and segment names should match in count if they exist
    if segments ~= nil and segmentNames ~= nil then
        if #segments ~= #segmentNames then
            return false;
        end
    end
    
    -- Check if this run has all segments from existing bestSegments
    -- This ensures we only accept complete runs that killed all bosses
    if InstanceTimerSaved ~= nil and InstanceTimerSaved.Data ~= nil then
        if InstanceTimerSaved.Data[instance] ~= nil and InstanceTimerSaved.Data[instance][class] ~= nil then
            local existingBestSegments = InstanceTimerSaved.Data[instance][class].bestSegments;
            if existingBestSegments ~= nil then
                -- Count how many segments are in bestSegments
                local expectedSegmentCount = 0;
                for _ in pairs(existingBestSegments) do
                    expectedSegmentCount = expectedSegmentCount + 1;
                end
                
                -- If there are existing best segments, the new run must have all of them
                if expectedSegmentCount > 0 then
                    if segments == nil or segmentNames == nil then
                        return false;
                    end
                    
                    if #segments < expectedSegmentCount then
                        return false;
                    end
                    
                    -- Check that all existing segment names are present in the new run
                    for existingSegmentName, _ in pairs(existingBestSegments) do
                        local found = false;
                        for i = 1, #segmentNames do
                            if segmentNames[i] == existingSegmentName then
                                found = true;
                                break;
                            end
                        end
                        if not found then
                            return false;
                        end
                    end
                end
            end
        end
    end
    
    return true;
end

-- Helper function to check if a run has all expected segments
local function IsRunComplete(runEntry, expectedSegmentNames)
    if runEntry == nil or runEntry.segmentNames == nil then
        return false;
    end
    
    if expectedSegmentNames == nil or #expectedSegmentNames == 0 then
        return true; -- No expected segments yet, so run is considered complete
    end
    
    if #runEntry.segmentNames < #expectedSegmentNames then
        return false;
    end
    
    -- Check that all expected segment names are present
    for _, expectedName in ipairs(expectedSegmentNames) do
        local found = false;
        for _, actualName in ipairs(runEntry.segmentNames) do
            if actualName == expectedName then
                found = true;
                break;
            end
        end
        if not found then
            return false;
        end
    end
    
    return true;
end

-- Save a run to the database
function InstanceTimer.Database.SaveRun(instance, class, segments, segmentNames, finalTime)
    if not InstanceTimer.Database.IsRunValid(instance, class, segments, segmentNames, finalTime) then
        return -1; -- INVALID_RUN
    end
    
    InitializeSavedVariables();
    
    -- Initialize dungeon entry if it doesn't exist
    if InstanceTimerSaved.Data[instance] == nil then
        InstanceTimerSaved.Data[instance] = {};
    end
    
    -- Initialize class entry if it doesn't exist
    if InstanceTimerSaved.Data[instance][class] == nil then
        InstanceTimerSaved.Data[instance][class] = {
            personalBest = nil,
            bestSegments = {},
            history = {}
        };
    end
    
    local classData = InstanceTimerSaved.Data[instance][class];
    
    -- Create run entry
    local runEntry = {
        finalTime = finalTime,
        segments = segments or {},
        segmentNames = segmentNames or {},
        date = date("%Y-%m-%d %H:%M:%S")
    };
    
    -- Update best segments first to establish what a complete run looks like
    if segments ~= nil and segmentNames ~= nil then
        for i = 1, #segments do
            local segmentName = segmentNames[i];
            local segmentTime = segments[i];
            
            if classData.bestSegments[segmentName] == nil or segmentTime < classData.bestSegments[segmentName] then
                classData.bestSegments[segmentName] = segmentTime;
            end
        end
    end
    
    -- Build list of expected segment names from bestSegments
    local expectedSegmentNames = {};
    for segmentName, _ in pairs(classData.bestSegments) do
        table.insert(expectedSegmentNames, segmentName);
    end
    
    -- Clean up incomplete runs from history
    local cleanedHistory = {};
    for _, historyRun in ipairs(classData.history) do
        if IsRunComplete(historyRun, expectedSegmentNames) then
            table.insert(cleanedHistory, historyRun);
        end
    end
    classData.history = cleanedHistory;
    
    -- Check if current PB is incomplete and reset if needed
    if classData.personalBest ~= nil and not IsRunComplete(classData.personalBest, expectedSegmentNames) then
        classData.personalBest = nil;
    end
    
    -- Check if this is a personal best
    local isPB = false;
    if classData.personalBest == nil or finalTime < classData.personalBest.finalTime then
        classData.personalBest = runEntry;
        isPB = true;
    end
    
    -- Add to history
    table.insert(classData.history, 1, runEntry); -- Insert at beginning for most recent first
    
    -- Trim history if it exceeds max
    if #classData.history > MAX_HISTORY_PER_DUNGEON then
        table.remove(classData.history, #classData.history); -- Remove oldest
    end
    
    return isPB and 1 or 0; -- Return 1 if PB, 0 if not
end

-- Get all personal bests for a specific class across all dungeons
function InstanceTimer.Database.GetAllPBsForClass(class)
    if InstanceTimerSaved == nil or InstanceTimerSaved.Data == nil then
        return {};
    end
    
    local pbs = {};
    for dungeonName, dungeonData in pairs(InstanceTimerSaved.Data) do
        if dungeonData[class] ~= nil and dungeonData[class].personalBest ~= nil then
            pbs[dungeonName] = dungeonData[class].personalBest;
        end
    end
    
    return pbs;
end

-- Get all best segments for a specific dungeon and class
function InstanceTimer.Database.GetAllBestSegments(instance, class)
    if InstanceTimerSaved == nil or InstanceTimerSaved.Data == nil then
        return {};
    end
    
    if InstanceTimerSaved.Data[instance] == nil then
        return {};
    end
    
    if InstanceTimerSaved.Data[instance][class] == nil then
        return {};
    end
    
    return InstanceTimerSaved.Data[instance][class].bestSegments or {};
end

-- Check if current segment time beats the best segment time
function InstanceTimer.Database.IsSegmentPB(instance, class, segmentName, segmentTime)
    local bestSegment = InstanceTimer.Database.GetBestSegment(instance, class, segmentName);
    
    if bestSegment == nil then
        return true; -- First time doing this segment
    end
    
    return segmentTime < bestSegment;
end

-- Get the sum of all best segments (theoretical best possible time)
function InstanceTimer.Database.GetSumOfBest(instance, class)
    local bestSegments = InstanceTimer.Database.GetAllBestSegments(instance, class);
    
    local sum = 0;
    for _, segmentTime in pairs(bestSegments) do
        sum = sum + segmentTime;
    end
    
    return sum;
end

local frameLoadListener = CreateFrame("FRAME", "InstanceTimerDatabaseLoadListenerFrame");
frameLoadListener:RegisterEvent("ADDON_LOADED");
function frameLoadListener:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "InstanceTimer" then
        InitializeSavedVariables();
        loaded = true;
        
        if InstanceTimerSaved.Version == VERSION then
            print("Welcome back. It's business as usual. *Cracks Knuckles*");
        else
            if InstanceTimerSaved.Version == nil then
                message("Welcome to instance timer!");
            else
                print("Welcome back to InstanceTimer! We've made a few changes here and there. Checkout our page to see what's new!"); -- TODO: Link
            end
            InstanceTimerSaved.Version = VERSION;
        end
    end
end
frameLoadListener:SetScript("OnEvent", frameLoadListener.OnEvent);
