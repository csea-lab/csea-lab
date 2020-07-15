% polhemus6.m
% opens a serial port on the PC and 
% helps - a little - in digitizing headshape
% saves result as a BESA sfp-file
% cfg file must have 1<rows<25 and 1<cols<80
% as in other free software for this purpose
% andreas - summer of 2001
%
%  !!!!!!!!!!!!!!!!!uses matlab 6 built-in rather than cport minitoolbox

function[sfpmat, smat] = polhemus6();

% select cfg file
[file,path] = uigetfile('*.cfg', 'select cfg file');
cfgfilepath = [path file];
%%%%%%%%%%%%
% define feedback sound

t =0:(1000/44100)/1000:20/1000;
 diffsqrt = abs(sqrt(4000) - sqrt(3.2043e+03));
 diffsqrt_step = diffsqrt / length(t);
 sqrtvec = sqrt(3.2043e+03)+diffsqrt_step : diffsqrt_step : sqrt(4000);
 powervec = sqrtvec .^2;
 for index = 1 : length(t)
sweep(index) = sin(2*pi*powervec(index)*t(index));
end

M2 =10 * 44100 / 1000;
squarecos1 = (cos(pi/2:(pi-pi/2)/M2:pi-(pi-pi/2)/M2)).^2;
squarecos2 = (cos(0:(pi-pi/2)/M2:pi/2-(pi-pi/2)/M2)).^2;

sweep_tap = [sweep(1:M2) .* squarecos1 sweep(M2+1:length(t) - M2) sweep(length(t)-M2+1 : length(t)).*squarecos2];


% draw positions according to cfgfile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -->  figure settings

h2 = figure(2)
subplot(2,1,1)
th2 = title(' electrode  positions  already digitized:front ');
set(h2, 'Position' , [500,20,500,700]) 
set(th2, 'FontSize', 12)
set(th2, 'FontName', 'arial')

subplot(2,1,2)
th2 = title(' electrode  positions  already digitized:left ');
set(h2, 'Position' , [500,20,500,700]) 
set(th2, 'FontSize', 12)
set(th2, 'FontName', 'arial')



h = figure(1);
set(h, 'Position' , [11,20,500,700]) 
th = title(' electrode  positions  to  digitize ');
set(th, 'FontSize', 14)
set(th, 'FontName', 'arial')
set(th, 'FontWeight', 'bold')
axis([20 65 0 25]); 
axis off
view(0, 270)



% ----> read entire file to determine size
			fid = fopen(cfgfilepath);
			
			linecount = 0;		
		while 1
            line = fgetl(fid);
            if ~isstr(line), break, end
            linecount = linecount +1;	
        end
	
			fclose(fid)
			
% ----> define text and pos matrices
		charmat = char(zeros(linecount, 20));
		posmat  = zeros(linecount,2);
		sfpmat = zeros(linecount,3);
      
% ----> read data into matrices
			fid = fopen(cfgfilepath);
			index = 1

		while 1
            line = fgetl(fid);
            if ~isstr(line), break, end
            blankInd = findstr(line,' ');
			charmat(index,1:blankInd(1)-1) = line(1:blankInd(1)-1);
			posmat(index,:) = str2num(line(blankInd(1)+1:length(line)));
			index = index+1;
		end
	
			fclose(fid)

			
			
%%%%%%%%%%% ----> draw in yellow
msgbox('digitization follows the highlighted sensors. press stylus button at nasion to start digitization', 'start digitization','help')



for positionInd = 1:size(posmat,1);
	h=text(posmat(positionInd,2),posmat(positionInd,1),deblank(charmat(positionInd,:)));
	set(h,'color', 'y')
	set(h,'FontSize', 12)
	set(h,'FontWeight', 'demi')
end



%%%%%%%%%%open and configure serial port comm1:
H = serial('COM1');
     fopen(H)
        set(H,'BaudRate',9600,'Parity','N', 'Timeout', 600);


for positionInd = 1:size(posmat,1);
	h=text(posmat(positionInd,2),posmat(positionInd,1),deblank(charmat(positionInd,:)));
	set(h,'color', 'k')
	set(h,'FontSize', 20)
	set(h,'FontWeight', 'bold')
