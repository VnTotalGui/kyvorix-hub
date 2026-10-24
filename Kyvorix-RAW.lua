-- KYVORIX / Client UI 6.1. Standalone client chunk or Studio LocalScript.
-- Presentation and read-only character data only; no gameplay manipulation.
-- All timings below are proposed adaptations; they are not measured shop timings.
-- Optional global KYVORIX_UI_CONFIG table uses the same keys as Studio attributes:
-- KyvorixAssetsAuthorized, KyvorixLogoAsset, KyvorixPortalAsset.
-- Use only image assets permitted for your experience; false is the safe default.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
assert(RunService:IsClient(), "KYVORIX UI must run on the Roblox client.")
if not game:IsLoaded() then game.Loaded:Wait() end
local player = Players.LocalPlayer
if not player then
	local deadline=os.clock()+15
	repeat task.wait(.1); player=Players.LocalPlayer until player or os.clock()>=deadline
end
assert(player, "KYVORIX UI: LocalPlayer unavailable after 15 seconds.")
local playerGui = player:WaitForChild("PlayerGui",15)
assert(playerGui, "KYVORIX UI: PlayerGui unavailable after 15 seconds.")
local hostScript=typeof(script)=="Instance" and script or nil
local options=type(KYVORIX_UI_CONFIG)=="table" and KYVORIX_UI_CONFIG or {}
local function readOption(name,fallback)
	if options[name]~=nil then return options[name] end
	if hostScript then
		local ok,value=pcall(function() return hostScript:GetAttribute(name) end)
		if ok and value~=nil then return value end
	end
	return fallback
end
local OWNER = "KYVORIX_CLIENT_6"
for _, child in playerGui:GetChildren() do
	if child:IsA("ScreenGui") and (child:GetAttribute("KyvorixOwner")==OWNER
		or child:GetAttribute("KyvorixOwner")=="KYVORIX_STUDIO_6" or child.Name=="Kyvorix") then child:Destroy() end
end
local C = {
	bg=Color3.fromRGB(7,11,27), panel=Color3.fromRGB(16,21,43),
	card=Color3.fromRGB(24,30,53), line=Color3.fromRGB(62,77,106),
	text=Color3.fromRGB(234,243,255), muted=Color3.fromRGB(186,199,219),
	cyan=Color3.fromRGB(0,225,238), purple=Color3.fromRGB(167,118,239),
}
local timings = {window=.24, hover=.14, page=.18}
local state = {open=false, fast=false, reduced=false, aura=true, palette=1}
local dead = false
local connections, tweens, delays = {}, {}, {}
local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end
local function later(seconds, callback)
	local thread
	thread = task.delay(seconds, function()
		delays[thread] = nil
		if not dead then callback() end
	end)
	delays[thread] = true
end
local function stop(object, finish)
	local entry = tweens[object]
	if not entry then return end
	tweens[object] = nil
	entry.connection:Disconnect()
	entry.tween:Cancel()
	if finish then for key,value in pairs(entry.goals) do object[key] = value end end
end
local function animate(object, goals, duration)
	stop(object, false)
	if state.fast or state.reduced then
		for key,value in pairs(goals) do object[key] = value end
		return
	end
	local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goals)
	local entry = {tween=tween, goals=goals}
	entry.connection = tween.Completed:Connect(function()
		if tweens[object] == entry then tweens[object] = nil end
		entry.connection:Disconnect()
	end)
	tweens[object] = entry
	tween:Play()
end
local function finishMotion()
	local objects = {}
	for object in pairs(tweens) do table.insert(objects, object) end
	for _,object in objects do stop(object, true) end
end
local function make(class, parent, props)
	local object = Instance.new(class)
	for key,value in pairs(props or {}) do object[key] = value end
	object.Parent = parent
	return object
end
local function corner(object, radius)
	return make("UICorner", object, {CornerRadius=UDim.new(0,radius or 12)})
end
local function frame(parent, color)
	return make("Frame", parent, {BackgroundColor3=color or C.card, BorderSizePixel=0})
end
local function rect(object,x,y,w,h)
	object.Position = UDim2.fromOffset(x,y)
	object.Size = UDim2.fromOffset(w,h)
