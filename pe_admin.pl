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

#This is the administrator page of the blog
use CGI::Carp qw/fatalsToBrowser/;	# This is optional
use CGI':all';
use POSIX qw(ceil floor);
use POSIX qw/strftime/; #sc0ttman
						
do "./blog/pe_Config.pl" or (require "./blog/pe_Config.pl.bak"); #change the path to the /blog folder on your computer
require "$config_DatabaseFolder/sub.pl"; 

# efia redirect for https 10.07.13
if ($config_useHTTPSlogin == 1){
	my $url = url(-full=>1);
	if ($url =~ /^http:/) {
		unless ($ENV{'HTTP_X_FORWARDED_PROTO'} eq "https"){
			print redirect("https://$ENV{HTTP_HOST}$ENV{REQUEST_URI}");
			exit;
		}
	}
}
#efia fix login to work with Hiawatha 13.06.13 and added https option
my $getip = getIP();
my $name = crypt($getip, $config_randomString);
my $cookie = cookie($name);
my $dummy = cookie ( -name   =>'enabled', -value  => 1);
my $form_pass = r('password');
my $value = crypt(rand(999999), $config_randomString);
my $log_in;

if (r('process')eq 'log_in'){
	
	if ($form_pass eq $config_adminPass){
		$log_in = "logged";
		open FILE, "+>$config_tmpFolder/log_in.txt" or $log_in = "file" ; 
		print FILE $value;
		close FILE;
		if ($config_useHTTPSlogin == 1){
			$cookie = cookie( -name   => $name,
             -value  => $value, -secure => 1, httponly => 1);}
        else {$cookie = cookie( -name   => $name,
             -value  => $value, httponly => 1);}
            
		print header(-charset => qw(utf-8), -cookie => $cookie) ;
		$log_in = "cookie" unless defined ($ENV{'HTTP_COOKIE'} );
	}
	else { print header(-charset => qw(utf-8)); $log_in = "pass";}
}

elsif (r('do')eq 'log_out'){
	unlink "$config_tmpFolder/log_in.txt";
	$cookie = cookie(-name=>$name, value=>'log out', expires=>'-1d');
	print header(-charset => qw(utf-8), -cookie => $cookie);
}

else {print header(-charset => qw(utf-8), -cookie => $dummy);}


