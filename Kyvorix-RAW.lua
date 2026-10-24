-- KYVORIX / CYBER CHROMA 7.1
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
	assetsNote={"Original shop artwork. Logo has an embedded 48px fallback; diagnostics distinguish it from the full PNG.","Ảnh gốc của shop. Logo có bản dự phòng 48px; chẩn đoán phân biệt rõ với PNG đầy đủ."},
	logoLoading={"Logo\nloading","Đang tải\nlogo"},logoMissing={"Logo\nunavailable","Logo\nchưa tải"},
	rasterImage={"Embedded 48px artwork","Ảnh nhúng 48px"},
	bootTitle={"Launch your HUB","Khởi động HUB"},bootSubtitle={"A quick, honest check before you begin.","Kiểm tra rõ ràng trước khi bắt đầu."},
	bootChecking={"Checking your session…","Đang kiểm tra phiên chơi…"},
	bootReady={"Ready to open KYVORIX.","Sẵn sàng mở KYVORIX."},
	bootReadyWarn={"Ready. Some optional data is unavailable.","Sẵn sàng. Một số dữ liệu tùy chọn chưa có."},
	bootEnvironment={"Client & interface","Client & giao diện"},bootCharacter={"Character","Nhân vật"},
	bootLevel={"Character level","Cấp độ nhân vật"},bootHealth={"Health","Sức khỏe"},
	bootWallet={"Beli & fragments","Beli & fragments"},bootArtwork={"Original artwork","Ảnh gốc"},bootKey={"Access key","Key truy cập"},
	checking={"CHECKING","ĐANG KIỂM TRA"},passed={"READY","SẴN SÀNG"},warning={"OPTIONAL","TÙY CHỌN"},
	skipped={"SKIPPED","BỎ QUA"},bootKeySkip={"Not enabled by the owner","Chủ sở hữu chưa bật"},
	bootDataMissing={"Not exposed by this game","Trò chơi chưa cung cấp dữ liệu"},
	bootCharMissing={"Character has not spawned yet","Nhân vật chưa xuất hiện"},
	bootLoad={"Load HUB","Mở HUB"},bootRetry={"Retry artwork","Thử lại ảnh"},
	bootDetails={"Diagnostics","Chẩn đoán"},bootBusy={"Checks are still running.","Các bước kiểm tra chưa hoàn tất."},
	bootDetailsPrinted={"Startup details printed to Output.","Đã in chi tiết khởi động vào Output."},
	bootNative={"Embedded logo active; full PNG unavailable","Logo nhúng đang dùng; PNG đầy đủ chưa tải"},
	bootAssetWarn={"Some artwork is unavailable","Một số ảnh chưa tải được"},
	shortHome={"Home","Chính"},shortProgress={"Progress","Tiến độ"},shortCombat={"Combat","Chiến đấu"},shortCollect={"Collect","Thu thập"},
	shortEvents={"Events","Sự kiện"},shortTravel={"Travel","Di chuyển"},shortSettings={"Settings","Cài đặt"},shortSystem={"Connect","Kết nối"},
}
local function tr(key)
	local pair=L[key]
	return pair and pair[S.language=="vi" and 2 or 1] or key
