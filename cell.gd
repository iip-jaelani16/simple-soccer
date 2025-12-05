extends Area2D


signal target_clicked(target_node) 
signal target_hit
signal game_over

@export var region_normal: Rect2
@export var region_hit: Rect2
@export var region_caught: Rect2

@onready var sprite = $Sprite2D


var adalah_target_aktif: bool = false
var adalah_jebakan: bool = false
var sudah_selesai: bool = false

func _ready():
	add_to_group("GrupTarget")
	input_event.connect(_on_input_event)
	body_entered.connect(_on_body_entered)
	
	
	reset_tampilan_ronde()
	if sprite:
		sprite.region_enabled = true


func siapkan_nasib(status_jebakan: bool):
	
	adalah_jebakan = status_jebakan
	
	
	
	if sprite:
		sprite.region_rect = region_normal


func reset_tampilan_ronde():
	
	adalah_target_aktif = false
	adalah_jebakan = false
	sudah_selesai = false  
	
	
	modulate = Color.WHITE
	
	
	if sprite:
		sprite.region_rect = region_normal


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		if sudah_selesai: return
		
		
		get_tree().call_group("GrupTarget", "matikan_seleksi")
		
		
		adalah_target_aktif = true
		modulate = Color(1.2, 1.2, 0.5) 
		
		
		target_clicked.emit(self)


func matikan_seleksi():
	adalah_target_aktif = false
	
	
	if sudah_selesai:
		
		modulate = Color(0.8, 0.8, 0.8) 
	else:
		
		modulate = Color.WHITE


func _on_body_entered(body):
	
	if not adalah_target_aktif: return
	
	
	if sudah_selesai: return

	if body.name == "Bola" or body is RigidBody2D: 
		if body.has_method("hentikan_animasi"):
			body.hentikan_animasi()
		
		
		if adalah_jebakan:
			print("ZONK! Kena Jebakan")
			
			if sprite:
				sprite.region_rect = region_caught
			
			
			modulate = Color.RED
			AudioManager.play_explode()
			game_over.emit()
		
		else:
			print("AMAN! (Win)")
			
			sudah_selesai = true
			
			
			if sprite:
				sprite.region_rect = region_hit
			
			AudioManager.play_hit()
			target_hit.emit()
