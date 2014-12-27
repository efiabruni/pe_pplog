## This is the Configuration file for the blog, it is backed up by pe_Config.pl.bak
## 0 = no; 1 = yes;
## . = in the same path as the pe_pplog.pl and the pe_admin.pl file; .. = one path above
## Edit away!

# Required settings for the blog to work
our $config_adminPass = 'puppy';												# Admin password for adding entries
																				
##If you don't want to change anything else, the rest is optional
#Personal settings
our $config_blogHeader= 'pe_pplog';												# on top of page
our $config_blogFooter='';														# on bottom of page
our $config_blogTitle = 'blog';													# Blog title 

#Folders:																		
our $config_DatabaseFolder ='./blog_data';										# Full path	should be outside of server home, but needs to be read and writable by server
our $config_smiliesFolder = '/pe_pplog/images/smilies';									# Relative path from server home. For the smilies, add and change smilies as you wish
our $config_currentStyleFolder = '/pe_pplog/css';										# Styles folder 
our $config_currentStyleSheet = 'style.css';									# Style sheet name
our $config_tmpFolder = '/tmp';													# path to the tmp folder

#Look and Feel:
our %config_blogSettings = (JQuery=>1, HTTPS=>1, markup=>"plaintext", plugins=>"");
our %config_adminSettings = (JQuery=>1, HTTPS=>1, markup=>"bbcode", plugins=>"notes");

our $lang = "EN";																# Language setting (EN, DE, EL, CUSTOM), for custom language type "CUSTOM" and add translation below at $locale{"CUSTOM"}=
our $config_entriesPerPage = 5;													# For pagination... How many
our $config_maxPagesDisplayed = 5;												# Maximum number of pages displayed at the 
our $config_gmt = -4;															# Your GMT, -4 is Chile
our $config_entriesOnRSS = 0;													# 0 = ALL ENTRIES, if you want a limit, change t

#Menu options:
our $config_menuEntriesLimit = 10;												# Limits of entries to show in the menu
our %config_menuLinks =('pe_pplog'=>'http://tine.pagekite.me/blog', 'Puppy Linux'=>'http://puppylinux.com', 'Pup_pplog'=>'https://code.google.com/p/pplog/');#External links in the menu

our $config_showLatestComments = 1;												# Show latest comments on the menu
our $config_showLatestCommentsLimit = 10;										# Show 10 latest comments
our $config_showHits = 1;														# Want to show how many users are 
our $config_showUsersOnline = 0;												# Wanna show how many users are browsing 
our $config_usersOnlineTimeout = 120;											# How long is an user considered online? In 

#Comments settings:
our $config_allowComments = 1;													# Allow comments
our @config_commentsForbiddenAuthors = qw(admin administrator);					# These are the usernames that normal users, first name is default for Admin comments 
#Security question for comments ('Question'=>'Answer','Question2'=>'Answer2')
our %config_commentsSecurityQuestion =('Spell 4'=>'four','What is two plus three? (spell)'=>'five','What do you call a baby dog?'=>'Puppy');#Password for comments. <a href="?do=contact">Register</a>'

our $config_bbCodeOnCommentaries = 1;											# Allow BBCODE buttons on comments entry page
our $config_commentsMaxLenght = 2000;											# Comment maximum characters
our $config_commentsPerPage = 20;												# How many comments will be shown 									

our $config_sendMailWithNewComment = 0;											# Receive a mail when someone posts a 
our @config_sendMailWithNewCommentMail = ('/usr/bin/sendmail -t','me@example.com');		# Email adress to send mail to (contact and comment). Use local if you want to have the emails appear on the admin site instead 		

#For search engines:
our $config_metaRobots = 'noimageindex';										# Options for search engines: noindex nofollow nosnipped noimageindex  noodp noarchive unavailable_after:[date] none
our $config_metaDescription = 'pe_pplog';				            		    # Description for search engines
our $config_metaKeywords = 'post, perl, blog';			  						# Keywords for search engines...
			