end
local UI={connections={},tweens={},tasks={},workers={},bindings={},updaters={},ambient={},gradients={},features={},assets={},assetJobs={},logoSlots={}}
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
	return thread
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
-- Original owner PNG data and an explicit lower-detail UI fallback.
-- Compiled from original owner PNG; 48px quantized fallback, one shared GUI pool.
local NATIVE_LOGO={size=48,palette={16777215,16580349,15331575,13560572,13426419,13554395,12570602,12109020,11515073,10078194,10203866,6670333,6337017,9938371,10265003,8561113,5613043,9476006,8754876,8818336,7836357,7768238,7897493,7110313,6780314,6844028,5739495,5606363,5669067,4556505,2393579,5534376,5466771,4026055,2387924,5596039,5988979,5528428,4546456,4676479,4608883,5001309,4018297,4344153,3950692,3301799,3299743,3297668,2318525,1922474,1724320,2771343,1394849,3426157,2508662,3162731,2964577,2441075,3817292,3619396,2963793,2503508,3027776,2632502,2305086,1851020,998799,734094,1848157,1127269,1715286,1845824,1190746,600678,599398,335205,861004,531275,1516609,794688,596544,2106675,1647415,1580331,1186864,727861,333125,333108,792106,398381,266545,134192,988191,659227,331296,592658,330264,133404,66854,132628,132108,66061,263172,197379,131588,262914,197378,197122,131586,66050,524800,197377,197121,131585,131584,32,12,6,65794,3,131329,65793,65537,1,262400,65792,65536,0},data=[[000001017eff0100060179ff0700010178ff0800010179ff090002017eff0b00030179ff0e00010178ff0f0002017eff1100010179ff1200010167ff1300020166ff150001016cff160001017dff1700020161ff190001017eff1a00010176ff1b00010167ff1c00010166ff1d0001016cff1e00030179ff2100010178ff2200020179ff240001017eff2500020179ff2700020178ff2900060179ff2f0001017eff0001010179ff0101040178ff050101016cff060101016bff070101016cff0801020178ff0a01020171ff0c0101026bff0d0102016cff0f01010167ff1001010166ff110101017dff120104017fff1601010175ff1701010120ff1801010126ff1901010175ff1a01010177ff1b0103017fff1e0101017eff1f01010166ff2001010167ff210101016cff2201010178ff230101017eff240101017aff2501010278ff260101016cff2701010171ff2801010278ff290102016cff2b01010176ff2c0101016cff2d01010171ff2e01010378ff2f01010279ff000201037eff0102010279ff0202020178ff0402020279ff060202016cff0802010171ff0902010170ff0a0201016aff0b02010170ff0d0201016cff0e02010179ff0f0202017fff1102010175ff1202010151ff1302010129ff1402010219ff1502010125ff1602010227ff170201010aff1802010112ff1902010135ff1a0201012bff1b02010124ff1c02010125ff1d02010151ff1e02010165ff1f0202017fff210201017dff2202010176ff2302020179ff2602010171ff270201016cff290201016cff2a02010171ff2b0203016cff0203020171ff0603010178ff0703030170ff0a03010171ff0b03010167ff0c03010170ff0d0301017eff0e0301017fff0f0301013fff1003010113ff1103020105ff130301010eff150301013bff1703010105ff1803010213ff190301012cff1a0301013fff1b03010119ff1c0302010eff1e03010108ff1f03010113ff200301013eff2103010175ff220301017fff2303010171ff2403010168ff2503020178ff2703010171ff280301016bff2903010171ff2a03020178ff2c0302016bff2f0301017eff0104010178ff020401016bff030401016cff0404010171ff0504010178ff0604020171ff0804020178ff0a0401016cff0b0401017eff0c0401017fff0d04010159ff0e04010118ff0f04010105ff1004010108ff1104010124ff1204010147ff1304010157ff1404010150ff1504010149ff1604010115ff1704010102ff1904010127ff1a04010156ff1b04010161ff1c04010162ff1d04010154ff1e04010129ff1f0401010eff2004010107ff2104010118ff2204010157ff2304010175ff240401017fff250401016cff2604010179ff2704010178ff2804010170ff290401016aff2a04010171ff2b04010178ff2c04010171ff2d0401016bff2e04010171ff2f04010479ff0005010179ff010501016cff0205020171ff040501016cff050501016bff0605010171ff0705010179ff080501016cff0905010170ff0a0501017fff0b05010159ff0c05010133ff0d05010146ff0e05010125ff0f05010152ff1005010144ff1105010136ff120501012fff1305010126ff140501014cff150501014dff1605010116ff1705010112ff1805010127ff190501013aff1a05020161ff1c0501011fff1d05010133ff1e05020149ff2005010155ff2105010129ff2205010152ff2305010136ff2405010157ff250501017fff2605010170ff270501016cff2805020171ff2a0501016cff2b05040171ff0006010178ff010602016cff0306010171ff0406010278ff0506010171ff0606010179ff0706010168ff080601017fff0906010177ff0a06010155ff0b0602011bff0d06010160ff0e06010148ff0f0601011cff1006010136ff1106010158ff120601013fff1306010208ff1406010158ff150601015eff1606010105ff1706010109ff180601012dff1906010117ff1a06010161ff1b06010158ff1c06010108ff1d06010153ff1e06010160ff1f06010145ff200601011cff2106010148ff2206010164ff2306010126ff240601011cff2506010155ff2606010177ff270601017fff2806010167ff2906010179ff2a06010171ff2b0601016aff2c06010171ff2d06010379ff2e06010371ff0007010679ff010701016cff020701026aff0307010270ff0507010179ff0607010167ff070701017fff0807010161ff0907010116ff0a07010125ff0b07010152ff0c07010149ff0d0701014fff0e0701015eff0f0701010dff100701010eff110701015eff120701013aff1407010105ff1507010207ff1607010103ff170701010cff1807010122ff190701010fff1a07010212ff1b07010105ff1c0701010dff1d07010151ff1e0701015fff1f0701010eff200701010dff210701015eff220701014fff2307010149ff2407010154ff250701013aff2607010118ff270701015eff280701017fff2907010167ff2a07010178ff2b07010171ff2c07010178ff0108010171ff0408010171ff0508010167ff060801017fff0708010158ff0808010108ff0908010102ff0a0801013fff0b08020156ff0d0801015dff0e08010152ff0f0801012aff1008010116ff110801013bff1208010124ff1308010212ff1408010102ff160801010dff1708010134ff1808010133ff1908010120ff1b08010102ff1c08010215ff1d0801012bff1e0801013eff1f08010116ff2008010138ff210801017fff2208010164ff2308010145ff2408010142ff2508010152ff2608010105ff2708010107ff2808010152ff290801017fff2a08010167ff2b08010179ff2c08010171ff2f08010278ff0109030171ff0409010166ff050901017fff0609010151ff0709010104ff0809010105ff090901013eff0a09010149ff0b0901015aff0c0901015cff0d09010135ff0e0901012fff0f0901015aff1009010115ff1109010125ff120901012cff1409010104ff150901010aff1609010106ff170901010dff180901011fff190901011cff1a0901010fff1b09010103ff1d0901013dff1e09010125ff1f09010114ff2009010163ff2109020158ff230901015dff240901014cff2509010142ff2609010147ff2709010108ff280901010dff2909010152ff2a0901017fff2b09010167ff2c09020171ff2e09010170ff010a01016cff020a010171ff030a01016aff040a01017dff050a01015dff060a010108ff070a010105ff080a010153ff090a010157ff0a0a010155ff0b0a01013dff0c0a01011fff0d0a010126ff0e0a010144ff0f0a010173ff100a010128ff110a010118ff120a010137ff130a010116ff140a010112ff150a010120ff160a01012cff170a01013cff180a010146ff190a010138ff1a0a010120ff1b0a01010dff1c0a010119ff1d0a010146ff1e0a010117ff1f0a01012cff200a01017fff210a010165ff220a010177ff230a01015eff240a010154ff250a010159ff260a010157ff270a01015cff280a010111ff290a01010dff2a0a010158ff2b0a01017fff2c0a01016cff2d0a010178ff2e0a010171ff2f0a010479ff010b020171ff030b01016bff040b010168ff050b010216ff060b010111ff070b01012cff080b01014bff090b01017cff0a0b010152ff0b0b010139ff0c0b01013dff0d0b02012fff0f0b010133ff100b01012eff110b010115ff120b010144ff130b010148ff140b01014cff150b010138ff160b02013cff180b01013eff190b010163ff1a0b010177ff1b0b010163ff1c0b01013fff1d0b01013aff1e0b010112ff1f0b01012bff200b01013bff210b01013cff220b010128ff230b01012bff240b010137ff250b010146ff260b01016eff270b010142ff280b01012aff290b010108ff2a0b010118ff2b0b010164ff2c0b010178ff2d0b010179ff2e0b01016cff010c010178ff020c010167ff030c01017fff040c01013eff060c01013aff070c010130ff080c010149ff090c010164ff0a0c010146ff0b0c010154ff0c0c010127ff0d0c010114ff0e0c01010fff0f0c010104ff100c010102ff110c010104ff120c020103ff140c010102ff150c010108ff160c010120ff170c010117ff180c01012aff190c010159ff1a0c01015fff1b0c01012aff1c0c01011cff1d0c01012dff1e0c01011dff1f0c01010cff200c01010bff210c010103ff220c010108ff230c010116ff240c01014eff250c01012fff260c010146ff270c01014cff280c01011eff290c010128ff2a0c010119ff2b0c01013eff2c0c01017bff2d0c01016cff2e0c010378ff000d01017dff010d01026cff020d010178ff030d010175ff040d01012cff050d010140ff060d01011fff070d010110ff080d010173ff090d010144ff0a0d010152ff0b0d010168ff0c0d010159ff0d0d010141ff0e0d010130ff0f0d01012dff100d010107ff110d010100ff120d010101ff130d010100ff140d010111ff150d010154ff160d010123ff170d01013dff180d01015cff190d01016dff1a0d01017bff1b0d010145ff1c0d010122ff1d0d020130ff1f0d01011bff200d010106ff210d010116ff220d01012cff230d010138ff240d01017fff250d01015cff260d01011fff270d01015aff280d02011dff2a0d01013eff2b0d01013cff2c0d010174ff2d0d01017eff000e010279ff020e01017fff030e010155ff040e010151ff050e010150ff060e01011eff070e01012fff080e010138ff090e01011fff0a0e01014eff0b0e01015dff0c0e010162ff0d0e01011dff0e0e020130ff100e010143ff110e010107ff120e020101ff140e010119ff150e01012cff160e01012fff170e01014fff180e01017eff190e010174ff1a0e010139ff1b0e02011eff1d0e01010bff1e0e010104ff1f0e010102ff200e01010eff210e02013fff230e01015dff240e010177ff250e01014fff260e010144ff270e020136ff290e01011eff2a0e010146ff2b0e010153ff2c0e010158ff2d0e01017fff2f0e01017dff010f01017eff020f010163ff030f010127ff040f01015cff050f010142ff060f010122ff070f010152ff080f010110ff090f010136ff0a0f010168ff0b0f010160ff0c0f01015bff0d0f01010cff0e0f010243ff0f0f01014aff100f010130ff110f010134ff120f010106ff130f010400ff140f010216ff150f010111ff160f010135ff170f010163ff180f010173ff190f01012eff1a0f020110ff1c0f01011dff1d0f010104ff1e0f010100ff1f0f010104ff200f010224ff210f01013fff220f01017dff230f02015fff250f01013dff260f010135ff270f010120ff280f01012cff290f010122ff2a0f010142ff2b0f01015fff2c0f010138ff2d0f010163ff2e0f01037fff2f0f010179ff001001016dff011001027fff0210010150ff0310010126ff041001013aff0510010157ff0610010155ff071001012fff0810010141ff0910010157ff0a10010158ff0b1001015eff0c1001014dff0d10010139ff0f10010144ff1010020222ff121001010cff1510010108ff161001012cff1710010162ff1810010121ff1910010110ff1a1001010bff1b10010103ff1c10020102ff1e10010108ff1f10010105ff2110010164ff2210010165ff2310010174ff241001015dff251001015cff2610020147ff281001015cff2910010152ff2a1001014fff2b1001013bff2c10010124ff2d10010152ff2f10010176ff0011010178ff0211010236ff0311010123ff041101012cff051101013cff061101013bff071102012fff0911010240ff0a1101015eff0b11010127ff0c1101011bff0d11010133ff0e11010152ff0f11010126ff1211010209ff1411010117ff151101011fff1611010139ff171101011aff1811020110ff1a11010103ff1b11010105ff1c11010116ff1d1101013eff1e11010119ff1f1101010dff2011010154ff211101015bff221101012eff231101012dff2411010161ff2511010166ff2611010147ff2711010137ff2811010152ff2911010153ff2a11010146ff2b1101012fff2c11010115ff2d11010223ff2f11010169ff001201017eff0112010161ff0312010125ff041201013cff051201013aff061201015cff071201015fff081201013aff0a1201015fff0b12010147ff0c12010133ff0d12010121ff0e12010145ff0f1201011cff1012010232ff1112010243ff141201021fff1512010133ff161201010fff171201010bff181201010aff1912010108ff1a12010119ff1b1201012cff1c12010152ff1d1201013fff1e1201012cff1f12010136ff2012010162ff2112010173ff2212010133ff231201010cff2412010162ff251201017fff2612010137ff271201013dff2812010138ff2912020120ff2b1201012eff2c12010117ff2e12010177ff2f12010171ff001301027fff0113010145ff0213010141ff0313010153ff0413010158ff0513010154ff0613010252ff0713010154ff0813010153ff0913010151ff0a1301012bff0b13010152ff0c13010159ff0d1301014dff0e13010157ff0f1301040fff121301010cff1313010201ff151301010fff1613010109ff1713010114ff181301011cff1913010139ff1a13010159ff1b1301013dff1c13010154ff1d1301015dff1e1301014dff1f13010234ff201301011dff2113020121ff2313010143ff2413010135ff2513010126ff261301014dff2713010159ff281301013dff2913010127ff2a1301012cff2b13010140ff2c13010147ff2d1301012eff2e13010151ff2f1301047fff011401012dff0214010122ff031401014dff041402014fff071401015eff0814010159ff091401014eff0a14010153ff0b14010140ff0c14010156ff0d14010162ff0e14010155ff1014010141ff111401014bff121401010fff141401010dff1514010105ff1614010107ff171402010cff191401011fff1a14010138ff1b14010156ff1c14010163ff1d14010174ff1e14010162ff201401010cff211401010bff2214010141ff2314010114ff2414010109ff251401010dff2614010120ff2714020121ff291401010fff2a1401012aff2b1401015eff2c1401015fff2d14010135ff2e1401015fff0015010277ff0115010131ff0215010110ff031501011aff0415010121ff051501012eff0615010149ff0715010133ff081501012dff091501011bff0a15010248ff0b1501015dff0c15010148ff0d15010156ff0e1501014eff1015010134ff1115010143ff121501010aff1315010102ff1415010140ff151501014aff1615010124ff171501010eff1815010105ff1915020103ff1b1501010aff1c15010136ff1d15010149ff1e1501011dff1f1501010cff2015010121ff211501014aff2215010112ff2315010118ff241501021bff251501011fff261501013cff2715010120ff2815010126ff2915020133ff2b15010150ff2c15010146ff2d15010147ff2e15010164ff0116010141ff0216010130ff0316020121ff0516010109ff061601010cff071601021dff0816010221ff091601011dff0b16010175ff0c1601014cff0d1601014aff0e16010152ff1016010130ff1116010122ff121601020fff1316010105ff141601023dff151601014bff1616010134ff171601014bff1816010150ff1916010125ff1a16010106ff1b16010102ff1c16010103ff1d1601010bff1e16010122ff1f16010141ff2016010262ff211601012cff2216010124ff2316010145ff251601011dff2616010146ff2716010154ff281601014eff2916010118ff2a1601010fff2b16010145ff2c16010140ff2d1601013cff2e16010159ff001701027fff0117010132ff0217010131ff0317010146ff0417010156ff0517010132ff061701010bff091701011bff0a1701014cff0b1701017fff0c17010136ff0d17010144ff0e17010151ff0f1701011aff101702011eff1317010108ff1517010152ff161701014aff171701011eff1817010130ff1917010143ff1a17010124ff1b17010104ff1c17010202ff1d17010104ff1e17010120ff1f17010161ff2117010147ff2217010154ff231701015eff2417010145ff2517010141ff261701014fff2717010139ff2817010121ff291701011bff2a17010114ff2b17010126ff2c1701024cff2d1702014dff2f17010179ff011801014bff021801011bff031801012fff041801015eff0518010156ff061802011aff081801011dff091801011aff0a18010150ff0b18010161ff0c1801021bff0d18010141ff0e18010148ff0f1802011eff1118010110ff121801011aff131801010dff141801012aff1518010128ff161801017fff1718010148ff1818020122ff1a18010134ff1b18010112ff1d18010101ff1e18010103ff1f18010117ff2018010158ff2118010174ff2218010175ff2318010177ff2418010175ff251801017bff2618010174ff2718010133ff2818020121ff2a18010117ff2b18010120ff2d1801011aff2e18010149ff2f1801017fff0019010163ff0119010114ff021901010cff0319010143ff0419010158ff0519010165ff0619010141ff071901010cff0819010149ff091901012eff0a1901015bff0b1901014dff0d1901010cff0e1901011bff0f19020110ff111901010bff1219010104ff131901010aff1419010127ff1519010118ff161901015dff171901017bff181901015bff191902011eff1b19010134ff1c1901011bff1d19010106ff1e19010101ff1f19010102ff201901011cff2119010157ff2219010161ff2319010155ff2419010150ff2519010159ff261901015fff2719010163ff281902014cff2a1901013cff2b1901012aff2c19010136ff2d19020109ff2f1901014fff001a010127ff011a010103ff021a010122ff031a010245ff041a01015aff051a010174ff061a010162ff071a010141ff081a01015bff091a010156ff0a1a01012dff0b1a01011fff0c1a01014bff0d1a01012eff0e1a010109ff0f1a01010bff101a010103ff111a010104ff121a010111ff131a010118ff141a010140ff151a010113ff161a010158ff171a02015fff191a010149ff1a1a03011eff1d1a010130ff1e1a010115ff1f1a020103ff211a01011bff221a01014aff231a010145ff241a010114ff251a01012dff261a010149ff271a010161ff281a01017fff291a010163ff2a1a010158ff2b1a01015cff2c1a01011cff2d1a010209ff2e1a01010aff2f1a010135ff001b010138ff011b010106ff021b01010cff041b010144ff051b010127ff061b02012fff081b01011fff091b01011aff0a1b010117ff0b1b010140ff0c1b01014eff0d1b010112ff0e1b020109ff101b010107ff111b010115ff121b010118ff131b010113ff141b010124ff151b01010dff161b010129ff171b010111ff181b010113ff191b010151ff1a1b01011dff1b1b01010bff1c1b010109ff1d1b01011aff1e1b01012dff1f1b01011cff201b020109ff221b01010cff231b010120ff241b010129ff251b010115ff261b01011bff271b01011fff281b010136ff291b010139ff2a1b010128ff2b1b010140ff2c1b01011fff2e1b01012eff2f1b01015eff001c010175ff011c010145ff021c01010fff031c01011bff041c010133ff051c01012aff061c010115ff071c010106ff081c01010dff091c010151ff0a1c01013aff0b1c010125ff0c1c01012bff0d1c010147ff0e1c010144ff0f1c01012fff101c010157ff111c010160ff121c01013fff131c01012bff141c010119ff151c01012bff161c010153ff171c010118ff181c010123ff191c01015cff1a1c010138ff1b1c010120ff1c1c010127ff1d1c01013cff1e1c01015eff1f1c010156ff201c010139ff211c010137ff221c01013eff231c030129ff261c010151ff271c010116ff281c010107ff291c010112ff2a1c01012cff2b1c010136ff2c1c010110ff2d1c01011dff2e1c010150ff2f1c01017fff001d010171ff011d010146ff021d010131ff031d010141ff041d010156ff051d01015eff061d010124ff071d010200ff081d010211ff091d01015cff0a1d010100ff0b1d010107ff0c1d01013eff0d1d010213ff0e1d010116ff0f1d01017bff101d010116ff111d010113ff121d010116ff131d010129ff141d01017fff151d010125ff161d010116ff171d01013eff181d010116ff191d01010eff1a1d010116ff1b1d010160ff1c1d010125ff1d1d010113ff1e1d01010eff1f1d010111ff201d01013fff211d01013aff221d010111ff231d01013aff241d01010eff251d010100ff261d01013bff271d01010eff281d010101ff291d01012cff2a1d01015dff2b1d010156ff2c1d010134ff2d1d01012dff2e1d010138ff2f1d010168ff001e010179ff011e010177ff021e010146ff031e01011cff041e010126ff051e010173ff061e010129ff091e020105ff0b1e010152ff0c1e01017fff0e1e010100ff0f1e01012bff101e010100ff111e010124ff121e020105ff141e010164ff151e010102ff161e020108ff181e010102ff191e010116ff1a1e010101ff1b1e01010eff1c1e010111ff1d1e010100ff1e1e010119ff1f1e020105ff211e010129ff221e010100ff231e01023bff241e01015dff251e020104ff271e010102ff281e01010eff291e010160ff2a1e01017bff2b1e010127ff2c1e010117ff2d1e010138ff2e1e010164ff2f1e01017dff001f01016cff011f01017fff021f010147ff031f010137ff041f010124ff051f01013eff061f01022bff071f010105ff081f010107ff091f010104ff0a1f010125ff0b1f01017fff0c1f010166ff0d1f01015fff0e1f010107ff0f1f010104ff101f010108ff111f01017fff121f010124ff131f010104ff141f01012bff151f010104ff161f01013aff171f010105ff181f010113ff191f01017fff1a1f020108ff1c1f010119ff1d1f010105ff1e1f01013cff1f1f01010dff201f010111ff211f01013bff221f010104ff241f01027fff251f010125ff261f010104ff271f010107ff281f01013dff291f01017fff2a1f01013cff2b1f010125ff2c1f01012aff2d1f010147ff2e1f01017fff2f1f010168ff0020010179ff0120010176ff0220010154ff0320010119ff0420010129ff052001017aff0720010123ff0820020119ff0a20010111ff0b20010140ff0c2001017eff0d2001027fff0e2001012bff0f20010113ff102001013eff112001017dff1220010153ff1320010118ff1420010111ff1520010118ff162001015eff172001010eff1820010127ff1920010173ff1a20010115ff1b20010118ff1c2001012cff1d20010115ff1e2002010fff202001013dff212001013fff2220010115ff232001013eff2520010119ff2620010118ff2720010119ff2820010135ff2920010164ff2a2001015aff2b20010139ff2c20010120ff2d20010158ff2e20010179ff2f20010176ff002101017eff0121010179ff022101017fff032101015cff0421020138ff0621010128ff072101010aff082101012bff092101013eff0a21010107ff0b2101010dff0c2101015eff0e21010125ff0f21010107ff102101013dff1121010168ff1221010164ff1321010115ff1421010106ff1521010126ff1621010163ff1721010112ff182102010fff1a21010109ff1b21010127ff1c21010120ff1d2101010aff1e21010138ff1f21010106ff2021010139ff212101014eff2221010206ff2321010140ff242101013cff2521010106ff2621010115ff2721010112ff282101010fff2921010156ff2a21010134ff2b21010133ff2c2101015cff2d2101017fff2e21010178ff2f2101027dff002201017dff0122020179ff032201017bff0422010155ff052201014fff0622010118ff0722010107ff0822010135ff0922010173ff0a22010115ff0b22010106ff0c22010114ff0d2201015dff0e22010118ff0f22010109ff1022010144ff112201017bff1222010175ff132201022aff142201011cff1522010145ff1622010162ff1722010143ff182201011aff1922010114ff1a22010126ff1b22010162ff1c22010126ff1d2201011cff1e22010157ff1f22010114ff202201010fff212201012aff2322010118ff242201010dff2522010107ff2622010140ff2722010118ff2822010106ff2922010131ff2a2201011eff2b2201014cff2c2201017fff2d2201016cff2e22010179ff002301017eff0123010178ff0223010167ff0323010179ff0423010148ff0523010136ff0623010112ff0723010109ff0823010126ff0923010150ff0a2301012cff0b23010123ff0c23010127ff0d23010154ff0e23010147ff0f23010146ff1023010147ff1123010138ff1223010227ff142301012eff1523010139ff1623010143ff172301010bff1823010110ff192301014bff1a23010146ff1b23010127ff1c23020133ff1e23010139ff1f23010156ff202301014eff2123020147ff232301012cff2423010127ff2523010123ff262301017fff272301012cff2823010109ff292301010fff2a23010121ff2b23010156ff2c23020176ff2e2301016cff2f23010779ff0024010179ff0124010171ff022401026cff032401017dff042401015eff052402011cff0724010144ff082401014eff0924010127ff0a2401012fff0b24010145ff0c2401014cff0d2401014eff0e2401013dff0f24010135ff102401012fff112401012aff132401011fff1424010109ff1524010104ff162401011cff172401011aff182401011dff192401011cff1a24010104ff1b2401010aff1c2401011fff1d2401012fff1e24020136ff2024010139ff2124010145ff2224010155ff2324020148ff2524010139ff2624010136ff272402014eff2924010121ff2a2401011cff2b24010158ff2c2401017eff2d24010168ff2e2401026bff002501027dff0125010178ff032501017fff0425010158ff052501014dff062501014aff0725010143ff0825020149ff0a2501014dff0b2501014cff0c25010145ff0d25010160ff0e2501025eff0f25010264ff1025010177ff1125010163ff122501017bff1325010175ff1425010159ff1525010127ff1625010112ff1725010126ff1825010133ff1925010118ff1a2501012fff1b25010155ff1c25010174ff1d2501017fff1e25010161ff1f2501015eff2025010157ff2125010161ff2225010163ff2325010150ff242501014fff2525010156ff262501014cff272501014fff2825010149ff292501014bff2a25010156ff2b25010154ff2c2501017fff2d2501016cff0126020178ff0326010179ff042602017fff0626010163ff0726010131ff082601011eff092601012dff0a26010117ff0b2601013eff0c26010159ff0d2601015aff1026010160ff112601014cff122601024fff1326010159ff1426010165ff1526010158ff1626010138ff1726010111ff1826010123ff192601014fff1a2601014eff1b26010174ff1c26010160ff1d2601014fff1e26010148ff1f26010145ff2026010148ff2126010146ff222601012eff232601015eff2426010153ff2526010119ff262601012cff2726010130ff282601012dff2926010163ff2a2602017fff2c2601017dff2d26010179ff2e2601016cff002701017eff0127010171ff022701016fff0327010170ff042701016cff0527020168ff0727010174ff082701012dff092701010bff0a2701010cff0b2701010dff0c2701013bff0d27010153ff0e27020146ff1027010161ff1127010164ff132701024cff1427010164ff1527010176ff162701015bff1727010123ff182701013cff1927010157ff1a27010139ff1b27010155ff1c27010159ff1d2701014cff1e27010145ff1f27010133ff202702011cff2227010135ff232701013fff2427010108ff252701010fff2627010134ff2727010145ff2827010165ff292701017fff2a27010168ff2b27010176ff2c27020179ff2e27010178ff002801017dff0128010278ff0228010170ff032801016aff0428010170ff0528010178ff062801016dff0728010166ff0828010173ff0928010133ff0a28010122ff0b28010121ff0c28010147ff0d2802013fff0f2801013cff1028010139ff112801014eff1228010159ff1428010163ff1528010159ff1628010157ff1728010144ff1828010146ff1928010162ff1a28020161ff1c28010157ff1d28010139ff1e2801012dff1f2801011cff2028010123ff212801013eff222801013fff2328010151ff2428010123ff252801014dff2628010162ff272801017fff2828020176ff2a28010178ff2b28030171ff2e2801016cff002901017eff022902016aff0429020170ff0629010171ff072901016dff0829010166ff0929010174ff0a29010173ff0b2901014dff0c29010145ff0d29010161ff0e2901013fff0f29010116ff1029010125ff112901013cff1229010158ff1329010150ff1429010139ff1529010145ff1629010141ff1729010121ff182901012dff1929020139ff1b29010136ff1c29010133ff1d29010136ff1e29010138ff1f2901022bff2029010116ff212901012bff2229010161ff2329010144ff242901015aff2529010168ff262901017eff272901016dff2829010178ff2929010171ff2a2901016aff2b2901016bff2c29010171ff2d29020170ff002a010179ff012a01016cff022a01016aff032a010170ff042a010171ff052a01026aff062a01016bff072a010176ff082a020168ff0a2a010172ff0b2a01017cff0c2a010158ff0d2a010148ff0e2a010123ff0f2a01010dff102a010116ff112a010129ff122a01013aff132a010151ff142a01013dff152a010133ff162a010132ff172a020121ff192a010131ff1a2a01012dff1b2a010135ff1c2a010140ff1d2a01013fff1e2a01013bff202a010113ff212a010112ff222a010148ff232a010159ff242a01016aff252a01017dff262a010176ff272a010178ff282a010171ff292a010170ff2a2a020171ff2c2a010278ff2d2a020371ff2f2a010278ff002b010178ff012b02016aff032b020170ff062b01016cff072b010179ff082b01017eff092b010179ff0a2b020176ff0c2b01017fff0d2b010176ff0e2b010158ff0f2b01012aff102b01012cff112b020151ff132b010153ff142b010141ff152b010110ff162b04010bff1a2b010110ff1b2b010141ff1c2b02015cff1e2b010153ff1f2b01013dff202b010137ff212b010152ff222b010164ff232b01017fff242b010179ff252b040178ff292b030171ff002c010279ff012c010171ff022c010170ff032c01016aff042c010171ff052c010170ff062c010171ff072c010178ff082c010179ff092c020171ff0b2c010179ff0c2c01016dff0d2c01017dff0e2c02017fff102c010161ff112c010150ff122c010145ff132c01014cff142c010149ff152c010134ff162c010130ff172c01011dff182c01011eff192c010130ff1a2c010132ff1b2c010145ff1c2c010150ff1d2c010148ff1e2c010155ff1f2c010161ff202c02017fff222c01017eff232c010168ff242c030178ff272c020179ff292c020171ff2b2c020178ff2f2c010279ff012d020170ff032d020171ff052d01016aff062d01016bff072d01016cff082d030171ff0b2d020178ff0d2d01016cff0e2d010167ff0f2d010166ff102d01017eff112d01017fff122d010163ff132d01015eff142d01015aff152d010150ff162d01014dff172d020143ff192d01014dff1a2d010157ff1b2d01015eff1c2d010161ff1d2d010164ff1e2d01017fff1f2d01017eff202d01016aff212d010167ff222d01016cff232d030171ff262d010170ff272d010171ff282d010179ff292d010178ff2a2d010171ff2b2d010178ff2c2d010171ff2d2d010170ff2e2d01016bff002e01027fff012e010171ff022e01016bff032e010170ff042e01016aff052e010166ff062e010167ff072e02016aff092e02016bff0b2e02016cff0d2e03016bff102e010167ff112e01016aff122e010172ff132e02017fff152e01017bff162e010177ff172e020165ff192e010177ff1a2e01017bff1b2e02017fff1d2e01017eff1e2e01016cff1f2e010167ff202e03016bff232e010171ff242e010178ff252e01016cff262e010167ff272e01016aff282e03016bff2b2e01016cff2c2e02016aff2e2e01016cff2f2e01017eff012f01017eff022f010179ff032f010178ff042f03016cff072f010178ff082f010179ff092f030178ff0c2f040179ff102f020178ff122f030179ff152f020176ff172f010179ff182f01017aff192f030176ff1c2f050179ff212f01017dff222f030179ff252f010178ff262f01016cff272f010171ff282f010179ff292f010178ff2a2f04016cff2e2f010179ff2f2f01017fff]]}

