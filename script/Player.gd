extends KinematicBody2D

# 屏幕尺寸，在ready函数中初始化
var screen_size = Vector2(1920, 1080)
# 水平移动速度放大系数
const HORIZONTAL_FIX_K = 10
const A = 9.8 * 200 # 玩家下落加速度
var _velocity = Vector2(0, 0)
# 上升和下降状态记录变量
var upOrFall = "fall"
const UP_V = 800  # 玩家上升速度，为匀速

# 根据状态播放动画
func playAnimateByState():
	# 根据水平速度调整动画方向
	$AnimatedSprite.flip_h = _velocity.x < 0
	if upOrFall == "fall":
		$AnimatedSprite.play("drop")
	elif upOrFall == "up" or upOrFall == "hang":
		$AnimatedSprite.play("jump")
	elif upOrFall == "boom":
		$AnimatedSprite.play("boom")
		yield(get_tree().create_timer(1), "timeout")
		upOrFall = "fall"
	elif upOrFall == "fly":
		$AnimatedSprite.play("fly")

func fly(delta):
	var vertical_target = screen_size.y / 2
	var distance = position.y - vertical_target
	# 如果没到达屏幕中部
	if distance > 0:
		_velocity.y = -UP_V
		position += _velocity * delta
	else:
		# 到达屏幕中部，处于等待状态
		upOrFall = "fly"
		# 在上升到指定位置以后，仅改变水平方向
		position.x += _velocity.x * delta

func up(delta):
	var vertical_target = screen_size.y / 2
	var distance = position.y - vertical_target
	# 如果没到达屏幕中部
	if distance > 0:
		_velocity.y = -UP_V
		position += _velocity * delta
	else:
		# 到达屏幕中部，处于等待状态
		upOrFall = "hang"

func hang(delta):
	if get_node("..").gameState == "ready":
		upOrFall = "fall"
	else:
		# 在上升到指定位置以后，仅改变水平方向
		position.x += _velocity.x * delta

func fall(delta):
	var vertical_target = screen_size.y
	var x = position.y - vertical_target / 2 # 下落的距离
	# 速度距离公式，初速为1
	_velocity.y = sqrt(A * x + 1)
	# 移动
	var collide_info = move_and_collide(_velocity * delta)
	# 如果碰到
	if collide_info:
		_on_Player_body_entered(collide_info.collider)

func _process(delta):
	# 获取鼠标坐标与玩家的水平距离
	var mouse_position = get_viewport().get_mouse_position()
	var diffDistance = mouse_position.x - position.x
	# 如果有点距离，则移动
	_velocity.x = diffDistance * HORIZONTAL_FIX_K
	# 开始移动
	if upOrFall == 'fall':
		fall(delta)
	elif upOrFall == "up":
		up(delta)
	elif upOrFall == "hang":
		hang(delta)
	elif upOrFall == "fly":
		fly(delta)
	# 限制玩家位置
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, screen_size.y / 2, screen_size.y)
	playAnimateByState()

# 此处处理玩家下落碰撞后的行为
func _on_Player_body_entered(body):
	if body.name.find("Platform") != -1:
		if body.name.find("dead") != -1:
			upOrFall = "boom"
		elif body.name.find("fly") != -1:
			upOrFall = "fly"
		else:
			upOrFall = "up"
		body.on_Player_touched()
	elif body.name.find("deadLine") != -1:
		# 只有不在游戏时才会起跳
		if $"..".gameState != "playing":
			upOrFall = "up"
		get_node("..").player_On_deadLine()
	elif body.name.find("cloud") != -1:
		body.on_Player_touched()
		pass
