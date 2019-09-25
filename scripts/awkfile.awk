#!/usr/bin/awk -f

# usage command
# prints the headers information and filter contents
# prints aggregate power,
#./awkfile.awk horst_now.log  
BEGIN { FS=" "; OFS=", "
	s = 0; r = 0; avgRate = 0;
	#print "Power\tFrequency\tRate\tFrequency\tChannel" 
}
{ 
  #print $6"\t"$9"\t"$10"\t"$11"\t"$15 
  
  if ($6 != 0){
      s += 10 ^ ($6/10);
      r += $10;
      lines ++;     
  }
  PwrTotal = 10 *(log(s)/log(10));
  if (NR != 0){
      avgRate = r/NR;
  }
}
END {print PwrTotal, avgRate;}


 
