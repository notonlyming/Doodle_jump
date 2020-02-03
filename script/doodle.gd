extends Node2D
# doodle游戏的主界面

var gameState = "ready" # 有over starting falling 和 ready 4种状态
var score = 0 # 记录游戏的分数
# 几种背景颜色
const goodColors = [
Color("#fa5a5a"), # red
Color("#f0d264"), # yellow
Color("#82c8a0"), # green
Color("#cb99c5"), # purple
]
# 下一个要变换的颜色，一开始为白色
var targetColor:Color = Color.white
# 记录颜色变换步幅，值只能为正一和负一
# 更新颜色时，他会与当前颜色的向量相加，使之变换颜色
var colorDirection:Vector3
# 帧数计数器，由下面的代码控制。
# 也是与颜色控制相关
# 用于控制颜色每几帧更新一次，不然每帧更新一次太瞎眼
var frameCounter:int = 0


func _ready():
	$InfoDisplay.GameReady() # 显示预备信息
	randomize() # 置随机数种子
	# 因退出的时候需要做一些事情，例如传递分数(还未实现)
	# 这些事情理应游戏根来做，所以连接到游戏根下的quit函数
	get_node("InfoDisplay/ButtonExit").connect("pressed", self, "quit")

func quit():
	get_tree().quit()

func _process(delta):
	$InfoDisplay.updateScore(score)
	# 每3帧推进一下渐变颜色
	if score > 10000 and frameCounter > 3 :
		changeColorRandomly()
		frameCounter = 0  # 帧数计数器翻转控制
	else:
		frameCounter += 1

# 碰到了底下的死亡线
func player_On_deadLine():
	if gameState == "starting":
		gameState = "falling"
		$Player.upOrFall = "up" # 升起玩家
		$Platforms.raiseThem() # 升起平台，表示下落
		$PlayerFall.playing = true
		yield(get_tree().create_timer(2), "timeout") # 延时两秒结束
		dead()

# 判断两个颜色是否相等
func isColorEqual(color1:Color, color2:Color):
	var result = false
	if abs(color1.r8 - color2.r8) < 1:
		if abs(color1.r8 - color2.r8) < 1: 
			if abs(color1.r8 - color2.r8) < 1:
				result = true
	return result

func converColorToVector3(color:Color):
	return Vector3(color.r8, color.g8, color.b8)

# 随机地改变颜色
func changeColorRandomly():
	var colorCurrent:Vector3 = converColorToVector3($ColorRect.color)
	if isColorEqual($ColorRect.color, targetColor):
		# 如果当前颜色是目标颜色
		# 改变目标颜色
		targetColor = goodColors[randi() % goodColors.size()]
		# 计算当前颜色指向目标颜色的方向向量, 方向只在这里(改变了颜色的时候)计算一次
		colorDirection = converColorToVector3(targetColor) - colorCurrent
		colorDirection = Vector3(sign(colorDirection.x), sign(colorDirection.y), sign(colorDirection.z))
	else:
		# 否则向目标颜色靠近
		colorCurrent += colorDirection
		$ColorRect.color = Color(colorCurrent.x / 255, colorCurrent.y / 255, colorCurrent.z / 255)

# 玩家挂掉时做的一些事情
func dead():
	$InfoDisplay.GameOver(score)
	$Platforms.gameOver()
	gameState = "over"

# 开始游戏做的一些事情
func start_game():
	score = 0
	var platforms = preload("res://Scene/Platforms.tscn").instance()
	add_child(platforms)
	$InfoDisplay.GameStarted()
	gameState = "starting"
	$ColorRect.color = Color.white
	$Player.upOrFall = "fall"