#Security
our $config_randomString = 'zjhd092nmbd20dbJASDK1BFGAB1';						# This is for password encryption... Edit if you wish
our @config_ipBan = qw(202.325.35.145 165.265.26.65);							# 2 random IPS, sorry if it is yours... Just edit if that is the case

#adding things
our $config_contactAddress = ''; 												#for contact form plugin
our @config_uploadFolders = qw(/images /css); 									#path to folder for files from webserver root
our @config_allowedMime = qw(image/ text/css text/html text/plain);			    #MIME types allowed for upload

our $config_customMenuHTMLtop = ''; 											# eg a reddit button: <a target="_blank" href="http://reddit.com/submit?url=http://'.$ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'}.'">Reddit This <img border="0" src="reddit.gif" /></a>';								
our $config_customMenuHTMLbottom = '';											# HTML here, will appear in the bottom of the menu of the main blog
our $config_customHTMLpost = '';												# a place for social buttons
our $config_customHTMLhead = '';												# for any script you might wish to add to the main blog									
our $config_customHTMLadmin = '';												# for adding scripts to the admin page

our %locale;

$locale {"EN"} = {
#Plugins
emails => "Emails", 
notes=> "Notes",
upload=>"Upload File",
editConfig => "Change settings",
contact => "Contact Me",
pplogtohtml => "Archive blog", 
#Head
admin => "Admin",
powered => "Powered by pe_pplog",
#Header
header => "Admin Page",
menu => "Main menu",
index => "Index",
new => "New entry",
pag => "Pages",
plug => "Plugins",
listPag => "List Pages",
archive => "Archive",
log_out => "Log Out",
rss=> "RSS Feeds",
#Menu
search => "Search",
bytitle => "by title",
bycontent => "by content",
entries => "Entries",
categories => "Categories",
comments => "Comments",
listComments => "List comments",
entryby => "Posted by",
links => "Links",
stats => "Stats",
users => "Users online: ",
hits => "Hits: ",
#Log in page
msglog_out => "You have logged out. Goodbye!",
msglogged => "You are logged in. Welcome!",
msgpass => "Wrong password!",
msgcookie => "Please allow cookies.",
msgfile => "Not possible to write in 'tmp' Folder",
pass => "Please enter your password:",
log_in => "Log in",
#Entry form
title => "Title",
bbcode => "Bbcode help",
spancat => "To assign more than one category to a post, use a ' example: category1'category2 ",
ispage => "is a page",
spanpage => "A page is basically a post which is linked in the menu and not displayed normally",
ishtml => "is HTML",
spanhtml => "Check this if the post contains pure html",
subentry => "Submit entry",
newnote => "New Note",
edit => "Edit entry",
edentry => "Save changes",
necessary => "All fields necessary",
#Delete form
delete => "Delete entry",
sure => "Are you sure?",
back => "Go back",
commentdel => "Comment deleted",
#Show entry
noentry => "Sorry, that entry does not exists or it has been deleted.",
e => "Edit",
d => "Delete",
postedon => "Posted on ",
nocomments => "No comments posted yet",
by => "by ",
addcomment => "Add Comment",
delcomment => "Delete Comment",
pages => "Pages: ",
#Messages 
ban => "Sorry, you have been banned",
nopages1 => "No entries yet.",
nopages2 => "Why don't you make one?",
noplugin => "Sorry, the plugin does not seem to be installed!",
deentry => "Entry deleted",
config => "There is something wrong with your Config. file using pe_Config.pl.bak. The blog is working, but maybe not how you want to?",
newcomments => "Newest Comments",
comment => "Comment",
postunder => "Posted under",
#Comments form
toolong1 => "The content is too long! Max characters allowed: ", 
toolong2 => " You typed: ",
commentadd => "Comment added. Thanks ",
commentview => "View comment",
captcha => "You are a spam bot, please go home",
pot => "Honeypot for spam bots, if you are human leave this empty",
question => "Incorrect security answer. Please, try again.",
comtwice=>"Comment has already been posted",
compass => "Wrong password for this nickname. Please try again or choose another nickname.",
newuser => "You are a new user posting here... You will be added to a database so nobody can steal your identity. Remember your password!",
mail => "Hello, I'm sending this mail because of a new comment on your blog: http://$ENV{'HTTP_HOST'}$ENV{'REQUEST_URI'}\nRemember you can disallow this option changing the \$config_sendMailWithNewComment Variable to 0. \nComment content: \n",
subject => "New comment on the pe_pplog",
sendmail => "sendmail nor available!",
author => "Author",
code => "Security Code",
password => "Password",
spancom => "So no one else can use your username to comment",
preview => "Preview Comment",
nocomment => "No comments",
noentries => "No entries created yet.",
#Search
keyword => "The keyword must be at least 4 characters long!",
searchfor => "Search for ",
matches => " match(es) found",
#Archive
Jan=>"January", Feb=>"February", Mar=>"March", Apr=>"April", May=>"May", 
Jun=>"June", Jul=>"July", Aug=>"August", Sep=>"September", Oct=>"October", Nov=>"November", Dec=>"December",
year => "Year",
submit => "Submit",
#Bbcode
newGallery => "Gallery",
makegallery => "Create a new Gallery from pictures in a folder (path)",
style => "use any css style options",
list => "Bulletpoint or odered (list=1) list",
point => "Bulletpoints or numbers",
code => "Show code",
quote => "Quote someone",
http => "Clickable link",
img => "insert an image (path)",
box => "A lightbox (image or text)",
};

