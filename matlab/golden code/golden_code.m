close all;
clear all;
fileID_x0 = fopen('x0.txt', 'w');
fileID_x1 = fopen('x1.txt', 'w');

%%
s0  = uint32(4294967295);
s1  = uint32(3435973837);
s2  = uint32(16711935);

s0_b = uint32(2584963208);
s1_b = uint32(3414123685);
s2_b = uint32(458793276);

for i = 1 : 100

    b0   = uint32( bitshift(bitxor( bitshift(s0, 13), s0, 'uint32'), -19) );
    s0   = uint32( bitxor( bitshift(  bitand(s0, 4294967294, 'uint32'), 12, 'uint32'), b0, 'uint32'));

    b1   = uint32( bitshift(bitxor( bitshift(s1, 2), s1, 'uint32'), -25) );
    s1   = uint32( bitxor( bitshift(  bitand(s1, 4294967288, 'uint32'), 4, 'uint32'), b1, 'uint32'));

    b2   = uint32( bitshift(bitxor( bitshift(s2, 3), s2, 'uint32'), -11) );
    s2   = uint32( bitxor( bitshift(  bitand(s2, 4294967280, 'uint32'), 17, 'uint32'), b2, 'uint32'));

    a    = uint32( bitxor( bitxor(s0, s1, 'uint32'), s2, 'uint32'));        % input seed 0
    
%%
    b0_b   = uint32( bitshift(bitxor( bitshift(s0_b, 13), s0_b, 'uint32'), -19) );
    s0_b   = uint32( bitxor( bitshift(  bitand(s0_b, 4294967294, 'uint32'), 12, 'uint32'), b0_b, 'uint32'));

    b1_b   = uint32( bitshift(bitxor( bitshift(s1_b, 2), s1_b, 'uint32'), -25) );
    s1_b   = uint32( bitxor( bitshift(  bitand(s1_b, 4294967288, 'uint32'), 4, 'uint32'), b1_b, 'uint32'));

    b2_b   = uint32( bitshift(bitxor( bitshift(s2_b, 3), s2_b, 'uint32'), -11) );
    s2_b   = uint32( bitxor( bitshift(  bitand(s2_b, 4294967280, 'uint32'), 17, 'uint32'), b2_b, 'uint32'));

    b      = uint32( bitxor( bitxor(s0_b, s1_b, 'uint32'), s2_b, 'uint32'));               % input seed 1
    
%%

    u1       = uint16(bitand(b,65535));                 % u1 for calculation of cos/sine function
    temp_u0  =   bitshift((bitand(b,4294901760, 'uint32')),-16);
    u0  =  uint64(bitor((bitshift( a, 16)), temp_u0)) ;       % u0 for calculation of logarithm and square root

%%
    exp_e        = LeadingZeroDetector(u0, 48) + 1;    % calculates LRZ for u0
    x_e          = shiftbits( u0, exp_e, 49);
    x_e_a        = shiftbits(x_e, -41, 8);
    x_e_b_1        = shiftbits(x_e, 8, 49);
    temp_x       =  fi(x_e_b_1 ,0,97,48);
    temp_x_1     = bitsra(temp_x,48);                   % shifts right fixed point numbers
    x_e_b        = fi(temp_x_1,0,49,48);
    [C2, C1, C0] = ln2_coefficients(x_e_a);
    uT_x_e_b_2   = fi(x_e_b, 0, 49, 48) * fi(x_e_b, 0, 49, 48);              % uT - untruncated
    uT_C2_x_e_b_2= fi(uT_x_e_b_2, 0,98, 96) * fi(C2, 1, 13, 12);    % signed number (C2 * x * x)
    uT_C1_x_e_b  = fi(x_e_b, 0, 49, 48) * fi(C1, 0, 22, 22);            % unsigned number (C1 * x)
    uT_C0_C1_x_e_b_sum = fi(uT_C1_x_e_b, 0,71, 70) +  fi(C0, 1, 30, 28);  % sum
    uT_y_e       = fi(uT_C2_x_e_b_2, 1 ,111, 108)+ fi(uT_C0_C1_x_e_b_sum, 1,73, 70);
    nTBP         = numerictype(1,32,27);
    y_e          = quantize(uT_y_e, nTBP, 'Round', 'Saturate');         % quantizing with required bit width
    ln2          = fi(log(2), 0, 32, 32);
    ebar         = fi((ln2 * exp_e), 0, 34,28);
    e            = fi((ebar - y_e), 0, 31,24);              % output of logarithm