local function refreshAssetViews(kind)
	local job=UI.assetJobs[kind]
	if not job or S.dead then return end
	for _,entry in UI.assets[kind] or {} do
		entry.state=job.state; entry.source=job.source; entry.done=job.state=="loaded"
		if job.uri then entry.image.Image=job.uri end
		entry.image.Visible=job.state=="loaded" and job.source~="rasterImage"
		entry.fallback.Visible=job.state~="loaded"
		entry.fallback.Text=kind=="logo" and tr(job.state=="loading" and "logoLoading" or "logoMissing")
			or (job.state=="loading" and tr("imageLoading") or (tr("imageMissing").."\n"..tr("imageHelp")))
	end
	if UI.syncLogoSlot then UI.syncLogoSlot() end
	if UI.refreshBoot then UI.refreshBoot() end
end
function UI.syncLogoSlot()
	if not UI.nativeLogo then return end
	local job=UI.assetJobs.logo
	local slot=UI.logoSlots[S.mode]
	UI.nativeLogo.Visible=job and job.source=="rasterImage" and slot~=nil
	if slot then UI.nativeLogo.Parent=slot end
end
local function adoptImage(kind,uri,source,priority)
	local job=UI.assetJobs[kind]
	if S.dead or priority<(job.priority or 0) then return end
	job.uri=uri; job.source=source; job.priority=priority; job.state="loaded"
	if kind=="logo" and priority>=2 and UI.nativeLogo then
		UI.nativeLogo:Destroy(); UI.nativeLogo=nil; UI.nativeLogoNodes=0
	end
	refreshAssetViews(kind)
