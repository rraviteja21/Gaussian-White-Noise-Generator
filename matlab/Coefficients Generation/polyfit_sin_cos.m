% function to calculate cos  coeffients
clear all;
close all;
fileID = fopen('coeff_sin_cos.txt','w+');
sum = double(0);
x = linspace(0, double(pi/2), 128);
y1 = sqrt(x);
for i= [0:127]
   xp = linspace(sum, sum + double(0.0078125), 128);
   y = cos(xp* (pi/2));
   m = polyfit(xp, y, 1);
   sum = sum + double(0.0078125);
%    disp(m);
   %%
   temp = bitshift( fi(m(1), 1, 64), -7 );
   nTBP = numerictype(1,12,11);
   m_c1 = quantize(sfi(temp), nTBP, 'Round', 'Saturate');
%    disp(m_c1);
   %%
   temp1 = sfi( m(1) * i/128, 64);
   temp2 = sfi( temp1 + m(2), 64) ;
   nTBP1 = numerictype(0,19,18);
   m_c0 =  quantize(sfi(temp2), nTBP1, 'Round', 'Saturate');
    % disp(m_c0);
   %%
%    fprintf('  7d%d:\n     begin\n',i);
%    fprintf('      C1 <= 12b');
%    %disp(m_c1);
%    disp(bin(fi(m_c1, 1, 12,11)));
%     fprintf(';\n');
%    fprintf('      C0 <= 19b');
%    %disp(m_c0);
%    disp(bin(fi(m_c0, 0, 19,18)));
%    fprintf(';\n');
%    fprintf('      end\n');
% %disp('------------------------');

    fprintf('  case %d\n ',i);
    fprintf('      C1  = ');
    disp(m_c1);
    fprintf(';\n');
    fprintf('      C0  = ');
    disp(m_c0);
    fprintf(';\n');
   
end
fprintf('      otherwise\n');
fprintf('         C1 = 0;\n');
fprintf('         C0 = 0;\n');