extends StaticBody2D

# 弹力系数，玩家将根据该值调整获得的向上初速度
const type = "brittle"
const PLATFORM_WIDTH = 50
var distance = 0

func _process(delta):
	# 更新自己的距离
	distance = $"..".screen_size.y - $"..".BOTTOM_EDGE - position.y 

# 发现玩家碰撞时播放动画
func on_Player_touched():
	$Sprite.play("brittle")
	$"..".adjustPositonByplatform(self)
	$CollisionShape2D.disabled = true
	$"../PlayerBrittle".playing = true

func changeCollision(state):
	$CollisionShape2D.disabled = (state == "disable")
