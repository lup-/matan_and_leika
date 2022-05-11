extends Node2D

signal activate_cell

export(Array) var values
export(PackedScene) var cell_scene
export(ButtonGroup) var button_group
var cells = []


func init_cells(cell_valules):
	cells = []
	for row in cell_valules:
		var cell_row = []
		for cell_value in row:
			var cell = cell_scene.instance()
			cell.value = cell_value
			cell.group = button_group
			var row_index = len(cells)
			var cell_index = len(cell_row)
			var cell_size = 72
			var cell_gap = 10
			cell.set_position(Vector2(cell_index, row_index) * (cell_size+cell_gap))
			cell.connect("toggled", self, "on_button_toggled", [cell])
			cell_row.append(cell)
			add_child(cell)
		cells.append(cell_row)

func set_disable_row(row_index, disable):
	for cell in cells[row_index]:
		cell.disabled = disable

func set_disable_col(col_index, disable):
	for row in cells:
		row[col_index].disabled = disable

func set_disable_all(disable):
	for row in cells:
		for cell in row:
			cell.disabled = disable
	
func enable_only_row(row_index):
	set_disable_all(true)
	set_disable_row(row_index, false)

func enable_only_col(col_index):
	set_disable_all(true)
	set_disable_col(col_index, false)

func enable_only_cell(row_index, col_index):
	set_disable_all(true)
	cells[row_index][col_index].disabled = false
	

func _ready():
	init_cells(values)


func on_button_toggled(pressed, cell):
	if not pressed:
		return
		
	for row_index in len(cells):
		for cell_index in len(cells[row_index]):
			var search_cell = cells[row_index][cell_index]
			if search_cell == cell:
				emit_signal('activate_cell', row_index, cell_index, cell)

