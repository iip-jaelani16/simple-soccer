extends RigidBody2D

# Pengaturan kecepatan bola
@export var kecepatan: float = 1000.0

# Referensi ke node Animasi (Pastikan nama node di Scene Tree sesuai)
@onready var animation_sprite = $AmimationSprite2D

func _ready():
	# Pastikan mode fisika RigidBody2D tidak Lock/Static
	sleeping = false

func tembak_ke(target_posisi: Vector2):
	# DEBUG: Lihat apakah fungsi ini dipanggil
	print("Menembak ke: ", target_posisi, " dari ", global_position)
	
	sleeping = false # Wajib: Bangunkan bola
	freeze = false   # Wajib: Pastikan tidak beku
	
	AudioManager.play_shoot()
	
	linear_velocity = Vector2.ZERO
	var arah = (target_posisi - global_position).normalized()
	
	if animation_sprite:
		animation_sprite.play("play")
	
	# Terapkan kecepatan
	linear_velocity = arah * kecepatan
	
	# DEBUG: Cek kecepatan akhir
	print("Kecepatan Bola Sekarang: ", linear_velocity)

# Fungsi 2: Reset Posisi (Dipanggil oleh Main Level)
func reset_posisi(posisi_baru: Vector2):
	# Hentikan semua gerakan fisika
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	sleeping = true # Tidurkan sebentar agar posisi stabil
	
	# Matikan animasi
	hentikan_animasi()
	
	# Pindahkan posisi secara paksa (Aman untuk RigidBody)
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(posisi_baru)
	)
	
	# Bangunkan lagi di frame berikutnya (opsional, tapi bagus untuk kestabilan)
	await get_tree().process_frame
	sleeping = false

# Fungsi 3: Hentikan Animasi (Dipanggil saat kena Target)
func hentikan_animasi():
	if animation_sprite:
		animation_sprite.stop()
		animation_sprite.frame = 0 # Kembali ke frame awal
