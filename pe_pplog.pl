#!/usr/bin/perl -U

#####################################################################
# 	pe_pplog (pretty easy pplog) v.2a								#
#	The idea of this blog, is to add the versatility of JQuery to	#
#	the simplicity of the original PPLOG, creating a modern looking	#
#	blog which is easliy customised									#
#																	#
#	Based on PPlog Version: 1.1b Coded by Federico Ramírez (fedekun)#
#	The changelog can be found in the included changelog.txt and	#
#	changes have been commented in the code with "efia" 			#
#																	#
#	pe_pplog and PPLOG use the GNU Public Licence v3				#
#	http://www.opensource.org/licenses/gpl-3.0.html					#
#																	#
#	For comments, questions, love letters and law suit threads 		#
#	contact svala.3@gmail.com										#
#																	#
#	Version: 2.1b  December 3rd, 2013  Christina Milcher (efia)		#
#####################################################################

#BK 8jul09 patch from fedekun, blog writes zero-byte file if leave title off a post.
#BK 8jul09 removed 'onclick="javascript:this.disabled=true"' from all submit forms, doesn't work with opera and ie...
#sc0ttman 02mar13 added anchor tags to all comments 

#This is the main page of the blog
use CGI::Carp qw/fatalsToBrowser/;	# This is optional
use CGI':all';
use POSIX qw(ceil floor);
use POSIX qw/strftime/; #sc0ttman
						
do "./blog/pe_Config.pl" or (require "./blog/pe_Config.pl.bak"); #change the path to the /blog folder on your computer
require "$config_DatabaseFolder/sub.pl"; 