print '<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<meta name="Robots" content="none" />
<meta name="Viewport" content="width=device-width, initial-scale=1.0, maximum-scale=2.0, user-scaleable=yes"/>
<title>'.$locale{$lang}->{$admin}.' - '.$locale{$lang}->{powered}.'</title>';
if($config_enableJQuery == 1)	
{
	JQuery(); 
}
javascript();
print $config_customHTMLadmin.
#second stylesheet for mobile devices 5.06.13
'<link href='.$config_currentStyleFolder.'/'.$config_currentStyleSheet.' rel=stylesheet type=text/css media="Screen, print">
<link href='.$config_currentStyleFolder.'/mobile.css rel=stylesheet type=text/css media="only screen and (max-width: 550px), only screen and (max-device-width: 480px)">
</head>
<body><header><div id="header"><a href="?do=log_out">'.$locale{$lang}->{log_out}.'</a><a href="/pe_pplog/pe_pplog.pl"> Blog</a></div>
<a href=?page=1 style="text-decoration:none;"><h1 id="header">'.$locale{$lang}->{header}.'</h1></a><a id="mobile" href="#">'.$locale{$lang}->{menu}.'</a>
<div id="header"><a href=?page=1>'.$locale{$lang}->{index}.'</a>
<a href=?do=newEntry>'.$locale{$lang}->{new}.'</a>';
#menu bar 5.06.13; plugins menu entries
foreach(@config_pluginsAdmin)
{
	print '<a href="?do='.$_.'">'.$locale{$lang}->{$_}.'</a>'; #16.05
}
# 100613 added sc0ttmans UTF-8 fix
print '<a href="?do=listPag">'.$locale{$lang}->{listPag}.'</a>
<a href=?do=archive>'.$locale{$lang}->{archive}.'</a>
<form id="mobile" accept-charset="UTF-8" name="form1" method="post" style=" text-align:center; margin-left:1%; width:98%">
<input type="text" name="keyword" value="'.$locale{$lang}->{search}.'">
<input type="hidden" name="do" value="search">
<input type="submit" name="Submit" value="'.$locale{$lang}->{search}.'"><br />
'.$locale{$lang}->{bytitle}.'<input name="by" type="radio" value="0" checked> '.$locale{$lang}->{bycontent}.'<input name="by" type="radio" value="1">
</form> 
</div></header>
<nav><h1>'.$locale{$lang}->{search}.'</h1>
<form accept-charset="UTF-8" name="form1" method="post">
<input type="text" name="keyword" style="width:150px">', # search field 100613 added sc0ttmans UTF-8 fix
'<input type="hidden" name="do" value="search"><br />
'.$locale{$lang}->{bytitle}.'<input name="by" type="radio" value="0" checked> '.$locale{$lang}->{bycontent}.'<input name="by" type="radio" value="1">
</form>
<h1>'.$locale{$lang}->{entries}.'</h1>';
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
		print '<a href="?viewDetailed=posts/'.$entry[4].'">'.$entry[0].'</a>';
		$i++;
	}
}
#Categories 
print '<h1>'.$locale{$lang}->{categories}.'</h1>';
my @categories = sort(getCategories());
foreach(@categories)
{
	print '<a href="?viewCat='.$_.'">'.$_.'</a>';
}
# Latest comments on the menu 
if($config_showLatestComments == 1)
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
			print '<a href="?viewDetailed=posts/'.$entry[4].'#'.$entry[5].'" title="'.$locale{$lang}->{entryby}.' '.$entry[1].'">'.$entry[0].'</a>'; #sc0ttman
			$i++;
		}
	}
}

if(($config_showUsersOnline == 1) || ($config_showHits == 1)) #show stats for the main blog
{
	print '<h1>'.$locale{$lang}->{stats}.'</h1>';
}
if($config_showUsersOnline == 1) #show users online 
{
	my $timestamp = time();
	my $timeout = ($timestamp-$config_usersOnlineTimeout);
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
	print $locale{$lang}->{users}.scalar(@online_array).' <br />';
}
if($config_showHits == 1) #show hits
{
	open(FILE, "<$config_postsDatabaseFolder/hits.$config_dbFilesExtension.hits");
	while(<FILE>)
	{
		print $locale{$lang}->{hits}.$_;
	}
	close FILE;
}

print '</nav><div id="content">';#content

#logout message
if (r('do')eq 'log_out'){
	print "<br />$locale{$lang}->{msglog_out}";
}
#messages for all possible login scenarios
if ($log_in eq "logged"){print "<br />$locale{$lang}->{msglogged}";}
if ($log_in eq "pass"){ print "<br />$locale{$lang}->{msgpass}";}
if ($log_in eq "cookie"){ print "<br />$locale{$lang}->{msgcookie}";}
if ($log_in eq "file"){ print"'<br />$locale{$lang}->{msgfile}";}

#read login file in tmp
open FILE, "$config_tmpFolder/log_in.txt";
while (<FILE>){$value = $_;}
close FILE;

#login form
unless ($cookie eq $value || $log_in eq "logged"){
	print '<form accept-charset="UTF-8" method="post">
	<h1>'.$locale{$lang}->{pass}.'</h1><br />
	<input type="password" name="password">
	<input name="process" type="hidden" id="process" value="log_in">
	<input type="submit" name="Submit" type="hidden" value="'.$locale{$lang}->{log_in}.'"></form>';
	exit; #stop here if not logged in
}


