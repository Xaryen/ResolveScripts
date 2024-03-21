local mediaPool = resolve:GetProjectManager():GetCurrentProject():GetMediaPool()
local project = resolve:GetProjectManager():GetCurrentProject()
local timelineClips = {}
local timeline = project:GetCurrentTimeline()
local rootFolder = mediaPool:GetRootFolder()


function PrintTable(tbl)
    for k, v in pairs(tbl) do
        if not v == nil then
            print(k .. " : " .. v)
        end
    end
end

local function compareFileNames(name1, name2)
    -- Function to extract version type and number from a file name
    local function extractVersionTypeAndNumber(fileName)
        local versionType, versionNumber = fileName:match("(%u+)_V(%d+)")
        return versionType, tonumber(versionNumber)
    end

    name1 = name1:GetName()
    name2 = name2:GetName()

    local type1, number1 = extractVersionTypeAndNumber(name1)
    local type2, number2 = extractVersionTypeAndNumber(name2)

    -- Define order of version types
    local typeOrder = { MAIN = 1, TIMING = 2, LINE = 3, PREVIZ = 4 }

    -- Compare version types
    if typeOrder[type1] < typeOrder[type2] then
        return true
    elseif typeOrder[type1] > typeOrder[type2] then
        return false
    end

    -- If version types are the same, compare version numbers (in reverse order)
    return number1 > number2
end

function GetAllClipsInProject()
    local allClips = {}

    -- Recursive function to traverse folders
    local function traverseFolders(folder)
        -- Get and add all clips in the current folder
        local clips = folder:GetClipList()
        for _, clip in ipairs(clips) do
            table.insert(allClips, clip)
        end

        -- Recurse into subfolders
        local subFolders = folder:GetSubFolderList()
        for _, subFolder in ipairs(subFolders) do
            traverseFolders(subFolder)
        end
    end

    -- Start the recursive traversal from the root folder
    traverseFolders(rootFolder)

    return allClips
end

function TrimName(fileName)
    local parts = {}
    
    -- Split the file name by underscores
    for part in fileName:gmatch("[^_]+") do
        table.insert(parts, part)
    end
    
    -- Remove last two parts
    local partsToRemove = math.min(#parts, 2)
    for i = 1, partsToRemove do
        table.remove(parts)
    end
    -- Concatenate remaining parts back into a string
    fileName = table.concat(parts, "_")
    --print(fileName)
    return fileName
end

local projectClips = GetAllClipsInProject();
local projectClipsTrimmed = {}

for _, clip in ipairs(projectClips) do
    local clipName = clip:GetName()
    clipName = TrimName(clipName)
    table.insert(projectClipsTrimmed, clipName)
end

function GetAllClipsInTimeline(TL)
    local trackCount = TL:GetTrackCount("Video")
    for i=1, trackCount, 1 do
        print(i)
        local g = TL:GetItemListInTrack("Video", i)

        for _, a in ipairs(g) do
            table.insert(timelineClips, a)
        end
    end
end


function FindTakes(item)
    local takes = {}
    local itemName = item:GetName()
    local trimmedItemName = TrimName(itemName)
    
    print(itemName)
    
    for i, trimmedClipName in ipairs(projectClipsTrimmed) do
        
        if trimmedClipName == trimmedItemName then
            print(projectClips[i]:GetName())
            print("match!")
            table.insert(takes, projectClips[i])
        end

    end

   return takes
end


GetAllClipsInTimeline(timeline)

PrintTable(timelineClips)

for _, item in ipairs(timelineClips) do
    local itemSrc = item:GetMediaPoolItem()
    local itemName = itemSrc:GetName()
    print("current item: " .. itemName)

    local myTakes = FindTakes(itemSrc)

    print("---------------------------------")
    for _, take in ipairs(myTakes) do
        local takeName = take:GetName()
        print(takeName)
    end

    table.sort(myTakes, compareFileNames)

    print(#myTakes)

    --since there's no way to replace source media (even though the conform lock button in the UI does that)
    --we use the take selector to load all the takes then select the newest one 

    for i=#myTakes, 1, -1 do
        item:AddTake(myTakes[i], 8)
        print("added take")

        
    end
    
    print(myTakes[1]:GetName())

    print(itemName)

    if not (myTakes[1]:GetName() == itemName) then
        item:SelectTakeByIndex(#myTakes)
    end

    -- local d = item:GetTakeByIndex(1)

    -- print(d["mediaPoolItem"]:GetName())

    --disabled for now
    --item:FinalizeTake() 

end





-- GetSelectedTakeIndex()	int	Returns the index of currently selected take, or 0 if the clip is not a take selector.
-- GetTakeByIndex(idx)	{takeInfo...}	Returns a dict (keys “startFrame”, “endFrame” and “mediaPoolItem”) with take info for specified index.
-- GetTakesCount()	int	Returns the number of takes in take selector, or 0 if the clip is not a take selector.


