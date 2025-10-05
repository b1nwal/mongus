

static func create_hitbox_from_image(image: Image) -> Area2D:
	var width = image.get_width()
	var height = image.get_height()

	var min_x = width
	var min_y = height
	var max_x = 0
	var max_y = 0

	for y in range(height):
		for x in range(width):
			if image.get_pixel(x, y).a > 0.01:
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)

	if max_x < min_x or max_y < min_y:
		push_warning("Image is fully transparent, returning empty Area2D")
		return Area2D.new()

	var area = Area2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2((max_x - min_x + 1)/2.0, (max_y - min_y + 1)/2.0)
	
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(min_x + shape.extents.x - width/2, min_y + shape.extents.y - height/2 - 200)
	area.add_child(collision)
	area.collision_mask = 2
	
	return area
