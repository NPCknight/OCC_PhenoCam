% 本代码是物候相机最优色彩合成方法（Optimal Color Composition，OCC）的实现代码，可以重建出物候相机逐日照片时序和GCC时间序列
% 本代码分为4个主要部分：
% 【1.输入参数】      照片储存路径，照片包含的天数，物候相机站点名，照片上划定的感兴趣区范围，合成窗口，可用照片起止拍摄时间
% 【2.前期准备】      照片整理，限定可用照片的时间段（包含了计算每张可用照片的对比度的代码，已注释掉，需要的话可以使用）
% 【3.计算GCC-Per90】 选取每天所有照片的90th分位数，构成GCC-Per90，重建出的GCC_OCC时序储存在.../GCC_per90.csv中
% 【4.OCC方法实现】   Step1 RGB颜色模式转为HSB(HSV)颜色模式;
%                     Step2 在窗口内进行最优DN值选择并合成每日照片image_OCC;
%                     Step3 在每日合成照片image_OCC中计算GCC_OCC
%                     重建出的逐日照片时序储存在.../OCC_DailyPhoto文件夹中，重建出的GCC_OCC时序储存在.../GCC_OCC.csv中
% 【输出数据】        GCC_per90.csv    90th分位数滤波方法重建出的GCC时序
%                     GCC_all.csv      所有可用照片的原始GCC时序
%                     GCC_OCC.csv      OCC方法重建出的GCC时序
%                     OCC_DailyPhoto   OCC方法重建出的逐日照片时序
%                     date_label.csv   每天是否有照片的标记，1-有照片，0-无照片
%                     image_list.csv   可用照片文件名
%                     doy_list.csv     可用照片的对应DOY和拍摄
% 注意：目前代码是适用于从https://phenocam.sr.unh.edu/webcam/gallery/下载的照片，从照片命名中获取照片拍摄时间
% by 李青  2021.06.17

%% ------1.输入参数----------------------------------------------------------------------------------
date_num=4;                %照片包含的天数（从第一天到最后一天，不必考虑中间日期照片是否有缺失）
sitename='millhaft';       %物候相机站点名
ROI=[560 860 100 1196];    %照片上划定的感兴趣区，只包含目标植被
win_size=3;                %最有DN值选择及照片合成窗口;关注照片纹理时建议win_size=1;关注时序平滑度时建议win_size=3
start_time=9;              %可用照片起始时间，目前为9:00
end_time=15;               %可用照片结束时间，目前为15:00，为排除夜晚、凌晨、黄昏照片

