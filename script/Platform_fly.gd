extends StaticBody2D

const type = "fly"
const PLATFORM_WIDTH = 50
var distance
var _direction = "+"
var _moveVelocity = 8

func _ready():
	distance = $"..".screen_size.y * 2
	$Sprite.play("have")

func _process(delta):
	if _direction == "+":
		position.x += _moveVelocity
		if position.x > $"..".screen_size.x / 5 * 4:
			_direction = '-'
	elif _direction == '-':
		position.x -= _moveVelocity
		if position.x < $"..".screen_size.x / 5:
			_direction = '+'

func changeCollision(state):
	$CollisionShape2D.disabled = state == "disable"

func on_Player_touched():
	$"..".adjustPositonByplatform(self)
	$Sprite.play("haveNot")
	$"../PlayerFly".playing = true
