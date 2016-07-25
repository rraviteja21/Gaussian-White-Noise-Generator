% function to calculate logarithm coeffients
clear all;
close all;
fileID = fopen('coeff.txt', 'w+');
sum =double(1);
x = linspace(1, 2-double(2.2737367544323205947879765625e-13), 256 );
y1= log(x);
for i =[0:255]
  xp = linspace(sum ,sum + double(0.00390625), 256 );
  y= log(xp);
  m = polyfit(xp, y,2);
  sum = sum + double(0.00390625);
  temp =  bitshift ( sfi( m(1),64), -16); 
  temp_1 = sfi(temp, 64);     %C2 >> 16        (13,11)
  nTBP = numerictype(1,13,12); 
  m_c2 = quantize(temp_1, nTBP, 'Round', 'Saturate');

    
  temp1 = sfi(m(1),64) * sfi(2, 64);   % 2 * C2
  temp2 = fi(i/256,0,64);
  temp3 = sfi(temp1 * temp2,64);       % 2C2*x_e
  temp4 = sfi(m(2),64);                 % C1
  temp5 = sfi( temp3 + temp4, 64);
  temp6 = bitshift( sfi( temp5, 64), -8 );
  nTBP1 = numerictype(0,22,22);
  m_c1 = quantize(temp6, nTBP1, 'Round', 'Saturate');                   %2C2*x_e + C1
   
 t_1 =  fi(i/256,0,64) * fi(i/256,0, 64);
 t_2 = sfi(m(1),64) * sfi(t_1, 64);      % C2 * x_e * x_e
 t1_1 = sfi(m(2), 64) * fi(i/256,0,64);      % C1 * x_e  
 t1_2 = sfi(m(3), 64);                      %C0
 t1_3 = sfi(t_2 + t1_1 + t1_2, 64);
 nTBP2 = numerictype(1,30,28);
 m_c0 = quantize(t1_3, nTBP2, 'Round', 'Saturate');  

%  fprintf('8d%d:\n      begin\n',i);
%  %fprintf('      case %d \n',i);
%  fprintf('      C2 <= 13b');
%   disp( bin(sfi( m_c2,13,12)));
% %   disp(m_c2);
%   fprintf(';\n');
%  fprintf('      C1 <= 22b');
%  disp( bin(sfi( m_c1,22,22)) );
% %  disp(m_c1);
%   fprintf(';\n');
%  fprintf('      C0 <= 30b');
%  disp( bin(sfi( m_c0,30,28)) );
% %   disp(m_c0);
%   fprintf(';\n');
%   fprintf('     end\n');
%   disp('-----------------------')


%     fprintf('  case %d\n ',i);
%     fprintf('      C2  = ');
%     disp(m_c2);
%      fprintf(';\n');
%     fprintf('      C1  = ');
%     disp(m_c1);
%     fprintf(';\n');
%     fprintf('      C0  = ');
%     disp(m_c0);
%     fprintf(';\n');
   
end
% fprintf('      otherwise\n');
% fprintf('         C2 = 0;\n');
% fprintf('         C1 = 0;\n');
% fprintf('         C0 = 0;\n');
 