$locale {"GER"} = {
preview => "Kommentar anschauen",
emails => "Emails",
newnote => "Neue Notiz",
notes=> "Notizen",
contact => "Kontakt",
pplogtohtml => "Blog archivieren", 
#head
admin => "Administrator ",
powered => "Angetrieben durch pe_pplog",
#header
log_out => "Abmelden",
header => "Administrator Seite",
menu => "Hauptmenü",
index => "Startseite",
new => "Neuer Eintrag",
pag => "Seiten",
plug => "Erweiterungen",
rss => "RSS Feeds",
listPag => "Seiten Auflisten",
archive => "Blogarchiv",
#menu
search => "Suchen",
bytitle => "in der Überschrift",
bycontent => "im Inhalt",
entries => "Einträge",
categories => "Kategorien",
comments => "Kommentare",
listComments => "Kommentare Auflisten",
entryby => "Beitrag von",
links => "Weblinks",
stats => "Statistik",
users => "Besucher online: ",
hits => "Aufrufe: ",
#Log in
msglog_out => "Sie haben sich abgemeldet. Auf Wiedersehen!",
msglogged => "Sie sind angemeldet. Willkommen!",
msgpass => "Falsches Passwort!",
msgcookie => "Bitte erlauben sie Cookies.",
msgfile => "Es ist nicht möglich in den 'tmp' Ordner zu schreiben",
pass => "Geben sie ihr Passwort ein:",
log_in => "Anmelden",
#New entry
title => "Titel",
bbcode => "Bbcode Hilfe",
spancat => "Um mehr als eine Kategorie anzugebne, benutzen sie ein ' Zum Beispiel: Kategorie1'Kategorie2 ",
ispage => "ist eine Seite",
spanpage => "Eine Seite ist ein Eintrag, der einen separaten Menüeintrag hat und nicht normal angezeigt wird",
ishtml => "ist HTML",
spanhtml => "Dies markieren falls der Eintrag reines html ist",
subentry => "Eintrag hinzufügen",
edit => "Eintrag bearbeiten",
edentry => "Änderungen speichern",
#Delete entry
delete => "Eintrag löschen",
sure => "Sind sie sicher?",
back => "Zurück",
#Comments
necessary => "Alle Felder müssen ausgefüllt sein!",
toolong1 => "Der Eintrag ist zu lang. Maximal ",
toolong2 => "Zeichen erlaubt. Länge ihres Eintrags: ", 
commentadd => "Kommentar hinzugefügt. Danke ",
commentview => "Kommentar ansehen",
commentdel => "Kommentar gelöscht",
#Entry
noentry => "Dieser Eintrag existiert nicht oder wurde gelöscht",
e => "Bearbeiten",
d => "Löschen",
postedon => "Erstellt am ",
nocomments => "Noch keine Kommentare vorhanden.",
by => "bei ",
addcomment => "Kommentar hinzufügen",
delcomment => "Kommentar löschen",
pages => "Seiten: ",
nopages1 => "Noch keine Einträge vohanden.",
nopages2 => "Möchten sie einen erstellen?",
noplugin => "Die Erweiterung scheint nicht vorhanden zu sein.",
deentry => "Eintrag gelöscht",
config => "Ein Fehler ist in der Konfigurationsdatei aufgetreten, pe_Config.pl.bak wird verwendet. Der Blog funktioniert, aber eventuell nicht nach ihren Einstellungen.", 
newcomments => "Neueste Kommentare",
comment => "Kommentar",
postunder => "Eingetragen unter",
captcha => "Hallo Spambot, hau ab",
question => "Die Antwort auf die Sicherheitsfrage ist falsch, bitte versuchen sie es erneut.",
comtwice=>"Das Kommentar existiert schon",
compass => "Falsches Passwort für diesen Benutzernamen. Versuchen sie es erneut, oder wählen sie einen anderen Namen.",
newuser => "Sie sind neu auf dieser Seite. Ihr Benutzername wird der Datenbank hinzugefügt, bitte merken sie sich ihr Passwort.", 
mail => "Guten Tag! Ein neuer Kommentar wurde auf Ihrem Blog: http://$ENV{'HTTP_HOST'}$ENV{'REQUEST_URI'} hinterlassen. nSie können diese Option verbieten indem Sie die Variabel \$config_sendMailWithNewComment zu 0 ändern \n\nKommentar:\n",
subject => "Ein neuer Kommentar auf dem pe_pplog",
author => "Benutzername",
code => "Sicherheitscode",
password => "Passwort",
spancom => "Damit niemand anders Ihrem Benutzernamen nutzen kann",
nocomment => "Keine Kommentare",
noentries => "Noch keine Einträge vorhanden.",
#Search
keyword => "Das Suchwort muss mindestens 4 Zeichen lang sein",
searchfor => "Suche nach ",
matches => " Treffer gefunden",
#Archive
Jan=>"Januar", Feb=>"Februar", Mar=>"März", Apr=>"April", May=>"Mai", 
Jun=>"Juni", Jul=>"Juli", Aug=>"August", Sep=>"September", Oct=>"Oktober", Nov=>"November", Dec=>"Dezember",
year => "Jahr",
sendmail => "Sendmail nicht verfügbar!",
editConfig => "Einstellungen Ändern",
submit => "Senden",
newGallery => "Gallerie",
makegal => "Neue Gallerie erstellen aus Bildern in einem Ordner (Pfad)",
ban => "Leider wurden Sie gesperrt",
#bbcode
style => "css Bezeichnungen hinzufügen",
list => "Ungeordnete oder geordnete (list=1) Liste",
point => "Listenpunkt oder Nummer",
code => "Code anzeigen",
quote => "Jemanden zitieren",
http => "Einen anklickbaren Link erstellen",
img => "Ein Bild einfügen (Pfad)",
box => "Eine 'Lightbox' eifügen (Bild oder Text)",
pot => "Honigpot für Spambots, bitte nicht ausfüllen",

};

