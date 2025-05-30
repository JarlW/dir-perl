#Configuration file for Tjalles
#"table" based WEB
print "init params-";

#used insted of $configFile for rootDir
	$homeName ="TableHome";

#The actual name for TableOfContents files...
	$tocName='table';
#contains cleartext for directory  name
#Note that it may contain more than that
	$configFile ='toc.cfg';

#frameTargets!
	$tocTarget= "hankToc";
	$mainTarget ='hankText';

#Skips files and/or directorys that should not show in the TOC
#Note: You do NOT have to deny file types (*.gif) see:$fileTypeAallow
	$dirTypeDeny= "icon|images|cfg"; #applies also on files!
	$fileStartsDeny= "zxweq|toc";
	$fileContainsDeny = "frame|zxweq";

#Allow ONLY filetypes with theese extensions
	$fileTypeAallow = 'html|htm|txt|shtml';


# HTML template files which are used only once during "startUp"
	$fileHead = 'head.cfg';
	$fileDirUp = 'dirUp.cfg';
	$fileDirUpCurr = 'dirUpCurr.cfg';
	$fileItemFile = 'itemLineFile.cfg';
	$fileItemDir = 'itemLineDir.cfg';
	$fileFoot = 'footer.cfg';
		
#lazyness, These should be in files:
	$starItemList='';
	$endItemList='';
	
#END OF PARAMETERS!!!
print "OK";
