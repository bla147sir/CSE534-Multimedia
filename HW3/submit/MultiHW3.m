o_pic1 = imread('ori_pic1.jpg');
o_pic2 = imread('ori_pic2.jpg');
o_pic3 = imread('ori_pic3.jpg');

%------------------grey scale & down sampled 4:1:1---------------% 
[grey1, cb1, cr1] = grey_sample(o_pic1);
[grey2, cb2, cr2] = grey_sample(o_pic2);
[grey3, cb3, cr3] = grey_sample(o_pic3);

pic1 = o_pic1;
pic1(:,:,1) = grey1(:,:);
pic1(:,:,2) = grey1(:,:);
pic1(:,:,3) = grey1(:,:);
pic2 = o_pic2;
pic2(:,:,1) = grey2(:,:);
pic2(:,:,2) = grey2(:,:);
pic2(:,:,3) = grey2(:,:);
pic3 = o_pic3;
pic3(:,:,1) = grey3(:,:);
pic3(:,:,2) = grey3(:,:);
pic3(:,:,3) = grey3(:,:);

imwrite(pic1, 'grey1.jpg');
imwrite(pic2, 'grey2.jpg');
imwrite(pic3, 'grey3.jpg');

pic1_1024 = imresize(pic1, [1024 1024]);
pic2_1024 = imresize(pic2, [1024 1024]);
pic3_1024 = imresize(pic3, [1024 1024]);

imwrite(pic1_1024,'subsample1.jpg');
imwrite(pic2_1024,'subsample2.jpg');
imwrite(pic3_1024,'subsample3.jpg');

grey1 = pic1_1024(:,:,1);
grey2 = pic2_1024(:,:,1);
grey3 = pic3_1024(:,:,1);
%------------- level shift -128---------%
grey1_shift = double(grey1)-128;
grey2_shift = double(grey2)-128;
grey3_shift = double(grey3)-128;

%------------- DCT transform ------------%
func_dct = @(block_struct)dct(block_struct.data);   
dctgrey1 = int16(blockproc(grey1_shift, [8 8], func_dct));
dctgrey2 = int16(blockproc(grey2_shift, [8 8], func_dct));
dctgrey3 = int16(blockproc(grey3_shift, [8 8], func_dct));

%------------- Quantization --------------%
[quan_1Q1, quan_1Q2, quan_1Q3] = quantization(dctgrey1);
[quan_2Q1, quan_2Q2, quan_2Q3] = quantization(dctgrey2);
[quan_3Q1, quan_3Q2, quan_3Q3] = quantization(dctgrey3);

%------------- entropy coding -------------%
encode_11 = encode(quan_1Q1);
encode_12 = encode(quan_1Q2);
encode_13 = encode(quan_1Q3);
encode_21 = encode(quan_2Q1);
encode_22 = encode(quan_2Q2);
encode_23 = encode(quan_2Q3);
encode_31 = encode(quan_3Q1);
encode_32 = encode(quan_3Q2);
encode_33 = encode(quan_3Q3);

%---------------------Reconstruct---------------------------%

%----- inverse Quantization -------%
[iquan_1Q1, iquan_1Q2, iquan_1Q3] = iquantization(quan_1Q1, quan_1Q2, quan_1Q3);
[iquan_2Q1, iquan_2Q2, iquan_2Q3] = iquantization(quan_2Q1, quan_2Q2, quan_2Q3);
[iquan_3Q1, iquan_3Q2, iquan_3Q3] = iquantization(quan_3Q1, quan_3Q2, quan_3Q3);

%-------iDCT--------%
func_idct = @(block_struct)idct(block_struct.data);   
idctgrey11 = int16(blockproc(double(iquan_1Q1), [8 8], func_idct));
idctgrey12 = int16(blockproc(double(iquan_1Q2), [8 8], func_idct));
idctgrey13 = int16(blockproc(double(iquan_1Q3), [8 8], func_idct));

idctgrey21 = int16(blockproc(double(iquan_2Q1), [8 8], func_idct));
idctgrey22 = int16(blockproc(double(iquan_2Q2), [8 8], func_idct));
idctgrey23 = int16(blockproc(double(iquan_2Q3), [8 8], func_idct));

idctgrey31 = int16(blockproc(double(iquan_3Q1), [8 8], func_idct));
idctgrey32 = int16(blockproc(double(iquan_3Q2), [8 8], func_idct));
idctgrey33 = int16(blockproc(double(iquan_3Q3), [8 8], func_idct));

%------- shift +128-----%
r11 = idctgrey11 + 128;
r12 = idctgrey12 + 128;
r13 = idctgrey13 + 128;

r21 = idctgrey21 + 128;
r22 = idctgrey22 + 128;
r23 = idctgrey23 + 128;

