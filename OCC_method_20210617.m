% ������������������ɫ�ʺϳɷ�����Optimal Color Composition��OCC����ʵ�ִ��룬�����ؽ���������������Ƭʱ���GCCʱ������
% �������Ϊ4����Ҫ���֣�
% ��1.���������      ��Ƭ����·������Ƭ������������������վ��������Ƭ�ϻ����ĸ���Ȥ����Χ���ϳɴ��ڣ�������Ƭ��ֹ����ʱ��
% ��2.ǰ��׼����      ��Ƭ�����޶�������Ƭ��ʱ��Σ������˼���ÿ�ſ�����Ƭ�ĶԱȶȵĴ��룬��ע�͵�����Ҫ�Ļ�����ʹ�ã�
% ��3.����GCC-Per90�� ѡȡÿ��������Ƭ��90th��λ��������GCC-Per90���ؽ�����GCC_OCCʱ�򴢴���.../GCC_per90.csv��
% ��4.OCC����ʵ�֡�   Step1 RGB��ɫģʽתΪHSB(HSV)��ɫģʽ;
%                     Step2 �ڴ����ڽ�������DNֵѡ�񲢺ϳ�ÿ����Ƭimage_OCC;
%                     Step3 ��ÿ�պϳ���Ƭimage_OCC�м���GCC_OCC
%                     �ؽ�����������Ƭʱ�򴢴���.../OCC_DailyPhoto�ļ����У��ؽ�����GCC_OCCʱ�򴢴���.../GCC_OCC.csv��
% ��������ݡ�        GCC_per90.csv    90th��λ���˲������ؽ�����GCCʱ��
%                     GCC_all.csv      ���п�����Ƭ��ԭʼGCCʱ��
%                     GCC_OCC.csv      OCC�����ؽ�����GCCʱ��
%                     OCC_DailyPhoto   OCC�����ؽ�����������Ƭʱ��
%                     date_label.csv   ÿ���Ƿ�����Ƭ�ı�ǣ�1-����Ƭ��0-����Ƭ
%                     image_list.csv   ������Ƭ�ļ���
%                     doy_list.csv     ������Ƭ�Ķ�ӦDOY������
% ע�⣺Ŀǰ�����������ڴ�https://phenocam.sr.unh.edu/webcam/gallery/���ص���Ƭ������Ƭ�����л�ȡ��Ƭ����ʱ��
% by ����  2021.06.17

%% ------1.�������----------------------------------------------------------------------------------
date_num=4;                %��Ƭ�������������ӵ�һ�쵽���һ�죬���ؿ����м�������Ƭ�Ƿ���ȱʧ��
sitename='millhaft';       %������վ����
ROI=[560 860 100 1196];    %��Ƭ�ϻ����ĸ���Ȥ����ֻ����Ŀ��ֲ��
win_size=3;                %����DNֵѡ����Ƭ�ϳɴ���;��ע��Ƭ����ʱ����win_size=1;��עʱ��ƽ����ʱ����win_size=3
start_time=9;              %������Ƭ��ʼʱ�䣬ĿǰΪ9:00
end_time=15;               %������Ƭ����ʱ�䣬ĿǰΪ15:00��Ϊ�ų�ҹ���賿���ƻ���Ƭ