if(r('do') eq 'RSS')
{
	my @baseUrl = split(/\?/, 'http://'.$ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'});
	my $base = $baseUrl[0];
	my @entries = getFiles($config_postsDatabaseFolder);
	my $limit;
	
	print header(-charset => qw(utf-8)), '<?xml version="1.0" encoding="UTF-8"?>
	<rss version="2.0">
	<channel>
	<title>'.$config_blogTitle.'</title>
	<description>'.$config_metaDescription.'</description>
	<link>http://'.$ENV{'HTTP_HOST'}.substr($ENV{'REQUEST_URI'},0,length($ENV{'REQUEST_URI'})-7).'</link>';
	
	if($config_entriesOnRSS == 0)
	{
		$limit = scalar(@entries);
	}
	else
	{
		$limit = $config_entriesOnRSS;
	}
	
	for(my $i = 0; $i < $limit; $i++)
	{
		my @finalEntries = split(/¬/, $entries[$i]);
		my $content = $finalEntries[1];
		$content =~ s/\</&lt;/gi;
		$content =~ s/\>/&gt;/gi;
		print '<item>
		<link>'.$base.'?viewDetailed='.$finalEntries[4].'</link>
		<title>'.$finalEntries[0].'</title>
		<category>'.$finalEntries[3].'</category>
		<description>'.$content.'</description>
		</item>';
	}
	
	print '</channel>
	</rss>';
}



else
{
print header(-charset => qw(utf-8)),'<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<meta name="Name" content="'.$config_blogTitle.'" />
<meta name="Robots" content="'.$config_metaRobots.'" />
<meta name="Keywords" content="'.$config_metaKeywords.'" />
<meta name="Description" content="'.$config_metaDescription.'" />
<meta name="Viewport" content="width=device-width, initial-scale=1.0, maximum-scale=2.0, user-scaleable=yes"/>
<title>'.$config_blogTitle.' - '.$locale{$lang}->{powered}.'</title>';

if($config_enableJQuery == 1)	

{
	JQuery();
	print $config_customHTMLhead; 

}

# Efia as entry and edit page is moved this becomes optional
if ($config_bbCodeOnCommentaries == 1)
{
	javascript();
}
#second stylesheet for mobile devices 05.06.13
print '<link href='.$config_currentStyleFolder.'/'.$config_currentStyleSheet.' rel=stylesheet type=text/css media="Screen, print">
<link href='.$config_currentStyleFolder.'/mobile.css rel=stylesheet type=text/css media="only screen and (max-width: 550px), only screen and (max-device-width: 480px)">
</head>
<body><header><div id="header"><a href="/pe_pplog/pe_admin.pl"> '.$locale{$lang}->{admin}.'</a></div>
<h1 id="header">'.$config_blogHeader.'</h1><a id="mobile" href="">'.$locale{$lang}->{menu}.'</a>
<div id="header"><ul class="menu"><li><a href=?page=1>'.$locale{$lang}->{index}.'</a></li></ul> ';
#Plugin menu entry 24.05.13 and drop down menu 5.06.13
foreach(@config_pluginsBlog) 
{
	print '<ul class="menu"><li><a href="?do='.$_.'">'.$locale{$lang}->{$_}.'</a></li></ul>'; #16.05
}
my @pages = getPages();

if(scalar(@pages) > 0)
{
	print '<ul class="menu"><li><a class="menu" href="#">'.$locale{$lang}->{pag}.' »</a><ul class="drop">';
	foreach(@pages)
	{
		my $fileName = $_;
		my $content;
		open(FILE, "<$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$content.=$_;
		}
		close FILE;
		my @data = split(/¬/, $content);
		my $title = $data[0];
		print '<li><a href="?viewDetailed='.$fileName.'">'.$title.'</a></li>';
	}
	print'</ul></li></ul>';
}
# 100613 added sc0ttmans UTF-8 fix		
print '<ul class="menu"><li><a href=?do=archive>'.$locale{$lang}->{archive}.'</a></li></ul>
<form id="mobile" accept-charset="UTF-8" name="form1" method="post" style=" text-align:center; margin-left:1%; width:98%">
<input type="text" name="keyword">
<input type="hidden" name="do" value="search">
<input type="submit" name="Submit" value="'.$locale{$lang}->{search}.'"><br />
'.$locale{$lang}->{bytitle}.' <input name="by" type="radio" value="0" checked> '.$locale{$lang}->{bycontent}.' <input name="by" type="radio" value="1">
</form>
<ul class="menu"><li><a href="?do=RSS">'.$locale{$lang}->{rss}.'</a></li></ul></div></header>
<nav>'
#THIS IS THE SIDEBAR MENU 
#Custom html in menu top
.$config_customMenuHTMLtop. 
#search 
'<h1>'.$locale{$lang}->{search}.'</h1>
<form accept-charset="UTF-8" name="form1" method="post">
<input type="text" name="keyword" style="width:150px">', 
'<input type="hidden" name="do" value="search"><br />
'.$locale{$lang}->{bytitle}.' <input name="by" type="radio" value="0" checked> '.$locale{$lang}->{bycontent}.' <input name="by" type="radio" value="1">
</form>
<h1>'.$locale{$lang}->{categories}.'</h1>';			# Show Categories on Menu	
my @categories = sort(getCategories());
foreach(@categories)
{
	print '<a href="?viewCat='.$_.'">'.$_.'</a>';
}

print '<h1>'.$locale{$lang}->{entries}.'</h1>';	# Show Entries in Menu

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

if($config_showLatestComments == 1)
{
	# Latest comments on the menu
		
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

	# Display Custom HTML in the bottom of menu
	
print $config_customMenuHTMLbottom;

# Show Some Links Defined on the Configuration
if(@config_menuLinks > 0)
{
	print '<h1>'.$locale{$lang}->{links}.'</h1>';
	foreach(@config_menuLinks)
	{
		my @link = split(/,/, $_);
		print '<a href="'.$link[0].'">'.$link[1].'</a>';
	}
}
#Site statistics
if(($config_showUsersOnline == 1) || ($config_showHits == 1))
{
	print '<h1>'.$locale{$lang}->{stats}.'</h1>';
}

if($config_showUsersOnline == 1)
{
	# Show users online
	
	my $remote = getIP();
	my $timestamp = time();
	my $timeout = ($timestamp-$config_usersOnlineTimeout);
	
	if((-s "$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo") > (1024*5))		# If its bigger than 0.5 MB, truncate the file and start again
	{
		open(FILE, "+>$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo");
	}
	else
	{
		open(FILE, ">>$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo");
	}
	
	print FILE $remote."||".$timestamp."\n";
	close FILE;
	my @online_array = ();
	my $content;
	open(FILE, "<$config_postsDatabaseFolder/online.$config_dbFilesExtension.uo");
	while(<FILE>)
	{
		$content.=$_;
	}
	close FILE;
	
	my @l = split(/\n/, $content);
	foreach(@l)
	{
		my @f = split(/\|\|/, $_);
		my $ip = $f[0];
		my $time = $f[1];
		if($time >= $timeout)
		{
			push(@online_array, $ip);
		}
	}
	@online_array = array_unique(@online_array);
	print $locale{$lang}->{users}.scalar(@online_array).'<br />';
}

if($config_showHits == 1)
{
	# Display Hits
	
	# Check hits
	open(FILE, "<$config_postsDatabaseFolder/hits.$config_dbFilesExtension.hits");
	my $content;
	while(<FILE>)
	{
		$content.=$_;
	}
	close FILE;
			
	# Add hits
	open(FILE, ">$config_postsDatabaseFolder/hits.$config_dbFilesExtension.hits");
	print FILE ++$content;
	close FILE;
	
	print ''.$locale{$lang}->{hits}.$content;
}

print '</nav>';

#content
print '<div id="content">';

#end here for banned people
foreach(@config_ipBan)
{
	my $ip = getIP();
	if($ip eq $_)
	{
		die ($locale{$lang}->{ban});
	}
}

# Start with GETS and POSTS		

if(r('viewCat') ne '')
{
	# Blog Category Display
	
	my $cat = r('viewCat');
	my @entries = getFiles($config_postsDatabaseFolder);
	my @thisCategoryEntries = ();
	foreach my $item(@entries)
	{
		my @split = split(/¬/, $item);											# [0] = Title	[1] = Content	[2] = Date	[3] = Category
		my @nextsplit = split(/'/,$split[3]);									# split if more than one category
		if (grep { $_ eq $cat } @nextsplit)
		{
		push(@thisCategoryEntries, $item);
		}
	}
	
	# Pagination - This is the so called Pagination
	my $page = r('p');																# The current page
	if($page eq ''){ $page = 1; }													# Makes page 1 the default page
	my $totalPages = ceil((scalar(@thisCategoryEntries))/$config_entriesPerPage);	# How many pages will be?
	# What part of the array should i show in the page?
	my $arrayEnd = ($config_entriesPerPage*$page);									# The array will start from this number
	my $arrayStart = $arrayEnd-($config_entriesPerPage-1);							# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;

	my $i = $arrayStart;															# Start Looping...
	while($i<=$arrayEnd)
	{
		unless($thisCategoryEntries[$i] eq '')
		{
			my @finalEntries = split(/¬/, $thisCategoryEntries[$i]);
			my @categories = split (/'/, $finalEntries[3]);

			#show entries with slide effect
			print '<div class="article"><h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a></h1><div class="hide"><a href="?viewDetailed='.$finalEntries[4].'">'.$locale{$lang}->{comments}.' </a> '.$config_customHTMLpost.'</br>
			'.$finalEntries[1].'<br /><br /></div><footer>'.$locale{$lang}->{postedon}.' '.$finalEntries[2].' - '.$locale{$lang}->{categories}.': ';
			for (0..$#categories){
				print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
			}
			print '<br /></footer><br /><br /></div>'; 
		}
		$i++;
	}
	# Now i will display the pages
	if($totalPages >= 1)
	{
		print $locale{$lang}->{pages};
	}
	else
	{
		print $locale{$lang}->{nocategory};
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
					print '<a href="?viewCat='.$cat.'&p='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="?viewCat='.$cat.'&p='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="?viewCat='.$cat.'&p='.$i.'">['.$i.']</a> ';
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

#search
elsif(r('do') eq 'search')
{
	doSearch(); 
}
elsif (r('Submit') eq $locale{$lang}->{preview})
{
	my $title = r('title');
	my $author = r('author');
	my $content = r('content');
	my $postTitle = r('postTitle');
	my $fileName = r('sendComment');
	my $date = getdate($config_gmt);
	my $originalCode =r('originalCode');
	my $code = r('code');
	my $question = r('question');
	my $pass = r('pass');
	
	print '<b>'.$title.'</b> &nbsp; '.$locale{$lang}->{postedon}.' <b>'.$date.'</b> '.$locale{$lang}->{by}.' <b>'.$author.'</b><br />';
	print bbcode($content); 
	
	print '<br /><br /><h1>'.$locale{$lang}->{addcomment}.'</h1>
			<form accept-charset="UTF-8" name="submitform" method="post">
			<table>
			<tr>
			<td>'.$locale{$lang}->{title}.'</td>
			<td><input name="title" type="text" id="title" value="'.$title.'"></td>
			</tr>
			<tr>
			<td>'.$locale{$lang}->{author}.'</td>
			<td><input name="author" type="text" id="author" value="'.$author.'"></td>
			</tr>';
		
		#bbcode buttons if allowed
		if ($config_bbCodeOnCommentaries == 1)
		{
			bbcodeComments();
		}
		else
		{
		print'<tr><td>&nbsp;</td>';
		}
	print '<td><textarea name="content" id="content" cols="50" rows="10">'.$content.'</textarea></td>
			</tr>';
			
			if($config_commentsSecurityCode == 1)
			{

				print '<tr><td>'.$locale{$lang}->{code}.'</td>
				<td>'.$originalCode.'<input name="originalCode" value="'.$originalCode.'" type="hidden" id="originalCode"></td>
				</tr><tr>
				<td></td>
				<td><input name="code" type="text" id="code" value="'.$code.'"></td>
				</tr>';
			}
			
			print '<tr>
			<td>'.$config_commentsSecurityQuestion.'</td>
			<td><input name="question" type="text" id="question" value="'.$question.'"></td>
			</tr>
			<tr>' if $config_securityQuestionOnComments == 1;
			
			print '<tr>
			<td>'.$locale{$lang}->{password}.' <span text="'.$locale{$lang}->{spancom}.'">(?)</span></td>
			<td><input name="pass" type="password" id="pass" value="'.$pass.'"></td>
			</tr>
			<tr>
			<td><input name="postTitle" value="'.$postTitle.'" type="hidden" id="postTitle">
			<input name="sendComment" value="'.$fileName.'" type="hidden" id="sendComment"></td>
			<td><input type="submit" name="Submit" value="'.$locale{$lang}->{preview}.'"><input type="submit" name="Submit" value="'.$locale{$lang}->{addcomment}.'">
			</td>
			</tr>
			</table>
			</form>';
}

#view detailed and send comment
elsif(r('viewDetailed') ne '' || r('sendComment') ne '')
{	
	my $fileName = r('viewDetailed');
	my $do = 1;
	my $content;
	
	if(r('sendComment') ne '')
	{
	# Send Comment Process
	
	   $fileName = r('sendComment');
	my $posttitle = r('postTitle'); 
	my $title = r('title');
	my $author = r('author');
	   $content = bbcode(r('content'));
	my $pass = r('pass');
	my $date = getdate($config_gmt);
	my $anchor = strftime "%Y%m%d%H%M%S", localtime; #sc0ttman anchor
	my $triedAsAdmin = 0;
	
	if($title eq '' || $author eq '' || $content eq '' || $pass eq '')
	{
		print '<br />'.$locale{$lang}->{necessary};
		$do = 0;
	}
	 #check captcha if indicated
	if($config_commentsSecurityCode == 1)
	{
		my $code = r('code');
		my $originalCode = r('originalCode');
		
		unless($code eq $originalCode)
		{
			print '<br />'.$locale{$lang}->{captcha};
			$do = 0;
		}
	}
	#check security question if indicated
	if($config_securityQuestionOnComments == 1)
	{
		my $question = r('question');
		unless(lc($question) eq lc($config_commentsSecurityAnswer))
		{
			print '<br />'.$locale{$lang}->{question};
			$do = 0;
		}
	}
	
	my $hasPosted = 0;					# This is to see if the user has posted already, so we add him/her to the database :]
	
	foreach(@config_commentsForbiddenAuthors)
	{
		if($_ eq $author)
		{
			unless($pass eq $config_adminPass)		# Prevent users from using nicks like "admin"
			{
				$do = 0;
				print '<br />'.$locale{$lang}->{compass};
			}
			# Efia admin used to be added to the database
			$hasPosted = 1;
			$triedAsAdmin = 1;
		}
	}
	
	# Start of author checking, for identity security
	open(FILE, "<$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
	my $data = '';
	while(<FILE>)
	{
		$data.=$_;
	}
	close(FILE);
	
	if($triedAsAdmin == 0)
	{
		my @users = split(/"/, $data);
		foreach(@users)
		{
			my @data = split(/'/, $_);
			if($author eq $data[0])
			{
				$hasPosted = 1;
				if(crypt($pass, $config_randomString) ne $data[1])
				{
					$do = 0;
					print '<br />'.$locale{$lang}->{compass};
				}
				last;
			}
		}
	}
	
	if($hasPosted == 0)
	{
		open(FILE, ">>$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
		print FILE $author."'".crypt($pass, $config_randomString).'"';#encrypt password
		close FILE;
		print '<br />'.$locale{$lang}->{newuser};
	}
	# End of author checking, start adding comment
	
	if($do == 1)
	{	

			if(length($content) > $config_commentsMaxLenght)
			{
				print '<br />'.$locale{$lang}->{toolong1}.$config_commentsMaxLenght.$locale{$lang}->{toolong2}.length($content);
			}
			else
			{
	           my $comment = $title.'"'.$author.'"'.$content.'"'.$date.'"'.$fileName.'"'.$anchor.'"'.$posttitle."'";; #sc0ttman 
				
				# Add comment
				open(FILE, ">>$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
				print FILE $comment;
				close FILE;
				
				# Add comment number to a file with latest comments				
				open(FILE, ">>$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
				print FILE $comment;
				close FILE;
				
				print '</br>'.$locale{$lang}->{commentadd}.$author.'! <a href="?viewDetailed='.$fileName.'#'.$anchor.'">View Comment</a>';
				
				# If Comment Send Mail is active
				if($config_sendMailWithNewComment == 1)
				{
					open (MAIL,"|$config_sendMailWithNewCommentMail[0]");
					print MAIL "To: $config_sendMailWithNewCommentMail[1] \n";
					print MAIL "From: PPLOG \n";
					print MAIL "Subject: $locale{$lang}->{subject}\n\n";
					print MAIL "$locale{$lang}->{mail} $author \n $title \n $content";
					close(MAIL);
				}
		}
	}
}

	# Display Individual Entry
	$do = 1;
	
	unless(-e "$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension")
	{
		print '</br>'.$locale{$lang}->{noentry};
		$do = 0;
	}
	
	# First Display Entry
	if($do == 1)		# Checks if the file exists before doing all this
	{
		my $tempContent;
		open(FILE, "<$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		my @entry = split(/¬/, $tempContent);
		my @categories = split (/'/, $entry[3]);
		my $postTitle = $entry[0];

		#display the entry
		print '<h1><a href="?viewDetailed='.$entry[4].'">'.$entry[0].'</a></h1>'.$config_customHTMLpost.'</br>'.$entry[1].'<br /><br /><footer>'.$locale{$lang}->{postedon}.$entry[2].' - '.$locale{$lang}->{categories}.': ';
		for (0..$#categories){
					print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';  
				} 
		print '</footer><br /><br />';  
		
		# Now Display Comments
		unless(-d $config_commentsDatabaseFolder)		# Does the comments folder exists? We will save comments there...
		{
			mkdir($config_commentsDatabaseFolder, 0755);
		}
	
		my $content = '';
		open(FILE, "<$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$content.=$_;
		}
		close FILE;
		
		if($content eq '')
		{
			print $locale{$lang}->{nocomments};
		}
		else
		{
			print '<h1>'.$locale{$lang}->{comments}.':</h1>';
			
			my @comments = split(/'/, $content);
				
		
			@comments = reverse(@comments); # newest first by default
		
	
			my $i = 0;
			foreach(@comments)
			{
				my @comment = split(/"/, $_);
				# $title = $comment[0]; $author = $comment[1]; $content = $comment[2]; $date = $comment[3]; $anchor = $comment[5]; 
				#sc0ttman anchor for comments
                print '<a id="anchor" name="'.$comment[5].'"></a><b>'.$comment[0].'</b> &nbsp; '.$locale{$lang}->{postedon}.' <b>'.$comment[3].'</b> '.$locale{$lang}->{by}.' <b>'.$comment[1].'</b><br />'; #020313 
				print $comment[2];
				
				print '<br /><br />';
			}
		}
		# Add comment form
		if($config_allowComments == 1)
		{
			# 100613 added sc0ttmans UTF-8 fix
			print '<br /><br /><h1>'.$locale{$lang}->{addcomment}.'</h1>
			<form accept-charset="UTF-8" name="submitform" method="post">
			<table>
			<tr>
			<td>'.$locale{$lang}->{title}.'</td>
			<td><input name="title" type="text" id="title"></td>
			</tr>
			<tr>
			<td>'.$locale{$lang}->{author}.'</td>
			<td><input name="author" type="text" id="author"></td>
			</tr>';
		
		#bbcode buttons if allowed
		if ($config_bbCodeOnCommentaries == 1)
		{
			bbcodeComments();
		}
		else
		{
		print'<tr><td>&nbsp;</td>';
		}
	print '<td><textarea name="content" id="content" cols="50" rows="10"></textarea></td>
			</tr>';
			
			if($config_commentsSecurityCode == 1)
			{
				my $code = '';
	
				$code = uc(substr(crypt(rand(999999), $config_randomString),1,8));
	
				$code =~ s/\.//;
				$code =~ s/\///;
				print '<tr><td>'.$locale{$lang}->{code}.'</td>
				<td>'.$code.'<input name="originalCode" value="'.$code.'" type="hidden" id="originalCode"></td>
				</tr>
				<tr>
				<td></td>
				<td><input name="code" type="text" id="code"></td>
				</tr>';
			}
			
			print '<tr>
			<td>'.$config_commentsSecurityQuestion.'</td>
			<td><input name="question" type="text" id="question"></td>
			</tr>
			<tr>' if $config_securityQuestionOnComments == 1;
			
			print '<tr>
			<td>'.$locale{$lang}->{password}.' <span text="'.$locale{$lang}->{spancom}.'">(?)</span></td>
			<td><input name="pass" type="password" id="pass"></td>
			</tr>
			<tr>
			<td><input name="postTitle" value="'.$postTitle.'" type="hidden" id="postTitle">
			<input name="sendComment" value="'.$fileName.'" type="hidden" id="sendComment">
			</td>
			<td><input type="submit" name="Submit" value="'.$locale{$lang}->{preview}.'">
			<input type="submit" name="Submit" value="'.$locale{$lang}->{addcomment}.'">
			</td>
			</tr>
			</table>
			</form>';
		}
	}
}

#archive
elsif(r('do') eq 'archive')
{
	doArchive();
}
#list comments		
elsif(r('do') eq 'listComments')
{
	listComments();
}
#bbcode help
elsif (r('BbcodeHelp') ne '')
{
	BbcodeHelp();
}

elsif (grep {$_ eq r('do') } @config_pluginsBlog) #24.05.13 plugin section
{
	my $plugin = r('do');
	do "$config_DatabaseFolder/$plugin.pl" or print '<br />'.$locale{$lang}->{noplugin}.' <a href="?page=1">'.$locale{$lang}->{back}.'</a>';
}
#processes for plugin
elsif (grep {$_ eq r('process') } @config_pluginsBlog)
{
	my $plugin = r('process');
	do "$config_DatabaseFolder/$plugin.pl" or print '<br />'.$locale{$lang}->{noplugin}.' <a href="?page=1">'.$locale{$lang}->{back}.'</a>';
}

else
{
	# Blog Main Page
	my @tmpEntries = getFiles($config_postsDatabaseFolder);
	my @entries=();
	my @pages = getPages();
	foreach my $item(@tmpEntries)
		{
			my @split = split(/¬/, $item);
			unless (grep {$_ eq $split[4] } @pages){push(@entries, $item);}
		}
		
	if(scalar(@entries) != 0)
	{
		# Pagination - This is the so called Pagination
		my $page = r('page');												# The current page
		if($page eq ''){ $page = 1; }										# Makes page 1 the default page
		my $totalPages = ceil((scalar(@entries))/$config_entriesPerPage);	# How many pages will be?
		# What part of the array should i show in the page?
		my $arrayEnd = ($config_entriesPerPage*$page);						# The array will start from this number
		my $arrayStart = $arrayEnd-($config_entriesPerPage-1);				# And loop till this number
		# As arrays start from 0, i will lower 1 to these values
		$arrayEnd--;
		$arrayStart--;

		my $i = $arrayStart;												# Start Looping...
		while($i<=$arrayEnd)
		{
			unless($entries[$i] eq '')
			{
				#check for pages
				my @finalEntries = split(/¬/, $entries[$i]);
				my @categories = split (/'/, $finalEntries[3]);

				# This is for displaying how many comments are posted on that entry
				my $commentsLink;
				my $content;
				open(FILE, "<$config_commentsDatabaseFolder/$finalEntries[4].$config_dbFilesExtension");
				while(<FILE>){$content.=$_;}
				close FILE;
					
				my @comments = split(/'/, $content);
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
					$commentsLink = scalar(@comments).$locale{$lang}->{comments};
				}
				#print entry
				print '<h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a></h1><a href="?viewDetailed='.$finalEntries[4].'">'.$commentsLink.'</a> '.$config_customHTMLpost.'</br>'.$finalEntries[1].'<br /><br /><footer>'.$locale{$lang}->{postedon}.$finalEntries[2].' - '.$locale{$lang}->{categories}.': ';
				for (0..$#categories){
				print '<a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
				}
				print '</footer><br /><br />'; 
			}
		$i++;
		}
		# Now i will display the pages
		print $locale{$lang}->{pages};
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
						print '<a href="?page='.$i.'">['.$i.']</a> ...';
					}
					elsif($startPage > 1 && $displayed == 0)
					{
						print '... <a href="?page='.$i.'">['.$i.']</a> ';
						$displayed = 1;
					}
					else
					{
						print '<a href="?page='.$i.'">['.$i.']</a> ';
					}
				}
				else
				{
					print '['.$i.'] ';
				}
			}
		}
		
	}
	else
	{
		print $locale{$lang}->{noentries};
	}
}
#footer
print '</div><footer id="footer">'.$config_blogFooter.'</footer></div></body></html>';
}
#done!

