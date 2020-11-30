tool
extends MMGenTexture
class_name MMGenImage

var timer : Timer
var filetime : int = 0

"""
Texture generator from image
"""

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2
	timer.start()
	timer.connect("timeout", self, "_on_timeout")

func get_type() -> String:
	return "image"

func get_type_name() -> String:
	return "Image"

func get_parameter_defs() -> Array:
	return [ { name="image", type="path" } ]

func get_filetime(file_path : String) -> int:
	var f : File = File.new()
	if f.file_exists(file_path):
		return f.get_modified_time(file_path)
	return 0

func set_parameter(n : String, v) -> void:
	.set_parameter(n, v)
	if n == "image":
		filetime = get_filetime(v)
		texture.load(v)

func _on_timeout() -> void:
	var file_path : String = get_parameter("image")
	var new_filetime : int = get_filetime(file_path)
	if filetime != new_filetime:
		filetime = new_filetime
		texture.load(file_path)
		.set_parameter("image", file_path)
