extends Node


@onready var music_bgm = $AudioBGM
@onready var sfx_click = $AudioClickSFX
@onready var sfx_shoot = $AudioShoot
@onready var sfx_hit = $AudioHit
@onready var sfx_explode = $AudioExplode
@onready var sfx_win = $AudioWin


var default_bgm_volume: float = 0.0 
var tween_music: Tween

func _ready():
	if music_bgm:
		
		default_bgm_volume = music_bgm.volume_db
		
		
		if not music_bgm.playing:
			music_bgm.play()


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



func play_win():
	
	if music_bgm:
		
		if tween_music: tween_music.kill()
		tween_music = create_tween()
		
		
		tween_music.tween_property(music_bgm, "volume_db", -20.0, 1.0)
	
	
	if sfx_win: 
		sfx_win.play()

func resume_bgm():
	if music_bgm:
		
		if tween_music: tween_music.kill()
		tween_music = create_tween()
		
		
		tween_music.tween_property(music_bgm, "volume_db", default_bgm_volume, 2.0)
		
		
		if not music_bgm.playing:
			music_bgm.play()
