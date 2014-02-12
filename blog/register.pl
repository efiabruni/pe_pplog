if (r('process') eq 'register'){
	
if (r('Submit') eq 'Register'){
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


	unless ($email =~/^[A-Z0-9._-]+@[A-Z0-9.]+\.[A-Z]{2,4}$/i){
		$verified = 0;
		print "The email you entered is in the wrong format";
	}

	open (BLOCK, "<$config_commentsDatabaseFolder/blocked.$config_dbFilesExtension.dat");
	while (<BLOCK>){$emails.=$_;}
	close (BLOCK);
	
	my @blocked = split(/\n/, $emails); 

	foreach (@blocked){
		if ($email =~/$_/i){
			$verified = 0;
			print "Sorry, your email is blocked";
			last;
		}
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
		my $name = r('name');
		my $opass = r('opass');
		my $npass = r('npass');
		my $npass2 = r('npass2');
		my $userdata;
		my @users;
		my @user;
		my $email;
		my @newusers;
		my $newuserdata = '';
		my $do = 1;

		open(FILE, "<$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
		while (<FILE>) {$userdata=$_;}
		close (FILE);

		@users = split(/"/,$userdata);
		foreach (@users){
			@user = split(/'/,$_);
			if ($user[0] eq $name){
				unless ($user[1] eq crypt($opass, $config_randomString)){
					print "Wrong password";
					$do = 0;
					}
				$email = $user[2];
				}
			else {push (@newusers, $_);}
		}
		if ($npass ne $npass2){
			print "<br />Passwords do not match";
			$do=0;
		}
		if ($do == 1){
			foreach (@newusers){$newuserdata.=$_.'"';}
			$npass = crypt($npass, $config_randomString);
			$newuserdata.=$name."'".$npass."'".$email.'"';
			open(FILE, ">$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
			print FILE $newuserdata; 
			close FILE;
			print "Password has been changed";
		}				

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
print '<h1>Change Password</h1>	
<form action="" name="submitform" method="post">
<table><tr>
<td>Username</td>
<td><input name=name type=text id=name></td>
</tr><tr>
<td>Old password</td>
<td><input name=opass type=password id=opass></td>
</tr><tr>
<td>New password</td>
<td><input name=npass type=password id=npass></td>
</tr><tr>
<td>Repeat new password</td>
<td><input name=npass2 type=password id=npass2></td>
</tr><tr>
<td><input name="process" type="hidden" id="process" value="register"></td> 
<td><input type="submit" name="Submit" value="Change Password"></td>
</tr></table></form>';
}
print '';