end
local function text(parent, value, size, color, bold)
	return make("TextLabel",parent,{
		BackgroundTransparency=1, BorderSizePixel=0, Text=value, TextSize=size or 14,
		TextColor3=color or C.text, Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center,
		TextWrapped=true,
	})
end
local function border(object,color,transparency)
	return make("UIStroke",object,{Color=color or C.line,Transparency=transparency or .35,Thickness=1})
end
local gradients = {}
local function gradient(object)
	local g = make("UIGradient",object,{Color=ColorSequence.new(C.cyan,C.purple)})
	table.insert(gradients,g)
	return g
end
local gui = make("ScreenGui",playerGui,{
	Name="KyvorixClientUI",ResetOnSpawn=false,IgnoreGuiInset=false,
	DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
})
gui:SetAttribute("KyvorixOwner",OWNER)
local root = frame(gui); root.BackgroundTransparency=1; root.Size=UDim2.fromScale(1,1)
local scrim = make("TextButton",root,{
	Size=UDim2.fromScale(1,1),Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(3,6,15),
	BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=1,
})
local window = make("CanvasGroup",root,{
	AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(860,580),
	BackgroundColor3=C.bg,BorderSizePixel=0,GroupTransparency=1,Visible=false,Active=true,
	ClipsDescendants=true,ZIndex=2,
})
corner(window,16); border(window,C.cyan,.55)
local scale = make("UIScale",window,{Scale=1})
local background = frame(window,Color3.new(1,1,1)); background.Size=UDim2.fromScale(1,1)
make("UIGradient",background,{Rotation=130,Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,C.bg),ColorSequenceKeypoint.new(.6,Color3.fromRGB(23,14,43)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(8,28,39)),
})})
local grid = frame(window); grid.BackgroundTransparency=1; grid.Size=UDim2.fromScale(1,1)
for x=0,1100,40 do local line=frame(grid,C.line); line.BackgroundTransparency=.9; rect(line,x,0,1,900) end
for y=0,900,40 do local line=frame(grid,C.line); line.BackgroundTransparency=.9; rect(line,0,y,1100,1) end
local chrome=frame(window); chrome.BackgroundTransparency=1; chrome.Size=UDim2.fromScale(1,1); chrome.ZIndex=2
local toast = text(chrome,"",11,C.cyan); toast.ZIndex=10; toast.Visible=false
local toastVersion=0
local function notify(message)
	toastVersion+=1
	local version=toastVersion
	toast.Text=message; toast.Visible=true
	later(5,function() if toastVersion==version then toast.Visible=false end end)
end
local function button(parent,title,primary,callback)
	local b=make("TextButton",parent,{Text="",AutoButtonColor=false,BackgroundTransparency=1,Selectable=true})
	local fill=frame(b,primary and Color3.new(1,1,1) or C.card)
	fill.Size=UDim2.fromScale(1,1); corner(fill,9)
	if primary then gradient(fill) else border(fill) end
	local caption=text(fill,title,12,primary and C.bg or C.text,true)
	caption.Size=UDim2.new(1,-12,1,0); caption.Position=UDim2.fromOffset(6,0); caption.TextXAlignment=Enum.TextXAlignment.Center
	local press=make("UIScale",fill,{Scale=1})
	fill.AnchorPoint=Vector2.new(.5,.5); fill.Position=UDim2.fromScale(.5,.5)
	local function focus(on)
		local resting=b:GetAttribute("RestTransparency") or 0
		animate(fill,{BackgroundTransparency=on and .15 or resting},timings.hover)
	end
	connect(b.MouseEnter,function() focus(true) end); connect(b.MouseLeave,function() focus(false); animate(press,{Scale=1},timings.hover) end)
	connect(b.SelectionGained,function() focus(true) end); connect(b.SelectionLost,function() focus(false) end)
	connect(b.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(press,{Scale=.96},.08) end
	end)
	connect(b.InputEnded,function() animate(press,{Scale=1},timings.hover) end)
	connect(b.Activated,function()
		animate(press,{Scale=1},timings.hover)
		local ok,err=pcall(callback)
		if not ok then warn(err); notify("Không thể hoàn tất thao tác giao diện.") end
	end)
	return b,caption,fill
