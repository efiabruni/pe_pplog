# 19.07.13 added edit css option, thanks to sc0ttman!
if (r('process')eq 'editConfig')
{
	if (r('pass') eq $config_adminPass && r('confContent') ne ''){

		my $content = basic_r('confContent');
		my $which = r('which');
		my $file;
		$file = "$config_serverRoot$config_currentStyleFolder/$config_currentStyleSheet" if $which eq "css";
		
		if ($which eq "config"){
		$file = "$config_DatabaseFolder/pe_Config.pl";
		
		unless (rename ("$file", "$file.bak")){
			print '<br />'.$locale{$lang}->{nobackup}.' <a href="?page=1">'.$locale{$lang}->{back}.'</a>';
			last;
			}
		}
		open (FILE, ">$file");
		print FILE $content and print $file.'<br />'.$locale{$lang}->{saved}.' <a href="?page=1">'.$locale{$lang}->{goindex}.'</a>';
		close FILE;
	}
	else {print '<br />'.$locale{$lang}->{nosaved}.' <a href="?do=editConfig">'.$locale{$lang}->{try}.'</a>?';}
	
}

elsif (r('password') eq $config_adminPass){

	my $configFile = "$config_DatabaseFolder/pe_Config.pl";
	my $content = '';
	my $cssFile = "./$config_currentStyleFolder/$config_currentStyleSheet";
	my $css = '';
	my $pass = r('password');
	
	open (FILE, $configFile) or print $locale{$lang}->{noopenconfig};
	while (<FILE>){$content .= $_;}
	close FILE;
	
	print '<form accept-charset="UTF-8" name="submitform" method="post">
		   <legend>'.$locale{$lang}->{changesettings}.'</legend>
		   <textarea name="confContent"  wrap="off" rows="30" id="confContent">'
		   .$content.
		  '</textarea><p>
		    '.$locale{$lang}->{warning1}.'<a href="?page=1">'.$locale{$lang}->{warning2}.'</a>
		   <input name="pass" type="hidden" id="pass" value="'.$pass.'">
		   <input name="which" type="hidden" id="which" value="config">
		   <input name="process" type="hidden" id="process" value="editConfig">
		   <input type="submit" name="Submit" type="hidden" value="'.$locale{$lang}->{edentry}.'"></p></form><br />';
		   
	open (FILE, $cssFile) or print $locale{$lang}->{noopencss};
	while (<FILE>){$css .= $_;}
	close FILE;
	
	print '<form accept-charset="UTF-8" name="submitform" method="post">
		   <legend>'.$locale{$lang}->{changestyle}.'</legend>
		   <textarea name="confContent" wrap="off" rows="30" id="confContent">'
		   .$css.
		  '</textarea><p>
		   <input name="pass" type="hidden" id="pass" value="'.$pass.'">
		   <input name="which" type="hidden" id="which" value="css">
		   <input name="process" type="hidden" id="process" value="editConfig">
		   <input type="submit" name="Submit" type="hidden" value="'.$locale{$lang}->{edentry}.'"></p></form>';
}
else {
	print '<form method="post" action="">
	<legend>'.$locale{$lang}->{eCpassword}.'</legend>
	<input type="password" name="password">
	<input name="do" type="hidden" id="do" value="editConfig">
	<input type="submit" name="Submit" type="hidden" value="'.$locale{$lang}->{submit}.'"></form>';
}
		
