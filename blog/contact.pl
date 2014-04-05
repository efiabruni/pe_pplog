#contact plug in for the pe_pplog, 16.05.13 by efia
#bugfix and added security question feature 23.11.13

if (r('process')eq 'contact'){
	my $title = r('title');
	my $author = r('name');
	my $email = r('email');
	my $message = r('content');
	my $originalQuestion = r('originalQuestion');
	my $question = r('question');
	my $pot = r('comment');
	
	if($title eq '' || $author eq '' || $message eq ''|| $email eq '')
	{
		print '<br />'.$locale{$lang}->{necessary};
		$do = 0;
	}
	 #check captcha if indicated
	elsif($pot ne '')
	{
		print '<br />'.$locale{$lang}->{captcha};
	}
	#check security question if indicated
	elsif(lc($question) ne lc($config_commentsSecurityQuestion{$originalQuestion}))
	{
			print '<br />'.$locale{$lang}->{question};
	}
		
	else {
		if ($config_sendMailWithNewCommentMail[0] eq "local"){
			my $date = getdate($config_gmt);
			my @files = getFiles($config_DatabaseFolder."/emails");
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
			open(FILE, ">$config_DatabaseFolder/emails/$i.$config_dbFilesExtension");
			print FILE "$title¬$message¬$date¬$author'$email¬$i";
			close FILE;         
			print "<br />$locale{$lang}->{message} $author!";
		}
	else{
		open (MAIL,"|$config_sendMailWithNewCommentMail[0]") or die $locale{$lang}->{sendmail};
		print MAIL "To: $config_sendMailWithNewCommentMail[1]\n";
		print MAIL "From: $email, \t $author \n";
		print MAIL "Subject: $title\n\n";
		print MAIL "$message ";
		close(MAIL);
	
		print "<br />$locale{$lang}->{message} $author.";
		}
	}		
}
my $originalQuestion =$keys[rand @keys];
print '<h1>'.$locale{$lang}->{contactinfo}.'</h1>'.$config_contactAddress.'<br />
<form action="" name="submitform" method="post">
<legend>'.$locale{$lang}->{contactform}.'</legend>	
<p><label for="title">'.$locale{$lang}->{csubject}.'</label>
<input name=title type=text id=title></p>
<p><label for="name">'.$locale{$lang}->{name}.'</label>
<input name=name type=text id=name></p>
<p><label for="email">'.$locale{$lang}->{email}.'</label>
<input name=email type=text id=email></p>
<p class="comment"><label for="commment">'.$locale{$lang}->{pot}.'</label>
<input name="comment" type="text" id="comment" ></p>
<p><label for="content">Message</label>
<textarea name="content" id="content"></textarea></p>
<p><label for="question"><input name="originalQuestion" value="'.$originalQuestion.'" type="hidden" id="originalQuestion">'
.$originalQuestion.'</label>
<input name="question" type="text" id="question"></p>
<p><input name="process" type="hidden" id="process" value="contact"> 
<input type="submit" name="Submit" value="'.$locale{$lang}->{send}.'">
</p></form>';