filep = mfilename('fullpath');
[pathstr,namestr]=fileparts(filep);
input_path = [pathstr,'\test_data'];   %��Ƭ����·��
output_path=[pathstr,'\output\'];      %���·�������봢��·���´�������ļ���
mkdir(output_path);
%% ------2.ǰ��׼����������Ƭ�ļ�������Աȶȣ�---------------------------------------------------------
%��Ƭ�ļ�����(�޶�������Ƭ��ʱ��Σ���ÿ���start_time��end_time)
fprintf('Organizing photo files.\n');
fileFolder=fullfile(input_path);
dirOutput=dir(fullfile(fileFolder,'*.jpg'));
fileNames={dirOutput.name};
image_list=cell(length(fileNames),1); %��¼���õ���Ƭ����
date_time_list=zeros(length(fileNames),2);  %��¼������Ƭ����ʱ�䣬��һ��Ϊ�ڼ��죬�ڶ���Ϊ����ʱ��
label=zeros(date_num,1);              %��¼ÿ���Ƿ�����Ƭ
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
    if (temp_hm>=start_time)&&(temp_hm<=(end_time+10/60))   %�޶�������Ƭ��ʱ��Σ���ÿ���start_time��end_time
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
csvwrite([output_path,'date_label.csv'],label);       %���ÿ���Ƿ�����Ƭ
cell2csv([output_path,'image_list.csv'],image_list);  %���õ���Ƭ����
csvwrite([output_path,'doy_list.csv'],date_time_list);      %������Ƭ�Ķ�Ӧ������ʱ��

%%����ÿ�ſ�����Ƭ�ĶԱȶȣ���ע�͵�����Ҫ�Ļ�����ʹ�ã�
% fprintf('Calculating photo contrast.\n');
% contrast=zeros(length(image_list),1);%��¼������Ƭ�ĶԱȶ�
% for i_num=1:length(image_list)   
%     img_name=[input_path,'\',image_list{i_num}];
%     image_all = imread(img_name);
%     image=image_all(ROI(1):ROI(2),ROI(3):ROI(4),:);
%     image=im2double(image);
%     f = rgb2gray(image);
%     [m,n] = size(f);      %��ԭʼͼ�������m������n
%     g = padarray(f,[1 1],'symmetric','both');   %��ԭʼͼ�������չ������50*50��ͼ����չ����52*52��ͼ��%��չֻ�Ƕ�ԭʼͼ����ܱ����ؽ��и��Ƶķ�������
%     [r,c] = size(g);      %����չ��ͼ�������r������c
%     g = im2double(g);     %����չ��ͼ��ת���˫���ȸ�����
%     k=0;                  %����һ��ֵk����ʼֵΪ0
%     for ii=2:r-1
%         for jj=2:c-1
%             k = k+(g(ii,jj-1)-g(ii,jj))^2+(g(ii-1,jj)-g(ii,jj))^2+(g(ii,jj+1)-g(ii,jj))^2+(g(ii+1,jj)-g(ii,jj))^2;
%         end
%     end
%     contrast(i_num) =k/(4*(m-2)*(n-2)+3*(2*(m-2)+2*(n-2))+4*2);    %��ԭʼͼ��Աȶ�
% end
% csvwrite([output_path,'contrast.csv'],contrast);%���п�����Ƭ�ĶԱȶ�
%% ------3.����GCC-Per90---------------------------------------------------------
%ѡȡÿ��������Ƭ��90th��λ��������GCC-Per90
fprintf('Reconstructing GCC-Per90.\n');
temp_doy=date_time_list(:,1);
gcc_all=zeros(length(image_list),1);    %���п�����Ƭ��ԭʼGCC
gcc_per90=zeros(date_num,1);
for n_date=1:length(label)
    if label(n_date)==0                 %����û����Ƭ��¼������
        continue
    else
        temp_image_list=image_list(temp_doy==n_date);
        gcc_temp=zeros(length(temp_image_list),1);     %��¼��n_date�����п�����Ƭ��GCC��ֵ
        for n_image=1:length(temp_image_list)
            img_name=[input_path,'\',cell2mat(temp_image_list(n_image))];
            image_all = imread(img_name);
            image_i8=image_all(ROI(1):ROI(2),ROI(3):ROI(4),:);
            %imshow(image_i8)
            image=im2double(image_i8);
            gcc_temp(n_image)=mean(mean(image(:,:,2)))./(mean(mean(image(:,:,1)))+mean(mean(image(:,:,2)))+mean(mean(image(:,:,3))));          
        end
        gcc_all(temp_doy==n_date)=gcc_temp;
        temp_90th=prctile(gcc_temp,90);  %ѡȡһ��������GCC��90th��λ��
        [min_value,min_local]=min(abs(gcc_temp-temp_90th));
        gcc_per90(n_date)=gcc_temp(min_local);
    end
end
csvwrite([output_path,'GCC_all.csv'],gcc_all);      %���п�����Ƭ��ԭʼGCC
csvwrite([output_path,'GCC_per90.csv'],gcc_per90);  %90th��λ�������ؽ���GCC_per90ʱ��

%% -------4.OCC�㷨ʵ��-------------------------------------------------------------------
% OCCʵ�֣��ؽ�����������Ƭʱ�򴢴���.../OCC_DailyPhoto�ļ����У��ؽ�����GCC_OCCʱ�򴢴���.../GCC_OCC.csv��
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
        S_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%������Ƭ���Ͷȣ�s��
        B_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%������Ƭ����(b)
        r_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%������Ƭred����
        g_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%������Ƭgreen����
        b_one_day=zeros(ROI(2)-ROI(1)+1,ROI(4)-ROI(3)+1,length(temp_image_list));%������Ƭblue����
%--------Step1 RGB��ɫģʽתΪHSB(HSV)��ɫģʽ------------------------------------------
        for n_image=1:length(temp_image_list)
            img_name=[input_path,'\',cell2mat(temp_image_list(n_image))];
            image_all = imread(img_name);
            image_i8=image_all(ROI(1):ROI(2),ROI(3):ROI(4),:);
            %imshow(image)
            image=im2double(image_i8);
            Corner = colorspace('HSB<-rgb', image);%ͬһ���ڵ�HSB
            %�ж��Ƿ����л�ѩ��Ԫ/��ɫ��Ԫ
            temp_blue=image(:,:,3);
            snow=find(temp_blue>=0.9);  %��ѩ��Ԫ����ɫͨ����ֵ>=0.9
            temp_h=Corner(:,:,1);
            blue=intersect(find(temp_h>=170),find(temp_h<=270));   %��ɫ��Ԫ
            label_remove=[snow;blue];
            %���л�ѩ��Ԫ/��ɫ��Ԫ����ǣ�b&s����Ϊ100,100��Ϊ���(���ᱻѡ�ϵ���)��rgb��Ϊ��2��2��2����Ϊ��ǣ���ʱrgb�Ǹ��������ݣ�
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
            
            B_one_day(:,:,n_image)=temp_B;%ͬһ����������Ƭ��B(����)
            S_one_day(:,:,n_image)=temp_S;%ͬһ����������Ƭ��S(���Ͷ�)
            r_one_day(:,:,n_image) = temp_r;%ͬһ����������Ƭ��red����
            g_one_day(:,:,n_image) = temp_g;%ͬһ����������Ƭ��green����
            b_one_day(:,:,n_image) = temp_b;%ͬһ����������Ƭ��blue����       
        end      
%--------Step2 �ڴ����ڽ�������DNֵѡ�񲢺ϳ�ÿ����Ƭimage_OCC---------------------------------
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
                L1=distence_0.*sin(angle);                       %����Ԫ������-���Ͷȶ�ά�ռ��У���1:1�ߵľ���
                L2=sqrt((1-temp_win_B).^2+(1-temp_win_S).^2);    %����Ԫ������-���Ͷȶ�ά�ռ��У������Ͻǣ�1,1���ľ���
                %��L1��L2��һ���ڽ��б�׼��
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
                CCI=normal_chuizhi+normal_distance;      %L1+L2����Ϊ������Ԫ����ָ��
                optimal_pixel= find(CCI==min(CCI,[],'all'));   %CCI��Сֵ��Ӧ��Ԫ��Ϊ���DNֵ
                if isempty(optimal_pixel)           %���û��ѡ�������Ԫ���ͽ�����Ԫλ����Ϊ��2,2,2��
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
        %����gccʱ����ȥDNֵΪ��2��2��2������Ԫ����󽫸ò�����Ԫ��ԭΪ��0��0��0��
        image_OCC_r=image_OCC(:,:,1);
        image_OCC_g=image_OCC(:,:,2);
        image_OCC_b=image_OCC(:,:,3);
        location_2=find(image_OCC_r==2);
        image_OCC_r(location_2)=[];
        image_OCC_g(location_2)=[];
        image_OCC_b(location_2)=[];
%--------Step3 ��ÿ�պϳ���Ƭimage_OCC�м���GCC_OCC-------------------------------------
        gcc_occ(n_date)=mean(image_OCC_g)/(mean(image_OCC_r)+mean(image_OCC_g)+mean(image_OCC_b));
        image_OCC(image_OCC==2)=0;
        imwrite(image_OCC,[output_path,'OCC_DailyPhoto','\',sitename,'_',num2str(n_date),'.jpg'])
    end   
    toc
end
csvwrite([output_path,'GCC_OCC.csv'],gcc_occ);
fprintf('Complete\n');