end
local authorized=readOption("KyvorixAssetsAuthorized",false)==true
local assetStates={}
local function imagePanel(parent,kind,id)
	local holder=frame(parent,C.bg); corner(holder,10)
	local image=make("ImageLabel",holder,{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ScaleType=Enum.ScaleType.Fit,Image="",Visible=false})
	local fallback=text(holder,"",11,C.muted)
	fallback.Position=UDim2.fromOffset(8,4); fallback.Size=UDim2.new(1,-16,1,-8); fallback.TextXAlignment=Enum.TextXAlignment.Center
	local raw=tostring(id or "")
	local number=raw:match("^rbxassetid://(%d+)$") or raw:match("^(%d+)$")
	local function status(value) assetStates[kind]=value; fallback.Text=kind..": "..value end
	if not authorized then status("chưa xác minh quyền ảnh")
	elseif not number then status("chưa cấu hình Roblox asset ID")
	else
		image.Image="rbxassetid://"..number
		status("đang tải ảnh")
		local settled=false
		local function finish(ok)
			-- A late successful load may recover after the finite error timeout.
			if dead or (settled and (not ok or image.Visible)) then return end
			settled=true; image.Visible=ok; fallback.Visible=not ok
			status(ok and "đã tải" or "tải lỗi; kiểm tra asset ID và quyền")
		end
		connect(image:GetPropertyChangedSignal("IsLoaded"),function() if image.IsLoaded then finish(true) end end)
		later(10,function() finish(image.IsLoaded) end)
		task.spawn(function()
			local ok=pcall(function() ContentProvider:PreloadAsync({image}) end)
			if dead then return end
			if image.IsLoaded then finish(true) elseif not ok then finish(false) end
		end)
	end
	return holder,image,fallback
end
local header=frame(chrome,C.panel)
local logo,_,logoFallback=imagePanel(header,"Logo",readOption("KyvorixLogoAsset","99762201965349"))
rect(logo,14,10,44,44); logoFallback.TextSize=7
local brand=text(header,"KYVORIX",21,C.text,true); rect(brand,70,9,190,27)
local tagline=text(header,"HUB / CLIENT UI",9,C.muted); rect(tagline,71,36,220,16)
local dragHandle=make("TextButton",header,{Text="",BackgroundTransparency=1,AutoButtonColor=false,Active=true})
local sidebar=frame(chrome,C.panel); corner(sidebar,12)
local sideCaption=text(sidebar,"KHÁM PHÁ",9,C.muted); rect(sideCaption,12,12,100,18)
local sideFoot=text(sidebar,"KYVORIX\nCLIENT UI",9,C.muted)
local marker=frame(sidebar,C.cyan); corner(marker,2)
local body=frame(chrome); body.BackgroundTransparency=1; body.ClipsDescendants=true
local footer=text(chrome,"KYVORIX UI  •  Dữ liệu nhân vật chỉ đọc",10,C.muted)
local names={"Điều khiển","Tiến trình","Chiến đấu","Thu thập","Biển & sự kiện","Di chuyển","Cài đặt","Tương thích"}
local pages,navs={},{}
local currentPage=names[1]
local refreshAmbient=function() end
local function page(name)
	local p=make("ScrollingFrame",body,{
		Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollBarThickness=3,
		ScrollBarImageColor3=C.cyan,Visible=name==currentPage,
	})
	make("UIPadding",p,{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,10),PaddingBottom=UDim.new(0,6)})
	make("UIListLayout",p,{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder})
	pages[name]=p
	return p
end
for _,name in names do page(name) end
local function card(parent,height,order)
	local c=frame(parent,C.panel); c.Size=UDim2.new(1,0,0,height); c.LayoutOrder=order or 1
	corner(c,13); border(c,C.line,.6)
	return c
end
local function fullLabel(parent,value,y,h,size,color,bold)
	local l=text(parent,value,size,color,bold)
	l.Position=UDim2.fromOffset(16,y); l.Size=UDim2.new(1,-32,0,h)
	return l
end
local setPage
setPage=function(name)
	if not pages[name] then return end
	currentPage=name
	for n,p in pairs(pages) do
		stop(p,true); p.Visible=n==name
		if n==name then
			p.Position=UDim2.fromOffset(7,0)
			animate(p,{Position=UDim2.fromOffset(0,0)},timings.page)
		end
	end
	for index,item in navs do
		item.button:SetAttribute("RestTransparency",names[index]==name and 0 or 1)
		stop(item.fill,false)
		item.fill.BackgroundTransparency=names[index]==name and 0 or 1
		item.caption.TextColor3=names[index]==name and C.text or C.muted
		if names[index]==name then animate(marker,{Position=UDim2.fromOffset(4,43+(index-1)*45)},timings.page) end
	end
	refreshAmbient()
