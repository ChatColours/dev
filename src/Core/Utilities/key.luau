local system = {}
local API_Url = "https://stevehub.up.railway.app/api/"
local HttpService = game:GetService("HttpService")

local reasons = {
    ["KEY_NOT_FOUND"] = "This key does not exist.",
    ["KEY_EXPIRED"] = "The key has expired and is not available.",
    ["HWID_MISMATCH"] = "The key is linked to a different HWID",
    ["HWID_BANNED"] = "The HWID is banned from using this key.",
    ["INVALID_TIMESTAMP"] = "The timestamp provided is invalid.",
    ["ROBLOX_BANNED"] = "This account has been banned.",
    ["MEMBER_BANNED"] = "The user which generated this key is banned."
}

local function checkStructure(data)
    if data["Username"] and data["Userid"] and data["Hwid"] and data["Tick"] and data["Key license"] then
        return true
    else
        return false
    end
end

function system.Validate(data)
    assert(type(data) == "table", "Invalid data. Expected a table, got " .. type(data))
    assert(checkStructure(data), "Invalid data, missing required fields.")

    local Packet = HttpService:JSONEncode(data)
    local success, result = pcall(function()
        return request(
            {
                Url = API_Url .. "validate",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = Packet
            }
        )
    end)

    if not success or not result.Success then
        error("Failed to validate key: " .. (result and result.StatusCode or "Unknown error"))
        return false
    end

    local response = HttpService:JSONDecode(result.Body)
    if response.Approved then
        return {
            Approved = true,
            ClaimedAt = response.ClaimedAt,
            Hwid = response.Hwid,
            EndsAt = response.EndsAt
        }
    else
        return {Approved = false, Reason = reasons[response.Reason] or "An unknown error occurred."}
    end
end

return system