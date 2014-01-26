my $userdata;
my @users;
my @user;

open(FILE, "<$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
while (<FILE>) {$userdata=$_;}
close (FILE);

@users = split(/"/,$userdata);

if (r('process') eq 'block'){
	my $email = r('email');
	my @newusers;
	my $newuserdata = '';

#add email to block list
	open (BLOCK, ">>$config_commentsDatabaseFolder/blocked.$config_dbFilesExtension.dat");
	print BLOCK $email."\n";
	close (BLOCK);	
	foreach (@users){
		unless ($_ =~ /$email/i) {push(@newusers, $_);}
	}
	
	foreach (@newusers){$newuserdata.=$_.'"';}
		
	open(FILE, ">$config_commentsDatabaseFolder/users.$config_dbFilesExtension.dat");
	print FILE $newuserdata;
	close (FILE);
	
	print "$email has been blocked";
}

print '<h1>Block users</h1><form accept-charset="UTF-8" name="form1" method="post"><table>';
foreach (@users){
	@user = split(/'/,$_);
	print "<tr><td>$user[0]</td><td>$user[2]<input name='email' type='hidden' value='$user[2]'></td>
			<td><input name='process' type='hidden' id='process' value='block'>
			<input type='submit' name='Submit' value='Block user'></td></tr>";
		}
print '</table></form>';

