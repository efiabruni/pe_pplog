#contact plug in for the pe_pplog, 16.05.13 by efia
#bugfix and added security question feature 23.11.13

if (r('process')eq 'contact'){
	my $title = r('title');
	my $author = r('name');
	my $email = r('email');
	my $message = r('content');
	my $do = 1;
	
	if($title eq '' || $author eq '' || $message eq ''|| $email eq '')
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
		
	if ($do ==1) {
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
print '<h1>'.$locale{$lang}->{contactinfo}.'</h1>'.$config_contactAddress.'<br />
<h1>'.$locale{$lang}->{contactform}.'</h1>	
<form action="" name="submitform" method="post">
<table><tr>
<td>'.$locale{$lang}->{csubject}.'</td>
<td><input name=title type=text id=title></td>
</tr><tr>
<td>'.$locale{$lang}->{name}.'</td>
<td><input name=name type=text id=name></td>
</tr><tr>
<td>'.$locale{$lang}->{email}.'</td>
<td><input name=email type=text id=email></td>
</tr><tr><td>'.$locale{$lang}->{cmessage}.'</td>
<td><textarea name="content" cols="35" rows="10" id="content"></textarea></td></tr>';

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
			</tr>' if $config_securityQuestionOnComments == 1;			
print'<tr>
<td><input name="process" type="hidden" id="process" value="contact"></td> 
<td><input type="submit" name="Submit" value="'.$locale{$lang}->{send}.'"></td>
</tr></table></form>';