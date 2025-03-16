extends Node2D

var soundMenu = preload("res://Son/Game Music.wav")
var soundGame = preload("res://Son/Game Music.wav")
var soundChaine1 = preload("res://Son/CHAINE1.wav")
var soundChaine2 = preload("res://Son/CHAINE2.wav")
var soundJump1 = preload("res://Son/JUMP1.wav")
var soundJump2 = preload("res://Son/JUMP2.wav")
var soundJump3 = preload("res://Son/JUMP3.wav")
var soundLand1 = preload("res://Son/LAND1.wav")
var soundLand2 = preload("res://Son/LAND2.wav")
var soundMort1 = preload("res://Son/MORT1.wav")
var soundMort2 = preload("res://Son/MORT2.wav")
var soundMort3 = preload("res://Son/MORT3.wav")
var soundRun = preload("res://Son/RUN.wav")
var soundSlide = preload("res://Son/SLIDE.wav")
var soundSplit1 = preload("res://Son/SPLIT1.wav")
var soundSplit2 = preload("res://Son/SPLIT2.wav")
var soundSplit3 = preload("res://Son/SPLIT3.wav")

@onready var music_menu = $menuMusic
@onready var music_game = $gameMusic
@onready var music_sfx = $sfx

#permet de stopper toutes les musiques
func stop_all_music():
	music_menu.stop()
	music_game.stop()

#Lance la musique selon les scenes
func update_music():
	var current_scene = get_tree().current_scene
	if current_scene:
		# Si le nom de la scène contient "Menu", on joue la musique du menu
		if !current_scene.name.find("Menu"):
			stop_all_music()
			print("start music menu")
			music_menu.stream = soundMenu
			music_menu.play()
			current_scene = get_tree().current_scene
			await get_tree().create_timer(97.0).timeout
			if current_scene.name.find("Menu"):
				pass
			else:
				update_music()
		# Sinon, on suppose que c'est le niveau et on joue la musique de jeu
		else:
			print("start music game")
			stop_all_music()
			music_game.stream = soundGame
			music_game.play()

func play_sfx(state_name: String):
	var rand_val
	music_sfx.stop()
	match state_name:
		"idle":
			pass
		"run":
			music_sfx.stream = soundRun
			pass
		"jump":
			rand_val = randi() % 3
			match rand_val:
				0:
					music_sfx.stream = soundJump1
					pass
				1:
					music_sfx.stream = soundJump2
					pass
				2:
					music_sfx.stream = soundJump3
					pass
		"dash":
			pass
		"wall_slide":
			music_sfx.stream = soundSlide
			pass
		"split":
			rand_val = randi() % 3
			match rand_val:
				0:
					music_sfx.stream = soundSplit1
					pass
				1:
					music_sfx.stream = soundSplit2
					pass
				2:
					music_sfx.stream = soundSplit3
					pass
		"fusion":
			pass
			
		"death": 
			rand_val = randi() % 3
			match rand_val:
				0:
					music_sfx.stream = soundMort1
					pass
				1:
					music_sfx.stream = soundMort2
					pass
				2:
					music_sfx.stream = soundMort3
					pass
		_:
			print("État inconnu pour l'animation: ", state_name)
	music_sfx.play()
