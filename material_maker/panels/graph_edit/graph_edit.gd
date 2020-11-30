extends GraphEdit
class_name MMGraphEdit

var node_factory = null

var save_path = null setget set_save_path
var need_save = false
var need_save_crash_recovery = false

var top_generator = null
var generator = null

var last_selected = null

onready var node_popup = $"../AddNodePopup"

onready var timer : Timer = $Timer

onready var subgraph_ui : HBoxContainer = $GraphUI/SubGraphUI
onready var button_transmits_seed : Button = $GraphUI/SubGraphUI/ButtonTransmitsSeed

signal save_path_changed
signal graph_changed
signal view_updated

func _ready() -> void:
	OS.low_processor_usage_mode = true
	center_view()
	for t in range(41):
		add_valid_connection_type(t, 42)
		add_valid_connection_type(42, t)

func _gui_input(event) -> void:
	if event.is_action_pressed("ui_library_popup") && get_rect().has_point(get_local_mouse_position()):
		node_popup.rect_global_position = get_global_mouse_position()
		node_popup.show_popup()
	elif event.is_action_pressed("ui_hierarchy_up"):
		on_ButtonUp_pressed()
	elif event.is_action_pressed("ui_hierarchy_down"):
		var selected_nodes = get_selected_nodes()
		if selected_nodes.size() == 1 and selected_nodes[0].generator is MMGenGraph:
			update_view(selected_nodes[0].generator)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.is_pressed() and event.control:
			call_deferred("set_scroll_ofs", scroll_offset)
			zoom *= 1.1
		elif event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed() and event.control:
			call_deferred("set_scroll_ofs", scroll_offset)
			zoom /= 1.1
		else:
			call_deferred("check_last_selected")
	elif event is InputEventKey and event.pressed:
		var scancode_with_modifiers = event.get_scancode_with_modifiers()
		if scancode_with_modifiers == KEY_DELETE or scancode_with_modifiers == KEY_BACKSPACE:
			remove_selection()
	elif event is InputEventMouseMotion:
		for c in get_children():
			if c.has_method("get_slot_tooltip"):
				var rect = c.get_global_rect()
				rect = Rect2(rect.position, rect.size*c.get_global_transform().get_scale())
				if rect.has_point(get_global_mouse_position()):
					hint_tooltip = c.get_slot_tooltip(get_global_mouse_position()-c.rect_global_position)
				else:
					c.clear_connection_labels()
	return

# Misc. useful functions
func get_source(node, port) -> Dictionary:
	for c in get_connection_list():
		if c.to == node and c.to_port == port:
			return { node=c.from, slot=c.from_port }
	return {}

func offset_from_global_position(global_position) -> Vector2:
	return (scroll_offset + global_position - rect_global_position) / zoom

func add_node(node) -> void:
	add_child(node)
	move_child(node, 0)
	node.connect("close_request", self, "remove_node", [ node ])

func connect_node(from, from_slot, to, to_slot):
	var from_node : MMGraphNodeBase = get_node(from)
	var to_node : MMGraphNodeBase = get_node(to)
	var connect_count = 1
	var connected : bool = false
	var out_ports = from_node.generator.get_output_defs()
	var in_ports = to_node.generator.get_input_defs()
	if out_ports[from_slot].has("group_size") and in_ports[to_slot].has("group_size") and out_ports[from_slot].group_size == in_ports[to_slot].group_size:
		connect_count = out_ports[from_slot].group_size
	for i in range(connect_count):
		if generator.connect_children(from_node.generator, from_slot+i, to_node.generator, to_slot+i):
			var disconnect = get_source(to, to_slot+i)
			if !disconnect.empty():
				.disconnect_node(disconnect.node, disconnect.slot, to, to_slot+i)
			.connect_node(from, from_slot+i, to, to_slot+i)
			connected = true
	if connected:
		send_changed_signal()

func disconnect_node(from, from_slot, to, to_slot) -> void:
	if generator.disconnect_children(get_node(from).generator, from_slot, get_node(to).generator, to_slot):
		.disconnect_node(from, from_slot, to, to_slot)
		send_changed_signal()

func on_connections_changed(removed_connections : Array, added_connections : Array) -> void:
	for c in removed_connections:
		.disconnect_node("node_"+c.from, c.from_port, "node_"+c.to, c.to_port)
	for c in added_connections:
		.connect_node("node_"+c.from, c.from_port, "node_"+c.to, c.to_port)

func remove_node(node) -> void:
	if generator.remove_generator(node.generator):
		var node_name = node.name
		for c in get_connection_list():
			if c.from == node_name or c.to == node_name:
				disconnect_node(c.from, c.from_port, c.to, c.to_port)
		if node == last_selected:
			set_last_selected(null)
		remove_child(node)
		node.queue_free()
		send_changed_signal()

