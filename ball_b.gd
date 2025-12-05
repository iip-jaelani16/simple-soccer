extends RigidBody2D


@export var kecepatan: float = 1000.0


@onready var animation_sprite = $AmimationSprite2D

func _ready():
	
	sleeping = false

func tembak_ke(target_posisi: Vector2):
	
	print("Menembak ke: ", target_posisi, " dari ", global_position)
	
	sleeping = false 
	freeze = false   
	
	AudioManager.play_shoot()
	
	linear_velocity = Vector2.ZERO
	var arah = (target_posisi - global_position).normalized()
	
	if animation_sprite:
		animation_sprite.play("play")
	
	
	linear_velocity = arah * kecepatan
	
	
	print("Kecepatan Bola Sekarang: ", linear_velocity)


func reset_posisi(posisi_baru: Vector2):
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	sleeping = true 
	
	
	hentikan_animasi()
	
	
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(posisi_baru)
	)
	
	
	await get_tree().process_frame
	sleeping = false


func hentikan_animasi():
	if animation_sprite:
		animation_sprite.stop()
		animation_sprite.frame = 0 
