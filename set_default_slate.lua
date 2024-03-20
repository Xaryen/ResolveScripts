local mediaPool = resolve:GetProjectManager():GetCurrentProject():GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()

function GetAllClipsInProject()
    local allClips = {}

    local function traverseFolders(folder)
        local clips = folder:GetClipList()
        for _, clip in ipairs(clips) do
            table.insert(allClips, clip)
        end

        local subFolders = folder:GetSubFolderList()
        for _, subFolder in ipairs(subFolders) do
            traverseFolders(subFolder)
        end
    end

    traverseFolders(rootFolder)

    return allClips
end


local allClips = GetAllClipsInProject()

for i, clip in ipairs(allClips) do
    print(i .. " " .. clip)
    --set mark In to 8 frames (how tho??)
end



