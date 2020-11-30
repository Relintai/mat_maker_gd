extends WindowDialog

onready var parameter_list : VBoxContainer = $Sizer/Tabs/General/Parameters/Sizer
onready var input_list : VBoxContainer = $Sizer/Tabs/General/Inputs/Sizer
onready var output_list : VBoxContainer = $Sizer/Tabs/Outputs/Outputs/Sizer

onready var main_code_editor : TextEdit = $"Sizer/Tabs/Main Code"
onready var instance_functions_editor : TextEdit = $"Sizer/Tabs/Instance Functions"
onready var includes_editor : LineEdit = $"Sizer/Tabs/Global Functions/Includes/Includes"
onready var global_functions_editor : TextEdit = $"Sizer/Tabs/Global Functions/Functions"

const ParameterEditor = preload("res://material_maker/windows/node_editor/parameter.tscn")
const InputEditor = preload("res://material_maker/windows/node_editor/input.tscn")
const OutputEditor = preload("res://material_maker/windows/node_editor/output.tscn")

signal node_changed

func _ready() -> void:
	main_code_editor.add_color_region("//", "", Color(0, 0.5, 0), true)
	instance_functions_editor.add_color_region("//", "", Color(0, 0.5, 0), true)
	global_functions_editor.add_color_region("//", "", Color(0, 0.5, 0), true)

func add_item(parent, scene) -> Node:
	var object = scene.instance()
	parent.add_child(object)
	parent.move_child(object, parent.get_child_count()-2)
	return object

func set_model_data(data) -> void:
	if data.has("name"):
		$Sizer/Tabs/General/Name/Name.text = data.name
	if data.has("shortdesc"):
		$Sizer/Tabs/General/Name/Description.short_description = data.shortdesc
	if data.has("longdesc"):
		$Sizer/Tabs/General/Name/Description.long_description = data.longdesc
	$Sizer/Tabs/General/Name/Description.update_tooltip()
	if data.has("parameters"):
		for p in data.parameters:
			add_item(parameter_list, ParameterEditor).set_model_data(p)
		parameter_list.update_up_down_buttons()
	if data.has("inputs"):
		var group_size = 0
		for i in range(data.inputs.size()):
			var input = data.inputs[i]
			if group_size > 1 && i == data.inputs.size()-1:
				group_size = 1
			group_size = add_item(input_list, InputEditor).set_model_data(input, group_size)
		input_list.update_up_down_buttons()
		PortGroupButton.update_groups(input_list)
	if data.has("outputs"):
		var group_size = 0
		for o in range(data.outputs.size()):
			var output = data.outputs[o]
			if group_size > 1 && o == data.outputs.size()-1:
				group_size = 1
			group_size = add_item(output_list, OutputEditor).set_model_data(output, group_size)
		output_list.update_up_down_buttons()
		PortGroupButton.update_groups(output_list)
	if data.has("includes"):
		includes_editor.text = PoolStringArray(data.includes).join(",")
	if data.has("global"):
		global_functions_editor.text = data.global
	if data.has("instance"):
		instance_functions_editor.text = data.instance
	if data.has("code"):
		main_code_editor.text = data.code

func get_model_data() -> Dictionary:
	var data = {
		name=$Sizer/Tabs/General/Name/Name.text,
		global=global_functions_editor.text,
		instance=instance_functions_editor.text,
		code=main_code_editor.text
	}
	if $Sizer/Tabs/General/Name/Description.short_description != "":
		data.shortdesc = $Sizer/Tabs/General/Name/Description.short_description
	if $Sizer/Tabs/General/Name/Description.long_description != "":
		data.longdesc = $Sizer/Tabs/General/Name/Description.long_description
	var includes : String = includes_editor.text.replace(" ", "")
	if includes != "":
		data.includes = includes.split(",")
	data.parameters = []
	for p in parameter_list.get_children():
		if p.has_method("get_model_data"):
			data.parameters.append(p.get_model_data())
	data.inputs = []
	for i in input_list.get_children():
		if i.has_method("get_model_data"):
			data.inputs.append(i.get_model_data())
	data.outputs = []
	for o in output_list.get_children():
		if o.has_method("get_model_data"):
			data.outputs.append(o.get_model_data())
	return data

func _on_AddParameter_pressed() -> void:
	add_item(parameter_list, ParameterEditor)
	parameter_list.update_up_down_buttons()

func _on_AddInput_pressed() -> void:
	add_item(input_list, InputEditor)
	input_list.update_up_down_buttons()

func _on_AddOutput_pressed() -> void:
	add_item(output_list, OutputEditor)
	output_list.update_up_down_buttons()

func _on_Apply_pressed() -> void:
	emit_signal("node_changed", get_model_data())

func _on_OK_pressed() -> void:
	emit_signal("node_changed", get_model_data())
	queue_free()

func _on_Cancel_pressed() -> void:
	queue_free()