%%
    k            = bitand(e,127);
    exp_f        = 5 - LeadingZeroDetector( uint8(k) , 7);          % calulates LRZ for e
    x_f1         = bitshift( fi(e,0,31), -1 * exp_f);  
    if bitand(exp_f, 1, 'uint8') == 1                   % condition to check if input is in [1,2)
        x_f      = bitshift( fi(x_f1,0,31), -1);   
        x_f_a = bitshift(fi(x_f,0,31), -25);    
        x_f_a  = bitshift(fi(x_f_a,0,32,26), 26); 
        x_f_b = bitshift(fi(x_f,0,31), 6);
        [C1, C0] = sqrt_coefficients_1_2(x_f_a);
        uT_c1_x_f_b = fi(x_f_b, 0, 31,24) * fi(C1, 0, 12, 12);          % uT - untruncated
        uT_y_f   = fi(uT_c1_x_f_b, 0, 43,36) + fi(C0, 0, 20, 19);
        nTBP     = numerictype(0,20,13);
        y_f      = quantize(uT_y_f, nTBP, 'Round', 'Saturate'); 
        exp_f1   = shiftbits( (exp_f + 1), -1, 3);
    else                                                                 % input in range [2,4)
        x_f = x_f1;
        x_f_a = bitshift(fi(x_f,0,31), -25);    
        x_f_a  = bitshift(fi(x_f_a,0,32,26), 26) 
        x_f_b = bitshift(fi(x_f,0,31), 6);
        [C1, C0] = sqrt_coefficients_2_4(x_f_a);
        uT_c1_x_f_b = fi(x_f_b, 0, 31,24) * fi(C1, 0, 12, 12);
        uT_y_f = fi(uT_c1_x_f_b, 0, 43,36) + fi(C0, 0, 20, 19);
        nTBP = numerictype(0,20,13);
        y_f = quantize(uT_y_f, nTBP, 'Round', 'Saturate');
        exp_f1 = shiftbits( exp_f, -1, 3);
    end
    f = bitshift(fi(y_f, 0, 20,13), exp_f1);    

%%
    quad = bitshift( u1 ,-14 );     % finds which quadrant the sample is in
    x_g_a = bitand(u1,16383, 'uint16');
    x_g_b = bitcmp(x_g_a, 'uint16');
    x_g_b = bitand(x_g_b,16383, 'uint16');
    x_g_a_a = bitshift(bitand(x_g_a, 16256), -7);
    x_g_b_a = bitshift(bitand(x_g_b, 16256), -7);
    temp_x_g_a_b = (bitshift( bitand(x_g_a, 127), 7));
    temp_x_g_a_b_1  = fi(temp_x_g_a_b, 0 ,28,14);       
    temp_x_g_a_b_2 = bitsra(temp_x_g_a_b_1, 14);        % converts integer to fixed point fraction by not changing the binary bits for cos
    x_g_a_b  = fi(temp_x_g_a_b_2, 0, 14,14);
     
    temp_x_g_b_b = (bitshift( bitand(x_g_b, 127), 7));
    temp_x_g_b_b_1  = fi(temp_x_g_b_b, 0 ,28,14);
    temp_x_g_b_b_2 = bitsra(temp_x_g_b_b_1, 14);         % converts integer to fixed point fraction by not changing the binary bits foe sine
    x_g_b_b  = fi(temp_x_g_b_b_2, 0, 14,14);
    
    [C1, C0]= cos_coefficients(x_g_a_a);        % cos function returns coefficients
    uT_C1_x_g_a_b = fi(C1, 1, 12,11) * fi(x_g_a_b, 0, 14,14);
    uT_y_g_a = fi(uT_C1_x_g_a_b, 1, 27, 25) + fi(C0, 0, 19, 18);
    nTBP = numerictype(1,16,15);
    y_g_a = quantize(uT_y_g_a, nTBP, 'Round', 'Saturate');

    [C1, C0]= cos_coefficients(x_g_b_a);                 % sin function returns coefficients
    uT_C1_x_g_b_b = fi(C1, 1, 12,11) * fi(x_g_b_b, 0, 14,14);
    uT_y_g_b = fi(uT_C1_x_g_b_b, 1, 27, 25) + fi(C0, 0, 19, 18);
    nTBP = numerictype(1,16,15);
    y_g_b = quantize(uT_y_g_b, nTBP, 'Round', 'Saturate');
% sign change based on quadrant
    switch quad
        case 0
            g0 = y_g_b;
            g1 = y_g_a;
        case 1
            g0 = y_g_a;
            g1 = -1 * y_g_b;
        case 2
            g0 = -1 * y_g_b;
            g1 = -1 *y_g_a;
        case 3
             g0 = -1 * y_g_a;
             g1 = y_g_b;
    end
% calculation of noise signal
    x0 = sfi((g0*f),16,11);
    x1 = sfi((g1*f),16,11);
 % conversion to integer format for comparision   
    x0_int = storedInteger(x0);
    x1_int = storedInteger(x1);
    
    fprintf(fileID_x0, '%d\n', int32(x0_int));
    fprintf(fileID_x1, '%d\n', int32(x1_int));
end

