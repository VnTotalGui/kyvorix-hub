-- KYVORIX / CYBER CHROMA 7.0
-- Standalone client UI; no gameplay automation, hooks or protection bypass.
-- Optional KYVORIX_UI_CONFIG: Language, RightInset, KyvorixLogoAsset,
-- KyvorixPortalAsset, KyvorixAssetsAuthorized, LocalArtwork.
-- Original artwork is downloaded as PNG data only from the owner's repository.
-- Proposed Studio/client animation timings; not a pixel-exact web reproduction.
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local ContentProvider=game:GetService("ContentProvider")
local HttpService=game:GetService("HttpService")
assert(RunService:IsClient(),"KYVORIX must run on the client.")
local player=Players.LocalPlayer
local timeout=os.clock()+15
while not player and os.clock()<timeout do task.wait(.1); player=Players.LocalPlayer end
assert(player,"KYVORIX: LocalPlayer unavailable.")
local playerGui=player:WaitForChild("PlayerGui",15)
assert(playerGui,"KYVORIX: PlayerGui unavailable.")
local host=typeof(script)=="Instance" and script or nil
local config=type(KYVORIX_UI_CONFIG)=="table" and KYVORIX_UI_CONFIG or {}
local function option(key,fallback)
	if config[key]~=nil then return config[key] end
	if host then local ok,v=pcall(function() return host:GetAttribute(key) end); if ok and v~=nil then return v end end
	return fallback
end
for _,child in playerGui:GetChildren() do
	if child:IsA("ScreenGui") and (child:GetAttribute("KyvorixOwner")=="KYVORIX_CLIENT_6"
		or child:GetAttribute("KyvorixOwner")=="KYVORIX_CLIENT_7" or child:GetAttribute("KyvorixOwner")=="KYVORIX_STUDIO_6"
		or child.Name=="Kyvorix") then child:Destroy() end
end
local S={
	language="en",mode="HUB",page="home",transitioning=false,fast=false,reduced=false,aura=true,
	particles=true,palette=1,dead=false,epoch=0,hubCenter=nil,hubSize=nil,
}
local savedLanguage=playerGui:GetAttribute("KyvorixLanguage")
if savedLanguage=="en" or savedLanguage=="vi" then S.language=savedLanguage
elseif option("Language","en")=="vi" then S.language="vi" end
local C={
	bg=Color3.fromRGB(4,7,20),panel=Color3.fromRGB(10,16,36),card=Color3.fromRGB(17,24,46),
	line=Color3.fromRGB(49,66,96),text=Color3.fromRGB(234,243,255),muted=Color3.fromRGB(179,198,221),
	cyan=Color3.fromRGB(0,235,245),purple=Color3.fromRGB(167,101,246),pink=Color3.fromRGB(255,60,151),
	gold=Color3.fromRGB(246,204,72),
}
local L={
	home={"Dashboard","Điều khiển"},progress={"Progress","Tiến trình"},combat={"Combat","Chiến đấu"},
	collect={"Collection","Thu thập"},events={"Sea & Events","Biển & sự kiện"},travel={"Travel","Di chuyển"},
	settings={"Settings","Cài đặt"},system={"Connections","Kết nối"},
	explore={"YOUR UNIVERSE","VŨ TRỤ CỦA BẠN"},edition={"CYBER CHROMA / HUB","CYBER CHROMA / HUB"},
	eyebrow={"YOUR NEXT JOURNEY STARTS HERE","HÀNH TRÌNH MỚI BẮT ĐẦU TỪ ĐÂY"},
	headline1={"Play your best.","Chơi hết mình."},headline2={"Reach new heights.","Vươn tầm mới."},
	intro={"Your goals. Your journey. One KYVORIX space for your interface, character insights and what comes next.",
		"Mục tiêu của bạn. Hành trình của bạn. Một không gian KYVORIX cho giao diện, chỉ số nhân vật và bước tiếp theo."},
	discover={"Explore your hub","Khám phá HUB"},personalize={"Make it yours","Tùy chỉnh ngay"},
	nextworld={"KYVORIX / NEXT WORLD","KYVORIX / NEXT WORLD"},world={"Your next world awaits.","Thế giới mới đang chờ."},
	chapter={"THE NEXT CHAPTER","CHƯƠNG TIẾP THEO"},ready={"Ready when you are.","Sẵn sàng cùng bạn."},
	character={"YOUR CHARACTER","NHÂN VẬT CỦA BẠN"},level={"LEVEL","CẤP ĐỘ"},beli={"BELI","BELI"},
	fragments={"FRAGMENTS","FRAGMENTS"},health={"HEALTH","SỨC KHỎE"},unavailable={"Not available","Chưa có"},
	live={"READ-ONLY / LIVE","CHỈ ĐỌC / TRỰC TIẾP"},workspace={"Your space. Your pace.","Không gian của bạn. Nhịp điệu của bạn."},
	workspaceDesc={"Tune your colors and motion. Keep what matters in KYVORIX STATUS.","Chọn màu sắc, chuyển động và theo dõi những gì cần thiết trong KYVORIX STATUS."},
	toStatus={"Show compact status","Mở status nhỏ gọn"},themeTag={"CHROME / CYAN / MAGENTA","CHROME / CYAN / MAGENTA"},
	pending={"NOT CONNECTED","CHƯA KẾT NỐI"},
	pendingDesc={"This page has no authorized gameplay callback. No action is started by opening it.","Trang này chưa có callback gameplay được cấp quyền. Mở trang không chạy tác vụ nào."},
	progressDesc={"Character data updates on the dashboard. Shop order tracking is waiting for an authorized API.","Chỉ số nhân vật cập nhật trên trang chính. Theo dõi đơn hàng đang chờ API được cấp quyền."},
	settingsDesc={"A little more you. Every change updates your status instantly.","Mang dấu ấn của bạn. Mọi thay đổi cập nhật vào status ngay."},
	reduced={"Reduced motion","Giảm chuyển động"},reducedDesc={"Instant transitions and no ambient movement.","Chuyển trạng thái tức thì và dừng chuyển động nền."},
	fast={"Fastmode","Fastmode"},fastDesc={"Less decoration, lighter interface, immediate feedback.","Giảm trang trí, giao diện nhẹ hơn và phản hồi tức thì."},
	aura={"Aura & orbits","Aura & quỹ đạo"},auraDesc={"Layered cyan and magenta light around your artwork.","Ánh sáng cyan và magenta nhiều lớp quanh ảnh gốc."},
	particles={"Ambient sparks","Hạt sáng nền"},particlesDesc={"A small pooled field of softly moving highlights.","Các điểm sáng chuyển động nhẹ, được giới hạn số lượng."},
	palette={"Color story","Bảng màu"},paletteDesc={"Change the accent colors across the entire hub.","Đổi màu nhấn trên toàn bộ HUB."},
	on={"ON","BẬT"},off={"OFF","TẮT"},sunset={"Sunset","Hoàng hôn"},
	language={"Hub language","Ngôn ngữ HUB"},languageDesc={"English by default. Switch every page to Vietnamese.","Tiếng Anh mặc định. Đổi mọi trang sang tiếng Việt."},
	save={"Save session","Lưu trong phiên"},saveDesc={"Store interface preferences for this play session.","Lưu tùy chọn giao diện trong phiên chơi hiện tại."},
	restore={"Restore session","Khôi phục phiên"},restoreDesc={"Restore your saved interface preferences.","Khôi phục tùy chọn giao diện đã lưu."},
	reset={"Reset appearance","Đặt lại giao diện"},resetDesc={"Restore colors and effects without changing language.","Khôi phục màu và hiệu ứng, giữ ngôn ngữ hiện tại."},
	size={"Window size","Kích thước cửa sổ"},sizeDesc={"Resize with the lower-right corner or these controls.","Kéo góc dưới phải hoặc dùng hai nút bên cạnh."},
	smaller={"Smaller","Thu gọn"},larger={"Larger","Phóng lớn"},saved={"Session preferences saved.","Đã lưu tùy chọn trong phiên."},
	restored={"Session preferences restored.","Đã khôi phục tùy chọn trong phiên."},badProfile={"No valid saved session.","Không có cấu hình phiên hợp lệ."},
	error={"The interface could not complete that action.","Giao diện không hoàn tất được thao tác."},
	connections={"CONNECTIONS & ORIGINAL ARTWORK","KẾT NỐI & ẢNH GỐC"},
	apiWait={"Shop sign-in, orders, support and payments await an authorized API.","Đăng nhập, đơn hàng, hỗ trợ và thanh toán đang chờ API được cấp quyền."},
	imageLoading={"Loading original artwork…","Đang tải ảnh gốc…"},imageMissing={"Artwork unavailable","Chưa tải được ảnh"},
	imageHelp={"Check the image source and asset access.","Kiểm tra nguồn ảnh và quyền asset."},
	loaded={"Loaded","Đã tải"},loading={"Loading","Đang tải"},failed={"Unavailable","Chưa khả dụng"},
	localImage={"Owner PNG / local asset","PNG chủ sở hữu / ảnh cục bộ"},robloxImage={"Roblox image asset","Asset ảnh Roblox"},
	logo={"Logo","Logo"},portal={"Portal","Cánh cổng"},print={"Print diagnostics","In chẩn đoán"},
	printed={"Interface diagnostics printed to Output.","Đã in chẩn đoán giao diện vào Output."},
	footer={"KYVORIX / Interface only","KYVORIX / Chỉ giao diện"},
	statusTitle={"KYVORIX STATUS","KYVORIX STATUS"},active={"ACTIVE","ĐANG BẬT"},none={"No features enabled","Chưa bật chức năng"},
	features={"FEATURES","CHỨC NĂNG"},interface={"INTERFACE","GIAO DIỆN"},open={"Open HUB","Mở HUB"},
	statusHint={"Live settings · tap to restore","Cập nhật trực tiếp · ấn để mở"},
	minimize={"Minimize to launcher","Thu thành nút mở"},compact={"Switch to STATUS","Chuyển sang STATUS"},close={"Close HUB","Đóng HUB"},
	destroy={"Destroy interface","Hủy giao diện"},destroyDesc={"Disconnect events and remove this hub.","Ngắt sự kiện và xóa HUB này."},
	assetsNote={"Original shop images; no imitation artwork. Image failures are shown explicitly.","Ảnh gốc của shop, không dùng hình thay thế. Nếu ảnh lỗi, trạng thái được hiển thị rõ."},
	shortHome={"Home","Chính"},shortProgress={"Progress","Tiến độ"},shortCombat={"Combat","Chiến đấu"},shortCollect={"Collect","Thu thập"},
	shortEvents={"Events","Sự kiện"},shortTravel={"Travel","Di chuyển"},shortSettings={"Settings","Cài đặt"},shortSystem={"Connect","Kết nối"},
}
local function tr(key)
	local pair=L[key]
	return pair and pair[S.language=="vi" and 2 or 1] or key
