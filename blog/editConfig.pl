# 19.07.13 added edit css option, thanks to sc0ttman!
if (r('process')eq 'editConfig')
{
	if (r('pass') eq $config_adminPass && r('content') ne ''){

		my $content = basic_r('content');
		my $which = r('which');
		my $file;
		$file = "$config_serverRoot/$config_currentStyleFolder/$config_currentStyleSheet" if $which eq "css";
		
		if ($which eq "config"){
		$file = "$config_DatabaseFolder/pe_Config.pl";
		
		unless (rename ("$file", "$file.bak")){
			print '<br />'.$locale{$lang}->{nobackup}.' <a href="?page=1">'.$locale{$lang}->{back}.'</a>';
			last;
			}
		}
		open (FILE, ">$file");
		print FILE $content and print '<br />'.$locale{$lang}->{saved}.' <a href="?page=1">'.$locale{$lang}->{goindex}.'</a>';
		close FILE;
	}
	else {print '<br />'.$locale{$lang}->{nosaved}.' <a href="?do=editConfig">'.$locale{$lang}->{try}.'</a>?';}
	
}

elsif (r('password') eq $config_adminPass){

	my $configFile = "$config_DatabaseFolder/pe_Config.pl";
	my $content = '';
	my $cssFile = "$config_serverRoot/$config_currentStyleFolder/$config_currentStyleSheet";
	my $css = '';
	my $pass = r('password');
	
	open (FILE, $configFile) or print $locale{$lang}->{noopenconfig};
	while (<FILE>){$content .= $_;}
	close FILE;
	
	print '<h1>'.$locale{$lang}->{changesettings}.'</h1>
		   <form accept-charset="UTF-8" name="submitform" method="post">
		   <textarea name="content"  rows="200" cols="100" wrap="off" style="max-width:100%" id="content">'
		   .$content.
		  '</textarea><br /><br />
		   '.$locale{$lang}->{warning1}.'<a href="?page=1">'.$locale{$lang}->{warning2}.'</a>
		   <input name="pass" type="hidden" id="pass" value="'.$pass.'">
		   <input name="which" type="hidden" id="which" value="config">
		   <input name="process" type="hidden" id="process" value="editConfig">
		   <input type="submit" name="Submit" type="hidden" value="'.$locale{$lang}->{edentry}.'"></form>';
		   
	open (FILE, $cssFile) or print $locale{$lang}->{noopencss};
	while (<FILE>){$css .= $_;}
	close FILE;
	
	print '<h1>'.$locale{$lang}->{changestyle}.'</h1>
		   <form accept-charset="UTF-8" name="submitform" method="post">
		   <textarea name="content"  rows="200" cols="100" wrap="off" style="max-width:100%" id="content">'
		   .$css.
		  '</textarea><br /><br />
		   <input name="pass" type="hidden" id="pass" value="'.$pass.'">
		   <input name="which" type="hidden" id="which" value="css">
		   <input name="process" type="hidden" id="process" value="editConfig">
		   <input type="submit" name="Submit" type="hidden" value="'.$locale{$lang}->{edentry}.'"></form>';
}
else {
	print '<h1>'.$locale{$lang}->{eCpassword}.'</h1>
	<form method="post" action="">
	<input type="password" name="password">
	<input name="do" type="hidden" id="do" value="editConfig">
	<input type="submit" name="Submit" type="hidden" value="'.$locale{$lang}->{submit}.'"></form>';
}
		
