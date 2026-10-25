-- KYVORIX / CYBER CHROMA 7.4
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
	bootWallet={"Beli & fragments","Beli & fragments"},bootArtwork={"Brand logo","Logo thương hiệu"},bootKey={"Access key","Key truy cập"},
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
		bootArtwork="Logo merek",
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
		bootArtwork="Logo de marca",
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
		bootArtwork="Logótipo da marca",
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
		bootArtwork="Logo de marque",
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
		Text=literal and key or tr(key),TextColor3=color or C.text,TextSize=math.max(12,size or 14),
		Font=bold and Enum.Font.SourceSansSemibold or Enum.Font.SourceSans,TextWrapped=true,
		TextScaled=false,TextStrokeTransparency=1,LineHeight=1.05,
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
-- Compiled from original owner PNG; 96px quantized fallback, one shared GUI pool.
local NATIVE_LOGO={size=96,palette={16777215,16777212,16776442,16580350,16055806,16382459,16120059,15857659,15856631,15528441,15461619,14546685,14937337,14870771,14803948,14345203,14277863,13103357,11004925,13491186,11328765,13554916,13422554,12701932,13093328,12568797,12501454,11718905,11651313,10078968,11714264,10599914,11646663,11449021,10794200,11969995,10791612,10528698,9811178,9874653,9807049,9805236,9540767,8122877,8051709,8703227,7196157,1635583,2880223,3788797,8699638,7323898,7845360,5225211,2144252,8301283,8430296,8494288,7186931,6138354,6528487,5024503,5021167,2794234,501499,8754108,7705551,7965124,6590935,6587583,8818082,7373732,8422803,8422019,5214949,5147607,3641068,4817638,4817083,3506913,2134766,627190,1214189,818687,32767,556975,7305883,7698821,7238532,7040633,6256304,6451341,6318728,5989248,6382703,5791084,4159453,4025560,2978785,4945588,4942763,3370929,4285104,3039680,5071241,5069691,3628683,5723748,5264481,5001573,4543620,4608101,4540501,3954063,3755140,4016483,3818077,4079689,3750726,2905261,3166337,2966138,3031390,2898262,3159621,2764867,2829622,1734623,1666259,358635,225272,1205478,91630,2122941,681399,1661655,482027,23527,22013,1857983,1595555,153520,1659335,741587,1198278,84976,84937,1920658,1918864,806813,935572,671697,16092,868010,209614,274852,1784966,933258,474504,1127046,209282,2112876,2176862,1063787,865897,1913433,602733,1912145,2108479,535917,797787,3023929,2171948,2106159,1844799,1842729,1451091,1450037,1514537,1381917,927322,859719,990259,923692,857135,922142,855570,402319,402277,336982,466260,467270,465729,464439,464168,397362,462626,528154,527381,395542,526603,328715,140681,138369,139609,137555,137790,135993,134970,134957,134693,134181,133669,132646,133399,132625,132110,131845,131592,131329,65545,196608,131072,65536,9890,6565,9334,6258,8277,6475,5200,4923,4095,255,665,3185,3409,3643,1359,1338,3627,2340,1574,1557,545,786,776,262,33,20,13,8,5,2,256,0},data=[[2f01010153773001010153882e02010188222f0201013bee300201013bff3102010191222d0301018a112e03010182882f03010114ff300301011dff310301015499320301018a1126040101e9112704010191332804010183552904010162772a04010162992b04010161bb2c04010161cc2d04010162dd2e0401013bff2f0401011aff3004010124ff310401013dff3204010167dd3304010167cc3404010161bb35040101619936040101627737040101835538040101913339040101e81122050101e911230501018433240501015077250501014abb260501013cee2705010138ff2805010127ff2905010122ff2a05010246ff2b0501015cff2c0501015dff2d05010164ff2e0501011bff2f05010124ff3005010148ff3105010126ff3205010178ff330502016fff350501015cff3605010141ff3705010138ff3805010137ff390501013cee3a0501014dbb3b0501014f883c05010182443d050101e911200601018444210601014c99220601013add230601011fff2406010117ff250601010fff260601010dff2706010110ff2806010116ff2906010121ff2b06010159ff2c0601015fff2d06010163ff2e06010117ff2f06010118ff300601015eff3106010128ff3206010164ff3306020170ff3506010159ff360601012aff370601011aff380601010eff3906010115ff3a0601011eff3b06010122ff3c06010127ff3d0601013add3e0601014c993f06010184441d07010182221e0701014c771f0701013acc200701011bff2107010104ff2207020100ff2407010108ff2507010118ff260701012aff2707010159ff2807010175ff29070101acff2a070101baff2b070101c8ff2c070101f9ff2d07010147ff2e07010218ff2f0701010aff300701015fff3107010148ff3207010147ff33070101dcff34070101c8ff35070101baff36070101b3ff3707010175ff380701015eff3907010148ff3a07010129ff3b07010120ff3c07010110ff3d07010109ff3e0701010cff3f0701011bff4007010134dd410701014c774207010182221b08010151221c0801017f881d08010144ee1e08010117ff1f08010109ff2008020100ff2208010116ff2308010148ff2408010175ff25080101baff26080301ffff29080101f3ff2a080101cfff2b080101bfff2c080101a6ff2d0801011eff2f08010100ff3008010125ff310801016cff3208010120ff33080101bcff34080101edff35080101f1ff36080101fbff37080301ffff3a080101baff3b0801017eff3c0801015eff3d08010121ff3e08010105ff3f08010100ff400801010eff410801011cff4208010142ee4308010162994408010182331909010140221a09010182881b0901018dee1c09010169ff1d09010121ff1e0901010dff1f09010110ff200901012aff2109010170ff22090101c5ff23090101fdff24090101dcff25090101cfff26090101aaff2709010296ff28090101aaff2909010196ff2a09010152ff2b0901018dff2c0901014bff2d0901020eff2e09010121ff2f0901010eff3009010120ff3109010170ff3209010121ff3309010163ff34090101bbff350901018dff36090101a6ff37090101cfff380901019eff39090101bcff3a090101cfff3b090101f9ff3c090101fbff3d090101c5ff3e09010176ff3f09010157ff4009010121ff4109010116ff4209010124ff4309010169ff440901019dff450901018999460901015122180a01018277190a01018dee1a0a0101a3ff1b0a0101adff1c0a010125ff1d0a01011aff1e0a01015eff1f0a0101baff200a0101ffff210a0101f9ff220a0101aaff230a01016aff240a010155ff250a01017fff260a01013dff280a0101ceff290a01019eff2a0a010196ff2b0a0101f4ff2c0a0101aeff2e0a010148ff2f0a010156ff300a01015dff310a010175ff320a010146ff330a0101b3ff340a0101f5ff350a0101cfff360a0201e7ff380a0101e2ff390a01013cff3a0a010180ff3b0a020186ff3d0a0101a6ff3e0a0101f4ff3f0a0101fdff400a0101c8ff410a010170ff420a01012aff430a010125ff440a0101acff450a0101b5ff460a01019eee470a01018977160b01015133170b010184bb180b010184ff190b010166ff1a0b0101a5ff1b0b0101b2ff1c0b0101adff1d0b0101d8ff1e0b0101ffff1f0b0101d1ff200b01016aff210b01013cff220b01013eff230b010165ff240b0101aaff250b0101a1ff260b010119ff270b010172ff280b0101faff290b0101c0ff2a0b0101aaff2b0b0101d8ff2c0b0101f3ff2d0b01011aff2e0b010116ff2f0b010165ff300b010166ff310b01015bff320b01015dff330b0201d8ff350b0101d7ff360b0201d8ff380b010169ff390b01010dff3a0b01017bff3b0b0101e4ff3c0b010186ff3d0b010150ff3e0b010152ff3f0b01018dff400b0101c0ff410b0101fcff420b0101fbff430b0101acff440b0101b3ff450b0101acff460b010173ff470b01018bff480b010189cc490b01015144150c01015477160c010189ee170c01014cff180c010112ff190c01013bff1a0c0101bcff1b0c0101d9ff1c0c0101fbff1d0c010179ff1e0c01018cff1f0c010155ff200c01014eff210c010193ff220c0101a9ff230c0101f2ff240c0101fcff250c010175ff260c010115ff270c010159ff280c0101d6ff290c0101c1ff2a0c0101c0ff2b0c0101f9ff2c0c010169ff2d0c010100ff2e0c01011bff2f0c010151ff300c01019fff310c010143ff320c010148ff330c01016eff340c0101f4ff350c0101c5ff360c0101ceff370c0101d6ff380c010157ff390c010115ff3a0c010176ff3b0c0101fcff3c0c0101f8ff3d0c0101efff3e0c0101a6ff3f0c010195ff400c010186ff410c01018cff420c010178ff430c0101faff440c0101d9ff450c0101c4ff460c010161ff470c010112ff480c01014aff490c010192ff4a0c01018188130d01019133140d01018fbb150d0101a6ff160d010163ff170d010114ff180d010150ff190d0101e0ff1a0d0101f9ff1b0d0101f3ff1c0d0101a0ff1d0d010180ff1e0d01010bff1f0d010142ff200d0101e7ff210d0101ffff220d0101b9ff230d0101b7ff240d0101fdff250d010170ff260d020118ff280d01017bff290d0101f9ff2a0d0101dcff2b0d01017aff2c0d01020fff2d0d010107ff2e0d010133ff2f0d01012bff300d01019aff310d010160ff320d010126ff330d010142ff340d01017aff350d0101f9ff360d0101f2ff370d01017bff380d010118ff390d010121ff3a0d010175ff3b0d0101fbff3c0d0101c4ff3d0d0101d8ff3e0d0101ffff3f0d0101c3ff400d01015aff410d01010bff420d010167ff430d0101bbff440d0101f1ff450d0101fdff460d0101edff470d01018cff480d010114ff490d010145ff4a0d0101beff4b0d010186bb4c0d01018a33120e01018f77130e010144ff140e010174ff150e010176ff160e010179ff170e0101caff180e0101cbff190e0101e3ff1a0e0101bdff1b0e0101ceff1c0e0101bcff1d0e0101f2ff1e0e010147ff1f0e01010eff200e010110ff210e01015bff220e0101c0ff230e0101b4ff240e0101faff250e01016bff260e010124ff270e010105ff280e01010aff290e010148ff2a0e01015dff2b0e010117ff2d0e010114ff2e0e01012eff2f0e01010bff300e01013fff310e010191ff320e010114ff330e010138ff340e010128ff350e01015dff360e010148ff370e01010eff380e010105ff390e01012aff3a0e01016cff3b0e0101faff3c0e0201b8ff3e0e01015eff3f0e010119ff400e010110ff410e010141ff420e0101f8ff430e0101e6ff440e0101edff450e0101a6ff460e0101cdff470e0101efff480e0101ccff490e010179ff4a0e010176ff4b0e01017dff4c0e010144ff4d0e01018277100f01012f11110f010192aa120f010126ff130f01011aff140f01016cff150f01015fff160f0101baff170f0101dfff180f0101cfff190f010155ff1a0f010186ff1b0f0101d6ff1c0f0101ffff1d0f0101d9ff1e0f0101a1ff1f0f01011aff200f01010eff210f010118ff220f0101a7ff230f0101e7ff240f0101b7ff250f010248ff260f010147ff270f010142ff280f010105ff290f020103ff2b0f01010fff2c0f010113ff2d0f010132ff2e0f010182ff2f0f010136ff300f01018bff310f01019aff320f010132ff330f010145ff340f010129ff350f01010dff360f010103ff370f010106ff380f01011fff390f010168ff3a0f010159ff3b0f0101b9ff3c0f0101f4ff3d0f0101b6ff3e0f010120ff3f0f010110ff400f010113ff410f010179ff420f0101fcff430f0101dbff440f0101f5ff450f010195ff460f010151ff470f01019eff480f0101f9ff490f0101d9ff4a0f010174ff4b0f010176ff4c0f01012aff4d0f01011dff4e0f010183990f10010184111010010186bb111001011fff1210010101ff1310010115ff1410010146ff15100101baff16100101fdff17100101bcff1810010192ff19100101a6ff1a100101f9ff1b100101fdff1c100101b9ff1d100101c1ff1e100101e5ff1f10010126ff2010010149ff211001016cff2210010170ff231001017dff241001015fff261001015bff271001016aff2810010102ff2910010107ff2a10010147ff2b10010108ff2c10010104ff2d10010117ff2e10010161ff2f1001018fff30100101bbff3110010145ff3210010146ff331001015dff3410010119ff351001015aff361001020aff3710010103ff3810010164ff391001015bff3a1001015eff3b10010170ff3c100101a8ff3d10010175ff3e1001017cff3f1001012aff4010010126ff41100101edff42100101d9ff43100201d8ff45100101f9ff46100101aaff4710010150ff481001018bff49100101efff4a100101faff4b1001016bff4c1001011aff4d1001010aff4e1001011bff4f1001017fbb501001019a110e11010154220f11010162dd101101011fff1111010102ff1211010104ff1311010121ff14110101adff15110101ffff161101019eff171101018dff18110101d0ff19110101fdff1a110101baff1b110101a7ff1c11010179ff1d11010165ff1e11010196ff1f11010193ff201101015aff2111010157ff2211010176ff231101016bff241101015eff251101015fff2611010124ff2711010116ff2811010100ff2911010108ff2a11010124ff2b11010125ff2c11010146ff2d11010147ff2e11010156ff2f110101bbff3011010199ff311101015cff3211010179ff3311010168ff3411010141ff3511010129ff3711010100ff3811010116ff3911010148ff3a11010275ff3b1101016bff3c11010170ff3d1101017eff3e11010157ff3f11010145ff4011010193ff41110101d0ff42110101cfff43110101d2ff44110101fdff45110101f7ff46110101faff47110101edff4811010185ff4911010152ff4a110101b4ff4b110101c4ff4c11010148ff4d11010104ff4e11010101ff4f11010113ff501101014fcc5111010151220d12010191220e12010133dd0f12010104ff1012010110ff111201010fff1212010125ff13120101baff14120101f8ff151201028dff1612010199ff17120101d6ff18120101ffff19120101b9ff1a12010173ff1b120101aeff1c1201016aff1d120101a2ff1e120101f3ff1f120101e7ff201201013cff2112010119ff2212010175ff231201017eff241201015bff251201016cff2612020146ff2812010142ff291201012dff2a12010145ff2b1201015bff2c12010147ff2d1201015aff2e12010128ff2f12010171ff3012010169ff3112010171ff3212010177ff3312010166ff3412010164ff351201015aff361201012dff3712010134ff3812010143ff3912010147ff3b1201015cff3c120101b2ff3d12010176ff3e12010115ff3f1201013cff40120101f0ff41120101d6ff42120101ceff43120101e5ff44120101bfff45120101cfff46120101d6ff47120101fcff48120101efff4912010165ff4a12010150ff4b120101bcff4c120101ffff4d12010159ff4e12010103ff4f1201010eff5012010119ff5112010134dd5212010154220c1301019a110d1301013acc0e13010104ff0f1302011aff1113010148ff12130101c8ff13130101f1ff1413010180ff16130101f9ff17130101ffff18130101a8ff19130101a3ff1a130101a7ff1b1301016aff1c1301014cff1d13010177ff1e130101a1ff1f130101d6ff20130101a3ff211301011bff2213010125ff23130101acff241301017dff2513010173ff2613010168ff271301015aff2813010113ff2913010105ff2a1301013aff2b13010113ff2c13010100ff2d13010104ff2e1301010cff2f13010125ff3013010168ff3113010166ff321301015aff3313010139ff341301011dff351301013aff3613010105ff371301010fff3813010144ff3913010164ff3a13010279ff3b1301017dff3c130101afff3d13010125ff3e13010111ff3f1301019cff40130101dcff41130101d7ff42130101aaff43130101d6ff44130101ceff45130101a0ff461301019dff47130101ceff48130101faff49130101f2ff4a13010195ff4b13010150ff4c130101e6ff4d130101ffff4e1301015eff4f1301011aff501301012aff5113010129ff521301013acc5313010191110c1401013ebb0d14010113ff0e14010118ff0f1401010dff1014010146ff11140101dbff12140101d8ff1314010155ff141401018dff15140101f9ff16140101fdff171401016eff181402014eff1a1401013bff1b1401014dff1c14010167ff1d14010193ff1e140101a3ff1f140101d8ff20140101edff211401011eff221401012aff23140101a5ff2414010177ff2514010169ff2614010124ff2714010120ff2814010105ff2914010104ff2a1401011bff2b1401011fff2c14010128ff2d14010147ff2e14010156ff2f1401015aff3014010166ff3114020164ff331401015aff3414010139ff351401011cff3614010104ff3714010100ff3814010128ff3914010248ff3b14010193ff3c140101a1ff3d14010129ff3e1401011cff3f140101efff40140101daff41140101d3ff421401019eff43140101ceff44140101fcff45140101f3ff46140101beff4714010195ff481401016aff49140101daff4a140101f9ff4b140101e2ff4c14010192ff4d140101b7ff4e140101ffff4f1401016bff5014010129ff5114010149ff5214010125ff531401013abb0b1501014f880c15010113ff0d1501012aff0e1501011aff0f15010118ff10150101c8ff11150101d8ff12150101b9ff13150101bfff14150101f9ff15150101fdff1615010168ff1715020165ff191501013bff1a15020177ff1c150101a4ff1d150101c3ff1e150101cfff1f150201c3ff2115010164ff2215010156ff2315010172ff2415010178ff251501015eff2615010146ff271501015bff2815010171ff291501018cff2a150101a1ff2b150101bdff2c150101d1ff2d150101f1ff2e150101f5ff2f150101f1ff30150101d2ff31150101f3ff32150101d6ff33150101d3ff34150101cfff35150101a1ff3615010165ff3715010178ff3815010158ff3a1501016cff3b15010179ff3c1501016eff3d15010144ff3e15010163ff3f150101d7ff40150101c8ff41150101c9ff42150101ddff43150101c5ff44150101c4ff45150101c2ff46150101ddff47150101c4ff48150101a3ff4915010193ff4a150101c2ff4b150101fdff4c150101c1ff4d150101adff4e150101b9ff4f150101faff5015010157ff5115010119ff5215010148ff5315010119ff541501013e990a16010188440b1601011fff0c1602012aff0e16010124ff0f160101b3ff10160101cbff11160101b5ff12160101c8ff13160101ffff14160101dfff1516010172ff1616010177ff17160101a4ff181601016aff19160101d3ff1a160101beff1b1601019dff1c160101bcff1d160101a0ff1e160101bcff1f160101ccff20160101edff21160101a4ff221601010fff2316010159ff24160101abff25160101b6ff26160101f9ff27160101fcff28160101fdff29160201ffff2b160101fdff2c160101fbff2d160201fcff2f160101fbff30160101fcff31160201ffff33160101deff34160101dfff35160401ffff39160101fbff3a160101c5ff3b160101b3ff3c1601015dff3d1601010fff3e160101b6ff3f160101ffff40160201fbff42160101dcff43160101ffff44160101f0ff45160101a9ff46160101ffff47160101ceff48160101e4ff49160101a5ff4a16010165ff4b160101c7ff4c160101ffff4d160101c8ff4e160101a8ff4f16010199ff50160101c7ff511601012aff521601010fff531601012aff5416010126ff551601015066091701019a110a1701013aee0b17010121ff0c1701015fff0d17010146ff0e17010175ff0f170101ecff101701018aff11170101a4ff12170101deff13170101dfff14170101a2ff1517010194ff16170101aaff171701019cff18170101e7ff19170101b5ff1a17010185ff1b17040180ff1f17020185ff2117010167ff2217010127ff2317010178ff24170101a1ff2517010179ff2617010178ff271701016aff281701016eff2917020164ff2b1702015aff2d17030143ff3017010247ff311701015bff32170101a5ff33170101ceff34170101bdff35170101d6ff36170101c8ff37170101acff3817010176ff3917030175ff3c1701015eff3d17010122ff3e1701015eff3f1701015dff401701015bff4117020156ff431701015bff4417030147ff4717010156ff4817010144ff49170101c1ff4a1701019cff4b17010265ff4c170101c8ff4d170101ffff4e170101b1ff4f17010151ff501701019bff511701017eff5217010118ff5317010246ff5417010148ff551701013aee5617010184220918010160aa0a18010119ff0b18020159ff0d1801016cff0e180101e7ff0f18010182ff1018010184ff11180101c3ff12180101dfff13180101d2ff14180101a0ff15180101bdff161801016aff17180101c3ff1818010145ff191801011fff1a1801011bff1b1801011cff1c18010111ff1d1801010bff1e18030111ff2118010114ff2218010132ff231801011dff241801011bff251802011dff2718010114ff281801011bff2918010113ff2a1802010bff2c1801011cff2d18020147ff2f1801011fff3118010173ff32180101bfff33180101d1ff34180101ceff35180101d8ff36180101a8ff3718010132ff381801011dff3918010137ff3a18010134ff3b1801012eff3c18010133ff3d1801013dff3e1801012eff3f1801012cff401801012dff411801012cff4218010112ff4318010111ff4418010127ff451801010fff461801010aff4718010157ff4818010173ff491801018bff4a180101bcff4c18010179ff4d180101fcff4e180101d7ff4f18010192ff5018010151ff511801019eff521801016fff541801015eff5518010129ff561801013ebb0819010153550919010145ff0a190101acff0b1901026cff0c1901015fff0d190101b1ff0e1901017fff0f19010240ff101901019eff11190102ffff12190101faff13190101a6ff14190101e5ff15190101a1ff16190101bfff17190101beff18190101a1ff191901014eff1a19010168ff1b19010163ff1c19010171ff1d1901015aff1e19010115ff1f19010100ff2019010105ff2119010106ff2219010101ff2319060102ff2919010100ff2a1901011aff2b1901016dff2c190101c7ff2d1901017cff2e1901015bff2f19010171ff30190101d1ff31190101e5ff32190101f7ff33190101d8ff34190101d9ff35190101ffff36190101a2ff3719010177ff3819010180ff391901018fff3a190101ebff3b1901019bff3c1901018fff3d19010150ff3e1901013fff3f1901013dff4019010150ff4119010131ff4219010111ff431901011fff4419010128ff4519010148ff461901017dff47190101b1ff48190101f6ff49190101aaff4a1901019dff4b1901018cff4c1901014fff4d190101bfff4e190101ffff4f190101ccff5019020140ff52190101a0ff531901015fff5419010159ff55190101b3ff561901015bff571901013e66081a010160cc091a01015fff0a1a0101b2ff0c1a010173ff0d1a010185ff0e1a01012fff101a0101e5ff121a0101a4ff131a01018cff141a0101a1ff151a0101a5ff161a0101d3ff171a0101c1ff181a0101d8ff191a010194ff1a1a0101a7ff1b1a01019cff1c1a01013dff1d1a010199ff1e1a0101bbff1f1a010145ff201a010107ff211a010105ff221a010109ff231a010106ff241a020205ff261a030106ff291a01015eff2a1a0101f9ff2b1a0101f3ff2c1a010157ff2d1a010128ff2e1a01017aff2f1a0101b0ff301a010169ff311a0101c2ff321a0101f6ff331a0201d2ff351a0101f6ff361a01017aff371a0101eeff381a010199ff391a010136ff3a1a01019aff3b1a0101caff3c1a01018dff3d1a01018eff3e1a01019bff3f1a010151ff401a01012eff411a010111ff421a01011fff431a010128ff441a010175ff451a0101aeff461a010139ff471a01015cff481a0101f7ff491a0101daff4a1a0101d2ff4b1a0101a1ff4c1a01013dff4d1a01014fff4e1a0101d1ff4f1a0101f0ff501a010152ff511a01012fff521a01013fff531a010171ff541a010170ff551a01017dff561a01017cff571a01014ecc071b01019866081b010171ff091b01016fff0a1b010169ff0b1b01017eff0c1b01019dff0d1b02012bff0f1b010180ff101b0101f2ff111b0101d1ff121b010193ff131b0101a4ff141b0101aeff151b0101c5ff161b0101d9ff171b0101ffff181b0101d6ff191b0101cdff1a1b010177ff1b1b01018cff1c1b010190ff1d1b010135ff1e1b010183ff1f1b0101e1ff201b010177ff211b01010fff221b010106ff231b010109ff261b010206ff271b010205ff281b01020eff291b0101c2ff2a1b0101c4ff2b1b01015cff2c1b010122ff2d1b010173ff2e1b0101aaff2f1b010175ff301b0101b9ff311b0102d6ff321b0101f7ff331b0101f5ff341b0101f3ff351b0101d8ff361b0101beff371b010195ff381b010136ff391b010153ff3a1b010189ff3b1b010136ff3c1b01013fff3d1b010198ff3e1b010162ff3f1b010111ff401b01010fff411b01011cff421b010141ff431b01017eff441b0101aeff451b010147ff461b01016fff471b0101b6ff481b0102fdff491b0201d9ff4b1b0101d2ff4c1b010194ff4d1b01013dff4e1b0101a3ff4f1b0101f4ff501b01018dff511b02012bff531b010186ff541b0101a8ff551b01015cff561b010170ff571b0101a1ff581b01019255061c01018211071c010199dd081c010170ff091c0101b2ff0a1c0101afff0b1c0101b0ff0c1c010186ff0d1c01012fff0e1c01012eff0f1c0101a0ff101c0101c1ff111c0101a0ff121c010179ff131c010164ff141c0101aaff151c0101a2ff161c0101fdff171c0101c5ff181c0101d2ff191c0101f8ff1a1c010171ff1b1c01012bff1c1c010197ff1d1c01019bff1e1c010136ff1f1c010187ff201c0101cbff211c01018eff221c01010bff231c010105ff241c010109ff251c010105ff291c0101b7ff2a1c01017eff2b1c010147ff2c1c010176ff2d1c010293ff2e1c010171ff2f1c0101ffff301c0101d3ff321c0101f3ff331c0201f1ff351c0101eeff361c010167ff371c01013fff381c010153ff391c010136ff3a1c010131ff3b1c01012eff3c1c010135ff3d1c01012eff3e1c01010bff3f1c01010dff401c010117ff411c010121ff421c0101adff431c0101acff441c01016cff451c0101c6ff461c0101a5ff471c0101d9ff491c0101f6ff4a1c0101d6ff4b1c0201d2ff4d1c010161ff4e1c01014bff4f1c0101c0ff501c0101cdff511c01013eff521c01012fff531c010151ff541c01019cff551c010175ff561c0101b2ff571c01017eff581c01019ccc061d01018f77071d010178ff081d01017eff091d0101d8ff0a1d0101c6ff0b1d0101a9ff0c1d010151ff0d1d010136ff0e1d010186ff0f1d0101f8ff101d01016aff111d01014eff121d01013cff131d01014cff141d01018cff151d0101a3ff161d0101c5ff171d01019eff181d0101d1ff191d0101efff1a1d010163ff1b1d01022cff1c1d01018aff1d1d01019aff1e1d0101bbff1f1d010151ff201d010199ff211d0101ebff221d010180ff231d01010bff241d030108ff271d010403ff281d010110ff291d0101c2ff2a1d010170ff2b1d010122ff2c1d0101acff2e1d0101a0ff2f1d0101fbff301d0101d6ff311d0101f3ff321d0101f1ff331d0101efff341d0101cbff351d01014cff361d010131ff371d010181ff381d010188ff391d01013dff3a1d01014cff3b1d010133ff3c1d01010bff3d1d010103ff3e1d010208ff3f1d01020fff401d010116ff411d01016cff421d0101c9ff431d01015fff441d0101c8ff451d0101b1ff461d0101b2ff471d0101f6ff481d0101d8ff491d0101dbff4a1d010193ff4b1d010162ff4c1d0101ceff4d1d0101bcff4e1d02018cff501d0101f9ff511d01019dff521d020136ff541d010195ff551d0101b2ff561d0101fdff571d0101afff581d010173ff591d01018d66051e01014011061e01018ddd071e010169ff081e0101b1ff091e0101c8ff0a1e0101b5ff0b1e01018dff0c1e010140ff0d1e010152ff0e1e0101edff0f1e0101c1ff101e01011dff111e01012eff121e010162ff131e010195ff141e0101f1ff151e0101f6ff161e0101fdff171e0101bcff181e0101bdff191e0101eeff1a1e01013cff1c1e01019aff1d1e0101e0ff1e1e0101eeff1f1e0101caff201e010236ff211e0101caff221e0101ebff231e01014cff241e010107ff251e020108ff281e010116ff291e0101b7ff2a1e010159ff2b1e01010fff2c1e01017dff2d1e0101bdff2e1e0101bcff2f1e0102f5ff301e0101f9ff311e0101d4ff321e0101eeff331e010199ff341e010135ff351e010136ff361e010140ff371e010152ff381e010183ff391e010188ff3a1e01013dff3b1e010111ff3c1e010102ff3d1e010206ff401e010148ff411e0101afff421e01015eff431e01017eff441e0101ffff451e0101c8ff461e0101ffff471e0101d8ff481e0101ceff491e0101fcff4a1e0101b6ff4b1e0101a3ff4c1e0101a4ff4d1e010193ff4e1e010167ff4f1e01014aff501e010168ff511e010171ff521e010161ff531e010135ff541e010181ff551e0101a7ff561e0101c8ff571e0101b2ff581e010270ff591e010193dd051f01018955061f010166ff071f01015dff081f0101a8ff091f0101b3ff0a1f0101b6ff0b1f010181ff0c1f010136ff0d1f010193ff0e1f0101fbff0f1f010168ff101f01012eff111f010180ff121f010190ff131f0101c1ff141f0101d9ff151f0201fdff171f0101d6ff181f0101ddff191f0101efff1a1f010137ff1b1f01012bff1c1f010188ff1d1f0102cbff1e1f0102efff1f1f0101a6ff211f010198ff221f010290ff231f010198ff241f01014cff251f010107ff261f010108ff281f01021aff291f0101aeff2a1f010146ff2b1f01020eff2c1f010173ff2d1f0101a7ff2e1f0101f1ff301f0101f0ff311f0101ecff321f01018eff331f010135ff341f010136ff351f010151ff361f01012eff371f010131ff381f010140ff391f01012cff3a1f010104ff3b1f010105ff3c1f010108ff3e1f010103ff3f1f010121ff401f010158ff411f010170ff421f01015fff431f0101fdff441f0101d9ff451f0101ffff461f0102d2ff471f0101d1ff481f0101d9ff491f0101b3ff4a1f0102acff4b1f010176ff4c1f010169ff4d1f01015bff4e1f01015cff4f1f01016dff501f010174ff511f01017bff521f0101a4ff531f01014fff541f010140ff551f0101b5ff561f0101acff571f0101b3ff591f010164ff5a1f010192550520010192bb0620010143ff0720010138ff082001017dff092001017bff0a200101c8ff0b200101bcff0c2001014fff0d200101b6ff0e200101daff0f2001013cff102001017fff112001019bff122001019eff13200101c0ff14200101c1ff15200101d6ff16200101d9ff17200101bfff18200101a6ff19200101e7ff1a20010177ff1b20010135ff1c2001018aff1f20010194ff202001013dff212001019aff232001013dff242001018fff2520010132ff2620010302ff29200102a7ff2a20010125ff2c20010145ff2d200101a8ff2e200101dcff2f200101d1ff30200101ebff3120010160ff3220010135ff332001023fff3420010151ff3520010131ff3620010112ff372001012bff3820010112ff392001010dff3a2001010eff3b2001020dff3c20010106ff3d20010100ff3e20020116ff402001012aff412001015fff42200101d6ff43200101d9ff44200101d8ff45200101f3ff47200101d6ff48200101baff49200101a8ff4b200101adff4c200101acff4d2001017dff4e2001017aff4f2002017eff51200101a8ff52200101adff532001016aff54200101a0ff55200101fcff562001017cff57200101acff582001016dff5920010147ff5a2001018caa0421010182220521010186ff0621010173ff072101017aff082101016fff092101015dff0a210101ffff0b210101f4ff0c210101faff0d210101ffff0e210101b1ff0f2101017fff10210101a0ff11210101bdff1221010196ff13210101bcff142101029dff152101019eff16210101ffff17210101efff1821010192ff19210101cdff1a210101ecff1b210101c0ff1c21010177ff1d210101bbff1e210101e6ff1f21010177ff202101013fff2121010198ff2221010197ff2321010135ff242101013dff252101012dff2721010500ff2821010221ff2a21010124ff2b21010118ff2c21010171ff2d210101aeff2e210101f8ff2f210101caff302101013eff312101013dff3221010151ff3421010131ff352101012bff3621010104ff372101010bff382101010fff392101010cff3a21010107ff3c21010121ff3d2101016cff3e21010121ff3f21010110ff4021010159ff41210101a8ff42210101ffff43210101d8ff44210101f4ff45210101f0ff46210101f1ff47210101d8ff48210301b9ff4b210101b3ff4c210101b2ff4d210101a3ff4e2101018dff4f210101afff50210101adff51210101afff52210101b1ff53210101acff54210101f9ff55210101c1ff562101015fff572101016fff5821010174ff5921010141ff5a21010167ee5b2101019822042201015455052201019eff062201017bff072201017dff0822010173ff0922010174ff0a2201019cff0b220101b7ff0c22010170ff0d22010159ff0e22010164ff0f22010150ff102201018dff11220101bfff12220101e7ff13220101d6ff15220101bdff16220101b0ff1722010139ff182201014aff1922010167ff1a2201018cff1b220101efff1c220101faff1d220101a5ff1e220101b0ff1f2201014eff202201034cff2122010191ff2222010150ff232201013dff242201013fff2522010114ff29220101a2ff2a22020128ff2c220101a5ff2d220101e5ff2e2201019fff2f2201012dff302201013dff3122010182ff3222010150ff3322010136ff342201012eff352201010bff362203010cff3922010118ff3a22010157ff3b22010176ff3c220101fcff3d22010158ff3e22010103ff3f2201012aff402201016eff41220101f9ff42220101d0ff43220102bcff442201019fff4522010199ff462201019bff47220101e2ff48220101c3ff49220301c6ff4c220101c5ff4d220101f0ff4e220101c1ff4f220101c4ff50220101d8ff51220101d7ff52220101b7ff53220101adff54220101b2ff5522010168ff5622010144ff572201016aff582201017bff5922010122ff5a22010144ff5b22010192660423010184aa052301014eff062301011cff0723010147ff082301015dff092301016dff0a23010174ff0b2301016cff0c23010158ff0d230101a7ff0e230101aeff0f2301015bff102301015aff1123010156ff122301016bff132301017cff14230101c3ff15230101fdff1623010169ff1723010137ff1823010135ff192301014cff1a23010135ff1b2301013cff1c23010179ff1d230101c8ff1e23010174ff1f2301014bff2123010192ff222301018cff2323010153ff242301013dff252301020bff2623010408ff2823010124ff29230101a9ff2a23020143ff2c230101eeff2d23010177ff2e23010111ff2f23010133ff3023010150ff312301013fff322302013dff3423010114ff3523010107ff3623010115ff3723010129ff382301016cff39230101afff3a230101d7ff3b230101ffff3c23010158ff3d2301010fff3e23010148ff3f23010147ff40230101b6ff41230101d5ff42230101e5ff4423010190ff452301013aff4623010114ff4723010187ff48230101ecff49230101c7ff4a230101d7ff4b230101c8ff4c230101f0ff4d23010156ff4e23010138ff4f23010179ff502301017aff51230101a8ff52230101b5ff53230101d1ff54230101f9ff55230101a1ff5623010177ff5723010164ff582301016aff592301010fff5a2301011bff5b23010192aa032401018a110424010181dd0524010169ff0624010159ff072401015dff082401016fff0924010176ff0a240101b2ff0b2401015fff0c240101b3ff0d240101ffff0e240101fcff0f240101baff1024010170ff112401016dff1224010170ff1324010174ff14240102b9ff15240101faff16240101c2ff17240101a1ff1824010167ff1924010177ff1a2401018eff1b2402014fff1d24010196ff1e24010168ff1f2401013cff21240101cbff22240101e2ff2324010188ff2424010162ff2824010125ff29240101caff2a24010145ff2b2401019cff2c24010171ff2d24010111ff2e2401012eff2f24020150ff312401013dff322401011bff332401010cff342401011aff352401015eff362401017cff372401017dff382402017eff3a240101adff3b2401015fff3c2401012aff3d240101adff3e24010164ff3f2401016aff40240101ffff41240101d6ff42240101f3ff43240101d4ff44240101ecff4524010190ff462401010bff472401014cff48240101e3ff49240102d6ff4a240201d7ff4c240101b8ff4d24010145ff4e24010179ff4f240101a5ff502401016aff512401014eff5224010138ff5324010139ff5424010164ff5524010193ff56240101ccff572401016fff582401014bff5924010128ff5a2401011cff5b24010161dd5c240101e8110325010151440425010186ff05250101faff0625010175ff072501016dff082501017bff092501017dff0a250101b7ff0b25010169ff0c2501017eff0d250101dbff0e250101c4ff0f250101acff102501017dff112501017eff12250102b2ff13250101c2ff15250101d9ff16250101d6ff17250101a5ff18250101a1ff192501019cff1a25010193ff1b2501018bff1c250101a9ff1d250101cdff1e2501015bff1f25010232ff2025010160ff21250102ebff222501019fff2325010183ff2425010152ff2525010211ff2825010229ff29250101e0ff2a2501019cff2b2501015aff2c25010112ff2d25010135ff2e25010150ff2f2501013eff302501011bff3125010110ff3225010121ff332501015fff34250101aeff35250101a8ff362501016dff3725010158ff3825010169ff39250101adff3a25010176ff3b25010174ff3c250101ffff3d250101c0ff3e25010163ff3f250101f2ff40250101eeff41250101ebff42250101e6ff43250101e5ff44250101ebff4525010161ff4625010135ff4725010183ff48250101e2ff4a250101d2ff4b250101f7ff4c250101a2ff4d2501019cff4e250101b9ff4f250101b1ff50250101adff51250101a8ff5225010179ff5325010164ff5425010145ff5525010142ff562501014bff572501014eff582501016aff5925010178ff5a2501015bff5b25010167ff5c2501019833032601015199042601017fff05260101cdff062601017eff0726010174ff08260101a8ff09260101aeff0a260101c4ff0b2601017aff0c2601016fff0d260101daff0e260101aeff0f260101b1ff10260101c5ff11260101c4ff132601017cff142601016fff1526010159ff162601017cff17260101c1ff18260101b4ff19260101bdff1a260101a6ff1b2601018dff1c260102ccff1d260101d1ff1e26010147ff2026010162ff22260101beff2326010191ff242601017fff2726010103ff29260101eaff2a26010163ff2b26010112ff2c2601013dff2d2601013aff2e26010113ff2f26010110ff3026010129ff3126010168ff3226010171ff3326010172ff342601017aff3526010173ff362601016eff3726010179ff38260101c1ff39260101d8ff3a260101aeff3b260101ffff3c260101d4ff3d26010185ff3e26010165ff3f26010167ff402601014dff4126010162ff4226010197ff43260101cbff4426010177ff452601013eff462601018bff4726010199ff48260101e5ff49260101efff4a260101edff4b260101f2ff4c2601019eff4d260101ceff4e260101c2ff4f260101b7ff50260101aeff51260101a7ff52260101a8ff5326020179ff55260101a7ff562601017bff572601017aff5826010178ff5926010165ff5a2601018cff5b2601024fff5c2601013b7702270101e911032701013ddd042701013eff05270101ebff06270101b1ff072701027aff08270101b5ff09270101c0ff0a270101d2ff0b270101b6ff0c27010173ff0d270101fcff0e270101b8ff0f270101a7ff102701017eff1127050176ff1627010170ff17270101c2ff18270101cfff19270101d1ff1a270101e5ff1b270101bcff1d270101d0ff1e27010141ff1f2701012dff202701014fff21270201cbff232701019aff2427010162ff2527010213ff262701010aff2727010100ff2827010147ff2927010199ff2a2701012dff2b27010132ff2c27010113ff2d27010118ff2e27010148ff2f27010171ff3027010177ff3127010161ff3227010162ff33270101a5ff34270101b7ff35270201e5ff37270101e4ff38270101f3ff39270101b6ff3a270101b7ff3b270101d6ff3c270101e5ff3d27010196ff3e27010195ff3f2701018bff402701013dff412701012bff422701013dff4327010160ff442701012dff4527010161ff462701019eff472701018fff482701019fff4927010142ff4a2701011fff4b2701014fff4c270101a0ff4d270101f4ff4e270101bfff4f270101ccff5027020179ff52270101aaff5327010138ff5427010178ff55270201b1ff57270101b2ff58270101b7ff59270101b3ff5a270101aaff5c27010142dd022801018a33032801013bff042801014cff052801019bff06280101c0ff08280101e5ff09280101e7ff0a280101d1ff0b280101b7ff0c2801017bff0d2801017dff0e2801017cff0f280101a8ff10280101b2ff11280101c2ff12280101c5ff13280101b9ff14280201adff162801017cff17280101a8ff18280101bcff19280101e5ff1a280101d0ff1b280101d1ff1c280101d0ff1d280101e7ff1e28010128ff1f28010233ff202801018bff21280101e0ff222801018eff232801019bff2428010261ff2628010308ff2728010206ff2828010122ff292801011bff2a2801010cff2b2801020aff2c28010147ff2d2801018cff2e28010180ff2f28020150ff312801013fff3228010177ff33280101d5ff34280101f8ff35280101f2ff36280101e5ff37280101a9ff38280101f0ff39280101aeff3a280201f1ff3c280201f2ff3e280101cdff3f280101e1ff4028010160ff4128010135ff422801012eff4328010111ff442801014aff45280101ebff46280101cbff472801013cff482801010cff4928010113ff4a2801011eff4b28010126ff4c28010145ff4d280101a9ff4e28010199ff4f2801014cff5028010167ff5128010137ff522801011fff5328010113ff5428010172ff55280101a7ff56280101aeff57280101b7ff58280101b6ff59280101b9ff5a28010194ff5b2801018cff5c2801019fbb0229010182550329010133ff0429010136ff0529010192ff06290101caff07290101b0ff08290101a9ff09290101a1ff0a29010179ff0b2901017aff0c290101a5ff0d290101b6ff0e290101cfff0f290101f1ff10290101f0ff11290101d1ff12290101edff13290101ccff14290101c0ff15290101b7ff16290101b3ff1729010179ff18290101e6ff19290201ccff1b290101e5ff1c290101f2ff1d290101bcff1e29010239ff2029010299ff21290101ebff22290101e3ff23290101e0ff252901010fff282901012aff2929010159ff2a29010118ff2c29010107ff2d2901010bff2e29010112ff2f2902012cff3129010131ff322901012eff332901012dff3429010141ff3529010179ff36290101e2ff37290101e5ff38290101d6ff39290101c4ff3a290101f3ff3b290101f1ff3c290101edff3d290101ecff3e29010190ff3f2901014cff402901013fff4129010133ff4229010114ff432901014cff44290101e1ff452901019fff462901011eff4729010107ff4829010138ff4929010144ff4a29010145ff4b2901016eff4c29010168ff4d29010139ff4e2901013cff4f29010162ff502901018eff5129010167ff5229010132ff532901013aff5429010145ff5529010164ff56290101a1ff57290101d1ff58290101b7ff59290101f0ff5a29010265ff5b2901017aff5c290101a0bb022a01018266032a01012eff042a010140ff052a010181ff062a01014cff072a020161ff092a010177ff0a2a0101bbff0b2a0101bcff0c2a0101e5ff0d2a0101edff0e2a0101ecff0f2a0101cdff102a01019fff112a010167ff122a01014aff132a010133ff142a010193ff152a0101d3ff162a0101c5ff172a01017bff182a0101b4ff192a0201e5ff1b2a0101edff1c2a0101e7ff1d2a0101a9ff1f2a01022dff212a01019dff222a010199ff232a01019aff242a010167ff252a01020cff272a01010dff282a01016bff292a0101faff2a2a0101c3ff2b2a01017eff2c2a010157ff2d2a010120ff2e2a01010aff2f2a010100ff302a010109ff312a010117ff322a01011bff332a010114ff342a010111ff352a010104ff362a010127ff372a010171ff382a0101ccff392a0101edff3a2a0101e7ff3b2a0101ecff3c2a0101bbff3d2a010162ff3e2a02013fff402a010135ff412a01013aff422a010199ff432a0101cbff442a010178ff452a010111ff462a010110ff472a010168ff482a01014dff492a01013bff4a2a010127ff4b2a010171ff4c2a01017aff4d2a010174ff4e2a01015bff4f2a010138ff502a010142ff512a010177ff522a0101a0ff532a0101e2ff542a0101a6ff552a0101b4ff562a0101a9ff572a0101ccff582a0101f9ff592a0101b4ff5b2a0101c8ff5c2a0101a6dd5d2a01012f11022b01015255032b01013bff042b010151ff052b020112ff072b010153ff082b01018fff092b010183ff0a2b01014cff0b2b010192ff0c2b0101e0ff0d2b010190ff0e2b010160ff0f2b02013aff112b01014aff122b010177ff132b01013cff142b010177ff152b0101f2ff162b0101c4ff172b0101b2ff182b010194ff192b01019bff1a2b0101e2ff1b2b0101bcff1c2b0101edff1d2b0101aeff1e2b010122ff202b01019aff212b01018bff222b01014fff232b010198ff242b010161ff262b010110ff272b010119ff282b01025eff292b0101d4ff2a2b010199ff2b2b0101cbff2c2b0101f8ff2d2b0101c5ff2e2b01017cff2f2b010159ff302b010121ff312b01010eff322b01010fff332b020117ff352b010113ff362b010107ff372b01010bff382b010132ff392b01018bff3a2b01019bff3b2b010162ff3c2b01013dff3d2b020131ff3f2b01013dff402b010187ff412b0101ebff422b0101efff432b0101a7ff442b010122ff452b010119ff462b01017bff472b0101a5ff482b010127ff492b01013cff4a2b010144ff4b2b010179ff4c2b0101a5ff4d2b01017dff4e2b0101a2ff4f2b010177ff502b010169ff512b010156ff522b01015aff532b010166ff542b010163ff552b0101a9ff562b0101b5ff572b0101a7ff582b0101adff592b010193ff5a2b0101a7ff5b2b0101ffff5c2b0101a6ee5d2b01014022022c01013f44032c01014aff042c01019bff052c02013eff072c010183ff082c01013eff092c010114ff0a2c010111ff0b2c01011dff0c2c010132ff0d2c01011dff0e2c01013eff0f2c010187ff102c010190ff112c01018eff122c010160ff132c010133ff142c010299ff152c0104f0ff162c0102d2ff172c0101d3ff182c0101b1ff192c0101d1ff1a2c0101bcff1b2c01019cff1c2c0101efff1d2c01027bff1e2c010127ff1f2c010133ff202c010288ff212c01019aff222c010190ff232c010182ff242c01013eff252c010110ff262c01011aff272c010115ff292c0101faff2a2c0101d0ff2b2c010184ff2c2c01018fff2d2c0101bbff2e2c0101b5ff2f2c0101c2ff302c0101c4ff312c0101a8ff322c01015eff332c010116ff342c010113ff352c010119ff362c010113ff372c01010cff382c010111ff392c010114ff3a2c010133ff3b2c010136ff3c2c010131ff3d2c01013eff3e2c010162ff3f2c010197ff402c0101ebff412c0101d1ff422c0101b8ff432c01015bff442c01011eff452c01017bff462c0101aeff472c0101a2ff482c01018bff492c02013eff4b2c010167ff4c2c0101a6ff4d2c0101a7ff4e2c0101a5ff4f2c0101a7ff502c0101aeff512c0101b1ff522c0101a1ff532c010128ff542c01011bff552c010133ff562c010196ff572c0101bfff582c010174ff592c01016fff5a2c010170ff5b2c01017dff5c2c0101a9ff5d2c01015133022d01013d44032d01013cff042d0101eaff052d010194ff062d01018eff072d01019fff082d010199ff092d01018eff0a2d010198ff0b2d01010fff0c2d010135ff0d2d010188ff0e2d010162ff0f2d01014aff102d01013aff112d01014aff122d01018eff132d01013eff172d0101d6ff182d0101b6ff192d0101ccff1a2d010177ff1b2d0101beff1c2d0101f2ff1e2d010139ff1f2d010135ff212d010198ff222d01017fff232d010183ff242d01024dff252d010319ff262d010220ff272d010116ff282d01016dff292d0101f2ff2a2d0101a8ff2b2d0101f1ff2c2d010181ff2d2d010153ff2e2d01019aff2f2d0101e0ff302d0101a6ff312d0101c3ff322d0101faff332d010170ff342d01011aff352d01010cff362d010115ff372d010113ff382d01010cff392d010111ff3a2d010112ff3b2d010133ff3c2d010199ff3d2d0101cbff3e2d0101caff3f2d010194ff402d0101e6ff412d0101f0ff422d0101bfff432d010156ff442d010169ff452d0101b1ff462d010179ff472d010161ff482d01014dff492d01014bff4a2d010199ff4b2d01013bff4c2d01019fff4d2d0201a7ff4f2d0101aeff502d0101b1ff512d0101a2ff522d010171ff532d010164ff542d010145ff552d01015aff562d010144ff572d0101edff582d0201aeff5a2d010173ff5b2d010172ff5c2d0101e2ff5d2d01025344022e01015244032e01013fff042e010183ff052e0101a9ff062e010171ff072e0301bcff0a2e0101cbff0b2e01014aff0c2e010114ff0d2e01012dff0e2e01013aff0f2e010162ff102e010197ff112e010167ff122e01014aff132e010233ff142e01029fff162e0102d3ff172e0201d4ff192e010166ff1a2e01014eff1b2e0101f2ff1c2e0102f9ff1d2e010173ff1e2e010137ff1f2e01013dff202e010491ff212e010153ff222e01013fff232e010191ff272e010119ff282e01016fff292e0101f1ff2a2e010178ff2b2e0101b5ff2c2e0101efff2d2e010186ff2e2e010150ff2f2e020198ff312e01019aff322e01019fff332e0101b1ff342e010175ff352e010125ff362e01010cff372e010110ff382e010113ff392e01010cff3a2e01011bff3b2e01011fff3c2e010143ff3d2e0101c0ff3e2e0101f9ff3f2e0101b5ff402e0101d0ff412e0101cfff422e0101b8ff432e01016fff442e01017dff452e0101a7ff462e0101b4ff472e0101c1ff482e0101bcff492e02014aff4b2e010166ff4c2e0101b5ff4d2e0102a2ff4e2e0101aeff4f2e0101a4ff502e01019dff512e010177ff522e01011cff532e01014bff542e010126ff552e010171ff562e010222ff572e0101ccff582e0101d1ff592e0101b6ff5a2e0101a8ff5b2e0101edff5c2e010199ff022f01019133032f01017fff042f010131ff052f0101ecff062f010173ff072f0101bcff082f0101beff092f0101e5ff0a2f0101ccff0b2f010197ff0c2f010111ff0d2f010150ff0e2f010162ff0f2f01013cff102f01013aff112f01014aff122f010187ff172f0101d2ff182f0101ecff192f01013cff1a2f010277ff1b2f0101efff1d2f01015dff1e2f010134ff1f2f01013fff212f010131ff222f010140ff232f010182ff242f01013bff262f010124ff272f010220ff282f010274ff292f0101c1ff2a2f010169ff2b2f0101a8ff2c2f0101f5ff2d2f0101ecff2e2f01018dff2f2f010136ff302f010188ff312f010198ff322f010153ff332f010186ff342f01017bff352f01016fff362f010129ff372f010109ff382f01010eff392f01010fff3a2f01020dff3b2f010117ff3c2f01011fff3d2f010125ff3e2f0101b1ff3f2f0101f9ff402f0101d2ff412f0101e5ff422f0101d6ff432f0101a8ff442f0101aeff452f0101f1ff462f0201ffff482f0101f8ff492f0101ccff4a2f0101a4ff4b2f0101f2ff4c2f0101c0ff4e2f0101ccff4f2f01014bff502f01014aff512f010161ff522f01014bff532f010194ff542f01014eff552f010142ff572f010199ff582f010195ff592f0101aaff5a2f0101d1ff5b2f0101e2ff5c2f010183ff5d2f01019233023001019111033001018bdd0430010140ff05300101cbff063001015aff073001019cff08300101ceff09300101e7ff0a300101ceff0b300101e3ff0c3001013eff0d30010112ff0e3001013aff0f30010162ff1030010197ff1130010161ff123001014aff133001013bff14300102bcff15300201f0ff17300101d1ff18300101cbff193001013aff1b300101edff1c300101f4ff1d30010168ff1e3001013eff1f30010250ff213001012eff2230010131ff2330010154ff243001014dff2530010120ff2630010129ff29300101b5ff2a30010156ff2b30010176ff2c300101ffff2d300101d3ff2e300101e3ff2f3001018cff3030010136ff3130010153ff3230020291ff34300101cbff3530010168ff3630010141ff3730010122ff383001010cff3930010106ff3b30010209ff3c30010113ff3d30010139ff3e30010128ff3f3001017cff40300101f4ff41300101ceff42300101f9ff43300101d1ff44300101f5ff45300101fbff46300101d9ff47300101dcff48300101f6ff49300101fbff4a300101ffff4b300101f3ff4c300101d4ff4d300101f9ff4e300101a3ff4f3001013cff50300101cdff5130020160ff533001011dff543001014aff5530010139ff563001011cff57300101a2ff58300101a3ff5930010144ff5a30010166ff5b30010192ff5c30010192ee5d3001018e220331010192dd043101013fff0531010126ff063101014aff0731010179ff08310101d1ff09310201c3ff0b310101e5ff0c31010199ff0d3101012dff0e31010162ff0f3101013eff103101012dff113102013bff133101014cff15310101d3ff16310101d2ff17310101edff1831010190ff1931010112ff1a3101014aff1b310101bbff1c310101efff1d31010166ff1e3101013fff213101013dff223101012eff233101013fff243101013bff2531010128ff2631010141ff2731010128ff283101017bff2931010179ff2a31010241ff2b3101016fff2c310101f5ff2d310101d7ff2e310101c3ff2f310101cdff30310101a0ff3131010181ff3431010184ff3531010192ff3631010171ff373101011fff383101011bff393101010dff3a31010101ff3c31010105ff3d3101010aff3e31010142ff3f31010139ff4031010173ff41310101f9ff42310101f4ff43310101f3ff44310201f7ff46310101f5ff47310101d1ff48310101c1ff49310101d6ff4a310101f6ff4b310101ffff4c310101f7ff4d310101daff4e310101c3ff4f3101014eff503101014bff5131010161ff5231010177ff5331010161ff54310101bcff553101016eff563101011dff57310101a7ff58310101faff59310101beff5a3101011bff5b31010112ff5c3101017fee5d3101019122023201018244033201013aee043201010bff053201013fff06320101cbff0732010173ff08320101d0ff09320201f0ff0b320101c3ff0c320101cdff0d32010160ff0e3201022dff0f3201014dff1032010199ff11320101ebff123201013cff133201012cff14320101caff15320101e7ff16320101e5ff1732010196ff1832010135ff1932010111ff1a32010133ff1b32010162ff1c320101bbff1d32010167ff1e32010136ff1f3201013fff2032010153ff2132010136ff2232010140ff2332010131ff243201013aff2532010126ff263201011fff273201011bff2832010166ff2932010172ff2b3201015fff2c320101c4ff2d320102fdff2e320101f1ff2f320101e7ff30320101edff31320101a0ff3232010136ff3332010191ff3432010151ff3532010162ff36320101e1ff3732010166ff383201011fff3932010144ff3a3201010fff3b32010103ff3c32010108ff3d32010103ff3e32010105ff3f32010137ff403201014bff413201016dff42320101f9ff43320101faff44320101daff45320101d6ff46320101e7ff47320101e5ff48320101bfff49320101bdff4a320101bfff4b320101c1ff4c320101d6ff4d320101fdff4e320101faff4f320101e6ff50320101a2ff51320101a0ff5232010190ff53320101beff54320101aeff5532010168ff5632010142ff573201019cff58320101bdff59320101b8ff5a3201013bff5b32020111ff5d3201013dcc5e32010182110133010182330233010132ee0333010100ff043301013fff0533010192ff06330101a0ff0733010193ff08330101c0ff09330101f1ff0a330102d3ff0b330101f0ff0c330101d1ff0d330101bbff0f33010133ff10330101ebff11330102c3ff123301019fff133301019dff14330101e5ff15330101c3ff16330101e6ff17330101ccff183301019fff193301018bff1a3301012eff1b33010112ff1c3301012dff1d33010135ff1e33010131ff1f33010136ff2033010135ff213301012bff2233020112ff2433010111ff253301010bff2633010117ff273301011fff28330101a7ff293301017dff2a33010124ff2b33010158ff2c330101b1ff2e330101dbff2f330101d6ff30330101d2ff31330101efff323301018dff3333010136ff3433020182ff3633010199ff373301019aff3833010160ff3933010138ff3a3301013aff3b33010126ff3c3301010cff3d33010109ff3e33010107ff3f33010103ff4033010126ff413301014dff423301016eff43330101c3ff44330101e6ff45330101e5ff46330101cfff47330101beff48330101bcff49330101cdff4a330101bdff4b330101aaff4c330101b4ff4d330101c1ff4e330101daff4f330101fcff50330101ffff51330101f3ff523301019eff53330101b1ff54330101b6ff5533010173ff5633010168ff57330101b1ff5833010180ff593302013bff5b3301012dff5c3302010bff5e3301013daa013401013dcc0234010203ff033401011dff0434010183ff053401014fff063401018cff07340101bcff08340101aaff09340101f4ff0b340201f0ff0d340101bcff0e3401013cff0f3401014bff10340101e6ff12340201d1ff14340101cdff15340101e2ff1634010199ff173401015aff1834010179ff19340101e0ff1a3401018eff1b34010132ff1c34010111ff1d3401011dff1e34020135ff203401022bff213401012cff223401011dff233401010bff243401010cff2534010128ff2634010147ff2734010129ff28340102acff293401027cff2a34010125ff2b34010159ff2c3401017aff2d340101f6ff2e340101c9ff2f340101ffff30340101fbff31340101d2ff32340101bcff3334010180ff3434010136ff3534010191ff3634010162ff373401023fff3834010189ff3934010162ff3a3401014aff3b34010161ff3c34010142ff3d3402010cff3f34010113ff4034010103ff413401011cff4234010160ff4334010166ff443401019fff45340101cdff46340101e3ff4734010171ff4834010144ff4934010190ff4a340101caff4b340101a0ff4c340101a6ff4d340101bdff4e340101cfff4f340101f3ff50340101daff51340101fdff52340101c1ff53340101c3ff54340101b7ff55340101aeff563401017aff57340101b9ff5834010194ff593401012dff5a34010134ff5b3401013aff5c3401011dff5d34010132ff5e34010132ee5f3401018422003501019122013501011dee0335010134ff0435010180ff053501012eff0635010193ff07350101f9ff08350101a6ff09350101f0ff0a350101d4ff0b350201f1ff0d350101d4ff0e350101efff0f350101ecff10350101e7ff11350101e6ff12350101bcff13350101bbff1435010184ff153501013dff1635010122ff173501015bff183501018fff19350101e2ff1a350101f2ff1b3501019cff1c35010132ff1d35010133ff1e3501013dff1f3501012cff2135010112ff2235010107ff2335010115ff243501015cff253501015dff2635010156ff2735010146ff2a35010124ff2b35010121ff2c3501017bff2d350101c8ff2e350101f6ff2f3501017cff3035010176ff31350101fbff32350101ceff33350101cbff3435010150ff3535010131ff3635010191ff3835010135ff3935010182ff3a35010188ff3b35010166ff3c35010171ff3d35010164ff3e3501011cff3f3501010bff403501021bff4135010111ff423501011bff433501014dff4435010161ff453501019cff463501019bff4735010187ff4835010146ff493501011cff4a3501014dff4b35010188ff4c35010192ff4d350101caff4e350101ccff4f350101e7ff50350101f3ff51350101ffff52350101f1ff53350101f0ff54350101c3ff55350101f1ff563501017eff57350101c9ff58350101aaff5935010114ff5a35010112ff5b3501014aff5c3501012dff5d35010164ff5e3501013cee5f35010154330136010132cc0236010104ff033601011bff0436010183ff053601014cff0636010177ff07360101f2ff08360101aaff09360101a9ff0a360401b4ff0e360101a9ff0f360101a6ff103601019fff1136010199ff1236010189ff1336010150ff1436010112ff1536010121ff163601016cff17360101b0ff183601017aff19360101fbff1a360101aeff1b36010120ff1c36010212ff1d36010131ff1e3601012eff1f36010111ff203601010bff2136010100ff2236010128ff2336010179ff2436010173ff2536020169ff273601015dff28360101b7ff29360101d1ff2a36010159ff2b36010118ff2c3601016fff2d360101d7ff2e360101ffff2f36020118ff31360101dbff32360101fbff33360101cdff3436010199ff353601013fff3636010131ff3736010136ff383601012bff3936010136ff3a36010182ff3b36010198ff3c3601019bff3d36010199ff3e36010190ff3f36010126ff413601011cff4236010132ff433601022dff443601014cff4536010187ff46360101b5ff473601016eff4836010169ff493601012aff4a3601010dff4b36010144ff4c36010150ff4d36010189ff4e36010199ff4f3601019fff50360101beff51360101c0ff52360201b4ff54360101b5ff55360101b6ff563601017cff57360101d6ff5836010179ff593601011dff5a36010114ff5b3601014eff5c36010137ff5d36010166ff5e36010162cc013701015044023701012dee0337010104ff0437010114ff0537010150ff0637010183ff07370101cdff08370101c0ff093701013cff0a37010142ff0b37010141ff0c3701014eff0d3701014bff0e37010138ff0f37010137ff103701011dff1137020114ff1337010126ff1437010158ff153701016fff16370101adff17370101a8ff1837020173ff1a3701011eff1b37010111ff1d3701012bff1e37020112ff2037010143ff2137010156ff2237010147ff2337010128ff2437020124ff2637010122ff2737010129ff283701012aff2937020148ff2b37010121ff2c37010125ff2d37010175ff2e3701022aff2f37010104ff3037010126ff3137010246ff3237010276ff3337010169ff3437010163ff3537010160ff363701011dff373701012eff383701012cff393701012bff3a3701012dff3b37010134ff3c3701013aff3d37010142ff3e37010164ff3f37010293ff403701014aff413701012dff423701011dff4437010111ff453701011dff4637010128ff4737010125ff4837010176ff49370101b3ff4a37010125ff4b37010120ff4c37010139ff4d37010114ff4e3702011dff5037010142ff5137010145ff5237010163ff5337010166ff5437010147ff5537020141ff57370101aeff5837010166ff5937010132ff5a37010134ff5b3701014bff5c37010160ff5d37010187ee5e3701015333023801018233033801013bcc0438010111ff053801010bff063801012dff0738010180ff08380101eeff09380101a1ff0a3801015bff0b380101b2ff0c38010156ff0d38010141ff0e38010156ff0f3801015aff1038010164ff113801015bff123801017bff13380101b3ff14380101d4ff15380101fcff16380101faff17380101c1ff18380101aeff193801017bff1a3801017aff1b3801015bff1c3802015aff1e3802014eff2038010195ff21380101f0ff22380101b3ff2338010176ff243801016cff2538010159ff2638010148ff273801012aff2838010121ff2938010120ff2a38010125ff2b3801012aff2c38010170ff2d38010176ff2f38010144ff303801011dff3338010170ff343801015bff353801015aff3638010144ff3738010126ff383801011fff3938010128ff3a38010147ff3b3801015eff3c38010174ff3d380101b3ff3e380101b7ff403801014eff4138010165ff4238010163ff433801015aff4438010156ff4538020159ff4738010170ff48380101b9ff49380101f3ff4a380101ffff4b380101b1ff4c380101adff4d3801017dff4e38010168ff4f3801015bff503802015cff5238010156ff5338010146ff5438010176ff553801016dff563801017eff57380101ceff583801014aff5938010133ff5a3801013bff5b38010133ff5c38010183dd5d3801018a330339010191440439010189ff053901013fff0639010134ff0739010132ff083901014bff0939010196ff0a39010172ff0b3901015bff0c39010273ff0d3901010fff0e39010100ff0f39010105ff1039010103ff1139010129ff12390101b9ff13390101fcff1439010159ff153901012aff1639020148ff1839010157ff1939010176ff1a390201ffff1c390101fbff1d390101f8ff1e390101e5ff1f390101beff20390101e5ff21390101ceff22390101f3ff23390101faff24390201ffff26390101d7ff27390101c4ff28390201a8ff2a390101b1ff2b390101c8ff2c390101b3ff2d390201c8ff2f39010128ff3039010124ff31390201c8ff33390101acff34390101b2ff35390101a7ff3639010173ff373901017bff38390101b5ff39390101d1ff3a390101f9ff3b390101faff3c390101dcff3d390101f5ff3e390101ceff3f390101beff40390101bcff41390101e4ff42390101e7ff43390101f9ff44390101fdff45390101ffff46390101fbff473901015eff4839010149ff4939030148ff4c3901017eff4d390101fcff4e3901016dff4f3901010eff5039020109ff5239010107ff533901015dff5439010169ff553901016fff56390101cfff573901014aff583901012cff593901012eff5a39010131ff5b3901017fff5c390101e155023a01014faa033a01014dee043a010193ff053a0101a0ff063a0101bbff073a0102caff083a0101a5ff093a01019cff0a3a0101efff0b3a010168ff0d3a01015dff0e3a010104ff0f3a01010dff103a010104ff113a01016bff123a0102ffff133a0101daff143a010116ff153a020100ff173a01010dff183a010159ff193a010170ff1a3a01016bff1b3a02016fff1d3a010170ff1e3a0101b3ff1f3a0101c9ff203a01017dff213a01017cff223a01017dff233a010175ff243a01017cff253a0101a8ff263a0101adff273a0101afff283a0101fdff293a0101ffff2a3a0101b3ff2b3a0101adff2c3a0101aeff2d3a01017dff2e3a0101afff2f3a010176ff303a01017cff313a0101afff323a01017bff333a01017cff343a0101aeff353a0101f5ff363a0101ffff373a0101fbff383a0101adff393a0101a8ff3a3a0201a7ff3c3a01017bff3d3a01017dff3e3a01017cff3f3a0101a8ff403a0101f9ff413a0101fbff423a0101afff433a010170ff443a01016fff453a01016dff463a01016bff473a01015fff483a010120ff493a010103ff4a3a010107ff4b3a010100ff4c3a01016cff4d3a0101dfff4e3a01017eff4f3a01010dff503a010110ff513a010107ff523a01015eff533a0101aeff543a01015bff553a0101f5ff563a0101b4ff573a01018cff583a03018dff5b3a01019dff5c3a01014bdd5d3a01014daa5e3a01018911023b01018322033b010167cc043b010166ff053b010161ff063b010190ff083b0101cdff093b0101f4ff0a3b0101faff0b3b0101fdff0c3b01017cff0d3b010149ff0e3b010200ff0f3b01010aff103b010100ff113b01015eff133b01012aff143b010103ff153b010108ff163b010110ff173b01016bff183b0101ffff193b0101afff1a3b010116ff1b3b020100ff1d3b010121ff1e3b0101b9ff1f3b0101d9ff203b010146ff213b010200ff223b010103ff233b010121ff243b010110ff253b010106ff263b010108ff273b01015eff283b0101d9ff293b0101dbff2a3b010159ff2b3b010106ff2c3b010108ff2d3b01010eff2e3b010176ff2f3b01017cff303b010120ff313b010107ff323b020100ff343b010107ff353b01011aff363b010174ff373b0101f6ff383b010148ff393b010106ff3a3b010107ff3b3b010106ff3c3b010103ff3d3b010100ff3e3b010103ff3f3b010109ff403b010124ff413b0101b9ff423b0101acff433b010118ff443b020100ff463b01011aff473b0101d9ff483b0101afff493b010116ff4a3b01020aff4b3b010109ff4c3b010118ff4d3b0101d8ff4e3b010129ff4f3b010100ff503b010109ff513b010110ff523b01017eff533b01016fff543b0101c8ff553b0101fdff563b0101f5ff573b0101eeff583b0101e1ff593b0101e0ff5a3b010179ff5b3b010163ff5c3b01014dff5d3b01018744033c01019111043c01018fcc053c010163ff063c010132ff073c010145ff083c01019cff093c0101ccff0a3c0101bcff0b3c0101c9ff0c3c0101b8ff0d3c010348ff0f3c010108ff103c010103ff113c01017cff123c01016cff133c010100ff143c010105ff153c01010aff163c010159ff173c0101d1ff183c0101d9ff193c0101ffff1a3c010175ff1b3c010106ff1c3c010103ff1d3c010118ff1e3c0101c6ff1f3c0101fcff203c010120ff223c010110ff233c0101baff243c01012aff253c010100ff263c010103ff273c01016cff283c0101ffff293c0101fcff2a3c01016bff2b3c020100ff2d3c010149ff2e3c01017eff2f3c010105ff303c010100ff313c010108ff323c020110ff343c010106ff353c010100ff363c010106ff373c01017cff383c0101baff393c01020aff3a3c010103ff3b3c01010aff3c3c010116ff3d3c010118ff3e3c010110ff3f3c010107ff403c010200ff413c010125ff423c0101ffff433c010248ff443c010103ff453c010100ff463c010149ff473c0101ffff483c0101d8ff493c010159ff4b3c010108ff4c3c010103ff4d3c01012aff4e3c01020eff4f3c010107ff503c010100ff513c010157ff523c0101a7ff533c0101baff543c0101ffff553c0101f1ff563c0101e6ff573c010194ff583c010145ff593c010139ff5a3c010142ff5b3c010162ee5c3c01019833043d01018a22053d0101cdee063d010165ff073d010137ff083d010128ff093d010145ff0a3d0101e5ff0b3d0101c4ff0c3d0102b1ff0e3d010106ff0f3d010109ff103d010110ff113d01015eff123d01020aff133d020108ff153d010158ff163d0101c1ff173d0101f5ff183d0101dbff193d0101d9ff1a3d0101c9ff1b3d010121ff1c3d020100ff1e3d01015fff1f3d010175ff203d010100ff213d010103ff223d010149ff233d0101ffff243d01015fff253d010103ff263d010200ff273d010121ff283d0101f6ff293d0101c7ff2a3d010121ff2b3d010200ff2c3d01010eff2d3d0101afff2e3d010121ff2f3d010200ff303d010106ff313d010159ff323d0101b3ff333d0101afff343d010148ff353d010106ff363d010100ff373d010248ff383d0101b9ff3a3d010200ff3b3d01010eff3c3d01017eff3d3d0101baff3e3d01017cff3f3d01010aff413d01011aff423d0101dbff443d020100ff463d010148ff473d0201dbff493d0101c2ff4a3d010125ff4b3d010106ff4c3d01010dff4d3d01010aff4f3d01010aff503d010116ff513d01017cff523d0101bfff533d0101ffff543d0101c7ff553d0101f8ff563d010169ff573d010119ff583d01011eff593d01015aff5a3d0101e5ff5b3d0101e055053e01018cdd063e010178ff073e0101b5ff083e010170ff093e01011eff0a3e010170ff0b3e0101f6ff0e3e01010cff0f3e010110ff103e010116ff113e010110ff133e010109ff143e010157ff153e0101c7ff163e0101f5ff173e0101deff183e0101d9ff193e0101c9ff1a3e0101ffff1b3e010176ff1c3e01010dff1d3e010103ff1e3e010118ff1f3e01011aff203e010103ff213e010118ff223e0101b2ff233e0102dbff243e0101b2ff253e010110ff273e01010eff283e0101b1ff293e0101a8ff2a3e01020aff2c3e010125ff2d3e0101fdff2e3e01011aff303e010103ff313e010175ff323e0201ffff343e01016bff353e020100ff383e0101c5ff393e01010eff3b3e010110ff3c3e0101c5ff3d3e0101ffff3e3e01017eff3f3e010100ff403e010116ff413e010158ff423e0103ffff433e010157ff443e010104ff453e010103ff463e010149ff473e0102ffff483e0101dbff493e0101d7ff4a3e01017bff4b3e01011aff4c3e01010eff4d3e010110ff4e3e010115ff4f3e01010dff503e010157ff513e0101ceff523e0101d6ff533e0101d9ff543e0101f5ff553e0101adff563e010124ff573e01016bff583e0101b6ff593e010172ff5a3e010177ee5b3e01018a11043f0101bb44053f01015aff063f010143ff073f0101b7ff083f0101c9ff093f010157ff0a3f010148ff0b3f0101baff0c3f0102aeff0d3f010157ff0e3f010119ff0f3f010120ff103f01011aff113f010118ff123f01011aff133f010116ff143f010125ff153f0101b3ff163f0101dfff173f0102d9ff183f0201c8ff1a3f0101c9ff1b3f0101fdff1c3f010148ff1d3f040115ff213f010170ff223f0101fcff243f0101fcff253f01012aff263f01010aff273f01010dff283f010174ff293f01016bff2b3f01010dff2c3f01015fff2d3f0101dbff2e3f010121ff2f3f010106ff303f01010dff313f010176ff323f0101faff333f0101daff343f01015eff353f010108ff363f010106ff373f010159ff383f0101c9ff393f010118ff3a3f010110ff3b3f010121ff3c3f010147ff3d3f010129ff3e3f01011eff3f3f010120ff403f010146ff413f01012aff433f01015eff443f020110ff463f010158ff483f0101c9ff493f0101d9ff4a3f0101f6ff4b3f01015fff4c3f010115ff4d3f010118ff4e3f010119ff4f3f010120ff503f0101aeff513f0101c3ff523f0101dfff533f0101f3ff543f0101d6ff553f010144ff563f010156ff573f0101dfff583f0101efff593f010139ff5a3f010145ff5b3f0101ea550440010199bb05400101a8ff0640010157ff074001015bff084002015fff0a400101faff0b400101c8ff0d40010159ff0e4003015fff1140020159ff134001016dff1440010146ff1540010124ff16400101d4ff18400301baff1b400101ffff1c4001017dff1d40010246ff1e4001015eff1f40010157ff2040010158ff21400101c4ff22400101dbff23400101c8ff24400101fdff2540010173ff2640010157ff2740010156ff2840010158ff2940010157ff2a40020156ff2c400101c4ff2d400101c9ff2e40030146ff31400101a7ff32400101f1ff33400101f4ff344001015cff3540010129ff3640010246ff374001015fff38400101c6ff3940010146ff3a40010156ff3b4001015cff3c40010138ff3d4001011fff3e40010138ff3f40010145ff404001011fff414001017cff434001025fff4440010148ff454001015cff464001015fff47400101fdff48400102c8ff49400101dbff4a400101d8ff4b40010125ff4c40010156ff4d4001015fff4e4001016bff4f40010156ff5040010169ff51400101d1ff52400101fdff53400102f5ff54400101fbff55400101e2ff564001018bff57400101adff5840010164ff5940010156ee5a400101a8ff5b4001019fcc044101018f330541010199bb0641010179ff0741010125ff0841010129ff09410101baff0a410101d9ff0b410101baff0c410101a8ff0d4101015eff0e4101015cff0f4101015dff1041010148ff114101015dff124101015eff1341010156ff144101015dff1541010120ff1641010147ff17410101f9ff18410101baff19410101b9ff1a410101c5ff1b410101c8ff1c410101daff1e4101015dff1f41010148ff2041010159ff21410101ffff22410101c8ff23410101c6ff24410101daff25410101b7ff2641010156ff274101015bff2841010121ff2941010124ff2a41010156ff2b4101016eff2c410101f8ff2d410101c7ff2e41010129ff2f41010141ff3041010147ff31410101a9ff32410101edff33410101efff344101015aff354101011eff3741010168ff38410101f4ff3941010141ff3a41010146ff3b41010145ff3c4101014bff3d41010145ff3e4101015bff3f41010137ff40410101a5ff41410101ffff42410101fbff444101012aff4541010147ff464101015dff47410101f7ff49410101fcff4a4101015bff4b4101011eff4c4101015dff4d4101015cff4e4101015dff4f4101015cff5041010125ff51410101a3ff52410101d6ff54410101cdff55410101d8ff56410101cdff5741010156ff5841010146ff59410101a3ff5a4101019ddd5b410101bb440642010197660742010166ee084201015fff09420101a6ff0a420101c2ff0b420101c7ff0c420101aeff0d42010157ff0e42010147ff0f42010148ff1042010229ff11420101b2ff12420101afff1342010125ff1442020129ff164201010fff1742010172ff18420101faff19420101c5ff1a420101b9ff1b420102c6ff1c420101d8ff1d42010125ff1e42010129ff1f42010125ff204201015bff21420101f5ff22420102c6ff23420101c4ff24420101c6ff25420101f3ff264201015aff2742040128ff2b4201019cff2c420101f9ff2d420101d1ff2e42010128ff2f42010119ff3042010127ff3142010177ff3242020190ff3442010137ff3542010122ff3642010141ff374201015aff38420101f8ff3942010139ff3a42010217ff3b42010227ff3c420101f4ff3d42010128ff3e42010127ff3f42010128ff4042010166ff41420101d8ff42420101f3ff4342010169ff4442010120ff4542010122ff464201015bff47420101fcff48420101dbff49420101a5ff4a42010213ff4b42010128ff4c42010129ff4d42020141ff4f42010156ff5042010127ff5142010168ff52420101ceff53420101c3ff54420101a9ff55420101bbff56420101e0ff5742010171ff5842010166ff594201019b885a420101e81107430101985508430101e5ff0943010168ff0a43010137ff0b430101a1ff0c430101b6ff0d43010129ff0e43010124ff0f43010120ff11430101b3ff12430101fcff134301016dff1443010115ff1543010119ff1643020117ff18430101a9ff19430101d6ff1a430101c4ff1c430101d2ff1d4301021eff1e43010117ff1f43010122ff2043010166ff21430101f0ff23430201c2ff25430101faff2643010171ff274301011cff2843010139ff2943010128ff2a4301023cff2b430101ebff2c430101f1ff2d430101efff2e43010194ff2f43010127ff3043010126ff314301011bff3243020111ff344301011bff3543010139ff3643010142ff37430101a7ff38430101f9ff394301011fff3c430101f8ff3d43010174ff3e4301010cff3f4301011cff4043010126ff41430101cdff42430101d6ff434301016eff4443010119ff4543010113ff4643010147ff47430101dbff48430101f4ff4943010122ff4b4301011eff4c4301011cff4d43010179ff4e43010146ff4f4301011eff504301011fff5143010138ff52430101bcff53430101e7ff5443010196ff5543010151ff564301017fff57430101ecff58430101e077084401019bdd09440101ffff0a440101a8ff0b44010165ff0c440101b0ff0d44010122ff0e44010117ff0f44010128ff1044010256ff11440101b5ff12440101f5ff13440101c2ff1444010146ff1544010117ff1644010128ff1744010117ff1844010127ff19440101ecff1a440101f5ff1b440101d6ff1c440101f2ff1e44020122ff2044010164ff21440101f4ff22440102c4ff23440201c3ff25440101f4ff26440101a2ff2744010111ff284401011bff2944010114ff2b440102efff2c440101d0ff2d440101edff2e440101ecff2f44010187ff304401012dff314404011bff3544010137ff364401019cff37440101faff3844010174ff3944010113ff3a4401011fff3b4401011dff3c440101a2ff3d440101f9ff3e44010122ff3f4401010fff404401011bff4144010166ff42440101f8ff434401017aff444402011eff4644010139ff47440101ffff484401015fff4944010113ff4a44010128ff4b44010117ff4c44010138ff4d440101fdff4e44010169ff4f44010113ff504401011eff514401011bff5244010193ff53440101a0ff5444010150ff5544010136ff56440101a6ff57440101e3cc0845010153770945010194ff0a450101ffff0b450101f4ff0c450101a7ff0d45010113ff0e45010128ff0f45010143ff11450101bcff12450101e6ff13450101d7ff14450101a5ff1545030128ff1845010117ff1945010139ff1a450101beff1b450101fbff1c45010174ff1d45010111ff1e4501011dff1f45010132ff2045010138ff21450101b5ff23450101c3ff24450101d1ff25450101f1ff26450101c1ff2745010166ff284501019cff294501018bff2a45010177ff2c450101e6ff2d450101e3ff2e450101e1ff2f45010188ff3045010153ff3145010191ff3245010199ff334501019fff34450101a1ff35450101beff36450101f8ff37450101d0ff3845010171ff3945010177ff3a45010194ff3b45010166ff3c45010168ff3d450101dfff3e45010172ff3f45010126ff4045010137ff4145010114ff424501016fff4345010156ff444501011bff454501011fff4645010122ff4745010170ff484501011aff4945010128ff4a45010141ff4b4501011fff4c45010176ff4d450101dfff4e450101aeff4f4501011dff504501011fff5145010126ff5245010144ff53450101e0ff5445010136ff5545010181ff56450101e0ff574501018966084601014c11094601013eee0a460101a9ff0b460101d1ff0c4601015bff0d46010122ff0e46010163ff0f4601011bff1046010143ff11460101eeff124601019eff13460101ccff14460101b9ff154601011eff1646010126ff174601011dff1846010132ff1946010134ff1a46010164ff1b460101c4ff1c4602016fff1e4601017bff1f460101bfff20460101ceff21460101f0ff22460101edff23460101cdff24460201bcff26460101e6ff27460101efff28460101ebff29460101bbff2a460101eeff2b460101e2ff2c460101caff2d460101bbff2e46010191ff2f4601012dff3046010135ff3146010198ff32460101e1ff33460101bcff34460101f0ff35460101efff36460101caff37460101e3ff38460101ecff39460101caff3a460101ebff3b460101e3ff3c460101eeff3d460101edff3e460101efff3f460101f2ff40460101d0ff41460101aeff424601017bff4346010179ff444601016aff4546010164ff4646010145ff4746010138ff4846020137ff4a4601011dff4b46010128ff4c460101dbff4d460101d9ff4e460101ffff4f46010129ff504601011bff5146020138ff5346010145ff5446010180ff554601018aff5646010182cc094701013f660a4701014fff0b470101a1ff0c47010122ff0d47010144ff0e4702011bff1047010126ff1147010173ff12470101bfff1347010165ff14470101b7ff154701016aff16470101bdff17470101b6ff18470101baff19470101f6ff1a470101ffff1b470101d6ff1c470101edff1d470101f9ff1e470101f3ff1f470101c1ff20470101b8ff21470101aeff2247010172ff2347010168ff244704015aff2847010145ff2947020144ff2b470201caff2d47010190ff2e47010233ff2f47010104ff304701012cff314701013dff324701018eff3347010199ff34470101e3ff3547010163ff3647010145ff374701015bff384701015aff3947010145ff3a47020164ff3c47010171ff3d47010179ff3e470101b0ff3f470101c3ff40470101d1ff41470101f1ff42470101f0ff43470101f2ff44470301ffff47470101fcff48470101d6ff49470101a8ff4a47010173ff4b4701016fff4c470101dcff4d470101faff4e470101b5ff4f47010127ff5047020126ff5247010138ff534701011fff5447010166ff5547010181ff564701013644094801018a110a48010185ee0b48010122ff0c48010134ff0d4801013aff0e4801013cff0f48010194ff10480101c1ff11480101b7ff12480101d6ff134801017bff1448010173ff154801017eff16480101a8ff17480101a7ff18480101b0ff1948010179ff1a480101a5ff1b480101c8ff1c4801017dff1d4801016fff1e4801015bff1f48010142ff2048030138ff2348020142ff2548010139ff2648010128ff2748010122ff2848010119ff294801010eff2a48010100ff2b4801011eff2c4801019cff2d48010167ff2f4801012dff3048010133ff314801013eff3248010187ff334801019fff3448010122ff3548010100ff364801010dff3748010119ff3848010127ff3948010139ff3a48020144ff3c4803014aff3f4801014bff4048010163ff414801016aff424801017aff43480101a7ff44480101c8ff45480101b6ff4648010172ff47480101b0ff48480101aeff49480201b1ff4b4801017cff4c4801017bff4d480101c2ff4e480101c4ff4f480101c1ff50480101aaff5148010163ff524801013cff534801013eff544801011cff5548010180ee564801018a110949010187660a4901014eff0b4901014bff0c49010186ff0d490101a0ff0e490101e5ff0f490101f6ff10490101b1ff11490101a1ff124901015aff1349010141ff1449010145ff1549010167ff1649010185ff174901018cff184902019eff1a4901016aff1b49010179ff1c4902016aff1e49010178ff1f490101a3ff20490101a4ff21490101a6ff22490101e5ff23490101e7ff24490101c0ff25490101b4ff2649010179ff2749010165ff284901014bff2949010137ff2a49010127ff2b49010115ff2c49010104ff2d49010166ff2e4901019aff2f49010135ff304901014cff31490101e1ff3249010166ff3349010107ff3449010110ff3549010126ff3649010134ff374901014eff3849010155ff394901019eff3a490101a4ff3b490101bdff3c490201bfff3e490201aaff40490101a3ff4149010193ff4249010185ff434901018cff4449010178ff454901016aff46490101a3ff474901019eff484902018cff4a49010177ff4b4901014eff4c49010144ff4d4901014eff4e49010178ff4f490101a8ff50490101d7ff51490101f0ff52490101bcff534901018dff5449010161ff554901013cff564901016288084a01019a11094a010161ee0a4a010187ff0b4a0101e0cc0c4a010190cc0d4a01018bff0e4a0101eeff0f4a0101efff104a0101c2ff114a01018cff124a0101a0ff134a0101e3ff144a0101a9ff154a0101a4ff164a0101a3ff174a010186ff184a01019eff194a0101cfff1a4a0101d7ff1b4a0101d6ff1c4a0101d1ff1d4a0301ffff204a0101faff214a0101d0ff224a0101d6ff234a0101f7ff244a0101ffff254a0101fdff264a0101fbff274a0101f9ff284a0101b6ff294a01016eff2a4a010128ff2b4a01014aff2c4a010145ff2d4a010113ff2e4a010171ff2f4a020167ff314a010179ff324a010117ff334a01015aff344a01014fff354a010137ff364a010168ff374a0101aeff384a0101c7ff394a0101faff3a4a0201fcff3c4a0101deff3d4a0101dfff3e4a0101ffff3f4a0101faff404a0101ffff414a0101e6ff424a0101bcff434a0101fbff444a0101f3ff454a0101d6ff464a0101c1ff474a0101aaff484a010178ff494a0101a1ff4a4a0101a3ff4b4a0101a9ff4c4a0101ccff4d4a0101ceff4e4a010179ff4f4a0101aeff504a0101d6ff514a0101eeff524a010199ff534a01018edd544a0101e0cc554a010190ee564a010160ff574a01018322084b01019811094b010190440a4b010198220d4b01013faa0e4b010162ff0f4b010189ff104b0101caff114b0101b5ff124b01019dff134b0101a4ff144b0101e4ff154b0101d6ff164b0101dfff174b0101e5ff184b01018eff194b0101a3ff1a4b0101faff1b4b0101c7ff1c4b0101c2ff1d4b0101bdff1e4b0101bfff1f4b0101d9ff204b0101dfff214b0101d8ff224b0101bcff234b0101bdff244b0101d6ff254b0101d2ff264b0101f3ff274b0101d8ff284b0201faff2a4b0101f9ff2b4b01017aff2c4b010179ff2d4b010147ff2e4b01011eff2f4b0101a1ff304b0101b4ff314b010141ff324b010164ff334b0101beff344b0101a5ff354b0101f4ff364b0101faff374b0101f9ff384b0103f1ff394b0101f0ff3a4b0101d6ff3b4b0101d8ff3c4b0101a9ff3d4b0101a6ff3e4b0101a9ff3f4b01029dff404b0101bfff414b0101a0ff424b0101c1ff434b0101dfff444b0101dbff454b0101d2ff464b0101f0ff474b0101e7ff484b0101f1ff494b0101fcff4a4b0101f6ff4b4b0101c2ff4c4b0101bfff4d4b0101a4ff4e4b0101aeff4f4b0101c0ff504b0101e0ff514b010162ff524b010153cc534b01015122554b01018a11564b01018f33574b010187110d4c01019a110e4c01013dbb0f4c010150ff104c010140ff114c010192ff124c0101e2ff134c0101b4ff144c010166ff154c01015aff164c0101d2ff174c0101ffff184c0101bdff194c01019eff1a4c0101cdff1b4c0101c3ff1c4c0101d8ff1d4c0101d6ff1e4c0201ceff204c0101d6ff214c0101d1ff224c0101a6ff234c010195ff244c0201bcff264c0101e5ff274c0101cfff284c0101d3ff294c0101c9ff2a4c020173ff2c4c01017cff2d4c010129ff2e4c010141ff2f4c010129ff304c01015fff314c010168ff324c0102a2ff334c0101b3ff344c0101a2ff354c010173ff364c0101f3ff374c0102d6ff394c0101f3ff3a4c0101ffff3b4c0101d2ff3c4c020195ff3e4c010296ff404c010196ff414c01019dff424c0101bdff434c0101d6ff444c01019fff454c010195ff464c0101aaff474c0101d8ff484c0101ffff494c0101d9ff4a4c01017eff4b4c020175ff4d4c01017eff4e4c0101b0ff4f4c010198ff504c010135ff514c010133dd524c010191220e4d010184110f4d010152bb104d010136ff114d010131ff124d01013fff134d01013bff144d010114ff154d010126ff164d010144ff174d010170ff184d0101ffff194d0101fbff1a4d0101a6ff1b4d0101a0ff1c4d0101e7ff1d4d0101c2ff1e4d0101f7ff1f4d0101d2ff204d0101cfff214d0101a9ff224d0101a0ff234d010196ff244d01019fff254d0101a6ff264d0101a9ff274d0101a0ff284d0101a9ff294d0101f7ff2a4d0101aeff2b4d0101a5ff2c4d0101f0ff2d4d01015cff2e4d010156ff2f4d010121ff304d010146ff314d0101a5ff334d0101ceff344d01019dff354d01018cff364d0101e7ff394d0101aaff3a4d0101a6ff3b4d010196ff3c4d010199ff3d4d01019dff3f4d010199ff404d010195ff414d010199ff424d01019fff434d010190ff444d01014cff454d01013dff464d0101bfff474d0101ffff484d0101acff494d010159ff4a4d010148ff4b4d010124ff4c4d01012aff4d4d010193ff4e4d01018fff4f4d01013dff504d010133dd514d01019833104e010153aa114e01012cff124e01012bff134e010131ff144e01013aff154e010127ff164e01011cff174e010122ff184e010158ff194e0101baff1a4e0101d7ff1b4e01019eff1c4e010196ff1d4e0101e2ff1e4e0101ccff1f4e0101c4ff204e0101dbff214e0102d6ff224e0101cfff234e0101bdff244e02019dff264e010196ff274e0101a6ff284e0101f0ff294e0101d8ff2a4e0201fbff2c4e0101ccff2d4e0101e7ff2e4e020156ff304e010170ff314e01017bff324e0101bcff334e01019eff344e010196ff354e01018fff364e0101bdff374e0101ffff384e0101ceff394e01018eff3a4e01018cff3b4e010199ff3c4e010196ff3d4e010195ff3e4e03018bff414e010187ff424e010162ff434e01013dff444e010134ff454e01017aff464e0101ffff474e010170ff484e01012aff494e010116ff4a4e010106ff4b4e01012aff4c4e010194ff4d4e010181ff4e4e010180ff4f4e01014cdd504e01018a22114f010153aa124f01012dff134f01012bff144f010140ff154f01013eff164f010113ff174f010158ff184f0101a7ff194f010148ff1a4f010176ff1b4f0101ffff1c4f01017bff1d4f01014eff1e4f010185ff1f4f0101a0ff204f0101e7ff224f0101deff234f0101ffff244f0101bfff254f01019eff264f0101a6ff274f010196ff284f0101d2ff294f0101f7ff2a4f0101d6ff2b4f0101f7ff2c4f0101bdff2d4f0101e5ff2e4f0101a2ff2f4f010146ff304f01017bff314f0101b6ff324f0101d1ff334f0101a9ff344f01018eff354f01018bff364f01018dff374f0101d1ff384f0101a0ff394f0101bdff3a4f0101d6ff3b4f010195ff3c4f010187ff3d4f02018bff3f4f010187ff404f010162ff414f010135ff424f01012dff434f010147ff444f0101c7ff454f0101b3ff464f010157ff474f010175ff484f010170ff494f010100ff4a4f010122ff4b4f010199ff4c4f010184ff4d4f01018fff4e4f01019bbb4f4f010191111250010154771350010133ff145001012bff1550010140ff165001013dff1750010113ff18500101c1ff19500101c5ff1a5001015eff1b50010159ff1c500101b3ff1d500101c8ff1e50010169ff1f5001014eff2050010180ff21500101a9ff22500101e5ff23500101d7ff24500101c4ff2550010195ff2650010196ff27500102a9ff28500101f0ff29500101f3ff2a500101d8ff2b500101d2ff2c500101d6ff2d500101ccff2e500101e5ff2f50010147ff305001016fff31500101f2ff32500101cfff33500102ccff34500101bcff35500101e5ff36500101bdff37500101e5ff38500101d1ff39500101d6ff3a500101d0ff3b5001018bff3c50010193ff3d50010195ff3e5001014fff3f50010135ff4050010112ff4150010138ff42500101a7ff43500101faff445001016cff4550010157ff46500101acff47500101ffff485001011eff4950010134ff4a500101ecff4b500101caff4c5001018fff4d50010189771351010182441451010150cc1551010184ff1651010192ff1751010187ff1851010171ff19510101b6ff1a510101fdff1b510101acff1c5101015eff1d5101016cff1e510101ddff1f510101baff2051010169ff2151010144ff2251010165ff23510101a6ff24510101c3ff25510101d2ff26510101aaff28510101ceff29510101cfff2a510201a6ff2c510101a0ff2d510101bfff2e510101bcff2f51010193ff3051010177ff31510101e5ff32510101a0ff34510101d0ff35510101d4ff36510101f0ff37510101f4ff38510101a9ff39510101bcff3a51010165ff3b51010162ff3c51010285ff3d5101014bff3e51010137ff3f51010142ff40510101a7ff41510101f9ff425101017cff4351010159ff4451010175ff45510101fdff46510101b7ff4751010174ff4851010171ff49510101cdff4a510101e5ff4b51010199dd4c5101018a44155201018a881652010198ff17520101caff18520101e6ff19520101a4ff1a520101a7ff1b520101f6ff1c520101ffff1d52010175ff1e52010124ff1f5201016bff20520101c8ff21520101deff225201017dff2352010178ff24520101a1ff25520101a9ff26520101bdff27520101a4ff28520101a0ff29520201e5ff2b520101a6ff2c52010195ff2d5202018dff2f52010183ff3052010190ff315201018dff3252010199ff33520101e4ff34520101e7ff35520101edff36520101bcff37520101ccff38520101e2ff3952010265ff3a5201013eff3b5201018bff3d5201016aff3e520101b1ff3f520101d5ff4052010170ff4152010121ff4252010159ff43520101dbff44520101ffff45520101aeff46520101a1ff47520101b5ff48520101ceff495201019eff4a52010192aa4b5201018a111653010191331753010188bb1853010180ff19530101a9ff1a530101d1ff1b530101b8ff1c530101c6ff1d53010159ff1e53010129ff1f53010110ff2053010118ff2153010149ff225301017eff23530101ddff24530101f6ff25530101f0ff26530101ccff2753010194ff285301016aff295301014eff2a5301014fff2b5301019dff2c5301019eff2d53010185ff2e5301017fff2f53010135ff305301013dff315301017fff3253010186ff3353010180ff345301017fff355301014bff365301013dff375301013eff385301014bff3a530101bcff3b530101cfff3c530101c4ff3d530101afff3e5301016bff3f5301012aff4053010120ff4153010113ff4253010124ff43530101baff44530101b6ff45530101b5ff46530101e5ff4753010195ff485301018fee495301019855185401018877195401017fee1a5401018cff1b540101c2ff1c54010170ff1d54010146ff1e5401012aff1f54020120ff2154010125ff225401012aff2354010149ff245401016bff255401017eff26540101baff27540101fbff28540101b8ff29540101a5ff2a54010178ff2b54020165ff2d5401014eff2e5401014bff2f54010134ff3054010132ff315401014bff325401014fff335402014eff3554010163ff3654010178ff37540101a7ff38540101b8ff39540101c7ff3a540101acff3b54010270ff3c5401015eff3d54010159ff3e5401015eff3f5401015fff405401015bff4154010129ff4254010119ff4354010149ff44540101c5ff455401019dff465401018bff475401018f9948540101ea2219550101e1221a55010189991b55010186ff1c55010145ff1d55010129ff1e55010125ff1f55010121ff2055010146ff2155010158ff225501015fff235502016cff255501016bff265501016cff275501016fff285501017aff29550101a1ff2a5501019dff2b5503019bff2e5501019aff2f55010198ff3055010192ff3155010199ff325504019bff365501019cff375501017aff3855010173ff395501016fff3a5501016dff3c5502017cff3e55010175ff3f5501016fff405501015cff4155010146ff4255010117ff435501011fff4455010185ff455501018ebb46550101e1331b560101e1331c5601019b991d56010177ff1e56010142ff1f5601011eff2056010148ff2156010175ff225601017eff2356020170ff255601017cff26560101adff27560101b1ff28560101b0ff2956010167ff2a56020131ff2c56010135ff2d5602012eff2f5602012cff315603012eff3456020131ff3656010161ff37560101aaff38560101b5ff39560101b6ff3a560101b1ff3b5601017dff3c5601017cff3d5602017eff3f5601016dff4056010156ff4156010145ff4256010165ff435601019bcc44560101e0441d570101ea331e570101ca991f57010193ee2057010164ff2157010169ff2257010176ff23570101b3ff24570101baff25570101acff265701017dff27570101a5ff28570101a9ff2957010180ff2a5704012fff2e5701012bff2f57010111ff3057010112ff3157010130ff325704012fff3657010150ff37570101a9ff38570101a5ff39570101aeff3a570101b2ff3b570101baff3c570101b9ff3d570101a8ff3e5701017aff3f5701016aff4057010193ff41570101cabb42570101eb441f580101ea2220580101cb8821580101a0dd225801019cff2358010178ff24580101a1ff25580101bfff26580101d2ff27580101c4ff28580101c0ff2958010196ff2a58010180ff2b5801017fff2c5801013fff2d58010136ff2e58010131ff2f5801012eff3058020131ff3258010136ff3358010140ff3458010150ff355801017fff3658010195ff37580101beff38580101c3ff39580101c4ff3a580101bfff3b580101a3ff3c580101a1ff3d5801019cff3e5801019fdd3f580101cb8840580101ea3322590101e04423590101e0992459010180dd255901014fff265901019cff27590201a3ff29590101a9ff2a590101bcff2b590101cbff2c590101bbff2d5901019bff2e5901019aff2f59020197ff315901019aff32590101e0ff33590101bbff34590101caff35590101e2ff36590101aaff37590101a3ff38590101a1ff39590101a3ff3a59010185ff3b59010187dd3c590101e0993d5901019b553e5901019111255a0101bb66265a0101ccbb275a0101ccdd285a0101a9ff295a0101a6ff2a5a01019dff2b5a010196ff2c5a01018cff2d5a020185ff2f5a010180ff305a01017fff315a010185ff325a02018cff345a010194ff355a01019dff365a0101a3ff375a0101bcff385a0101ccdd395a0101ccbb3a5a0101bb883b5a0101e811275b01014011285b01019922295b0101ca442a5b0101e2662b5b0101e2882c5b0101ca992d5b0101e0bb2e5b01019bcc2f5b020182ff315b01019bcc325b0101e0bb335b0101caaa345b0101e299355b0101cb66365b0101ca44375b0101e022385b010182112f5c02019177]]}

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
	local holder=frame(parent,Color3.fromRGB(5,10,27),kind=="logo" and 1 or .1)
	holder.Name="ArtworkHolder_"..kind; holder.ClipsDescendants=kind~="logo"
	if kind~="logo" then round(holder,12) end
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
	Name="BootSurface",BackgroundColor3=C.bg,BackgroundTransparency=.06,Size=UDim2.fromScale(1,1),Visible=false,GroupTransparency=1,ZIndex=3,
})
UI.bootState={ready=false,checks={},keyState="skipped",started=os.clock(),warnings=false}
UI.bootLogo=imagePanel(UI.bootSurface,"logo"); rect(UI.bootLogo,18,18,64,64)
UI.logoSlots.BOOT=UI.bootLogo
UI.bootTitle=label(UI.bootSurface,"bootTitle",24,C.text,true)
UI.bootSubtitle=label(UI.bootSurface,"bootSubtitle",14,C.muted)
UI.bootClose=button(UI.bootSurface,"×",false,function() UI.gui:Destroy() end,"BootClose",true)
UI.bootLanguage=button(UI.bootSurface,"EN / VI",false,function() UI.openLanguages() end,"BootLanguage",true)
UI.bootProgressTrack=frame(UI.bootSurface,C.card); round(UI.bootProgressTrack,3)
UI.bootProgress=frame(UI.bootProgressTrack,Color3.new(1,1,1)); UI.bootProgress.Size=UDim2.fromScale(0,1); round(UI.bootProgress,3); gradient(UI.bootProgress)
UI.bootSummary=label(UI.bootSurface,"bootChecking",13,C.cyan,true)
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
	local logoReady=logo and logo.state=="loaded"
		UI.bootState.artwork={logoReady=logoReady==true,source=logo and logo.source or "",fullImageLoaded=logoReady and logo.source~="rasterImage" or false,portalLoaded=portal and portal.state=="loaded" or false}
	local artDetail=logoReady and tr("loaded") or (artPending and tr("imageLoading") or tr("bootAssetWarn"))
	if logo and logo.source=="rasterImage" and not artPending then artDetail=tr("bootNative") end
	check("artwork",artPending and "checking" or (logoReady and "passed" or "warning"),artDetail)
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
	rect(UI.statusSubtitle,10,31,w-20,14); UI.statusSubtitle.TextSize=11
	rect(UI.statusScroll,10,50,w-20,math.max(20,h-96)); UI.statusList.TextSize=12
	rect(UI.statusCount,10,h-42,w-20,12); UI.statusCount.TextSize=11
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
	return {build="KYVORIX Client UI 7.4",language=S.language,mode=S.mode,page=S.page,transitioning=S.transitioning,boot=UI.bootState,
		fast=S.fast,reduced=S.reduced,aura=S.aura,particles=S.particles,features=UI.featureCount(),assets=assets,
		window={width=UI.window.Size.X.Offset,height=UI.window.Size.Y.Offset,x=UI.window.Position.X.Offset,y=UI.window.Position.Y.Offset},
		artworkErrors={logo=UI.assetJobs.logo.errors,portal=UI.assetJobs.portal.errors},nativeLogoNodes=UI.nativeLogoNodes or 0,nativeLogoResolution=NATIVE_LOGO.size,
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