$locale {"EL"} = {
pplogtohtml => "Archive blog", 
upload=>"Upload File",
preview => "Preview Comment",
emails => "Emails",
newnote => "New Note",
viewnote => "View Notes",
notes=> "Notes",

admin => "Admin",
powered => "Με τη δύναμη του",
log_out => "Log Out",
header => "Admin Page",
menu => "Βασικό μενού",
index => "Αρχική σελίδα",
new => "Νέα δημοσίευση",
pag => "Σελίδες",
listPag => "Σελίδες",
plug => "Plugins",
archive => "Αρχείο άρθρων",
rss=> "Ροή νέων",
search => "Αναζήτηση",
bytitle => "Τίτλοι ",
bycontent => "Περιεχόμενο",
entries => "Τελευταία άρθρα",
categories => "Κατηγορίες",
comments => "Σχόλια",
listComments => "Εμφάνιση όλων",
entryby => " από τον/την",
links => "Σύνδεσμοι",
stats => "Στατιστικά",
users => "Ενεργοί χρήστες: ",
hits => "Επισκέψεις: ",
msglog_out => "You have logged out. Goodbye!",
msglogged => "You are logged in. Welcome!",
msgpass => "Λάθος κωδικός",
msgcookie => "Please allow cookies.",
msgfile => "Not possible to write in 'tmp' Folder",
pass => "Please enter your password:",
log_in => "Εντάξει",
title => "Τίτλος",
bbcode => "Bbcode help",
spancat => "To assign more than one category to a post, use a ' example: category1'category2 ",
ispage => "Είναι σελίδα ",
spanpage => "Μια σελίδα είναι στην ουσία μία δημοσίευση που εμφανίζεται στο μενού και όχι στον χώρο δημοσιεύσεων.",
ishtml => "is HTML",
spanhtml => "Check this if the post contains pure html",
subentry => "Εντάξει",
edit => "Επεξεργασία",
edentry => "Εντάξει",
delete => "Διαγραφή",
sure => "Are you sure?",
back => "Επιστροφή",
necessary => "Όλα τα πεδία είναι απαραίτητα!",
toolong1 => "Το περιεχόμενο είναι πολύ μεγάλο! Επιτρέπονται μέχρι ", 
toolong2 => " χαρακτήρες, εσύ πληκτρολόγησες  ",
commentadd => "Το σχόλιο καταχωρήθηκε. Ευχαριστώ ",
commentview => "View comment",
commentdel => "Το σχόλιο διαγράφηκε.",
noentry => "Λυπάμαι, η δημοσίευση που ψάχνεις δεν υπάρχει ή έχει διαγραφεί.",
e => "Επεξεργασία",
d => "Διαγραφή",
postedon => "Δημοσιεύθηκε στις ",
nocomments => "Δεν υπάρχουν σχόλια ακόμη",
by => "από τον/την ",
addcomment => "Προσθήκη σχολίου",
delcomment => "Διαγραφή σχολίου",
pages => "Σελίδες:  ",
nopages1 => "No entries yet",
nopages2 => "Why don't you κάνεις μία?",
noplugin => "Sorry, the plugin does not seem to be installed!",
deentry => "Η καταχώρηση διαγράφηκε.",
config => "There is something wrong with your Config. file using pe_Config.pl.bak. The blog is working, but maybe not how you want to?",
newcomments => "Newest Comments",
comment => "Τίτλος σχολίου",
postunder => "Posted under",
captcha => "You are a spam bot, please go home",
question => "Απάντησες λάθος. Προσπάθησε ξανά.",
comtwice=>"Comment has already been posted",
compass => "Το όνομα $author χρησιμοποιείται ήδη ή ξέχασες τον κωδικό σου. Επέλεξε άλλο όνομα ή πληκτρολόγησε τον κωδικό σου σωστά.",
newuser => "Είσαι νέος χρήστης εδώ...  Θα προστεθείς στη βάση δεδομένων ώστε να μην μπορεί κανείς άλλος να χρησιμοποιήσει την ταυτότητα σου. Να θυμάσαι τον κωδικό σου!!",
mail => "Hello, I'm sending this mail because of a new comment on your blog: http://$ENV{'HTTP_HOST'}$ENV{'REQUEST_URI'}\nRemember you can disallow this option changing the \$config_sendMailWithNewComment Variable to 0. \nComment content: \n",
subject => "New comment on the pe_pplog",
author => "Συντάκτης",
code => "Κείμενο ασφαλείας",
password => "Κωδικός",
spancom => "So no one else can use your username to comment",
nocomment => "Κανένα σχόλιο",
noentries => "Καμία καταχώρηση ακόμη.'",
keyword => "Η φράση πρέπει να περιέχει τουλάχιστον 4 χαρακτήρες!",
searchfor => "Αναζήτηση για ",
matches => "  αποτελέσματα βρέθηκαν",
Jan=>"January", Feb=>"February", Mar=>"March", Apr=>"April", May=>"May", 
Jun=>"June", Jul=>"July", Aug=>"August", Sep=>"September", Oct=>"October", Nov=>"November", Dec=>"December",
year => "Χρονιά",
contact => "Contact Me",
sendmail => "sendmail nor available!",
submit => "Submit",
newGallery => "Gallery",
makegallery => "Create a new Gallery from pictures in a folder (path)",
ban => "Λυπάμαι, έχεις αποκλειστεί.",
style => "use any css style options",
list => "Bulletpoint or odered (list=1) list",
point => "Bulletpoints or numbers",
code => "Show code",
quote => "Quote someone",
http => "Clickable link",
img => "insert an image (path)",
box => "A lightbox (image or text)",
pot => "Honeypot for spam bots, if you are human leave this empty",
};

