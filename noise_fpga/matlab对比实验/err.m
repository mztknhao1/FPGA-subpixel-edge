function [ a_dist,b_dist,number ] = err( matlab_sim_ideal,matlab_sim_noise )
[len_ideal,~] = size(matlab_sim_ideal);
[len_noise,~] = size(matlab_sim_noise);
aerr = 0;
berr = 0;
number = 0 ;
for i = 1:len_ideal
    x_ideal = matlab_sim_ideal(i,1);
    y_ideal = matlab_sim_ideal(i,2);
    for j=1:len_noise
        x_noise = matlab_sim_noise(j,1);
        y_noise = matlab_sim_noise(j,2);
        if(x_noise == x_ideal && y_noise == y_ideal)
            atmp_ideal = matlab_sim_ideal(i,3);
            btmp_ideal = matlab_sim_ideal(i,4);
            atmp_noise = matlab_sim_noise(j,3);
            btmp_noise = matlab_sim_noise(j,4);
            aerr = aerr + (atmp_ideal-atmp_noise).^2;
            berr = berr + (btmp_ideal-btmp_noise).^2;
            number = number+1;
        end
    end
end
a_dist = aerr.^0.5/number;
b_dist = berr.^0.5/number;
end