end
local UI={connections={},tweens={},tasks={},workers={},bindings={},updaters={},ambient={},gradients={},features={},assets={}}
local function connect(signal,callback)
	local c=signal:Connect(callback); table.insert(UI.connections,c); return c
end
local function later(seconds,callback)
	local thread
	thread=task.delay(seconds,function() UI.tasks[thread]=nil; if not S.dead then callback() end end)
	UI.tasks[thread]=true
	return thread
end
local function worker(callback)
	local thread
	thread=task.defer(function()
		local ok,err=pcall(callback); UI.workers[thread]=nil
		if not ok and not S.dead then warn("KYVORIX artwork: "..tostring(err)) end
	end)
	UI.workers[thread]=true
end
local function stop(object,finish)
	local entry=UI.tweens[object]
	if not entry then return end
	UI.tweens[object]=nil; entry.connection:Disconnect(); entry.tween:Cancel()
	if finish then for key,value in pairs(entry.goals) do object[key]=value end end
end
local function animate(object,goals,duration)
	stop(object,false)
	if S.fast or S.reduced or duration==0 then for key,value in pairs(goals) do object[key]=value end; return end
	local tween=TweenService:Create(object,TweenInfo.new(duration,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),goals)
	local entry={tween=tween,goals=goals}
	entry.connection=tween.Completed:Connect(function()
		if UI.tweens[object]==entry then UI.tweens[object]=nil end
		entry.connection:Disconnect()
	end)
	UI.tweens[object]=entry; tween:Play()
end
local function finishMotion()
	local objects={}; for object in pairs(UI.tweens) do table.insert(objects,object) end
	for _,object in objects do stop(object,true) end
end
local function make(class,parent,props)
	local object=Instance.new(class)
	for key,value in pairs(props or {}) do object[key]=value end
	object.Parent=parent; return object
end
local function rect(object,x,y,w,h) object.Position=UDim2.fromOffset(x,y); object.Size=UDim2.fromOffset(w,h) end
local function round(object,radius) make("UICorner",object,{CornerRadius=UDim.new(0,radius or 12)}) end
local function frame(parent,color,alpha)
	return make("Frame",parent,{BackgroundColor3=color or C.card,BackgroundTransparency=alpha or 0,BorderSizePixel=0})
end
local function stroke(object,color,alpha,width)
	return make("UIStroke",object,{Color=color or C.line,Transparency=alpha or 0,Thickness=width or 1})
end
local function gradient(object,colors,rotation)
	local g=make("UIGradient",object,{Color=colors or ColorSequence.new(C.cyan,C.purple),Rotation=rotation or 0})
	if not colors then table.insert(UI.gradients,g) end
	return g
end
local function label(parent,key,size,color,bold,literal)
	local l=make("TextLabel",parent,{
		Text=literal and key or tr(key),TextColor3=color or C.text,TextSize=size or 13,
		Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextWrapped=true,
		TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
		BackgroundTransparency=1,BorderSizePixel=0,
	})
	if not literal then table.insert(UI.bindings,{object=l,key=key}) end
	return l
end
local function full(parent,key,y,h,size,color,bold)
	local l=label(parent,key,size,color,bold); l.Position=UDim2.fromOffset(18,y); l.Size=UDim2.new(1,-36,0,h); return l
end
UI.gui=make("ScreenGui",playerGui,{Name="KyvorixClientUI",ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
UI.gui:SetAttribute("KyvorixOwner","KYVORIX_CLIENT_7")
UI.root=frame(UI.gui,nil,1); UI.root.Size=UDim2.fromScale(1,1)
UI.scrim=make("TextButton",UI.root,{Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(3,5,14),BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false,BorderSizePixel=0})
UI.window=make("CanvasGroup",UI.root,{
	Name="MorphWindow",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
	Size=UDim2.fromOffset(960,640),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,
	Visible=false,GroupTransparency=0,ZIndex=2,Active=true,
})
round(UI.window,16); UI.rim=stroke(UI.window,C.cyan,.35)
UI.background=frame(UI.window,Color3.new(1,1,1)); UI.background.Size=UDim2.fromScale(1,1)
gradient(UI.background,ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(5,17,35)),
	ColorSequenceKeypoint.new(.48,Color3.fromRGB(14,14,38)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(34,9,44)),
}),125)
UI.grid=frame(UI.window,nil,1); UI.grid.Size=UDim2.fromScale(1,1)
for x=0,1200,40 do local line=frame(UI.grid,C.cyan,.95); rect(line,x,0,1,1000) end
for y=0,1000,40 do local line=frame(UI.grid,C.purple,.92); rect(line,0,y,1200,1) end
UI.glows={}
for i=1,3 do
	local glow=frame(UI.window,Color3.new(1,1,1),.93)
	glow.Size=UDim2.fromScale(.65,.8); glow.Position=UDim2.fromScale(i==2 and .45 or -.18,i==3 and .5 or -.35)
	round(glow,240)
	gradient(glow,ColorSequence.new(i==2 and C.pink or C.cyan,C.purple),45+i*30)
	table.insert(UI.glows,glow)
