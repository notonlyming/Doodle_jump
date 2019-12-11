extends RigidBody2D

# 竖直初速度修正系数
const FIX_VERTICAL_V_K = 1.5
# 水平速度系数
const FIX_HORIZONTAL_V_K = 10
# 竖直方向施加的力，用于加速下落速度
# 注意，无法通过增加质量改变加速度
const VERTICAL_FORCE = 500
# 弹跳初速度, 该速度需要动态调整，无论如何都不能跳过屏幕中部
var jumpVelocity
# 屏幕尺寸，在ready函数中初始化
var screen_size
# 上升信号，用于让所有平台接收并关闭碰撞检测一边玩家能穿过平台
signal I_am_up
# 降落信号，与上面相反
signal I_am_fall
# 上次上升或下降状态
var lastUpFallState = "fall"

# 该函数由引擎自动调用，只有在里面改变施加力才能与物理系统协调
func _integrate_forces(state):
	applied_force = Vector2(0, VERTICAL_FORCE)

func _ready():
	screen_size = get_viewport_rect().size

# 根据速度播放动画
func playAnimateByVelocity():
	# 根据水平速度调整动画方向
	$AnimatedSprite.flip_h = linear_velocity.x < 0
	
	if linear_velocity.y > 0:
		$AnimatedSprite.play("drop")
	else:
		$AnimatedSprite.play("jump")

func _physics_process(delta):
	# 如果状态发生改变，发出上升或下降信号一次
	if linear_velocity.y < -0 and lastUpFallState == "fall":
		emit_signal("I_am_up")
		lastUpFallState = "up"
	elif linear_velocity.y > 0 and lastUpFallState == "up":
		emit_signal("I_am_fall")
		lastUpFallState = "fall"

func _process(delta):
	# 获取鼠标坐标与玩家的水平距离
	var mouse_position = get_viewport().get_mouse_position()
	var diffDistance = mouse_position.x - position.x
	# 如果有点距离，给他一个该方向的速度
	if abs(diffDistance) > 0:
		set_axis_velocity(Vector2(diffDistance * FIX_HORIZONTAL_V_K,0))
	else:
		set_axis_velocity(Vector2(0,0))
	
	# 播放玩家的跳跃动画
	playAnimateByVelocity()

# 此处处理玩家与平台发生碰撞后的起跳
func _on_Player_body_entered(body):
	# 玩家不能跳过屏幕中部，因此从起跳点到屏幕中部的距离为路程
	var x = body.position.y - screen_size.y / 2
	# 根据速度距离公式 v平方 = ax求出应该施加的初速度
	var a = (VERTICAL_FORCE + weight) / mass
	# 由该公式计算出来的初速度与引擎实际发生的由出入，因此乘以一个修正系数
	if x>0:
		jumpVelocity = -sqrt(a*x) * FIX_VERTICAL_V_K
	else:
		jumpVelocity = 0
	"""
	print("jumpV: %s" % jumpVelocity)
	print("position: [%s,%s]" %[position.x,position.y])
	"""
	set_axis_velocity(Vector2(0,jumpVelocity))