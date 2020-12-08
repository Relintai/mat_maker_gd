tool
extends TextureRect

var image : Image
var tex : ImageTexture

export(Vector2) var bmin : Vector2 = Vector2(0.1, 0.1)
export(Vector2) var bmax : Vector2 = Vector2(1, 1)

export(bool) var refresh setget reff,reffg

#class TGEntry:
#	var pos : float
#	var r : float
#	var g : float
#	var b : float
#	var a : float

var p_o28405_repeat : float = 1.000000000;
var p_o28405_rotate : float = 0.000000000;


var p_o28405_gradient_0_pos  : float= 0.000000000;
var p_o28405_gradient_0_r : float = 0.000000000;
var p_o28405_gradient_0_g : float = 0.000000000;
var p_o28405_gradient_0_b : float = 0.000000000;
var p_o28405_gradient_0_a  : float= 1.000000000;

var p_o28405_gradient_1_pos : float = 1.000000000;
var p_o28405_gradient_1_r : float = 1.000000000;
var p_o28405_gradient_1_g : float = 1.000000000;
var p_o28405_gradient_1_b : float = 1.000000000;
var p_o28405_gradient_1_a : float = 1.000000000;


func gen() -> void:
	if !image:
		image = Image.new()
		image.create(300, 300, false, Image.FORMAT_RGBA8)
		
	if !tex:
		tex = ImageTexture.new()
		
#	var bmin : Vector2 = Vector2(0.1, 0.1)
#	var bmax : Vector2 = Vector2(1, 1)

	image.lock()
	
	var w : float = image.get_width()
	var h : float = image.get_width()
	
	var pseed : float = randf() + randi()
	
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var v : Vector2 = Vector2(x / w, y / h)

			var o28405_0_r : float = 0.5 + (cos(p_o28405_rotate*0.01745329251)*(v.x-0.5)+sin(p_o28405_rotate*0.01745329251)*(v.y-0.5))/(cos(abs(modf(p_o28405_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237)
			var col : Color = o28405_gradient_gradient_fct(fractf(o28405_0_r*p_o28405_repeat))

			image.set_pixel(x, y, col)

	image.unlock()
	
	tex.create_from_image(image)
	texture = tex

func o28405_gradient_gradient_fct(x : float) -> Color:
	if (x < p_o28405_gradient_0_pos):
		return Color(p_o28405_gradient_0_r,p_o28405_gradient_0_g,p_o28405_gradient_0_b,p_o28405_gradient_0_a);
	elif (x < p_o28405_gradient_1_pos):
		return lerp(Color(p_o28405_gradient_0_r,p_o28405_gradient_0_g,p_o28405_gradient_0_b,p_o28405_gradient_0_a), Color(p_o28405_gradient_1_r,p_o28405_gradient_1_g,p_o28405_gradient_1_b,p_o28405_gradient_1_a), ((x-p_o28405_gradient_0_pos)/(p_o28405_gradient_1_pos-p_o28405_gradient_0_pos)));
		
	return Color(p_o28405_gradient_1_r,p_o28405_gradient_1_g,p_o28405_gradient_1_b,p_o28405_gradient_1_a);

#vec4 o5449_gradient_gradient_fct(float x) {
#  if (x < p_o5449_gradient_0_pos) {
#	return vec4(p_o5449_gradient_0_r,p_o5449_gradient_0_g,p_o5449_gradient_0_b,p_o5449_gradient_0_a);
#  } else if (x < p_o5449_gradient_1_pos) {
#	return mix(vec4(p_o5449_gradient_0_r,p_o5449_gradient_0_g,p_o5449_gradient_0_b,p_o5449_gradient_0_a), vec4(p_o5449_gradient_1_r,p_o5449_gradient_1_g,p_o5449_gradient_1_b,p_o5449_gradient_1_a), ((x-p_o5449_gradient_0_pos)/(p_o5449_gradient_1_pos-p_o5449_gradient_0_pos)));
#  } else if (x < p_o5449_gradient_2_pos) {
#	return mix(vec4(p_o5449_gradient_1_r,p_o5449_gradient_1_g,p_o5449_gradient_1_b,p_o5449_gradient_1_a), vec4(p_o5449_gradient_2_r,p_o5449_gradient_2_g,p_o5449_gradient_2_b,p_o5449_gradient_2_a), ((x-p_o5449_gradient_1_pos)/(p_o5449_gradient_2_pos-p_o5449_gradient_1_pos)));
#  } else if (x < p_o5449_gradient_3_pos) {
#	return mix(vec4(p_o5449_gradient_2_r,p_o5449_gradient_2_g,p_o5449_gradient_2_b,p_o5449_gradient_2_a), vec4(p_o5449_gradient_3_r,p_o5449_gradient_3_g,p_o5449_gradient_3_b,p_o5449_gradient_3_a), ((x-p_o5449_gradient_2_pos)/(p_o5449_gradient_3_pos-p_o5449_gradient_2_pos)));
#  }
#  return vec4(p_o5449_gradient_3_r,p_o5449_gradient_3_g,p_o5449_gradient_3_b,p_o5449_gradient_3_a);
#}

func modf(x : float, y : float) -> float:
	return x - y * floor(x / y)

func fract(v : Vector2) -> Vector2:
	v.x = v.x - floor(v.x)
	v.y = v.y - floor(v.y)
	
	return v
	
func fractf(f : float) -> float:
	return f - floor(f)

func rand(x : Vector2) -> float:
	return fractf(cos(x.dot(Vector2(13.9898, 8.141))) * 43758.5453);
	
func step(edge : float, x : float) -> float:
	if x < edge:
		return 0.0
	else:
		return 1.0

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


func reffg():
	return false

func reff(bb):
	if bb:
		gen()