end
local function buildNativeLogo()
	if UI.nativeLogo or UI.nativeBuilding or option("NativeLogoFallback",true)==false then return end
	UI.nativeBuilding=true
	worker(function()
		if UI.assetJobs.logo and UI.assetJobs.logo.priority>=2 then UI.nativeBuilding=false; return end
		local pool=frame(UI.root,nil,1)
		pool.Name="EmbeddedOriginalLogo"; pool.Size=UDim2.fromScale(1,1); pool.Visible=false; pool.ZIndex=2
		UI.nativeLogo=pool
		local colors={}
		for i,packed in NATIVE_LOGO.palette do
			colors[i]=Color3.fromRGB(math.floor(packed/65536)%256,math.floor(packed/256)%256,packed%256)
		end
		local count=0
		for index=1,#NATIVE_LOGO.data,12 do
			if S.dead then UI.nativeBuilding=false; return end
			if UI.assetJobs.logo.priority>=2 then pool:Destroy(); UI.nativeLogo=nil; UI.nativeBuilding=false; return end
			local function byte(offset) return tonumber(NATIVE_LOGO.data:sub(index+offset,index+offset+1),16) end
			local x,y,w,h,paletteIndex,opacity=byte(0),byte(2),byte(4),byte(6),byte(8),byte(10)
			local pixel=frame(pool,colors[paletteIndex+1],1-opacity/255)
			pixel:SetAttribute("OriginalArtwork",true)
			pixel.Position=UDim2.fromScale(x/NATIVE_LOGO.size,y/NATIVE_LOGO.size)
			pixel.Size=UDim2.fromScale(w/NATIVE_LOGO.size,h/NATIVE_LOGO.size)
			count+=1
			if count%128==0 then task.wait() end
		end
		UI.nativeBuilding=false
		if UI.assetJobs.logo.priority>=2 then pool:Destroy(); UI.nativeLogo=nil; return end
		UI.nativeLogoNodes=count
		adoptImage("logo",nil,"rasterImage",1)
	end)
