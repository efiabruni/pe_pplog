my @emails=getFiles($config_DatabaseFolder.'/emails');
print "<h1>$locale{$lang}->{emails}</h1>";
foreach (@emails){

	my @entries=split(/¬/, $_);
	my @categories = split (/'/, $entries[3]);
	print '<div class="article"><h1>'.$entries[0].' &nbsp; <small>
	<a href="mailto:'.$categories[1].'">'.$categories[0].'</a> - <a href="?delete=emails/'.$entries[4].'">'.$locale{$lang}->{d}.'</a></small></h1>
	<div class="hide"><br /><br />'.$entries[1].'<br /></div></br>
	<footer>'.$locale{$lang}->{postedon}.$entries[2].'</footer>';
}
print'';	

