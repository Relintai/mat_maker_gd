extends Reference

static func box(uv : Vector2, center : Vector3, rad : Vector3, rot : Vector3) -> float:
	var ro : Vector3 = Vector3(uv.x, uv.y, 1.0) - center
	var rd : Vector3 = Vector3(0.0000001, 0.0000001, -1.0)
	
	var r : Basis = Basis(Vector3(1, 0, 0), Vector3(0, cos(rot.x), -sin(rot.x)), Vector3(0, sin(rot.x), cos(rot.x)))
	r *= Basis(Vector3(cos(rot.y), 0, -sin(rot.y)), Vector3(0, 1, 0), Vector3(sin(rot.y), 0, cos(rot.y)))
	r *= Basis(Vector3(cos(rot.z), -sin(rot.z), 0), Vector3(sin(rot.z), cos(rot.z), 0), Vector3(0, 0, 1))
	
	ro = r * ro
	rd = r * rd
	
	var m : Vector3 = Vector3(1.0 / rd.x, 1.0 / rd.y, 1.0 / rd.z)
	
	var n : Vector3 = m * ro
	var k : Vector3 = Vector3(abs(m.x) * rad.x, abs(m.y) * rad.y, abs(m.z) * rad.z)
	var t1 : Vector3 = -n - k
	var t2 : Vector3 = -n + k

	var tN : float = max(max(t1.x, t1.y), t1.z)
	var tF : float = min(min(t2.x, t2.y), t2.z)

	if (tN>tF || tF<0.0):
		return 1.0

	return tN
	
	
#Color $(name_uv)_rect = bricks_$pattern($uv, Vector2($columns, $rows), $repeat, $row_offset)
#Color $(name_uv) = brick($uv, $(name_uv)_rect.xy, $(name_uv)_rect.zw, $mortar*$mortar_map($uv), $pround*$pround_map($uv), max(0.001, $bevel*$bevel_map($uv)))



static func brick(uv : Vector2, bmin : Vector2, bmax : Vector2, mortar : float, pround : float, bevel : float) -> Color:
	var color : float
	var size : Vector2 = bmax - bmin
	var min_size : float = min(size.x, size.y)
	mortar *= min_size
	bevel *= min_size
	pround * min_size
	var center : Vector2 = 0.5*(bmin+bmax)
	var d : Vector2 = Vector2()
	
	d.x = abs(uv.x - center.x) - 0.5 * (size.x) + (pround + mortar)
	d.y = abs(uv.y - center.y) - 0.5 * (size.y) + (pround + mortar)
	
	color = Vector2(max(d.x, 0), max(d.y, 0)).length() + min(max(d.x, d.y), 0.0) - pround
	
	color = clamp(-color / bevel, 0.0, 1.0)
#	x - y * floor(x/y)
	
	var tiled_brick_pos : Vector2 = Vector2(bmin.x - 1.0 * floor(bmin.x / 1.0), bmin.y - 1.0 * floor(bmin.y / 1.0))
	
	return Color(color, center.x, center.y, tiled_brick_pos.x + 7.0 * tiled_brick_pos.y)

	
