sub bbcode
	{	
		$_ = shift;	

		apo_r($_);

	s/\(/&#40;/gi;
	s/\)/&#41;/gi;
	s/\n(.+?)\n/<p>$1<\/p>/gi; ##this might not be working
	s/(http(s?):\/\/(\S+?))/<a href=$1>$1<\/a>/gi;
	s/\[(.+?)\/\]/<img src=$config_smiliesFolder\/$1.png \/>/gi; # Efia smilies!
 		
 		if (r('process') eq 'doEntry'){
		s/\[box=(.+?) title=(.+?)\](.+?)\[\/box\]/<input type=image class=thumb alt=$2 src=$1 title=$2 \/><div class=box><h3>$2<\/h3>$3<\/div>/gi;
		s/\[gal\]\s?(.+?)\s?\[\/gal\]/\[gal\]$1\[\/gal\] /gi;

		my @array = split (/\s/, $_);
		my @dirs = grep { /[gal]/&&/[\/gal]/; } @array;

		foreach my $dir(@dirs){
			my $pictures;
			$dir =~ s/\[gal]\W?(.+?)\W?\[\/gal]/$1/;
			opendir (PIC,"$config_serverRoot/$dir");
			my @pics = grep {/(jpg|jpeg|png|gif)$/i;} readdir(PIC);
	
			foreach my $pic(@pics)
			{
				my $name=$pic;
				$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
			
				if (-e "$config_serverRoot/$dir/thumbs"){
					$pictures .= "<input type=image class=thumb alt=$name src=$dir/thumbs/$pic title=$name /><div class=box><h3>$name</h3><img src=$dir/$pic /></div>";
				}
				else {
					$pictures .= "<input type=image class=thumb alt=$name src=$dir/$pic title=$name /><div class=box><h3>$name</h3><img src=$dir/$pic /></div>";
				}	
			}
			s/\[gal]\W?$dir\W?\[\/gal]/$pictures/;
		}
	}  

	return $_;
	}

sub bbdecode
	{
		$_ = shift;

	s/\n//;
	s/<br \/>//gi;
	s/<p>//gi;
	s/<\/p>//gi;
	s/\<a href=(.+?)>(.+?)\<\/a\>/$1/gi;
	s/\<img src=$config_smiliesFolder\/(.+?).png \/\>/\[$1\/\]/gi; #Efia added smilies!
	s/<input (.+?) src=(.+?) \/><div class=box><h3>(.+?)<\/h3>(.+?)<\/div>/\[box=$2\]$4\[\/box\]/gi;

	return $_;
	}

sub bbcodeButtons #Efia buttons for entry and edit 
	{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
	my @smilies = readdir (SM);
	closedir SM;

	print qq\<fieldset class="screen">
			 <input type="button" onClick="surroundText('[gal]','[/gal]', document.forms.submitform.content); return false;" value="$locale{$lang}->{newGallery}"  title="$locale{$lang}->{gal}" />
			<div class="smilies">\;

		foreach (@smilies){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'['.$name.'/]\', \'\', document.forms.submitform.content); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
		print '</div></fieldset>';
	}

sub bbcodeComments #Buttons for comments
	{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
	my @smilies = readdir (SM);
	closedir SM;
		print qq\<fieldset class="screen"><div class="smilies">\;
        foreach (@smilies){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'['.$name.'/]\', \'\', document.forms.submitform.comContent); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
		print '</div><br /><br /></fieldset>';
	}

1;