end
for i,name in names do
	local b,caption,fill=button(sidebar,name,false,function() setPage(name) end)
	b.Position=UDim2.fromOffset(10,37+(i-1)*45); b.Size=UDim2.new(1,-20,0,39)
	caption.TextSize=11; caption.TextWrapped=true
	navs[i]={button=b,caption=caption,fill=fill}
end
marker.Size=UDim2.fromOffset(3,27); marker.ZIndex=3
local home=pages[names[1]]
local hero=card(home,278,1)
local eyebrow=text(hero,"HÀNH TRÌNH MỚI BẮT ĐẦU TỪ ĐÂY",9,C.cyan,true)
local h1=text(hero,"Chơi hết mình.",27,C.text,true)
local h2=text(hero,"Vươn tầm mới.",27,Color3.new(1,1,1),true); gradient(h2)
local intro=text(hero,"Mục tiêu của bạn. Hành trình của bạn. Khám phá các gói dịch vụ Roblox và theo dõi tiến độ, tất cả tại KYVORIX.",12,C.muted)
local primary=button(hero,"Khám phá KYVORIX",true,function() setPage("Tiến trình") end)
local secondary=button(hero,"Dịch vụ & tài khoản",false,function()
	setPage("Tương thích"); notify("Đăng nhập, đơn hàng và thanh toán đang chờ API được cấp quyền.")
end)
local portal=imagePanel(hero,"Cánh cổng",readOption("KyvorixPortalAsset",nil))
local orbitLayer=frame(hero); orbitLayer.BackgroundTransparency=1
local rings={}
for i=1,3 do
	local ring=frame(orbitLayer); ring.BackgroundTransparency=1; ring.AnchorPoint=Vector2.new(.5,.5); ring.Position=UDim2.fromScale(.5,.5)
	make("UICorner",ring,{CornerRadius=UDim.new(.5,0)})
	border(ring,i==2 and C.cyan or C.purple,.75)
	local dot=frame(ring,i==2 and C.cyan or C.purple); corner(dot,4); rect(dot,0,0,4,4)
	rings[i]=ring
end
local ambient={}
refreshAmbient=function()
	for _,tween in ambient do tween:Cancel() end
	table.clear(ambient)
	if dead or not state.open or state.fast or state.reduced or not state.aura or currentPage~="Điều khiển" then return end
	for i,ring in rings do
		local tween=TweenService:Create(ring,TweenInfo.new(48+i*12,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Rotation=ring.Rotation+(i%2==0 and -360 or 360)})
		table.insert(ambient,tween); tween:Play()
	end
end
local statsCard=card(home,98,2)
fullLabel(statsCard,"NHÂN VẬT CỦA BẠN",10,18,9,C.muted,true)
local statCells,statValues={},{}
for i,title in {"CẤP ĐỘ","BELI","FRAGMENTS","SỨC KHỎE"} do
	local cell=frame(statsCard,C.card); corner(cell,8)
	local titleLabel=text(cell,title,8,C.muted); rect(titleLabel,9,5,100,14)
	local value=text(cell,"Chưa có",14,C.text,true); value.Position=UDim2.fromOffset(9,21); value.Size=UDim2.new(1,-18,0,23)
	statCells[i]=cell; statValues[i]=value
end
local route=card(home,104,3)
fullLabel(route,"Mỗi hành trình có một bước bắt đầu.",12,22,14,C.text,true)
fullLabel(route,"Khám phá dịch vụ  /  Xác nhận phạm vi  /  Theo dõi tiến độ",44,42,12,C.muted)
local apiNotice=card(home,76,4)
fullLabel(apiNotice,"DỊCH VỤ ĐANG CHỜ KẾT NỐI",10,18,10,C.cyan,true)
fullLabel(apiNotice,"Đăng nhập, đơn hàng, hỗ trợ và thanh toán chưa có API được cấp quyền.",30,35,11,C.muted)
local descriptions={
	["Tiến trình"]="Chỉ số nhân vật được đọc trực tiếp ở trang Điều khiển. Tiến độ dịch vụ đang chờ API của shop.",
	["Chiến đấu"]="Chưa có callback chiến đấu hợp lệ cho experience này. Điều khiển gameplay chưa khả dụng.",
	["Thu thập"]="Chưa có dữ liệu thu thập hoặc callback được chủ experience cấp quyền.",
	["Biển & sự kiện"]="Chưa có nguồn dữ liệu sự kiện được cấp quyền. Chưa khả dụng.",
	["Di chuyển"]="Chưa có callback di chuyển được chủ experience cung cấp. Chưa khả dụng.",
}
for name,description in pairs(descriptions) do
	local c=card(pages[name],132)
	fullLabel(c,name,16,28,21,C.text,true)
	fullLabel(c,description,52,62,13,C.muted)
