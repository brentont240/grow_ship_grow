extends Node

# This determines the growth needed to go to the next level
@export var growth_limit : int 

@onready var lasers = $Lasers
@onready var player = $Player
@onready var player_health = $Player/HealthComponent
@onready var game_over_screen = $UI/GameOverScreen
@onready var level_transition_screen = $UI/LevelTransition
@onready var level_screen_level = $UI/LevelTransition/Level
@onready var level_screen_help_text = $UI/LevelTransition/HelpText
@onready var mobs = $Mobs
@onready var boss_mob = $BossMob
@onready var spawn_timer = $SpawnTimer
@onready var hud = $UI/HUD

@export var mob_limit : int
@export var level : int

# 0 = ufo, 1 = asteroid, 
@export var mob_types_allowed : int

var ufo_mob = preload("res://entities/mobs/ufoMob.tscn")
var asteroid_mob = preload("res://entities/mobs/asteroidMob.tscn")
var ship_mob = preload("res://entities/mobs/shipMob.tscn")
var drone_mob = preload("res://entities/mobs/droneMob.tscn")

var power_up = preload("res://entities/powerUps/powerUps.tscn")

var lives = 3:
	set(value):
		lives = value
		hud.init_lives(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	game_over_screen.visible = false
	level_transition_screen.visible = false
	lives = 3
	hud.growth = "0"
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("has_grown", _on_player_has_grown)
	player.connect("add_life", _on_player_add_life)
	player_health .connect("is_hit", _on_player_hit)
	player_health.connect("is_dead", _on_player_dead)
	spawn_timer.start()
	boss_mob.connect("enemy_laser_shot", _on_enemy_laser_shot)
	boss_mob.get_node("HealthComponent").connect("is_dead", _on_boss_is_dead)
	

func _on_player_laser_shot(laser):
	$LaserSoundEffect.play()
	lasers.add_child(laser)
	
func _on_enemy_laser_shot(laser):
	$LaserSoundEffect.play()
	lasers.add_child(laser)

func _on_mob_is_dead():
	player.add_kill()

func _on_spawn_timer_timeout():
	var roll = randi_range(0, mob_types_allowed)
	if mobs.get_child_count() < mob_limit:
		var mob
		match roll:
			0:
				mob = ufo_mob.instantiate()
			1:
				mob = asteroid_mob.instantiate()
				mob.connect("create_small_asteroids", _on_create_small_asteroids)
			2:
				mob = ship_mob.instantiate()
				mob.connect("enemy_laser_shot", _on_enemy_laser_shot)
			3:
				mob = drone_mob.instantiate()
				mob.connect("enemy_laser_shot", _on_enemy_laser_shot)
		var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
		mob.position = mob_spawn_location.position
		mob.get_node("MobComponent").connect("spawn_powerup", _on_spawn_power_up)
		# Asteroids don't add to player growth
		if roll != 1:
			mob.get_node("HealthComponent").connect("is_dead", _on_mob_is_dead)
		mobs.add_child(mob)

func _on_player_has_grown():
	hud.growth = str(player.growth)

func _on_player_hit():
	lives -= 1
	
func _on_player_dead():
	await get_tree().create_timer(2).timeout
	game_over_screen.visible = true

func _on_create_small_asteroids(pos):
	# Spawn 1 to 3 smaller asteroids
	var roll = randi_range(1, 3)
	
	for n in roll:
		var mob = asteroid_mob.instantiate()
		mob.position = pos
		mob.is_large_asteroid = false
		# Don't add to mob scene, so it doesn't count for the mobs count
		add_child(mob)
		
func _on_spawn_power_up(pos):
	var roll = randi_range(0, 4)
	var new_power_up = power_up.instantiate()
	new_power_up.power_up_type = roll
	new_power_up.position = pos
	add_child(new_power_up)

func _on_player_add_life():
	lives += 1
	
func _on_boss_is_dead():
	changeLevel()

func changeLevel():
	remove_child(player)
	# hide all of the mobs somehow
	var next_level = level + 1
	var level_path
	match next_level:
		2:
			level_screen_level.text = "Level 2"
			level_screen_help_text.text = "Asteroids do not help grow your ship, but they do have a higher chance of droping powerups."
			level_path = "res://scenes/level2.tscn"
		3:
			level_screen_level.text = "Level 3"
			level_screen_help_text.text = ""
			level_path = "res://scenes/level3.tscn"
		4:
			level_screen_level.text = "Level 4"
			level_screen_help_text.text = ""
			level_path = "res://scenes/level4.tscn"
		5:
			level_screen_level.text = "Level 5: Warning!"
			level_screen_help_text.text = "Large ship incoming! Defeat the enemy ship."
			level_path = "res://scenes/level5.tscn"
		6:
			level_screen_level.text = "Congratulations!"
			level_screen_help_text.text = "You have beaten the game!"
			level_path = "res://scenes/credits.tscn"
			
	level_transition_screen.visible = true
	await get_tree().create_timer(7).timeout
	get_tree().change_scene_to_file(level_path)

