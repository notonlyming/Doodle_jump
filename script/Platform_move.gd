extends StaticBody2D

const type = "move"
const PLATFORM_WIDTH = 50
var _direction = "+"
var _moveVelocity = 4
var distance = 0

func _ready():
	$Sprite.play("move")

func _process(delta):
	if _direction == "+":
		position.x += _moveVelocity
		if position.x > $"..".screen_size.x / 5 * 4:
			_direction = '-'
	elif _direction == '-':
		position.x -= _moveVelocity
		if position.x < $"..".screen_size.x / 5:
			_direction = '+'
	# 更新自己的距离
	distance = $"..".screen_size.y - $"..".BOTTOM_EDGE - position.y 

func changeCollision(state):
	$CollisionShape2D.disabled = state == "disable"

func on_Player_touched():
	$"..".adjustPositonByplatform(self)
	$"../PlayerJump".playing = true
