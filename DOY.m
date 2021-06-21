function [day_of_year] = DOY( year,month,day )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%判断输入的年份是不是闰年%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mod(year, 400)==0
    leap_day=1;%如果输入的年数能被400，整除，则说明这一年是闰年
elseif (mod(year,4)==0)&&(mod(year,100)~=0)
    leap_day=1;%如果输入的年数能被4整除，但是不能被100整除，则说明这一年是闰年
elseif (mod(year,100)==0)&&(mod(year,400)~=0)
    leap_day=0;%如果输入的年数能被100整除，但是不能被400整除，则说明这一年不是闰年
else
    leap_day=0;
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%输入月份的天数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch(month)
    case(1)
      day_of_year=day;
    case(2)
      day_of_year=day+31;
    case(3)
      day_of_year=day+31+28+leap_day;
    case(4)
      day_of_year=day+2*31+28+leap_day;
    case(5)
      day_of_year=day+2*31+28+30+leap_day; 
    case(6)
      day_of_year=day+3*31+28+30+leap_day;
    case(7)
      day_of_year=day+3*31+28+2*30+leap_day;
    case(8)
      day_of_year=day+4*31+28+2*30+leap_day;
    case(9)
      day_of_year=day+5*31+28+2*30+leap_day;
    case(10)
      day_of_year=day+5*31+28+3*30+leap_day;
    case(11)
      day_of_year=day+6*31+28+3*30+leap_day;
    case(12)
      day_of_year=day+6*31+28+4*30+leap_day;
end

end

