extends HSplitContainer

const PANEL_POSITIONS = {
	TopLeft="Left/Top",
	BottomLeft="Left/Bottom",
	TopRight="SplitRight/Right/Top",
	BottomRight="SplitRight/Right/Bottom"
}
const PANELS = [
	{ name="Library", scene=preload("res://material_maker/panels/library/library.tscn"), position="TopLeft" },
	{ name="Preview2D", scene=preload("res://material_maker/panels/preview_2d/preview_2d_panel.tscn"), position="BottomLeft" },
	{ name="Preview3D", scene=preload("res://material_maker/panels/preview_3d/preview_3d_panel.tscn"), position="BottomLeft" },
	{ name="Histogram", scene=preload("res://material_maker/widgets/histogram/histogram.tscn"), position="BottomLeft" },
	{ name="Hierarchy", scene=preload("res://material_maker/panels/hierarchy/hierarchy_panel.tscn"), position="TopRight" },
	{ name="Reference", scene=preload("res://material_maker/panels/reference/reference_panel.tscn"), position="BottomLeft" }
]

var panels = {}
var previous_width : float

func _ready() -> void:
	previous_width = rect_size.x

func load_panels(config_cache) -> void:
	# Create panels
	for panel_pos in PANEL_POSITIONS.keys():
		get_node(PANEL_POSITIONS[panel_pos]).set_tabs_rearrange_group(1)
	for panel in PANELS:
		var node = panel.scene.instance()
		node.name = panel.name
		if "config_cache" in node:
			node.config_cache = config_cache
		panels[panel.name] = node
		var tab = get_node(PANEL_POSITIONS[panel.position])
		if config_cache.has_section_key("layout", panel.name+"_location"):
			tab = get_node(PANEL_POSITIONS[config_cache.get_value("layout", panel.name+"_location")])
		if config_cache.has_section_key("layout", panel.name+"_hidden") && config_cache.get_value("layout", panel.name+"_hidden"):
			node.set_meta("parent_tab_container", tab)
		else:
			tab.add_child(node)
	# Split positions
	if config_cache.has_section_key("layout", "LeftVSplitOffset"):
		split_offset = config_cache.get_value("layout", "LeftVSplitOffset")
	if config_cache.has_section_key("layout", "LeftHSplitOffset"):
		$Left.split_offset = config_cache.get_value("layout", "LeftHSplitOffset")
	if config_cache.has_section_key("layout", "RightVSplitOffset"):
		$SplitRight.split_offset = config_cache.get_value("layout", "RightVSplitOffset")
	if config_cache.has_section_key("layout", "RightHSplitOffset"):
		$SplitRight/Right.split_offset = config_cache.get_value("layout", "RightHSplitOffset")
	update_panels()

func save_config(config_cache) -> void:
	for p in panels:
		var location = panels[p].get_parent()
		var hidden = false
		if location == null:
			hidden = true
			location = panels[p].get_meta("parent_tab_container")
		config_cache.set_value("layout", p+"_hidden", hidden)
		for l in PANEL_POSITIONS.keys():
			if location == get_node(PANEL_POSITIONS[l]):
				config_cache.set_value("layout", p+"_location", l)
	config_cache.set_value("layout", "LeftVSplitOffset", split_offset)
	config_cache.set_value("layout", "LeftHSplitOffset", $Left.split_offset)
	config_cache.set_value("layout", "RightVSplitOffset", $SplitRight.split_offset)
	config_cache.set_value("layout", "RightHSplitOffset", $SplitRight/Right.split_offset)

func get_panel(n) -> Control:
	return panels[n]

func get_panel_list() -> Array:
	var panels_list = panels.keys()
	panels_list.sort()
	return panels_list

func is_panel_visible(panel_name : String) -> bool:
	return panels[panel_name].get_parent() != null

func set_panel_visible(panel_name : String, v : bool) -> void:
	var panel = panels[panel_name]
	if v:
		panel.get_meta("parent_tab_container").add_child(panel)
	else:
		panel.set_meta("parent_tab_container", panel.get_parent())
		panel.get_parent().remove_child(panel)
	update_panels()

func update_panels() -> void:
	var left_width = $Left.rect_size.x
	var left_requested = left_width
	var right_width = $SplitRight/Right.rect_size.x
	var right_requested = right_width
	if $Left/Top.get_tab_count() == 0:
		if $Left/Bottom.get_tab_count() == 0:
			left_requested = 10
			$Left.split_offset -= ($Left/Top.rect_size.y-$Left/Bottom.rect_size.y)/2
			$Left.clamp_split_offset()
		else:
			$Left.split_offset -= $Left/Top.rect_size.y-10
			$Left.clamp_split_offset()
	elif $Left/Bottom.get_tab_count() == 0:
		$Left.split_offset += $Left/Bottom.rect_size.y-10
		$Left.clamp_split_offset()
	if $SplitRight/Right/Top.get_tab_count() == 0:
		if $SplitRight/Right/Bottom.get_tab_count() == 0:
			right_requested = 10
			$SplitRight/Right.split_offset -= ($SplitRight/Right/Top.rect_size.y-$SplitRight/Right/Bottom.rect_size.y)/2
			$SplitRight/Right.clamp_split_offset()
		else:
			$SplitRight/Right.split_offset -= $SplitRight/Right/Top.rect_size.y-10
			$SplitRight/Right.clamp_split_offset()
	elif $SplitRight/Right/Bottom.get_tab_count() == 0:
		$SplitRight/Right.split_offset += $SplitRight/Right/Bottom.rect_size.y-10
		$SplitRight/Right.clamp_split_offset()
	split_offset += left_requested - left_width + right_requested - right_width
	clamp_split_offset()
	$SplitRight.split_offset += right_width - right_requested

func _on_Left_dragged(_offset : int) -> void:
	$Left.clamp_split_offset()

func _on_Right_dragged(_offset : int) -> void:
	$SplitRight/Right.clamp_split_offset()

func _on_tab_changed(_tab):
	update_panels()

func _on_Layout_resized():
# warning-ignore:narrowing_conversion
	split_offset -= rect_size.x - previous_width
	previous_width = rect_size.x
