function N_D = analog_digital_converter(x)
switch true 
    case x <-4.1
    N_D = 0;
    case x >= -4.1 && x < -2.1
        N_D = 1;
    case x>= -2.1 && x < 2.1 
        N_D = 2 ;
    otherwise
        N_D = 3;
end 


    