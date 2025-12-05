extends Node2D

@onready var bola = $Ball
@onready var lbl_notif = $CanvasLayer/LbNotif

var posisi_start_bola: Vector2
var tween_notif:Tween


# --- UI REFERENSI ---
@onready var btn_easy = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnEasy
@onready var btn_normal = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnNormal
@onready var btn_hard = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnHard
@onready var btn_extreme = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnExtreme

@onready var lbl_balance = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/GridContainer/LbBalance
@onready var lbl_bet = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/GridContainer/VBoxContainer/LbBet
@onready var lbl_win = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/GridContainer/LbWin
@onready var btn_main = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/HBoxContainer/Bet

@onready var lb_info = $CanvasLayer/Panel/LbInfo

# poup menang
@onready var popup_hasil = $CanvasLayer/PopupHasil
@onready var lbl_result_title = $CanvasLayer/PopupHasil/ColorRect/Panel/MarginContainer/VBoxContainer/LbTitle
@onready var lbl_result_amount = $CanvasLayer/PopupHasil/ColorRect/Panel/MarginContainer/VBoxContainer/LbAmount



# --- STATE GAME ---
var is_game_active: bool = false # Apakah bola sedang main?

func _ready():
	randomize()
	# Setup Awal
	update_tampilan_tombol_level()
	update_ui_text()
	update_info_tambahan()

	if bola: posisi_start_bola = bola.global_position

	if popup_hasil: popup_hasil.visible = false
	
	if lbl_notif:
		lbl_notif.visible = false
		lbl_notif.modulate.a = 0
	
	# Koneksi Signal Target
	for child in get_children():
		if child.has_signal("target_clicked"):
			if not child.target_clicked.is_connected(_on_target_dipilih):
				child.target_clicked.connect(_on_target_dipilih)
			if not child.target_hit.is_connected(_on_bola_kena_target):
				child.target_hit.connect(_on_bola_kena_target)
			if not child.game_over.is_connected(_on_game_over):
				child.connect("game_over", _on_game_over)

# --- FUNGSI BARU: TAMPILKAN POPUP ---
func tampilkan_popup_hasil(menang: bool, jumlah: float):
	if not popup_hasil: return
	
	popup_hasil.visible = true
	
	if menang:
		lbl_result_title.text = "YOU WIN!"
		lbl_result_title.modulate = Color.GREEN
		lbl_result_amount.text = "+ $" + str(snapped(jumlah, 0.01))
		lbl_result_amount.modulate = Color.GOLD
	else:
		lbl_result_title.text = "GAME OVER"
		lbl_result_title.modulate = Color.RED
		# Tampilkan minus bet yang hilang
		lbl_result_amount.text = "- $" + str(snapped(GameData.current_bet, 0.01))
		lbl_result_amount.modulate = Color.WHITE

func _on_btn_close_result_pressed():
	# Sembunyikan popup agar pemain bisa main lagi
	popup_hasil.visible = false
	AudioManager.resume_bgm()
	
# --- FUNGSI BARU: MENAMPILKAN NOTIFIKASI ---
func tampilkan_notifikasi(pesan: String):
	if not lbl_notif: return
	
	# 1. Reset animasi sebelumnya (jika ada) agar tidak bentrok kalau diklik cepat
	if tween_notif and tween_notif.is_valid():
		tween_notif.kill()
	
	# 2. Set Teks & Tampilkan
	lbl_notif.text = pesan
	lbl_notif.visible = true
	lbl_notif.modulate.a = 1.0 # Pastikan terlihat penuh (Opaque)
	
	# 3. Buat Animasi (Tween)
	tween_notif = create_tween()
	
	# Efek: Diam selama 1 detik, lalu memudar (fade out) selama 0.5 detik
	tween_notif.tween_interval(1.0) 
	tween_notif.tween_property(lbl_notif, "modulate:a", 0.0, 0.5)
	
	# Setelah selesai memudar, sembunyikan node-nya
	tween_notif.tween_callback(func(): lbl_notif.visible = false)


