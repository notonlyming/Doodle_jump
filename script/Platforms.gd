extends Node2D

var screen_size = Vector2(1920, 1080)
const PLATFORM_GAP = 200
# 平台移动速度
var speed = 20
const FALL_A = 0.3
# 这是一个列表，第一个是接触到的平台，第二个是应该到达的距离
# 用于_process移动所有平台的参考
var target = [null, null]
var Platform_type_list = [
	preload("res://Scene/Platform_normal.tscn"),
	preload("res://Scene/Platform_elestic.tscn"),
	preload("res://Scene/Platform_move.tscn"),
	preload("res://Scene/Platform_fly.tscn"),
	preload("res://Scene/Platform_dead.tscn"),
	preload("res://Scene/Platform_brittle.tscn"),
	preload("res://Scene/cloud.tscn")
]
enum platformTypes {NORMAL, ELESTIC, MOVE, FLY, DEAD, BRITTLE, CLOUD}
const BOTTOM_EDGE = 50
var allPlatforms = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_generatePlatforms()

func gameOver():
	queue_free()

func enableCollision():
	if allPlatforms.size() > 2:
		for platform in allPlatforms:
			platform.changeCollision("enable")

func disableCollision():
	if allPlatforms.size() > 2:
		for platform in allPlatforms:
			platform.changeCollision("disable")

# 该函数随机生成一些初始platform放在场景上
func _generatePlatforms():
	# 在y轴上分配，分配顺序从屏幕下到上，因为后面生成的平台在屏幕上方
	# 所以此处先再上面生成一些随机平台
	var yArray = range(screen_size.y + PLATFORM_GAP / 2, screen_size.y * 3, PLATFORM_GAP)
	yArray.invert()
	for y in yArray:
		generateNew(y)
	
	# 再生成一些普通平台
	yArray = range(BOTTOM_EDGE, screen_size.y - PLATFORM_GAP / 2, PLATFORM_GAP)
	yArray.invert()
	for y in yArray:
		generateNew(y, platformTypes.NORMAL)

# 生成平台类型决策函数，用于限制特定平台的数量
"""
死亡平台：5个以内只能出现2个，死亡平台不能挨着。否则替换为移动平台.
飞行平台：不能太多，20个以内至多有一个。否则替换为普通平台。
弹性平台：不能太多，10个以内最多2个。否则替换为普通平台。
云：3个以内只能出现一个, 且不与死亡平台同时出现
"""
func generateTypeDecide(recommandType:int):
	var resultType = recommandType
	if allPlatforms != null:
		if recommandType == platformTypes.DEAD:
			var deadCounter = countPlatforms(-5, 0, "dead")
			if deadCounter <= 2:
				if allPlatforms[-1].type == "dead" or allPlatforms[-1].type == "cloud":  # 如果是紧挨着，则替换成移动平台
					resultType = platformTypes.MOVE
			else: # 两个或两个以上
				resultType = platformTypes.NORMAL
		elif recommandType == platformTypes.FLY:
			var flyCounter = countPlatforms(-20, 0, "fly")
			if flyCounter > 1 or randi() % 2 == 0:
				resultType = platformTypes.NORMAL
		elif recommandType == platformTypes.ELESTIC:
			var elesticCounter = countPlatforms(-10, 0, "elestic")
			if elesticCounter > 2:
				resultType = platformTypes.NORMAL
		elif recommandType == platformTypes.CLOUD:
			var cloudCounter = countPlatforms(-3, 0, "cloud") + countPlatforms(-3, 0, "dead")
			if cloudCounter > 0:
				resultType = platformTypes.NORMAL
	return resultType

# 查找特定范围内，特定平台的数目
func countPlatforms(from, to, type):
	var counter = 0
	if allPlatforms.size() > abs(to - from):
		for i in range(from, to):
			if allPlatforms[i].type == type:
				counter += 1
	return counter

