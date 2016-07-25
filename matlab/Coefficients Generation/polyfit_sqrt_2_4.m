% function to calculate square root coeffients in interval [2,4)
clear all;
close all;
fileID = fopen('coeff_sqrt[2,4].txt','w+');
sum = double(2);
x =  linspace(2, 4 - double(5.9605e-08),64);
y1 = sqrt(x);
for i= [0:63]
   xp =  linspace(sum, sum + double(0.03125), 64);
   y =sqrt(xp);
   m = polyfit(xp, y, 1);
   sum = sum + double(0.03125);
%%
   temp = bitshift (fi(m(1),0,64), -6);
   nTBP = numerictype(0,12,12);
   m_c1 = quantize(temp, nTBP, 'Round', 'Saturate');
   %%
   temp1 = fi(m(1),0, 64) * fi(i/64, 0, 64);
   temp2 = fi(temp1, 0, 64) + fi(m(2), 0, 64);
   nTBP1 = numerictype(0,20,19);
   m_c0 = quantize(temp2, nTBP1, 'Round', 'Saturate');

   %%
%     fprintf(' 6d%d\n     begin\n',i);
%     fprintf('      C1 <= ');
%     disp(m_c1);
% %    disp(bin(fi(m_c1, 0, 12,12)));
%     fprintf(';\n');
%     fprintf('      C0 <= ');
%     disp(m_c0);
% %    disp(bin(fi(m_c0, 0, 20,15)));
%     fprintf(';\n');
%    fprintf('      end\n');
%    %disp('-------------');

%     fprintf('  case %d\n ',i);
%     fprintf('      C1  = ');
%     disp(m_c1);
%     fprintf(';\n');
%     fprintf('      C0  = ');
%     disp(m_c0);
%     fprintf(';\n');
end
% fprintf('      otherwise\n');
% fprintf('         C1 = 0;\n');
% fprintf('         C0 = 0;\n');

