-- KYVORIX / CYBER CHROMA 7.2
-- Standalone client UI; no gameplay automation, hooks or protection bypass.
-- Optional KYVORIX_UI_CONFIG: Language, RightInset, LeftInset, BottomInset, KyvorixLogoAsset,
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
local LANGUAGE_ORDER={"en","vi","id","es","pt","fr"}
local LANGUAGES={
	en={country="United Kingdom",native="English",title="Choose language",code="GB"},
	vi={country="Việt Nam",native="Tiếng Việt",title="Chọn ngôn ngữ",code="VN"},
	id={country="Indonesia",native="Bahasa Indonesia",title="Pilih bahasa",code="ID"},
	es={country="España",native="Español",title="Elegir idioma",code="ES"},
	pt={country="Portugal",native="Português",title="Escolher idioma",code="PT"},
	fr={country="France",native="Français",title="Choisir la langue",code="FR"},
}

local S={
	language="en",mode="HUB",page="home",transitioning=false,fast=false,reduced=false,aura=true,
	particles=true,palette=1,dead=false,epoch=0,hubCenter=nil,hubSize=nil,
}
local savedLanguage=playerGui:GetAttribute("KyvorixLanguage")
if LANGUAGES[savedLanguage] then S.language=savedLanguage
elseif LANGUAGES[option("Language","en")] then S.language=option("Language","en") end
local C={
	bg=Color3.fromRGB(4,7,20),panel=Color3.fromRGB(10,16,36),card=Color3.fromRGB(17,24,46),
	line=Color3.fromRGB(49,66,96),text=Color3.fromRGB(234,243,255),muted=Color3.fromRGB(192,207,228),
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
	language={"Hub language","Ngôn ngữ HUB"},languageDesc={"English by default. Choose from six interface languages.","Tiếng Anh mặc định. Chọn một trong sáu ngôn ngữ giao diện."},
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
local EXTRA_TRANSLATIONS={
	id={
		home="Dasbor",
		progress="Progres",
		combat="Pertempuran",
		collect="Koleksi",
		events="Laut & Acara",
		travel="Perjalanan",
		settings="Pengaturan",
		system="Koneksi",
		explore="SEMESTAMU",
		edition="CYBER CHROMA / HUB",
		eyebrow="PERJALANAN BARUMU DIMULAI DI SINI",
		headline1="Bermainlah sepenuh hati.",
		headline2="Raih ketinggian baru.",
		intro="Tujuanmu. Perjalananmu. Satu ruang KYVORIX untuk antarmuka, informasi karakter, dan langkah selanjutnya.",
		discover="Jelajahi HUB",
		personalize="Sesuaikan gayamu",
		nextworld="KYVORIX / DUNIA BERIKUTNYA",
		world="Dunia berikutnya menantimu.",
		chapter="BAB BERIKUTNYA",
		ready="Siap saat kamu siap.",
		character="KARAKTERMU",
		level="LEVEL",
		beli="BELI",
		fragments="FRAGMENTS",
		health="KESEHATAN",
		unavailable="Tidak tersedia",
		live="HANYA BACA / LANGSUNG",
		workspace="Ruangmu. Ritmemu.",
		workspaceDesc="Sesuaikan warna dan gerakan. Pantau hal penting di KYVORIX STATUS.",
		toStatus="Buka status ringkas",
		themeTag="CHROME / CYAN / MAGENTA",
		pending="BELUM TERHUBUNG",
		pendingDesc="Halaman ini belum memiliki callback gameplay yang diizinkan. Membukanya tidak menjalankan tindakan.",
		progressDesc="Data karakter diperbarui di dasbor. Pelacakan pesanan shop menunggu API yang diizinkan.",
		settingsDesc="Lebih sesuai gayamu. Setiap perubahan langsung memperbarui status.",
		reduced="Kurangi gerakan",
		reducedDesc="Transisi langsung tanpa gerakan latar.",
		fast="Mode cepat",
		fastDesc="Dekorasi lebih sedikit, antarmuka lebih ringan, respons langsung.",
		aura="Aura & orbit",
		auraDesc="Cahaya cyan dan magenta berlapis di sekitar gambar.",
		particles="Percikan latar",
		particlesDesc="Sekumpulan kecil titik cahaya yang bergerak lembut.",
		palette="Palet warna",
		paletteDesc="Ubah warna aksen di seluruh HUB.",
		on="AKTIF",
		off="NONAKTIF",
		sunset="Senja",
		language="Bahasa HUB",
		languageDesc="Bahasa Inggris secara bawaan. Pilih bahasa antarmuka di sini.",
		save="Simpan sesi",
		saveDesc="Simpan preferensi antarmuka untuk sesi bermain ini.",
		restore="Pulihkan sesi",
		restoreDesc="Pulihkan preferensi antarmuka yang tersimpan.",
		reset="Atur ulang tampilan",
		resetDesc="Pulihkan warna dan efek tanpa mengubah bahasa.",
		size="Ukuran jendela",
		sizeDesc="Ubah ukuran dari sudut kanan bawah atau tombol ini.",
		smaller="Lebih kecil",
		larger="Lebih besar",
		saved="Preferensi sesi tersimpan.",
		restored="Preferensi sesi dipulihkan.",
		badProfile="Tidak ada sesi tersimpan yang valid.",
		error="Antarmuka tidak dapat menyelesaikan tindakan itu.",
		connections="KONEKSI & GAMBAR ASLI",
		apiWait="Login shop, pesanan, dukungan, dan pembayaran menunggu API yang diizinkan.",
		imageLoading="Memuat gambar asli…",
		imageMissing="Gambar tidak tersedia",
		imageHelp="Periksa sumber gambar dan akses asset.",
		loaded="Dimuat",
		loading="Memuat",
		failed="Tidak tersedia",
		localImage="PNG pemilik / asset lokal",
		robloxImage="Asset gambar Roblox",
		logo="Logo",
		portal="Portal",
		print="Cetak diagnostik",
		printed="Diagnostik antarmuka dicetak ke Output.",
		footer="KYVORIX / Antarmuka saja",
		statusTitle="KYVORIX STATUS",
		active="AKTIF",
		none="Tidak ada fitur aktif",
		features="FITUR",
		interface="ANTARMUKA",
		open="Buka HUB",
		statusHint="Pengaturan langsung · ketuk untuk membuka",
		minimize="Perkecil ke tombol pembuka",
		compact="Beralih ke STATUS",
		close="Tutup HUB",
		destroy="Hapus antarmuka",
		destroyDesc="Putuskan event dan hapus HUB ini.",
		assetsNote="Gambar asli shop. Logo memiliki cadangan 48px tersemat; diagnostik membedakannya dari PNG penuh.",
		logoLoading="Logo\nmemuat",
		logoMissing="Logo\ntidak tersedia",
		rasterImage="Gambar tersemat 48px",
		bootTitle="Mulai HUB-mu",
		bootSubtitle="Pemeriksaan singkat dan jelas sebelum memulai.",
		bootChecking="Memeriksa sesimu…",
		bootReady="Siap membuka KYVORIX.",
		bootReadyWarn="Siap. Beberapa data opsional tidak tersedia.",
		bootEnvironment="Client & antarmuka",
		bootCharacter="Karakter",
		bootLevel="Level karakter",
		bootHealth="Kesehatan",
		bootWallet="Beli & fragments",
		bootArtwork="Gambar asli",
		bootKey="Key akses",
		checking="MEMERIKSA",
		passed="SIAP",
		warning="OPSIONAL",
		skipped="DILEWATI",
		bootKeySkip="Belum diaktifkan pemilik",
		bootDataMissing="Tidak disediakan game ini",
		bootCharMissing="Karakter belum muncul",
		bootLoad="Muat HUB",
		bootRetry="Coba lagi gambar",
		bootDetails="Diagnostik",
		bootBusy="Pemeriksaan masih berjalan.",
		bootDetailsPrinted="Detail startup dicetak ke Output.",
		bootNative="Logo tersemat aktif; PNG penuh tidak tersedia",
		bootAssetWarn="Beberapa gambar tidak tersedia",
		shortHome="Beranda",
		shortProgress="Progres",
		shortCombat="Tempur",
		shortCollect="Koleksi",
		shortEvents="Acara",
		shortTravel="Jelajah",
		shortSettings="Setelan",
		shortSystem="Koneksi",
	},
	es={
		home="Panel",
		progress="Progreso",
		combat="Combate",
		collect="Colección",
		events="Mar y eventos",
		travel="Viajes",
		settings="Ajustes",
		system="Conexiones",
		explore="TU UNIVERSO",
		edition="CYBER CHROMA / HUB",
		eyebrow="TU PRÓXIMO VIAJE EMPIEZA AQUÍ",
		headline1="Juega al máximo.",
		headline2="Alcanza nuevas metas.",
		intro="Tus metas. Tu camino. Un espacio KYVORIX para tu interfaz, los datos de tu personaje y tu próximo paso.",
		discover="Explora tu HUB",
		personalize="Personalízalo",
		nextworld="KYVORIX / NUEVO MUNDO",
		world="Tu próximo mundo te espera.",
		chapter="EL SIGUIENTE CAPÍTULO",
		ready="Listo cuando tú lo estés.",
		character="TU PERSONAJE",
		level="NIVEL",
		beli="BELI",
		fragments="FRAGMENTOS",
		health="SALUD",
		unavailable="No disponible",
		live="SOLO LECTURA / EN VIVO",
		workspace="Tu espacio. Tu ritmo.",
		workspaceDesc="Ajusta colores y movimiento. Consulta lo importante en KYVORIX STATUS.",
		toStatus="Ver estado compacto",
		themeTag="CROMO / CIAN / MAGENTA",
		pending="SIN CONEXIÓN",
		pendingDesc="Esta página no tiene un callback de juego autorizado. Abrirla no inicia ninguna acción.",
		progressDesc="Los datos del personaje se actualizan en el panel. El seguimiento de pedidos espera una API autorizada.",
		settingsDesc="Dale tu estilo. Cada cambio actualiza el estado al instante.",
		reduced="Reducir movimiento",
		reducedDesc="Transiciones instantáneas sin movimiento ambiental.",
		fast="Modo rápido",
		fastDesc="Menos decoración, interfaz más ligera y respuesta inmediata.",
		aura="Aura y órbitas",
		auraDesc="Luz cian y magenta en capas alrededor de la imagen.",
		particles="Destellos ambientales",
		particlesDesc="Un pequeño grupo limitado de luces que se mueven suavemente.",
		palette="Paleta de colores",
		paletteDesc="Cambia los colores de acento de todo el HUB.",
		on="SÍ",
		off="NO",
		sunset="Atardecer",
		language="Idioma del HUB",
		languageDesc="Inglés por defecto. Elige aquí el idioma de la interfaz.",
		save="Guardar sesión",
		saveDesc="Guarda las preferencias de interfaz durante esta sesión.",
		restore="Restaurar sesión",
		restoreDesc="Restaura las preferencias de interfaz guardadas.",
		reset="Restablecer apariencia",
		resetDesc="Restaura colores y efectos sin cambiar el idioma.",
		size="Tamaño de ventana",
		sizeDesc="Arrastra la esquina inferior derecha o usa estos controles.",
		smaller="Más pequeño",
		larger="Más grande",
		saved="Preferencias de sesión guardadas.",
		restored="Preferencias de sesión restauradas.",
		badProfile="No hay una sesión guardada válida.",
		error="La interfaz no pudo completar esa acción.",
		connections="CONEXIONES E IMÁGENES ORIGINALES",
		apiWait="El acceso a la tienda, los pedidos, el soporte y los pagos esperan una API autorizada.",
		imageLoading="Cargando imágenes originales…",
		imageMissing="Imagen no disponible",
		imageHelp="Comprueba el origen y el acceso de la imagen.",
		loaded="Cargado",
		loading="Cargando",
		failed="No disponible",
		localImage="PNG del propietario / recurso local",
		robloxImage="Recurso de imagen Roblox",
		logo="Logo",
		portal="Portal",
		print="Mostrar diagnóstico",
		printed="Diagnóstico de interfaz enviado a Output.",
		footer="KYVORIX / Solo interfaz",
		statusTitle="KYVORIX STATUS",
		active="ACTIVAS",
		none="Sin funciones activas",
		features="FUNCIONES",
		interface="INTERFAZ",
		open="Abrir HUB",
		statusHint="Ajustes en vivo · toca para abrir",
		minimize="Minimizar al lanzador",
		compact="Cambiar a STATUS",
		close="Cerrar HUB",
		destroy="Eliminar interfaz",
		destroyDesc="Desconecta los eventos y elimina este HUB.",
		assetsNote="Imágenes originales de la tienda. El logo tiene una versión integrada de 48px; el diagnóstico la distingue del PNG completo.",
		logoLoading="Cargando\nlogo",
		logoMissing="Logo\nno disponible",
		rasterImage="Imagen integrada de 48px",
		bootTitle="Inicia tu HUB",
		bootSubtitle="Una comprobación rápida y transparente antes de empezar.",
		bootChecking="Comprobando tu sesión…",
		bootReady="Listo para abrir KYVORIX.",
		bootReadyWarn="Listo. Algunos datos opcionales no están disponibles.",
		bootEnvironment="Cliente e interfaz",
		bootCharacter="Personaje",
		bootLevel="Nivel del personaje",
		bootHealth="Salud",
		bootWallet="Beli y fragmentos",
		bootArtwork="Imágenes originales",
		bootKey="Clave de acceso",
		checking="COMPROBANDO",
		passed="LISTO",
		warning="OPCIONAL",
		skipped="OMITIDO",
		bootKeySkip="No activada por el propietario",
		bootDataMissing="Este juego no expone estos datos",
		bootCharMissing="El personaje aún no ha aparecido",
		bootLoad="Cargar HUB",
		bootRetry="Reintentar imágenes",
		bootDetails="Diagnóstico",
		bootBusy="Las comprobaciones siguen en curso.",
		bootDetailsPrinted="Detalles de inicio enviados a Output.",
		bootNative="Logo integrado activo; PNG completo no disponible",
		bootAssetWarn="Algunas imágenes no están disponibles",
		shortHome="Inicio",
		shortProgress="Progreso",
		shortCombat="Combate",
		shortCollect="Colección",
		shortEvents="Eventos",
		shortTravel="Viajes",
		shortSettings="Ajustes",
		shortSystem="Conectar",
	},
	pt={
		home="Painel",
		progress="Progresso",
		combat="Combate",
		collect="Coleção",
		events="Mar e eventos",
		travel="Viagens",
		settings="Configurações",
		system="Conexões",
		explore="SEU UNIVERSO",
		edition="CYBER CHROMA / HUB",
		eyebrow="SUA PRÓXIMA JORNADA COMEÇA AQUI",
		headline1="Jogue o seu melhor.",
		headline2="Alcance novos horizontes.",
		intro="Seus objetivos. Sua jornada. Um espaço KYVORIX para sua interface, os dados do personagem e o próximo passo.",
		discover="Explore seu HUB",
		personalize="Personalize",
		nextworld="KYVORIX / PRÓXIMO MUNDO",
		world="Seu próximo mundo espera.",
		chapter="O PRÓXIMO CAPÍTULO",
		ready="Pronto quando você estiver.",
		character="SEU PERSONAGEM",
		level="NÍVEL",
		beli="BELI",
		fragments="FRAGMENTOS",
		health="VIDA",
		unavailable="Indisponível",
		live="SOMENTE LEITURA / AO VIVO",
		workspace="Seu espaço. Seu ritmo.",
		workspaceDesc="Ajuste cores e movimentos. Acompanhe o que importa no KYVORIX STATUS.",
		toStatus="Ver status compacto",
		themeTag="CROMADO / CIANO / MAGENTA",
		pending="NÃO CONECTADO",
		pendingDesc="Esta página não tem callback de jogo autorizado. Abri-la não inicia nenhuma ação.",
		progressDesc="Os dados do personagem são atualizados no painel. O rastreamento de pedidos aguarda uma API autorizada.",
		settingsDesc="Deixe com a sua cara. Cada mudança atualiza o status na hora.",
		reduced="Reduzir movimentos",
		reducedDesc="Transições instantâneas e sem movimento de fundo.",
		fast="Modo rápido",
		fastDesc="Menos decoração, interface mais leve e resposta imediata.",
		aura="Aura e órbitas",
		auraDesc="Luzes ciano e magenta em camadas ao redor da imagem.",
		particles="Partículas de fundo",
		particlesDesc="Um pequeno conjunto limitado de luzes com movimentos suaves.",
		palette="Paleta de cores",
		paletteDesc="Mude as cores de destaque de todo o HUB.",
		on="ATIVADO",
		off="DESATIVADO",
		sunset="Pôr do sol",
		language="Idioma do HUB",
		languageDesc="Inglês por padrão. Escolha aqui o idioma da interface.",
		save="Salvar sessão",
		saveDesc="Guarde as preferências da interface nesta sessão de jogo.",
		restore="Restaurar sessão",
		restoreDesc="Restaure as preferências da interface salvas.",
		reset="Redefinir aparência",
		resetDesc="Restaure cores e efeitos sem mudar o idioma.",
		size="Tamanho da janela",
		sizeDesc="Arraste o canto inferior direito ou use estes controles.",
		smaller="Menor",
		larger="Maior",
		saved="Preferências da sessão salvas.",
		restored="Preferências da sessão restauradas.",
		badProfile="Nenhuma sessão salva válida.",
		error="A interface não conseguiu concluir essa ação.",
		connections="CONEXÕES E IMAGENS ORIGINAIS",
		apiWait="Login da loja, pedidos, suporte e pagamentos aguardam uma API autorizada.",
		imageLoading="Carregando imagens originais…",
		imageMissing="Imagem indisponível",
		imageHelp="Verifique a origem e o acesso da imagem.",
		loaded="Carregado",
		loading="Carregando",
		failed="Indisponível",
		localImage="PNG do proprietário / recurso local",
		robloxImage="Recurso de imagem Roblox",
		logo="Logo",
		portal="Portal",
		print="Exibir diagnóstico",
		printed="Diagnóstico da interface enviado ao Output.",
		footer="KYVORIX / Somente interface",
		statusTitle="KYVORIX STATUS",
		active="ATIVAS",
		none="Nenhuma função ativa",
		features="FUNÇÕES",
		interface="INTERFACE",
		open="Abrir HUB",
		statusHint="Ajustes ao vivo · toque para abrir",
		minimize="Minimizar para o iniciador",
		compact="Mudar para STATUS",
		close="Fechar HUB",
		destroy="Remover interface",
		destroyDesc="Desconecte os eventos e remova este HUB.",
		assetsNote="Imagens originais da loja. O logo tem uma versão integrada de 48px; o diagnóstico a distingue do PNG completo.",
		logoLoading="Carregando\nlogo",
		logoMissing="Logo\nindisponível",
		rasterImage="Imagem integrada de 48px",
		bootTitle="Inicie seu HUB",
		bootSubtitle="Uma verificação rápida e transparente antes de começar.",
		bootChecking="Verificando sua sessão…",
		bootReady="Pronto para abrir o KYVORIX.",
		bootReadyWarn="Pronto. Alguns dados opcionais estão indisponíveis.",
		bootEnvironment="Cliente e interface",
		bootCharacter="Personagem",
		bootLevel="Nível do personagem",
		bootHealth="Vida",
		bootWallet="Beli e fragmentos",
		bootArtwork="Imagens originais",
		bootKey="Chave de acesso",
		checking="VERIFICANDO",
		passed="PRONTO",
		warning="OPCIONAL",
		skipped="IGNORADO",
		bootKeySkip="Não ativada pelo proprietário",
		bootDataMissing="Este jogo não fornece estes dados",
		bootCharMissing="O personagem ainda não apareceu",
		bootLoad="Carregar HUB",
		bootRetry="Tentar imagens novamente",
		bootDetails="Diagnóstico",
		bootBusy="As verificações ainda estão em andamento.",
		bootDetailsPrinted="Detalhes da inicialização enviados ao Output.",
		bootNative="Logo integrado ativo; PNG completo indisponível",
		bootAssetWarn="Algumas imagens estão indisponíveis",
		shortHome="Início",
		shortProgress="Progresso",
		shortCombat="Combate",
		shortCollect="Coleta",
		shortEvents="Eventos",
		shortTravel="Viagens",
		shortSettings="Ajustes",
		shortSystem="Conectar",
	},
	fr={
		home="Tableau de bord",
		progress="Progression",
		combat="Combat",
		collect="Collection",
		events="Mer et événements",
		travel="Voyages",
		settings="Paramètres",
		system="Connexions",
		explore="VOTRE UNIVERS",
		edition="CYBER CHROMA / HUB",
		eyebrow="VOTRE PROCHAINE AVENTURE COMMENCE ICI",
		headline1="Donnez le meilleur.",
		headline2="Atteignez de nouveaux sommets.",
		intro="Vos objectifs. Votre parcours. Un espace KYVORIX pour votre interface, les données du personnage et la suite.",
		discover="Explorez votre HUB",
		personalize="Personnaliser",
		nextworld="KYVORIX / PROCHAIN MONDE",
		world="Votre prochain monde vous attend.",
		chapter="LE PROCHAIN CHAPITRE",
		ready="Prêt à vous suivre.",
		character="VOTRE PERSONNAGE",
		level="NIVEAU",
		beli="BELI",
		fragments="FRAGMENTS",
		health="SANTÉ",
		unavailable="Indisponible",
		live="LECTURE SEULE / EN DIRECT",
		workspace="Votre espace. Votre rythme.",
		workspaceDesc="Ajustez les couleurs et les mouvements. Suivez l’essentiel dans KYVORIX STATUS.",
		toStatus="Afficher le statut compact",
		themeTag="CHROME / CYAN / MAGENTA",
		pending="NON CONNECTÉ",
		pendingDesc="Cette page ne dispose d’aucun callback de jeu autorisé. Son ouverture ne lance aucune action.",
		progressDesc="Les données du personnage s’actualisent dans le tableau de bord. Le suivi des commandes attend une API autorisée.",
		settingsDesc="À votre image. Chaque changement actualise le statut immédiatement.",
		reduced="Réduire les mouvements",
		reducedDesc="Transitions instantanées et aucun mouvement d’ambiance.",
		fast="Mode rapide",
		fastDesc="Moins de décoration, une interface plus légère et une réponse immédiate.",
		aura="Aura et orbites",
		auraDesc="Lumières cyan et magenta superposées autour de l’image.",
		particles="Étincelles d’ambiance",
		particlesDesc="Un petit ensemble limité de points lumineux aux mouvements doux.",
		palette="Palette de couleurs",
		paletteDesc="Modifiez les couleurs d’accent de tout le HUB.",
		on="ACTIVÉ",
		off="DÉSACTIVÉ",
		sunset="Coucher de soleil",
		language="Langue du HUB",
		languageDesc="Anglais par défaut. Choisissez ici la langue de l’interface.",
		save="Enregistrer la session",
		saveDesc="Enregistrez les préférences de l’interface pour cette session.",
		restore="Restaurer la session",
		restoreDesc="Restaurez vos préférences d’interface enregistrées.",
		reset="Réinitialiser l’apparence",
		resetDesc="Restaurez les couleurs et les effets sans changer de langue.",
		size="Taille de la fenêtre",
		sizeDesc="Redimensionnez par le coin inférieur droit ou avec ces commandes.",
		smaller="Réduire",
		larger="Agrandir",
		saved="Préférences de session enregistrées.",
		restored="Préférences de session restaurées.",
		badProfile="Aucune session enregistrée valide.",
		error="L’interface n’a pas pu terminer cette action.",
		connections="CONNEXIONS ET IMAGES ORIGINALES",
		apiWait="La connexion à la boutique, les commandes, l’assistance et les paiements attendent une API autorisée.",
		imageLoading="Chargement des images originales…",
		imageMissing="Image indisponible",
		imageHelp="Vérifiez la source de l’image et l’accès à la ressource.",
		loaded="Chargé",
		loading="Chargement",
		failed="Indisponible",
		localImage="PNG du propriétaire / ressource locale",
		robloxImage="Ressource image Roblox",
		logo="Logo",
		portal="Portail",
		print="Afficher le diagnostic",
		printed="Diagnostic de l’interface envoyé dans Output.",
		footer="KYVORIX / Interface uniquement",
		statusTitle="KYVORIX STATUS",
		active="ACTIVES",
		none="Aucune fonction active",
		features="FONCTIONS",
		interface="INTERFACE",
		open="Ouvrir le HUB",
		statusHint="Réglages en direct · toucher pour ouvrir",
		minimize="Réduire au lanceur",
		compact="Passer à STATUS",
		close="Fermer le HUB",
		destroy="Supprimer l’interface",
		destroyDesc="Déconnectez les événements et supprimez ce HUB.",
		assetsNote="Images originales de la boutique. Le logo possède une version intégrée de 48px ; le diagnostic la distingue du PNG complet.",
		logoLoading="Chargement\ndu logo",
		logoMissing="Logo\nindisponible",
		rasterImage="Image intégrée de 48px",
		bootTitle="Lancez votre HUB",
		bootSubtitle="Une vérification rapide et transparente avant de commencer.",
		bootChecking="Vérification de votre session…",
		bootReady="Prêt à ouvrir KYVORIX.",
		bootReadyWarn="Prêt. Certaines données facultatives sont indisponibles.",
		bootEnvironment="Client et interface",
		bootCharacter="Personnage",
		bootLevel="Niveau du personnage",
		bootHealth="Santé",
		bootWallet="Beli et fragments",
		bootArtwork="Images originales",
		bootKey="Clé d’accès",
		checking="VÉRIFICATION",
		passed="PRÊT",
		warning="FACULTATIF",
		skipped="IGNORÉ",
		bootKeySkip="Non activée par le propriétaire",
		bootDataMissing="Ce jeu ne fournit pas ces données",
		bootCharMissing="Le personnage n’est pas encore apparu",
		bootLoad="Charger le HUB",
		bootRetry="Réessayer les images",
		bootDetails="Diagnostic",
		bootBusy="Les vérifications sont toujours en cours.",
		bootDetailsPrinted="Détails du démarrage envoyés dans Output.",
		bootNative="Logo intégré actif ; PNG complet indisponible",
		bootAssetWarn="Certaines images sont indisponibles",
		shortHome="Accueil",
		shortProgress="Progrès",
		shortCombat="Combat",
		shortCollect="Collecte",
		shortEvents="Événements",
		shortTravel="Voyages",
		shortSettings="Réglages",
		shortSystem="Connexion",
	},
}

local function tr(key)
	if EXTRA_TRANSLATIONS[S.language] and EXTRA_TRANSLATIONS[S.language][key] then return EXTRA_TRANSLATIONS[S.language][key] end
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
local function animate(object,goals,duration,easing,direction)
	stop(object,false)
	if S.fast or S.reduced or duration==0 then for key,value in pairs(goals) do object[key]=value end; return end
	local tween=TweenService:Create(object,TweenInfo.new(duration,easing or Enum.EasingStyle.Quint,direction or Enum.EasingDirection.Out),goals)
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
		Text=literal and key or tr(key),TextColor3=color or C.text,TextSize=math.max(11,size or 13),
		Font=bold and Enum.Font.GothamBold or Enum.Font.GothamMedium,TextWrapped=true,
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
	connect(b.MouseLeave,function() hover(false); animate(press,{Scale=1},.18) end)
	connect(b.SelectionGained,function() hover(true) end); connect(b.SelectionLost,function() hover(false) end)
	connect(b.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(press,{Scale=.97},.10) end
	end)
	connect(b.InputEnded,function() animate(press,{Scale=1},.18) end)
	connect(b.Activated,function()
		if S.dead then return end
		animate(press,{Scale=1},.18)
		local ok,err=pcall(callback)
		if not ok then warn("KYVORIX UI: "..tostring(err)); notify("error") end
	end)
	return b,l,f
end
local function windowControl(parent,kind,callback,name)
	local b,caption,face=button(parent,"",false,callback,name,true)
	caption.Visible=false; b:SetAttribute("RestTransparency",.45); face.BackgroundTransparency=.45
	local icon=frame(face,nil,1); icon.AnchorPoint=Vector2.new(.5,.5); icon.Position=UDim2.fromScale(.5,.5); icon.Size=UDim2.fromOffset(14,14)
	local pieces={}
	local function line(x,y,w,h,rotation)
		local p=frame(icon,C.text); rect(p,x,y,w,h); p.Rotation=rotation or 0; round(p,1); table.insert(pieces,p)
	end
	if kind=="minimize" then line(1,6,12,2)
	elseif kind=="status" then
		line(1,1,12,1); line(1,12,12,1); line(1,1,1,12); line(12,1,1,12)
	else line(0,6,14,1,45); line(0,6,14,1,-45) end
	local function tint(on)
		for _,p in pieces do animate(p,{BackgroundColor3=on and (kind=="close" and Color3.fromRGB(255,116,139) or C.cyan) or C.text},.18) end
	end
	connect(b.MouseEnter,function() tint(true) end); connect(b.MouseLeave,function() tint(false) end)
	connect(b.SelectionGained,function() tint(true) end); connect(b.SelectionLost,function() tint(false) end)
	return b
end
local setMode,refreshStatus,refreshEffects,setLanguage,layoutHub
local function card(parent,height,order)
	local c=frame(parent,C.panel,.08); c.Size=UDim2.new(1,0,0,height); c.LayoutOrder=order or 1
	round(c,14); stroke(c,C.line,.25); return c
end
-- Original owner PNG data and an explicit lower-detail UI fallback.
-- Compiled from original owner PNG; 48px quantized fallback, one shared GUI pool.
local NATIVE_LOGO={size=48,palette={16777215,15596287,16513988,15067633,14018298,14080223,11857919,11854333,12310775,13094362,11127797,12959698,12041418,11383498,9878249,10136524,11050907,9936558,9541540,8953543,8949667,6610429,783103,7127037,3916277,7647477,5876719,3518971,8363217,6987492,5282542,2858483,7704522,8159458,5737433,7571886,8094321,4491751,4359099,2525421,164297,7437201,7173258,6387624,6778240,6185846,4486860,3894994,5206434,5137555,4088993,4217261,4151952,4479357,4084090,3754616,5658978,5460824,4673376,4212825,3948361,2585042,2648775,946922,2777786,811217,2250427,1070803,218596,87466,2774671,1463692,1919404,2247313,346309,738198,2902136,2899554,1525630,933496,144340,470934,669063,1521783,537720,863348,2701916,1718625,1650527,667746,402781,3488069,3290171,2831689,2764347,2500404,2109515,2042432,1190732,1647935,665166,203658,203866,269394,662853,136260,1515576,990777,333879,398131,67894,1908262,923173,725281,658455,265246,2854,67358,795,197641,131330,255,136,27,5,262144,65536,0},data=[[170002013f22160101013f11170102011abb190101013f11110201015011120201011e55130201011988140201010eaa1502010123cc160201012edd170201010fff1802010113ff1902010133dd1a02010131cc1b0201011caa1c02010119881d0201011e551e02010144220e03010179110f0301011a551003010107aa1103010104ee1203010109ff130301010dff1403010124ff150301013cff1603010135ff1703010109ff1803010214ff190301013aff1a0301015fff1b0301012cff1c03010111ff1d0301010fff1e0301010aee1f03010107bb2003010119552103010150110d0401014a660e04010120dd0f04010104ff100401010cff1104010138ff1204010161ff130401016cff1404010169ff1504010154ff1604010123ff1704010103ff1904010131ff1a04010166ff1b04020174ff1d0401016aff1e04010138ff1f04010110ff2004010109ff2104010120dd2204010145770b0501013f440c0501013dcc0d05010157ff0e05010138ff0f05010161ff1005010157ff1105020147ff1305010130ff140501015aff1505010167ff160501012aff1705010113ff1805010135ff190501013bff1a05010274ff1b0501016dff1c05010130ff1d05010147ff1e0501014bff1f05010259ff200501016bff2105010139ff2205010161ff2305010140cc240501013f440906010179110a0601014b880b06020125ff0d06010175ff0e06010159ff0f06010122ff100601014eff110601016bff120601015fff130601010cff1406010170ff1506010174ff160601010bff1706010117ff180601013eff1906010123ff1b06010170ff1c0601010cff1d0601015fff1e06010174ff2006010126ff2106010155ff2206010177ff2306010132ff240601011eff250601014b99260601017911080701014a33090701011ccc0a07010138ff0b0701016aff0c07010152ff0d07010164ff0e07010174ff0f0701010fff1007010111ff110701016dff120701015bff130701010dff1407010109ff150701020cff1607010107ff170701011aff180701013dff1907010119ff1a07010111ff1b07010105ff1c0701010dff1d0701015eff1e07010173ff1f07010110ff200701010fff2107010174ff2207010164ff2307010152ff240701016aff250701013cff260701011ccc270701014433070801013d44080801010aee0908010103ff0a0801015fff0b08010166ff0c08010167ff0d08010171ff0e08010163ff0f08010146ff1008010114ff110801013cff120801012dff1308010114ff1408010103ff160801010fff1708010148ff1808010149ff1908010131ff1a08010113ff1b08010103ff1c08010114ff1d08010139ff1e0801015cff1f08010114ff200801014cff210801017cff2208010177ff2308010159ff240801014bff2508010163ff2608010109ff2708010108ee280801012544060901011e440709010108ff0809010109ff090901015bff0a09010152ff0b09010169ff0c09010170ff0d0901014cff0e09010140ff0f09010169ff1009010120ff1109010138ff120901013bff1309010111ff1409010108ff150901010eff1609010109ff170901010fff1809010132ff1909010126ff1a0901011cff1b09010104ff1c09010120ff1d09010156ff1e09010138ff1f0901011cff2009010174ff2109020168ff230901016cff2409010159ff2509010145ff2609010161ff270901010cff280901010fff290901012544050a01012722060a01010eee070a010105ff080a01016fff090a01016cff0a0a010164ff0b0a010156ff0c0a010126ff0d0a010140ff0e0a01014eff0f0a010175ff100a010136ff110a010129ff120a01014dff130a010129ff140a010113ff150a010130ff160a01013aff170a010156ff180a010162ff190a010156ff1a0a010130ff1b0a010113ff1c0a01012aff1d0a010158ff1e0a01012bff1f0a010137ff200a01017fff210a010174ff220a01017bff230a010169ff240a010162ff250a01016cff260a010169ff270a010172ff280a010112ff290a01010fee2a0a01011e22050b01011ccc060b010110ff070b010137ff080b010165ff090b01017dff0a0b010162ff0b0b010149ff0c0b010157ff0d0b010146ff0e0b010140ff0f0b020149ff110b010123ff120b010156ff130b010158ff140b010162ff150b030156ff180b01015dff190b010175ff1a0b020177ff1c0b01015eff1d0b01013cff1e0b010114ff1f0b01013aff200b01015bff210b01015dff220b010136ff230b01013aff240b01014cff250b010157ff260b01017dff270b010154ff280b010136ff290b01010cff2a0b01011ccc2b0b01011811040c01012e77050c010129ff060c01013cff070c010141ff080c010154ff090c010173ff0a0c010153ff0b0c010164ff0c0c010130ff0d0c02011cff0f0c010104ff100c010101ff110c010108ff120c020104ff140c010101ff150c01010dff160c01022aff170c010123ff180c010136ff190c01016dff1a0c010173ff1b0c010135ff1c0c010125ff1d0c010140ff1e0c010125ff1f0c01011aff200c010115ff210c010106ff220c01010dff230c010129ff240c010162ff250c010142ff260c010157ff270c01015aff280c01013fff290c010135ff2a0c01012cff2b0c01012688030d01014422040d010134ee050d01015eff060d010126ff070d010118ff080d010174ff090d010153ff0a0d010162ff0b0d010177ff0c0d01016cff0d0d010149ff0e0d01013eff0f0d010142ff100d010109ff110d030100ff140d010112ff150d010170ff170d010156ff180d010170ff190d010177ff1a0d01017cff1b0d010159ff1c0d01013fff1d0d010141ff1e0d010143ff1f0d010125ff200d010107ff210d010129ff220d02013bff240d01017fff250d01016cff260d01012eff270d010169ff280d02011fff2a0d01015bff2b0d010137ee2c0d01014411030e01014899040e01015fff050e010168ff060e01011bff070e010146ff080e01014cff090e010126ff0a0e010157ff0b0e010171ff0c0e01016eff0d0e010122ff0e0e010143ff0f0e010141ff100e010151ff110e01010aff120e020100ff140e01012cff150e01013aff160e010134ff170e010164ff180e010177ff190e01017bff1a0e010153ff1b0e020127ff1d0e010118ff1e0e010107ff1f0e010101ff200e010111ff210e01015fff220e01015eff230e010171ff240e01017cff250e010164ff260e01014fff270e010149ff280e010147ff290e01011bff2a0e010157ff2b0e01016fff2c0e01014e99020f01013f22030f010132ee040f01016fff050f010147ff060f010128ff070f010163ff080f010117ff090f010148ff0a0f010177ff0b0f010173ff0c0f010169ff0d0f010117ff0e0f01014aff0f0f010159ff100f010141ff110f01014aff120f010108ff130f010600ff140f01012aff150f010112ff160f010137ff170f010175ff180f010174ff190f010142ff1a0f01011bff1b0f01011fff1c0f010127ff1d0f010108ff1e0f010100ff1f0f010103ff200f01022dff210f01015eff220f01017eff230f020172ff250f010160ff260f010137ff270f010130ff280f01014dff290f01013dff2a0f010147ff2b0f010172ff2c0f010136ee2d0f01013f11021001014a770310010231ff041001013bff051001016cff061001016bff0710010146ff0810010145ff0910010166ff0a10010168ff0b1001016dff0c1001015aff0d10010149ff0e10010151ff0f10010153ff101002023fff121001011aff1410010229ff151001010dff1610010136ff171001016eff181001012fff191001011fff1a10010118ff1b10010106ff1c10010101ff1d10010103ff1e1001010dff1f10010109ff2110010177ff2210010176ff231001017bff2410010171ff251001016fff2610020160ff281001016fff2910010163ff2a10010162ff2b1001015bff2c10010131ff2d1001013e77021101013ebb041101013aff051101015dff061101013cff0711020134ff091101025dff0a11010169ff0b11010131ff0c1101011eff0d11010146ff0e11010163ff0f11010134ff1211010217ff151101012bff1611010153ff171101011dff181101011fff191101011bff1a11010106ff1b11010109ff1c11010114ff1d1101015bff1e1101012cff1f11010111ff201101016bff2111010169ff2211010142ff2311010140ff241101026eff2511010177ff2611010160ff271101014cff2811010163ff291101016aff2a11010160ff2b11010134ff2c11010114ff2d1101011dbb011201011f110212010147ee031201012dff041201013cff051201013bff061201016fff0712010172ff081201013bff0a12010172ff0b12010162ff0c12010146ff0d1201013dff0e1201014eff0f12010126ff1012010148ff1112010251ff1412010130ff1512010149ff1612010119ff1712010117ff1812010119ff191201010dff1a1201012cff1b1201013aff1c12010161ff1d1201015eff1e1201013aff1f1201014cff201202016eff2212010148ff2312010119ff251201017fff261201014cff2712010156ff281201014dff2912020130ff2b12010132ff2c12010123ff2d12010122ee2e1201017911011301011b660213010148ff031301016aff041301016bff051301016aff0613010161ff071301016aff081301016fff091301015fff0a1301013bff0b13010161ff0c1301016cff0d1301015aff0e13010169ff0f1301011cff1013010142ff1213010219ff141301012eff1513010119ff161301010eff1713010120ff181301012bff1913010153ff1a1301016dff1b13010157ff1c1301016bff1d13010171ff1e13010166ff1f13010142ff2013010125ff211302012fff2313010145ff2413010137ff2513010132ff2613010167ff271301016dff2813010160ff2913010134ff2a13010137ff2b13020160ff2d13010140ff2e1301011e55011401011a99021401013fff031402015aff0514010168ff0614010163ff0714010170ff081401016dff0914010162ff0a1401016aff0b1401015dff0c14010167ff0d1401016eff0e14010168ff0f1401011dff1014010248ff1114010165ff1414010111ff1514010109ff161401010cff1714010119ff181401011bff1914010126ff1a1401014dff1b14010167ff1c14010175ff1d14010176ff1e1401016eff1f1401014aff2014020117ff2214010148ff231401011cff241401010aff2514010113ff2614010131ff271401012fff281401012eff291401010eff2a14010134ff2b1401016bff2c14010171ff2d14010146ff2e1401014966011501011faa0215010118ff031501011eff041501013dff0515010142ff0615010154ff0715010149ff0815010140ff0915010225ff0a15010158ff0b15010170ff0c15010155ff0d15010166ff0e15010162ff0f1501011cff111501014aff121501010eff1315010103ff141501025dff1515010158ff161501012dff1715010110ff1815010109ff1915020104ff1b1501010eff1c15010149ff1d15010152ff1e15010127ff1f15010118ff201501012fff2115010155ff2215010113ff2315010129ff2415010122ff2515010130ff2615010156ff2715020130ff2915010146ff2a15010149ff2b15010167ff2c15010157ff2d15010160ff2e1501015a77011601012599021601013eff031601013dff041601012fff0516020119ff0716010225ff081601022fff0a16010155ff0b16010176ff0c16010164ff0d16010155ff0e16010163ff0f1601011dff1016020144ff1216010119ff1316010109ff1516010166ff161601014aff1716010165ff181601016bff1916010138ff1a16010109ff1b16010101ff1c16010106ff1d16010117ff1e1601013dff1f16010148ff201601016eff211601013aff221601012cff2316010158ff2416020125ff2616010157ff271601016aff2816010163ff291601012bff2a1601011cff2b16010153ff2c16010161ff2d1601014dff2e1601015299011701011f990217010142ff0317010158ff0417010167ff0517010148ff0617010117ff091701021eff0a17010159ff0b17010177ff0c17010149ff0d17010153ff0e1701015fff0f1701011eff1017010227ff111701013fff121701011cff131701010cff1417010156ff1517010161ff1617010159ff171701013fff1817010144ff1917010152ff1a1701012dff1b17010105ff1c17010203ff1d17010108ff1e17010131ff1f17010175ff201701026dff2117010160ff2217010163ff2317010171ff2417010153ff2517010149ff2617010162ff271701014cff2817010140ff2917010122ff2a17010120ff2b17010130ff2c1702015aff2e1701014a990118010141660218010125ff0318010134ff041801016dff0518010169ff061802011eff0818010125ff0a18010164ff0b18010174ff0c18010222ff0d18010149ff0e1801015aff0f1801011fff111801011bff121801011dff1318010111ff1418010136ff151801012dff161801017cff1718010159ff181801013fff1918010144ff1a18010148ff1b18010113ff1d18010101ff1e18010104ff1f1801012bff2118010176ff2218020177ff2418010176ff251801017cff2618010177ff2718010146ff281802012fff2a1802012bff2c18010158ff2d1801011dff2e1801013f88001901014411011901010abb021901011aff0319010152ff041901026cff0519010175ff0619010152ff0719010117ff0819010152ff0919010132ff0a19010169ff0b19010166ff0d19010117ff0e19010125ff0f1902011bff1119010115ff1219010107ff131901010eff1419010135ff1519010129ff1619010171ff1719010277ff1819010169ff1919010127ff1a1901013fff1b19010148ff1c1901011dff1d19010108ff1e19010100ff1f19010104ff2019010120ff211901016cff2219010174ff2319010168ff2419010166ff2519010169ff2619010171ff2719010172ff2819010164ff2919010159ff2a19010156ff2b19010135ff2c1901014eff2d1901010aff2e19010106ee2f1901011a33001a01010e88011a010106ff021a01013fff031a010153ff051a01017bff061a01016eff071a010149ff081a010169ff091a010166ff0a1a010140ff0b1a01012bff0c1a010165ff0d1a010132ff0e1a01010aff0f1a010115ff101a010106ff111a010104ff121a010111ff131a01012aff141a01015eff151a010112ff161a01016fff181a010172ff191a010154ff1a1a030127ff1d1a010143ff1e1a010120ff1f1a020104ff211a010122ff221a010151ff231a010152ff241a010120ff251a010142ff261a010151ff271a01016eff281a01017fff291a010174ff2a1a01016dff2b1a010171ff2c1a010120ff2d1a010117ff2e1a01010eff2f1a01011e99001b01011955011b010107ee021b010117ff031b010152ff041b010158ff051b010134ff061b020146ff081b01012eff091b01011eff0a1b010123ff0b1b01015dff0c1b010162ff0d1b010114ff0e1b010106ff0f1b010107ff101b01010cff111b010123ff121b010129ff131b010114ff141b01012dff151b01010dff161b010139ff171b010114ff181b010112ff191b01015fff1a1b010125ff1b1b020115ff1d1b01011eff1e1b010133ff1f1b01012eff201b02010aff221b010119ff231b010131ff241b010138ff251b010113ff261b01011eff271b01012eff281b02014cff2a1b010135ff2b1b01015dff2c1b01012bff2d1b01010eff2e1b01012fee2f1b01013d44011c01012566021c010119ff031c010122ff041c010149ff051c010135ff061c010123ff071c010109ff081c01010fff091c01015fff0a1c01013cff0b1c010138ff0c1c01013aff0d1c010161ff0e1c010156ff0f1c010146ff101c010169ff111c010173ff121c01015eff131c01013bff141c01012aff151c01013aff161c01016fff171c010129ff181c01012aff191c01016fff1a1c01014dff1b1c010130ff1c1c010135ff1d1c01015dff1e1c010171ff1f1c010169ff201c01014eff211c01014cff221c01015cff231c010138ff241c01013aff251c010139ff261c01015fff271c010129ff281c010109ff291c010111ff2a1c01013aff2b1c01014cff2c1c010117ff2d1c01011fff2e1c01014366011d01012f88021d010142ff031d010148ff041d010166ff051d01016dff061d01012dff071d010200ff081d010110ff091d010172ff0a1d010100ff0b1d010109ff0c1d01015cff0d1d010114ff0e1d010129ff0f1d01017cff101d01012aff111d010114ff121d010129ff131d010138ff141d01017fff151d010138ff161d010129ff171d01015eff181d010129ff191d010111ff1a1d01012aff1b1d010172ff1c1d010138ff1d1d010114ff1e1d010111ff1f1d010112ff201d01015fff211d01015bff221d010112ff231d01013bff241d010111ff251d010100ff261d01015bff271d010112ff281d010100ff291d01013aff2a1d010170ff2b1d010167ff2c1d010145ff2d1d010140ff2e1d01012e99021e010142aa031e010122ff041e010131ff051e010174ff061e010139ff081e010112ff091e01010bff0a1e010105ff0b1e01016aff0c1e01017fff0d1e010112ff0e1e010100ff0f1e01013cff101e010100ff111e01012cff121e010109ff131e010105ff141e010177ff151e010203ff161e01010cff171e01010dff181e010103ff191e010114ff1a1e010101ff1b1e010111ff1c1e010114ff1d1e010100ff1e1e01012cff1f1e010105ff201e010109ff211e010139ff221e010100ff231e01023cff241e010172ff251e010103ff261e010205ff271e010101ff281e010111ff291e010173ff2a1e01017cff2b1e010135ff2c1e010123ff2d1e010133cc2e1e01014411021f01013499031f01014dff041f01012cff051f01015bff061f01013aff071f010109ff081f01010bff091f010103ff0a1f01013aff0b1f01017fff0c1f010277ff0d1f010172ff0e1f01010bff0f1f010105ff101f01010dff111f01017fff121f01012dff131f010103ff141f01013bff161f01013cff171f010105ff181f010112ff191f01017fff1a1f02010dff1c1f01012cff1d1f010105ff1e1f01015dff1f1f020111ff211f01015bff221f010103ff241f01027fff251f010138ff271f010109ff281f01015dff291f01017fff2a1f010156ff2b1f01012dff2c1f010137ff2d1f010132990220010153990320010129ff0420010138ff0520010178ff062001013bff072002012cff092001012dff0a20010114ff0b20010161ff0d2001027cff0e2001013bff0f20010114ff102001015bff112001017eff122001016fff1320010129ff1420010112ff152001012aff1620010171ff1720010111ff1820010134ff192001016eff1a20010114ff1b2001012aff1c2001013bff1d20010123ff1e2002011cff202001015dff212001015fff2220010114ff232001015cff252001012dff2620010129ff272001012cff282001014dff2920010177ff2a20010169ff2b2001014cff2c20010131ff2d20010153aa032101013366042101014cff0521010156ff062101013aff072101010dff082101013aff092101015bff0a21010109ff0b2101010fff0c21010174ff0e21010138ff0f2101010bff1021010160ff1121010176ff1221010173ff1321010123ff1421010108ff1521010132ff1621010175ff1721010120ff182101010eff192101011dff1a2101010aff1b21010131ff1c2101012cff1d2101010aff1e2101014dff1f21010108ff202101014cff212101016aff2221010109ff232102015eff2521010208ff2621010123ff2721010114ff282101011cff2921010169ff2a2101014bff2b21010148ff2c21010149770422010154cc0522010168ff062201012bff072201010cff0822010137ff0922010175ff0a22010114ff0b22010108ff0c22010120ff0d22010171ff0e22010129ff0f2201010aff102201014dff112202017bff1322010136ff1422010122ff1522010253ff162201016eff172201014aff182201021eff1922010120ff1a22010130ff1b2201016eff1c22010134ff1d22010120ff1e2201016bff1f22010113ff202201011cff2122010137ff2222010108ff232201012aff2422010111ff262201015dff2722010129ff2822010108ff2922010148ff2a22010127ff2b2201014bcc042301011f55052301014eff0623010113ff072301010aff0823010131ff0923010168ff0a2301013aff0b23020131ff0d2301016aff0e23010161ff0f23010157ff1023010160ff112301014cff1223010134ff132301014cff1423010133ff1623010165ff1723010117ff192301017aff1a23010158ff1b23010134ff1c23010146ff1d23010149ff1e23010153ff1f23010167ff2023010162ff2123020160ff2323010137ff2423010135ff252301012aff262301017fff272301013aff282301010aff292301011cff2a2301013dee2b2301013f440424010143330524020122ff072401014dff0824010161ff0924010135ff0a24010134ff0b2401014fff0c2401015aff0d24010162ff0e24010156ff0f2401014cff1024020134ff1224010131ff132401012bff142401010eff1524010108ff162401012eff172401011aff1824010125ff192401012eff1a24010108ff1b2401010eff1c24010130ff1d24010134ff1e24020146ff202401014cff2124010157ff2224010163ff2324020159ff252401014cff2624010137ff2724010160ff2824010162ff292401012eff2a24010122ff2b2401012f33042501013e55052501014a770625010145990725010151ff0825010155ff0925010154ff0a25010164ff0b25010159ff0c2501014bff0d25010171ff0e2501026dff0f25010176ff1025010177ff1125010174ff1225020177ff142501016bff1525010134ff1625010113ff1725020133ff192501012bff1a25010135ff1b25010168ff1c2501017bff1d2501017fff1e25010174ff1f2501016dff2025010167ff212501016dff2225010173ff2325020164ff2525010167ff2625010158ff2725010162ff2825010152ff292501014aaa2a25010143772b2501013d55072601011f99082601011fff0926010140ff0a26010120ff0b2601015dff0c2601016cff0d26010167ff0f26010175ff102601026dff112601014bff1226010254ff132601015aff1426010174ff152601016aff1626010137ff1726010111ff182601012dff1926010164ff1a26010158ff1b26010176ff1c2601016dff1d26010159ff1e2603014bff2126010155ff2226010140ff2326010174ff242601016fff252601012cff262601013aff2726010141ff282601011abb082701011a990927010115ff0a27010117ff0b2701010dff0c2701013cff0d27010163ff0e2702014fff1127010175ff132701014bff1427010173ff1527010177ff1627010169ff172701012aff182701013cff192701015aff1a27010143ff1b2701015aff1c27010164ff1d27010152ff1e27010148ff1f27010142ff2027010125ff212701011eff2227010136ff232701015fff242701010cff252701010fff2627010141ff272701013faa092801011a660a2801011fee0b28010125ff0c28010160ff0d2802015cff0f28010156ff1028010147ff1128010162ff1228010268ff1328010154ff1428010174ff152801016cff1628010167ff172801014eff1828010157ff1928010167ff1a28010169ff1b2801016eff1c28010168ff1d28010247ff1e2801013eff1f28010122ff2028010131ff212801015bff222802015fff2428010131ff2528010151ff2628010144770a29010150220b2901014abb0c2901014bff0d29010175ff0e2901015cff0f29010112ff102901012dff112901014dff132901015aff142901014eff1529010147ff1629010145ff1729010227ff182901023dff192901014bff1a2901014eff1b29010146ff1c29010140ff1e2901014cff1f2901013aff2029010114ff2129010139ff2229010175ff2329010153ff2429010152cc2529010151330c2a01013f660d2a01014bdd0e2a01012bff0f2a01010bff102a010111ff112a01012dff122a01013bff132a01015eff142a01014dff152a010146ff162a010142ff192a020140ff1b2a010136ff1c2a01015dff1d2a01015bff1e2a01013cff1f2a010138ff202a010111ff212a01010fff222a01014eee232a01014a770d2b01013f110e2b010142770f2b01012bdd102b010135ff112b01015dff122b01015cff132b01015fff142b010147ff152b020118ff172b020115ff192b020118ff1b2b010148ff1c2b01016aff1d2b01016fff1e2b010161ff1f2b01014dff202b010132dd212b01014088222b010144110f2c01016e11102c01015255112c01014fbb122c01014eee132c010162ff142c010154ff152c010145ff162c010128ff172c02011fff192c010128ff1a2c010141ff1b2c01014fff1c2c010164ff1d2c01014fee1e2c010152bb1f2c01015166202c01017a11122d01013f22132d01015266142d01015599152d010155bb162d010151cc172d02014aee192d010151cc1a2d010155bb1b2d010155991c2d010154771d2d01014422172e02014422]]}

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
	if kind=="portal" and layoutHub and UI.lastHubSize then layoutHub(UI.lastHubSize); if refreshEffects then refreshEffects() end end
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
		local url="https://raw.githubusercontent.com/VnTotalGui/kyvorix-hub/main/"..(kind=="logo" and "logo-transparent" or kind)..".png"
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
		local fileName="kyvorix-owned-"..kind.."-v72.png"
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
UI.languageButton,UI.languageCaption=button(UI.header,"EN / VI",false,function() UI.openLanguages() end,"LanguageSwitch",true)
UI.minimize=windowControl(UI.header,"minimize",function() setMode("MINI") end,"WindowMinimize")
UI.compact=windowControl(UI.header,"status",function() setMode("STATUS") end,"WindowStatus")
UI.close=windowControl(UI.header,"close",function() UI.gui:Destroy() end,"WindowClose")
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
		local selected=UI.pages[id]; selected.Position=UDim2.fromOffset(12,0); animate(selected,{Position=UDim2.fromOffset(0,0)},.28)
		animate(UI.marker,{Position=UDim2.fromOffset(3,6+(i-1)*43)},.30)
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
setting(1,"language","languageDesc",function() return LANGUAGES[S.language].native end,function() UI.openLanguages() end,"SettingsLanguage")
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
	assert(value.language==nil or LANGUAGES[value.language]~=nil,"Invalid language")
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
UI.statusMini=windowControl(UI.status,"minimize",function() setMode("MINI") end,"StatusMinimize")
UI.statusClose=windowControl(UI.status,"close",function() UI.gui:Destroy() end,"StatusClose")
UI.statusLang=button(UI.status,"EN / VI",false,function() UI.openLanguages() end,"StatusLanguage",true)
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
UI.bootLanguage=button(UI.bootSurface,"EN / VI",false,function() UI.openLanguages() end,"BootLanguage",true)
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
	rect(UI.bootLanguage,w-174,92,156,28)
	rect(UI.bootProgressTrack,18,105,math.max(18,w-210),3)
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
	animate(UI.bootProgress,{Size=UDim2.fromScale(done/#UI.bootCheckOrder,1)},.26)
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
	UI.statusCount.Text=tostring(#featureRows).." "..tr("active").."  /  "..string.upper(S.language)
	for _,update in UI.settingValues do update() end
end
refreshEffects=function()
	for _,tween in UI.ambient do tween:Cancel() end; table.clear(UI.ambient)
	UI.grid.Visible=not S.fast
	UI.orbit.Visible=S.aura and not S.fast and UI.heroHasArtwork==true
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
				local tween=TweenService:Create(spark,TweenInfo.new(3.2+i*.16,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{
					Position=spark.Position+UDim2.fromOffset(0,-7-i%3),BackgroundTransparency=.75,
				})
				table.insert(UI.ambient,tween); tween:Play()
			end
		end
		local g=UI.headGradient
		local tween=TweenService:Create(g,TweenInfo.new(5.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Offset=Vector2.new(.16,0)})
		table.insert(UI.ambient,tween); tween:Play()
	end
	for _,update in UI.settingValues do update() end
	if S.fast or S.reduced then
		finishMotion()
	end
end
setLanguage=function(language)
	assert(LANGUAGES[language],"Unsupported language")
	S.language=language; playerGui:SetAttribute("KyvorixLanguage",language)
	for _,binding in UI.bindings do binding.object.Text=tr(binding.key) end
	UI.refreshLanguageChoice()
	if UI.toast.Visible then UI.toast.Text=tr(UI.toast:GetAttribute("MessageKey") or "error") end
	for _,update in UI.updaters do update() end
	if UI.refreshBoot then UI.refreshBoot() end
	if layoutHub and UI.lastHubSize then layoutHub(UI.lastHubSize) end
	refreshStatus(); UI.updateData()
	return true
end
-- Flags are native UI shapes, so they do not depend on emoji fonts or image permissions.
function UI.drawFlag(parent,language)
	local flag=frame(parent,Color3.fromRGB(255,255,255)); flag.Name="CountryFlag"; flag.Size=UDim2.fromOffset(24,16); flag.ClipsDescendants=true; flag:SetAttribute("OriginalArtwork",true)
	local function band(x,y,w,h,r,g,b)
		local p=frame(flag,Color3.fromRGB(r,g,b)); rect(p,x,y,w,h); p:SetAttribute("OriginalArtwork",true); return p
	end
	if language=="vi" then
		band(0,0,24,16,218,37,29); local star=label(flag,"★",12,Color3.fromRGB(255,222,0),true,true); rect(star,0,0,24,16); star.TextXAlignment=Enum.TextXAlignment.Center; star:SetAttribute("OriginalArtwork",true)
	elseif language=="id" then band(0,0,24,8,225,40,48)
	elseif language=="fr" then band(0,0,8,16,0,38,84); band(16,0,8,16,237,41,57)
	elseif language=="es" then band(0,0,24,4,170,21,27); band(0,4,24,8,241,191,0); band(0,12,24,4,170,21,27)
	elseif language=="pt" then band(0,0,10,16,0,102,0); band(10,0,14,16,255,0,0); local dot=band(8,5,6,6,255,220,40); round(dot,6)
	else
		band(0,0,24,16,1,33,105)
		for _,angle in {33,-33} do local p=band(-2,6,28,3,255,255,255); p.Rotation=angle end
		band(0,5,24,6,255,255,255); band(9,0,6,16,255,255,255); band(0,6,24,4,200,16,46); band(10,0,4,16,200,16,46)
	end
	return flag
end
UI.languageModal=frame(UI.root,Color3.fromRGB(2,4,14),.18)
UI.languageModal.Name="LanguagePicker"; UI.languageModal.Size=UDim2.fromScale(1,1); UI.languageModal.ZIndex=20; UI.languageModal.Visible=false; UI.languageModal.Active=true
UI.languagePanel=make("CanvasGroup",UI.languageModal,{Name="LanguagePanel",BackgroundColor3=C.panel,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(320,420),BorderSizePixel=0})
round(UI.languagePanel,16); stroke(UI.languagePanel,C.cyan,.3)
UI.languageHeading=label(UI.languagePanel,"",17,C.text,true,true); rect(UI.languageHeading,18,14,240,28)
UI.languageClose=windowControl(UI.languagePanel,"close",function() UI.languageModal.Visible=false end,"LanguagePickerClose"); rect(UI.languageClose,276,12,30,30)
local languageScroll=make("ScrollingFrame",UI.languagePanel,{Name="LanguageOptions",BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(14,56),Size=UDim2.new(1,-28,1,-70),CanvasSize=UDim2.fromOffset(0,#LANGUAGE_ORDER*54),ScrollBarThickness=3,ScrollBarImageColor3=C.cyan})
UI.languageChoices={}
for i,language in LANGUAGE_ORDER do
	local info=LANGUAGES[language]
	local choice,caption,face=button(languageScroll,info.country.."  ·  "..info.native,false,function() setLanguage(language); UI.languageModal.Visible=false end,"Language_"..language,true)
	choice.Position=UDim2.fromOffset(0,(i-1)*54); choice.Size=UDim2.new(1,-6,0,46)
	caption.TextSize=12; caption.TextXAlignment=Enum.TextXAlignment.Left; caption.Position=UDim2.fromOffset(48,0); caption.Size=UDim2.new(1,-58,1,0)
	local flag=UI.drawFlag(face,language); flag.Position=UDim2.fromOffset(13,15)
	UI.languageChoices[language]=face
end
function UI.openLanguages()
	if S.dead then return end
	UI.languageHeading.Text=LANGUAGES[S.language].title
	local vp=UI.root.AbsoluteSize
	UI.languagePanel.Size=UDim2.fromOffset(math.min(340,math.max(96,vp.X-24)),math.min(420,math.max(136,vp.Y-24)))
	UI.languageClose.Position=UDim2.new(1,-44,0,12)
	UI.languageModal.Visible=true; UI.languagePanel.GroupTransparency=.5
	animate(UI.languagePanel,{GroupTransparency=0},.22)
end
UI.languageCaptions={}
for _,target in {UI.languageButton,UI.bootLanguage,UI.statusLang} do
	local face=target:FindFirstChildWhichIsA("Frame")
	local caption=face:FindFirstChildWhichIsA("TextLabel")
	caption.Position=UDim2.fromOffset(35,0); caption.Size=UDim2.new(1,-40,1,0); caption.TextSize=11
	local flagHost=frame(face,nil,1); rect(flagHost,8,0,24,16); flagHost.Position=UDim2.new(0,8,.5,-8)
	table.insert(UI.languageCaptions,{caption=caption,host=flagHost})
end
function UI.refreshLanguageChoice()
	for _,item in UI.languageCaptions do
		item.caption.Text=LANGUAGES[S.language].country
		for _,child in item.host:GetChildren() do child:Destroy() end
		UI.drawFlag(item.host,S.language)
	end
	UI.languageHeading.Text=LANGUAGES[S.language].title
	for language,face in UI.languageChoices do face.BackgroundTransparency=language==S.language and .05 or .5 end
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
		local size=Vector2.new(math.min(224,vp.X-24),math.min(174,vp.Y-24))
		return size,Vector2.new(vp.X-gap-size.X/2,vp.Y/2)
	elseif mode=="MINI" then
		local size=Vector2.new(56,56)
		local leftGap=math.clamp(tonumber(option("LeftInset",6)) or 6,4,8)
		local bottomGap=math.clamp(tonumber(option("BottomInset",6)) or 6,4,8)
		return size,Vector2.new(leftGap+size.X/2,vp.Y-bottomGap-size.Y/2)
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
	local side=phone and 78 or (compact and 104 or 138)
	local narrowHeader=w<620
	local headerH=narrowHeader and 104 or 72
	UI.header.Size=UDim2.new(1,0,0,headerH)
	UI.tag.Visible=not narrowHeader; UI.brand.Visible=w>=360
	UI.brand.TextSize=phone and 18 or 21
	if narrowHeader then
		rect(UI.languageButton,16,65,156,28)
	else rect(UI.languageButton,w-302,21,158,30) end
	rect(UI.minimize,w-132,20,36,31); rect(UI.compact,w-92,20,36,31); rect(UI.close,w-52,20,36,31)
	UI.dragHandle.Position=UDim2.fromOffset(62,0); UI.dragHandle.Size=UDim2.fromOffset(math.max(0,w-310),64)
	local top=headerH+12
	local sidebarH=math.max(72,h-top-38)
	rect(UI.sidebar,12,top,side,sidebarH)
	UI.sideCaption.Visible=not compact
	UI.sideFoot.Visible=h>580
	UI.sideFoot.Position=UDim2.new(0,12,1,-36); UI.sideFoot.Size=UDim2.new(1,-24,0,27)
	local navY=compact and 8 or 34
	rect(UI.navScroll,0,navY,side,math.max(36,sidebarH-navY-(UI.sideFoot.Visible and 42 or 8)))
	for i,nav in UI.navs do
		nav.button.Position=UDim2.fromOffset(8,(i-1)*43); nav.button.Size=UDim2.new(1,-16,0,37)
		nav.caption.Text=tr(compact and nav.short or nav.id); nav.caption.TextSize=phone and 10 or 12
		if nav.id==S.page then UI.marker.Position=UDim2.fromOffset(3,6+(i-1)*43); UI.marker.Size=UDim2.fromOffset(3,27) end
	end
	local bodyX=side+24
	rect(UI.body,bodyX,top,math.max(48,w-bodyX-12),math.max(48,h-top-38))
	rect(UI.footer,bodyX,h-27,w-bodyX-18,18)
	rect(UI.toast,bodyX,h-58,w-bodyX-18,26)
	local cw=math.max(48,w-bodyX-22)
	local pad=cw<340 and 16 or 20
	local artwork=UI.assetJobs.portal and UI.assetJobs.portal.state=="loaded"
	UI.heroHasArtwork=artwork==true
	local two=artwork and cw>=620
	local textW=two and math.floor(cw*.54) or math.max(32,cw-pad*2)
	local artW=two and math.floor(cw*.37) or math.min(340,math.max(32,cw-pad*2))
	local artH=artW*2/3
	local titleSize=math.clamp(textW/11,22,32)
	local titleH=textW<240 and 58 or 44
	local introY=56+titleH*2+10
	local introH=textW<270 and 80 or 58
	local buttonY=introY+introH+18
	local stackedButtons=textW<330
	local textBottom=buttonY+(stackedButtons and 86 or 42)
	local heroH=textBottom+pad
	if artwork then heroH=two and math.max(heroH,artH+80) or heroH+artH+66 end
	UI.hero.Size=UDim2.new(1,0,0,heroH)
	rect(UI.eyebrow,pad,18,textW,24)
	UI.eyebrow.TextSize=textW<240 and 10 or 11
	UI.h1.TextSize=titleSize; UI.h2.TextSize=titleSize
	rect(UI.h1,pad,56,textW,titleH); rect(UI.h2,pad,56+titleH,textW,titleH)
	rect(UI.intro,pad,introY,textW,introH)
	UI.intro.TextYAlignment=Enum.TextYAlignment.Top
	if stackedButtons then
		rect(UI.discover,pad,buttonY,textW,38); rect(UI.personalize,pad,buttonY+48,textW,38)
	else
		local primaryW=math.floor((textW-12)*.54)
		rect(UI.discover,pad,buttonY,primaryW,42); rect(UI.personalize,pad+primaryW+12,buttonY,textW-primaryW-12,42)
	end
	local artX=two and cw-artW-pad or (cw-artW)/2
	local artY=two and (heroH-artH)/2-10 or textBottom+30
	UI.art.Visible=artwork==true; UI.artTag.Visible=artwork==true; UI.artCaption.Visible=artwork==true
	rect(UI.art,artX,artY,artW,artH); rect(UI.orbit,artX,artY,artW,artH)
	rect(UI.artTag,artX+8,artY+artH+6,artW-16,14); rect(UI.artCaption,artX+8,artY+artH+21,artW-16,20)
	for i,ring in UI.rings do ring.Size=UDim2.fromOffset(artH*(.85+i*.11),artH*(.85+i*.11)) end
	UI.orbit.Visible=artwork==true and S.aura and not S.fast
	UI.heroRule.Visible=false
	for _,pill in UI.pills do pill.Visible=false end
	local statColumns=cw<560 and 2 or 4
	local cellW=(cw-32-(statColumns-1)*8)/statColumns
	UI.stats.Size=UDim2.new(1,0,0,statColumns==2 and 178 or 112)
	for i,cell in UI.statCells do
		rect(cell,16+((i-1)%statColumns)*(cellW+8),36+math.floor((i-1)/statColumns)*66,cellW,58)
		UI.statValues[i].TextSize=cw<280 and 13 or 17
	end
	local stacked=cw<460
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
	rect(UI.statusTitle,10,9,w-72,18); UI.statusTitle.TextSize=11
	rect(UI.statusMini,w-58,7,22,22); rect(UI.statusClose,w-32,7,22,22)
	rect(UI.statusSubtitle,10,31,w-20,14); UI.statusSubtitle.TextSize=10
	rect(UI.statusScroll,10,50,w-20,math.max(20,h-96)); UI.statusList.TextSize=11
	rect(UI.statusCount,10,h-42,w-20,12); UI.statusCount.TextSize=10
	rect(UI.statusRestore,10,h-25,72,19); UI.statusRestore:FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("TextLabel").TextSize=11
	rect(UI.statusLang,88,h-25,w-98,19); UI.statusLang:FindFirstChildWhichIsA("Frame"):FindFirstChildWhichIsA("TextLabel").TextSize=11
end
setMode=function(mode,instant)
	assert(mode=="HUB" or mode=="STATUS" or mode=="MINI" or mode=="BOOT","Unsupported window mode")
	if S.dead then return false end
	S.epoch+=1; local epoch=S.epoch
	S.mode=mode; S.transitioning=true; UI.drag=nil; UI.resize=nil; if UI.languageModal then UI.languageModal.Visible=false end
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
	for _,surface in {UI.hub,UI.status,UI.mini,UI.bootSurface} do if surface.Visible then animate(surface,{GroupTransparency=1},.16) end end
	animate(UI.window,{Size=UDim2.fromOffset(size.X,size.Y),Position=UDim2.fromOffset(center.X,center.Y)},.62,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
	later(.20,function()
		if S.epoch~=epoch then return end
		for _,surface in {UI.hub,UI.status,UI.mini,UI.bootSurface} do surface.Visible=surface==target end
		UI.syncLogoSlot()
		target.GroupTransparency=1; animate(target,{GroupTransparency=0},.34)
	end)
	later(.64,finish)
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
		.."\n"..tr("language")..": "..LANGUAGES[S.language].native
		.."\n"..tr("logo")..": "..artState("logo").."\n"..tr("portal")..": "..artState("portal")
		.."\n"..tr("features")..": "..tostring(UI.featureCount())
end
function UI.featureCount()
	local count=0; for _,f in pairs(UI.features) do if f.enabled then count+=1 end end; return count
end
function UI.diagnostics()
	local assets={}
	for kind,list in pairs(UI.assets) do assets[kind]=list[1] and {state=list[1].state,source=list[1].source} or {} end
	return {build="KYVORIX Client UI 7.2",language=S.language,mode=S.mode,page=S.page,transitioning=S.transitioning,boot=UI.bootState,
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
