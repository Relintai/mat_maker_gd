tool
extends TextureRect

var image : Image
var tex : ImageTexture

export(bool) var refresh setget reff,reffg

func _ready():
	pass

func gen() -> void:
	if !image:
		image = Image.new()
		image.create(300, 300, false, Image.FORMAT_RGBA8)
		
	if !tex:
		tex = ImageTexture.new()
		
	var bmin : Vector2 = Vector2(0.3, 0.3)
	var bmax : Vector2 = Vector2(1, 1)

	image.lock()
	
	var w : float = image.get_width()
	var h : float = image.get_width()
	
	var pseed : float = randf() + randi()
	
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var v : Vector2 = Vector2(x / w, y / h)

			var vb : Vector3 = brick_uv(v, bmin, bmax, pseed)
#			var col : Color = Color(vb.x, vb.y, vb.z, 1)
			
			var col : Color = brick(v, bmin, bmax, 0.2, 0.2, 0.2)
			
			image.set_pixel(x, y, col)
			
#vec4 $(name_uv)_rect = bricks_$pattern($uv, vec2($columns, $rows), $repeat, $row_offset);
#vec4 $(name_uv) = brick($uv, $(name_uv)_rect.xy, $(name_uv)_rect.zw, $mortar*$mortar_map($uv), $round*$round_map($uv), max(0.001, $bevel*$bevel_map($uv)));
	
	image.unlock()
	
	tex.create_from_image(image)
	texture = tex

#func b2(UV : Vector2):
#	var ms : float = max(size.x, size.y)
#	var uv : Vector2 = 0.5+(UV-vec2(0.5))*ms/size.yx
#	#var is : float = min(size.x, size.y)
#	vec4 image = preview_2d(uv)
#	var image_with_background : Vector3 = mix(vec3(mod(floor(uv.x*32.0)+floor(uv.y*32.0), 2.0)), image.xyz, image.a)
#	uv -= vec2(0.5)
#	uv = abs(uv)
#	return Color(image_with_background, step(max(uv.x, uv.y), 0.5)*0.8+0.2)

func brick(uv : Vector2, bmin : Vector2, bmax : Vector2, mortar : float, pround : float, bevel : float) -> Color:
	var color : float
	var size : Vector2 = bmax - bmin

	var min_size : float = min(size.x, size.y)
	mortar *= min_size
	bevel *= min_size
	pround *= min_size

	var center : Vector2 = 0.5 * (bmin + bmax)
	var d : Vector2 = Vector2()
	
	d.x = abs(uv.x - center.x) - 0.5 * (size.x) + (pround + mortar)
	d.y = abs(uv.y - center.y) - 0.5 * (size.y) + (pround + mortar)
	
	color = Vector2(max(d.x, 0), max(d.y, 0)).length() + min(max(d.x, d.y), 0.0) - pround
	
	color = clamp(-color / bevel, 0.0, 1.0)

#	var tiled_brick_pos : Vector2 = Vector2(bmin.x - 1.0 * floor(bmin.x / 1.0), bmin.y - 1.0 * floor(bmin.y / 1.0))

	var tiled_brick_pos_x : float = bmin.x - 1.0 * floor(bmin.x / 1.0)
	var tiled_brick_pos_y : float = bmin.y - 1.0 * floor(bmin.y / 1.0)
	
	#vec2 tiled_brick_pos = mod(bmin, vec2(1.0, 1.0));
	
	return Color(color, center.x, center.y, tiled_brick_pos_x + 7.0 * tiled_brick_pos_y)

func brick_uv(uv : Vector2, bmin : Vector2, bmax : Vector2, pseed : float) -> Vector3:
	var center : Vector2 = 0.5 * (bmin + bmax)
	var size : Vector2 = bmax - bmin
	var max_size : float = max(size.x, size.y)
	
	var x : float = 0.5+ (uv.x - center.x) / max_size
	var y : float = 0.5+ (uv.y - center.y) /max_size
	
	return Vector3(x, y, rand(fract(center) + Vector2(pseed, pseed)))

func fract(v : Vector2) -> Vector2:
	v.x = v.x - floor(v.x)
	v.y = v.y - floor(v.y)
	
	return v
	
func fractf(f : float) -> float:
	return f - floor(f)

func rand(x : Vector2) -> float:
	return fractf(cos(x.dot(Vector2(13.9898, 8.141))) * 43758.5453);

#common -----

#float rand(vec2 x) {
#    return fract(cos(dot(x, vec2(13.9898, 8.141))) * 43758.5453);
#}
#
#vec2 rand2(vec2 x) {
#    return fract(cos(vec2(dot(x, vec2(13.9898, 8.141)),
#						  dot(x, vec2(3.4562, 17.398)))) * 43758.5453);
#}
#
#vec3 rand3(vec2 x) {
#    return fract(cos(vec3(dot(x, vec2(13.9898, 8.141)),
#                          dot(x, vec2(3.4562, 17.398)),
#                          dot(x, vec2(13.254, 5.867)))) * 43758.5453);
#}
#
#vec3 rgb2hsv(vec3 c) {
#	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
#	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
#	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
#
#	float d = q.x - min(q.w, q.y);
#	float e = 1.0e-10;
#	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
#}
#
#vec3 hsv2rgb(vec3 c) {
#	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
#	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
#	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
#}


#end common