end
local settings=pages["Cài đặt"]
local controlUpdates={}
local function settingRow(order,title,description,getValue,callback)
	local c=card(settings,86,order)
	local titleLabel=text(c,title,13,C.text,true); titleLabel.Position=UDim2.fromOffset(14,12); titleLabel.Size=UDim2.new(1,-172,0,23)
	local desc=text(c,description,10,C.muted); desc.Position=UDim2.fromOffset(14,37); desc.Size=UDim2.new(1,-172,0,39)
	local b,caption=button(c,getValue(),false,callback)
	b.Position=UDim2.new(1,-146,0,23); b.Size=UDim2.fromOffset(132,38)
	table.insert(controlUpdates,function() caption.Text=getValue() end)
	return c
end
local function refreshControls() for _,update in controlUpdates do update() end end
local function applyEffects()
	if state.fast or state.reduced then finishMotion() end
	grid.Visible=not state.fast
	orbitLayer.Visible=state.aura and not state.fast
	refreshAmbient()
	refreshControls()
end
settingRow(1,"Giảm chuyển động","Bỏ chuyển cảnh và chuyển động nền.",function() return state.reduced and "Đang bật" or "Đang tắt" end,function()
	state.reduced=not state.reduced; applyEffects()
end)
settingRow(2,"Fastmode","Giảm trang trí; phản hồi giao diện tức thì.",function() return state.fast and "Đang bật" or "Đang tắt" end,function()
	state.fast=not state.fast; applyEffects()
end)
settingRow(3,"Aura","Vòng quỹ đạo trang trí quanh vùng ảnh gốc.",function() return state.aura and "Đang bật" or "Đang tắt" end,function()
	state.aura=not state.aura; applyEffects()
end)
local palettes={
	{Color3.fromRGB(0,225,238),Color3.fromRGB(167,118,239),"KYVORIX"},
	{Color3.fromRGB(101,228,187),Color3.fromRGB(105,169,250),"Aurora"},
	{Color3.fromRGB(244,156,112),Color3.fromRGB(199,130,240),"Hoàng hôn"},
}
local function applyPalette()
	local p=palettes[state.palette]
	local oldCyan,oldPurple=C.cyan,C.purple
	local function recolor(color)
		if color==oldCyan then return p[1] elseif color==oldPurple then return p[2] end
		return color
	end
	for _,object in gui:GetDescendants() do
		if object:IsA("GuiObject") then object.BackgroundColor3=recolor(object.BackgroundColor3) end
		if object:IsA("TextLabel") or object:IsA("TextButton") then object.TextColor3=recolor(object.TextColor3) end
		if object:IsA("UIStroke") then object.Color=recolor(object.Color) end
		if object:IsA("ScrollingFrame") then object.ScrollBarImageColor3=recolor(object.ScrollBarImageColor3) end
	end
	C.cyan=p[1]; C.purple=p[2]
	for _,g in gradients do g.Color=ColorSequence.new(C.cyan,C.purple) end
	marker.BackgroundColor3=C.cyan
	refreshControls()
end
settingRow(4,"Bảng màu","Giữ nhận diện mặc định hoặc chọn màu phụ.",function() return palettes[state.palette][3] end,function()
	state.palette=state.palette%#palettes+1; applyPalette()
end)
local function profile()
	return {version=1,reduced=state.reduced,fast=state.fast,aura=state.aura,palette=state.palette}
