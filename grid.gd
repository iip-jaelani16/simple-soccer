extends Node2D

@export var cell_scene: PackedScene
@export var cell_size := Vector2(70, 70)
@export var columns := 7
@export var rows := 4


const LAYOUT := [
	[1,1,1,1,1,1,1],
	[1,1,1,0,1,1,1],
	[1,1,0,0,0,1,1],
	[1,0,0,0,0,0,1],
]

signal grid_clicked(pos: Vector2)

func _ready():
	for row in LAYOUT.size():
		for col in LAYOUT[row].size():
			if LAYOUT[row][col] == 0:
				continue

			var cell := cell_scene.instantiate()
			add_child(cell)

			cell.position = Vector2(
				col * cell_size.x + cell_size.x / 2,
				row * cell_size.y + cell_size.y / 2
			)
			cell.cell_clicked.connect(_on_cell_clicked)
			
	resize_to_screen()
	get_viewport().size_changed.connect(resize_to_screen)


func _on_cell_clicked(pos: Vector2):
	print("Grid terima klik dari cell di: ", pos)
	grid_clicked.emit(pos)  
	
	
func resize_to_screen():
	var screen_width = get_viewport().size.x
	
	var total_grid_width = columns * cell_size.x
	
	var scale_factor = screen_width / total_grid_width
	scale = Vector2(scale_factor, scale_factor)

	
	var new_width = total_grid_width * scale_factor
	position.x = (screen_width - new_width) * 0.5

	
