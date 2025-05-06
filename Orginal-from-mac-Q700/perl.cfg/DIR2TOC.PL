# THIS SCRIPT CAN NOT RUN BY IT SELF!!!!
# Should be run from a script that contains all 
# necessary variables

# NOTE Macs dont do: 'chdir ../'
	if ($OS=~"MAC"){$dirSep =':';}
	if ($OS=~"WIN")	{$dirSep ='\\';}			
	if ($OS=~"UNIX"){$dirSep ='/';}
	
	$defaultLang = 'SE';  # This should not be edited
#$currLang = 'SE'; This can be set in config.pl or 
#					even before that

	$otherLang= &doLang();
	sub doLang{
		local(@regLang) =(FI,SE,EN,DE,FR);
		local (@tempLang);
		local ($out);
		for(@regLang){
			local($i) = $_;
			next if ($i eq $currLang);

			push (@tempLang,$i);
		}
		$out =join ('|', @tempLang);
		return $out;
	} #end doLang

if ($currLang eq $defaultLang){
	$tocFile = "toc$tocName\.html";
	}
	else{
	$tocFile = "toc$tocName-$currLang\.html";
	}
	
print "\nStart main....\n";
# INIT HTML stuff
# e.g READ CFG-files into memory
# DONT CAHNGE VALUES IN OUTPUT ANYWHERE IN SCRIPT, ONLY READ!
# THEY ARE USED many times.
#INIT start of HTML-File
	open (STYLE, "$cfgDir"."$dirSep"."$fileHead");
	while (<STYLE>){$getHEAD="$getHEAD$_";}
	close STYLE;
	
#INIT dirUp-Part
	open (STYLE, "$cfgDir"."$dirSep"."$fileDirUp");
	while (<STYLE>){$getDIRUP="$getDIRUP$_";}
	close STYLE;

#INIT dirUpCurr-Part
	open (STYLE, "$cfgDir"."$dirSep"."$fileDirUpCurr");
	while (<STYLE>){$getDIRUPCURR="$getDIRUPCURR$_";}
	close STYLE;
	
#INIT Template for file Item 
	open (STYLE, "$cfgDir"."$dirSep"."$fileItemFile");
	while (<STYLE>){$getFILEITEM="$getFILEITEM$_";}
	close STYLE;
	
#INIT Template for Directory Item 
	open (STYLE, "$cfgDir"."$dirSep"."$fileItemDir");
	while (<STYLE>){$getDIRITEM="$getDIRITEM$_";}
	close STYLE;
#INIT End of HTML-file
	open (STYLE, "$cfgDir"."$dirSep"."$fileFoot");
	while (<STYLE>){$getFOOT="$getFOOT$_";}
	close STYLE;	
	
print " Init done\n";
	
# START WITH ROOT DIR!
# TOC for rootDir is not done by sub doDir()
	opendir(DIR,$rootDir) || die "Can't open current \ndirectory: $rootDir";
	@filenames = readdir(DIR);
	closedir(DIR);
	chdir $rootDir;
	
#open the toc.file in ROOT dir
	$tempTocFile = ">$tocFile";
	open (ROOTTOCH, $tempTocFile);
	print ROOTTOCH &startHtml($homeName);
	print ROOTTOCH &dirUpLine("",$homeName,"",0);
	print ROOTTOCH $starItemList;
	for (@filenames) {
		local($i)= $_;
		next if ($i=~ /^\..*/);  #All files that starts with a dot
		next if ($i=~ /.*($dirTypeDeny)/);
		if (!(-d $i)){
			next if ($i!~ /.*\.($fileTypeAallow)$/);
				if ($currLang ne $defaultLang){
					next if ($i!~ /.*\-($currLang)\..*/i);
				}
				else {
					next if ($i=~ /.*\-($otherLang)\..*/i);
				}										#Language filter!
			next if ($i=~ /($fileStartsDeny).*/);
			next if ($i=~ /.*($fileContainsDeny).*/);		
			$title = &getTitle($i);
			print ROOTTOCH &itemLine($i,$title, "F");
		}else{
			push(@toDoDir,$i);	
			$dirtitle = &getDirTitle($i);
			print ROOTTOCH &itemLine("$i/$tocFile",$dirtitle,"D");
		}	
	} #filenames
	print ROOTTOCH $endItemList;
	print ROOTTOCH &endHtml();
	close ROOTTOCH;
