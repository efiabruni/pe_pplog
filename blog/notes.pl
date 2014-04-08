my $page = r('page');
my $cat = r('cat');
my $do = '?do=notes';
my @notes=getFiles($config_DatabaseFolder.'/notes');
my @categories;
my @tempCategories = ();

if (scalar(@notes) == 0){print $locale{$lang}->{nopages1}.' <a href="?do=newEntry">'.$locale{$lang}->{nopages2}.'</a>';}

else
{
	foreach(@notes)
		{
			my @finalEntries = split(/¬/, $_);
			my @split = split(/'/, $finalEntries[3]);
			push(@tempCategories, @split);
		}
	@categories = array_unique(@tempCategories);
	
	print '<h1>'.$locale{$lang}->{categories}.'</h1>'; 
	foreach(@categories)
	{
		print '<a href="?do=notes&cat='.$_.'">'.$_.'</a><br />';
	}
	unless ($cat eq ''){
		my @thisCategoryEntries = ();
		foreach my $item(@notes)
		{
			my @split = split(/¬/, $item);											# [0] = Title	[1] = Content	[2] = Date	[3] = Category
			my @nextsplit = split(/'/,$split[3]);									# Efia change to accomodate more than one category
			if (grep { $_ eq $cat } @nextsplit)
			{
				push(@thisCategoryEntries, $item);
			}
		}
		@notes = @thisCategoryEntries;
		$do = $do.'&cat='.$cat;
	}
	# display notes
	if($page eq ''){ $page = 1; }	
	my $totalPages = ceil((scalar(@notes))/$config_entriesPerPage);								
	my $arrayEnd = ($config_entriesPerPage*$page);						# The array will start from this number
	my $arrayStart = $arrayEnd-($config_entriesPerPage-1);				# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;

	my $i = $arrayStart;												# Start Looping...
	while($i<=$arrayEnd)
		{
			unless($notes[$i] eq '')
			{
				my @finalEntries = split(/¬/, $notes[$i]);
				@categories = split (/'/, $finalEntries[3]);
				print '<div class="article"><h1>'.$finalEntries[0].' &nbsp; <small><a href="?edit=notes/'.$finalEntries[4].'">'.$locale{$lang}->{e}.'</a> - <a href="?delete=notes/'.$finalEntries[4].'">'.$locale{$lang}->{d}.'</a></small>
				</h1><form accept-charset="UTF-8" name="form1" method="post" style="text-align:right;">
				<input name="title" type="hidden" id="title" value="'.$finalEntries[0].'">
				<input name="content" type="hidden" id="content" value="'.$finalEntries[1].'">
				<input name="category" type="hidden" id="category" value="'.$finalEntries[3].'">
				<input name="isHTML" type="hidden" id="isHTML" value="1">
				<input name="dir" type="hidden" value="/posts"></td>
				<input name="process" type="hidden" id="process" value="doEntry">
				<input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'">
				</form>
				<br /><br />'.$finalEntries[1].'<br /></br><footer>'.$locale{$lang}->{postedon}.$finalEntries[2].' - '.$locale{$lang}->{categories}.': ';
				for (0..$#categories)
				{
					print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
				}
					print '<br /></footer><br /><br /></div>'; 
		}
		$i++;
	}


		if($totalPages >= 1)
	{
		print $locale{$lang}->{pages};
	}

	my $startPage = $page == 1 ? 1 : ($page-1);
	my $displayed = 0;
	for(my $i = $startPage; $i <= (($page-1)+$config_maxPagesDisplayed); $i++)
	{
		if($i <= $totalPages)
		{
			if($page != $i)
			{
				if($i == (($page-1)+$config_maxPagesDisplayed) && (($page-1)+$config_maxPagesDisplayed) < $totalPages)
				{
					print '<a href="'.$do.'&page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="'.$do.'&page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="'.$do.'&page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}
}
print '';
