function count = LeadingZeroDetector(x, n)
    count =0;       % finds leading zeros for given inpu. n tells from which bit to start counting to right
    shift = bitshift(1, n - 1, 'uint64');
    
    for i = [0: n - 1]
        retval = bitand(x, shift);
        if retval == 0
            count = count + 1;
            shift = bitshift(shift, -1);
            continue
        else
            break
        end
    end
end