print " Root done\n";

# RECURSION I ARRAY
# The "main of main"-Part of the script.
	print " toDolist \(dirs: @toDoDir \)\n";
	print " Starting Subs\n";
		while(@toDoDir){
			$nextDir= pop(@toDoDir);
			print "   starting $nextDir";
			chdir $rootDir;
			&doDir($nextDir);
		}
	print "\n Is toDoList empty\? \-\>@toDoDir\<\-\n";
	
# END RECURSION

#subs

sub doDir{
	local($currDir) = @_;
	local ($a);
	local ($TempCurrDir);
	local ($b);
	
# open a dir and read	
	if ($OS=~"MAC"){$TempCurrDir ="$dirSep$currDir";}	    #MACOS
	if ($OS=~"WIN")	{$TempCurrDir ="$currDir";}				#WINDOWS
	if ($OS=~"UNIX"){$TempCurrDir ="$currDir";}				#UNIX	
	opendir(DIR,$TempCurrDir) || die 
							"Can't open current \ndirectory: $currDir";
	local(@filename) = readdir(DIR);
	closedir(DIR);
	chdir $TempCurrDir;	
#open a toc.file in curr dir
	$tempTocFile = ">$tocFile";
	open (TOCH, $tempTocFile);
	print TOCH &startHtml($currDir);


# IN PROGESS......
# Create Navigation list
local($oneDirUp) ="..\/";
local($dirUp) ="";

#WINDOS ONLY
#local(@path) = split(/\\/,$currDir);
#MAC ONLY
#	local(@path) = split(/:/,$currDir);

	if ($OS=~"MAC"){@path = split(/$dirSep/,$currDir);}	#MACOS
	if ($OS=~"WIN")	{@path = split(/\\/,$currDir);}	#WINDOWS
	if ($OS=~"UNIX"){@path = split(/\//,$currDir);}	#UNIX	


	#INIT dirUp
		local($j)=$#path;
		$dirUp ="..\/"; # this is for rootDir 

		# count all subDirs and put ../ for each
			while ($j--){
				$dirUp .=$oneDirUp;
			}
		$j=$#path;
		print TOCH &dirUpLine("$dirUp$tocFile",$homeName,"",1);
		local ($add);
		local($tPath)="";
		for (@path){
			local($dir)=$_;
			$tPath.="$dir$dirSep";
			$dirUp =substr ($dirUp,3);
			$add .="-";
			local($tTitle)=&getDirTitleABS($tPath);
			print TOCH &dirUpLine("$dirUp$tocFile",$tTitle,$add,$j);
			$j--;
		}	#END of DIRUP

#Start TOC-list		
	print TOCH $starItemList;
	for (@filename) {
		local($i)= $_;
		next if ($i=~ /^\..*/);  #All files that starts with a dot
		next if ($i=~ /.*($dirTypeDeny)/);
		if (!(-d $i)){
			next if ($i!~ /.*\.($fileTypeAallow)$/);
			#Language filter:
				if ($currLang ne $defaultLang){
					next if ($i!~ /.*\-($currLang)\..*/i);
				}else {
					next if ($i=~ /.*\-($otherLang)\..*/i);
				}
			next if ($i=~ /($fileStartsDeny).*/);
			next if ($i=~ /.*($fileContainsDeny).*/);		
			$title = &getTitle($i);
			print TOCH &itemLine($i,$title, "F");		
		}
		else{
			$title = &getDirTitle($i);
			print TOCH &itemLine("$i/$tocFile",$title,"D");	
		$newDir ="$currDir$dirSep$i";
		push(@toDoDir,$newDir);				#VERY IMPORTANT LINE!
		}
	} # End forLoop	
	print TOCH $endItemList;
#END TOC-list

print TOCH &endHtml();
close TOCH;
print "-OK\n";
} #end SUB doDir

# fetch a TITLE from a file
sub getTitle {
	local($in) = @_;
	local($get);
	open(CurrFILE,$in);
	read (CurrFILE,$get,500);
	close CurrFILE;
	if($get=~ m/<TITLE>(.*)<\/TITLE>/i) {
# HTML MATCH
		$title=$1;
	} 
	else {$title=$in;
		#the filename is the most logical!
	}
	return $title;
} # end getTitle


# hamtar TITLE fran en cfgfil for en dir
sub getDirTitle {
	local($in) = @_;
	local($a);
	local($dirTitle);
	local($f);
	local($get);		
#MAC needs Šr ":" for it's relativ paths
	if ($OS=~"MAC"){$a ="$dirSep$in$dirSep$configFile";}	    #MACOS
	if ($OS=~"WIN")	{$a ="$in$dirSep$configFile";}				#WINDOWS
	if ($OS=~"UNIX"){$a ="$in$dirSep$configFile";}				#UNIX	
	open(CFG,$a);
	while (<CFG>){$get="$get$_";}
	close CFG;
			if($get=~ m/TITLE-$currLang:(.*);/) {
			$dirTitle=$1;} 
		else {
		#No CFG file or lang code dosnt exists create one:
		local ($a2) = ">>$a";
			open (CFG, $a2);
			print CFG "TITLE\-$currLang\:$a\;\n";	
			$dirTitle="$in\/";
			close CFG;
		}
		return $dirTitle;
} #end getDirTitle


#Get Directory title by absolut PATH
sub getDirTitleABS {
	local($in) = @_;
	local($a);
	local($dirTitle);
	local($get);		
	$a ="$rootDir$dirSep$in$configFile";
	open(CFG,$a);
	while (<CFG>){$get="$get$_";}
	close CFG;
			if($get=~ m/TITLE-$currLang:(.*);/) {
			$dirTitle=$1;} 
	else {
		$dirTitle="$in\/";
	}
	return $dirTitle;
} #end getDirTitle2

# HTML SUBS, 
# Used for change of 
# No read or write of files!
# So never use filehandle here!
# See in INIT Html
	sub startHtml {
		local($in) = @_;
		local($out) =$getHEAD;
		$out=~ s/TITLEhere/$in $currLang/;
		$out=~ s/TARGEThere/$mainTarget/;	
		return $out;
	} #end StartHtml

sub dirUpLine {
	local($i1,$i2,$prefix,$count) = @_;
	local ($out);
		if ($count==0){	
			$out=$getDIRUPCURR;
			$out=~ s/TITLEhere/$i2/;
			$out=~ s/PrefiXhere/$prefix/;
		}
		else {
			$out=$getDIRUP;
			$out=~ s/URLhere/$i1/;
			$out=~ s/TITLEhere/$i2/;
			$out=~ s/TARGEThere/$tocTarget/;
			$out=~ s/PrefiXhere/$prefix/;
		}
	return $out;
} #end dirUpLine

sub itemLine {
	local($i1,$i2,$i3) = @_;
	local ($out);
	if ($i3 =~ "D"){

		$out=$getDIRITEM;
		$out=~ s/URLhere/$i1/;
		$out=~ s/TITLEhere/$i2/;
		$out=~ s/TARGEThere/$tocTarget/;
	} else {
		$out=$getFILEITEM;
		$out=~ s/URLhere/$i1/;
		$out=~ s/TITLEhere/$i2/;
	}
	return $out;
} #end itemLine

sub endHtml {
	local($in) = @_;
	$out = $getFOOT;
	return $out;
} #end endHtml

print "End main\n";
