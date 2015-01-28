# Basic Functions
our $config_serverRoot = $ENV{'DOCUMENT_ROOT'};
our $config_postsDatabaseFolder = "$config_DatabaseFolder/posts";
our $config_commentsDatabaseFolder = "$config_DatabaseFolder/comments";
our $config_dbFilesExtension = 'ppl';	
our @config_pluginsAdmin = split(/,/, $config_adminSettings{plugins});
our @config_pluginsBlog = split(/,/, $config_blogSettings{plugins});
our @keys = keys%config_commentsSecurityQuestion;

#HTML functions are encoded
sub r
{
	escapeHTML(param($_[0]));
}
#No encoding
sub basic_r
{
	param($_[0]);
}

sub apo_r
{
	$_ = shift;
	s/¬/&not;/gi;
	s/'/&#39;/gi;
	return $_;
}

sub getIP #return ip in standard format
{
	my $ip;
	if (defined $ENV{'HTTP_X_FORWARDED_FOR'}){
		$ip = $ENV{'HTTP_X_FORWARDED_FOR'}; 
		$ip =~ s/::ffff:(.*)/$1/;
		}
	else {$ip = $ENV{'REMOTE_ADDR'};}
	return $ip;
}

sub getdate
{
	#my $gmt = $_[0];
	my $var = shift;
	my $day = 1440;
	my $hour =  60;
	my @gmts = split(':',$var); 
	my $gmts1 = $gmts[1];
	$gmts1 = -$gmts1 if $gmts[0]=~ /^(-)/; #to account for -gmts 
	$gmt = $gmts[0]*60+$gmts1; 
	my $date = gmtime;
	my @dat = split(' ', $date);
	my @time = split(':',$dat[3]);
	
	my $minutes=$time[1]+($time[0]*60)+($dat[2]*1440);
	my $value=$minutes+$gmt;
	my @time = ();

	my $d = int($value/$day); push (@time, $d); $value = ($value%$day);
	my $h = int($value/$hour); push (@time, $h); $value = ($value%$hour);
	unless ($value =~ /\d\d/){$value = '0'.$value;}
	push (@time, $value);

	
	return $time[0].' '.$dat[1].' '.$dat[4].', '.$time[1].':'.$time[2];
}

sub array_unique #everything only added once
{
	my %seen = ();
	@_ = grep { ! $seen{ $_ }++ } @_;
}

sub getFiles			# This function returns all files from the db folder 
{
	my $dir=$_[0];
	if(!(opendir(DH, $dir)))
	{
		mkdir($dir, 0755);
	}
	
	my @entriesFiles = (); 		# This one has all files names
	my @entries = (); 			# This one has the content of all files not splitted
	
	foreach(readdir DH)
	{
		unless($_ eq '.' or $_ eq '..' or (!($_ =~ /$config_dbFilesExtension$/)))
		{
			push(@entriesFiles, $_);
		}
	}
	
	@entriesFiles = sort{$b <=> $a}(@entriesFiles);		# Here I order the array in descending order so i show Newest First
	
	foreach(@entriesFiles)
	{
		my $tempContent = '';
		open(FILE, "<".$dir."/$_");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		push(@entries, $tempContent);
	}
	return @entries;
}

