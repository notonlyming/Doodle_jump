extends StaticBody2D

# 弹力系数，玩家将根据该值调整获得的向上初速度
const type = "elestic"
const PLATFORM_WIDTH = 50
var distance

func _ready():
	distance = $"..".screen_size.y / 3 * 2

# 发现玩家碰撞时播放动画
func on_Player_touched():
	$Sprite.play()
	$"..".adjustPositonByplatform(self)
	$"../PlayerElestic".playing = true

func changeCollision(state):
	$CollisionShape2D.disabled = (state == "disable")
