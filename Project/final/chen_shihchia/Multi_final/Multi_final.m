o_pic1 = imread('original_pic.jpg');
grey1(:,:) = uint8(0.299*o_pic1(:,:,1)+0.587*o_pic1(:,:,2)+0.114*o_pic1(:,:,3));
pic1 = o_pic1;
pic1(:,:,1) = grey1(:,:);
pic1(:,:,2) = grey1(:,:);
pic1(:,:,3) = grey1(:,:);
imwrite(pic1,'greyscale.jpg');
grey = pic1(:,:,1);

Q1 = [16 11 10 16 24 40 51 61;
      12 12 14 19 26 58 60 55;
      14 13 16 24 40 57 69 56;
      14 17 22 29 51 87 80 62;
      18 22 37 56 68 109 103 77;
      24 35 55 64 81 104 113 92;
      49 64 78 87 103 121 120 101;
      72 92 95 98 112 100 103 99];

[encode_grey, ratio, decode_grey] = encode_decode(Q1,grey);
rpic = uint8(zeros(1024,1024,3));
rpic(:,:,1) = decode_grey;
rpic(:,:,2) = decode_grey;
rpic(:,:,3) = decode_grey;
imwrite(rpic,'reconstruct_pic7x7.jpg');
psnr = PSNR(grey, uint8(decode_grey));


function[code_img,radio,re_img]=encode_decode(q,gray_img)
fun1=@(block)dct2(block.data);
fun1_1=@(block)dctvbs5x5(block.data);
dct_img=blockproc(gray_img,[8 8],fun1_1);

fun2=@(block)(block.data ./q);
q_img=blockproc(dct_img,[8 8],fun2);

[p_img,symbol_img] = imhist(int8(q_img));

p_img = p_img / sum(p_img);

[dict_img,~] = huffmandict(symbol_img,p_img);

sig_img = reshape(int8(q_img),1,(1024*1024));

code_img = huffmanenco(sig_img,dict_img);

radio=(1024*1024*8)/size(code_img,2);

dsig_img = huffmandeco(code_img,dict_img);
re_reshape_img = reshape(dsig_img,1024,1024);

re_fun1=@(block)(block.data .* q);
re_q_img = blockproc(re_reshape_img,[8 8],re_fun1);

re_fun2=@(block)idct2(block.data);
re_img = blockproc(re_q_img,[8 8],re_fun2);
end

function vbsoutput = dctvbs5x5(dct8x8)
    vbsoutput = dct2(dct8x8);
    vbsoutput(8:8,8:8) = 0;
end
function psnr = PSNR(original, recon)
    %------RSME-----%
    temp = original - recon;
    temp = temp .* temp;
    temp = sum(sum(temp))/(1024*1024);
    rsme = sqrt(temp);
    rsme = rsme(rsme>0);
    %------PSNR------%
    psnr = 20*log10(255/rsme);
end