# --- FUNGSI UPDATE UI ---
func update_ui_text():
	lbl_balance.text = "Balance: $" + str(snapped(GameData.balance, 0.01))
	lbl_bet.text = "$" + str(GameData.current_bet)

# --- TOMBOL PLUS / MINUS ---
func _on_btn_min_pressed():
	if is_game_active: return # Gak boleh ganti bet pas main
	AudioManager.play_click()
	GameData.current_bet -= 0.5
	if GameData.current_bet < 0.5: GameData.current_bet = 0.5
	update_ui_text()

func _on_btn_plus_pressed():
	if is_game_active: return
	AudioManager.play_click()
	GameData.current_bet += 0.5
	if GameData.current_bet > 10.0: GameData.current_bet = 10.0
	update_ui_text()

# --- TOMBOL UTAMA (BET / CASHOUT) ---
func _on_btn_main_pressed():
	AudioManager.play_click()
	if not is_game_active:
		# LOGIKA MULAI GAME (BET)
		start_game()
	else:
		# LOGIKA BERHENTI (CASHOUT)
		do_cashout()

func start_game():
	# Cek Saldo
	AudioManager.play_click()
	if GameData.balance < GameData.current_bet:
		print("Saldo tidak cukup!")
		return
	
	# 1. Potong Saldo
	GameData.balance -= GameData.current_bet
	
	# 2. Reset Data Ronde
	GameData.current_step = 0
	is_game_active = true
	
	# 3. Update Visual
	# Matikan tombol level dan plus minus biar gak diganti pas main
	toggle_ui_settings(false) 
	
	# Reset semua target
	get_tree().call_group("GrupTarget", "reset_tampilan_ronde") 
	
	# Ubah tombol jadi Cashout
	update_tombol_cashout() 
	update_ui_text()
	update_info_tambahan()
	print("Game Dimulai! Bet Terkunci: ", GameData.current_bet)

func do_cashout():
	# Cek apakah user cashout sebelum main (Refund)
	if GameData.current_step == 0:
		GameData.balance += GameData.current_bet
		print("Cashout Awal (Refund)")
	else:
		# --- PERBAIKAN DI SINI ---
		# HAPUS baris: GameData.current_step -= 1 
		# Kita langsung hitung kemenangan berdasarkan step terakhir yang dicapai
		AudioManager.play_win()
		var win_amount = GameData.get_current_win_value()
		GameData.balance += win_amount
		print("CASHOUT SUKSES! Menang: ", win_amount)
		tampilkan_popup_hasil(true, win_amount)
	
	reset_game_state()


func update_info_tambahan():
	var streak = GameData.current_step
	var target_total = GameData.JACKPOT_LIMITS[GameData.current_difficulty_name]
	lb_info.text ="Target : " + str(streak) + "/" + str(target_total)

# --- HELPER LOGIC ---
func update_tombol_cashout():
	if GameData.current_step == 0:
		btn_main.text = "Running..."
		# Reset label WIN
		lbl_win.text = "WIN\n-" 
		return

	var win_val = GameData.get_current_win_value()
	
	# Update tombol Cashout
	btn_main.text = "CASHOUT: $" + str(snapped(win_val, 0.01))
	
	# Update Label WIN di UI (sesuai screenshot)
	# Pastikan Anda punya node Label bernama LblWin
	lbl_win.text = "WIN\n$" + str(snapped(win_val, 0.01))

func reset_game_state():
	is_game_active = false
	GameData.current_step = 0
	
	btn_main.text = "BET"
	toggle_ui_settings(true) # Nyalakan lagi tombol setting
	update_ui_text()
	update_info_tambahan()
	
	# Reset bola
	if bola: bola.reset_posisi(posisi_start_bola)
	get_tree().call_group("GrupTarget", "reset_tampilan_ronde")

func toggle_ui_settings(aktif: bool):
	# Fungsi mematikan/menyalakan tombol setting
	btn_easy.disabled = !aktif
	btn_normal.disabled = !aktif
	btn_hard.disabled = !aktif
	btn_extreme.disabled = !aktif
	# disable btn plus minus juga kalau perlu

