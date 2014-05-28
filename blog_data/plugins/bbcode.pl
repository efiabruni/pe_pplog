sub bbcode
#`Efia changed [ to { to make it possible to to use rel=prettyPhoto[Gallery] (though abandoned the idea to use pretty Photo later)
{	
	$_ = $_[0];	
s/\{gal\}\s?(.+?)\s?\{\/gal\}/\{gal\}$1\{\/gal\} /gi;

my @array = split (/\s/, $_);
my @dirs = grep { /{gal}/&&/{\/gal}/; } @array;

s/'/&apos;/gi; # Jamesbond, solution to the ' giving problems in comments
s/¬/&#172;/gi;
s/{qcode\}(.+?)\{\/qcode\}/<pre><code>$1<\/code><\/pre>/gi;# Efia updated to the <code> tag also serves for quoting!
s/\n/<br \/>/gi;
s/\{b\}(.+?)\{\/b\}/<b>$1<\/b>/gi;  
s/\{i\}(.+?)\{\/i\}/<i>$1<\/i>/gi;
s/\{u\}(.+?)\{\/u\}/<u>$1<\/u>/gi;
s/\{\*\}(.+?)\{\/\*\}/<li>$1<\/li>/gi;
s/\{style=(.+?)\}(.+?)\{\/style\}/<p style=$1>$2<\/p>/gi; # Efia more text styling options
s/\{img\}(.+?)\{\/img\}/<img src=$1\/>/gi;
s/\{url\}(.+?)\{\/url\}/<a href=$1>$1<\/a>/gi; 
s/\{url=(.+?)\}(.+?)\{\/url\}/<a href=$1>$2<\/a>/gi;
s/\{box=(.+?) title=(.+?)\}(.+?)\{\/box\}/<input type=image class=thumb alt=$2 src=$1 title=$2 \/><div class=box><h3>$2<\/h3>$3<\/div>/gi;
s/\{(.+?)\/\}/<img src=$config_smiliesFolder\/$1.png \/>/gi; # Efia smilies!	
	
foreach my $dir(@dirs){
	my $pictures;
	$dir =~ s/{gal}\W?(.+?)\W?{\/gal}/$1/;
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
	s/\{gal}\W?$dir\W?\{\/gal}/$pictures/;
}  
	
	return $_;
}

sub bbdecode
#`Efia changed [ to { to make it possible to to use rel=prettyPhoto[Gallery]
{
	$_ = $_[0];
s/\n//;
s/\<pre><code\>(.+?)\<\/code\><\/pre>/\{qcode\}$1\{\/qcode\}/gi; #Efia, also serves for quoting updated div=code to <code>
s/<br \/>//gi;
s/\<b\>(.+?)\<\/b\>/\{b\}$1\{\/b\}/gi;
s/\<i\>(.+?)\<\/i\>/\{i\}$1\{\/i\}/gi;
s/\<u\>(.+?)\<\/u\>/\{u\}$1\{\/u\}/gi;
s/\<li\>(.+?)\<\/li\>/\{\*\}$1\{\/\*\}/gi;
s/\<p style=(.+?)\>(.+?)\<\/p\>/\{style=$1\}$2\{\/style\}/gi; # Efia more text styling options
s/\<img src=$config_smiliesFolder\/(.+?).png \/\>/\{$1\/\}/gi; #Efia added smilies!
s/\<img src=(.+?)\/>/\{img\}$1\{\/img\}/gi;
s/\<a href=(.+?)>(.+?)\<\/a\>/\{url=$1\}$2\{\/url\}/gi;
s/<input (.+?) src=(.+?)\/><div class=box><h3>(.+?)<\/h3>(.+?)<\/div>/\{box=$2\}$4\{\/box\}/gi;

	return $_;
}

