extends Node2D

enum GameState { MENU, PLAYING, WIN, LOSE }

var state = GameState.MENU

var points = []
var occupied = []


# ------------------------
# READY
# ------------------------
func _ready():
	# connect HUD signals
	$HUD.play_pressed.connect(start_game)
	$HUD.restart_pressed.connect(start_game)
	$HUD.quit_pressed.connect(quit_game)

	$HUD.show_menu()
	$HUD/Fireworks.visible = false   # 👈 ADD THIS

# ------------------------
# GAME CONTROL
# ------------------------
func start_game():
	state = GameState.PLAYING
	reset_game()
	$HUD.show_game()
	$HUD/Fireworks.visible = false   # 👈 ADD THIS


func quit_game():
	get_tree().quit()


# ------------------------
# RESET GAME
# ------------------------
func reset_game():
	points.clear()
	occupied.clear()

	# rebuild points
	for p in $Points.get_children():
		points.append(p.global_position)
		occupied.append(false)

	# reset all frogs
	for node in get_children():
		if node.has_method("setup"):
			node.setup(self)


# ------------------------
# WIN CHECK
# ------------------------
func check_win():
	var g1 = get_node_or_null("green_frog1")
	var p2 = get_node_or_null("pink_frog3")

	if g1 == null or p2 == null:
		print("Frogs not found")
		return

	print("Green:", g1.current_index, " Pink:", p2.current_index)

	# Example condition: Green -> P5, Pink -> P3
	# (P5 = index 4, P3 = index 2)
	if g1.current_index == 4 and p2.current_index == 2:
		win()


# ------------------------
# WIN / LOSE
# ------------------------
func win():
	if state != GameState.PLAYING:
		return

	state = GameState.WIN
	$HUD.show_win()
	print("WIN")
	$HUD/Fireworks.visible = true   # 👈 ADD THIS


func lose():
	if state != GameState.PLAYING:
		return

	state = GameState.LOSE
	$HUD.show_lose()
	print("LOSE")
	
func check_lose():
	for node in get_children():
		if node.has_method("can_move"):
			if node.can_move():
				return   # at least one move exists → NOT lose

	# no frog can move
	lose()
