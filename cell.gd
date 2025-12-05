extends Area2D

# Update Signal: Mengirim object target ini sendiri
signal target_clicked(target_node) 
signal target_hit
signal game_over

@export var region_normal: Rect2
@export var region_hit: Rect2
@export var region_caught: Rect2

@onready var sprite = $Sprite2D

# State
var adalah_target_aktif: bool = false
var adalah_jebakan: bool = false
var sudah_selesai: bool = false

func _ready():
	add_to_group("GrupTarget")
	input_event.connect(_on_input_event)
	body_entered.connect(_on_body_entered)
	
	# Setup awal
	reset_tampilan_ronde()
	if sprite:
		sprite.region_enabled = true

# --- FUNGSI SETTING NASIB (Dipanggil MainLevel saat Klik) ---
func siapkan_nasib(status_jebakan: bool):
	# Fungsi ini dipanggil TEPAT sebelum bola meluncur
	adalah_jebakan = status_jebakan
	
	# Reset visual ke normal dulu (biar pemain tidak tahu)
	# Walaupun sebenarnya sudah direset di awal, ini untuk keamanan ganda
	if sprite:
		sprite.region_rect = region_normal

# --- RESET VISUAL (PERBAIKAN UTAMA DISINI) ---
func reset_tampilan_ronde():
	# 1. Reset Status Logika ke Awal
	adalah_target_aktif = false
	adalah_jebakan = false
	sudah_selesai = false  # <--- PENTING: Paksa reset jadi false agar bisa dimainkan lagi
	
	# 2. Reset Visual ke Normal
	modulate = Color.WHITE
	
	# Selalu kembalikan gambar ke posisi Normal, tidak peduli status sebelumnya
	if sprite:
		sprite.region_rect = region_normal

# --- INPUT HANDLE ---
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Jika target ini sudah terbuka (selesai), jangan bisa diklik lagi
		if sudah_selesai: return
		
		# Matikan seleksi visual di target lain
		get_tree().call_group("GrupTarget", "matikan_seleksi")
		
		# Aktifkan diri sendiri
		adalah_target_aktif = true
		modulate = Color(1.2, 1.2, 0.5) # Highlight Kuning
		
		# Kirim sinyal ke MainLevel
		target_clicked.emit(self)

# Fungsi ini dipanggil oleh target LAIN saat mereka diklik
func matikan_seleksi():
	adalah_target_aktif = false
	
	# Kembalikan warna sesuai status
	if sudah_selesai:
		# Jika sudah terbuka, biarkan agak gelap/berbeda (opsional)
		modulate = Color(0.8, 0.8, 0.8) 
	else:
		# Jika belum, balik ke putih bersih
		modulate = Color.WHITE

# --- COLLISION HANDLE ---
func _on_body_entered(body):
	# Hanya bereaksi jika saya target yang sedang aktif (dipilih)
	if not adalah_target_aktif: return
	
	# Jika bola nyasar masuk lagi ke target yang sudah selesai, abaikan
	if sudah_selesai: return

	if body.name == "Bola" or body is RigidBody2D: # Sesuaikan nama node bola Anda
		if body.has_method("hentikan_animasi"):
			body.hentikan_animasi()
		
		# EKSEKUSI NASIB YANG SUDAH DIHITUNG MAIN LEVEL
		if adalah_jebakan:
			print("ZONK! Kena Jebakan")
			# Ganti gambar jadi Bom/Caught
			if sprite:
				sprite.region_rect = region_caught
			
			# Beri warna merah
			modulate = Color.RED
			AudioManager.play_explode()
			game_over.emit()
		
		else:
			print("AMAN! (Win)")
			# Tandai selesai agar tidak bisa diklik lagi ronde ini
			sudah_selesai = true
			
			# Ganti gambar jadi Terbuka/Hit
			if sprite:
				sprite.region_rect = region_hit
			
			AudioManager.play_hit()
			target_hit.emit()
