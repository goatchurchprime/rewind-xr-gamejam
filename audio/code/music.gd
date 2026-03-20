extends AudioStreamPlayer

## songs
var song_1 = preload("res://audio/music/song_1/song_1.tres")
var song_2 = preload("res://audio/music/song_2/song_2.tres")
var song_boss = preload("res://audio/music/song_boss/song_boss.tres")

##
var songs : Array[AudioStreamSynchronized] = [song_1, song_2, song_boss]
var current_song = 0

func _ready():
	finished.connect(on_song_finished)
	stream = songs[current_song]
	var now_playing = songs[current_song] as AudioStreamSynchronized
	# set tracks to muted..
	now_playing.set("stream_0/volume", -60.0) # drums
	# keep the bass
	#now_playing.set("stream_1/volume", -60.0) # bass
	now_playing.set("stream_2/volume", -60.0) # synth
	now_playing.set("stream_3/volume", -60.0) # keys
	play()

func on_song_finished():
	current_song += 1
	if current_song > songs.size():
		current_song = 0
	stream = songs[current_song]
	play()
