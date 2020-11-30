extends Node

func create_node(model : String, type : String) -> Node:
	var node_type = null
	var node = null
	var file_name = "res://material_maker/nodes/"+model+"/"+model+".tscn"
	if ! ResourceLoader.exists(file_name):
		file_name = "res://material_maker/nodes/"+type+"/"+type+".tscn"
	if ResourceLoader.exists(file_name):
		node_type = load(file_name)
	if node_type != null:
		node = node_type.instance()
	if node == null:
		node = preload("res://material_maker/nodes/generic/generic.tscn").instance()
	return node
