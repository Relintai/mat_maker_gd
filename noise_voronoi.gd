tool
extends TextureRect

var image : Image
var tex : ImageTexture

export(Vector2) var bmin : Vector2 = Vector2(0.1, 0.1)
export(Vector2) var bmax : Vector2 = Vector2(1, 1)

export(bool) var refresh setget reff,reffg

func _ready():
	if !Engine.editor_hint:
		gen()


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

#			var f : float = pattern(v, 4, 4, CombinerType.MULTIPLY, CombinerAxisType.SINE, CombinerAxisType.SINE)

#			var col : Color = voron_1(v)
#			var col : Color = voron_2(v)
			var col : Color = voron_3(v)

			image.set_pixel(x, y, col)

			
	image.unlock()
	
	tex.create_from_image(image)
	texture = tex


func voron_1(uv : Vector2) -> Color:
	var c : Color = voronoi(((uv)), Vector2(p_o8689_scale_x, p_o8689_scale_y), Vector2(p_o8689_stretch_y, p_o8689_stretch_x), p_o8689_intensity, p_o8689_randomness, seed_o8689);
	
	return Color(c.b, c.b, c.b, 1)

func voron_2(uv : Vector2) -> Color:
	var c : Color = voronoi(((uv)), Vector2(p_o8689_scale_x, p_o8689_scale_y), Vector2(p_o8689_stretch_y, p_o8689_stretch_x), p_o8689_intensity, p_o8689_randomness, seed_o8689);
	
	return Color(c.a, c.a, c.a, 1)

func voron_3(uv : Vector2) -> Color:
	var c : Color = voronoi(((uv)), Vector2(p_o8689_scale_x, p_o8689_scale_y), Vector2(p_o8689_stretch_y, p_o8689_stretch_x), p_o8689_intensity, p_o8689_randomness, seed_o8689);
	
	var vv : Vector2 = Vector2(c.r, c.g)
	
	var v : Vector3 = rand3(fractv2(vv));
	
	return Color(v.x, v.y, v.z, 1)


var seed_o8689 = 11667;
var p_o8689_scale_x = 4.000000000;
var p_o8689_scale_y = 4.000000000;
var p_o8689_stretch_x = 1.000000000;
var p_o8689_stretch_y = 1.000000000;
var p_o8689_intensity = 1.000000000;
var p_o8689_randomness = 0.750000000;


func voronoi(uv : Vector2, size : Vector2, stretch : Vector2, intensity : float, randomness : float, pseed : int) -> Color:
	var seed2 : Vector2 = rand2(Vector2(float(pseed), 1.0-float(pseed)));
	uv *= size;
	var best_distance0 : float = 1.0;
	var best_distance1 : float = 1.0;
	var point0 : Vector2;
	var point1 : Vector2;
	var p0 : Vector2 = floorv2(uv);
	
	for dx in range(-1, 2):# (int dx = -1; dx < 2; ++dx) {
		for dy in range(-1, 2):# (int dy = -1; dy < 2; ++dy) {
			var d : Vector2 = Vector2(float(dx), float(dy));
			var p : Vector2 = p0+d;
			
			p += randomness * rand2(seed2 + modv2(p, size));
			var distance : float = (stretch * (uv - p) / size).length();
			
			if (best_distance0 > distance):
				best_distance1 = best_distance0;
				best_distance0 = distance;
				point1 = point0;
				point0 = p;
			elif (best_distance1 > distance):
				best_distance1 = distance;
				point1 = p;

	var edge_distance : float = (uv - 0.5*(point0+point1)).dot((point0-point1).normalized());
	
	return Color(point0.x, point0.y, best_distance0 * (size).length() * intensity, edge_distance);

