extends Node2D

func execute(s, dir = []):
	s.velocity = Vector2(0, 0)
	
	if dir.has("up"):
		s.velocity.y -= 1
	if dir.has("down"):
		s.velocity.y += 1
	if dir.has("left"):
		s.velocity.x -= 1
	if dir.has("right"):
		s.velocity.x += 1
	
	if dir.size():
		#s.velocity += Vector2(s.current_speed, s.current_speed)
		s.velocity = s.velocity.normalized() * s.current_speed
		s.move_and_slide()