end
UI.hub=make("CanvasGroup",UI.window,{Name="HubSurface",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=2})
UI.status=make("CanvasGroup",UI.window,{Name="StatusSurface",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false,GroupTransparency=1,ZIndex=3})
UI.mini=make("CanvasGroup",UI.window,{Name="MiniSurface",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false,GroupTransparency=1,ZIndex=3})
UI.toast=label(UI.hub,"",11,C.cyan,false,true); UI.toast.Visible=false; UI.toast.ZIndex=15
local toastEpoch=0
local function notify(key)
	toastEpoch+=1; local epoch=toastEpoch
	UI.toast:SetAttribute("MessageKey",key); UI.toast.Text=tr(key); UI.toast.Visible=true
	later(4,function() if toastEpoch==epoch then UI.toast.Visible=false end end)
end
local function button(parent,key,primary,callback,name,literal)
	local b=make("TextButton",parent,{Name=name or key,Text="",BackgroundTransparency=1,AutoButtonColor=false,Selectable=true})
	local f=frame(b,primary and Color3.new(1,1,1) or C.card)
	f.AnchorPoint=Vector2.new(.5,.5); f.Position=UDim2.fromScale(.5,.5); f.Size=UDim2.fromScale(1,1); round(f,9)
	local edge=stroke(f,primary and C.cyan or C.line,primary and .08 or .15)
	if primary then gradient(f) end
	local l=label(f,key,12,primary and C.bg or C.text,true,literal)
	l.Position=UDim2.fromOffset(6,0); l.Size=UDim2.new(1,-12,1,0); l.TextXAlignment=Enum.TextXAlignment.Center
	local press=make("UIScale",f,{Scale=1})
	local function hover(on)
		animate(edge,{Transparency=on and 0 or (primary and .08 or .15),Color=on and C.cyan or (primary and C.cyan or C.line)},.15)
		animate(f,{BackgroundTransparency=on and .08 or (b:GetAttribute("RestTransparency") or 0)},.15)
	end
	connect(b.MouseEnter,function() hover(true) end)
	connect(b.MouseLeave,function() hover(false); animate(press,{Scale=1},.12) end)
	connect(b.SelectionGained,function() hover(true) end); connect(b.SelectionLost,function() hover(false) end)
	connect(b.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(press,{Scale=.95},.08) end
	end)
	connect(b.InputEnded,function() animate(press,{Scale=1},.12) end)
	connect(b.Activated,function()
		if S.dead then return end
		animate(press,{Scale=1},.12)
		local ok,err=pcall(callback)
		if not ok then warn("KYVORIX UI: "..tostring(err)); notify("error") end
	end)
	return b,l,f
end
local setMode,refreshStatus,refreshEffects,setLanguage,layoutHub
local function card(parent,height,order)
	local c=frame(parent,C.panel,.08); c.Size=UDim2.new(1,0,0,height); c.LayoutOrder=order or 1
	round(c,14); stroke(c,C.line,.25); return c
