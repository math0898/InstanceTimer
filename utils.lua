InstanceTimer = {};
InstanceTimer.Utils = {};

function InstanceTimer.Utils.arrayContains(table, value)
    for i, val in ipairs(table) do
        if val == value then
            return true;
        end
    end
    return false;
end
