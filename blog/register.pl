if (r('process') eq 'register'){

my $email = r('email');
my $password = substr(rand(99999999),0,8);
my $username = r('username');
my $verified = 1;
my $emails;

	 #check captcha if indicated
	if($config_commentsSecurityCode == 1)
	{
		my $code = r('code');
		my $originalCode = r('originalCode');
		
		unless($code eq $originalCode)
		{
			print '<br />'.$locale{$lang}->{captcha};
			last;
		}
	}
	#check security question if indicated
	if($config_securityQuestionOnComments == 1)
	{
		my $question = r('question');
		unless(lc($question) eq lc($config_commentsSecurityAnswer))
		{
			print '<br />'.$locale{$lang}->{question};
			last;
		}
	}


unless ($email =~/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i){
	$verified = 0;
	print "The email you entered is in the wrong format";
}

open (BLOCK, "<$config_commentsDatabaseFolder/blocked.$config_dbFilesExtension.dat");
while (<BLOCK>){$emails=$_;}
close (BLOCK);

my @blocked = split(/\n/, $emails); 

#maybe rather regex?
if (grep{$_ eq $email}@blocked){
	$verified = 0;
	print "Sorry, your email is blocked";
}

if ($verified == 1){
	open (MAIL,"|$config_sendMailWithNewCommentMail[0]") or die $locale{$lang}->{sendmail};
	print MAIL "To: $email \n";
	print MAIL "From: $config_blogTitle \n";
	print MAIL "Subject: Comment registration\n\n";
	print MAIL "You have been registered on $config_blogTitle. This is your password: $password";
	close(MAIL);

	open(FILE, ">>$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
	print FILE $username."'".crypt($password, $config_randomString)."'".$email.'"';#encrypt password
	close FILE;
	print '<br />'.$locale{$lang}->{newuser}; 	
	print "<br />Your password has been sent to you per mail.";
	}
}
else{
	print '<h1>Register to comment</h1>	
<form action="" name="submitform" method="post">
<table><tr>
<td>Username</td>
<td><input name=username type=text id=username></td>
</tr><tr>
<td>Email</td>
<td><input name=email type=text id=email></td>
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
			<td>'.$config_contactSecurityQuestion.'</td>
			<td><input name="question" type="text" id="question"></td>
			</tr>' if $config_securityQuestionOnContact == 1;			
print'<tr>
<td><input name="process" type="hidden" id="process" value="register"></td> 
<td><input type="submit" name="Submit" value="Register"></td>
</tr></table></form>';
}
print '';