$locale {"ES"} = {
pplogtohtml => "Archivar el blog", 
comtwice=>"Ya existe el commentario",
preview => "Ver Commentario",
emails => "Correos electrónicos",
newnote => "Nuevas Notas",
notes=> "Notas",
contact => "Contacto",

admin => "Administrador",
powered => "Blog de pe_pplog",
log_out => "Salir",
header => "Página de Administrador",
menu => "Menú principal",
index => "Inicio",
new => "Nueva Entrada",
pag => "Páginas",
plug => "Plugins",
listPag => "Poner Páginas",
archive => "Archivo",
rss=> "RSS",
search => "Buscar",
bytitle => "del título",
bycontent => "del contenido",
entries => "Entradas",
categories => "Categorías",
comments => "Comentarios",
listComments => "Poner Comentarios",
entryby => "Anuncio de",
links => "Enlaces",
stats => "Estadística",
users => "Visitantes ahora: ",
hits => "Visitas: ",
msglog_out => "Ha salido. ¡Adiós!",
msglogged => "Ha accedido. ¡Bienvenido!",
msgpass => "¡La contraseña es incorrecto!",
msgcookie => "Por favor acepte cookies.",
msgfile => "No puede escribir en la carpeta 'tmp'",
pass => "Por favor ingresa su contraseña",
log_in => "Acceder",
title => "Titulo",
bbcode => "Ayuda Bbcode",
spancat => "De asignar más de una categoría a una entrada, use un ' por ejemplo: categoría1'categoría2 ",
ispage => "es una página",
spanpage => "Una página es básicamente una entrada que está enlazado en el menú y no se muestra normalmente",
ishtml => "es HTML",
spanhtml => "Marka esta opción si la entrada contiene HTML puro",
subentry => "Publicar entrada",
edit => "Editar entrada",
edentry => "Guardar cambios",
delete => "Borrar entrada",
sure => "Está seguro?",
back => "Volver",
necessary => "Todos los campos necesarios",
toolong1 => "El contenido es demasiado largo! Caracteres máximo permitidos: ", 
toolong2 => " Ha escrito: ",
commentadd => "Comentario añadido. Gracias ",
commentview => "Ver comentario",
commentdel => "Comentario eliminado",
noentry => "Lo siento, esta entrada no existe o ha sido borrada.",
e => "Editar",
d => "Borrar",
postedon => "Publicado en ",
nocomments => "No hay comentarios publicados aún",
by => "de ",
addcomment => "Deja comentario ",
delcomment => "Borrar comentario",
pages => "Páginas: ",
nopages1 => "No hay páginas aún.",
nopages2 => "Quiere hacer una?",
noplugin => "¡Lo siento, el plugin no parece estar instalado!",
deentry => "Entrada borrado",
config => "Hay algo mal con su configuración. Presentar con pe_Config.pl.bak. El blog tal vez no está funcionando, como usted quiere?",
newcomments => "Comentarios recientes",
comment => "Comentario",
postunder => "Publicado en",
captcha => "Adíos spam bot",
question => "Respuesta de seguridad es incorrecto. Por favor, inténtelo de nuevo.",
compass => "Contraseña incorrecta para este nombre de usuario. Por favor inténtelo de nuevo o elija otro nombre.",
newuser => "Usted es un nuevo usuario publicar aquí...Su nombre de usuario será añadido a una base de datos. ¡Recuerde su contraseña!",
mail => "Hola, Estoy enviando este correo porque hay un nuevo commentario en su blog: http://$ENV{'HTTP_HOST'}$ENV{'REQUEST_URI'}\nRecuerde que usted puede rechazar esta opción de cambiar el  variable \$config_sendMailWithNewComment a 0\n\nCommentario:\n",
subject => "Nuevo comentario en el pe_pplog",
author => "Usario",
code => "Código de seguridad",
password => "Contraseña",
spancom => "Así que nadie puede usar su nombre de usuario para comentar",
nocomment => "0 comentarios",
noentries => "No hay entradas publicadas aún.",
keyword => "La palabra clave debe tener al menos 4 caracteres de largo!",
searchfor => "Buscar ",
matches => " coincidencia(s) encontrada(s).",
Jan=>"Enero", Feb=>"Febrero", Mar=>"Marzo", Apr=>"Abril", May=>"Mayo", 
Jun=>"Junio", Jul=>"Julio", Aug=>"Augosto", Sep=>"Septiembre", Oct=>"Octubre", Nov=>"Noviembre", Dec=>"Diciembre",
year => "Año",
sendmail => "sendmail no es instalado!",
editConfig => "Configuración",
submit => "Confirmar",

newGallery => "Galería",
makegallery => "Crear una nueva galería de imágenes de una carpeta",
ban => "Lo siento, usted ha sido prohibido",
style => "Utilizar opciónes de estilo css",
list => "Lista desordenada o ordenada(list=1)",
point => "Punto de viñeta o numeros",
code => "Monstrar código",
quote => "Citar a alguien",
http => "enlace",
img => "insertar una imagen (camino)",
box => "Una caja de luz (imagen o texto)",
pot => "Una trampa por los spam bots, por favor no llenarlo",
};