# --- INTERAKSI TARGET ---
func _on_target_dipilih(target_node):
	# PENTING: Target gak boleh diklik kalau belum tekan BET
	if not is_game_active:
		print("Klik BET Dulu!")
		tampilkan_notifikasi("Klik BET Dulu BOS!")
		return
	
	# Logic RNG (Sama seperti sebelumnya)
	var acak = randf()
	var jadi_jebakan = false
	
	if acak <= GameData.current_rtp:
		jadi_jebakan = false
	else:
		jadi_jebakan = true
	
	target_node.siapkan_nasib(jadi_jebakan)
	if bola: bola.tembak_ke(target_node.global_position)

# --- BAGIAN UPDATE DI MainLevel.gd ---

func _on_bola_kena_target():
	print("Target Aman. Naik Step.")
	
	# Naikkan langkah
	GameData.current_step += 1
	
	# Update tombol cashout dengan nominal baru
	update_tombol_cashout()
	update_info_tambahan()
	
	# --- LOGIKA BARU: CEK JACKPOT ---
	if GameData.is_jackpot_reached():
		print("JACKPOT TERCAPAI!")
		# Tunggu sebentar biar animasi bola sampai dulu
		await get_tree().create_timer(0.5).timeout 
		menang_jackpot()
	else:
		# Jika belum jackpot, reset bola dan lanjut main
		await get_tree().create_timer(1.0).timeout
		if bola: bola.reset_posisi(posisi_start_bola)

# --- FUNGSI BARU: MENANG JACKPOT ---
func menang_jackpot():
	var win_amount = GameData.get_current_win_value()
	GameData.balance += win_amount
	
	# Tidak perlu notif teks tombol lagi, langsung popup besar saja
	print("JACKPOT!")
	
	# PANGGIL POPUP MENANG (JACKPOT)
	tampilkan_popup_hasil(true, win_amount)
	# Override judulnya jadi JACKPOT biar lebih seru
	lbl_result_title.text = "JACKPOT!!"
	lbl_result_title.modulate = Color.GOLD
	
	reset_game_state()


func _on_game_over():
	print("ZONK!")
	
	# Jeda sedikit agar lihat ledakan
	await get_tree().create_timer(1.0).timeout
	
	# PANGGIL POPUP KALAH
	# Jumlah 0 karena kita cuma mau kasih tau dia rugi Bet
	tampilkan_popup_hasil(false, 0.0)
	
	reset_game_state()

# --- FUNGSI TOMBOL LEVEL ---
# (Sama seperti sebelumnya, tapi tambahkan toggle_ui_settings biar aman)
func update_tampilan_tombol_level():
	btn_easy.modulate = Color.WHITE
	btn_normal.modulate = Color.WHITE
	btn_hard.modulate = Color.WHITE
	btn_extreme.modulate = Color.WHITE
	
	match GameData.current_difficulty_name:
		"Easy": btn_easy.modulate = Color.GREEN
		"Normal": btn_normal.modulate = Color.GREEN
		"Hard": btn_hard.modulate = Color.GREEN
		"Extreme": btn_extreme.modulate = Color.GREEN
	
	update_info_tambahan()

func _on_btn_easy_pressed():
	AudioManager.play_click()
	if is_game_active: return
	GameData.set_difficulty(0.90, "Easy")
	update_tampilan_tombol_level()

func _on_btn_normal_pressed():
	AudioManager.play_click()
	if is_game_active: return
	GameData.set_difficulty(0.70, "Normal")
	update_tampilan_tombol_level()

func _on_btn_hard_pressed():
	AudioManager.play_click()
	if is_game_active: return
	GameData.set_difficulty(0.40, "Hard")
	update_tampilan_tombol_level()

func _on_btn_extreme_pressed():
	AudioManager.play_click()
	if is_game_active: return
	GameData.set_difficulty(0.10, "Extreme")
	update_tampilan_tombol_level()
