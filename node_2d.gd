extends Node2D

@onready var bola = $Ball
@onready var lbl_notif = $CanvasLayer/LbNotif

var posisi_start_bola: Vector2
var tween_notif:Tween



@onready var btn_easy = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnEasy
@onready var btn_normal = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnNormal
@onready var btn_hard = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnHard
@onready var btn_extreme = $CanvasLayer/Panel/VBoxContainer/Level/MarginContainer/VBoxContainer/GridContainer/BtnExtreme

@onready var lbl_balance = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/GridContainer/LbBalance
@onready var lbl_bet = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/GridContainer/VBoxContainer/LbBet
@onready var lbl_win = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/GridContainer/LbWin
@onready var btn_main = $CanvasLayer/Panel/VBoxContainer/Panel2/MarginContainer/VBoxContainer/HBoxContainer/Bet

@onready var lb_info = $CanvasLayer/Panel/LbInfo


@onready var popup_hasil = $CanvasLayer/PopupHasil
@onready var lbl_result_title = $CanvasLayer/PopupHasil/ColorRect/Panel/MarginContainer/VBoxContainer/LbTitle
@onready var lbl_result_amount = $CanvasLayer/PopupHasil/ColorRect/Panel/MarginContainer/VBoxContainer/LbAmount




var is_game_active: bool = false 

func _ready():
	randomize()
	
	update_tampilan_tombol_level()
	update_ui_text()
	update_info_tambahan()

	if bola: posisi_start_bola = bola.global_position

	if popup_hasil: popup_hasil.visible = false
	
	if lbl_notif:
		lbl_notif.visible = false
		lbl_notif.modulate.a = 0
	
	
	for child in get_children():
		if child.has_signal("target_clicked"):
			if not child.target_clicked.is_connected(_on_target_dipilih):
				child.target_clicked.connect(_on_target_dipilih)
			if not child.target_hit.is_connected(_on_bola_kena_target):
				child.target_hit.connect(_on_bola_kena_target)
			if not child.game_over.is_connected(_on_game_over):
				child.connect("game_over", _on_game_over)


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
		
		lbl_result_amount.text = "- $" + str(snapped(GameData.current_bet, 0.01))
		lbl_result_amount.modulate = Color.WHITE

func _on_btn_close_result_pressed():
	
	popup_hasil.visible = false
	AudioManager.resume_bgm()
	

func tampilkan_notifikasi(pesan: String):
	if not lbl_notif: return
	
	
	if tween_notif and tween_notif.is_valid():
		tween_notif.kill()
	
	
	lbl_notif.text = pesan
	lbl_notif.visible = true
	lbl_notif.modulate.a = 1.0 
	
	
	tween_notif = create_tween()
	
	
	tween_notif.tween_interval(1.0) 
	tween_notif.tween_property(lbl_notif, "modulate:a", 0.0, 0.5)
	
	
	tween_notif.tween_callback(func(): lbl_notif.visible = false)



func update_ui_text():
	lbl_balance.text = "Balance: $" + str(snapped(GameData.balance, 0.01))
	lbl_bet.text = "$" + str(GameData.current_bet)


func _on_btn_min_pressed():
	if is_game_active: return 
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


func _on_btn_main_pressed():
	AudioManager.play_click()
	if not is_game_active:
		
		start_game()
	else:
		
		do_cashout()

func start_game():
	
	AudioManager.play_click()
	if GameData.balance < GameData.current_bet:
		print("Saldo tidak cukup!")
		return
	
	
	GameData.balance -= GameData.current_bet
	
	
	GameData.current_step = 0
	is_game_active = true
	
	
	
	toggle_ui_settings(false) 
	
	
	get_tree().call_group("GrupTarget", "reset_tampilan_ronde") 
	
	
	update_tombol_cashout() 
	update_ui_text()
	update_info_tambahan()
	print("Game Dimulai! Bet Terkunci: ", GameData.current_bet)

func do_cashout():
	
	if GameData.current_step == 0:
		GameData.balance += GameData.current_bet
		print("Cashout Awal (Refund)")
	else:
		
		
		
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


func update_tombol_cashout():
	if GameData.current_step == 0:
		btn_main.text = "Running..."
		
		lbl_win.text = "WIN\n-" 
		return

	var win_val = GameData.get_current_win_value()
	
	
	btn_main.text = "CASHOUT: $" + str(snapped(win_val, 0.01))
	
	
	
	lbl_win.text = "WIN\n$" + str(snapped(win_val, 0.01))

func reset_game_state():
	is_game_active = false
	GameData.current_step = 0
	
	btn_main.text = "BET"
	toggle_ui_settings(true) 
	update_ui_text()
	update_info_tambahan()
	
	
	if bola: bola.reset_posisi(posisi_start_bola)
	get_tree().call_group("GrupTarget", "reset_tampilan_ronde")

func toggle_ui_settings(aktif: bool):
	
	btn_easy.disabled = !aktif
	btn_normal.disabled = !aktif
	btn_hard.disabled = !aktif
	btn_extreme.disabled = !aktif
	


func _on_target_dipilih(target_node):
	
	if not is_game_active:
		print("Klik BET Dulu!")
		tampilkan_notifikasi("Klik BET Dulu BOS!")
		return
	
	
	var acak = randf()
	var jadi_jebakan = false
	
	if acak <= GameData.current_rtp:
		jadi_jebakan = false
	else:
		jadi_jebakan = true
	
	target_node.siapkan_nasib(jadi_jebakan)
	if bola: bola.tembak_ke(target_node.global_position)



func _on_bola_kena_target():
	print("Target Aman. Naik Step.")
	
	
	GameData.current_step += 1
	
	
	update_tombol_cashout()
	update_info_tambahan()
	
	
	if GameData.is_jackpot_reached():
		print("JACKPOT TERCAPAI!")
		
		await get_tree().create_timer(0.5).timeout 
		menang_jackpot()
	else:
		
		await get_tree().create_timer(1.0).timeout
		if bola: bola.reset_posisi(posisi_start_bola)


func menang_jackpot():
	var win_amount = GameData.get_current_win_value()
	GameData.balance += win_amount
	
	
	print("JACKPOT!")
	
	
	tampilkan_popup_hasil(true, win_amount)
	
	lbl_result_title.text = "JACKPOT!!"
	lbl_result_title.modulate = Color.GOLD
	
	reset_game_state()


func _on_game_over():
	print("ZONK!")
	
	
	await get_tree().create_timer(1.0).timeout
	
	
	
	tampilkan_popup_hasil(false, 0.0)
	
	reset_game_state()



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
