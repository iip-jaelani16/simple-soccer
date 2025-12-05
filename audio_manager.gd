extends Node

# Ambil referensi ke anak-anak node
@onready var music_bgm = $AudioBGM
@onready var sfx_click = $AudioClickSFX
@onready var sfx_shoot = $AudioShoot
@onready var sfx_hit = $AudioHit
@onready var sfx_explode = $AudioExplode
@onready var sfx_win = $AudioWin

# Variabel untuk menyimpan volume asli dan tween
var default_bgm_volume: float = 0.0 
var tween_music: Tween

func _ready():
	if music_bgm:
		# 1. Simpan volume awal yang Anda atur di Inspector (biasanya 0 dB)
		default_bgm_volume = music_bgm.volume_db
		
		# 2. Mainkan musik jika belum main
		if not music_bgm.playing:
			music_bgm.play()

# --- FUNGSI WRAPPER SFX ---
func play_click():
	if sfx_click: sfx_click.play()

func play_shoot():
	if sfx_shoot: sfx_shoot.play()

func play_hit():
	if sfx_hit: 
		sfx_hit.pitch_scale = randf_range(0.9, 1.1)
		sfx_hit.play()

func play_explode():
	if sfx_explode: sfx_explode.play()

# --- UPDATE DI BAGIAN WIN & RESUME ---

func play_win():
	# 1. Kecilkan BGM perlahan (Ducking)
	if music_bgm:
		# Reset tween lama jika ada
		if tween_music: tween_music.kill()
		tween_music = create_tween()
		
		# Turunkan volume ke -20 dB (Sangat pelan) dalam durasi 1.0 detik
		tween_music.tween_property(music_bgm, "volume_db", -20.0, 1.0)
	
	# 2. Mainkan suara menang yang keras
	if sfx_win: 
		sfx_win.play()

func resume_bgm():
	if music_bgm:
		# Reset tween lama
		if tween_music: tween_music.kill()
		tween_music = create_tween()
		
		# Kembalikan volume ke posisi Awal (default) dalam durasi 2.0 detik (lebih pelan naiknya)
		tween_music.tween_property(music_bgm, "volume_db", default_bgm_volume, 2.0)
		
		# Jaga-jaga kalau musiknya mati, nyalakan lagi
		if not music_bgm.playing:
			music_bgm.play()