filep = mfilename('fullpath');
[pathstr,namestr]=fileparts(filep);
input_path = [pathstr,'\test_data'];   %照片储存路径
output_path=[pathstr,'\output\'];      %输出路径，代码储存路径下创建输出文件夹
mkdir(output_path);
%% ------2.前期准备（整理照片文件，计算对比度）---------------------------------------------------------
%照片文件整理(限定可用照片的时间段，即每天的start_time至end_time)
fprintf('Organizing photo files.\n');
fileFolder=fullfile(input_path);
dirOutput=dir(fullfile(fileFolder,'*.jpg'));
fileNames={dirOutput.name};
image_list=cell(length(fileNames),1); %记录可用的照片名称
date_time_list=zeros(length(fileNames),2);  %记录可用照片拍摄时间，第一列为第几天，第二列为拍摄时刻
label=zeros(date_num,1);              %记录每日是否有照片
temp_1=fileNames{1};
year=str2num(temp_1(length(sitename)+2:length(sitename)+2+3));
month=str2num(temp_1(length(sitename)+7:length(sitename)+7+1));
day=str2num(temp_1(length(sitename)+10:length(sitename)+10+1));
[day_of_year_pre] = DOY(year,month,day);
num_date=1;
for zz=1:length(fileNames)
    temp_filename=fileNames{zz};
    image_list{zz}=temp_filename;
    year=str2num(temp_filename(length(sitename)+2:length(sitename)+2+3));
    month=str2num(temp_filename(length(sitename)+7:length(sitename)+7+1));
    day=str2num(temp_filename(length(sitename)+10:length(sitename)+10+1));
    hour=str2num(temp_filename(length(sitename)+13:length(sitename)+13+1));
    minu=str2num(temp_filename(length(sitename)+15:length(sitename)+15+1));
    temp_hm=hour+minu/60;
    if (temp_hm>=start_time)&&(temp_hm<=(end_time+10/60))   %限定可用照片的时间段，即每天的start_time至end_time
        [day_of_year] = DOY(year,month,day);
        diff = day_of_year-day_of_year_pre;
        date_time_list(zz,1)=num_date+diff;
        date_time_list(zz,2)=temp_hm;
        label(num_date+diff)=1;
        num_date=num_date+diff;
        day_of_year_pre=day_of_year;
    end
end
temp=date_time_list(:,1);
date_time_list(temp==0,:)=[];
image_list(temp==0,:)=[];
csvwrite([output_path,'date_label.csv'],label);       %标记每天是否有照片
cell2csv([output_path,'image_list.csv'],image_list);  %可用的照片名称
csvwrite([output_path,'doy_list.csv'],date_time_list);      %可用照片的对应天数和时间

%%计算每张可用照片的对比度（已注释掉，需要的话可以使用）
% fprintf('Calculating photo contrast.\n');
% contrast=zeros(length(image_list),1);%记录可用照片的对比度
% for i_num=1:length(image_list)   
%     img_name=[input_path,'\',image_list{i_num}];
%     image_all = imread(img_name);
%     image=image_all(ROI(1):ROI(2),ROI(3):ROI(4),:);
%     image=im2double(image);
%     f = rgb2gray(image);
%     [m,n] = size(f);      %求原始图像的行数m和列数n
%     g = padarray(f,[1 1],'symmetric','both');   %对原始图像进行扩展，比如50*50的图像，扩展后变成52*52的图像，%扩展只是对原始图像的周边像素进行复制的方法进行
%     [r,c] = size(g);      %求扩展后图像的行数r和列数c
%     g = im2double(g);     %把扩展后图像转变成双精度浮点数
%     k=0;                  %定义一数值k，初始值为0
%     for ii=2:r-1
%         for jj=2:c-1
%             k = k+(g(ii,jj-1)-g(ii,jj))^2+(g(ii-1,jj)-g(ii,jj))^2+(g(ii,jj+1)-g(ii,jj))^2+(g(ii+1,jj)-g(ii,jj))^2;
%         end
%     end
%     contrast(i_num) =k/(4*(m-2)*(n-2)+3*(2*(m-2)+2*(n-2))+4*2);    %求原始图像对比度
% end
% csvwrite([output_path,'contrast.csv'],contrast);%所有可用照片的对比度
%% ------3.计算GCC-Per90---------------------------------------------------------
%选取每天所有照片的90th分位数，构成GCC-Per90
fprintf('Reconstructing GCC-Per90.\n');
temp_doy=date_time_list(:,1);
gcc_all=zeros(length(image_list),1);    %所有可用照片的原始GCC
gcc_per90=zeros(date_num,1);
for n_date=1:length(label)
    if label(n_date)==0                 %跳过没有照片记录的日期
        continue
    else
        temp_image_list=image_list(temp_doy==n_date);
        gcc_temp=zeros(length(temp_image_list),1);     %记录第n_date天所有可用照片的GCC数值
        for n_image=1:length(temp_image_list)
            img_name=[input_path,'\',cell2mat(temp_image_list(n_image))];
            image_all = imread(img_name);
            image_i8=image_all(ROI(1):ROI(2),ROI(3):ROI(4),:);
            %imshow(image_i8)
            image=im2double(image_i8);
            gcc_temp(n_image)=mean(mean(image(:,:,2)))./(mean(mean(image(:,:,1)))+mean(mean(image(:,:,2)))+mean(mean(image(:,:,3))));          
        end
        gcc_all(temp_doy==n_date)=gcc_temp;
        temp_90th=prctile(gcc_temp,90);  %选取一天内所有GCC的90th分位数
        [min_value,min_local]=min(abs(gcc_temp-temp_90th));
        gcc_per90(n_date)=gcc_temp(min_local);
    end
end
csvwrite([output_path,'GCC_all.csv'],gcc_all);      %所有可用照片的原始GCC
csvwrite([output_path,'GCC_per90.csv'],gcc_per90);  %90th分位数方法重建的GCC_per90时序

%% -------4.OCC算法实现-------------------------------------------------------------------
% OCC实现，重建出的逐日照片时序储存在.../OCC_DailyPhoto文件夹中，重建出的GCC_OCC时序储存在.../GCC_OCC.csv中
fprintf('Reconstructing GCC-OCC.\n');
gcc_occ=zeros(date_num,1);
mkdir([output_path,'OCC_DailyPhoto']);
x_win=floor((ROI(2)-ROI(1)+1)/win_size);
y_win=floor((ROI(4)-ROI(3)+1)/win_size);
temp_doy=date_time_list(:,1);
temp_time=date_time_list(:,2);
for n_date=1:length(label)    
    tic
    if label(n_date)==0
        continue
    else
        fprintf(['Processing photos of Day ',num2str(n_date)],'.Running time is:');
        temp_image_list=image_list(temp_doy==n_date);
        S_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%储存照片饱和度（s）
        B_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%储存照片明度(b)
        r_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%储存照片red分量
        g_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%储存照片green分量
        b_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%储存照片blue分量
%--------Step1 RGB颜色模式转为HSB(HSV)颜色模式------------------------------------------
        for n_image=1:length(temp_image_list)
            img_name=[input_path,'\',cell2mat(temp_image_list(n_image))];
            image_all = imread(img_name);
            image_i8=image_all(ROI(1):ROI(2),ROI(3):ROI(4),:);
            %imshow(image)
            image=im2double(image_i8);
            Corner = colorspace('HSB<-rgb', image);%同一日期的HSB
            %判断是否是有积雪像元/蓝色像元
            temp_blue=image(:,:,3);
            snow=find(temp_blue>=0.9);  %积雪像元：蓝色通道数值>=0.9
            temp_h=Corner(:,:,1);
            blue=intersect(find(temp_h>=170),find(temp_h<=270));   %蓝色像元
            label_remove=[snow;blue];
            %将有积雪像元/蓝色像元作标记，b&s设置为100,100作为标记(不会被选上的数)，rgb设为（2，2，2）作为标记（此时rgb是浮点型数据）
            temp_B=Corner(:,:,3);
            temp_S=Corner(:,:,2);
            temp_r= image(:,:,1);
            temp_g=image(:,:,2);
            temp_b=image(:,:,3);
            temp_B(label_remove)=100;
            temp_S(label_remove)=100;
            temp_r(label_remove)=2;
            temp_g(label_remove)=2;
            temp_b(label_remove)=2;
            
            B_one_day(:,:,n_image)=temp_B;%同一日期所有照片的B(明度)
            S_one_day(:,:,n_image)=temp_S;%同一日期所有照片的S(饱和度)
            r_one_day(:,:,n_image) = temp_r;%同一日期所有照片的red分量
            g_one_day(:,:,n_image) = temp_g;%同一日期所有照片的green分量
            b_one_day(:,:,n_image) = temp_b;%同一日期所有照片的blue分量       
        end      
%--------Step2 在窗口内进行最优DN值选择并合成每日照片image_OCC---------------------------------
        image_OCC=zeros(x_win,y_win,3);
        for ii=1:x_win
            for jj=1:y_win
                temp_win_B=B_one_day((ii-1)*win_size+1:ii*win_size,(jj-1)*win_size+1:jj*win_size,:);
                temp_win_S=S_one_day((ii-1)*win_size+1:ii*win_size,(jj-1)*win_size+1:jj*win_size,:);
                temp_r_win=r_one_day((ii-1)*win_size+1:ii*win_size,(jj-1)*win_size+1:jj*win_size,:);
                temp_g_win=g_one_day((ii-1)*win_size+1:ii*win_size,(jj-1)*win_size+1:jj*win_size,:);
                temp_b_win=b_one_day((ii-1)*win_size+1:ii*win_size,(jj-1)*win_size+1:jj*win_size,:);
                distence_0=sqrt(temp_win_B.^2+temp_win_S.^2);
                angle=abs(atan(temp_win_B./temp_win_S)-pi/4);
                L1=distence_0.*sin(angle);                       %该像元在明度-饱和度二维空间中，与1:1线的距离
                L2=sqrt((1-temp_win_B).^2+(1-temp_win_S).^2);    %该像元在明度-饱和度二维空间中，与右上角（1,1）的距离
                %对L1和L2在一天内进行标准化
                if max(L1(:))==min(L1(:))
                    normal_chuizhi=L1-L1;
                else
                    normal_chuizhi=(L1-min(L1(:)))./(max(L1(:))-min(L1(:)));
                end
                if max(L2(:))==min(L2(:))
                    normal_distance=L2-L2;
                else
                    normal_distance=(L2-min(L2(:)))./(max(L2(:))-min(L2(:)));
                end
                CCI=normal_chuizhi+normal_distance;      %L1+L2，作为最优像元评价指标
                optimal_pixel= find(CCI==min(CCI,[],'all'));   %CCI最小值对应像元即为最佳DN值
                if isempty(optimal_pixel)           %如果没有选出最佳像元，就将该像元位置设为（2,2,2）
                    image_OCC(ii,jj,1)=2;
                    image_OCC(ii,jj,2)=2;
                    image_OCC(ii,jj,3)=2;
                else
                    image_OCC(ii,jj,1)=temp_r_win(optimal_pixel(1));
                    image_OCC(ii,jj,2)=temp_g_win(optimal_pixel(1));
                    image_OCC(ii,jj,3)=temp_b_win(optimal_pixel(1));
                end
            end
        end
        %计算gcc时，除去DN值为（2，2，2）的像元，最后将该部分像元还原为（0，0，0）
        image_OCC_r=image_OCC(:,:,1);
        image_OCC_g=image_OCC(:,:,2);
        image_OCC_b=image_OCC(:,:,3);
        location_2=find(image_OCC_r==2);
        image_OCC_r(location_2)=[];
        image_OCC_g(location_2)=[];
        image_OCC_b(location_2)=[];
%--------Step3 在每日合成照片image_OCC中计算GCC_OCC-------------------------------------
        gcc_occ(n_date)=mean(image_OCC_g)/(mean(image_OCC_r)+mean(image_OCC_g)+mean(image_OCC_b));
        image_OCC(image_OCC==2)=0;
        imwrite(image_OCC,[output_path,'OCC_DailyPhoto','\',sitename,'_',num2str(n_date),'.jpg'])
    end   
    toc
end
csvwrite([output_path,'GCC_OCC.csv'],gcc_occ);
fprintf('Complete\n');


