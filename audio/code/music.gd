extends AudioStreamPlayer

## songs
var song_1 = preload("res://audio/music/song_1/song_1.tres")
var song_2 = preload("res://audio/music/song_2/song_2.tres")
var song_boss = preload("res://audio/music/song_boss/song_boss.tres")

##
var songs = [song_1, song_2, song_boss]
var current_song = 0

func _ready():
	finished.connect(on_song_finished)
	stream = songs[current_song]
	play()

func on_song_finished():
	if current_song > songs.size():
		current_song = 0
		stream = songs[current_song]
	else:
		current_song += 1
		stream = songs[current_song]
	play()
