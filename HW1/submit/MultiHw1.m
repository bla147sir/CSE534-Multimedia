speech = audioread('Speech.wav');
[y,fs] = audioread('Speech.wav');
subplot(3,1,1);
plot(speech);
title('original speech wave');
for i=1:479
    for j=1:240
        frame(i,j) = y((i-1)*160+j);
    end
end

clear i j;
Rk = zeros(479,78);
Maxframe = max(frame');
CL = Maxframe.*0.3;
for i = 1:479
    for k = 23:100
       for j = 1:240-k
           if frame(i,j) > CL(i) 
               a = 1;
           elseif frame(i,j) < CL(i)*(-1)
               a = -1;
           else
               a = 0;
           end

           if frame(i,j+k) > CL(i) 
               b = 1;
           elseif frame(i,j+k) < CL(i)*(-1) 
               b = -1;
           else
               b = 0;
           end 
           Rk(i,k-22) = Rk(i,k-22)+a*b;
       end
    end
end

clear i j k;
[R,RMaxPosition] = max(Rk');
Rn = zeros(479,1);
for i = 1:479
   for j = 1:240
       if frame(i,j) > CL(i) || frame(i,j) < CL(i)*(-1)
           Rn(i,1) = Rn(i,1)+1;
       end
   end
end

clear i j;
voice = zeros(479,1);
PitchDetection = zeros(479,1);
for i = 1:479
    if R(i)>=Rn(i)*0.3
       voice(i,1) = 1;  %1=voiced 0=unvoiced
       PitchDetection(i) = RMaxPosition(i)+23+23;
    end
end

%t = 0 : 1/8e3 : 1;         % 8 kHz sample freq for 1 s
%d = 0 : 1/3 : 1;           % 3 Hz repetition frequency
%Impulse = pulstran(t,d,'gauspuls');
%plot(t, Impulse);


clear i j k;
[coeffi,gain] = lpc(frame',10);

%reconstruct the speech
recon = zeros(479,240);
clear i j k;
for i = 11:479
    for k = 1:10
        for j = 1:240
            recon(i,j) = recon(i,j) + coeffi(i,k)*frame(i-k, j);
        end
        recon(i) = recon(i)+gain(i)*voice(i);
    end
end

clear i j k;
k = 1;
reconstruct = zeros(76790,0);
for i = 1:469
    for j = 1:160
        reconstruct(k) = recon(i,j);
        k = k+1;
    end
end
for j = 161:240
    recontruct(k) = recon(469,j);
    k = k+1;
end
subplot(3,1,2);
plot(reconstruct,'b');
title('Reconstructed speech');

%Build a list 
T = table(voice, PitchDetection, coeffi, gain);
T(1:479,:)
filename = 'list.xlsx';
writetable(T, filename)

%another reconstruction
clear i j k;
gain2 = gain.*gain;
gain2_v = gain2(:);   %convert 2d array to vector
coeffi_t = coeffi';
error = zeros(479,240);
error = frame;

for i = 11:479
    for k = 1:10
        for j = 1:240
            error(i,j) = error(i,j) - coeffi(i,k)*frame(i-k,j);
        end
    end
end

for i = 1:479
    coeffi_temp = coeffi_t((i-1)*11+1:(i-1)*11+11);
    recon_another(((i-1)*240+1:(i-1)*240+240)) = filter(gain2_v, coeffi_temp, error((i-1)*240+1:(i-1)*240+240)); 
end

subplot(3,1,3);
plot(recon_another,'b');
title('Another reconstructed speech');