end
local function applyProfile(value)
	assert(type(value)=="table" and value.version==1,"Sai phiên bản hồ sơ")
	assert(type(value.reduced)=="boolean" and type(value.aura)=="boolean","Sai kiểu tùy chọn")
	assert(value.fast==nil or type(value.fast)=="boolean","Fastmode không hợp lệ")
	assert(type(value.palette)=="number" and value.palette%1==0 and palettes[value.palette],"Bảng màu không hợp lệ")
	state.reduced=value.reduced; state.aura=value.aura; state.fast=value.fast==true; state.palette=value.palette
	applyPalette(); applyEffects()
	return true
end
settingRow(5,"Lưu giao diện","Chỉ lưu trong phiên chơi hiện tại.",function() return "Lưu phiên" end,function()
	playerGui:SetAttribute("KyvorixSessionProfile",HttpService:JSONEncode(profile())); notify("Đã lưu cài đặt trong phiên chơi.")
end)
settingRow(6,"Khôi phục giao diện","Đọc hồ sơ đã lưu trong PlayerGui.",function() return "Khôi phục" end,function()
	local raw=playerGui:GetAttribute("KyvorixSessionProfile")
	if type(raw)~="string" or #raw>4096 then notify("Chưa có hồ sơ hợp lệ trong phiên."); return end
	local ok=pcall(function() applyProfile(HttpService:JSONDecode(raw)) end)
	notify(ok and "Đã khôi phục giao diện." or "Hồ sơ không hợp lệ; giữ nguyên cài đặt.")
end)
settingRow(7,"Đặt lại giao diện","Khôi phục bảng màu và hiệu ứng mặc định.",function() return "Đặt lại" end,function()
	applyProfile({version=1,reduced=false,fast=false,aura=true,palette=1})
end)
settingRow(9,"Hủy giao diện","Giải phóng sự kiện và hiệu ứng của HUB.",function() return "Hủy UI" end,function() gui:Destroy() end)
local diagnosticsCard=card(pages["Tương thích"],220)
fullLabel(diagnosticsCard,"KẾT NỐI & TÀI NGUYÊN",14,24,17,C.text,true)
local diagnosticText=fullLabel(diagnosticsCard,"",46,120,11,C.muted)
local function diagnostics()
	return {
		build="KYVORIX Client UI 6.1", environment=RunService:IsStudio() and "Roblox Studio" or "Roblox client",
		assetsAuthorized=authorized, assets=assetStates, webAPI="Chưa kết nối",
		fast=state.fast,reduced=state.reduced,page=currentPage,
	}
end
local printButton=button(diagnosticsCard,"In chẩn đoán vào Output",false,function()
	print(HttpService:JSONEncode(diagnostics())); notify("Đã in chẩn đoán giao diện vào Output.")
end)
printButton.Position=UDim2.fromOffset(16,174); printButton.Size=UDim2.new(1,-32,0,32)
local sourceNotice=card(pages["Tương thích"],100,2)
fullLabel(sourceNotice,"Quyền sử dụng ảnh",12,22,14,C.text,true)
fullLabel(sourceNotice,"Chỉ dùng asset được phép cho experience của bạn. Link Blox Fruits không xác nhận quyền chỉnh sửa hoặc quyền dùng ảnh.",38,50,11,C.muted)
local width,height,fitScale=860,580,1
local compact=false
local function layout()
	local viewport=root.AbsoluteSize
	if viewport.X<1 or viewport.Y<1 then return end
	local small=viewport.X<660
	if small~=compact then compact=small; width=small and 520 or 860; height=small and 660 or 580 end
	local side=compact and 100 or 132
	fitScale=math.min(1,viewport.X*.84/width,viewport.Y*.84/height)
	window.Size=UDim2.fromOffset(width,height); scale.Scale=fitScale
	header.Size=UDim2.new(1,0,0,64)
	dragHandle.Position=UDim2.fromOffset(65,0); dragHandle.Size=UDim2.new(1,-207,1,0)
	rect(sidebar,12,76,side,height-118); sideFoot.Position=UDim2.new(0,12,1,-44); sideFoot.Size=UDim2.new(1,-24,0,34)
	rect(body,side+24,76,width-side-38,height-156)
	rect(footer,side+26,height-29,width-side-50,20)
	rect(toast,side+26,height-72,width-side-50,34)
	local cw=width-side-50
	local columns=cw>=590
	local artWidth=columns and math.floor(cw*.40) or math.min(280,cw-40)
	local artHeight=artWidth*2/3
	hero.Size=UDim2.new(1,0,0,columns and 278 or 268+artHeight)
	local textWidth=columns and cw-artWidth-40 or cw-36
	rect(eyebrow,18,17,textWidth,22); rect(h1,18,48,textWidth,37); rect(h2,18,84,textWidth,37)
	rect(intro,18,131,textWidth,64)
	rect(primary,18,214,math.floor((textWidth-8)/2),40)
	rect(secondary,22+math.floor(textWidth/2),214,math.floor((textWidth-8)/2),40)
	local artX=columns and cw-artWidth-10 or (cw-artWidth)/2
	local artY=columns and (278-artHeight)/2 or 265
	rect(portal,artX,artY,artWidth,artHeight); rect(orbitLayer,artX,artY,artWidth,artHeight)
	for i,ring in rings do
		local diameter=artHeight*(.78+i*.12)
		ring.Size=UDim2.fromOffset(diameter,diameter)
	end
	local cellWidth=(cw-40)/4
	for i,cell in statCells do rect(cell,14+(i-1)*(cellWidth+4),34,cellWidth,52) end
	local p=window.Position
	local halfX,halfY=width*fitScale/2,height*fitScale/2
	local x=p.X.Scale*viewport.X+p.X.Offset
	local y=p.Y.Scale*viewport.Y+p.Y.Offset
	local mx,my=math.min(4,viewport.X*.04),math.min(4,viewport.Y*.04)
	window.Position=UDim2.fromOffset(math.clamp(x,halfX+mx,viewport.X-halfX-mx),math.clamp(y,halfY+my,viewport.Y-halfY-my))
