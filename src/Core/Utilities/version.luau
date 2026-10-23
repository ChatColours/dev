local HttpService = game:GetService("HttpService")

local function GetLatestCommit(Owner, Repo, Branch)
    Branch = Branch or "main"

    local URL = string.format(
        "https://api.github.com/repos/%s/%s/commits/%s",
        Owner,
        Repo,
        Branch
    )

    local Success, Result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(URL))
    end)

    if not Success then
        warn("Failed to fetch commit:", Result)
        return nil
    end

    return Result.sha
end

return GetLatestCommit("ChatColours", "dev")