# 给定y值在x方向随机生成一个新随机类型的平台
func generateNew(y, typeIndex = null):
	# 随机pick一个平台
	var randomInt = randi()
	var pickPlatformType
	
	# 如果未执行平台类型
	if typeIndex == null:
		pickPlatformType = Platform_type_list[generateTypeDecide(randomInt % Platform_type_list.size())]
	else:
		pickPlatformType = Platform_type_list[typeIndex]

	var tempPlatform = pickPlatformType.instance()
	# 随机x坐标 从屏幕五分之一处 到 五分之四处
	tempPlatform.position.x = rand_range(screen_size.x/5, screen_size.x/5*4)
	tempPlatform.position.y = y
	add_child(tempPlatform)
	tempPlatform.add_to_group("platforms")
	allPlatforms = get_tree().get_nodes_in_group("platforms")  # 更新所有平台数组
	return tempPlatform

func deletPlatform(platform, topPlatform):
	if platform == target[0]:  # 修复连续飞行造成的顶部平台被删除导致引用出错BUG
		target[0] = null # 删除前将指针置为null，避免出错
		get_node("../Player").upOrFall = "fall"  # 令玩家下落
	platform.queue_free()
	# 此时在最顶部的平台上面再重新生成一个新的平台
	generateNew(topPlatform.position.y - PLATFORM_GAP)
	allPlatforms = get_tree().get_nodes_in_group("platforms")  # 更新所有平台数组

func getTopPlatform():
	return allPlatforms[-1]

func _physics_process(delta):
	# 将所有平台向下移动，直到下移距离接近0
	var moveLittle = speed
	var distance
	allPlatforms = get_tree().get_nodes_in_group("platforms")
	# 这是保证已经碰过了一次那个平台，游戏刚开始时是null
	# 这里保证只有玩家上升到中部才让平台下落，或者玩家触碰到死亡线(speed<0)
	if target[0] != null and ($"../Player".upOrFall == "hang" or $"../Player".upOrFall == "fly" or speed < 0):
		# 判断最顶平台是否到位
		if target[1] > target[0].position.y or (speed < 0 and target[1] < target[0].position.y):
			# 由于这里不知道上升距离，只知道剩余距离。因此是自由落体的逆向过程
			# 由速度距离公式vt2 - v02 = 2ax v02 = 0得
			distance = target[1] - target[0].position.y
			# 速度变化函数的作用范围在一倍的屏幕竖向距离
			if distance < screen_size.y and speed > 0:
				moveLittle = sqrt(FALL_A * abs(distance))
			# 控制所有平台向下落
			for index in range(allPlatforms.size()):
				# 向下落一点点
				allPlatforms[index].position.y += moveLittle
				# 如果有平台下到屏幕以下了，则删除平台
				if allPlatforms[index].position.y > screen_size.y:
					deletPlatform(allPlatforms[index], allPlatforms[-1])
					break # 重新来过，因为有平台被销毁了
			# 根据移动距离加分
			if speed > 0:  # 仅在玩家跳跃时加分
				get_node("..").score += moveLittle
		else:
			# 如果平台到位，则玩家可以下落
			get_node("../Player").upOrFall = "fall"

# 触碰到的platform有一个要移动的距离
# 这个函数会直接确定最顶部要移动的距离
# (为什么不是碰到的那个，因为碰到的那个下去以后很快就会销毁。
# 而最顶部的往往在屏幕上面2个屏幕的地方)
# 移动的事情会交给_process来做
func adjustPositonByplatform(touchedPlatform):
	var distance = touchedPlatform.distance
	# 重算最顶部位置，以最顶部的平台归位到正确位置为准
	# 这是因为最底部的平台是会被删除的，会出点问题
	var TopPlatform = getTopPlatform()
	target = [TopPlatform, TopPlatform.position.y + distance]

# 如果死亡则将平台们升起
func raiseThem():
	var TopPlatform = getTopPlatform()
	speed *= -1 # 反转速度使平台可以上升
	target = [TopPlatform, TopPlatform.position.y - screen_size.y]