# Global operations on graph

func update_tab_title() -> void:
	if !get_parent().has_method("set_tab_title"):
		print("no set_tab_title method")
		return
	var title = "[unnamed]"
	if save_path != null:
		title = save_path.right(save_path.rfind("/")+1)
	if need_save:
		title += " *"
	if get_parent().has_method("set_tab_title"):
		get_parent().set_tab_title(get_index(), title)

func set_need_save(ns = true) -> void:
	if ns != need_save:
		need_save = ns
		update_tab_title()
	if save_path != null:
		if ns:
			need_save_crash_recovery = true
		else:
			need_save_crash_recovery = false

func set_save_path(path) -> void:
	if path != save_path:
		remove_crash_recovery_file()
		need_save_crash_recovery = false
		save_path = path
		update_tab_title()
		emit_signal("save_path_changed", self, path)

func clear_view() -> void:
	clear_connections()
	for c in get_children():
		if c is GraphNode:
			if c == last_selected:
				set_last_selected(null)
			remove_child(c)
			c.free()

func crash_recovery_save() -> void:
	if !need_save_crash_recovery:
		return
	var data = top_generator.serialize()
	var file = File.new()
	if file.open(save_path+".mmcr", File.WRITE) == OK:
		file.store_string(JSON.print(data))
		file.close()
		need_save_crash_recovery = false

func remove_crash_recovery_file() -> void:
	if save_path != null:
		var dir = Directory.new()
		dir.remove(save_path+".mmcr")

# Center view

func center_view() -> void:
	var center = Vector2(0, 0)
	var node_count = 0
	for c in get_children():
		if c is GraphNode:
			center += c.offset + 0.5*c.rect_size
			node_count += 1
	if node_count > 0:
		center /= node_count
		scroll_offset = center - 0.5*rect_size

func update_view(g) -> void:
	if generator != null:
		generator.disconnect("connections_changed", self, "on_connections_changed")
	clear_view()
	generator = g
	if generator != null:
		generator.connect("connections_changed", self, "on_connections_changed")
	update_graph(generator.get_children(), generator.connections)
	subgraph_ui.visible = generator != top_generator
	subgraph_ui.get_node("Label").text = generator.label
	$GraphUI/SubGraphUI/Description.short_description = generator.shortdesc
	$GraphUI/SubGraphUI/Description.long_description = generator.longdesc
	$GraphUI/SubGraphUI/Description.update_tooltip()
	center_view()
	if generator.get_parent() is MMGenGraph:
		button_transmits_seed.visible = true
		button_transmits_seed.pressed = generator.transmits_seed
	else:
		button_transmits_seed.visible = false
	emit_signal("view_updated", generator)


func clear_material() -> void:
	if top_generator != null:
		remove_child(top_generator)
		top_generator.free()
		top_generator = null
		generator = null
	send_changed_signal()

func update_graph(generators, connections) -> Array:
	var rv = []
	for g in generators:
		var node = node_factory.create_node(g.get_template_name() if g.is_template() else "", g.get_type())
		if node != null:
			node.name = "node_"+g.name
			add_node(node)
			node.generator = g
		node.offset = g.position
		rv.push_back(node)
	for c in connections:
		.connect_node("node_"+c.from, c.from_port, "node_"+c.to, c.to_port)
	return rv

func new_material() -> void:
	clear_material()
	top_generator = mm_loader.create_gen({nodes=[{name="Material", type="material","parameters":{"size":11}}], connections=[]})
	if top_generator != null:
		add_child(top_generator)
		move_child(top_generator, 0)
		update_view(top_generator)
		center_view()
		set_save_path(null)
		set_need_save(false)

func get_free_name(type) -> String:
	var i = 0
	while true:
		var node_name = type+"_"+str(i)
		if !has_node(node_name):
			return node_name
		i += 1
	return ""

func create_nodes(data, position : Vector2 = Vector2(0, 0)) -> Array:
	if !data is Dictionary:
		return []
	if data.has("type"):
		data = { nodes=[data], connections=[] }
	if data.has("nodes") and typeof(data.nodes) == TYPE_ARRAY and data.has("connections") and typeof(data.connections) == TYPE_ARRAY:
		var new_stuff = mm_loader.add_to_gen_graph(generator, data.nodes, data.connections)
		var actions : Array = []
		for g in new_stuff.generators:
			g.position += position
			actions.append({ action="add_node", node=g.name })
		for c in new_stuff.connections:
			actions.append({ action="add_connection", connection=c })
		$UndoRedo.add_action("Add nodes and connections", actions)
		return update_graph(new_stuff.generators, new_stuff.connections)
	return []

func create_gen_from_type(gen_name) -> void:
	create_nodes({ type=gen_name, parameters={} }, scroll_offset+0.5*rect_size)

