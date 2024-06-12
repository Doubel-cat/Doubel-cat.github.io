extends Node2D


func execute(s, dir = Vector2(0, 0)):
	s.velocity = Vector2(0, 0)
	s.velocity = s.global_position.direction_to(dir).normalized() * s.current_speed
	
	s.move_and_slide()