if(r('do') eq 'newEntry')
{
	# Blog Add New Entry Form
	# 100613 added sc0ttmans UTF-8 fix
		my @categories = getCategories();
		print '<h1>'.$locale{$lang}->{new}.'...</h1>	
		<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<table><tr>
		<td>'.$locale{$lang}->{title}.'</td>
		<td><input name=title type=text id=title></td>
		</tr>';
		
		bbcodeButtons();
		
		print '<td><textarea name="content" cols="50" rows="15" id="content"></textarea></td></tr>
		<tr><td>'.$locale{$lang}->{categories}.' <span text="'.$locale{$lang}->{spancat}.'">(?)</span></td><td>';

			
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
		<td>'.$locale{$lang}->{ispage}.' <span text="'.$locale{$lang}->{spanpage}.'">(?)</span></td>
		<td><input type="checkbox" name="isPage" value="1"> '.$locale{$lang}->{ishtml}.' <span text="'.$locale{$lang}->{spanhtml}.'">(?)</span>
		<input type="checkbox" name="isHTML" value="1"></td>
		</tr>
		<tr>
		<td><input name="dir" type="hidden" value="/posts">
		<input name="process" type="hidden" id="process" value="newEntry"></td> 
		<td><input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'"></td>
		</tr>
		</table>
		</form>';
}

