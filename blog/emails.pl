my @emails=getFiles($config_DatabaseFolder.'/emails');
print "<h1>$locale{$lang}->{emails}</h1>";

foreach (@emails){

	my @entries=split(/¬/, $_);
	my @address = split (/'/, $entries[3]);
	print '<h1>'.$entries[0].' &nbsp; <small>
	<a href="mailto:'.$address[1].'">'.$address[0].'</a> - <a href="?delete=emails/'.$entries[4].'">'.$locale{$lang}->{d}.'</a></small></h1>
	<div class="full">'.$entries[1].'<br /></br>
	<footer>'.$locale{$lang}->{postedon}.$entries[2].'</footer></div>';
}
print "0 $locale{$lang}->{emails}" if (scalar(@emails) == 0);	
