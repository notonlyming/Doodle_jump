extends StaticBody2D

const type = "normal"
const PLATFORM_WIDTH = 50

func changeCollision(state):
	$CollisionShape2D.disabled = state == "disable"