r31 = idctgrey31 + 128;
r32 = idctgrey32 + 128;
r33 = idctgrey33 + 128;

%----- write image-----%
rpic11 = uint8(zeros(1024,1024,3));
rpic11(:,:,1) = r11;
rpic11(:,:,2) = r11;
rpic11(:,:,3) = r11;
imwrite(rpic11,'reconstruct11.jpg');
rpic12 = uint8(zeros(1024,1024,3));
rpic12(:,:,1) = r12;
rpic12(:,:,2) = r12;
rpic12(:,:,3) = r12;
imwrite(rpic12,'reconstruct12.jpg');
rpic13 = uint8(zeros(1024,1024,3));
rpic13(:,:,1) = r13;
rpic13(:,:,2) = r13;
rpic13(:,:,3) = r13;
imwrite(rpic13,'reconstruct13.jpg');

rpic21 = uint8(zeros(1024,1024,3));
rpic21(:,:,1) = r21;
rpic21(:,:,2) = r21;
rpic21(:,:,3) = r21;
imwrite(rpic21,'reconstruct21.jpg');
rpic22 = uint8(zeros(1024,1024,3));
rpic22(:,:,1) = r22;
rpic22(:,:,2) = r22;
rpic22(:,:,3) = r22;
imwrite(rpic22,'reconstruct22.jpg');
rpic23 = uint8(zeros(1024,1024,3));
rpic23(:,:,1) = r23;
rpic23(:,:,2) = r23;
rpic23(:,:,3) = r23;
imwrite(rpic23,'reconstruct23.jpg');

rpic31 = uint8(zeros(1024,1024,3));
rpic31(:,:,1) = r31;
rpic31(:,:,2) = r31;
rpic31(:,:,3) = r31;
imwrite(rpic31,'reconstruct31.jpg');
rpic32 = uint8(zeros(1024,1024,3));
rpic32(:,:,1) = r32;
rpic32(:,:,2) = r32;
rpic32(:,:,3) = r32;
imwrite(rpic32,'reconstruct32.jpg');
rpic33 = uint8(zeros(1024,1024,3));
rpic33(:,:,1) = r33;
rpic33(:,:,2) = r33;
rpic33(:,:,3) = r33;
imwrite(rpic33,'reconstruct33.jpg');

%---------- PSNR ------------%
psnr11 = PSNR(grey1, uint8(r11));
psnr12 = PSNR(grey1, uint8(r12));
psnr13 = PSNR(grey1, uint8(r13));
psnr21 = PSNR(grey2, uint8(r21));
psnr22 = PSNR(grey2, uint8(r22));
psnr23 = PSNR(grey2, uint8(r23));
psnr31 = PSNR(grey3, uint8(r31));
psnr32 = PSNR(grey3, uint8(r32));
psnr33 = PSNR(grey3, uint8(r33));

function [grey, cb, cr] = grey_sample(picture)    % greyscale and down sample cb and cr
    %------ grey scale -----%
    [r, c, rgb] = size(picture);
    grey = zeros(r, c);
    grey(:,:) = uint8(0.299*picture(:,:,1)+0.587*picture(:,:,2)+0.114*picture(:,:,3));
    %------ get cb, cr and down sampled to 4:1:1 ----%
    cb = zeros(r, c/4);   
    cr = zeros(r, c/4);
    for i = 1 : r
        for j = 1 : 4 : c
            cb(i,j) = -0.169*picture(i,j,1)+(-0.331)*picture(i,j,2)+0.5*picture(i,j,3);
            cr(i,j) = 0.5*picture(i,j,1)+(-0.419)*picture(i,j,2)+(-0.081)*picture(i,j,3);
        end
    end
end
function [quan_Q1, quan_Q2, quan_Q3] = quantization(dctgrey)   % quantization   
    Q1 = [16 11 10 16 24 40 51 61;
          12 12 14 19 26 58 60 55;
          14 13 16 24 40 57 69 56;
          14 17 22 29 51 87 80 62;
          18 22 37 56 68 109 103 77;
          24 35 55 64 81 104 113 92;
          49 64 78 87 103 121 120 101;
          72 92 95 98 112 100 103 99];
  
    Q2 = [ 1 1 1 1 1 2 3 3;
           1 1 1 1 1 3 3 3;
           1 1 1 1 2 3 3 3;
           1 1 1 1 3 4 4 3;
           1 1 2 3 3 5 5 4;
           1 2 3 3 4 5 6 5;
           2 3 4 4 5 6 6 5;
           4 5 5 5 6 5 5 5 ];  

    Q3 = [17 18 24 47 99 99 99 99;
          18 21 26 66 99 99 99 99;
          24 26 56 99 99 99 99 99;
          47 66 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99 ];

    func_quant_Q1 = @(block_struct)(block_struct.data ./Q1);
    quan_Q1 = int16(blockproc(double(dctgrey), [8 8], func_quant_Q1));
    
    func_quant_Q2 = @(block_struct)(block_struct.data ./Q2);
    quan_Q2 = int16(blockproc(double(dctgrey), [8 8], func_quant_Q2));
    
    func_quant_Q3 = @(block_struct)(block_struct.data ./Q3);
    quan_Q3 = int16(blockproc(double(dctgrey), [8 8], func_quant_Q3));
