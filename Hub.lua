-- execute once you entered the limbo
for i,v in pairs(workspace.RepressedMemories.RepressedMemoriesNPC.Head.Dialog: GetDescendants()) do
if v:IsA("DialogChoice") then 
if v:FindFirstChild("RightChoice") then 
v.UserDialog = "i don't know"

elseif v:FindFirstChild("FailChoice") then
v:Destroy()
end

end 
end
