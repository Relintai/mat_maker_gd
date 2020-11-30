extends MMGraphNodeBase

func set_generator(g) -> void:
	.set_generator(g)
	generator.connect("parameter_changed", self, "on_parameter_changed")
	update_node()

func on_parameter_changed(p, _v) -> void:
	if p == "__update_all__":
		call_deferred("update_node")

func update_up_down_buttons() -> void:
	for c in get_children():
		if ! (c is Button):
			c.update_up_down_button()

func update_node() -> void:
	for c in get_children():
		remove_child(c)
		c.free()
	rect_size = Vector2(0, 0)
	title = generator.get_type_name()
	var color = Color(0.0, 0.5, 0.0, 0.5)
	var io_defs = generator.get_io_defs()
	var group_size = 0
	for i in io_defs.size():
		var p = io_defs[i]
		color = mm_io_types.types[p.type].color
		var slot_type = mm_io_types.types[p.type].slot_type
		set_slot(get_child_count(), generator.name != "gen_inputs", slot_type, color, generator.name != "gen_outputs", slot_type, color)
		var port : Control = preload("res://material_maker/nodes/ios/port.tscn").instance()
		add_child(port)
		if group_size > 1 && i == io_defs.size()-1:
			group_size = 1
		group_size = port.set_model_data(p, group_size)
	PortGroupButton.update_groups(self)
	var add_button : Button = preload("res://material_maker/nodes/ios/add.tscn").instance()
	add_child(add_button)
	add_button.connect("pressed", generator, "add_port")
	set_slot(get_child_count()-1, false, 0, color, false, 0, color)
	update_up_down_buttons()
