extends Node2D

@onready var grid := $Grid
@onready var ball := $Ball

func _ready():
	grid.grid_clicked.connect(_on_cell_clicked)

func _on_cell_clicked(target_pos: Vector2):
	ball.move_to(target_pos)