end
-- Load only owner-supplied image DATA. Custom asset capability is optional.
-- No credential, private asset fetch, game hook, or permission bypass is used.
local function imagePanel(parent,kind)
	local holder=frame(parent,Color3.fromRGB(5,10,27),.1); holder.ClipsDescendants=true; round(holder,12)
	local image=make("ImageLabel",holder,{Name="Original_"..kind,Image="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ScaleType=Enum.ScaleType.Fit,Visible=false})
	local fallback=label(holder,"imageLoading",11,C.muted)
	fallback.Position=UDim2.fromOffset(8,4); fallback.Size=UDim2.new(1,-16,1,-8); fallback.TextXAlignment=Enum.TextXAlignment.Center
	local entry={state="loading",source="",image=image,fallback=fallback,done=false}
	UI.assets[kind]=UI.assets[kind] or {}; table.insert(UI.assets[kind],entry)
	table.insert(UI.updaters,function()
		fallback.Text=entry.state=="loading" and tr("imageLoading") or (tr("imageMissing").."\n"..tr("imageHelp"))
	end)
	local function settle(ok)
		if S.dead or (entry.done and not ok) then return end
		entry.done=ok; entry.state=ok and "loaded" or "failed"; image.Visible=ok; fallback.Visible=not ok
		fallback.Text=ok and "" or (tr("imageMissing").."\n"..tr("imageHelp"))
	end
	connect(image:GetPropertyChangedSignal("IsLoaded"),function() if image.IsLoaded then settle(true) end end)
	later(12,function() if not entry.done then settle(false) end end)
	worker(function()
		local imageUri
		local customAsset=type(getcustomasset)=="function" and getcustomasset or (type(getsynasset)=="function" and getsynasset or nil)
		if option("LocalArtwork",true)~=false and customAsset and type(writefile)=="function" then
			local fileName="kyvorix-owned-"..kind.."-v7.png"
			local ok,uri=pcall(function()
				local bytes=game:HttpGet("https://raw.githubusercontent.com/VnTotalGui/kyvorix-hub/main/"..kind..".png")
				assert(type(bytes)=="string" and #bytes>8 and #bytes<8*1024*1024 and bytes:sub(1,8)=="\137PNG\r\n\26\n","Invalid PNG data")
				writefile(fileName,bytes)
				return customAsset(fileName)
			end)
			if ok and type(uri)=="string" and #uri>0 then imageUri=uri; entry.source="localImage" end
		end
		if not imageUri then
			local raw=option(kind=="logo" and "KyvorixLogoAsset" or "KyvorixPortalAsset","")
			local digits=tostring(raw):match("^rbxassetid://(%d+)$") or tostring(raw):match("^(%d+)$")
			if digits and option("KyvorixAssetsAuthorized",false)==true then imageUri="rbxassetid://"..digits; entry.source="robloxImage" end
		end
		if S.dead then return end
		if not imageUri then settle(false); return end
		image.Image=imageUri
		local ok=pcall(function() ContentProvider:PreloadAsync({image}) end)
		if S.dead then return end
		if image.IsLoaded then settle(true) elseif not ok then settle(false) end
	end)
	return holder,image,fallback
end
-- Header and Windows-style controls: minimize / status / close.
UI.header=frame(UI.hub,C.bg,.1)
UI.logo=imagePanel(UI.header,"logo"); rect(UI.logo,16,13,40,40)
UI.brand=label(UI.header,"KYVORIX",21,C.text,true,true); rect(UI.brand,68,11,180,28)
UI.tag=label(UI.header,"edition",8,C.muted); rect(UI.tag,69,39,225,15)
UI.dragHandle=make("TextButton",UI.header,{Name="WindowDragHandle",Text="",BackgroundTransparency=1,Active=true,AutoButtonColor=false})
UI.headerLine=frame(UI.header,Color3.new(1,1,1)); UI.headerLine.Position=UDim2.new(0,0,1,-1); UI.headerLine.Size=UDim2.new(1,0,0,1); gradient(UI.headerLine)
UI.languageButton,UI.languageCaption=button(UI.header,"EN / VI",false,function() setLanguage(S.language=="en" and "vi" or "en") end,"LanguageSwitch",true)
UI.minimize=button(UI.header,"—",false,function() setMode("MINI") end,"WindowMinimize",true)
UI.compact=button(UI.header,"□",false,function() setMode("STATUS") end,"WindowStatus",true)
UI.close=button(UI.header,"×",false,function() UI.gui:Destroy() end,"WindowClose",true)
UI.sidebar=frame(UI.hub,C.bg,.25); round(UI.sidebar,12)
UI.navScroll=make("ScrollingFrame",UI.sidebar,{
	Name="NavigationScroll",BackgroundTransparency=1,BorderSizePixel=0,
	CanvasSize=UDim2.fromOffset(0,344),ScrollBarThickness=2,ScrollBarImageColor3=C.cyan,
	ClipsDescendants=true,
})
UI.sideCaption=label(UI.sidebar,"explore",8,C.muted,true); rect(UI.sideCaption,12,10,126,18)
UI.sideFoot=label(UI.sidebar,"KYVORIX\nCYBER CHROMA",8,C.muted,false,true)
UI.marker=frame(UI.navScroll,C.cyan); round(UI.marker,2); UI.marker.Size=UDim2.fromOffset(3,27); UI.marker.ZIndex=3
UI.body=frame(UI.hub,nil,1); UI.body.ClipsDescendants=true
UI.footer=label(UI.hub,"footer",9,C.muted)
UI.pages={}; UI.navs={}
local pageOrder={"home","progress","combat","collect","events","travel","settings","system"}
local shortKeys={"shortHome","shortProgress","shortCombat","shortCollect","shortEvents","shortTravel","shortSettings","shortSystem"}
for i,id in pageOrder do
	local p=make("ScrollingFrame",UI.body,{
		Name="page_"..id,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Visible=i==1,
		CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=C.cyan,
	})
	make("UIPadding",p,{PaddingRight=UDim.new(0,8),PaddingLeft=UDim.new(0,2),PaddingBottom=UDim.new(0,8)})
	make("UIListLayout",p,{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder})
	UI.pages[id]=p
	local b,l,f=button(UI.navScroll,id,false,function()
		S.page=id
		for name,page in pairs(UI.pages) do stop(page,true); page.Visible=name==id end
		for n,nav in UI.navs do
			stop(nav.fill,false)
			local selected=pageOrder[n]==id
			nav.button:SetAttribute("RestTransparency",selected and 0 or 1)
			nav.fill.BackgroundTransparency=selected and 0 or 1
			nav.caption.TextColor3=selected and C.text or C.muted
		end
		local selected=UI.pages[id]; selected.Position=UDim2.fromOffset(8,0); animate(selected,{Position=UDim2.fromOffset(0,0)},.18)
		animate(UI.marker,{Position=UDim2.fromOffset(3,6+(i-1)*43)},.22)
		refreshEffects()
	end,"nav_"..id)
	b.Position=UDim2.fromOffset(9,(i-1)*43); b.Size=UDim2.new(1,-18,0,37)
	UI.navs[i]={button=b,caption=l,fill=f,id=id,short=shortKeys[i]}; l.TextSize=11
end
UI.hero=card(UI.pages.home,330,1)
UI.eyebrow=label(UI.hero,"eyebrow",9,C.cyan,true)
UI.h1=label(UI.hero,"headline1",31,C.text,true)
UI.h2=label(UI.hero,"headline2",31,Color3.new(1,1,1),true); UI.headGradient=gradient(UI.h2)
UI.intro=label(UI.hero,"intro",12,C.muted)
UI.discover=button(UI.hero,"discover",true,function()
	S.page="progress"; UI.navs[2].button:FindFirstChildOfClass("Frame")
	for id,p in pairs(UI.pages) do p.Visible=id==S.page end
	UI.refreshNav()
end,"HeroExplore")
UI.personalize=button(UI.hero,"personalize",false,function()
	S.page="settings"; for id,p in pairs(UI.pages) do p.Visible=id==S.page end; UI.refreshNav()
end,"HeroPersonalize")
UI.art=imagePanel(UI.hero,"portal")
UI.artTag=label(UI.hero,"nextworld",8,C.cyan,true)
UI.artCaption=label(UI.hero,"world",13,C.text,true)
UI.orbit=frame(UI.hero,nil,1); UI.rings={}
for i=1,3 do
	local ring=frame(UI.orbit,nil,1); ring.AnchorPoint=Vector2.new(.5,.5); ring.Position=UDim2.fromScale(.5,.5)
	make("UICorner",ring,{CornerRadius=UDim.new(.5,0)})
	stroke(ring,i==1 and C.pink or (i==2 and C.cyan or C.purple),.55)
	local dot=frame(ring,i==1 and C.pink or C.cyan); round(dot,3); rect(dot,2,2,4,4)
	UI.rings[i]=ring
end
UI.heroRule=frame(UI.hero,Color3.new(1,1,1)); gradient(UI.heroRule)
UI.pills={}
for i,key in {"themeTag","live"} do
	local pill=frame(UI.hero,C.card,.2); round(pill,12); stroke(pill,C.cyan,.7)
	local text=label(pill,key,7,C.muted,true); text.Size=UDim2.fromScale(1,1); text.TextXAlignment=Enum.TextXAlignment.Center
	UI.pills[i]=pill
end
UI.stats=card(UI.pages.home,110,2); full(UI.stats,"character",10,17,9,C.muted,true)
UI.statCells={}; UI.statValues={}
for i,key in {"level","beli","fragments","health"} do
	local cell=frame(UI.stats,C.card); round(cell,9)
	local caption=label(cell,key,8,C.muted,true); rect(caption,10,7,120,15); caption.Size=UDim2.new(1,-20,0,15)
	local value=label(cell,"unavailable",16,C.text,true); value.Position=UDim2.fromOffset(10,28); value.Size=UDim2.new(1,-20,0,24)
	UI.statCells[i]=cell; UI.statValues[i]=value
end
UI.workspace=card(UI.pages.home,122,3)
full(UI.workspace,"workspace",13,26,18,C.text,true)
UI.workspaceDesc=full(UI.workspace,"workspaceDesc",43,33,11,C.muted)
UI.toStatus=button(UI.workspace,"toStatus",false,function() setMode("STATUS") end,"DashboardStatus")
UI.toStatus.Position=UDim2.fromOffset(18,82); UI.toStatus.Size=UDim2.fromOffset(210,27)
UI.pendingCards={}
for _,id in {"progress","combat","collect","events","travel"} do
	local c=card(UI.pages[id],190)
	full(c,id,16,30,24,C.text,true); full(c,"pending",57,19,9,C.pink,true)
	local desc=full(c,id=="progress" and "progressDesc" or "pendingDesc",85,86,12,C.muted)
	UI.pendingCards[id]={card=c,description=desc}
end
-- Settings are real UI callbacks. Feature entries without callbacks remain unavailable.
UI.settingRows={}; UI.settingValues={}
local function setting(order,key,description,value,callback,id)
	local c=card(UI.pages.settings,90,order)
	local title=label(c,key,13,C.text,true); title.Position=UDim2.fromOffset(16,12); title.Size=UDim2.new(1,-180,0,23)
	local desc=label(c,description,10,C.muted); desc.Position=UDim2.fromOffset(16,38); desc.Size=UDim2.new(1,-180,0,38)
	local b,l=button(c,"",false,callback,id or "setting_"..key,true)
	b.Position=UDim2.new(1,-152,0,26); b.Size=UDim2.fromOffset(136,36)
	UI.settingRows[#UI.settingRows+1]={card=c,title=title,desc=desc,button=b}
	UI.settingValues[#UI.settingValues+1]=function() l.Text=value() end
end
local function toggle(key)
	S[key]=not S[key]; refreshEffects(); refreshStatus()
	if S.transitioning and (S.fast or S.reduced) then setMode(S.mode,true) end
end
setting(1,"language","languageDesc",function() return S.language=="en" and "English" or "Tiếng Việt" end,function() setLanguage(S.language=="en" and "vi" or "en") end,"SettingsLanguage")
setting(2,"reduced","reducedDesc",function() return tr(S.reduced and "on" or "off") end,function() toggle("reduced") end,"ToggleReduced")
setting(3,"fast","fastDesc",function() return tr(S.fast and "on" or "off") end,function() toggle("fast") end,"ToggleFast")
setting(4,"aura","auraDesc",function() return tr(S.aura and "on" or "off") end,function() toggle("aura") end,"ToggleAura")
setting(5,"particles","particlesDesc",function() return tr(S.particles and "on" or "off") end,function() toggle("particles") end,"ToggleParticles")
UI.palettes={
	{Color3.fromRGB(0,235,245),Color3.fromRGB(167,101,246),"KYVORIX"},
	{Color3.fromRGB(88,229,186),Color3.fromRGB(89,157,248),"Aurora"},
	{Color3.fromRGB(255,172,107),Color3.fromRGB(222,117,238),"sunset"},
}
function UI.applyPalette()
	local p=UI.palettes[S.palette]
	local old1,old2=C.cyan,C.purple
	local function color(v) if v==old1 then return p[1] elseif v==old2 then return p[2] end; return v end
	for _,o in UI.gui:GetDescendants() do
		if o:IsA("GuiObject") then o.BackgroundColor3=color(o.BackgroundColor3) end
		if o:IsA("TextLabel") or o:IsA("TextButton") then o.TextColor3=color(o.TextColor3) end
		if o:IsA("UIStroke") then o.Color=color(o.Color) end
		if o:IsA("ScrollingFrame") then o.ScrollBarImageColor3=color(o.ScrollBarImageColor3) end
	end
	C.cyan=p[1]; C.purple=p[2]
	for _,g in UI.gradients do g.Color=ColorSequence.new(C.cyan,C.purple) end
	refreshEffects(); refreshStatus()
end
setting(6,"palette","paletteDesc",function()
	local key=UI.palettes[S.palette][3]; return key=="sunset" and tr(key) or key
end,function() S.palette=S.palette%#UI.palettes+1; UI.applyPalette() end,"CyclePalette")
function UI.profile()
	return {version=2,language=S.language,fast=S.fast,reduced=S.reduced,aura=S.aura,particles=S.particles,palette=S.palette}
end
function UI.applyProfile(value)
	assert(type(value)=="table" and (value.version==1 or value.version==2),"Invalid profile version")
	assert(type(value.reduced)=="boolean" and type(value.aura)=="boolean","Invalid profile fields")
	assert(value.fast==nil or type(value.fast)=="boolean","Invalid Fastmode")
	assert(value.particles==nil or type(value.particles)=="boolean","Invalid particles")
	assert(value.language==nil or value.language=="en" or value.language=="vi","Invalid language")
	assert(type(value.palette)=="number" and value.palette%1==0 and UI.palettes[value.palette],"Invalid palette")
	S.reduced=value.reduced; S.aura=value.aura; S.fast=value.fast==true; S.particles=value.particles~=false; S.palette=value.palette
	if value.language then setLanguage(value.language) end
	UI.applyPalette()
	if S.transitioning and (S.fast or S.reduced) then setMode(S.mode,true) end
	return true
end
setting(7,"save","saveDesc",function() return tr("save") end,function()
	playerGui:SetAttribute("KyvorixSessionProfile",HttpService:JSONEncode(UI.profile())); notify("saved")
end,"SaveProfile")
setting(8,"restore","restoreDesc",function() return tr("restore") end,function()
	local raw=playerGui:GetAttribute("KyvorixSessionProfile")
	if type(raw)~="string" or #raw>4096 then notify("badProfile"); return end
	local ok=pcall(function() UI.applyProfile(HttpService:JSONDecode(raw)) end); notify(ok and "restored" or "badProfile")
end,"RestoreProfile")
setting(9,"reset","resetDesc",function() return tr("reset") end,function()
	UI.applyProfile({version=2,language=S.language,reduced=false,fast=false,aura=true,particles=true,palette=1})
end,"ResetAppearance")
setting(11,"destroy","destroyDesc",function() return tr("destroy") end,function() UI.gui:Destroy() end,"DestroyUI")
UI.sizeCard=card(UI.pages.settings,88,10); full(UI.sizeCard,"size",10,23,13,C.text,true)
UI.smaller=button(UI.sizeCard,"smaller",false,function()
	local size=S.hubSize or Vector2.new(960,640); S.hubSize=Vector2.new(math.max(460,size.X-80),math.max(500,size.Y-40)); setMode("HUB",true)
end,"SizeSmaller")
UI.larger=button(UI.sizeCard,"larger",false,function()
	local size=S.hubSize or Vector2.new(960,640); S.hubSize=Vector2.new(math.min(1160,size.X+80),math.min(800,size.Y+40)); setMode("HUB",true)
end,"SizeLarger")
rect(UI.smaller,16,43,130,30); UI.larger.Position=UDim2.new(1,-146,0,43); UI.larger.Size=UDim2.fromOffset(130,30)
UI.connectionCard=card(UI.pages.system,278)
full(UI.connectionCard,"connections",14,30,15,C.text,true)
UI.diagnosticsText=full(UI.connectionCard,"",53,126,11,C.muted)
UI.apiText=full(UI.connectionCard,"apiWait",180,45,11,C.muted)
UI.print=button(UI.connectionCard,"print",false,function() print(HttpService:JSONEncode(UI.diagnostics())); notify("printed") end,"PrintDiagnostics")
UI.print.Position=UDim2.fromOffset(18,233); UI.print.Size=UDim2.new(1,-36,0,30)
UI.assetNote=card(UI.pages.system,94,2); full(UI.assetNote,"assetsNote",14,66,11,C.muted)
-- Compact status shares S and the feature registry; no duplicate toggle state.
UI.statusLine=frame(UI.status,Color3.new(1,1,1)); UI.statusLine.Size=UDim2.new(1,0,0,3); gradient(UI.statusLine)
UI.statusTitle=label(UI.status,"statusTitle",13,C.text,true); rect(UI.statusTitle,16,14,200,22)
UI.statusSubtitle=label(UI.status,"statusHint",9,C.muted); rect(UI.statusSubtitle,16,38,260,18)
UI.statusList=label(UI.status,"",11,C.text,false,true); UI.statusList.TextYAlignment=Enum.TextYAlignment.Top
UI.statusScroll=make("ScrollingFrame",UI.status,{BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=C.cyan})
UI.statusList.Parent=UI.statusScroll; UI.statusList.Position=UDim2.fromOffset(0,0); UI.statusList.Size=UDim2.new(1,-5,0,130)
UI.statusCount=label(UI.status,"",9,C.cyan,true,true)
UI.statusRestore=button(UI.status,"open",true,function() setMode("HUB") end,"StatusRestore")
UI.statusMini=button(UI.status,"—",false,function() setMode("MINI") end,"StatusMinimize",true)
UI.statusClose=button(UI.status,"×",false,function() UI.gui:Destroy() end,"StatusClose",true)
UI.statusLang=button(UI.status,"EN / VI",false,function() setLanguage(S.language=="en" and "vi" or "en") end,"StatusLanguage",true)
UI.miniRestore=button(UI.mini,"KYVORIX",true,function() setMode("HUB") end,"MiniRestore",true)
UI.miniRestore.Size=UDim2.fromScale(1,1)
UI.sparkles={}; UI.sparkBases={}
for i=1,10 do
	local spark=frame(UI.hub,i%3==0 and C.pink or C.cyan,.24); round(spark,3)
	spark.Size=UDim2.fromOffset(i%2==0 and 3 or 4,i%2==0 and 3 or 4)
	spark.Position=UDim2.fromScale(((i*29)%97)/100,((i*37)%89)/100)
	spark.ZIndex=1; table.insert(UI.sparkles,spark); UI.sparkBases[spark]=spark.Position
end
function UI.refreshNav()
	for i,nav in UI.navs do
		local selected=nav.id==S.page
		stop(nav.fill,false); nav.button:SetAttribute("RestTransparency",selected and 0 or 1)
		nav.fill.BackgroundTransparency=selected and 0 or 1; nav.caption.TextColor3=selected and C.text or C.muted
		if selected then UI.marker.Position=UDim2.fromOffset(3,6+(i-1)*43) end
	end
	refreshEffects()
end
refreshStatus=function()
	if S.dead then return end
	local featureRows={}
	for id,feature in pairs(UI.features) do
		if feature.enabled then table.insert(featureRows,{id=id,title=S.language=="vi" and feature.vi or feature.en}) end
	end
	table.sort(featureRows,function(a,b) return a.id<b.id end)
	local lines={tr("features").."  /  "..tostring(#featureRows).." "..tr("active")}
	if #featureRows==0 then table.insert(lines,tr("none")) else for _,feature in featureRows do table.insert(lines,"• "..feature.title) end end
	table.insert(lines,"")
	local effects={}
	if S.fast then table.insert(effects,tr("fast")) end
	if S.reduced then table.insert(effects,tr("reduced")) end
	if S.aura and not S.fast then table.insert(effects,tr("aura")) end
	if S.particles and not S.fast then table.insert(effects,tr("particles")) end
	table.insert(lines,tr("interface").."  /  "..table.concat(effects," · "))
	UI.statusList.Text=table.concat(lines,"\n")
	UI.statusList.Size=UDim2.new(1,-5,0,math.max(108,(#featureRows+5)*18))
	UI.statusCount.Text=tostring(#featureRows).." "..tr("active").."  /  "..(S.language=="en" and "EN" or "VI")
	for _,update in UI.settingValues do update() end
end
refreshEffects=function()
	for _,tween in UI.ambient do tween:Cancel() end; table.clear(UI.ambient)
	UI.grid.Visible=not S.fast
	UI.orbit.Visible=S.aura and not S.fast
	for _,glow in UI.glows do glow.Visible=S.aura and not S.fast end
	for _,spark in UI.sparkles do
		spark.Position=UI.sparkBases[spark]
		spark.Visible=S.particles and not S.fast and S.mode=="HUB"
	end
	UI.headGradient.Offset=Vector2.new(0,0)
	if S.mode=="HUB" and not S.transitioning and not S.fast and not S.reduced then
		if S.aura and S.page=="home" then
			for i,ring in UI.rings do
				local tween=TweenService:Create(ring,TweenInfo.new(32+i*10,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Rotation=ring.Rotation+(i%2==0 and -360 or 360)})
				table.insert(UI.ambient,tween); tween:Play()
			end
		end
		if S.particles then
			for i,spark in UI.sparkles do
				local tween=TweenService:Create(spark,TweenInfo.new(2.4+i*.12,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{
					Position=spark.Position+UDim2.fromOffset(0,-7-i%3),BackgroundTransparency=.75,
				})
				table.insert(UI.ambient,tween); tween:Play()
			end
		end
		local g=UI.headGradient
		local tween=TweenService:Create(g,TweenInfo.new(3.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Offset=Vector2.new(.16,0)})
		table.insert(UI.ambient,tween); tween:Play()
	end
	for _,update in UI.settingValues do update() end
	if S.fast or S.reduced then
		finishMotion()
	end
end
setLanguage=function(language)
	assert(language=="en" or language=="vi","Unsupported language")
	S.language=language; playerGui:SetAttribute("KyvorixLanguage",language)
	for _,binding in UI.bindings do binding.object.Text=tr(binding.key) end
	UI.languageCaption.Text=language=="en" and "EN / VI" or "VI / EN"
	if UI.toast.Visible then UI.toast.Text=tr(UI.toast:GetAttribute("MessageKey") or "error") end
	for _,update in UI.updaters do update() end
	if layoutHub and UI.lastHubSize then layoutHub(UI.lastHubSize) end
	refreshStatus(); UI.updateData()
	return true
end
local function viewport()
	local size=UI.root.AbsoluteSize
	return Vector2.new(math.max(size.X,120),math.max(size.Y,160))
end
local function clampCenter(center,size,vp)
	local margin=Vector2.new(math.min(8,vp.X*.02),math.min(8,vp.Y*.02))
	return Vector2.new(math.clamp(center.X,size.X/2+margin.X,vp.X-size.X/2-margin.X),math.clamp(center.Y,size.Y/2+margin.Y,vp.Y-size.Y/2-margin.Y))
end
function UI.geometry(mode)
	local vp=viewport()
	local gap=math.clamp(tonumber(option("RightInset",12)) or 12,8,20)
	if mode=="STATUS" then
		local size=Vector2.new(math.min(292,vp.X-24),math.min(242,vp.Y-24))
		return size,Vector2.new(vp.X-gap-size.X/2,vp.Y/2)
	elseif mode=="MINI" then
		local size=Vector2.new(math.min(112,vp.X-24),40)
		return size,Vector2.new(vp.X-gap-size.X/2,vp.Y/2)
	end
	local requested=S.hubSize or Vector2.new(math.min(1000,vp.X*.80),math.min(670,vp.Y*.82))
	local size=Vector2.new(math.min(requested.X,vp.X-24),math.min(requested.Y,vp.Y-24))
	size=Vector2.new(math.max(96,size.X),math.max(136,size.Y))
	return size,clampCenter(S.hubCenter or vp/2,size,vp)
end
layoutHub=function(size)
	UI.lastHubSize=size
	local w,h=size.X,size.Y
	local compact=w<700
	local phone=w<460
	local side=phone and 72 or (compact and 102 or 154)
	local headerH=phone and 104 or 72
	UI.header.Size=UDim2.new(1,0,0,headerH)
	UI.tag.Visible=not phone
	UI.brand.TextSize=phone and 18 or 21
	if phone then
		rect(UI.languageButton,16,65,74,28)
	else rect(UI.languageButton,w-232,21,88,30) end
	rect(UI.minimize,w-132,20,36,31); rect(UI.compact,w-92,20,36,31); rect(UI.close,w-52,20,36,31)
	UI.dragHandle.Position=UDim2.fromOffset(62,0); UI.dragHandle.Size=UDim2.fromOffset(math.max(0,w-310),64)
	local top=headerH+14
	rect(UI.sidebar,12,top,side,h-top-38)
	UI.sideCaption.Visible=not compact
	UI.sideFoot.Visible=h>540
	UI.sideFoot.Position=UDim2.new(0,12,1,-38); UI.sideFoot.Size=UDim2.new(1,-24,0,29)
	rect(UI.navScroll,0,compact and 6 or 30,side,math.max(36,h-top-38-(compact and 6 or 30)-(UI.sideFoot.Visible and 42 or 8)))
	for i,nav in UI.navs do
		nav.button.Position=UDim2.fromOffset(8,(i-1)*43); nav.button.Size=UDim2.new(1,-16,0,37)
		nav.caption.Text=tr(compact and nav.short or nav.id); nav.caption.TextSize=phone and 9 or 11
		if nav.id==S.page then UI.marker.Position=UDim2.fromOffset(3,6+(i-1)*43); UI.marker.Size=UDim2.fromOffset(3,27) end
	end
	local bodyX=side+24
	rect(UI.body,bodyX,top,w-bodyX-14,h-top-68)
	rect(UI.footer,bodyX,h-28,w-bodyX-18,18)
	rect(UI.toast,bodyX,h-58,w-bodyX-18,26)
	local cw=w-bodyX-24
	local two=cw>=620
	local textW=two and math.floor(cw*.51) or cw-36
	local artW=two and math.floor(cw*.43) or math.min(380,cw-36)
	local artH=artW*2/3
	local titleSize=math.clamp(textW/10.2,19,34)
	local heroH=two and math.max(330,artH+66) or 332+artH+54
	UI.hero.Size=UDim2.new(1,0,0,heroH)
	rect(UI.eyebrow,18,18,textW,28)
	UI.eyebrow.TextSize=textW<240 and 7 or 9
	UI.h1.TextSize=titleSize; UI.h2.TextSize=titleSize
	rect(UI.h1,18,57,textW,45); rect(UI.h2,18,100,textW,45)
	rect(UI.intro,18,158,textW,82)
	if textW<270 then
		rect(UI.discover,18,250,textW,33); rect(UI.personalize,18,291,textW,33)
	else
		rect(UI.discover,18,250,(textW-10)*.54,38); rect(UI.personalize,28+(textW-10)*.54,250,(textW-10)*.46,38)
	end
	local artX=two and cw-artW-14 or (cw-artW)/2
	local artY=two and (heroH-artH)/2-8 or 344
	rect(UI.art,artX,artY,artW,artH); rect(UI.orbit,artX,artY,artW,artH)
	rect(UI.artTag,artX+8,artY+artH+6,artW-16,14); rect(UI.artCaption,artX+8,artY+artH+21,artW-16,20)
	for i,ring in UI.rings do ring.Size=UDim2.fromOffset(artH*(.85+i*.11),artH*(.85+i*.11)) end
	UI.orbit.Visible=S.aura and not S.fast
	UI.heroRule.Visible=two; rect(UI.heroRule,18,heroH-24,cw-36,1)
	for i,pill in UI.pills do pill.Visible=false; rect(pill,18+(i-1)*150,heroH-17,140,13) end
	local statColumns=cw<480 and 2 or 4
	local cellW=(cw-28-(statColumns-1)*6)/statColumns
	UI.stats.Size=UDim2.new(1,0,0,statColumns==2 and 174 or 110)
	for i,cell in UI.statCells do
		rect(cell,14+((i-1)%statColumns)*(cellW+6),35+math.floor((i-1)/statColumns)*65,cellW,58)
		UI.statValues[i].TextSize=cw<280 and 12 or 16
	end
	local stacked=cw<410
	for _,row in UI.settingRows do
		row.card.Size=UDim2.new(1,0,0,stacked and 154 or 90)
		row.title.Size=UDim2.new(1,stacked and -32 or -180,0,25)
		row.desc.Size=UDim2.new(1,stacked and -32 or -180,0,stacked and 56 or 38)
		row.button.Position=stacked and UDim2.fromOffset(16,107) or UDim2.new(1,-152,0,26)
		row.button.Size=stacked and UDim2.new(1,-32,0,32) or UDim2.fromOffset(136,36)
	end
	if cw<320 then
		UI.workspace.Size=UDim2.new(1,0,0,190); UI.workspaceDesc.Size=UDim2.new(1,-36,0,84)
		UI.toStatus.Position=UDim2.fromOffset(18,144); UI.toStatus.Size=UDim2.new(1,-36,0,30)
		UI.sizeCard.Size=UDim2.new(1,0,0,130); UI.smaller.Size=UDim2.new(1,-32,0,30)
		UI.larger.Position=UDim2.fromOffset(16,82); UI.larger.Size=UDim2.new(1,-32,0,30)
		UI.connectionCard.Size=UDim2.new(1,0,0,370); UI.diagnosticsText.Size=UDim2.new(1,-36,0,190)
		UI.apiText.Position=UDim2.fromOffset(18,248); UI.apiText.Size=UDim2.new(1,-36,0,70)
		UI.print.Position=UDim2.fromOffset(18,328)
		UI.assetNote.Size=UDim2.new(1,0,0,160)
	else
		UI.workspace.Size=UDim2.new(1,0,0,122); UI.workspaceDesc.Size=UDim2.new(1,-36,0,33)
		UI.toStatus.Position=UDim2.fromOffset(18,82); UI.toStatus.Size=UDim2.fromOffset(210,27)
		UI.sizeCard.Size=UDim2.new(1,0,0,88); UI.smaller.Size=UDim2.fromOffset(130,30)
		UI.larger.Position=UDim2.new(1,-146,0,43); UI.larger.Size=UDim2.fromOffset(130,30)
		UI.connectionCard.Size=UDim2.new(1,0,0,278); UI.diagnosticsText.Size=UDim2.new(1,-36,0,126)
		UI.apiText.Position=UDim2.fromOffset(18,180); UI.apiText.Size=UDim2.new(1,-36,0,45); UI.print.Position=UDim2.fromOffset(18,233)
		UI.assetNote.Size=UDim2.new(1,0,0,94)
	end
	for _,item in pairs(UI.pendingCards) do
		item.card.Size=UDim2.new(1,0,0,cw<300 and 260 or 190)
		item.description.Size=UDim2.new(1,-36,0,cw<300 and 158 or 86)
	end
end
local function layoutCompact(size)
	local w,h=size.X,size.Y
	rect(UI.statusTitle,14,13,w-100,21); UI.statusTitle.TextSize=w<240 and 11 or 13
	rect(UI.statusMini,w-76,10,28,26); rect(UI.statusClose,w-42,10,28,26)
	rect(UI.statusSubtitle,14,38,w-28,25)
	rect(UI.statusScroll,14,72,w-28,math.max(28,h-136))
	rect(UI.statusCount,14,h-53,w-110,16)
	rect(UI.statusRestore,14,h-32,w-98,24); rect(UI.statusLang,w-76,h-32,62,24)
end
setMode=function(mode,instant)
	assert(mode=="HUB" or mode=="STATUS" or mode=="MINI","Unsupported window mode")
	if S.dead then return false end
	S.epoch+=1; local epoch=S.epoch
	S.mode=mode; S.transitioning=true; UI.drag=nil; UI.resize=nil
	stop(UI.window,false)
	for _,surface in {UI.hub,UI.status,UI.mini} do stop(surface,false) end
	refreshEffects()
	local size,center=UI.geometry(mode)
	if mode=="HUB" then layoutHub(size) else layoutCompact(size) end
	UI.window.Visible=true
	UI.scrim.Visible=mode=="HUB"
	animate(UI.scrim,{BackgroundTransparency=mode=="HUB" and .72 or 1},.18)
	local target=mode=="HUB" and UI.hub or (mode=="STATUS" and UI.status or UI.mini)
	local function finish()
		if S.dead or S.epoch~=epoch then return end
		UI.window.Size=UDim2.fromOffset(size.X,size.Y); UI.window.Position=UDim2.fromOffset(center.X,center.Y)
		for _,surface in {UI.hub,UI.status,UI.mini} do surface.Visible=surface==target; surface.GroupTransparency=surface==target and 0 or 1 end
		S.transitioning=false; refreshEffects(); refreshStatus()
	end
	if instant or S.fast or S.reduced then finish(); return true end
	for _,surface in {UI.hub,UI.status,UI.mini} do if surface.Visible then animate(surface,{GroupTransparency=1},.10) end end
	animate(UI.window,{Size=UDim2.fromOffset(size.X,size.Y),Position=UDim2.fromOffset(center.X,center.Y)},.48)
	later(.16,function()
		if S.epoch~=epoch then return end
		for _,surface in {UI.hub,UI.status,UI.mini} do surface.Visible=surface==target end
		target.GroupTransparency=1; animate(target,{GroupTransparency=0},.26)
	end)
	later(.50,finish)
	return true
end
UI.grip=make("TextButton",UI.hub,{Name="WindowResizeGrip",Text="↘",TextColor3=C.muted,TextSize=19,BackgroundTransparency=1,Position=UDim2.new(1,-28,1,-28),Size=UDim2.fromOffset(25,25)})
local function pointer(input) return Vector2.new(input.Position.X,input.Position.Y)-UI.root.AbsolutePosition end
local function primaryPointer(input) return input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch end
connect(UI.dragHandle.InputBegan,function(input)
	if primaryPointer(input) and S.mode=="HUB" and not S.transitioning then
		local p=UI.window.Position
		UI.drag={input=input,point=pointer(input),center=Vector2.new(p.X.Offset,p.Y.Offset)}
	end
end)
connect(UI.grip.InputBegan,function(input)
	if primaryPointer(input) and S.mode=="HUB" and not S.transitioning then
		UI.resize={input=input,point=pointer(input),size=Vector2.new(UI.window.Size.X.Offset,UI.window.Size.Y.Offset)}
	end
end)
connect(UIS.InputChanged,function(input)
	local mouse=input.UserInputType==Enum.UserInputType.MouseMovement
	if UI.drag and ((mouse and UI.drag.input.UserInputType==Enum.UserInputType.MouseButton1) or input==UI.drag.input) then
		local delta=pointer(input)-UI.drag.point
		local size=Vector2.new(UI.window.Size.X.Offset,UI.window.Size.Y.Offset)
		S.hubCenter=clampCenter(UI.drag.center+delta,size,viewport())
		UI.window.Position=UDim2.fromOffset(S.hubCenter.X,S.hubCenter.Y)
	elseif UI.resize and ((mouse and UI.resize.input.UserInputType==Enum.UserInputType.MouseButton1) or input==UI.resize.input) then
		local delta=pointer(input)-UI.resize.point
		local vp=viewport()
		S.hubSize=Vector2.new(math.clamp(UI.resize.size.X+delta.X,math.min(460,vp.X-24),math.min(1160,vp.X-24)),
			math.clamp(UI.resize.size.Y+delta.Y,math.min(500,vp.Y-24),math.min(800,vp.Y-24)))
		local size,center=UI.geometry("HUB")
		UI.window.Size=UDim2.fromOffset(size.X,size.Y); UI.window.Position=UDim2.fromOffset(center.X,center.Y); layoutHub(size)
	end
end)
connect(UIS.InputEnded,function(input)
	if UI.drag and (input==UI.drag.input or input.UserInputType==Enum.UserInputType.MouseButton1) then UI.drag=nil end
	if UI.resize and (input==UI.resize.input or input.UserInputType==Enum.UserInputType.MouseButton1) then UI.resize=nil end
end)
connect(UIS.WindowFocusReleased,function() UI.drag=nil; UI.resize=nil end)
connect(UIS.InputBegan,function(input,processed)
	if not processed and (input.KeyCode==Enum.KeyCode.RightShift or input.KeyCode==Enum.KeyCode.RightControl) then setMode(S.mode=="HUB" and "MINI" or "HUB") end
end)
connect(UI.root:GetPropertyChangedSignal("AbsoluteSize"),function() if not S.dead then setMode(S.mode,true) end end)
local function readData(name)
	local folder=player:FindFirstChild("Data")
	local v=folder and folder:FindFirstChild(name)
	if v and v:IsA("ValueBase") then
		local ok,result=pcall(function() return v.Value end)
		if ok and (type(result)=="number" or type(result)=="string") then return tostring(result) end
	end
	return tr("unavailable")
end
function UI.updateData()
	UI.statValues[1].Text=readData("Level"); UI.statValues[2].Text=readData("Beli"); UI.statValues[3].Text=readData("Fragments")
	local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	UI.statValues[4].Text=hum and string.format("%.0f / %.0f",hum.Health,hum.MaxHealth) or tr("unavailable")
	local function artState(kind)
		local entry=UI.assets[kind] and UI.assets[kind][1]
		return entry and tr(entry.state) or tr("unavailable")
	end
	UI.diagnosticsText.Text="KYVORIX 7 / "..(RunService:IsStudio() and "Studio" or "Client")
		.."\n"..tr("language")..": "..(S.language=="en" and "English" or "Tiếng Việt")
		.."\n"..tr("logo")..": "..artState("logo").."\n"..tr("portal")..": "..artState("portal")
		.."\n"..tr("features")..": "..tostring(UI.featureCount())
end
function UI.featureCount()
	local count=0; for _,f in pairs(UI.features) do if f.enabled then count+=1 end end; return count
end
function UI.diagnostics()
	local assets={}
	for kind,list in pairs(UI.assets) do assets[kind]=list[1] and {state=list[1].state,source=list[1].source} or {} end
	return {build="KYVORIX Client UI 7",language=S.language,mode=S.mode,page=S.page,transitioning=S.transitioning,
		fast=S.fast,reduced=S.reduced,aura=S.aura,particles=S.particles,features=UI.featureCount(),assets=assets,
		window={width=UI.window.Size.X.Offset,height=UI.window.Size.Y.Offset,x=UI.window.Position.X.Offset,y=UI.window.Position.Y.Offset},
		dead=S.dead}
end
function UI.setFeature(id,en,vi,enabled)
	assert(type(id)=="string" and #id>0 and #id<=48 and id:match("^[%w_%-]+$"),"Invalid feature id")
	assert(type(en)=="string" and #en<=80 and type(vi)=="string" and #vi<=120 and type(enabled)=="boolean","Invalid feature state")
	local count=0; for _ in pairs(UI.features) do count+=1 end
	assert(UI.features[id] or count<32,"Feature limit reached")
	UI.features[id]={en=en,vi=vi,enabled=enabled}
	refreshStatus(); return true
end
local function hook(name,callback)
	local bind=make("BindableFunction",UI.gui,{Name=name}); bind.OnInvoke=callback
	return bind
end
UI.hooks={
	hook("GetUIDiagnostics",UI.diagnostics),hook("SetLanguage",setLanguage),hook("SetMode",setMode),
	hook("ApplyUIProfile",function(value) return pcall(UI.applyProfile,value) end),
	-- Local status registration only. This never implements or starts gameplay.
	hook("SetFeatureState",UI.setFeature),
}
local elapsed=0
connect(RunService.RenderStepped,function(dt)
	if S.dead or S.mode=="MINI" then return end
	elapsed+=dt
	if elapsed>=1 then elapsed=0; UI.updateData() end
end)
local function cleanup()
	if S.dead then return end
	S.dead=true; S.epoch+=1; UI.drag=nil; UI.resize=nil
	for _,c in UI.connections do c:Disconnect() end; table.clear(UI.connections)
	for _,tween in UI.ambient do tween:Cancel() end; table.clear(UI.ambient)
	local objects={}; for object in pairs(UI.tweens) do table.insert(objects,object) end
	for _,object in objects do stop(object,false) end
	for thread in pairs(UI.tasks) do pcall(task.cancel,thread) end; table.clear(UI.tasks)
	for thread in pairs(UI.workers) do pcall(task.cancel,thread) end; table.clear(UI.workers)
	for _,bind in UI.hooks do bind.OnInvoke=nil end
end
connect(UI.gui.Destroying,cleanup)
if RunService:IsStudio() and host and host:IsA("LocalScript") then connect(host.Destroying,function() if UI.gui.Parent then UI.gui:Destroy() end end) end
-- Initialise after every callback and surface exists. English is the first-run default.
UI.refreshNav(); setLanguage(S.language); refreshStatus(); UI.updateData()
local initialSize,initialCenter=UI.geometry("HUB")
layoutHub(initialSize)
UI.window.Size=UDim2.fromOffset(initialSize.X*.88,initialSize.Y*.88)
UI.window.Position=UDim2.fromOffset(initialCenter.X,initialCenter.Y+22)
setMode("HUB")
