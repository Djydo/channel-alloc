BEGIN{
FS=" "
}
{if (NR > 48){
  if(NR < 58){ 
    printf "%d %.2f %s\n",$3,$8,$14
  }
  if((NR > 57)&&(NR < 79)){
    printf "%d %.2f %s\n",$3,$7,$13
  }
}}
