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
<body><header>
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
print '<ul class="menu"><li><a href=?do=archive>'.$locale{$lang}->{archive}.'</a></li></ul>';
menuMobileSearch();
print '<ul class="menu"><li><a href="?do=RSS">'.$locale{$lang}->{rss}.'</a></li></ul></div></header>
<div id="content">';#content

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
	my $do = '?viewCat='.$cat.'&';
	my $part = 0;
	
	if (scalar(@entries) == 0){print $locale{$lang}->{nopages1};}

	else{
		foreach my $item(@entries)
		{
			my @split = split(/¬/, $item);											# [0] = Title	[1] = Content	[2] = Date	[3] = Category
			my @nextsplit = split(/'/,$split[3]);									# split if more than one category
			if (grep { $_ eq $cat } @nextsplit)
			{
			push(@thisCategoryEntries, $item);
			}
		}
		doPages($do, $part, @thisCategoryEntries);
	}
}

#search
elsif(r('do') eq 'search')
{
	doSearch(); 
}

#view detailed and send comment
elsif(r('viewDetailed') ne '')
{	
	my $fileName = r('viewDetailed');
	my $do = 1;
	my $tempContent;

# Display Individual Entry 
	unless(-e "$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension")
	{
		print '</br>'.$locale{$lang}->{noentry};
		last;
	}
 
# First Display Entry
	open(FILE, "<$config_postsDatabaseFolder/$fileName.$config_dbFilesExtension");
	while(<FILE>)
	{
		$tempContent.=$_;
	}
	close FILE;

	my @entry = split(/¬/, $tempContent);
	my @categories = split (/'/, $entry[3]);

	#display the entry
	print '<h1>'.$entry[0].'</h1><div class="full">'.$config_customHTMLpost.'</br>'.$entry[1].'<br /><br /><footer id="footer">'.$locale{$lang}->{postedon}.$entry[2].' - '.$locale{$lang}->{categories}.': ';
	for (0..$#categories){
		print ' <a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';
	}
	print '</footer></div>';
	
	# Now Display Comments
	unless(-d $config_commentsDatabaseFolder)	# Does the comments folder exists? We will save comments there...
	{
		mkdir($config_commentsDatabaseFolder, 0755);
	}
 
	undef $tempContent;
	open(FILE, "<$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
	while(<FILE>)
	{
		$tempContent.=$_;
	}
	close FILE;
 
	if($tempContent eq '')
	{
		print $locale{$lang}->{nocomments};
	}
	else
	{
		print '<h1>'.$locale{$lang}->{comments}.':</h1>';
 
		my @comments = split(/'/, $tempContent);
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
	if($config_allowComments == 1)
	{
	my $postTitle = apo_r(r('postTitle'));
	my $comTitle = apo_r(r('comTitle'));
	my $author = apo_r(r('author'));
	my $comContent = apo_r(r('comContent'));
	my $pass = r('pass');
	my $question = r('question');
	my $date = getdate($config_gmt);
	my $anchor = strftime "%Y%m%d%H%M%S", localtime; #sc0ttman anchor
	my $triedAsAdmin = 0;
	my $check=$comTitle.'"'.$author.'"'.$comContent.'"';

			
	if(r('process') eq 'doComment')
	{
		# Send Comment Process
		open (FILE, "<$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
		while (<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
			
		#check if the comment already exists
		if ($tempContent=~ /$check/)
		{
			print '<br /><a id="anchor" name="preview">'.$locale{$lang}->{comtwice};
		}
		
		elsif(length($comContent) > $config_commentsMaxLenght)
		{
		print '<br /><a id="anchor" name="preview">'.$locale{$lang}->{toolong1}.$config_commentsMaxLenght.$locale{$lang}->{toolong2}.length($comContent);
		}
		
		else{
			if (r('Submit') eq $locale{$lang}->{preview}){
				#print comment preview as html
				print '<br /><b>Preview:</b> <a id="anchor" name="preview"></a><b>'.$comTitle.'</b> &nbsp; '.$locale{$lang}->{postedon}.' <b>'.$date.'</b> '.$locale{$lang}->{by}.' <b>'.$author.'</b><br />'.$comContent; 
				
			}
			
			else 
			{
				
				my $code = r('code');
				my $originalCode = r('originalCode');
				my $hasPosted = 0;	# This is to see if the user has posted already, so we add him/her to the database :]
				
				if($comTitle eq '' || $author eq '' || $comContent eq '' || $pass eq '')
				{
					print '<br /><a id="anchor" name="preview"></a>'.$locale{$lang}->{necessary};
				}

				#check captcha if indicated
				elsif($config_commentsSecurityCode == 1 && $code ne $originalCode)
				{
					print '<br /><a id="anchor" name="preview"></a>'.$locale{$lang}->{captcha};
				}
				
				#check security question if indicated
				elsif($config_securityQuestionOnComments == 1 && lc($question) ne lc($config_commentsSecurityAnswer))
				{
					print '<br /><a id="anchor" name="preview"></a>'.$locale{$lang}->{question};
				}
				
				else
				{	# Start of author checking, for identity security
					if (grep{$_ eq $author} @config_commentsForbiddenAuthors){
					if($pass ne $config_adminPass)
					{
						$do=0;
					}
				}
				
				else{	
					undef $tempContent;
					open(FILE, "<$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
					while(<FILE>)
					{
						$tempContent.=$_;
					}
					close(FILE);
					my @users = split(/"/, $tempContent);
					#this is not particularly elegant
					foreach(@users)
					{
						my @data = split(/'/, $_);
						if($author eq $data[0])
						{
							$hasPosted = 1;
							if(crypt($pass, $config_randomString) ne $data[1])
							{
								$do = 0;
							}
							last;	
						}
					}
					
					if($hasPosted == 0)
					{
						open(FILE, ">>$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
						print FILE $author."'".crypt($pass, $config_randomString).'"';#encrypt password
						close FILE;
						print '<br /><a id="anchor" name="preview"></a>'.$locale{$lang}->{newuser};
					}
				}
				
				# End of author checking, start adding comment
				if($do == 1)
				{	
					my $comment = $comTitle.'"'.$author.'"'.$comContent.'"'.$date.'"'.$fileName.'"'.$anchor.'"'.$postTitle."'"; #sc0ttman
					# Add comment
					open(FILE, ">>$config_commentsDatabaseFolder/$fileName.$config_dbFilesExtension");
					print FILE $comment;
					close FILE;
					# Add comment number to a file with latest comments
					open(FILE, ">>$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
					print FILE $comment;
					close FILE;
					
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
					print "<meta http-equiv='refresh' content='1;url=$ENV{SCRIPT_URI}?viewDetailed=$fileName#$anchor'>";	
				}
				else 
				{
					print '<br /><a id="anchor" name="preview"></a>'.$locale{$lang}->{compass};
				}
			}
		}
		
	}
}		
 
	# Add comment form

		# 100613 added sc0ttmans UTF-8 fix
		$comContent=r('comContent');
		$originalQuestion=$keys[rand @keys];
		print '<br /><br />
		<form accept-charset="UTF-8" name="submitform" method="post" action="'.$ENV{SCRIPT_URL}.'#preview">
		<legend>'.$locale{$lang}->{addcomment}.'</legend>
		<p><label for="comTitle">'.$locale{$lang}->{title}.'</label>
		<input name="comTitle" type="text" id="comTitle" value="'.$comTitle.'"></p>
		<p class="comment"><label for="commment">'.$locale{$lang}->{pot}.'</label>
		<input name="comment" type="text" id="comment" ></p>
		<p><label for="author">'.$locale{$lang}->{author}.'</label>
		<input name="author" type="text" id="author" value="'.$author.'"></p>
		<textarea name="comContent" id="comContent">'.$comContent.'</textarea>';
		
		print '<p><label for="question"><input name="originalQuestion" value="'.$originalQuestion.'" type="hidden" id="originalQuestion">
		'.$originalQuestion.'</label><input name="question" type="text" id="question" ></p>
		<p><label for="pass">'.$locale{$lang}->{password}.' <span text="'.$locale{$lang}->{spancom}.'">(?)</span></label>
		<input name="pass" type="password" id="pass" value="'.$pass.'"></p>
		<p><input name="postTitle" value="'.$entry[0].'" type="hidden" id="postTitle">
		<input name="process" value="doComment" type="hidden" id="process">
		<input name="viewDetailed" value="'.$fileName.'" type="hidden" id="viewDetailed">
		<input type="submit" name="Submit" value="'.$locale{$lang}->{preview}.'">
		<input type="submit" name="Submit" value="'.$locale{$lang}->{addcomment}.'">
		</p></form>';
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
	my $do='?';
	my $part=0;
	
	if (scalar(@tmpEntries) == 0){print $locale{$lang}->{nopages1};}

	else{
		foreach my $item(@tmpEntries)
			{
				my @split = split(/¬/, $item);
				unless (grep {$_ eq $split[4] } @pages){push(@entries, $item);}
			}
		doPages($do, $part, @entries);
	}
}

print '</div><nav>'
#THIS IS THE SIDEBAR MENU 
#Custom html in menu top
.$config_customMenuHTMLtop;

menuSearch();#search
menuCategories();# Show Categories on Menu
menuEntries();	# Show Entries in Menu

if($config_showLatestComments == 1)
{
	menuComments(); # Latest comments on the menu
}

print $config_customMenuHTMLbottom; # Display Custom HTML in the bottom of menu

# Show Some Links Defined on the Configuration
if(%config_menuLinks > 0)
{
	print '<h1>'.$locale{$lang}->{links}.'</h1>';
	foreach(keys%config_menuLinks)
	{
		print '<a href="'.$config_menuLinks{$_}.'">'.$_.'</a>';
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

print '</nav><footer id="footer">'.$config_blogFooter.'</footer></body></html>';
}
#done!

