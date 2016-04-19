use strict;
use warnings;

foreach(@ARGV){
    open(FILE,$_) or die"$!";
    foreach(<FILE>){
	if((/^>/)){
	    print;
	}else{
	    s/u/T/ig;
	    s/a/A/ig;
	    s/g/G/ig;
	    s/c/C/ig;
	    print;
	}
    }
    close(FILE);
}
