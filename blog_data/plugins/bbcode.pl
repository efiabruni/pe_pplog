sub _alt
{
	$self = shift;
	$self=~ s/([\W])/CGI::escape($1)/eg; 
	return $self;
}
sub _url
{
	$self = shift;	
	$self = "http://".$self unless ($self =~ /^(http:\/\/|https:\/\/|\/|\?)/);
	$self=~ s/([\(\)\[\]\;\!\,])/CGI::escape($1)/eg; 
	return $self;
}
sub _decode
{
	$self = shift;
	$self=~ s/(\%\w\w)/CGI::unescape($1)/eg; 
	return $self;
}
sub bbcode
#`Efia changed [ to { to make it possible to to use rel=prettyPhoto[Gallery] (though abandoned the idea to use pretty Photo later)
{	
	$_ = shift;	
	
	s/\[gal\]\s?(.+?)\s?\[\/gal\]/\[gal\]$1\[\/gal\] /gi;

	my @array = split (/\s/, $_);
	my @dirs = grep { /\[gal\]/&&/\[\/gal\]/; } @array;

s/¬/&not;/gi;
s/'/&#39;/gi;
s/\(/&#40;/gi;
s/\)/&#41;/gi;
s/\n/<br \/>/gi; ##this might not be working
s/\[b\](.+?)\[\/b\]/<b>$1<\/b>/gi;
s/\[i\](.+?)\[\/i\]/<i>$1<\/i>/gi;
s/\[u\](.+?)\[\/u\]/<u>$1<\/u>/gi;
s/\[\*\](.+?)\[\/\*\]/<li>$1<\/li>/gi;
s/\[list\](.+?)\[\/list\]/<ul>$1<\/ul>/gi;
s/\[list=1\](.+?)\[\/list\]/<ol>$1<\/ol>/gi;
s/\[img\]\s?(\S+?)\s?\[\/img\]/"<img src="._url($1)." \/>"/gei;
s/\[img=(\S+?)\s?\](\S+?)\[\/img\]/"<img src="._url($2)." alt="._alt($1)." \/>"/gei;
s/\[url\]\s?(\S+?)\s?\[\/url\]/<a href=$1>$1<\/a>/gi;
s/\[url=(\S+?)\s?\](.+?)\[\/url\]/"<a href="._url($1).">$2<\/a>"/gei;
s/\[code\](.+?)\[\/code\]/<pre><code>$1<\/code><\/pre>/gi;# Efia updated to the <code> tag also serves for quoting!
s/\[quote\](.+?)\[\/quote\]/<blockquote><p>$1<\/p><\/blockquote>/gi;# Efia updated to the <code> tag also serves for quoting!
s/\[(.+?)\/\]/<img src=$config_smiliesFolder\/$1.png \/>/gi; # Efia smilies!	
	
	#if (r('process') eq 'doEntry'){
	s/\[style=(.+?)\](.+?)\[\/style\]/<p style=$1 >$2<\/p>/gi; # Efia more text styling options
	s/\[box=(.+?) title=(.+?)\](.+?)\[\/box\]/<input type=image class=thumb alt=$2 src=$1 title=$2 \/><div class=box><h3>$2<\/h3>$3<\/div>/gi;

	foreach my $dir(@dirs){
	my $pictures;
	$dir =~ s/\[gal\](.+?)\W?\[\/gal\]/$1/;
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
	s/\[gal\]$dir\W?\[\/gal\]/$pictures/;
}  

	return $_;
}

sub bbdecode
#`Efia changed [ to { to make it possible to to use rel=prettyPhoto[Gallery]
{
	$_ = shift;

s/\n//;
s/<br \/>//gi;
s/\<b\>(.+?)\<\/b\>/\[b\]$1\[\/b\]/gi;
s/\<i\>(.+?)\<\/i\>/\[i\]$1\[\/i\]/gi;
s/\<u\>(.+?)\<\/u\>/\[u\]$1\[\/u\]/gi;
s/\<li\>(.+?)\<\/li\>/\[\*\]$1\[\/\*\]/gi;
s/\<ul\>(.+?)\<\/ul\>/\[list\]$1\[\/list\]/gi;
s/\<ol\>(.+?)\<\/ol\>/\[list=1\]$1\[\/list\]/gi;
s/\<p style=(.+?) \>(.+?)\<\/p\>/\[style=$1\]$2\[\/style\]/gi; # Efia more text styling options
s/\<img src=$config_smiliesFolder\/(.+?).png \/\>/\[$1\/\]/gi; #Efia added smilies!
s/\<img src=(\S+?) alt=(.+?) \/>/"\[img="._decode($2)."\]"._decode($1)."\[\/img\]"/gei;
s/\<img src=(.+?) \/>/"\[img\]"._decode($1)."\[\/img\]"/gei;
s/<a href=(.+?)>(.+?)\<\/a\>/"\[url="._decode($1)."\]$2\[\/url\]"/gei;
s/\<pre><code\>(.+?)\<\/code\><\/pre>/\[code\]$1\[\/code\]/gi; #Efia, also serves for quoting updated div=code to <code>
s/\<blockquote><p>(.+?)\<\/p\>\<\/blockquote>/\[quote\]$1\[\/quote\]/gi; #Efia, also serves for quoting updated div=code to <code>
s/<input (.+?) src=(.+?) \/><div class=box><h3>(.+?)<\/h3>(.+?)<\/div>/\[box=$2\]$4\[\/box\]/gi;

	return $_;
}

