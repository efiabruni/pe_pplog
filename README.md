#Licenses:
The original PPLOG version 1.1b was coded by Federico Ramirez (fedekun)
and is licensed under the GNU Public License v3 (see LICENSE in the /blog folder).

Thanks to Scott Jarvis (sc0ttman), Chris (Catdude), Grant (Smokey01) and Jamesbond for suggestions and pointing out bugs. See comments in the script.

The smilies used in this blog are by lmproulx (http://www.picto-rama.blogspot.com/) and have been released into the public domain.

#Changelog:
The full changelog for the pe_pplog can be found in CHANGELOG in the /blog folder.

#Installation:
Move this folder (pe_pplog) to the root of your web server.   
 Rename HTACESS => .htacces

Test:(Start your webserver) and point your browser to http://localhost/pe_pplog, you should see the blog main page with the welcome message   
 The admin page should be at http://localhost/pe_pplog/pe_admin.pl

Open the pe_Config.pl file in a text editor.   
 set your password

Making the posts and comments folders writeable for the webserver   
Find out the username and usergroup for your webserver (traditionally it is "nobody")     
 open a terminal       
 type in "chown -R username:usergroup /the path to /blog" and enter


Test again:(Start your webserver) and point your browser to http://localhost/pe_pplog
you should see the blog main page with the welcome message. Write your first post :)

Change other options in pe_Config.pl according to your liking   
  If you want to change the name of the subdirectory (eg from pe_pplog to blog) change the path to the css and smilies folders    
Styling options can be changed in css (open with text editor)    
If you have old posts (from pup_pplog) you want to import into the new pplog you can find a script on the website: http://tine.pagekite.me/blog?viewDetailed=00035

#Trouble?
Error message: Object not found... Did you put the files in the root of your webserver?     
copy and paste the files to the root of the web server.      
Did you type the correct path into the browser?    

Error message: Permission denied...    
You might have to change the permissions for them to be executable for your webserver (chmod a+x /path../to../pe_pplog.pl and pe_admin.pl)     
Is your server set up to execute CGI (perl) scripts? (look in the config file of your web server)     
Sometimes when running cgi scripts from cgi-bin, they need to be renamed: pe_pplog.pl -> pe_pplog (eg. in the lampp webserver)      

Error message: Server not found... Is the webserver running?

Error message: Software error... Have you given the correct path to the /blog folder as
described above?     
Have you changed the pe_Config.pl file lately? There might be a syntax error (most of the time a missing ' or ;)!      

Cannot write new posts/comments... Does the webserver have the permission to write into the /posts and /comments folder?      
See making the posts and comments folder writeable above
