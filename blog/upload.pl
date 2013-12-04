print '<h1>'.$locale{$lang}->{upload}.'</h1>';

if (r('process') eq 'upload')
{
	my @filename = upload('filename');
	my $folder = r('folder');
	my $out_folder = $config_serverRoot.$folder;
	my ($bytesread, $buffer);
    my $numbytes = 1024;
    my $do = 1;
  
	if(!(opendir(DIR, $out_folder))) # create the folder if it does not exist
	{
		mkdir($out_folder, 0644);
	}
	
	foreach my $file(@filename)
	{
		my $output_file = $config_serverRoot.$folder.$file;  
		my $type = uploadInfo($file)->{'Content-Type'}; 
		
		if (defined $file) {
			# Upgrade the handle to one compatible with IO::Handle:
			$io_file = $file->handle;
		}
			# check for unsupported charcters
		unless($file =~ /^([-\@:\/\\\w.]+)$/) { 
			print "$locale{$lang}->{unsupported} '_', '-', '\@', '/', '\\','.'";
			$do=0;  
			}
			#check for allowed mime types
	unless (grep {$type =~ /$_(.+?)/} @config_allowedMime){
		print "$locale{$lang}->{extension}";
		$do=0;
	}

	
		#write file
		if ($do==1){
			open (OUTFILE, ">", "$output_file") or print "$locale{$lang}->{noopenup} $!";
			while ($bytesread = $io_file->read($buffer, $numbytes)) 
				{print OUTFILE $buffer;}
			
			close OUTFILE and print "$locale{$lang}->{saveup} $output_file <br />";
			}
		}
}
	

print '<form method="post" action="http://'.$ENV{HTTP_HOST}.$ENV{REQUEST_URI}.'" enctype="multipart/form-data" accept-charset="UTF-8">
<table><tr>
<td>'.$locale{$lang}->{file}.'</td>
<td><input type="file" name="filename" multiple /></td></tr>
<tr>
<td>'.$locale{$lang}->{folder}.'</td><td><select name="folder"/>';

#show upload folders and subfolders (2 levels)
foreach $fol(@config_uploadFolders){ 
	@recurse = <$config_serverRoot$fol*>; 
	foreach $rec(@recurse){
		my $name = $rec;
		$name =~ s/$config_serverRoot(.+?)/$1/;
		print '<option>'.$name.'/</option>' if -d $rec;
		@recurse2 = <$rec/*>;
		foreach $rec2(@recurse2){
			my $name2 = $rec2;
			$name2 =~ s/$config_serverRoot(.+?)/$1/;
			print '<option>'.$name2.'/</option>' if -d $rec2;
		}
		
	}
	
}
print'</select></td></tr>
<tr><td><input type="hidden" name="process" value="upload" id="process" /></td>
<td><input type="submit" name="Submit" value='.$locale{$lang}->{submit}.' /></td></tr>
</table></form>';



	


