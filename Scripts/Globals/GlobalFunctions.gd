extends Node


func create_directory(foldername:String="default",startingpath:String="user://"):
	var newdir : Directory = Directory.new()
	if !newdir.dir_exists(startingpath+foldername):
		newdir.make_dir_recursive(startingpath+foldername)
