local mediaPool = resolve:GetProjectManager():GetCurrentProject():GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()
local project = resolve:GetProjectManager():GetCurrentProject()
local TLClips = {}
local myTL = project:GetCurrentTimeline()


function PrintTable(tbl)
    for k, v in pairs(tbl) do
        if not v == nil then
            print(k .. " : " .. v)
        end
    end
end

function GetAllClipsInTimeline(TL)
    local trackCount = TL:GetTrackCount("Video")
    for i=1, trackCount, 1 do
        print(i)
        local g = TL:GetItemListInTrack("Video", i)

        for _, a in ipairs(g) do
            table.insert(TLClips, a)
        end
    end
end

GetAllClipsInTimeline(myTL)

PrintTable(TLClips)

for _, item in ipairs(TLClips) do
    local itemSrc = item:GetMediaPoolItem()
    local itemName = itemSrc:GetName()
    print(itemName)
end

-- GetItemListInTrack(trackType, index)

-- GetMediaPoolItem()

-- AddTake(mediaPoolItem, startFrame, endFrame)	Bool	Adds a new take to take selector. It will initialise this timeline item as take selector if it’s not already one. Arguments startFrame and endFrame are optional, and if not specified the entire clip will be added.
-- GetSelectedTakeIndex()	int	Returns the index of currently selected take, or 0 if the clip is not a take selector.
-- GetTakesCount()	int	Returns the number of takes in take selector, or 0 if the clip is not a take selector.
-- GetTakeByIndex(idx)	{takeInfo...}	Returns a dict (keys “startFrame”, “endFrame” and “mediaPoolItem”) with take info for specified index.
-- DeleteTakeByIndex(idx)	Bool	Deletes a take by index, 1 <= idx <= number of takes.
-- SelectTakeByIndex(idx)	Bool	Selects a take by index, 1 <= idx <= number of takes.
-- FinalizeTake()


--get all items in current timeline

--for each item get the relevant mediapoolitem

--check the allclips list for matching regex

--if it finds get highest version elseif get highest timing version 