#func brick_uv(uv : Vector2, bmin : Vector2, bmax : Vector2, pseed : float) -> Vector3:
#	var center : Vector2  = 0.5*(bmin + bmax)
#	var size : Vector2 = bmax - bmin
#	var max_size : float = max(size.x, size.y)
#
#	return Vector3(0.5 + (uv - center) / max_size, rand(fract(center) + Vector2(pseed)))
#
#
#func brick_corner_uv(uv : Vector2, bmin : Vector2, bmax : Vector2, mortar : float, corner : float, pseed : float) -> Vector3:
#	var center : Vector2 = 0.5 * (bmin + bmax)
#	var size : Vector2 = bmax - bmin
#	var max_size : float = max(size.x, size.y)
#	var min_size : float = min(size.x, size.y)
#	mortar *= min_size
#	corner *= min_size
#
#	var x : float = clamp((0.5 * size.x - mortar - abs(uv.x - center.x)) / corner, 0, 1)
#	var y : float = clamp((0.5 * size.y - mortar - abs(uv.y - center.y)) / corner, 0, 1)
#
#	return Vector3(x, y, rand(fract(center) + Vector2(pseed)))
#
#func bricks_rb(uv : Vector2, count : Vector2, repeat : float, offset : float) -> Color:
#	count *= repeat
#	var x_offset : float = offset * step(0.5, fract(uv.y*count.y*0.5))
#	var bmin : Vector2 = floor(Vector2(uv.x*count.x-x_offset, uv.y*count.y))
#	bmin.x += x_offset
#	bmin /= count
#
#	return Color(bmin.x, bmin.y, bmin.x+1.0/count,  bmin.y + 1.0/count)
#
#Color bricks_rb2(Vector2 uv, Vector2 count, float repeat, float offset):
#	count *= repeat
#	float x_offset = offset*step(0.5, fract(uv.y*count.y*0.5))
#	count.x = count.x*(1.0+step(0.5, fract(uv.y*count.y*0.5)))
#	Vector2 bmin = floor(Vector2(uv.x*count.x-x_offset, uv.y*count.y))
#	bmin.x += x_offsetbmin /= count
#
#	return Color(bmin, bmin+Vector2(1.0)/count)
#
#
#Color bricks_hb(Vector2 uv, Vector2 count, float repeat, float offset) :
#	float pc = count.x+count.y
#	float c = pc*repeatVector2 corner = floor(uv*c)
#	float cdiff = mod(corner.x-corner.y, pc)
#
#	if (cdiff < count.x) 
#		return Color((corner-Vector2(cdiff, 0.0))/c, (corner-Vector2(cdiff, 0.0)+Vector2(count.x, 1.0))/c)
#	else 
#		return Color((corner-Vector2(0.0, pc-cdiff-1.0))/c, (corner-Vector2(0.0, pc-cdiff-1.0)+Vector2(1.0, count.y))/c)
#
#
#Color bricks_bw(Vector2 uv, Vector2 count, float repeat, float offset) :
#	Vector2 c = 2.0*count*repeatfloat mc = max(c.x, c.y)
#	Vector2 corner1 = floor(uv*c)Vector2 corner2 = count*floor(repeat*2.0*uv)
#	float cdiff = mod(dot(floor(repeat*2.0*uv), Vector2(1.0)), 2.0)
#	Vector2 cornerVector2 size
#
#	if (cdiff == 0.0)	
#		corner = Vector2(corner1.x, corner2.y)
#		size = Vector2(1.0, count.y)
#	else 
#		corner = Vector2(corner2.x, corner1.y)
#		size = Vector2(count.x, 1.0)
#
#	return Color(corner/c, (corner+size)/c)
#
#Color bricks_sb(Vector2 uv, Vector2 count, float repeat, float offset) :
#	Vector2 c = (count+Vector2(1.0))*repeat
#	float mc = max(c.x, c.y)
#	Vector2 corner1 = floor(uv*c)
#	Vector2 corner2 = (count+Vector2(1.0))*floor(repeat*uv)Vector2 rcorner = corner1 - corner2
#	Vector2 corner
#	Vector2 size
#
#	if (rcorner.x == 0.0 && rcorner.y < count.y) 
#		corner = corner2
#		size = Vector2(1.0, count.y)
#	else if (rcorner.y == 0.0) 
#		tcorner = corner2+Vector2(1.0, 0.0)
#		size = Vector2(count.x, 1.0)
#	else if (rcorner.x == count.x) 
#		corner = corner2+Vector2(count.x, 1.0)
#		size = Vector2(1.0, count.y)
#	else if (rcorner.y == count.y) 
#		corner = corner2+Vector2(0.0, count.y)
#		size = Vector2(count.x, 1.0)
#	else 
#		corner = corner2+Vector2(1.0)
#		size = Vector2(count.x-1.0, count.y-1.0)
#
#	return Color(corner/c, (corner+size)/c)