pause(0.2)
%read polhemus coordinates from serial port

s=fgetl(H)
pause(0.2)
sound(sweep_tap, 22100)

%[stat,ErrStr]=cportreset(H)

   set(h,'color', 'r')
	set(h,'FontSize', 12)
   set(h,'FontWeight', 'demi')
   
smat = [smat; s];
dotInd = findstr(s, '.');
sfpmat(positionInd,:) = abs(str2num(s(3:dotInd(3)+2)))  

figure(2)
th2 = title(' electrode  positions  already digitized:front ');
set(h2, 'Position' , [500,20,500,700]) 
set(th2, 'FontSize', 12)
set(th2, 'FontName', 'arial')

subplot(2,1,2)
th2 = title(' electrode  positions  already digitized:left ');
set(h2, 'Position' , [500,20,500,700]) 
set(th2, 'FontSize', 12)
set(th2, 'FontName', 'arial')

if positionInd > 1
subplot(2,1,1), plot(sfpmat(positionInd-1,2).*-1, sfpmat(positionInd-1,1),'k*')
end
subplot(2,1,1), plot(sfpmat(positionInd,2).*-1, sfpmat(positionInd,1),'r*')
hold on
if positionInd > 1
subplot(2,1,2), plot(sfpmat(positionInd-1,1), sfpmat(positionInd-1,3),'k*')
end
subplot(2,1,2), plot(sfpmat(positionInd,1), sfpmat(positionInd,3),'r*')
hold on

figure(1)

end
fclose(H)			

msgbox('digitization is completed. coordinate matrix is saved to file. select path and filename in the ui-box', ' digitization completed ','help')
pause(3)
[file, path] = uiputfile('*', 'insert basename (no extension) for coordinate files')

% 0. resort output matrix to be fiducials at top + 1:129 at bottom in right order
realindvecEEGchar = charmat(5:size(charmat,1), 2:size(charmat,2));
realindvecEEGnum = []
for ind2 = 1:size(realindvecEEGchar,1)
    if ind2 == 1
    realindvecEEGnum = str2num(realindvecEEGchar(ind2,:))
    else
    realindvecEEGnum = [realindvecEEGnum;str2num(realindvecEEGchar(ind2,:))]
    end
end

indexvecnew = 1:length(realindvecEEGnum)
sfpmat_ord = zeros(length(realindvecEEGnum),size(sfpmat,2));

for ind3 = 1:length(indexvecnew)
    index_old_coor = find(realindvecEEGnum == ind3)
    sfpmat_ord(ind3, :) = sfpmat(index_old_coor + 4, :)
end

% build sfpmat_out for ascii
sfpmat_out1 = [sfpmat(1:4, :);sfpmat_ord];

% account for hardware/besaformat:
% first axis(x)= y in besa, second(y) = x in besa

sfpmat_out = [sfpmat_out1(:,2) sfpmat_out1(:,1) sfpmat_out1(:,3)];

% 1. save to ascii file
eval(['save ',path, file ,'.dat sfpmat_out -ascii'])


% 2. save to sfp file
% outmat for sfp-file
% [textmat tabvec coormat]

textmatfiduc = strvcat('FidNz', 'FidT9', 'FidT10','FidIn');
for ind4 = 1:length(realindvecEEGnum)
		if ind4 == 1
			textmatEEG = ['EEG1'];
		else
			textmatEEG = strvcat(textmatEEG, ['EEG' num2str(ind4)]);
		end
	end

textmatcomplete = strvcat(textmatfiduc, textmatEEG)

% tabs 
	tab = sprintf('\t');
	for ind5 = 1:size(textmatcomplete,1)
		if ind5 == 1
			blanktabMat =  [tab];
		else
			blanktabMat = [blanktabMat; tab];
		end
	end
	
% outmat_sfp
outmat_sfp = [textmatcomplete blanktabMat num2str(sfpmat_out)];
    
fid = fopen([path file '.sfp'], 'w')
	
	[a_end,b_end] = size(sfpmat);
	
	
	
 	for a = 1:a_end
		
            
 			fprintf(fid, '%s ', outmat_sfp(a,:));
           
		   
                
            fprintf(fid, '\n');

	end
		
	fclose(fid);
	

   