<?php

if(file_exists('d:/music/songs/'.$_GET['id'].'.mp3'))
{
	if(filesize('d:/music/songs/'.$_GET['id'].'.mp3')<=524288)
	{
		DownloadSong();
	}
	else
	{
		echo 'file_exists!';
	}
}
else
{
	DownloadSong();
}

function DownloadSong()
{
	$url = file_get_contents("https://csgogamers.com/musicserver/api/geturl.php?id=".$_GET['id']);
	if($url == NULL)
	{
		die('file_get_contents -> API -> false');
	}
	$file = file_get_contents($url);
	if($file == NULL)
	{
		die('file_get_contents -> download -> failed');
	}
	$name = 'd:/music/songs/'.$_GET['id'].'.mp3';
	if(file_put_contents($name,$file))
	{
		if(filesize('d:/music/songs/'.$_GET['id'].'.mp3')<=524288)
		{
			echo 'download failed: '.$url;
		}
		else
		{
			echo 'success!';
		}
	}
	else
	{
		echo 'put file failed: '.$name;
	}
}
?>