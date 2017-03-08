function events = VDT_extractevents(fn)

%by session only 
%don't remember to change the number of dummies and TR in the dumpevent
%function below! 

%fn = '/imaging/bc01/May_2011/Visual_Discrimination_Task/Behavioural_Data/vdtCBU110624.txt';

%open file
fid = fopen(fn,'r');
%Read the first line of the file containing the header information

x=0;
while x ~= 1;
    headerline = fgetl(fid);
    x = findstr('On_Task',headerline);
    if isempty(x) == 1
        x = 0;
    end

end

%The file pointer is now at the beginning of the second line. Use TEXTSCAN 
%to read the columns of data.
%s = string, f = decimal number, d = integer

% add an "On_Task" column so that while the task is on I can always pick it out.
% add Task_Type before cue onset
% add Block_End_Onset
% add Block_End_Offset, both after the event onset/offset

data = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s');

%close file
fclose(fid);

% headers = textscan(headerline,'%s','Delimiter','\t');
headers = textscan(headerline,'%s','\b\t');

for k = 1:length(headers{:})
eval([headers{1}{k} '= data{k};']);
end

nevents = length(data{1});

% columns in output matrix represent: *# = doesn't change through a block

% block type (2=1, 4=2, 8=3, h=4, b=5) 
% block number 
% block difficulty (easy=1, hard=2) 

% inter block interval onset #
% inter block interval duration #

% block onset #
% block duration #

% event accuracy (true = 1, false = 2)

% event onset
% event duration
% response time
% event to response duration

% cue onset #
% cue duration #
% block end onset #
% block end duration #
% inter trial interval duration (onset will be same as response time)
% event code:
% 1 - correct,2
% 2 - correct,4
% 3 - correct,8
% 4 - correct,H
% 5 - correct,B
% 6 - incorrect,2
% 7 - incorrect,4
% 8 - incorrect,8
% 9 - incorrect,H
% 10 - incorrect,B
% 11 - cue,2
% 12 - cue,4
% 13 - cue,8
% 14 - cue,H
% 15 - cue,B
% 16 - block,2
% 17 - block,4
% 18 - block,8
% 19 - block,H
% 20 - block,B
% 21 - omission,2
% 22 - omission,4
% 23 - omission,8
% 24 - omission,H
% 25 - omission,B
% 26 - blockend,2
% 27 - blockend,4
% 28 - blockend,8
% 29 - blockend,H
% 30 - blockend,B

events = NaN(nevents,17); 

e=0;
cl=1; %current line
nl = cl;
cb = 0; % current block number starts at 0
prevBEO = 0; %to prevent error on first encounter

% loop through lines of onset file and process contents
while e<=(nevents - 1)
    e=e+1;
        
    if strcmp(On_Task(cl),'on')
        
        % events(e,1) get task type
        % convert current task type into numerical code
        tt=char(Task_Type(cl)); 
        
        switch tt 
            case '2'
               tt = 1;
            case '4'
                tt = 2;
            case '8'
                tt = 3;
            case 'H'
                tt = 4;
            case 'B'
                tt = 5;
        end
        
%         tt=strfind(taskid,tt);
%         tt=find(char(tt{:})~=' ');
    
        % events(e,2) get block number
        bn=(Block_Number(cl));
    
        % events(e,3) get block difficulty
        bd=char(Difficulty(cl));
        if strcmp(bd,'Easy')
            bd=1;
        elseif strcmp(bd,'Hard')
            bd=2;
        end
        
        % events(e,4) inter block interval onset
            if Block_End_Offset(cl) ~= 0
                ibio=(Block_End_Offset(cl));
                
                % events(e,5) inter block interval duration
                if e<= (nevents - 2)
                    ibid=(Cue_Onset(cl + 1)-ibio); %start of next block - end of last.
                else 
                    ibid = (ibio + 4000); %the hard-coded ibi before rest block
                end
                
                % events (e,15) block end signal onset
                beo = Block_End_Onset(cl);
        
                % events (e,16) block end signal duration
                bed = (Block_End_Offset(cl) - beo);
            else
                ibio = NaN;
                ibid = NaN;
                beo = NaN;
                bed = NaN;
            end
            
        if cb ~= bn
            cb = bn;
                     
            % events(e,6) block onset
            bo=(Event_Onset(cl));
    
            % events(e,7) block duration
            if Block_End_Onset(cl) == 0 || Block_End_Onset(cl) == prevBEO;
                while Block_End_Onset(nl) == 0
                        nl = nl+1;
                end
                prevBEO = Block_End_Onset(nl);
                bdur=((Block_End_Onset(nl)) - bo);
            else
                prevBEO = Block_End_Onset(cl);
                bdur=((Block_End_Onset(cl)) - bo);
            end
%             bdur = NaN;
        
            % events (e,13) cue onset
            co = Cue_Onset(cl);
        
            % events (e,14) cue dur
            cdur = (Cue_Offset(cl) - co);
                                    
        else
            bo = NaN;
            bdur = NaN;
            co = NaN;
            cdur = NaN;
        end
        
        % events(e,8), event accuracy
        if strcmpi(Accuracy(cl), 'True') 
            ac = 1; 
        elseif strcmpi(Accuracy(cl), 'False') 
            ac = 2; 
        elseif strcmpi(Accuracy(cl), 'Omission')
            ac = 0;
        end
            
        % events(e,9), event onset
        eo = Event_Onset(cl);
        
        % events(e,10) event duration
        ed = (Event_Offset(cl) - eo);
        
        % events(e,11) response time
        if Block_End_Onset(cl) == 0
            rt = Response_Time(cl);
        else
            rt = NaN; % for end of block signal
        end
        
        % events (e,12) event to response duration
        if Block_End_Onset(cl) == 0
            er = (rt - Event_Offset(cl));
        else
            er = NaN; % for end of block signal
        end
                             
        % events (e,17) ITI duration
        iti = ITI(cl);
        
%         % events (e,18) Event Codes
%         switch tt
%             case 1
%                 if ac == 1
%                     ec = 1;
%                 elseif ac == 2
%                     ec = 6;
%                 else ec = 21;
%                 end
%                 
%                 if co ~= 0
%                     ec = 11;
%                 end                    
%                  
%         end
                   
        events(e,1) = tt;
        events(e,2) = bn;
        events(e,3) = bd;
        events(e,4) = ibio;
        events(e,5) = ibid;
        events(e,6) = bo;
        events(e,7) = bdur;
        events(e,8) = ac;
        events(e,9) = eo;
        events(e,10) = ed;
        events(e,11) = rt;
        events(e,12) = er;
        events(e,13) = co;
        events(e,14) = cdur;
        events(e,15) = beo;
        events(e,16) = bed;
        events(e,17) = iti;
%         events(e,18) = ec;
           
    end
    
   cl=cl+1;
   if cl == 872
      sddsfds= 0; 
   end
   nl = cl + 1; %next line
             
end