end
function UI.startAsset(kind)
	local job=UI.assetJobs[kind]
	if not job or S.dead then return end
	if job.generation and os.clock()<(job.nextRetryAt or 0) then return false end
	job.nextRetryAt=os.clock()+3
	for _,thread in job.threads or {} do
		if UI.workers[thread] then pcall(task.cancel,thread); UI.workers[thread]=nil end
	end
	job.threads={}
	for _,old in job.probes or {} do
		if old.connection then
			old.connection:Disconnect()
			local index=table.find(UI.connections,old.connection)
			if index then table.remove(UI.connections,index) end
		end
		old.image:Destroy()
	end
	job.probes={}
	if job.timeout and UI.tasks[job.timeout] then pcall(task.cancel,job.timeout); UI.tasks[job.timeout]=nil end
	job.generation=(job.generation or 0)+1
	local generation=job.generation
	if job.state~="loaded" then job.state="loading" end
	job.errors={}
	local function record(code,err)
		table.insert(job.errors,{code=code,detail=tostring(err or ""):sub(1,180)})
	end
	local function jobWorker(callback)
		local thread=worker(callback); table.insert(job.threads,thread); return thread
	end
	local function tryUri(uri,source,priority)
		local probe=make("ImageLabel",UI.root,{Name="ArtworkProbe_"..kind,Image=uri,BackgroundTransparency=1,Size=UDim2.fromOffset(1,1),Visible=false})
		local handle={image=probe}
		table.insert(job.probes,handle)
		local function retire()
			if handle.retired then return end
			handle.retired=true
			if handle.connection then
				handle.connection:Disconnect()
				local index=table.find(UI.connections,handle.connection)
				if index then table.remove(UI.connections,index) end
			end
			local index=table.find(job.probes,handle)
			if index then table.remove(job.probes,index) end
			probe:Destroy()
		end
		local function loaded()
			if not S.dead and not handle.retired and job.generation==generation and probe.IsLoaded then
				adoptImage(kind,uri,source,priority); retire()
			end
		end
		handle.connection=connect(probe:GetPropertyChangedSignal("IsLoaded"),loaded)
		jobWorker(function()
			local ok,err=pcall(function() ContentProvider:PreloadAsync({probe}) end)
			if S.dead or job.generation~=generation then return end
			if not ok then record("preload",err) end
			loaded()
		end)
	end
	local raw=option(kind=="logo" and "KyvorixLogoAsset" or "KyvorixPortalAsset","")
	local digits=tostring(raw):match("^rbxassetid://(%d+)$") or tostring(raw):match("^(%d+)$")
	if digits and option("KyvorixAssetsAuthorized",false)==true then tryUri("rbxassetid://"..digits,"robloxImage",3) end
	jobWorker(function()
		local customAsset=type(getcustomasset)=="function" and getcustomasset or (type(getsynasset)=="function" and getsynasset or nil)
		if option("LocalArtwork",true)==false then record("local_disabled"); return end
		if not customAsset or type(writefile)~="function" then record("local_capability_missing"); return end
		local url="https://raw.githubusercontent.com/VnTotalGui/kyvorix-hub/main/"..kind..".png"
		local function valid(bytes)
			return type(bytes)=="string" and #bytes>8 and #bytes<8*1024*1024 and bytes:sub(1,8)=="\137PNG\r\n\26\n"
		end
		local ok,bytes=pcall(function() return game:HttpGet(url) end)
		if not ok or not valid(bytes) then
			record("http_get",ok and "Invalid PNG response" or bytes)
			local requestFn=type(request)=="function" and request or (type(http_request)=="function" and http_request or nil)
			if requestFn then
				local requestOk,response=pcall(requestFn,{Url=url,Method="GET"})
				if requestOk and type(response)=="table" and valid(response.Body) then bytes=response.Body; ok=true
				else record("http_request",requestOk and "Invalid PNG response" or response) end
			end
		end
		if S.dead or job.generation~=generation then return end
		if not ok or not valid(bytes) then record("png_unavailable"); return end
		local fileName="kyvorix-owned-"..kind.."-v71.png"
		local stored,uri=pcall(function() writefile(fileName,bytes); return customAsset(fileName) end)
		if S.dead or job.generation~=generation then return end
		if stored and type(uri)=="string" and #uri>0 then tryUri(uri,"localImage",2) else record("custom_asset",uri) end
	end)
	if kind=="logo" then
		if UI.nativeLogo and job.source=="rasterImage" then refreshAssetViews(kind) else buildNativeLogo() end
	end
	job.timeout=later(12,function()
		if job.generation~=generation or job.state=="loaded" then return end
		job.state="failed"; record("timeout"); refreshAssetViews(kind)
	end)
	refreshAssetViews(kind)
