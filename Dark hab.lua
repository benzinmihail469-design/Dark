local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

print("=== Что внутри ===")
for k, v in pairs(lib) do
    print(k, "=>", typeof(v))
end