sub getCategories		# This function is to get the categories 
{						 
	my @categories = ('General');
	my @tempCategories = ();
	if(-d "$config_postsDatabaseFolder")
	{
		my @entries = getFiles($config_postsDatabaseFolder);
		foreach(@entries)
		{
			my @finalEntries = split(/¬/, $_);
			my @split = split(/'/, $finalEntries[3]);#for if there are more than 1 category
			push(@tempCategories, @split);
		}
		@categories = array_unique(@tempCategories);
	}
	return @categories;		
}

sub getPages #get the pages 
{
	open (FILE, "<$config_postsDatabaseFolder/pages.$config_dbFilesExtension.page");
	my $pagesContent;
	while(<FILE>)
	{
		$pagesContent.=$_;
	}
	close FILE;
	
	my @pages = split(/-/, $pagesContent);
}

#get comments
sub getComments
{
	open(FILE, "<$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
	my $content;
	while(<FILE>)
	{
		$content.=$_;
	}
	close(FILE);
	
	my @comments = split(/'/, $content);	
	@comments = reverse(@comments);			# We want newer first right?
}

#subs for the menu
sub menuMobileSearch
{
	print '<form id="mobile" accept-charset="UTF-8" name="form1" method="post">
	<input type="text" name="keyword">
	<input type="hidden" name="do" value="search">
	<input type="submit" name="Submit" value="'.$locale{$lang}->{search}.'">
	<input name="by" type="hidden" value="1">
	</form> ';
}

sub menuSearch
{
	print '<h1>'.$locale{$lang}->{search}.'</h1>
			<form accept-charset="UTF-8" name="form1" method="post">
			<input type="text" name="keyword" style="width:150px">', # search field 100613 added sc0ttmans UTF-8 fix
			'<input type="hidden" name="do" value="search"><br />
			'.$locale{$lang}->{bytitle}.'<input name="by" type="radio" value="0" checked> '.$locale{$lang}->{bycontent}.'<input name="by" type="radio" value="1">
			</form>';
}
sub menuEntries
{
	print'<h1>'.$locale{$lang}->{entries}.'</h1>';
	#latest entries 
	my @tmpEntries = getFiles($config_postsDatabaseFolder);
	my @entriesOnMenu=();
	my @pages = getPages();
	my $i = 0;

	foreach my $item(@tmpEntries)
		{
			my @split = split(/¬/, $item);
			unless (grep {$_ eq $split[4] } @pages){push(@entriesOnMenu, $item);}
		}

	foreach(@entriesOnMenu)
	{
		if($i <= $config_menuEntriesLimit)
		{
			my @entry = split(/¬/, $_);
			print '<a href="?viewDetailed='.$entry[4].'">'.$entry[0].'</a>';
			$i++;
		}
	}
}
sub menuCategories
{
	print' <h1>'.$locale{$lang}->{categories}.'</h1>';				
	my @categories = sort(getCategories());
	foreach(@categories)
	{
		print '<a href="?viewCat='.$_.'">'.$_.'</a>';
	}
}
sub menuComments
{
		
	my @comments = getComments();
	
	if(scalar(@comments) > 0)
	{
		print '<h1>'.$locale{$lang}->{comments}.'</h1>
		<a href="?do=listComments">'.$locale{$lang}->{listComments}.' »</a>';
	}
	
	my $i = 0;
	
	foreach(@comments)
	{
		if($i <= $config_showLatestCommentsLimit)
		{
			my @entry = split(/"/, $_);
			print '<a href="?viewDetailed='.$entry[4].'#'.$entry[5].'" title="'.$locale{$lang}->{entryby}.' '.$entry[1].'">'.$entry[0].'</a>'; #sc0ttman
			$i++;
		}
	}
}

#sub for contents
sub doPages
{	
	my @tempEntries = @_;
	my $do = shift @tempEntries;
	my $part = shift @tempEntries;
	
	# Pagination - This is the so called Pagination
	my $page = r('page');																# The current page
	if($page eq ''){ $page = 1; }													# Makes page 1 the default page
	my $totalPages = ceil((scalar(@tempEntries))/$config_entriesPerPage);	# How many pages will be?
	# What part of the array should i show in the page?
	my $arrayEnd = ($config_entriesPerPage*$page);									# The array will start from this number
	my $arrayStart = $arrayEnd-($config_entriesPerPage-1);							# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;
	
    my $i = $arrayStart;															# Start Looping...
	while($i<=$arrayEnd)
	{
		unless($tempEntries[$i] eq '')
		{
			my @finalEntries = split(/¬/, $tempEntries[$i]);
			my @categories = split (/'/, $finalEntries[3]);
			
			my $commentsLink;
			my $tmpContent;
			open(FILE, "<$config_commentsDatabaseFolder/$finalEntries[4].$config_dbFilesExtension");
			while(<FILE>){$tmpContent.=$_;}
			close FILE;		
			
			my @comments = split(/'/, $tmpContent);
			if(scalar(@comments) == 0)
				{
					$commentsLink = $locale{$lang}->{nocomment};
				}
			elsif(scalar(@comments) == 1)
				{
					$commentsLink = '1 '.$locale{$lang}->{comment};
				}
			else
				{
					$commentsLink = scalar(@comments).' '.$locale{$lang}->{comments};
				}
					
			if ($part == 1){
				# display the entries for admin pages
				print '<div class="article"><h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a> &nbsp; <small><a href="?edit=posts/'.$finalEntries[4].'">'.$locale{$lang}->{e}.'</a> - <a href="?delete=posts/'.$finalEntries[4].'">'.$locale{$lang}->{d}.'</a></small></h1>
				<a href="?viewDetailed='.$finalEntries[4].'">'.$commentsLink.'</a><br /><br />'.$finalEntries[1].'<br /></br><footer>'.$locale{$lang}->{postedon}.$finalEntries[2].' - '.$locale{$lang}->{categories}.':';
			}
			else{
				#show entries for main blog
				print '<div class="article"><h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a></h1><a href="?viewDetailed='.$finalEntries[4].'">'.$commentsLink.' </a> '.$config_customHTMLpost.'</br>
				'.$finalEntries[1].'<br /><br /><footer id="footer">'.$locale{$lang}->{postedon}.' '.$finalEntries[2].' - '.$locale{$lang}->{categories}.': ';
			}
			for (0..$#categories)
				{
					print ' <a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
				}
					print '<br /></footer><br /><br /></div>'; 
		}
		$i++;
	}
	#Pages
	if ($totalPages >= 1)
	{
		print $locale{$lang}->{pages};
	}
	else
	{
		print '<br />'.$locale{$lang}->{nopages1}.' <a href="?do=newEntry">'.$locale{$lang}->{nopages2}.'</a>?' if $part==1;
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
					print '<a href="'.$do.'page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="'.$do.'page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="'.$do.'page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}

}
sub doNewEntry
{
	# Blog Add New Entry Form
	# 100613 added sc0ttmans UTF-8 fix
		my @categories = getCategories();
		print '<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<legend>'.$locale{$lang}->{new}.'...</legend>
		<p><label for ="title">'.$locale{$lang}->{title}.'</label>
		<input name=title type=text id=title></p>';
		
		bbcodeButtons();
		
		print '<label for"isHTML">'.$locale{$lang}->{ishtml}.' <span text="'.$locale{$lang}->{spanhtml}.'">(?)</span></label>
		<input type="checkbox" name="isHTML" value="1">
		<textarea name="content" id="content"></textarea> 
		<p><label for="category">'.$locale{$lang}->{categories}.' <span text="'.$locale{$lang}->{spancat}.'">(?)</span></label>
		<input name="category" type="text" id="category">';

			if( scalar(@categories) > 0){
			print "<select onChange=\"surroundText(value,'', document.forms.submitform.category );\" ><option selected='selected' disabled='disabled'>...</option>";
		
			foreach(@categories)	# Here we display a comma between categories so is easier to undesrtand
			{
				print '<option  value="'.$_.'\'" >'.$_.'</option>';
			}
		
			print '</select>';
		}
		print '</p>
		<p><label for="isPage">'.$locale{$lang}->{ispage}.' <span text="'.$locale{$lang}->{spanpage}.'">(?)</span></label>
		<input type="checkbox" name="isPage" value="1"></p>
		<p><input name="process" type="hidden" id="process" value="doEntry">
		<input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'">';
		print '<input type="submit" name="Submit" value="'.$locale{$lang}->{newnote}.'">' if grep {$_ eq 'notes'} @config_pluginsAdmin;
		print '</p></form>';
}
sub listComments
{#list all comments
	print '<h1>'.$locale{$lang}->{comments}.'</h1>';
	my @comments = getComments();
	# This is pagination... Again :]
	my $page = r('page');												# The current page
	if($page eq ''){ $page = 1; }										# Makes page 1 the default page (Could be... $page = 1 if $page eq '')
	my $totalPages = ceil((scalar(@comments))/$config_commentsPerPage);	# How many pages will be?
	# What part of the array should i show in the page?
	my $arrayEnd = ($config_commentsPerPage*$page);						# The array will start from this number
	my $arrayStart = $arrayEnd-($config_commentsPerPage-1);				# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;
	my $i = $arrayStart;												# Start Looping...
	if(scalar(@comments) > 0)
	{
		print '<table width="100%"><tr><td><b>'.$locale{$lang}->{comment}.'</b></td><td><b>'.$locale{$lang}->{entryby}.'</b></td><td><b>'.$locale{$lang}->{postunder}.'</b></td></tr>';
	}
	else
	{
		print $locale{$lang}->{nocomments};
	}
	while($i<=$arrayEnd)
	{
		unless($comments[$i] eq '')
		{
			my @finalEntries = split(/"/, $comments[$i]);

			print '<tr><td><a href="?viewDetailed='.$finalEntries[4].'#'.$finalEntries[5].'" title="'.$finalEntries[2].'">'.$finalEntries[0].'</a></td><td>'.$finalEntries[1].'</td><td><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[6].'</a></td></tr>';
			# print comment with anchor and link to post
		}
		$i++;
	}
	# Now i will display the pages
	print '</table>'.$locale{$lang}->{pages} if scalar(@comments) > 0;
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
					print '<a href="?do=listComments&page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="?do=listComments&page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="?do=listComments&page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}
	print '';
}
sub doSearch
{
	# Search Function

	my $keyword = r('keyword');
	my $do = 1;
	
	if(length($keyword) < 4)
	{
		print $locale{$lang}->{keyword};
		$do = 0;
	}
	
	my $by = r('by');							# This can be 0 (by title) or 1 (by id) based on the splitted array
	if(($by != 0) && ($by != 1)){ $by = 0; }	# Just prevention from CURL or something...
	my $sBy = $by == 0 ? $locale{$lang}->{bytitle} : $locale{$lang}->{bycontent};	# This is a shorter way of "my $sBy = ''; if($by == 0) { $sBy = 'Title'; } else { $sBy = 'Content'; }"
	
	if($do == 1)
	{
		print '</br>'.$locale{$lang}->{searchfor}.'"'.$keyword.'" '.$sBy.':<br /><br />';
		my @entries = getFiles($config_postsDatabaseFolder);
		my $matches = 0;
		foreach(@entries)
		
		{
			my @currEntry = split(/¬/, $_);
			if(($currEntry[$by] =~ m/$keyword/i))
			{
				#results
				print '<a href="?viewDetailed='.$currEntry[4].'">'.$currEntry[0].'</a><br />';	
				$matches++;
					
			}
			
		}
		print '<br />'.$matches.$locale{$lang}->{matches};
	}
}
sub doArchive
{# Show blog archive
	
	print '<h1>'.$locale{$lang}->{archive}.'</h1>';
	my @entries = getFiles($config_postsDatabaseFolder);
	print $locale{$lang}->{noentries} if scalar(@entries) == 0;
	# Split the data in the post so i have them in this format "13 Dic 2008, 24:11|0001|Entry title" date|fileName|entryTitle
	my @dates = map { my @stuff = split(/¬/, $_); @stuff[2].'|'.@stuff[4].'|'.@stuff[0]; } @entries; #25.05.13 jamesbond
	my @years;
	foreach(@dates)
	{
		my @date = split(/\|/, $_);
		my @y = split(/\s/, $date[0]);
		$y[2] =~ s/,//;
		if($y[2] =~ /^\d+$/)
		{
			push(@years, $y[2]);
		}
	}
	@years = reverse(sort(array_unique(@years)));
	my $page = r('p');
	if ($page eq ''){$page = 1;}
	my $i = ($page - 1);
	my $totalPages = scalar@years;#a page for each year
	
	if ($years[$i]){
		# Sort months
		print "<h1><small>$years[$i]</small></h1>";
		my @months = qw(Dec Nov Oct Sep Aug Jul Jun May Apr Mar Feb Jan);
		
		for my $actualMonth(@months){ 
			my @entries = grep{/$actualMonth\s$years[$i]/}@dates;
			next if scalar @entries ==0;
			@entries = sort {$a<=>$b}reverse(@entries);
			print '<div class="slide"><a id="flip" href="">'.$locale{$lang}->{$actualMonth}.' ('.scalar @entries.' '.$locale{$lang}->{entries}.') »</a><table class="hide">';
			#print entries lowest to highest
			foreach (@entries){
				my @e = split(/\|/,$_);
				my @d = split(/\s/,$e[0]);
				print '<tr><td style="text-align:right">'.$d[0].'</td><td><a href="?viewDetailed='.$e[1].'">'.$e[2].'</a></td></tr>';
				}
				print "</table></div><br />";
			}
		}

		print '<br />'.$locale{$lang}->{year}.': ';
		$i = 0;
		while ($years[$i]) {
			my $j = ($i+1);
			print '<a href="?do=archive&p='.$j.'">'.$years[$i].'</a> ';#pages
			$i++;
		}			
}

# Javascript for bbcode buttons	
sub javascript 
{
	print <<EOF;
	<script language="javascript" type="text/javascript">
// FUNCTION BY SMF FORUMS http://www.simplemachines.org
function surroundText(text1, text2, textarea)
{
	// Can a text range be created?
	if (typeof(textarea.caretPos) != "undefined" && textarea.createTextRange)
	{
		var caretPos = textarea.caretPos, temp_length = caretPos.text.length;

		caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == \' \' ? text1 + caretPos.text + text2 + \' \' : text1 + caretPos.text + text2;

		if (temp_length == 0)
		{
			caretPos.moveStart("character", -text2.length);
			caretPos.moveEnd("character", -text2.length);
			caretPos.select();
		}
		else
			textarea.focus(caretPos);
	}
	// Mozilla text range wrap.
	else if (typeof(textarea.selectionStart) != "undefined")
	{
		var begin = textarea.value.substr(0, textarea.selectionStart);
		var selection = textarea.value.substr(textarea.selectionStart, textarea.selectionEnd - textarea.selectionStart);
		var end = textarea.value.substr(textarea.selectionEnd);
		var newCursorPos = textarea.selectionStart;
		var scrollPos = textarea.scrollTop;

		textarea.value = begin + text1 + selection + text2 + end;

		if (textarea.setSelectionRange)
		{
			if (selection.length == 0)
				textarea.setSelectionRange(newCursorPos + text1.length, newCursorPos + text1.length);
			else
				textarea.setSelectionRange(newCursorPos, newCursorPos + text1.length + selection.length + text2.length);
			textarea.focus();
		}
		textarea.scrollTop = scrollPos;
	}
	// Just put them on the end, then.
	else
	{
		textarea.value += text1 + text2;
		textarea.focus(textarea.value.length - 1);
	}
}
</script>
EOF
}

#JQuery functions
sub JQuery
{
	print q \
	<script src="https://code.jquery.com/jquery-1.9.1.min.js"></script> 
	 <script> $(document).ready(function(){$(".hide").hide();
     $(".slide #flip").click(function(event){
	 $(this).next(".hide").toggle("slow"); 
		event.preventDefault(); });
	$("#mobile").click(function(event){$("header div, form#mobile").slideToggle("slow");
		event.preventDefault(); });
	$("[name='isHTML']").click(function(){
		if($("[name='isHTML']").is(":checked"))
		{
			$(".screen").hide(); 
		}
		else
		{
			if ($(window).width()>=550){
				$(".screen").show(); 
			}
		}
		});
	});</script>\;
}	


return 1;