sub bbcodeButtons #Efia buttons for entry and edit 
{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
	my @smilies = readdir (SM);
	closedir SM;
	print qq\<fieldset class="screen">
			<input type="button" style="font-weight:bold" onClick="surroundText('[b]', '[/b]', document.forms.submitform.content); return false;" value="b" />
			<input type="button" style="font-style:italic" onClick="surroundText('[i]', '[/i]', document.forms.submitform.content); return false;" value="i" />
			<input type="button" style="text-decoration:underline" onClick="surroundText('[u]', '[/u]', document.forms.submitform.content); return false;" value="u" />
			<input type="button" style="color:red" onClick="surroundText('[style=text-align:;color:]', '[/style]', document.forms.submitform.content); return false;" value="style" title="$locale{$lang}->{style}" />
			<input type="button" onClick="surroundText('[list]', '[/list]', document.forms.submitform.content); return false;" value="list" title="$locale{$lang}->{list}" />
			<input type="button" onClick="surroundText('[*]', '[/*]', document.forms.submitform.content); return false;" value="&#8226" title="$locale{$lang}->{point}" />
			<input type="button" onClick="surroundText('[code]', '[/code]', document.forms.submitform.content); return false;" value="&lt; / &gt;" title="$locale{$lang}->{code}" />
			<input type="button" onClick="surroundText('[quote]', '[/quote]', document.forms.submitform.content); return false;" value="&#34quote&#34" title="$locale{$lang}->{quote}" />
			<input type="button" onClick="surroundText('[url]', '[/url]', document.forms.submitform.content); return false;" value="http://" title="$locale{$lang}->{http}" />
            <input type="button" onClick="surroundText('[img]', '[/img]', document.forms.submitform.content); return false;" value="img" title="$locale{$lang}->{img}" />
			<input type="button" onClick="surroundText('[box= title=]','[/box]', document.forms.submitform.content); return false;" value="Box" title="$locale{$lang}->{box}" />
            <input type="button" onClick="surroundText('[gal]','[/gal]', document.forms.submitform.content); return false;" value="$locale{$lang}->{newGallery}"  title="$locale{$lang}->{gal}" />
			<div class="smilies">\;

		foreach (@smilies){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'['.$name.'/]\', \'\', document.forms.submitform.content); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
			print '</div></fieldset><input class="screen" type=image alt="'.$locale{$lang}->{bbcode}.'"><div class=box />';
			BbcodeHelp();
			print'</div>';
}

sub bbcodeComments #Buttons for comments
{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
	my @smilies = readdir (SM);
	closedir SM;
		print qq\<fieldset class="screen">
			<input  type="button" style="font-weight:bold" onClick="surroundText('[b]', '[/b]', document.forms.submitform.comContent); return false;" value="b" />
			<input  type="button" style="font-style:italic" onClick="surroundText('[i]', '[/i]', document.forms.submitform.comContent); return false;" value="i" />
			<input  type="button" style="text-decoration:underline" onClick="surroundText('[u]', '[/u]', document.forms.submitform.comContent); return false;" value="u" />
			<input type="button" onClick="surroundText('[list]', '[/list]', document.forms.submitform.comContent); return false;" value="list" title="$locale{$lang}->{list}" />
			<input  type="button" onClick="surroundText('[*]', '[/*]', document.forms.submitform.comContent); return false;" value="&#8226" title="$locale{$lang}->{point}" />
			<input type="button" onClick="surroundText('[code]', '[/code]', document.forms.submitform.comContent); return false;" value="&lt; / &gt;" title="$locale{$lang}->{code}" />
			<input type="button" onClick="surroundText('[quote]', '[/quote]', document.forms.submitform.comContent); return false;" value="&#34quote&#34" title="$locale{$lang}->{quote}" />
			<input  type="button" onClick="surroundText('[url]', '[/url]', document.forms.submitform.comContent); return false;" value="http://" title="$locale{$lang}->{http}" />
            <input  type="button" onClick="surroundText('[img]', '[/img]', document.forms.submitform.comContent); return false;" value="img" title="$locale{$lang}->{img}" />
            <div class="smilies">\;
        foreach (@smilies){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'['.$name.'/]\', \'\', document.forms.submitform.comContent); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
		print '</div></fieldset><input class="screen" type=image alt="'.$locale{$lang}->{bbcode}.'"><div class=box />';
			BbcodeHelp();
			print'</div>';
	}

		
sub BbcodeHelp 
# Help Page for Bbcode
{	
	if ($lang eq "GER"){
		print <<EOF;
<h1>Bbcode Hilfe</h1>
Text:</br>
<b>[b]fett[/b]</b> <i>[i]kursiv[/i]</i>  <u>[u]unterstrichen[/u]</u></br>
<ul>[list]<li>[*]eine[/*]</li><li>[*]ungeordnete Liste[/*]</li><li>[*]erstellen[/*]</li>[list][/ul]
<ol>[list=1]<li>[*]eine[/*]</li><li>[*]ungeordnete Liste[/*]</li><li>[*]erstellen[/*]</li>[list][/ol]<br />
<br />
<code><pre>[code]Code zeigen[/code]</pre></code><br />
<blockquote>[quote]Jemanden zitieren[/quote]</blockquote>
<br />
Smileys:<br />
[Beispiel/] ertellt einen Smiley. In dem "/images/smilies" Ordner können Smileys hinzugefügt oder verändert werden. Der Dateiname (example.png) wird benutzt um sie aufzurufen.</br>
<br />
Medien:<br />
[img=Titel]hier einen Link oder Pfad zum Bild eintragen[/img]<br />
[url=http://webseite.com]link[/url] <a href=#>link</a><br />
[box=Thumbnail title=Titel]Bild[/box] eine Lightbox, um ein Bild einzufügen oder ähnliches einzufügen Bbcode benutzen. Eine Textbox mit dem style button erstellen.
Falls kein Thumbnail vorhanden ist, ist der Titel ein Link..<br /><br />
Den "Gallerie" Button benutzen um eine Gallerie von Bildern in einem Ordner zu erstellen; 
Pfad zu dem Ordner von dem Hauptverzeichnis des Servers aus angeben, Thumbnails werden entweder aus 
dem Ordner "thumbs" (gleiche Namen wie die Originalbilder) genommen oder die Originalbilder 
werden auf Thumbnailgröße geschrumpft (bei großen Bilder wird das die Ladezeit beeinflussen)<br />
<p style=text-align:center;color:blue;font-size:20px>[style=text-align:center;color:blue;font-size:30px]Text Formattierungsmöglichkeiten [/style]</p>
<br />
Mehr Möglichkeiten: <br />
An dem "Style" Button können die meisten css Optionen benutzt werden; 
Der Einfachkeit halber sind schon einige Optionen hinzugefügt worden, falls es nicht gebraucht wird, leer lassen</br>
<br />
Beispiele für Optionen:<br />
float:left= Textbox links<br />
float:right= Textbox rechts<br />
background-color=Hintergrundsfarbe<br />
width= Weite<br />
height= Höhe</br>
EOF
	}
	else {
		print <<EOF;
<h3>Bbcode help</h3>
<div><br />
Text styling:
<b>[b]bold[/b]</b> <i>[i]italics[/i]</i> <u>[u]underlined[/u]</u></br>
<ul>[list]<li>[*]making[/*]</li><li>[*]an unordered[/*]</li><li>[*]list[/*]</li>[/list]</ul>
<ol>[list=1]<li>[*]making[/*]</li><li>[*]an ordered[/*]</li><li>[*]list[/*]</li>[/list]</ol></br>
<br />
<code><pre>[code]show code[/code]</pre></code><br />
<blockquote>[quote]quote someone[/quote]</blockquote>
</br>
Smilies:<br />
[example/] will produce a smiley. Change pictures or add smilies in the smilies folder, the filename (example.png) is used to create the smiley.</br>
<br />
Media:<br />
[img=title]insert link or path to picture[/img]<br />
[url=http://website.com]link[/url] <a href=#>link</a><br />
<h3>Only in posts not in comments</h3>
[box=thumbnail title=title]image[/box] a lightbox, use the bbcode tags to insert images or textboxes with the style button. Any bbcode can be used in the box.
If there is no thumbnail the title will be clickable.<br /><br />
The "Gallery" button creates a gallery out of pictures in a folder. Insert path from the root of the web-server. Thumbnails should be in a folder called "thumbs" in the picture
folder if it does not exist the script will resize the original pictures (might affect page loading time)
<br /><br />
<p style=text-align:center;color:blue;font-size:20px>[style=text-align:center;color:blue;font-size:30px]text styling options[/style]</p>
More Options: </br>
The style button can take as many css style options as one likes. I already added some options for the lazy, just leave it empty if you don't want it</br>
</br>
some examples for options are:</br>
float:left= textbox left</br>
float:right= textbox right</br>
background-color= background color</br>
width= width</br>
height= height</br></div>
EOF
}
}

1;