end
local openVersion=0
local drag,resize
local launcher
local function setOpen(value)
	openVersion+=1
	local version=openVersion
	state.open=value
	if not value then drag=nil; resize=nil end
	if launcher then launcher.Visible=not value end
	refreshAmbient()
	if value then
		local wasVisible=window.Visible
		finishMotion(); layout(); window.Visible=true; scrim.Visible=true
		if not wasVisible then scale.Scale=fitScale*.94; window.GroupTransparency=1 end
		animate(scale,{Scale=fitScale},timings.window)
		animate(window,{GroupTransparency=0},timings.window)
		animate(scrim,{BackgroundTransparency=.45},timings.window)
	else
		finishMotion()
		animate(window,{GroupTransparency=1},timings.window)
		animate(scale,{Scale=fitScale*.94},timings.window)
		animate(scrim,{BackgroundTransparency=1},timings.window)
		later((state.fast or state.reduced) and 0 or timings.window,function()
			if openVersion==version and not state.open then window.Visible=false; scrim.Visible=false end
		end)
	end
end
local minimize=button(header,"Ẩn",false,function() setOpen(false) end)
minimize.AnchorPoint=Vector2.new(1,0); minimize.Position=UDim2.new(1,-66,0,16); minimize.Size=UDim2.fromOffset(50,32)
local close=button(header,"Đóng",false,function() setOpen(false) end)
close.AnchorPoint=Vector2.new(1,0); close.Position=UDim2.new(1,-10,0,16); close.Size=UDim2.fromOffset(50,32)
launcher=button(root,"KYVORIX  /  MỞ HUB",true,function() setOpen(true) end)
launcher.ZIndex=3; launcher.Position=UDim2.fromOffset(12,12); launcher.Size=UDim2.fromOffset(170,36)
local grip=make("TextButton",chrome,{Text="↘",TextColor3=C.muted,TextSize=19,BackgroundTransparency=1,Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,-31,1,-31)})
local sizeCard=card(settings,82,8)
fullLabel(sizeCard,"Kích thước cửa sổ",10,22,13,C.text,true)
local smaller=button(sizeCard,"Thu gọn",false,function() width=math.max(520,width-80); height=math.max(560,height-40); layout() end)
rect(smaller,14,41,130,29)
local larger=button(sizeCard,"Phóng lớn",false,function() width=math.min(1060,width+80); height=math.min(780,height+40); layout() end)
larger.Position=UDim2.new(1,-144,0,41); larger.Size=UDim2.fromOffset(130,29)
local function pointer(input) return Vector2.new(input.Position.X,input.Position.Y)-root.AbsolutePosition end
local function startsPointer(input)
	return input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch
