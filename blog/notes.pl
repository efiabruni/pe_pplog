
my $page = r('page');
my @notes=getFiles($config_DatabaseFolder.'/notes');

if($page eq ''){		my @categories = getCategories();
		#new note
		print '<h1>'.$locale{$lang}->{newnote}.'</h1>';
		if (scalar(@notes) >= 1){print '<a href=?do=notes&page=1 style="float:right;">'.$locale{$lang}->{viewnote}.'</a><br />'; }#view Notes</h1>	
		print'<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<table><tr>
		<td>'.$locale{$lang}->{title}.'</td>
		<td><input name=title type=text id=title></td>
		</tr>';
		
		#Efia added new buttons, took out WYSIWYG option and defined textarea col and rows
		bbcodeButtons();
		
		print '<td><textarea name="content" cols="50" rows="15" id="content"></textarea></td></tr>
		<tr><td>'.$locale{$lang}->{categories}.' <span text="'.$locale{$lang}->{spancat}.'">(?)</span></td><td>';
			
			#Efia html option is a checkbox now, javascript alert for categories
			
		my $i = 1;
		foreach(@categories)
		{
			if($i < scalar(@categories))	# Here we display a comma between categories so is easier to undesrtand
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
		<td>'.$locale{$lang}->{ishtml}.' <span text="'.$locale{$lang}->{spanhtml}.'">(?)</span>
		</td><td><input type="checkbox" name="isHTML" value="1"></td>
		</tr>
		<tr>
		<td><input name="dir" type="hidden" value="/notes"></td>
		<input name="process" type="hidden" id="process" value="newEntry"></td> 
		<td><input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'"></td>
		</tr>
		</table>
		</form>';
		
		
		
 }	

else{
# display notes
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
				my @categories = split (/'/, $finalEntries[3]);
				print '<div class="article"><h1>'.$finalEntries[0].' &nbsp; <small><a href="?edit=notes/'.$finalEntries[4].'">'.$locale{$lang}->{e}.'</a> - <a href="?delete=notes/'.$finalEntries[4].'">'.$locale{$lang}->{d}.'</a></small></h1>
				<form accept-charset="UTF-8" name="form1" method="post" style="display:inline; float:right;">
				<input name="title" type="hidden" id="title" value="'.$finalEntries[0].'">
				<input name="content" type="hidden" id="content" value="'.$finalEntries[1].'">
				<input name="category" type="hidden" id="category" value="'.$finalEntries[3].'">
				<input name="isHTML" type="hidden" id="isHTML" value="1">
				<input name="dir" type="hidden" value="/posts"></td>
				<input name="process" type="hidden" id="process" value="newEntry">
				<input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'">
				</form>
				<div class="hide"><br /><br />'.$finalEntries[1].'<br /></div></br><footer>'.$locale{$lang}->{postedon}.$finalEntries[2].' - '.$locale{$lang}->{categories}.': ';
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
					print '<a href="?do=notes&page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="?do=notes&page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="?do=notes&page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}
print ' ... <a href="?do=notes">'.$locale{$lang}->{newnote}.'</a>'; #New Note
}
#<inputs> title content category</> new Entry button