$locale {"CUSTOM"} =  {
#Plugins
emails => "Emails", 
notes=> "Notes",
upload=>"Upload File",
editConfig => "Change settings",
contact => "Contact Me",
#Head
admin => "Admin",
powered => "Powered by pe_pplog",
#Header
header => "Admin Page",
menu => "Main menu",
index => "Index",
new => "New entry",
pag => "Pages",
plug => "Plugins",
listPag => "List Pages",
archive => "Archive",
log_out => "Log Out",
rss=> "RSS Feeds",
#Menu
search => "Search",
bytitle => "by title",
bycontent => "by content",
entries => "Entries",
categories => "Categories",
comments => "Comments",
listComments => "List comments",
entryby => "Posted by",
links => "Links",
stats => "Stats",
users => "Users online: ",
hits => "Hits: ",
#Log in page
msglog_out => "You have logged out. Goodbye!",
msglogged => "You are logged in. Welcome!",
msgpass => "Wrong password!",
msgcookie => "Please allow cookies.",
msgfile => "Not possible to write in 'tmp' Folder",
pass => "Please enter your password:",
log_in => "Log in",
#Entry form
title => "Title",
bbcode => "Bbcode help",
spancat => "To assign more than one category to a post, use a ' example: category1'category2 ",
ispage => "is a page",
spanpage => "A page is basically a post which is linked in the menu and not displayed normally",
ishtml => "is HTML",
spanhtml => "Check this if the post contains pure html",
subentry => "Submit entry",
newnote => "New Note",
edit => "Edit entry",
edentry => "Save changes",
necessary => "All fields necessary",
#Delete form
delete => "Delete entry",
sure => "Are you sure?",
back => "Go back",
commentdel => "Comment deleted",
#Show entry
noentry => "Sorry, that entry does not exists or it has been deleted.",
e => "Edit",
d => "Delete",
postedon => "Posted on ",
nocomments => "No comments posted yet",
by => "by ",
addcomment => "Add Comment",
delcomment => "Delete Comment",
pages => "Pages: ",
#Messages 
ban => "Sorry, you have been banned",
nopages1 => "No entries yet.",
nopages2 => "Why don't you make one?",
noplugin => "Sorry, the plugin does not seem to be installed!",
deentry => "Entry deleted",
config => "There is something wrong with your Config. file using pe_Config.pl.bak. The blog is working, but maybe not how you want to?",
newcomments => "Newest Comments",
comment => "Comment",
postunder => "Posted under",
#Comments form
toolong1 => "The content is too long! Max characters allowed: ", 
toolong2 => " You typed: ",
commentadd => "Comment added. Thanks ",
commentview => "View comment",
captcha => "You are a spam bot, please go home",
pot => "Honeypot for spam bots, if you are human leave this empty",
question => "Incorrect security answer. Please, try again.",
comtwice=>"Comment has already been posted",
compass => "Wrong password for this nickname. Please try again or choose another nickname.",
newuser => "You are a new user posting here... You will be added to a database so nobody can steal your identity. Remember your password!",
mail => "Hello, I'm sending this mail because of a new comment on your blog: http://$ENV{'HTTP_HOST'}$ENV{'REQUEST_URI'}\nRemember you can disallow this option changing the \$config_sendMailWithNewComment Variable to 0. \nComment content: \n",
subject => "New comment on the pe_pplog",
sendmail => "sendmail nor available!",
author => "Author",
code => "Security Code",
password => "Password",
spancom => "So no one else can use your username to comment",
preview => "Preview Comment",
nocomment => "No comments",
noentries => "No entries created yet.",
#Search
keyword => "The keyword must be at least 4 characters long!",
searchfor => "Search for ",
matches => " match(es) found",
#Archive
Jan=>"January", Feb=>"February", Mar=>"March", Apr=>"April", May=>"May", 
Jun=>"June", Jul=>"July", Aug=>"August", Sep=>"September", Oct=>"October", Nov=>"November", Dec=>"December",
year => "Year",
submit => "Submit",
#Bbcode
newGallery => "Gallery",
makegallery => "Create a new Gallery from pictures in a folder (path)",
style => "use any css style options",
list => "Bulletpoint or odered (list=1) list",
point => "Bulletpoints or numbers",
code => "Show code",
quote => "Quote someone",
http => "Clickable link",
img => "insert an image (path)",
box => "A lightbox (image or text)",

pplogtohtml => "Archive blog", #
};

return 1;

#Changelog for Config options:

#Taken out $config options are:
#$allow Bbcode buttons 
#$config_useWYSIWYG 
#$config_allowHMTLOnEntries (is now a checkbox)
#$config_textAreaCols  and Rows (set to 15 and 50)
#$config_searchMinLength hardcoded to 4	
#$config:commentsDescending and set newest first as default
#$config_onlyNumbersOnCAPTCHA and  $config_CAPTCHALenght (set 8 numbers and letters as default )
#$config_showGmtOnFooter 
#$config_allowReddit (replace by custom html)
#$config_allowCustomHTML 
#$config_menuLinksHeader

#Added $config options are: 
#$config_blogHeader 
#$config_blogFooter
#$config_tmpFolder
#$config_customHTMLtop (in menu)
#$config_customHTMLpost
#$config_customHTMLhead (for scripts)
#$config_DatabaseFolder
#$config_serverRoot
#@config_pluginsAdmin
#@config_pluginsBlog