end
connect(dragHandle.InputBegan,function(input)
	if startsPointer(input) then finishMotion(); drag={input=input,point=pointer(input),position=window.Position} end
end)
connect(grip.InputBegan,function(input)
	if startsPointer(input) then finishMotion(); resize={input=input,point=pointer(input),width=width,height=height,scale=fitScale} end
end)
connect(UIS.InputChanged,function(input)
	local moving=input.UserInputType==Enum.UserInputType.MouseMovement
	if drag and ((moving and drag.input.UserInputType==Enum.UserInputType.MouseButton1) or input==drag.input) then
		local delta=pointer(input)-drag.point
		window.Position=drag.position+UDim2.fromOffset(delta.X,delta.Y); layout()
	elseif resize and ((moving and resize.input.UserInputType==Enum.UserInputType.MouseButton1) or input==resize.input) then
		local delta=(pointer(input)-resize.point)/resize.scale
		width=math.clamp(resize.width+delta.X,520,1060); height=math.clamp(resize.height+delta.Y,560,780); layout()
	end
end)
connect(UIS.InputEnded,function(input)
	if drag and (input==drag.input or input.UserInputType==Enum.UserInputType.MouseButton1) then drag=nil end
	if resize and (input==resize.input or input.UserInputType==Enum.UserInputType.MouseButton1) then resize=nil end
end)
connect(UIS.WindowFocusReleased,function() drag=nil; resize=nil end)
connect(UIS.InputBegan,function(input,processed)
	if not processed and (input.KeyCode==Enum.KeyCode.RightShift or input.KeyCode==Enum.KeyCode.RightControl) then setOpen(not state.open) end
end)
connect(root:GetPropertyChangedSignal("AbsoluteSize"),function() finishMotion(); layout() end)
local function readData(name)
	local folder=player:FindFirstChild("Data")
	local value=folder and folder:FindFirstChild(name)
	if value and value:IsA("ValueBase") then
		local ok,result=pcall(function() return value.Value end)
		if ok and (type(result)=="number" or type(result)=="string") then return tostring(result) end
	end
	return "Chưa có"
end
local function updateData()
	statValues[1].Text=readData("Level"); statValues[2].Text=readData("Beli"); statValues[3].Text=readData("Fragments")
	local character=player.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	statValues[4].Text=humanoid and string.format("%.0f / %.0f",humanoid.Health,humanoid.MaxHealth) or "Chưa có"
	diagnosticText.Text="Client UI 6.1  •  "..(RunService:IsStudio() and "Roblox Studio" or "Roblox client")
		.."\nLogo: "..(assetStates.Logo or "chưa kiểm tra")
		.."\nCánh cổng: "..(assetStates["Cánh cổng"] or "chưa kiểm tra")
		.."\nAPI shop: chưa kết nối. Không có dữ liệu đơn hàng giả lập."
end
local elapsed=0
connect(RunService.RenderStepped,function(dt)
	if not state.open then return end
	elapsed+=dt
	if elapsed>=1 then elapsed=0; updateData() end
end)
local applyHook=make("BindableFunction",gui,{Name="ApplyUIProfile"})
applyHook.OnInvoke=function(value) return pcall(applyProfile,value) end
local diagnosticHook=make("BindableFunction",gui,{Name="GetUIDiagnostics"})
diagnosticHook.OnInvoke=diagnostics
local function cleanup()
	if dead then return end
	dead=true
	for _,tween in ambient do tween:Cancel() end
	table.clear(ambient)
	for _,connection in connections do connection:Disconnect() end
	local objects={}
	for object in pairs(tweens) do table.insert(objects,object) end
	for _,object in objects do stop(object,false) end
	for thread in pairs(delays) do pcall(task.cancel,thread) end
	table.clear(delays); table.clear(connections)
	applyHook.OnInvoke=nil; diagnosticHook.OnInvoke=nil
end
connect(gui.Destroying,cleanup)
-- Remote chunks do not necessarily have a LocalScript instance.
-- In executor environments, cleanup belongs to our ScreenGui, not a host stub.
if RunService:IsStudio() and hostScript and hostScript:IsA("LocalScript") then
	connect(hostScript.Destroying,function() if gui.Parent then gui:Destroy() else cleanup() end end)
end
setPage(currentPage); applyEffects(); updateData(); layout(); setOpen(true)