func set_new_generator(new_generator) -> void:
	clear_material()
	top_generator = new_generator
	add_child(top_generator)
	move_child(top_generator, 0)
	update_view(top_generator)
	center_view()
	set_need_save(false)

func find_buffers(g) -> int:
	if g is MMGenBuffer:
		return 1
	var rv = 0
	for c in g.get_children():
		rv += find_buffers(c)
	return rv

func load_file(filename) -> bool:
	var rescued = false
	var new_generator = null
	var file = File.new()
	if filename != null and file.file_exists(filename+".mmcr"):
		var dialog = preload("res://material_maker/windows/accept_dialog/accept_dialog.tscn").instance()
		dialog.dialog_text = "Rescue file for "+filename.get_file()+" was found.\nLoad it?"
		dialog.get_ok().text = "Rescue"
		dialog.add_cancel("Load "+filename.get_file())
		add_child(dialog)
		var result = dialog.ask()
		while result is GDScriptFunctionState:
			result = yield(result, "completed")
		if result == "ok":
			new_generator = mm_loader.load_gen(filename+".mmcr")
	if new_generator != null:
		rescued = true
	else:
		new_generator = mm_loader.load_gen(filename)
	if new_generator != null:
		set_save_path(filename)
		set_new_generator(new_generator)
		if rescued:
			set_need_save(true)
		#print("Material has %d buffers" % find_buffers(new_generator))
		return true
	else:
		var dialog : AcceptDialog = AcceptDialog.new()
		add_child(dialog)
		dialog.window_title = "Load failed!"
		dialog.dialog_text = "Failed to load "+filename
		dialog.connect("popup_hide", dialog, "queue_free")
		dialog.popup_centered()
		return false

func save_file(filename) -> bool:
	var data = top_generator.serialize()
	var file = File.new()
	if file.open(filename, File.WRITE) == OK:
		file.store_string(JSON.print(data, "\t", true))
		file.close()
	else:
		return false
	set_save_path(filename)
	set_need_save(false)
	remove_crash_recovery_file()
	return true

func get_material_node() -> MMGenMaterial:
	for g in top_generator.get_children():
		if g.has_method("get_export_profiles"):
			return g
	return null

func export_material(export_prefix, profile) -> void:
	for g in top_generator.get_children():
		if g.has_method("export_material"):
			g.export_material(export_prefix, profile)

# Cut / copy / paste / duplicate

func get_selected_nodes() -> Array:
	var selected_nodes = []
	for n in get_children():
		if n is GraphNode and n.selected:
			selected_nodes.append(n)
	return selected_nodes

func remove_selection() -> void:
	for c in get_children():
		if c is GraphNode and c.selected and c.name != "Material":
			remove_node(c)

# Maybe move this to gen_graph...
func serialize_selection() -> Dictionary:
	var data = { nodes = [], connections = [] }
	var nodes = []
	for c in get_children():
		if c is GraphNode and c.selected and c.name != "Material":
			nodes.append(c)
	if nodes.empty():
		return {}
	var center = Vector2(0, 0)
	for n in nodes:
		center += n.offset+0.5*n.rect_size
	center /= nodes.size()
	for n in nodes:
		var s = n.generator.serialize()
		var p = n.offset-center
		s.node_position = { x=p.x, y=p.y }
		data.nodes.append(s)
	for c in get_connection_list():
		var from = get_node(c.from)
		var to = get_node(c.to)
		if from != null and from.selected and to != null and to.selected:
			var connection = c.duplicate(true)
			connection.from = from.generator.name
			connection.to = to.generator.name
			data.connections.append(connection)
	return data

func can_copy() -> bool:
	for c in get_children():
		if c is GraphNode and c.selected and c.name != "Material":
			return true
	return false

func cut() -> void:
	copy()
	remove_selection()

func copy() -> void:
	OS.clipboard = to_json(serialize_selection())

func do_paste(data) -> void:
	var position = scroll_offset+0.5*rect_size
	if Rect2(Vector2(0, 0), rect_size).has_point(get_local_mouse_position()):
		position = offset_from_global_position(get_global_transform().xform(get_local_mouse_position()))
	for c in get_children():
		if c is GraphNode:
			c.selected = false
	var new_nodes = create_nodes(data, position)
	if new_nodes != null:
		for c in new_nodes:
			c.selected = true

func paste() -> void:
	var data = OS.clipboard
	if data.left(4) == "http":
		var http_request = HTTPRequest.new()
		add_child(http_request)
		var error = http_request.request(data)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
		data = yield(http_request, "request_completed")[3].get_string_from_utf8()
		http_request.queue_free()
	var graph = parse_json(data)
	if graph != null:
		if graph is Dictionary and graph.has("type") and graph.type == "graph":
			var main_window = get_node("/root/MainWindow")
			var graph_edit = main_window.new_panel()
			var new_generator = mm_loader.create_gen(graph)
			if new_generator:
				graph_edit.set_new_generator(new_generator)
				main_window.hierarchy.update_from_graph_edit(graph_edit)
		else:
			do_paste(graph)
	else:
		print(data)

