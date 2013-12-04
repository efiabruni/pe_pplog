#This is a plugin for the admin page of the pe_pplog. It will create a gallery out of pictures in
#a folder. Please write the path from the web-server root (for example: web-server root = /root/Web-Server,
#image folder = /root/Web-Server/images, you write: /images)
#Efia 25.05.13
if(r('process') eq 'newGallery')
{		
	my $title = r('title');
	my $category = r('category');
	my $date = getdate($config_gmt);
	my $dir = r('folder');
	my $content = bbcode(r('content'));
	my $pictures = "";

	if($title eq '' || $category eq ''|| $dir eq '' )
        {
            die($locale{$lang}->{necessary});
        }
 
	my @files = getFiles($config_postsDatabaseFolder);
	my @lastOne = split(/¬/, $files[0]);
	my $i = 0;
       
         if($lastOne[4] eq '')
         {
            $i = sprintf("%05d",0);
         }
         else
         {
            $i = sprintf("%05d",$lastOne[4]+1);
         }


	opendir PIC, "$config_serverRoot/$dir";
	while ($_ = readdir (PIC)){
		foreach ($_){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
			
			if (-e "$config_serverRoot/$dir/thumbs"){
				$pictures .= "<input type=image class=thumb alt=$name src=$dir/thumbs/$_ title=$name /><div class=box><h3>$name</h3><img src=$dir/$_ /></div>" if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
			else {
				$pictures .= "<input type=image class=thumb alt=$name src=$dir/$_ title=$name /><div class=box><h3>$name</h3><img src=$dir/$_ /></div>" if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
				
		}
	}

	open(FILE, ">$config_postsDatabaseFolder/$i.$config_dbFilesExtension");
	print FILE $title.'¬'.$content.'<br />'.$pictures.'¬'.$date.'¬'.$category.'¬'.$i;
	close FILE;

	open(FILE, ">>$config_postsDatabaseFolder/galleries.$config_dbFilesExtension.galleries");
	print FILE $i.'-';
	close FILE;

       	my $tempContent;
		open(FILE, "<$config_postsDatabaseFolder/$i.$config_dbFilesExtension");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		my @entry = split(/¬/, $tempContent);
		my @categories = split (/'/, $entry[3]); 
		
		print '<h1><a href="?viewDetailed='.$entry[4].'">'.$entry[0].'</a></h1><a href="?edit=posts/'.$entry[4].'">'.$locale{$lang}->{e}.'</a> - <a href="?delete=posts/'.$entry[4].'">'.$locale{$lang}->{d}.'</a><br /><br />'.$entry[1].'<br /><br />
		<footer>'.$locale{$lang}->{postedon}.$entry[2].' - '.$locale{$lang}->{categories}.':';
		for (0..$#categories){
					print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
				} 
		print '</footer><br /><br />';

}

else
{
	my @categories = getCategories();
	print '<h1>'.$locale{$lang}->{makegallery}.'...</h1>	
	<form accept-charset="UTF-8" action="" name="submitform" method="post">
	<table><tr>
	<td>'.$locale{$lang}->{title}.'</td>
	<td><input name=title type=text id=title></td>
	</tr><tr>
	<td>'.$locale{$lang}->{imagefolder}.' <span text="'.$locale{$lang}->{spanimg}.'">(?)</span></td>
	<td><input name=folder type=text id=folder></td>
	</tr><tr>
	<td>'.$locale{$lang}->{comment}.'</td>
	<td><textarea name="content" cols="50" rows="10" id="content"></textarea></td></tr>
	<tr><td>'.$locale{$lang}->{categories}.' <span text="'.$locale{$lang}->{spancat}.' ">(?)</span></td><td>';
	
	my $i = 1;
	foreach(@categories)
		{
			if($i < scalar(@categories))	
			{
				print $_.', ';
			}
			else
			{
				print $_;
			}
			$i++;
		}
	print '</td></tr>
	<tr><td>&nbsp;</td><td><input name="category" type="text" id="category"></td></tr>
	<tr>
	<td><input name="process" type="hidden" id="process" value="newGallery"></td> 
	<td><input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'"></td>
	</tr></table></form>';
}