end
local function imagePanel(parent,kind)
	local holder=frame(parent,Color3.fromRGB(5,10,27),.1); holder.ClipsDescendants=true; round(holder,12)
	local image=make("ImageLabel",holder,{Name="Original_"..kind,Image="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ScaleType=Enum.ScaleType.Fit,Visible=false})
	local fallback=label(holder,kind=="logo" and "logoLoading" or "imageLoading",kind=="logo" and 7 or 11,C.muted)
	fallback.Position=UDim2.fromOffset(4,4); fallback.Size=UDim2.new(1,-8,1,-8); fallback.TextXAlignment=Enum.TextXAlignment.Center
	local entry={state="loading",source="",image=image,fallback=fallback,done=false,holder=holder}
	UI.assets[kind]=UI.assets[kind] or {}; table.insert(UI.assets[kind],entry)
	UI.assetJobs[kind]=UI.assetJobs[kind] or {state="loading",source="",priority=0,errors={}}
	table.insert(UI.updaters,function() refreshAssetViews(kind) end)
	return holder,image,fallback
end

-- Header and Windows-style controls: minimize / status / close.
UI.header=frame(UI.hub,C.bg,.1)
UI.logo=imagePanel(UI.header,"logo"); rect(UI.logo,16,13,40,40)
UI.logoSlots.HUB=UI.logo
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
		if o:IsA("GuiObject") and not o:GetAttribute("OriginalArtwork") then o.BackgroundColor3=color(o.BackgroundColor3) end
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
UI.miniRestore=button(UI.mini,"",false,function() setMode("HUB") end,"MiniRestore",true)
UI.miniRestore.Size=UDim2.fromScale(1,1)
UI.miniLogo=imagePanel(UI.miniRestore,"logo"); rect(UI.miniLogo,4,4,48,48)
UI.logoSlots.MINI=UI.miniLogo
UI.bootSurface=make("CanvasGroup",UI.window,{
	Name="BootSurface",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false,GroupTransparency=1,ZIndex=3,
})
UI.bootState={ready=false,checks={},keyState="skipped",started=os.clock(),warnings=false}
UI.bootLogo=imagePanel(UI.bootSurface,"logo"); rect(UI.bootLogo,18,18,64,64)
UI.logoSlots.BOOT=UI.bootLogo
UI.bootTitle=label(UI.bootSurface,"bootTitle",22,C.text,true)
UI.bootSubtitle=label(UI.bootSurface,"bootSubtitle",11,C.muted)
UI.bootClose=button(UI.bootSurface,"×",false,function() UI.gui:Destroy() end,"BootClose",true)
UI.bootLanguage=button(UI.bootSurface,"EN / VI",false,function() setLanguage(S.language=="en" and "vi" or "en") end,"BootLanguage",true)
UI.bootProgressTrack=frame(UI.bootSurface,C.card); round(UI.bootProgressTrack,3)
UI.bootProgress=frame(UI.bootProgressTrack,Color3.new(1,1,1)); UI.bootProgress.Size=UDim2.fromScale(0,1); round(UI.bootProgress,3); gradient(UI.bootProgress)
UI.bootSummary=label(UI.bootSurface,"bootChecking",11,C.cyan,true)
UI.bootChecksScroll=make("ScrollingFrame",UI.bootSurface,{
	Name="StartupChecks",BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,294),
	ScrollBarThickness=2,ScrollBarImageColor3=C.cyan,
})
UI.bootRows={}
UI.bootCheckOrder={"environment","character","level","health","wallet","artwork","key"}
for i,id in UI.bootCheckOrder do
	local key={environment="bootEnvironment",character="bootCharacter",level="bootLevel",health="bootHealth",wallet="bootWallet",artwork="bootArtwork",key="bootKey"}
	local row=frame(UI.bootChecksScroll,C.card,.25); round(row,8)
	row.Position=UDim2.fromOffset(0,(i-1)*42); row.Size=UDim2.new(1,-6,0,36)
	local title=label(row,key[id],10,C.text,true); rect(title,10,3,170,14); title.Size=UDim2.new(1,-100,0,14)
	local value=label(row,"checking",8,C.muted); rect(value,10,18,260,14); value.Size=UDim2.new(1,-20,0,14)
	UI.bootRows[id]={row=row,title=title,value=value}
end
UI.bootLoad,UI.bootLoadCaption=button(UI.bootSurface,"bootLoad",true,function()
	if not UI.bootState.ready then notify("bootBusy"); return end
	setMode("HUB")
end,"BootLoadHub")
UI.bootRetry=button(UI.bootSurface,"bootRetry",false,function()
	UI.startAsset("logo"); UI.startAsset("portal"); UI.refreshBoot()
end,"BootRetryArtwork")
UI.bootDetails=button(UI.bootSurface,"bootDetails",false,function()
	print(HttpService:JSONEncode(UI.diagnostics()))
	UI.bootSummary.Text=tr("bootDetailsPrinted")
end,"BootDiagnostics")
function UI.layoutBoot(size)
	local w,h=size.X,size.Y
	rect(UI.bootTitle,96,19,math.max(70,w-146),28)
	rect(UI.bootSubtitle,96,49,math.max(70,w-114),40)
	rect(UI.bootClose,w-42,12,28,26)
	rect(UI.bootLanguage,w-91,92,73,24)
	rect(UI.bootProgressTrack,18,105,w-127,3)
	rect(UI.bootSummary,18,124,w-36,37)
	rect(UI.bootChecksScroll,18,170,w-36,math.max(44,h-282))
	rect(UI.bootLoad,18,h-94,w-36,35)
	rect(UI.bootRetry,18,h-48,(w-46)/2,30)
	rect(UI.bootDetails,28+(w-46)/2,h-48,(w-46)/2,30)
end
function UI.refreshBoot()
	if S.dead then return end
	local checks=UI.bootState.checks
	local function check(id,state,value) checks[id]={state=state,value=value} end
	check("environment","passed","Roblox client / PlayerGui")
	local character=player.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	local waiting=not humanoid and os.clock()-UI.bootState.started<8
	check("character",humanoid and "passed" or (waiting and "checking" or "warning"),humanoid and character.Name or tr("bootCharMissing"))
	local data=player:FindFirstChild("Data")
	local function scalar(name)
		local v=data and data:FindFirstChild(name)
		if v and v:IsA("ValueBase") then
			local ok,value=pcall(function() return v.Value end)
			if ok and (type(value)=="string" or type(value)=="number") then return tostring(value) end
		end
	end
	local level=scalar("Level")
	check("level",level and "passed" or (waiting and "checking" or "warning"),level or tr("bootDataMissing"))
	check("health",humanoid and "passed" or (waiting and "checking" or "warning"),humanoid and string.format("%.0f / %.0f",humanoid.Health,humanoid.MaxHealth) or tr("bootDataMissing"))
	local beli,fragments=scalar("Beli"),scalar("Fragments")
	check("wallet",(beli and fragments) and "passed" or (waiting and "checking" or "warning"),(beli or "—").." / "..(fragments or "—"))
	local logo,portal=UI.assetJobs.logo,UI.assetJobs.portal
	local artPending=(logo and logo.state=="loading") or (portal and portal.state=="loading")
	local artComplete=logo and portal and logo.state=="loaded" and portal.state=="loaded"
	local artDetail=artComplete and tr("loaded") or (artPending and tr("imageLoading") or tr("bootAssetWarn"))
	if logo and logo.source=="rasterImage" and not artPending then artDetail=tr("bootNative") end
	check("artwork",artPending and "checking" or (artComplete and "passed" or "warning"),artDetail)
	check("key","skipped",tr("bootKeySkip"))
	local done,warnings=0,false
	for _,id in UI.bootCheckOrder do
		local entry=checks[id]
		if entry.state~="checking" then done+=1 end
		if entry.state=="warning" then warnings=true end
		UI.bootRows[id].value.Text=tr(entry.state).."  /  "..tostring(entry.value)
		UI.bootRows[id].value.TextColor3=entry.state=="warning" and C.gold or (entry.state=="passed" and C.cyan or C.muted)
	end
	UI.bootState.ready=done==#UI.bootCheckOrder; UI.bootState.warnings=warnings
	UI.bootLoad.Active=UI.bootState.ready; UI.bootLoad.Selectable=UI.bootState.ready
	UI.bootLoadCaption.Text=tr(UI.bootState.ready and "bootLoad" or "bootChecking")
	UI.bootSummary.Text=tr(UI.bootState.ready and (warnings and "bootReadyWarn" or "bootReady") or "bootChecking")
	animate(UI.bootProgress,{Size=UDim2.fromScale(done/#UI.bootCheckOrder,1)},.15)
end
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
	if UI.refreshBoot then UI.refreshBoot() end
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
		local size=Vector2.new(56,56)
		local leftGap=math.clamp(tonumber(option("LeftInset",6)) or 6,4,8)
		return size,Vector2.new(leftGap+size.X/2,leftGap+size.Y/2)
	elseif mode=="BOOT" then
		local size=Vector2.new(math.min(480,vp.X-24),math.min(580,vp.Y-24))
		return size,vp/2
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
	assert(mode=="HUB" or mode=="STATUS" or mode=="MINI" or mode=="BOOT","Unsupported window mode")
	if S.dead then return false end
	S.epoch+=1; local epoch=S.epoch
	S.mode=mode; S.transitioning=true; UI.drag=nil; UI.resize=nil
	stop(UI.window,false)
	for _,surface in {UI.hub,UI.status,UI.mini,UI.bootSurface} do stop(surface,false) end
	refreshEffects()
	local size,center=UI.geometry(mode)
	if mode=="HUB" then layoutHub(size) elseif mode=="STATUS" then layoutCompact(size) elseif mode=="BOOT" then UI.layoutBoot(size) end
	UI.window.Visible=true
	UI.scrim.Visible=mode=="HUB" or mode=="BOOT"
	animate(UI.scrim,{BackgroundTransparency=(mode=="HUB" or mode=="BOOT") and .72 or 1},.18)
	local target=mode=="HUB" and UI.hub or (mode=="STATUS" and UI.status or (mode=="BOOT" and UI.bootSurface or UI.mini))
	local function finish()
		if S.dead or S.epoch~=epoch then return end
		UI.window.Size=UDim2.fromOffset(size.X,size.Y); UI.window.Position=UDim2.fromOffset(center.X,center.Y)
		for _,surface in {UI.hub,UI.status,UI.mini,UI.bootSurface} do surface.Visible=surface==target; surface.GroupTransparency=surface==target and 0 or 1 end
		UI.syncLogoSlot()
		S.transitioning=false; refreshEffects(); refreshStatus()
	end
	if instant or S.fast or S.reduced then finish(); return true end
	for _,surface in {UI.hub,UI.status,UI.mini,UI.bootSurface} do if surface.Visible then animate(surface,{GroupTransparency=1},.10) end end
	animate(UI.window,{Size=UDim2.fromOffset(size.X,size.Y),Position=UDim2.fromOffset(center.X,center.Y)},.48)
	later(.16,function()
		if S.epoch~=epoch then return end
		for _,surface in {UI.hub,UI.status,UI.mini,UI.bootSurface} do surface.Visible=surface==target end
		UI.syncLogoSlot()
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
	if S.mode=="BOOT" then return end
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
	return {build="KYVORIX Client UI 7.1",language=S.language,mode=S.mode,page=S.page,transitioning=S.transitioning,boot=UI.bootState,
		fast=S.fast,reduced=S.reduced,aura=S.aura,particles=S.particles,features=UI.featureCount(),assets=assets,
		window={width=UI.window.Size.X.Offset,height=UI.window.Size.Y.Offset,x=UI.window.Position.X.Offset,y=UI.window.Position.Y.Offset},
		artworkErrors={logo=UI.assetJobs.logo.errors,portal=UI.assetJobs.portal.errors},nativeLogoNodes=UI.nativeLogoNodes or 0,
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
	if elapsed>=1 then
		elapsed=0; UI.updateData()
		if S.mode=="BOOT" then UI.refreshBoot() end
	end
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
local initialMode=option("ShowBootMenu",true)==false and "HUB" or "BOOT"
local hubSize=UI.geometry("HUB")
layoutHub(hubSize)
local initialSize,initialCenter=UI.geometry(initialMode)
if initialMode=="BOOT" then UI.hub.Visible=false; UI.bootSurface.Visible=true; UI.layoutBoot(initialSize) end
UI.window.Size=UDim2.fromOffset(initialSize.X*.88,initialSize.Y*.88)
UI.window.Position=UDim2.fromOffset(initialCenter.X,initialCenter.Y+22)
UI.startAsset("logo"); UI.startAsset("portal")
UI.refreshBoot()
setMode(initialMode)