func transform(uv : Vector2, translate : Vector2, rotate : float, scale : Vector2, repeat : bool) -> Vector2:
	var rv : Vector2 = Vector2();
	uv -= translate;
	uv -= Vector2(0.5, 0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += Vector2(0.5, 0.5);
	
	if (repeat):
		return fractv2(rv);
	else:
		return clampv2(rv, Vector2(0, 0), Vector2(1, 1));
		

func clampv3(v : Vector3, mi : Vector3, ma : Vector3) -> Vector3:
	v.x = clamp(v.x, mi.x, ma.x)
	v.y = clamp(v.y, mi.y, ma.y)
	v.y = clamp(v.z, mi.z, ma.z)
	
	return v

func floorc(a : Color) -> Color:
	var v : Color = Color()
	
	v.r = floor(a.r)
	v.g = floor(a.g)
	v.b = floor(a.b)
	v.a = floor(a.a)
	
	return v


func floorv2(a : Vector2) -> Vector2:
	var v : Vector2 = Vector2()
	
	v.x = floor(a.x)
	v.y = floor(a.y)
	
	return v
	
func smoothstepv2(a : float, b : float, c : Vector2) -> Vector2:
	var v : Vector2 = Vector2()
	
	v.x = smoothstep(a, b, c.x)
	v.y = smoothstep(a, b, c.y)
	
	return v

func maxv2(a : Vector2, b : Vector2) -> Vector2:
	var v : Vector2 = Vector2()
	
	v.x = max(a.x, b.x)
	v.y = max(a.y, b.y)
	
	return v

func maxv3(a : Vector3, b : Vector3) -> Vector3:
	var v : Vector3 = Vector3()
	
	v.x = max(a.x, b.x)
	v.y = max(a.y, b.y)
	v.z = max(a.z, b.z)
	
	return v

func absv2(v : Vector2) -> Vector2:
	v.x = abs(v.x)
	v.y = abs(v.y)
	
	return v
	
func absv3(v : Vector3) -> Vector3:
	v.x = abs(v.x)
	v.y = abs(v.y)
	v.y = abs(v.y)
	
	return v

func cosv2(v : Vector2) -> Vector2:
	v.x = cos(v.x)
	v.y = cos(v.y)
	
	return v

func cosv3(v : Vector3) -> Vector3:
	v.x = cos(v.x)
	v.y = cos(v.y)
	v.y = cos(v.y)
	
	return v

func modv3(a : Vector3, b : Vector3) -> Vector3:
	var v : Vector3 = Vector3()
	
	v.x = modf(a.x, b.x)
	v.y = modf(a.y, b.y)
	v.z = modf(a.z, b.z)
	
	return v
	
	
func modv2(a : Vector2, b : Vector2) -> Vector2:
	var v : Vector2 = Vector2()
	
	v.x = modf(a.x, b.x)
	v.y = modf(a.y, b.y)

	return v

func modf(x : float, y : float) -> float:
	return x - y * floor(x / y)

func fractv2(v : Vector2) -> Vector2:
	v.x = v.x - floor(v.x)
	v.y = v.y - floor(v.y)
	
	return v
	
func fractv3(v : Vector3) -> Vector3:
	v.x = v.x - floor(v.x)
	v.y = v.y - floor(v.y)
	v.z = v.z - floor(v.z)
	
	return v
	
func fract(f : float) -> float:
	return f - floor(f)

func clampv2(v : Vector2, pmin : Vector2, pmax : Vector2) -> Vector2:
	v.x = clamp(v.x, pmin.x, pmax.x)
	v.y = clamp(v.y, pmin.y, pmax.y)
	
	return v

func rand(x : Vector2) -> float:
	return fract(cos(x.dot(Vector2(13.9898, 8.141))) * 43758.5453);

func rand2(x : Vector2) -> Vector2:
	return fractv2(cosv2(Vector2(x.dot(Vector2(13.9898, 8.141)),
						  x.dot(Vector2(3.4562, 17.398)))) * 43758.5453);

func rand3(x : Vector2) -> Vector3:
	return fractv3(cosv3(Vector3(x.dot(Vector2(13.9898, 8.141)),
						  x.dot(Vector2(3.4562, 17.398)),
						  x.dot(Vector2(13.254, 5.867)))) * 43758.5453);

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