func duplicate_selected() -> void:
	do_paste(serialize_selection())

func select_all() -> void:
	for c in get_children():
		if c is GraphNode:
			c.selected = true

# Delay after graph update

func send_changed_signal() -> void:
	set_need_save(true)
	timer.stop()
	timer.start(0.2)

func do_send_changed_signal() -> void:
	emit_signal("graph_changed")

# Drag and drop

func can_drop_data(_position, data) -> bool:
	return typeof(data) == TYPE_COLOR or typeof(data) == TYPE_DICTIONARY and (data.has('type') or (data.has('nodes') and data.has('connections')))

func drop_data(position, data) -> void:
	# The following mitigates the SpinBox problem (captures mouse while dragging)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if typeof(data) == TYPE_COLOR:
		do_paste({type="uniform", color={ r=data.r, g=data.g, b=data.b, a=data.a }})
	elif typeof(data) == TYPE_DICTIONARY and data.has("type") and data.type == "Gradient" and data.has("points"):
		do_paste({type="colorize", gradient=data})
	else:
		create_nodes(data, offset_from_global_position(get_global_transform().xform(position)))

func on_ButtonUp_pressed() -> void:
	if generator != top_generator && generator.get_parent() is MMGenGraph:
		call_deferred("update_view", generator.get_parent())

func _on_Label_text_changed(new_text) -> void:
	generator.set_type_name(new_text)

# Create subgraph

func create_subgraph() -> void:
	var generators = []
	for n in get_selected_nodes():
		generators.push_back(n.generator)
	var subgraph = generator.create_subgraph(generators)
	if subgraph != null:
		update_view(subgraph)

func _on_ButtonShowTree_pressed() -> void:
	var graph_tree : Popup = preload("res://material_maker/widgets/graph_tree/graph_tree.tscn").instance()
	add_child(graph_tree)
	graph_tree.init("Top", top_generator)
	graph_tree.connect("item_double_clicked", self, "edit_subgraph")
	graph_tree.connect("popup_hide", graph_tree, "queue_free")
	graph_tree.popup_centered()

func edit_subgraph(g : MMGenGraph) -> void:
	if !g.is_editable():
		g.toggle_editable()
	update_view(g)


func _on_ButtonTransmitsSeed_toggled(button_pressed) -> void:
	if button_pressed != generator.transmits_seed:
		generator.transmits_seed = button_pressed

# Node selection

var highlighting_connections : bool = false

func highlight_connections() -> void:
	if highlighting_connections:
		return
	highlighting_connections = true
	while Input.is_mouse_button_pressed(BUTTON_LEFT):
		yield(get_tree(), "idle_frame")
	for c in get_connection_list():
		set_connection_activity(c.from, c.from_port, c.to, c.to_port, 1.0 if get_node(c.from).selected or get_node(c.to).selected else 0.0)
	highlighting_connections = false

func _on_GraphEdit_node_selected(node) -> void:
	set_last_selected(node)
	highlight_connections()

func _on_GraphEdit_node_unselected(node):
	highlight_connections()


func set_last_selected(node) -> void:
	if node is GraphNode:
		last_selected = node
	else:
		last_selected = null

func request_popup(node_name : String , slot_index : int, _release_position : Vector2, connect_output : bool) -> void:
	# Check if the connector was actually dragged
	var node : GraphNode = get_node(node_name)
	var node_transform : Transform2D = node.get_global_transform()
	var output_position = node_transform.xform(node.get_connection_output_position(slot_index)/node_transform.get_scale())
	# ignore if drag distance is too short
	if (get_global_mouse_position()-output_position).length() < 20:
		# Tell the node its connector was clicked
		if node.has_method("on_clicked_output"):
			node.on_clicked_output(slot_index)
		return
	# Request the popup
	node_popup.rect_global_position = get_global_mouse_position()
	var slot_type
	if connect_output:
		slot_type = mm_io_types.types[node.generator.get_input_defs()[slot_index].type].slot_type
	else:
		slot_type = mm_io_types.types[node.generator.get_output_defs()[slot_index].type].slot_type
	node_popup.show_popup(node_name, slot_index, slot_type, connect_output)

func check_last_selected() -> void:
	if last_selected != null and !(is_instance_valid(last_selected) and last_selected.selected):
		last_selected = null
		emit_signal("node_selected", null)

func on_drop_image_file(file_name : String) -> void:
	do_paste({type="image", image=file_name})


func _on_Description_descriptions_changed(short_description, long_description):
	generator.shortdesc = short_description
	generator.longdesc = long_description