elsif(r('process') eq 'newEntry')
	{
	# Blog Add New Entry Page
	
    #BK 7JUL09 patch from fedekun, fix post with no title that caused zero-byte message...	
    my $dir = r('dir');
    my $title = r('title');
    my $isHTML = r('isHTML');			#Efia HTML checkbox
    my $category = r('category');
    my $isPage = r('isPage');
    if($isHTML == 0)
        {
            $content = bbcode(r('content'));
        }
        else
        {
            $content = basic_r('content');
        }
 
       
     if($title eq '' || $content eq '' || $category eq '')
        {
            die($locale{$lang}->{necessary});
        }
       
     my @files = getFiles($config_DatabaseFolder.$dir);
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
       
         open(FILE, ">$config_DatabaseFolder$dir/$i.$config_dbFilesExtension");
       
         my $date = getdate($config_gmt);
         print FILE $title.'¬'.$content.'¬'.$date.'¬'.$category.'¬'.$i;    # 0: Title, 1: Content, 2: Date, 3: Category, 4: FileName
         close FILE;
       
         if($isPage == 1)
         {
            open(FILE, ">>$config_postsDatabaseFolder/pages.$config_dbFilesExtension.page");
            print FILE $i.'-';
            close FILE;
         }
      #BK 7JUL09 patch end.
      my $fileName = "$dir/$i";
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
 
elsif(r('edit') ne '')
{
	# Edit Entry Page
	
		my $id = r('edit');
		my $tempContent = '';
		open(FILE, "<$config_DatabaseFolder/$id.$config_dbFilesExtension");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		my @entry = split(/¬/, $tempContent);
		my $fileName = $entry[4];
		my $title = $entry[0];
		my $content = $entry[1];
		my $category = $entry[3];
		# 100613 added sc0ttmans UTF-8 fix
		print '<h1>'.$locale{$lang}->{edit}.'...</h1>
		<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<table>
		<tr>
		<td>'.$locale{$lang}->{title}.'</td>
		<td><input name=title type=text id=title value="'.$title.'"></td>
		</tr>';
		bbcodeButtons();
		print '<td><textarea name=content cols=50" rows="15" id="content">';
		
			print bbdecode($content);
		
		print '</textarea></td></tr><tr><td>'.$locale{$lang}->{categories}.' <span text="'.$locale{$lang}->{spancat}.' ">(?)</span></td><td>'; #Cat. tooltip 24.05.13
;
		my @categories = getCategories();
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
		print '</td></tr><tr><td>&nbsp;</td>
		<td><input name="category" type="text" id="category" value="'.$category.'"></td>
		</tr>
		<tr>	
		<td>'.$locale{$lang}->{ishtml}.' <span text="'.$locale{$lang}->{spanhtml}.'">(?)</span></td>
		<td><input type="checkbox" name="isHTML" value="1"></td>
		</tr>
		<tr>
		<td><input name="process" type="hidden" id="process" value="editEntry">
		<input name="fileName" type="hidden" id="fileName" value="'.$id.'"></td>
		<td><input type="submit" name="Submit" value="'.$locale{$lang}->{edentry}.'"></td>
		</tr>
		</table>
		</form>';
}

elsif(r('delete') ne '') 
{
	# Delete Entry Page
	
	my $fileName = r('delete');
	# 100613 added sc0ttmans UTF-8 fix
	print '<h1>'.$locale{$lang}->{delete}.'...</h1>
	<form accept-charset="UTF-8" name="form1" method="post">
	<table>
	<td>'.$locale{$lang}->{sure}.' <a href="?viewDetailed='.$fileName.'">'.$locale{$lang}->{back}.'</a>
	<input name="process" type="hidden" id="process" value="deleteEntry">
	<input name="fileName" type="hidden" id="fileName" value="'.$fileName.'">
	<td><input type="submit" name="Submit" value="'.$locale{$lang}->{delete}.'"></td>
	</tr>
	</table>
	</form>';
}
#preview Comments
elsif (r('Submit') eq $locale{$lang}->{preview})
{
	#get all the posted detailes
	my $title = r('title');
	my $author = $config_commentsForbiddenAuthors[0]; 
	my $content = r('content');
	my $postTitle = r('postTitle');
	my $fileNum = r('Comment');
	my $date = getdate($config_gmt);
	
	#print comment as html
	print '<b>'.$title.'</b> &nbsp; '.$locale{$lang}->{postedon}.' <b>'.$date.'</b> '.$locale{$lang}->{by}.' <b>'.$author.'</b><br />';
	print bbcode($content); 
	
	#print comment form with former entries
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
			</tr><tr>
			<td><input name="postTitle" value="'.$postTitle.'" type="hidden" id="postTitle">
			<input name="Comment" value="'.$fileNum.'" type="hidden" id="Comment"></td>
			<td><input type="submit" name="Submit" value="'.$locale{$lang}->{preview}.'"><input type="submit" name="Submit" value="'.$locale{$lang}->{addcomment}.'">
			</td>
			</tr>
			</table>
			</form>';
}

#Display Individual Entry and all processes which end with displaying an entry
elsif(r('viewDetailed') ne '' || r('process') eq 'editEntry'|| r('Submit') eq $locale{$lang}->{addcomment} || r('process') eq 'deleteComment')
{
	
	my $fileName = r('viewDetailed');
	$fileName = "posts/".$fileName if $fileName =~ /^(\d\d\d)/; #if there is no folder indication it is assumed to be a post
	my @split= split (/\//, $fileName);
	my $fileNum = $split[1];
	my @comments;
	my $content;
	my $do = 1;
	
 
	if(r('process') eq 'editEntry')
	{
	# Edit process
	
		my $title = r('title');
		my $isHTML = r('isHTML');				
		if($isHTML == 0)
		{
			$content = bbcode(r('content'));
		}
		else
		{
			$content = basic_r('content'); #if entry is html
		}
		my $category = r('category');
		$fileName = r('fileName');
		@split= split (/\//, $fileName); #get the file number
		$fileNum = $split[1];
		
		
		open(FILE, "+>$config_DatabaseFolder/$fileName.$config_dbFilesExtension");
		
		if($title eq '' or $content eq '' or $category eq '')
		{
			die($locale{$lang}->{necessary});
		}
		
		my $date = getdate($config_gmt);
		print FILE $title.'¬'.$content.'¬'.$date.'¬'.$category.'¬'.$fileNum;	# 0: Title, 1: Content, 2: Date, 3: Category, 4: FileName
		close FILE;
	}
	
	if(r('Submit') eq $locale{$lang}->{addcomment})
	{
	# Send Comment Process
	# Shorter for admin, no identity checking, security code or other
	
	$fileNum = r('Comment');
	$fileName = "posts/".$fileNum;
	my $posttitle = r('postTitle');
	my $title = r('title');
	my $author = $config_commentsForbiddenAuthors[0]; 
	$content =bbcode(r('content')); # the ' was giving problems with displying it, now it gets encoded, thanks to Jamesbond for the solution
	my $date = getdate($config_gmt);
	my $anchor = strftime "%Y%m%d%H%M%S", localtime; #sc0ttman added the anchor
	
	if($title eq '' || $content eq '')
	{
		die ($locale{$lang}->{necessary});
	}
	else
	{
			if(length($content) > $config_commentsMaxLenght)#if comment is too long
			{
				print '<br />'.$locale{$lang}->{toolong1}.$config_commentsMaxLenght.$locale{$lang}->{toolong2}.length($content);
			}
			else
			{
				my $content = $title.'"'.$author.'"'.$content.'"'.$date.'"'.$fileNum.'"'.$anchor.'"'.$posttitle."'"; #sc0ttman
				
				# Add comment
				open(FILE, ">>$config_commentsDatabaseFolder/$fileNum.$config_dbFilesExtension");
				print FILE $content;
				close FILE;
				
				# Add coment number to a file with latest comments				
				open(FILE, ">>$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
				print FILE $content;
				close FILE;
				
				print '</br>'.$locale{$lang}->{commentadd}.' <a href="?viewDetailed=posts/'.$fileNum.'#'.$anchor.'">'.$locale{$lang}->{commentview}.'</a>';
			}
		}
	}
	
	if(r('process') eq 'deleteComment')
	{
	# Delete Comment Process

		my $data = r('data');
		my @info = split(/\./, $data);
		$fileNum = $info[0];
		$fileName = "posts/".$fileNum;
		my $part = $info[1];
		my $commentToDelete;
		
		#get all the comments from the post
		open(FILE, "<$config_commentsDatabaseFolder/$fileNum.$config_dbFilesExtension");
		while(<FILE>)
		{
			$content=$_;
		}
		close FILE;
		
		@comments = split(/'/, $content);
			
			
			@comments = reverse(@comments); 
	
	
		my $newContent = '';
		
		my $i = 0;
		my @newComments;
		#delete the chosen one
		foreach(@comments)
		{
			if($i != $part)
			{
				push(@newComments, $_);
			}
			else
			{
				$commentToDelete = $_;
			}
			$i++;
		}
		
		if($i == 1)		# There was only 1 comment, delete comment file
		{
			unlink("$config_commentsDatabaseFolder/$fileNum.$config_dbFilesExtension");
		}
		else #new content of comment file if there were more than one
		{		
			reverse(@newComments);
			
			foreach(@newComments)
			{
				$newContent.=$_."'";
			}
			
			open(FILE, "+>$config_commentsDatabaseFolder/$fileNum.$config_dbFilesExtension");	# Open for writing, and delete everything else
			print FILE $newContent;
			close FILE;
		}
		
		# Now delete comment from the latest comments file where all comments are saved
		open(FILE, "<$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
		$newContent = '';
		while(<FILE>)
		{
			$newContent.=$_;
		}
		close FILE;
		
		@comments = split(/'/, $newContent);
		my $finalCommentsToAdd;
		foreach(@comments)
		{
			unless($_ eq $commentToDelete)
			{
				$finalCommentsToAdd.=$_."'";
			}
		}
		
		open(FILE, "+>$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");	# Open for writing, and delete everything else
		print FILE $finalCommentsToAdd;
		close FILE;
		
		# Finally print this
		print '</br>'.$locale{$lang}->{commentdel};
	}

	unless(-e "$config_DatabaseFolder/$fileName.$config_dbFilesExtension")
	{
		print '</br>'.$locale{$lang}->{noentry};
		$do = 0;
	}
	
	# view Detailed
	if($do == 1)		# Checks if the file exists before doing all this
	{
		my $tempContent;
		open(FILE, "<$config_DatabaseFolder/$fileName.$config_dbFilesExtension");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		my @entry = split(/¬/, $tempContent);
		my @categories = split (/'/, $entry[3]); 
		my $postTitle = $entry[0];

		# display the entry
		print '<h1><a href="?viewDetailed='.$fileName.'">'.$entry[0].'</a></h1><a href="?edit='.$fileName.'">'.$locale{$lang}->{e}.'</a> - <a href="?delete='.$fileName.'">'.$locale{$lang}->{d}.'</a><br /><br />'.$entry[1].'<br /><br />
		<footer>'.$locale{$lang}->{postedon}.$entry[2].' - '.$locale{$lang}->{categories}.':';
		for (0..$#categories){
					print ' <a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
				} 
		print '</footer><br /><br />'; 
	
	if ($fileName =~ /^(post)/){	
		# Now Display Comments
		unless(-d $config_commentsDatabaseFolder)		# Does the comments folder exists? We will save comments there...
		{
			mkdir($config_commentsDatabaseFolder, 0755);
		}
	
		$content = '';
		open(FILE, "<$config_commentsDatabaseFolder/$fileNum.$config_dbFilesExtension");
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
			
			@comments = split(/'/, $content);
				
		
			@comments = reverse(@comments); 
		
	
			my $i = 0;
			foreach(@comments)
			{
				my @comment = split(/"/, $_);
				#title = $comment[0]; author = $comment[1]; content = $comment[2]; date = $comment[3]; anchor = $comment[5]; 
				#sc0ttman anchor
				print '<a id="anchor" name="'.$comment[5].'"></a><b>'.$comment[0].'</b> &nbsp; '.$locale{$lang}->{postedon}.' <b>'.$comment[3].'</b> '.$locale{$lang}->{by}.' <b>'.$comment[1].'</b><br />';
				print $comment[2]; 
				
				print '<br /><a href="?deleteComment='.$fileNum.'.'.$i.'">'.$locale{$lang}->{d}.'</a><br /><br />';
				$i++;	# This is used for deleting comments, to know what comment number it has :]
			}
		}
		# Add comment form
		# 100613 added sc0ttmans UTF-8 fix
			print '<br /><br /><h1>'.$locale{$lang}->{addcomment}.'</h1>
			<form accept-charset="UTF-8" name="submitform" method="post">
			<table>	<tr>
			<td>'.$locale{$lang}->{title}.'</td>
			<td><input name="title" type="text" id="title"></td>
			</tr>';
		
		#bbcode buttons on comment form (or not)
	if ($config_bbCodeOnCommentaries == 1)
	{
		bbcodeComments();
	}
	else
	{
		print'<tr><td>&nbsp;</td>';
	}
	print '<td><textarea name="content" id="content" cols="50" rows="10"></textarea></td>
			</tr>
			<tr>
			<td>
			<input name="process" type="hidden" id="process" value="sendComment">
			<input name="Comment" value="'.$fileNum.'" type="hidden" id="Comment">
			<input name="postTitle" value="'.$postTitle.'" type="hidden" id="postTitle"></td>
			<td><input type="submit" name="Submit" value="'.$locale{$lang}->{preview}.'"><input type="submit" name="Submit" value="'.$locale{$lang}->{addcomment}.'"></td>
			</tr>
			</table>
			</form>';
		}
	}
}

elsif(r('deleteComment') ne '')
{
	# Delete Comment are you sure? form
	
	my $data = r('deleteComment');
	my @info = split(/\./, $data);
	$fileName = $info[0];
	
	print '<h1>'.$locale{$lang}->{delcomment}.'...</h1>
	<form name="form1" method="post">
	<table>
	<td>'.$locale{$lang}->{sure}.' <a href="?viewDetailed=posts/'.$fileName.'">'.$locale{$lang}->{back}.'</a>
	<input name="process" type="hidden" id="process" value="deleteComment">
	<input name="data" type="hidden" id="data" value="'.$data.'"></td>
	<td><input type="submit" name="Submit" value="'.$locale{$lang}->{delcomment}.'"></td>
	</tr>
	</table>
	</form>';
}
#list comments
elsif(r('do') eq 'listComments')
{
	listComments();
}
#list pages
elsif(r('do') eq 'listPag')
{
	my @pages = getPages();
	my @entries = getFiles($config_postsDatabaseFolder);
	my @tempEntries = ();
    foreach my $item(@entries)
	{
		my @split = split(/¬/, $item);	
		if (grep { $_ == $split[4] } @pages)
		{
		 push (@tempEntries, $item);
		}
	}
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
			
			# display the pages (with a slide out effect)
				print '<div class="article"><h1><a href="?viewDetailed=posts/'.$finalEntries[4].'">'.$finalEntries[0].'</a> &nbsp; <small><a href="?edit=posts/'.$finalEntries[4].'">'.$locale{$lang}->{e}.'</a> - <a href="?delete=posts/'.$finalEntries[4].'">'.$locale{$lang}->{d}.'</a></small></h1>
				<div class="hide"><a href="?viewDetailed=posts/'.$finalEntries[4].'">'.$locale{$lang}->{comments}.'</a><br /><br />'.$finalEntries[1].'<br /></div></br><footer>'.$locale{$lang}->{postedon}.$finalEntries[2].' - '.$locale{$lang}->{categories}.':';
				for (0..$#categories)
				{
					print ' <a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
				}
					print '<br /></footer><br /><br /></div>'; 
		}
		$i++;
	}
	#Pages
	if($totalPages >= 1)
	{
		print $locale{$lang}->{pages};
	}
	else
	{
		print '<br />'.$locale{$lang}->{nopages1}.' <a href="?do=newEntry">'.$locale{$lang}->{nopages2}.'</a>?';
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
					print '<a href="?do=listPag&page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="?do=listPag&page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="?do=listPag&page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}
}

elsif(r('viewCat') ne '')
{
	# Blog Category Display
	
	my $cat = r('viewCat');
	my @entries = getFiles($config_postsDatabaseFolder);
	my @thisCategoryEntries = ();
	foreach my $item(@entries)
	{
		my @split = split(/¬/, $item);											# [0] = Title	[1] = Content	[2] = Date	[3] = Category
		my @nextsplit = split(/'/,$split[3]);									# Split the categories (if more than 1)
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
			
			# display entries with JQuery show/hide effect
			print '<div class="article"><h1><a href="?viewDetailed=posts/'.$finalEntries[4].'">'.$finalEntries[0].'</a> &nbsp; <small><a href="?edit=posts/'.$finalEntries[4].'">'.$locale{$lang}->{e}.'</a> - <a href="?delete=posts/'.$finalEntries[4].'">'.$locale{$lang}->{d}.'</a></small></h1>
			<div class="hide"><a href="?viewDetailed=posts/'.$finalEntries[4].'">'.$locale{$lang}->{comments}.'</a><br /><br />'.$finalEntries[1].'<br /></div></br><footer>'.$locale{$lang}->{postedon}.$finalEntries[2].' - '.$locale{$lang}->{categories}.':';
			for (0..$#categories){
				print ' <a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
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
		print '<br />'.$locale{$lang}->{nocategory};
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
#archive
elsif(r('do') eq 'archive')
{
	doArchive();
}
#bbcode help page
elsif(r('BbcodeHelp')ne '')
{
	BbcodeHelp();
}
#do plugins from external file
elsif (grep {$_ eq r('do') } @config_pluginsAdmin) #24.05.13 plugin section
{
	my $plugin = r('do');
	do "$config_DatabaseFolder/$plugin.pl" or print '<br />'.$locale{$lang}->{noplugin}.' <a href="?page=1">'.$locale{$lang}->{back}.'</a>';
}

elsif (grep {$_ eq r('process') } @config_pluginsAdmin)
{
	my $plugin = r('process');
	do "$config_DatabaseFolder/$plugin.pl" or print '<br />'.$locale{$lang}->{noplugin}.' <a href="?page=1">'.$locale{$lang}->{back}.'</a>';
}
else
#front page
{
	if(r('process') eq 'deleteEntry')
{
	# Delete Entry Process
	
		my $fileName = r('fileName');
		my @split = split (/\//, $fileName);
		my $fileNum = $split[1];
		my @pages = getPages();
		my $isPage = 0;
		
		#delete from page database
		if ($fileName =~ /^(posts)/){
		foreach(@pages)
		{
			if($_ == $fileNum)
			{
				$isPage = 1;
				last;
			}
		}
		
		my $newPages;
		if($isPage == 1)
		{
			foreach(@pages)
			{
				if($_ != $fileNum)
				{
					$newPages.=$_.'-';
				}
			}
			
			open(FILE, "+>$config_postsDatabaseFolder/pages.$config_dbFilesExtension.page");
			print FILE $newPages;
			close FILE;
		}
	}
	#delete comments from post
	if (-e "$config_commentsDatabaseFolder/$fileNum.$config_dbFilesExtension")
	{
		open(FILE, "<$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
		$newContent = '';
		while(<FILE>)
			{
				$newContent.=$_;
			}
			close FILE;
		
		@comments = split(/'/, $newContent);
		my $finalCommentsToAdd;
		foreach(@comments)
		{
			my @parts = split (/"/, $_);
			unless($parts[4] eq $fileNum)
			{
				$finalCommentsToAdd.=$_."'";
			}
		}
		
		open(FILE, "+>$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");	# Open for writing, and delete everything else
		print FILE $finalCommentsToAdd;
		close FILE;
		unlink("$config_commentsDatabaseFolder/$fileNum.$config_dbFilesExtension")
	}
	#finally delete post
	unlink("$config_DatabaseFolder/$fileName.$config_dbFilesExtension");		
	print '</br>'.$locale{$lang}->{deentry};
}
	#Warning if back up Config file is used
	do "$config_DatabaseFolder/pe_Config.pl" or print $locale{$lang}->{config};
#show latest comments	
	print '<h1>'.$locale{$lang}->{newcomments}.'</h1>';
	my @comments = getComments();
	# This is pagination... Again :]
	my $arrayEnd = ($config_entriesPerPage);						# The array will start from this number
	my $arrayStart = $arrayEnd-($config_entriesPerPage-1);				# And loop till this number
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

			print '<tr><td><a href="?viewDetailed=posts/'.$finalEntries[4].'#'.$finalEntries[5].'" title="'.$finalEntries[2].'">'.$finalEntries[0].'</a></td><td>'.$finalEntries[1].'</td><td><a href="?viewDetailed=posts/'.$finalEntries[4].'">'.$finalEntries[6].'</a></td></tr>';
		}
		$i++;
	}
	print '</table><br />';
	#New entry form
	my @categories = getCategories();
	# 100613 added sc0ttmans UTF-8 fix 
	print '<h1>'.$locale{$lang}->{new}.'...</h1>	
		<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<table><tr>
		<td>'.$locale{$lang}->{title}.'</td>
		<td><input name=title type=text id=title></td>
		</tr>';
		
		bbcodeButtons();
		
	print '<td><textarea name="content" cols="50" rows="15" id="content"></textarea></td></tr>
		<tr><td>'.$locale{$lang}->{categories}.' <span text="'.$locale{$lang}->{spancat}.' ">(?)</span></td>
		<td>';
				
		$i = 1;
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
		<tr><td></td>
		<td><input name="category" type="text" id="category"></td></tr>
		<tr>
		<td>'.$locale{$lang}->{ispage}.' <span text="'.$locale{$lang}->{spanpage}.'">(?)</span></td>
		<td><input type="checkbox" name="isPage" value="1"></td></tr>
		<tr>
		<td>'.$locale{$lang}->{ishtml}.' <span text="'.$locale{$lang}->{spanhtml}.'">(?)</span></td>
		<td><input type="checkbox" name="isHTML" value="1"></td>
		</tr>
		<tr>
		<td><input name="dir" type="hidden" value="/posts">
		<input name="process" type="hidden" id="process" value="newEntry"></td> 
		<td><input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'"></td>
		</tr>
		</table>
		</form>';
}
			
print '</div></body></html>';
#the end