#
#vec4 $(name_uv)_rect = bricks_$pattern($uv, vec2($columns, $rows), $repeat, $row_offset);
#vec4 $(name_uv) = brick($uv, $(name_uv)_rect.xy, $(name_uv)_rect.zw, $mortar*$mortar_map($uv), $round*$round_map($uv), max(0.001, $bevel*$bevel_map($uv)));
#
#vec4 brick(vec2 uv, vec2 bmin, vec2 bmax, float mortar, float round, float bevel) {
#	float color;
#	vec2 size = bmax - bmin;
#	float min_size = min(size.x, size.y);
#	mortar *= min_size;
#	bevel *= min_size;
#	round *= min_size;
#	vec2 center = 0.5*(bmin+bmax);
#
#	vec2 d = abs(uv-center)-0.5*(size)+vec2(round+mortar);
#	color = length(max(d,vec2(0))) + min(max(d.x,d.y),0.0)-round;
#	color = clamp(-color/bevel, 0.0, 1.0);
#	vec2 tiled_brick_pos = mod(bmin, vec2(1.0, 1.0));
#
#	return vec4(color, center, tiled_brick_pos.x+7.0*tiled_brick_pos.y);
#}
#
#vec3 brick_uv(vec2 uv, vec2 bmin, vec2 bmax, float seed) {
#	vec2 center = 0.5*(bmin + bmax);
#	vec2 size = bmax - bmin;
#	float max_size = max(size.x, size.y);
#
#	return vec3(0.5+(uv-center)/max_size, rand(fract(center)+vec2(seed)));
#}
#
#vec3 brick_corner_uv(vec2 uv, vec2 bmin, vec2 bmax, float mortar, float corner, float seed) {
#	vec2 center = 0.5*(bmin + bmax);
#	vec2 size = bmax - bmin;
#	float max_size = max(size.x, size.y);
#	float min_size = min(size.x, size.y);
#	mortar *= min_size;\n\tcorner *= min_size;
#
#	return vec3(clamp((0.5*size-vec2(mortar)-abs(uv-center))/corner, vec2(0.0), vec2(1.0)), rand(fract(center)+vec2(seed)));
#}
#
#vec4 bricks_rb(vec2 uv, vec2 count, float repeat, float offset) {
#	count *= repeat;
#	float x_offset = offset*step(0.5, fract(uv.y*count.y*0.5));
#	vec2 bmin = floor(vec2(uv.x*count.x-x_offset, uv.y*count.y));
#	bmin.x += x_offset;\n\tbmin /= count;
#
#	return vec4(bmin, bmin+vec2(1.0)/count);
#}
#
#vec4 bricks_rb2(vec2 uv, vec2 count, float repeat, float offset) {
#	count *= repeat;
#
#	float x_offset = offset*step(0.5, fract(uv.y*count.y*0.5));
#	count.x = count.x*(1.0+step(0.5, fract(uv.y*count.y*0.5)));
#	vec2 bmin = floor(vec2(uv.x*count.x-x_offset, uv.y*count.y));
#
#	bmin.x += x_offset;
#	bmin /= count;
#	return vec4(bmin, bmin+vec2(1.0)/count);
#}
#
#vec4 bricks_hb(vec2 uv, vec2 count, float repeat, float offset) {
#	float pc = count.x+count.y;
#	float c = pc*repeat;
#	vec2 corner = floor(uv*c);
#	float cdiff = mod(corner.x-corner.y, pc);
#
#	if (cdiff < count.x) {
#		return vec4((corner-vec2(cdiff, 0.0))/c, (corner-vec2(cdiff, 0.0)+vec2(count.x, 1.0))/c);
#	} else {
#		return vec4((corner-vec2(0.0, pc-cdiff-1.0))/c, (corner-vec2(0.0, pc-cdiff-1.0)+vec2(1.0, count.y))/c);
#	}
#}
#
#vec4 bricks_bw(vec2 uv, vec2 count, float repeat, float offset) {
#	vec2 c = 2.0*count*repeat;
#	float mc = max(c.x, c.y);
#	vec2 corner1 = floor(uv*c);
#	vec2 corner2 = count*floor(repeat*2.0*uv);
#	float cdiff = mod(dot(floor(repeat*2.0*uv), vec2(1.0)), 2.0);
#	vec2 corner;
#	vec2 size;
#
#	if (cdiff == 0.0) {
#		corner = vec2(corner1.x, corner2.y);
#		size = vec2(1.0, count.y);
#	} else {
#		corner = vec2(corner2.x, corner1.y);
#		size = vec2(count.x, 1.0);
#	}
#
#	return vec4(corner/c, (corner+size)/c);
#}
#
#vec4 bricks_sb(vec2 uv, vec2 count, float repeat, float offset) {
#	vec2 c = (count+vec2(1.0))*repeat;
#	float mc = max(c.x, c.y);
#	vec2 corner1 = floor(uv*c);
#	vec2 corner2 = (count+vec2(1.0))*floor(repeat*uv);
#	vec2 rcorner = corner1 - corner2;
#
#	vec2 corner;
#	vec2 size;
#
#	if (rcorner.x == 0.0 && rcorner.y < count.y) {
#		corner = corner2;
#		size = vec2(1.0, count.y);
#	} else if (rcorner.y == 0.0) {
#		corner = corner2+vec2(1.0, 0.0);
#		size = vec2(count.x, 1.0);
#	} else if (rcorner.x == count.x) {
#		corner = corner2+vec2(count.x, 1.0);
#		size = vec2(1.0, count.y);
#	} else if (rcorner.y == count.y) {
#		corner = corner2+vec2(0.0, count.y);
#		size = vec2(count.x, 1.0);
#	} else {
#		corner = corner2+vec2(1.0);
#		size = vec2(count.x-1.0, count.y-1.0);
#	}
#
#	return vec4(corner/c, (corner+size)/c);
#}


func reffg():
	return false

func reff(bb):
	if bb:
		gen()