sub bbcodeButtons #Efia buttons for entry and edit 
{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
	print qq\<fieldset class="screen">
			<input type="button" style="font-weight:bold" onClick="surroundText('{b}', '{/b}', document.forms.submitform.content); return false;" value="b" />
			<input type="button" style="font-style:italic" onClick="surroundText('{i}', '{/i}', document.forms.submitform.content); return false;" value="i" />
			<input type="button" style="text-decoration:underline" onClick="surroundText('{u}', '{/u}', document.forms.submitform.content); return false;" value="u" />
			<input type="button" style="color:red" onClick="surroundText('{style=text-align:;color:}', '{/style}', document.forms.submitform.content); return false;" value="style" title="$locale{$lang}->{style}" />
			<input type="button" onClick="surroundText('{*}', '{/*}', document.forms.submitform.content); return false;" value=" &#8226 li" title="$locale{$lang}->{list}" />
			<input type="button" onClick="surroundText('{qcode}', '{/qcode}', document.forms.submitform.content); return false;" value="&#34/.&#34" title="$locale{$lang}->{quote}" />
			<input type="button" onClick="surroundText('{url}', '{/url}', document.forms.submitform.content); return false;" value="http://" title="$locale{$lang}->{http}" />
            <input type="button" onClick="surroundText('{img}', '{/img}', document.forms.submitform.content); return false;" value="img" title="$locale{$lang}->{img}" />
			<input type="button" onClick="surroundText('{box= title=}','{/box}', document.forms.submitform.content); return false;" value="Box" title="$locale{$lang}->{box}" />
            <input type="button" onClick="surroundText('{gal}','{/gal}', document.forms.submitform.content); return false;" value="$locale{$lang}->{newGallery}"  title="$locale{$lang}->{gal}" />
			<div class="smilies">\;
		my @smilies = readdir (SM);
		closedir SM;
		foreach (@smilies){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'{'.$name.'/}\', \'\', document.forms.submitform.content); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
			
		
			#<input  type="button" onClick="surroundText(\'{\', \'/}\', document.forms.submitform.content); return false;" value=":-)"/>
			print '</div></fieldset><input class="screen" type=image alt="'.$locale{$lang}->{bbcode}.'"><div class=box /><iframe src=?BbcodeHelp=help#content target="_blank" width=650px height=90%></iframe></div>';

}

sub bbcodeComments #Buttons for comments
{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
		print qq\<fieldset class="screen">
			<input  type="button" style="font-weight:bold" onClick="surroundText('{b}', '{/b}', document.forms.submitform.comContent); return false;" value="b" />
			<input  type="button" style="font-style:italic" onClick="surroundText('{i}', '{/i}', document.forms.submitform.comContent); return false;" value="i" />
			<input  type="button" style="text-decoration:underline" onClick="surroundText('{u}', '{/u}', document.forms.submitform.comContent); return false;" value="u" />
			<input  type="button" style="color:red" onClick="surroundText('{style=text-align:;color:}', '{/style}', document.forms.submitform.comContent); return false;" value="style" title="$locale{$lang}->{style}"/>
			<input  type="button" onClick="surroundText('{*}', '{/*}', document.forms.submitform.comContent); return false;" value=" &#8226 li" title="$locale{$lang}->{list}" />
			<input  type="button" onClick="surroundText('{qcode}', '{/qcode}', document.forms.submitform.comContent); return false;" value="&#34/.&#34" title="$locale{$lang}->{quote}" />
			<input  type="button" onClick="surroundText('{url}', '{/url}', document.forms.submitform.comContent); return false;" value="http://" title="$locale{$lang}->{http}" />
            <input  type="button" onClick="surroundText('{img}', '{/img}', document.forms.submitform.comContent); return false;" value="img" title="$locale{$lang}->{img}" />
            <div class="smilies">\;
        while ($_ = readdir (SM)){
		foreach ($_){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'{'.$name.'/}\', \'\', document.forms.submitform.comContent); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
		}	
		closedir SM;
			#<input  type="button" onClick="surroundText(\'{\', \'/}\', document.forms.submitform.content); return false;" value=":-)"/>
			print '</div></fieldset>';
}
1;