end
function [rlc] = encode(quan)     % encoding
    [r, c] = size(quan);
    zz = zeros(r*c/64, 64);
    dpcm = zeros(r*c/64, 64);
    rlc = zeros(r*c/64, 64, 2);
    k = 1;
    for i = 1 : 8 :r
        for j = 1 : 8 :c
            zz(k,:) = zigzag(quan(i:i+7, j:j+7));    %zigzag
            dpcm(k,:) = zz(k,:);
            if k ~= 1
                previous_dc = zz(k-1,1);
                dpcm(k,1) = zz(k,1) - previous_dc;     %DPCM 
                temp = RLC(dpcm(k,:));         %RLC
                [t1,t_len] = size(temp);
                for h = 1 : t_len
                    rlc(k, h, 1) = temp(h,1);
                    rlc(k, h, 2) = temp(h,2);
                end
                %---- VLC------%
            end
            k = k+1;
        end
    end
end
function output = zigzag(input)
    k = 1;
    for i = 1 : 8
        h = i;
        if mod(i,2)==0
            for j = 1 : i
               output(k) = input(j,h);
               h = h - 1;
               k = k + 1;
            end
        else
           for j = 1 : i
               output(k) = input(h,j);
               h = h - 1;
               k = k + 1;
           end
        end
    end
    for i = 1 : 7
        h = i;
        if mod(i, 2)==0
            for j = 8 : -1 :(i+1)
               output(k) = input(h,j);
               h = h + 1;
               k = k + 1;
            end
        else
           for j = 8 : -1 :(i+1)
               output(k) = input(j,h);
               h = h + 1;
               k = k + 1;
           end
        end
    end
end
function output = RLC(input)     %input = DPCM
    output = zeros(64,2);
    zero_num = 0;
    k = 1;
    for i = 1:length(input)     %AC   
        if i == 1 && input(i) ~= 0
        else
            if input(i) ~= 0
                output(k,1) = input(i);
                output(k,2) = zero_num;
                zero_num = 0;
                k = k + 1;
            else
                zero_num = zero_num + 1;
            end
        end  
    end
end
function [iquan_Q1, iquan_Q2, iquan_Q3] = iquantization(q1, q2, q3)   % quantization   
    Q1 = [16 11 10 16 24 40 51 61;
          12 12 14 19 26 58 60 55;
          14 13 16 24 40 57 69 56;
          14 17 22 29 51 87 80 62;
          18 22 37 56 68 109 103 77;
          24 35 55 64 81 104 113 92;
          49 64 78 87 103 121 120 101;
          72 92 95 98 112 100 103 99];
  
    Q2 = [ 1 1 1 1 1 2 3 3;
           1 1 1 1 1 3 3 3;
           1 1 1 1 2 3 3 3;
           1 1 1 1 3 4 4 3;
           1 1 2 3 3 5 5 4;
           1 2 3 3 4 5 6 5;
           2 3 4 4 5 6 6 5;
           4 5 5 5 6 5 5 5 ];  

    Q3 = [17 18 24 47 99 99 99 99;
          18 21 26 66 99 99 99 99;
          24 26 56 99 99 99 99 99;
          47 66 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99;
          99 99 99 99 99 99 99 99 ];

    func_quant_Q1 = @(block_struct)(block_struct.data .*Q1);
    iquan_Q1 = int16(blockproc(double(q1), [8 8], func_quant_Q1));
    
    func_quant_Q2 = @(block_struct)(block_struct.data .*Q2);
    iquan_Q2 = int16(blockproc(double(q2), [8 8], func_quant_Q2));
    
    func_quant_Q3 = @(block_struct)(block_struct.data .*Q3);
    iquan_Q3 = int16(blockproc(double(q3), [8 8], func_quant_Q3));
end
function psnr = PSNR(original, recon)
    %------RSME-----%
    temp = original - recon;
    temp = temp .* temp;
    temp = sum(sum(temp))/(1024*1024);
    %fprintf('temp = %d\n',temp);
    rsme = sqrt(temp);
    %fprintf('rsme = %d\n', rsme);
    rsme = rsme(rsme>0);
    %------PSNR------%
    psnr = 20*log10(255/rsme);
    %fprintf('psnr = %d', psnr);
end