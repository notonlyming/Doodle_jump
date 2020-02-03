extends StaticBody2D

const type = "normal"
const PLATFORM_WIDTH = 50
var distance = 0

func _process(delta):
	# 更新自己的距离
	distance = $"..".screen_size.y - $"..".BOTTOM_EDGE - position.y

func changeCollision(state):
	$CollisionShape2D.disabled = state == "disable"

func on_Player_touched():
	$"..".adjustPositonByplatform(self)
	$"../PlayerJump".playing = true
