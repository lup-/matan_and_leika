extends Node2D

signal multiplied

export(PackedScene) var matrix_scene
export(PackedScene) var result_scene

export(Array) var values_a = [[1, 2], [2, 3], [3, 4], [4, 5]]
export(Array) var values_b = [[3, 4, 5], [6, 7, 8]]

var matrix_a
var matrix_b
var matrix_result

var active_a_cell_data
var active_b_cell_data

var activation_history = []

var a_columns = 0
var a_rows = 0
var b_columns = 0
var b_rows = 0


func _ready():
	a_columns = len(values_a[0])
	a_rows = len(values_a)
	b_columns = len(values_b[0])
	b_rows = len(values_b)
	var cell_size = 72
	var cell_gap = 10
	
	matrix_a = matrix_scene.instance()
	matrix_a.values = values_a
	matrix_a.set_position(Vector2(0, b_rows) * (cell_size + cell_gap))
	matrix_a.connect("activate_cell", self, "on_activate_a_cell")
	add_child(matrix_a)
	
	matrix_b = matrix_scene.instance()
	matrix_b.values = values_b
	matrix_b.set_position(Vector2(a_columns, 0) * (cell_size + cell_gap))
	matrix_b.connect("activate_cell", self, "on_activate_b_cell")
	add_child(matrix_b)
	
	var result_values = []
	for row_index in a_rows:
		var row = []
		for col_index in b_columns:
			row.append(0)
		result_values.append(row)
	
	matrix_result = result_scene.instance()
	matrix_result.values = result_values
	matrix_result.set_position(Vector2(a_columns, b_rows) * (cell_size + cell_gap))
	matrix_result.connect("activate_cell", self, "on_activate_result_cell")
	add_child(matrix_result)

func toggle_result_activity():
	if active_a_cell_data and active_b_cell_data:
		matrix_result.enable_only_cell(active_a_cell_data[0], active_b_cell_data[1])
	elif active_a_cell_data:
		matrix_result.enable_only_row(active_a_cell_data[0])
	elif active_b_cell_data:
		matrix_result.enable_only_col(active_b_cell_data[1])
	else:
		matrix_result.set_disable_all(false)

func get_activated_a_by_b(row_index, col_index):
	var activated = []
	for rec in activation_history:
		var cell_a_data = rec[0]
		var cell_b_data = rec[1]
		if cell_b_data[0] == row_index and cell_b_data[1] == col_index:
			activated.append(cell_a_data[2])
	return activated

func get_activated_b_by_a(row_index, col_index):
	var activated = []
	for rec in activation_history:
		var cell_a_data = rec[0]
		var cell_b_data = rec[1]
		if cell_a_data[0] == row_index and cell_a_data[1] == col_index:
			activated.append(cell_b_data[2])
	return activated

func is_finished():
		var needed_operations = a_rows * b_columns * a_columns
		return len(activation_history) >= needed_operations
	

func toggle_ab_activity():
	if not active_a_cell_data and not active_b_cell_data:
		if is_finished():
			matrix_a.set_disable_all(true)
			matrix_b.set_disable_all(true)
		else:
			matrix_a.set_disable_all(false)
			matrix_b.set_disable_all(false)
	elif active_b_cell_data:
		var activated_a_cells = get_activated_a_by_b(active_b_cell_data[0], active_b_cell_data[1])
		for cell in activated_a_cells:
			cell.disabled = true
	elif active_a_cell_data:
		var activated_b_cells = get_activated_b_by_a(active_a_cell_data[0], active_a_cell_data[1])
		for cell in activated_b_cells:
			cell.disabled = true


func on_activate_a_cell(row_index, col_index, cell):
	active_a_cell_data = [row_index, col_index, cell]
	matrix_b.enable_only_row(col_index)
	toggle_result_activity()
	toggle_ab_activity()
	
func on_activate_b_cell(row_index, col_index, cell):
	active_b_cell_data = [row_index, col_index, cell]
	matrix_a.enable_only_col(row_index)
	toggle_result_activity()
	toggle_ab_activity()

func on_activate_result_cell(_row_index, _col_index, cell):
	if not active_a_cell_data or not active_b_cell_data:
		return
		
	var a_cell = active_a_cell_data[2]
	var b_cell = active_b_cell_data[2]
	cell.value = cell.value + a_cell.value * b_cell.value
	cell.disabled = true
	a_cell.pressed = false
	b_cell.pressed = false
	activation_history.append([active_a_cell_data, active_b_cell_data])
	active_a_cell_data = null
	active_b_cell_data = null
	toggle_result_activity()
	toggle_ab_activity()

	if is_finished():
		emit_signal("multiplied")
