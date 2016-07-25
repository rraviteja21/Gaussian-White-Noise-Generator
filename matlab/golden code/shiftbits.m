function y = shiftbits( x, n , ret_bits)
    temp_y = bitshift(x,n, 'uint64');  % function to shift bits. n tells the shift. and ret_bits returns the number of bits to return
    y = bitand( power(2, ret_bits) - 1, temp_y );
end
