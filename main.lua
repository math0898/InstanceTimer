local seconds = 0;
local segment = 0;
local splits = {};
local splitsNames = {};
local splitCount = 0;
local tenths = 0;
local courseName, iType, diffID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo();
local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(UnitGUID("player"));
local classR, classG, classB, classHex = GetClassColor(englishClass);
local bestTimes = {};
local bestTimesNames = {};
local bestsCount = 1;
local blacklistedZones = { "Eastern Kingdoms", "Kul Tiras", "Kalimdor", "Khaz Algar (Surface)", "Pandaria", "The Shadowlands", "Zereth Mortis", "Undermine", "Khaz Algar" }

local function incrementTimer()
    seconds = seconds + 1;
    segment = segment + 1;
end
C_Timer.NewTicker(1, incrementTimer);

local function incrementTenths()
    tenths = tenths + 1;
end
C_Timer.NewTicker(0.1, incrementTenths);

local activeFrame = CreateFrame("FRAME", "InstanceTimerRunningFrame", UIParent, "BasicFrameTemplateWithInset");
activeFrame:SetSize(200, 400);
activeFrame:SetPoint("CENTER", 850, 150);
activeFrame:RegisterForDrag("LeftButton");
activeFrame:SetMovable(true);
activeFrame:EnableMouse(true);
activeFrame:SetScript("OnDragStart", activeFrame.StartMoving);
activeFrame:SetScript("OnDragStop", activeFrame.StopMovingOrSizing);

activeFrame.title = activeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
activeFrame.title:SetPoint("TOP", 0, -5);
activeFrame.title:SetText(string.sub(courseName, 1, 18));
activeFrame.title:SetTextColor(classR, classG, classB);

activeFrame.mainTimer = activeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
activeFrame.mainTimer:SetSize(200, 50);
activeFrame.mainTimer:SetPoint("CENTER", 0, -175);
activeFrame.mainTimer:SetText("");

activeFrame.splitTimes = activeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
activeFrame.splitTimes:SetSize(200, 350);
activeFrame.splitTimes:SetPoint("RIGHT", -25, 150 - floor((splitCount * 12) / 2));
activeFrame.splitTimes:SetText("");
activeFrame.splitTimes:SetJustifyH("RIGHT");
if not InstanceTimer.Utils.arrayContains(blacklistedZones, courseName) then
    activeFrame:Show();
end

local function updateUI()
    activeFrame.mainTimer:SetText(string.format(" == %d:%02d.%d == ", seconds / 60, seconds % 60, tenths % 10));
    local s = "";
        for i = 1, splitCount do
        s = string.format(s .. splitsNames[i].. " > %d:%02d\n", splits[i] / 60, splits[i] % 60);
    end
    activeFrame.splitTimes:SetText(string.format(s .. " ---> %d:%02d", segment / 60, segment % 60));
    activeFrame.splitTimes:SetJustifyH("RIGHT");
end

C_Timer.NewTicker(0.05, updateUI);

--
-- Event Listeners
--

local function OnInstanceChangeListener(self, event, ...)
    local toSend = string.format("Last Instance: %dm, %02ds", seconds / 60, seconds % 60);
    for i = 1, splitCount do
        toSend = string.format(toSend .. "\nSegment: %dm, %02ds", splits[i] / 60, splits[i] % 60);
    end
    local inactiveFrame = CreateFrame("FRAME", "InstanceTimerResultFrame", UIParent, "BasicFrameTemplateWithInset");
    inactiveFrame:SetSize(200, 400);
    inactiveFrame:SetPoint("CENTER", 850, -250);
    inactiveFrame:SetMovable(true);
    inactiveFrame:RegisterForDrag("LeftButton");
    inactiveFrame:SetMovable(true);
    inactiveFrame:EnableMouse(true);
    inactiveFrame:SetScript("OnDragStart", inactiveFrame.StartMoving);
    inactiveFrame:SetScript("OnDragStop", inactiveFrame.StopMovingOrSizing);
    inactiveFrame.title = inactiveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    inactiveFrame.title:SetPoint("TOP", 0, -5);
    inactiveFrame.title:SetText(string.sub(courseName, 1, 18));
    inactiveFrame.title:SetTextColor(classR, classG, classB);
    inactiveFrame.mainTimer = inactiveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    inactiveFrame.mainTimer:SetSize(200, 50);
    inactiveFrame.mainTimer:SetPoint("CENTER", 0, -175);
    inactiveFrame.splitTimes = inactiveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    inactiveFrame.splitTimes:SetSize(200, 350);
    inactiveFrame.splitTimes:SetJustifyH("RIGHT");
    inactiveFrame.splitTimes:SetPoint("RIGHT", -25, 150 - floor((splitCount * 12) / 2));
    inactiveFrame.mainTimer:SetText(string.format(" == %d:%02d.%d == ", seconds / 60, seconds % 60, tenths % 10));
    local s = "";
        for i = 1, splitCount do
        s = string.format(s .. splitsNames[i].. " > %d:%02d\n", splits[i] / 60, splits[i] % 60);
    end
    inactiveFrame.splitTimes:SetText(string.format(s .. "Exit > %d:%02d", segment / 60, segment % 60));
    if not InstanceTimer.Utils.arrayContains(blacklistedZones, courseName) then
        inactiveFrame:Show();
    else
        inactiveFrame:Hide();
    end
    inactiveFrame.splitTimes:SetJustifyH("RIGHT");
    --
    -- Buggy
    --
    for i = 1, bestsCount do
        if bestTimesNames[i] == courseName then
            if bestTimes[i] > seconds then
                bestTimes[i] = seconds;
                inactiveFrame.mainTimer:SetTextColor(0.2, 0.8, 0.5);
            else 
                inactiveFrame.mainTimer:SetTextColor(0.8, 0.2, 0.3);
            end
        elseif i == bestsCount then
            bestTimes[i + 1] = seconds;
            bestTimesNames[i + 1] = courseName;
            bestsCount = bestsCount + 1;
            inactiveFrame.mainTimer:SetTextColor(0.2, 0.8, 0.5);
            break;
        end
    end
    --
    --
    --
    seconds = 0;
    segment = 0;
    splits = {};
    splitCount = 0;
    splitsNames = {};
    courseName, iType, diffID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo();
    activeFrame.title:SetText(string.sub(courseName, 1, 18));
    updateUI();
    if not InstanceTimer.Utils.arrayContains(blacklistedZones, courseName) then
        activeFrame:Show();
    else
        activeFrame:Hide();
    end
end

local function OnBossKillListener(self, event, encounterID, encounterName)
    -- message(string.format("Segment: %dm, %ds", segment / 60, segment % 60));
    splitCount = splitCount + 1;
    splits[splitCount] = segment;
    segment = 0;
    splitsNames[splitCount] = string.sub(encounterName, 1, 10);
    activeFrame.splitTimes:SetPoint("CENTER", 0, 150 - floor((splitCount * 12) / 2));
end

--
-- Registering Listeners
--

local frame = CreateFrame("FRAME", "InstanceTimerEnterWorldListenerFrame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", OnInstanceChangeListener);

local frame2 = CreateFrame("FRAME", "InstanceTimerKillBossListenerFrame");
frame2:RegisterEvent("BOSS_KILL");
frame2:SetScript("OnEvent", OnBossKillListener);
