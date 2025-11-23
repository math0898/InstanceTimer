if InstanceTimer == nil then
    InstanceTimer = {};
end
if InstanceTimer.Timer == nil then
    InstanceTimer.Timer = {};
end

-- Creates and the timer UI frame.
function InstanceTimer.Timer.CreateTimer (courseName, classRGB, splitCount)
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
    activeFrame.title:SetTextColor(classRGB.r, classRGB.g, classRGB.b);

    activeFrame.mainTimer = activeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    activeFrame.mainTimer:SetSize(200, 50);
    activeFrame.mainTimer:SetPoint("CENTER", 0, -175);
    activeFrame.mainTimer:SetText("");

    activeFrame.splitTimes = activeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    activeFrame.splitTimes:SetSize(200, 350);
    activeFrame.splitTimes:SetPoint("RIGHT", -25, 150 - floor((splitCount * 12) / 2));
    activeFrame.splitTimes:SetText("");
    activeFrame.splitTimes:SetJustifyH("RIGHT");

    -- activeFrame.splitTimes = {};
    -- for i = 1, splitCount do
    --     activeFrame.splitTimes[i] = activeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    --     activeFrame.splitTimes[i]:SetSize(200, 350);
    --     activeFrame.splitTimes[i]:SetPoint("RIGHT", -25, 150 - floor((i * 12) / 2));
    --     activeFrame.splitTimes[i]:SetText("");
    --     activeFrame.splitTimes[i]:SetJustifyH("RIGHT");
    -- end

    return activeFrame;
end
