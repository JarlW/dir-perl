#Tjalles skapa toc-file i ett dir-träd!
# 11-nov-97-Tjalle - skapad
# 12-nov-97-Tjalle - overförd till SDC
# 13-nov-97-Tjalle - implemntering av OS-specifikadelar
#                    verkar att fungera i Mac och Win
#                    Fick recursionen att fungera!!!(på Mac)

#kommentera bort felaktiga OS

#$OS="MAC";
$OS="WIN";
#$OS="UNIX";

# OBS Macar klarar inte av: chdir "../"
#MACOS
	if ($OS=~"MAC"){
		$dirSep =':';
	#	$rootDir='FATSO:perl:tjs';	
		$rootDir='FATSO:dokumentit:www-stuff';	
	}
#WINDOWS
	if ($OS=~"WIN")	{
		$dirSep ='\\';	
		$rootDir='H:\sdc\documentation';
	}
#UNIX				
	if ($OS=~"UNIX"){
		$dirSep ='/';
	}

$configFile ='toc.cfg';
$tocFile = 'toctest.html';
$tocTarget= "hankToc";  
$mainTarget ='hankText';
$fileTypeDeny = "css|gif|cfg|pl";
$cfgDir="perl\.cfg";
$htmlHead = 'head.cfg';


print "\nstart....\n";
	opendir(DIR,$rootDir) || die "Can't open current \ndirectory: $rootDir";
	@filenames = readdir(DIR);
	closedir(DIR);
	chdir $rootDir;	

#open the toc.file in ROOT dir
	$tempTocFile = ">$tocFile";
	open (ROOTTOCH, $tempTocFile);
	print ROOTTOCH &startHtml($currDir);
	print ROOTTOCH "<B>HOME</B><BR><HR>";
	print ROOTTOCH "<UL>";
for (@filenames) {
	chdir $rootDir;
	next if $_ eq '.';
	next if $_ eq '..';
	next if ($_=~ /(.*)frame(.*)/);
	next if $_ eq $tocFile;
	next if ($_=~ /toc(.*)/);
	next if ($_=~ /(.*)\.($fileTypeDeny)/);
	if (!(-d $_)){
		$title = &getTitle($_);
		print ROOTTOCH &itemLine($_,$title, "F");

	}
	else{
		$dirtitle = &getDirTitle($_);
		print ROOTTOCH &itemLine("$_/$tocFile",$dirtitle,"D");	
			push(@toDoDir,$_);
	}
} #filenames

print ROOTTOCH "</UL>";
print ROOTTOCH &endHtml();
close ROOTTOCH;



# RECURSION I ARRAY
print "toDolist....\n";
print @toDoDir;
print "\nStarting Subs....\n";
while(@toDoDir){
$nextDir= pop(@toDoDir);
print "starting... $nextDir";
	chdir $rootDir;
	&doDir($nextDir);
print "..Done\n";
}
print "is it empty\? @toDoDir\n";









#subs

sub doDir{
		local($currDir) = @_;
	local ($a);
	local ($TempCurrDir);
	local ($b);
	if ($OS=~"MAC"){$TempCurrDir ="$dirSep$currDir";}	    #MACOS
	if ($OS=~"WIN")	{$TempCurrDir ="$currDir";}				#WINDOWS
	if ($OS=~"UNIX"){$TempCurrDir ="$currDir";}				#UNIX	

# open a dir and read
	opendir(DIR,$TempCurrDir) || die "Can't open current \ndirectory: $currDir or";
	local(	@filename) = readdir(DIR);
	closedir(DIR);

	chdir $TempCurrDir;


#open a toc.file in curr dir
	$tempTocFile = ">$tocFile";
	open (TOCH, $tempTocFile);
	print TOCH &startHtml($currDir);


# IN PROGESS......

# Create Navigation list



#WINDOS ONLY
	local(@path) = split(/\\/,$currDir);
		local($j)=$#path;
	print "\n$_ and j: $j\n";
		for (@path){
			print "$j--";
			#$b="";
			#$b ="..\/$_";
	print TOCH "<B>$_\<\/B\>\<BR\>";	

		}

print TOCH "<B><A HREF=\"\.\.\/$tocFile\" TARGET=\"$tocTarget\">UP</A>\<\/B\>\<BR\>";
		local($TempTitle)=&getTitle($configFile);
	#print TOCH "<B>$TempTitle</B><BR><HR>";
	print TOCH "<UL>";
	for (@filename) {
		next if $_ eq '.';
		next if $_ eq '..';
		next if ($_=~ /(.*)frame(.*)/);
		next if ($_=~ /(.*)\.($fileTypeDeny)/);
		next if ($_=~ /toc(.*)/);
		if (!(-d $_)){
			$title = &getTitle($_);
			print TOCH &itemLine($_,$title, "F");		
		}
		else{
			$title = &getDirTitle($_);
			print TOCH &itemLine("$_/$tocFile",$title,"D");	
		#	print  "  $_, $title\n";
		$newDir ="$currDir$dirSep$_";
#print "\nNewDir:$newDir\n";
		push(@toDoDir,$newDir);

		}

	} # End forLoop
print TOCH "</UL>";
print TOCH &endHtml();
close TOCH;

} #end SUB doDir




# hamtar TITLE i en fil
sub getTitle {
	local($in) = @_;
	open(CurrFILE,$in);
	$f ="400";
	read (CurrFILE,$get,$f);
	close CurrFILE;
	if($get=~ m/<TITLE>(.*)<\/TITLE>/) {
		$title=$1;
	} 
	else {
		$title=$in;
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
#KOLLA OS Har inte hittat annan lšsning (MACAR behšver : fšr current dir
	if ($OS=~"MAC"){$a ="$dirSep$in$dirSep$configFile";}	    #MACOS
	if ($OS=~"WIN")	{$a ="$in$dirSep$configFile";}				#WINDOWS
	if ($OS=~"UNIX"){$a ="$in$dirSep$configFile";}				#UNIX	
	open(CurrFILE,$a);
	$f ="45";
	read (CurrFILE,$get,$f);
	close CurrFILE;
	if($get=~ m/<TITLE>(.*)<\/TITLE>/) {
		$dirtitle=$1;
	} 
	else {
		$dirtitle=$in;
	}
	return $dirtitle;
	
} #end getDirTitle


# HTML SUBS, 
# endast for att printa html!
# varken las eller skriv filer
sub startHtml {
	local($in) = @_;
	local($style) ="";
	open (STYLE, "$rootDir$dirSep"."$cfgDir$dirSep"."$htmlHead");
	while (<STYLE>){
		$style="$style$_";
	}
	if($style=~ s/<TITLE>(.*)<\/TITLE>/<TITLE>TOC for $in<\/TITLE>/)
		{$Style=$1;} 
	if($style=~ s/<BASE TARGET=\"(.*)\">/<BASE TARGET=\"$mainTarget\">/) 
		{$Style="$1";} 
	close STYLE;
	return $style;

} #end StartHtml

sub endHtml {
	local($in) = @_;
	$out ="\n</BODY>\n</HTML>";
	return $out;
} #end endHtml

sub itemLine {
	local($i1,$i2,$i3) = @_;
	if ($i3 =~ "D"){
		$out ="<LI><B><A HREF=\"$i1\" TARGET=\"$tocTarget\">$i2</A></B>\n";
	} else {
		$out ="<LI><A HREF=\"$i1\">$i2</A><BR>\n";
	}
	return $out;
} #end itemLine
