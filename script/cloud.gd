extends StaticBody2D

# 弹力系数，玩家将根据该值调整获得的向上初速度
const type = "cloud"
const PLATFORM_WIDTH = 50
var _direction = "+"
var _moveVelocity = 1
var basePosX  # 基准位置，不会偏离基准位置太多
const MOVE_DIS = 20  # 偏移量

func _ready():
	basePosX = position.x

func _process(delta):
	if _direction == "+":
		position.x += _moveVelocity
		if position.x > basePosX + MOVE_DIS:
			_direction = '-'
	elif _direction == '-':
		position.x -= _moveVelocity
		if position.x < basePosX - MOVE_DIS:
			_direction = '+'

# 发现玩家碰撞时播放动画
func on_Player_touched():
	$Sprite.play("disappear")
	$CollisionShape2D.disabled = true

func changeCollision(state):
	$CollisionShape2D.disabled = (state == "disable")
