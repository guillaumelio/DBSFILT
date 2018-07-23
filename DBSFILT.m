function varargout = DBSFILT(varargin)
% DBFILT() -
%     DBSFILT - Launch a Matlab GUI (Graphical User Interface)for removing 
%     High Frequency Deep Brain Stimulation induced artifacts from 
%     electroencephalographic data.
%
%     Available methods are : 
%     - Simple Low pass filtering.
%     - Low pass filtering + Frequency space outliers (spikes) rejection
%     (Allen et al. 2010)
%     - Low pass filtering + manual/automatic DBS induced spikes rejection
%     (Jech et al. 2006; Lio et al. 2013)
%     
%
%    USAGE :
%                >> DBSFILT
%                
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author : G. Lio 
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% v1.0 November 2012
%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References :
%
% Allen DP, Stegemöller EL, Zadikoff C, Rosenow JM, Mackinnon CD.
% Suppression of deep brain stimulation artifacts from the electroencephalogram by
% frequency-domain Hampel filtering.
% Clin Neurophysiol. 2010
% 
% Jech R, Ruzicka E, Urgosík D, Serranová T, Volfová M, Nováková O, Roth J,
% Dusek P, Mecír P. 
% Deep brain stimulation of the subthalamic nucleus affects resting EEG and visual
% evoked potentials in Parkinson's disease.
% Clin Neurophysiol. 2006
% 
% Lio G, Ballanger B, Thobois S, Boulinguez B.
% Removing deep brain stimulation artifacts from the electroencephalogram: issues,
% recommendations and open-source Toolbox.
% Submitted to Clinical Neurophysiology 2013
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2012 Guillaume Lio, guillaume.lio@isc.cnrs.fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%


% INIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DBSFILT_OpeningFcn, ...
                   'gui_OutputFcn',  @DBSFILT_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End INIT


% --- Executes just before DBSFILT is made visible.
function DBSFILT_OpeningFcn(hObject, eventdata, handles, varargin)
    global A1;
    fprintf('DBSFILT >> Initialization... \n')
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DBSFILT (see VARARGIN)

% Choose default command line output for DBSFILT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%set(hObject,'Color',[0.8 0.9 0.96]); 
%set(hObject,'Color',[0 0 0]); 

%I=imread('LOGO.png','BackgroundColor',[0.947 0.947 0.947]);
I=imread('LOGO.png','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
imshow(I);

DBSFILT_InitA1(hObject, eventdata, handles);
DBSFILT_InitA2(hObject, eventdata, handles);
DBSFILT_InitA3(hObject, eventdata, handles);

if(exist('pop_loadset','file')~=2)
    msgbox('EEGLAB toolbox not detected in the MATLAB path.','Toolbox','custom',A1.Iw,[],'modal')
end
if(exist('cheby2','file')~=2)
    msgbox('Signal Processing toolbox not detected in the MATLAB path.','Toolbox','custom',A1.Iw,[],'modal')
end
fprintf('DBSFILT >> Done.\n')



% --- GUI Initialization function - set default parameters.
function DBSFILT_InitA3(hObject, eventdata, handles)
global A3;

A3.x=[];
A3.EEG=[];
A3.ext='';
A3.varname='';

A3.filename='No file loaded...';
A3.filename2='No file loaded...';
A3.sr='?';

A3.spikes=[];
A3.nb_spikes=0;
A3.FFTlength=[];
A3.DATAlength=[];

A3.str_spike='0 spike detected';
set(handles.text_tab3_box2_detectedspikes,'String',A3.str_spike);
set(handles.text_tab3_box2_detectedspikes,'ForegroundColor',[0 0 0]);

set(handles.text_tab3_box1_filename,'String',A3.filename);
set(handles.text_tab3_box2_filename,'String',A3.filename2);
set(handles.edit_tab3_box1_sr,'String',A3.sr);

A3.Fmin=1;
A3.Fmax=100;

set(handles.edit_tab3_box4_fmin,'String',A3.Fmin);
set(handles.edit_tab3_box4_fmax,'String',A3.Fmax);

A3.Manual_Fwinwidth=1;
A3.Manual_nbspikes=1;
A3.Manual_targetF=130;

set(handles.edit_tab3_box3_Fwinwidth,'String',A3.Manual_Fwinwidth);
set(handles.edit_tab3_box3_nbspikes,'String',A3.Manual_nbspikes);
set(handles.edit_tab3_box3_targetF,'String',A3.Manual_targetF);




function DBSFILT_InitA2(hObject, eventdata, handles)
global A2;

A2.x=[];
A2.EEG=[];
A2.ext='';
A2.varname='';

A2.filename='No file loaded...';
A2.sr='?';

A2.HampelL=1;
A2.HampelT=1.5;

A2.FdbsL=130;
A2.FdbsR=130;
A2.nmax=5;
A2.eps=0.002;

A2.type=2;
A2.nb_spikes=0;
A2.str_spike='0 spike detected';

A2.Fmin=1;
A2.Fmax=100;
A2.SpikeFlag=1;

A2.spikes=[];
A2.FFTlength=[];
A2.DATAlength=[];
A2.nb_spikes=0;

set(handles.text_tab2_box1_filename,'String',A2.filename);
set(handles.edit_tab2_box1_sr,'String',A2.sr);

set(handles.radiobutton_tab2_box2_dbsID,'Value',1);
set(handles.radiobutton_tab2_box2_hampel,'Value',0);

set(handles.edit_tab2_box2_hampelT,'String',A2.HampelT);
set(handles.edit_tab2_box2_hampelWL,'String',A2.HampelL);
set(handles.edit_tab2_box2_dbsR,'String',A2.FdbsR);
set(handles.edit_tab2_box2_dbsL,'String',A2.FdbsL);
set(handles.edit_tab2_box2_Ftol,'String',A2.eps);
set(handles.edit_tab2_box2_Nmax,'String',A2.nmax);

set(handles.checkbox_tab2_box3_showspikes,'Value',1);

A2.str_spike='0 spike detected';
set(handles.text_tab2_box2_DetectedSpikes,'String',A2.str_spike);
set(handles.text_tab2_box2_DetectedSpikes,'ForegroundColor',[0 0 0]);

set(handles.edit_tab2_box3_fmin,'String',A2.Fmin);
set(handles.edit_tab2_box3_fmax,'String',A2.Fmax);



function DBSFILT_InitA1(hObject, eventdata, handles)
global A1;

A1.Ie=imread('icE.png','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
A1.Ii=imread('icI.png','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
A1.Iw=imread('icW.png','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));

A1.x=[];
A1.EEG=[];
A1.ext='';
A1.varname='';

A1.filtercount=0;

A1.filename='No file loaded...';
A1.sr='?';

A1.F_LP_flag=1;
A1.F_LP_cut=94.5;
A1.F_LP_width=2.5;
A1.F_LP_ripple=0.01;
A1.F_LP_attenuation=120;

A1.F_HP_flag=1;
A1.F_HP_cut=0.75;
A1.F_HP_width=0.5;
A1.F_HP_ripple=0.01;
A1.F_HP_attenuation=120;

A1.F_N_flag=0;
A1.F_N_cut1=48.5;
A1.F_N_cut2=51.5;
A1.F_N_width=1;
A1.F_N_ripple=0.01;
A1.F_N_attenuation=120;

A1.borderlength=4;

A1.Fmin=1;
A1.Fmax=100;

set(handles.text_tab1_box1_filename,'String',A1.filename);
set(handles.edit_tab1_box1_sr,'String',A1.sr);

set(handles.checkbox_tab1_box2_LP,'Value',A1.F_LP_flag);
set(handles.edit_tab1_box2_LP_fcut,'String',A1.F_LP_cut);
set(handles.edit_tab1_box2_LP_fbandwidth,'String',A1.F_LP_width);
set(handles.edit_tab1_box2_LP_Att,'String',A1.F_LP_attenuation);
set(handles.edit_tab1_box2_LP_Rip,'String',A1.F_LP_ripple);

set(handles.checkbox_tab1_box2_HP,'Value',A1.F_HP_flag);
set(handles.edit_tab1_box2_HP_fcut,'String',A1.F_HP_cut);
set(handles.edit_tab1_box2_HP_fbandwidth,'String',A1.F_HP_width);
set(handles.edit_tab1_box2_HP_Att,'String',A1.F_HP_attenuation);
set(handles.edit_tab1_box2_HP_Rip,'String',A1.F_HP_ripple);

set(handles.checkbox_tab1_box2_Notch,'Value',A1.F_N_flag);
set(handles.edit_tab1_box2_Notch_fcut1,'String',A1.F_N_cut1);
set(handles.edit_tab1_box2_Notch_fcut2,'String',A1.F_N_cut2);
set(handles.edit_tab1_box2_Notch_fbandwidth,'String',A1.F_N_width);
set(handles.edit_tab1_box2_Notch_Att,'String',A1.F_N_attenuation);
set(handles.edit_tab1_box2_Notch_Rip,'String',A1.F_N_ripple);

set(handles.edit_tab1_box3_borderlength,'String',A1.borderlength);

set(handles.edit_tab1_box4_fmin,'String',A1.Fmin);
set(handles.edit_tab1_box4_fmax,'String',A1.Fmax);

% UIWAIT makes DBSFILT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DBSFILT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;







%% ////////////////////////////////////////////////////////////////////////
%  Tab 1 - Temporal filtering
%%  ///////////////////////////////////////////////////////////////////////


%) Box 1 - Load data
%% ------------------------------------------------------------------------

                % Callback functions
                %"""""""""""""""""""

                function edit_tab1_box1_sr_Callback(hObject, eventdata, handles)
                global A1;
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  if(strcmp(get(hObject,'string'),'ILOVPINK'))
                      strflag = DBSFILT_warndlg('title','Warncat','string','Pink... Oh..          Do you want to proceed anyway ???');
                      if(strcmp(strflag,'Yes'))
                          set(handles.figure1,'Color',[1 0.9 0.9]);
                      end
                  end
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                  return
                else
                  if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                  else
                      A1.sr=temp;
                      fprintf('DBSFILT - Sampling Rate : %d Hz\n',A1.sr);
                  end
                end
                


                function edit_tab1_box1_filename_Callback(hObject, eventdata, handles)
                % Hints: get(hObject,'String') returns contents of text_tab1_box1_filename as text
                %        str2double(get(hObject,'String')) returns contents of text_tab1_box1_filename as a double

                function pushbutton_tab1_box1_load_Callback(hObject, eventdata, handles)
                global A1;
                [A1.x,A1.filename,A1.sr,A1.EEG, A1.ext,A1.varname,flag] = DBSFILT_loaddata();
                if(flag==0)
                    A1.filename='No file loaded...';
                    A1.sr='?';
                    A1.x=[];
                    A1.EEG=[];
                    A1.ext='';
                    A1.varname='';
                    A1.filtercount=0;
                    set(handles.text_tab1_box1_filename,'String',A1.filename);
                    set(handles.edit_tab1_box1_sr,'String',A1.sr);
                    msgbox('File not loaded.','ERROR','custom',A1.Ie,[],'modal')
                else
                    if(strcmp(A1.ext,'.set') || strcmp(A1.ext,'.SET'))
                        set(handles.edit_tab1_box1_sr,'String',num2str(A1.sr));                        
                    else
                        A1.sr='?';
                        set(handles.edit_tab1_box1_sr,'String',A1.sr);
                    end
                    set(handles.text_tab1_box1_filename,'String',A1.filename); 
                    A1.filtercount=0;
                end
                    
                
                

                % Create functions
                %"""""""""""""""""""

                function text_tab1_box1_filename_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end
                
                function edit_tab1_box1_sr_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end


%) Box 2 - Temporal filtering
%% ------------------------------------------------------------------------

            %) Low Pass Filter
            %______________________________________________________________
            
            
                % Callback functions
                %"""""""""""""""""""

                function checkbox_tab1_box2_LP_Callback(hObject, eventdata, handles)
                global A1,
                A1.F_LP_flag=get(hObject,'Value');
                if(A1.F_LP_flag)
                    fprintf('DBSFILT - Low pass filter : ON\n');
                else
                    fprintf('DBSFILT - Low pass filter : OFF\n');
                end
                

                function edit_tab1_box2_LP_fcut_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_LP_cut=temp;
                  fprintf('DBSFILT - Low pass - F cut : %f Hz\n',A1.F_LP_cut);
                end


                function edit_tab1_box2_LP_fbandwidth_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_LP_width=temp;
                  fprintf('DBSFILT - Low pass - F bandwidth : %f Hz\n',A1.F_LP_width);
                end

                function edit_tab1_box2_LP_Att_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_LP_attenuation=temp;
                  fprintf('DBSFILT - Low pass - Attenuation : %d dB\n',A1.F_LP_attenuation);
                end

                function edit_tab1_box2_LP_Rip_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_LP_ripple=temp;
                  fprintf('DBSFILT - Low pass - Attenuation : %f dB\n',A1.F_LP_ripple);
                end


                % Create functions
                %"""""""""""""""""""    

                function edit_tab1_box2_LP_fcut_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                     set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_LP_fbandwidth_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                   set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_LP_Att_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_LP_Rip_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end
            
            
            %) High Pass Filter
            %______________________________________________________________

                % Callback functions
                %"""""""""""""""""""

                function checkbox_tab1_box2_HP_Callback(hObject, eventdata, handles)
                global A1,
                A1.F_HP_flag=get(hObject,'Value');
                if(A1.F_HP_flag)
                    fprintf('DBSFILT - High pass filter : ON\n');
                else
                    fprintf('DBSFILT - High pass filter : OFF\n');
                end


                function edit_tab1_box2_HP_fcut_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_HP_cut=temp;
                  fprintf('DBSFILT - High pass - F cut : %f Hz\n',A1.F_HP_cut);
                end

                function edit_tab1_box2_HP_fbandwidth_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_HP_width=temp;
                  fprintf('DBSFILT - High pass - F bandwidth : %f Hz\n',A1.F_HP_width);
                end
                
                function edit_tab1_box2_HP_Att_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_HP_attenuation=temp;
                  fprintf('DBSFILT - High pass - Attenuation : %d dB\n',A1.F_HP_attenuation);
                end

                function edit_tab1_box2_HP_Rip_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_HP_ripple=temp;
                  fprintf('DBSFILT - High pass - Ripple : %f dB\n',A1.F_HP_ripple);
                end


                % Create functions
                %""""""""""""""""""" 

                function edit_tab1_box2_HP_fcut_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_HP_fbandwidth_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_HP_Att_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_HP_Rip_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end
            
            
            %) Notch Filter
            %______________________________________________________________

            
                % Callback functions
                %"""""""""""""""""""

                function checkbox_tab1_box2_Notch_Callback(hObject, eventdata, handles)
                global A1,
                A1.F_N_flag=get(hObject,'Value');
                if(A1.F_N_flag)
                    fprintf('DBSFILT - Band stop filter : ON\n');
                else
                    fprintf('DBSFILT - Band stop filter : OFF\n');
                end


                function edit_tab1_box2_Notch_fcut1_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_N_cut1=temp;
                  fprintf('DBSFILT - Band stop - F cut 1 : %f Hz\n',A1.F_N_cut1);
                end
                
                function edit_tab1_box2_Notch_fcut2_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_N_cut2=temp;
                  fprintf('DBSFILT - Band stop - F cut 2 : %f Hz\n',A1.F_N_cut2);
                end
                  
                function edit_tab1_box2_Notch_Att_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_N_attenuation=temp;
                  fprintf('DBSFILT - Band stop - Attenuation : %d dB\n',A1.F_N_attenuation);
                end

                function edit_tab1_box2_Notch_fbandwidth_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_N_width=temp;
                  fprintf('DBSFILT - Band stop - F bandwidth : %f Hz\n',A1.F_N_width);
                end
                    
                function edit_tab1_box2_Notch_Rip_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.F_N_ripple=temp;
                  fprintf('DBSFILT - Band stop - Ripple : %f dB\n',A1.F_N_ripple);
                end



                % Create functions
                %""""""""""""""""""" 

                function edit_tab1_box2_Notch_fcut1_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_Notch_fcut2_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_Notch_fbandwidth_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_Notch_Att_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box2_Notch_Rip_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end
            
            
            %) Display filters
            %______________________________________________________________

                % Callback functions
                %"""""""""""""""""""

                function pushbutton_tab1_box2_display_Callback(hObject, eventdata, handles)
                global A1;
                if(isnumeric(A1.sr))
                    HD1=[];
                    HD2=[];
                    HD3=[];
                    if(A1.F_LP_flag)
                        try
                           HD1= DBSFILT_lowpassfilterHD(A1.sr,A1.F_LP_cut,A1.F_LP_width,A1.F_LP_attenuation,A1.F_LP_ripple);
                        catch
                           msgbox('Invalid Low pass filter parameters','Bad Input','custom',A1.Ie,[],'modal')
                        end
                    end
                    if(A1.F_HP_flag)
                        try
                           HD2= DBSFILT_highpassfilterHD(A1.sr,A1.F_HP_cut,A1.F_HP_width,A1.F_HP_attenuation,A1.F_HP_ripple);
                        catch
                           msgbox('Invalid High pass filter parameters','Bad Input','custom',A1.Ie,[],'modal')
                        end
                    end
                    if(A1.F_N_flag)
                        try
                           HD3= DBSFILT_bandstopfilterHD(A1.sr,A1.F_N_cut1,A1.F_N_cut2,A1.F_N_width,A1.F_N_attenuation,A1.F_N_ripple);
                        catch
                           msgbox('Invalid Band stop filter parameters','Bad Input','custom',A1.Ie,[],'modal')
                        end
                    end
                    
                    if(isempty(HD1))
                        if(isempty(HD2))
                            if(isempty(HD3))
                                msgbox('0 valid filter to plot','Warning','custom',A1.Iw,[],'modal')
                            else
                                fvtool(HD3)
                            end
                        else
                            fvtool(HD2,HD3)
                        end
                    else
                        fvtool(HD1,HD2,HD3)
                    end

                else
                    msgbox('You must enter a numeric value for the sampling rate','Bad Input','custom',A1.Ie,[],'modal')
                end
                
            %) Launch filtering
            %______________________________________________________________

           
            
                % Callback functions
                %"""""""""""""""""""

                function pushbutton_tab1_box2_start_Callback(hObject, eventdata, handles)
                global A1;
                if(A1.filtercount>0)
                    str=sprintf('Data in memory has already been filtered %d times. Filter anyway ?\n',A1.filtercount);
                    strflag = DBSFILT_warndlg('title','Warning','string',str);
                    if(strcmp(strflag,'No'))
                        return
                    end
                end
                if(isnumeric(A1.sr))
                    if(isempty(A1.x)~=1)
                        HD1=[];
                        HD2=[];
                        HD3=[];
                        if(A1.F_LP_flag)
                            try
                               HD1= DBSFILT_lowpassfilterHD(A1.sr,A1.F_LP_cut,A1.F_LP_width,A1.F_LP_attenuation,A1.F_LP_ripple);
                               A1.filtercount=A1.filtercount+1;
                            catch
                               msgbox('Invalid Low pass filter parameters','Bad Input','custom',A1.Ie,[],'modal')
                            end
                        end
                        if(A1.F_HP_flag)
                            try
                               HD2= DBSFILT_highpassfilterHD(A1.sr,A1.F_HP_cut,A1.F_HP_width,A1.F_HP_attenuation,A1.F_HP_ripple);
                               A1.filtercount=A1.filtercount+1;
                            catch
                               msgbox('Invalid High pass filter parameters','Bad Input','custom',A1.Ie,[],'modal')
                            end
                        end
                        if(A1.F_N_flag)
                            try
                               A1.filtercount=A1.filtercount+1;
                               HD3= DBSFILT_bandstopfilterHD(A1.sr,A1.F_N_cut1,A1.F_N_cut2,A1.F_N_width,A1.F_N_attenuation,A1.F_N_ripple);
                            catch
                               msgbox('Invalid Band stop filter parameters','Bad Input','custom',A1.Ie,[],'modal')
                            end
                        end

                        if(isempty(HD1)~=1)
                                A1.x= DBSFILT_lowpassfilter(A1.x,A1.sr,A1.F_LP_cut,A1.F_LP_width,A1.F_LP_attenuation,A1.F_LP_ripple);
                        end
                        if(isempty(HD2)~=1)
                                A1.x= DBSFILT_highpassfilter(A1.x,A1.sr,A1.F_HP_cut,A1.F_HP_width,A1.F_HP_attenuation,A1.F_HP_ripple);
                        end
                        if(isempty(HD3)~=1)
                                A1.x= DBSFILT_bandstopfilter(A1.x,A1.sr,A1.F_N_cut1,A1.F_N_cut2,A1.F_N_width,A1.F_N_attenuation,A1.F_N_ripple);
                        end
                    else
                        msgbox('No loaded file...','ERROR','custom',A1.Ie,[],'modal')
                    end
                else
                     msgbox('You must enter a numeric value for the sampling rate','Bad Input','custom',A1.Ie,[],'modal')
                end
                    

%) Box 3 - Remove filters transient effect
%% ------------------------------------------------------------------------

                function edit_tab1_box3_borderlength_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.borderlength=temp;
                  fprintf('Time period to remove : %f s\n',A1.borderlength);
                end


                function edit_tab1_box3_borderlength_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end


                function pushbutton_tab1_box3_start_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(A1.borderlength)~=1)
                    if(isempty(A1.x)~=1)
                        fprintf('DBSFILT >> Remove first and last %f second(s) from the data...\n',A1.borderlength);
                        if isempty(A1.EEG)
                            if(isnumeric(A1.sr))
                                try
                                    A1.x= DBSFILT_cutdata(A1.x,A1.sr,A1.borderlength);
                                    fprintf('DBSFILT >> OK.\n');
                                catch
                                    msgbox('ERROR... Data length might be to short.','ERROR','custom',A1.Ie,[],'modal')
                                end

                            else
                            fprintf('DBSFILT >> ERROR.\n');
                            msgbox('You must enter a numeric value for the sampling rate','Bad Input','custom',A1.Ie,[],'modal')
                            end
                        else
                           try 
                               [A1.x A1.EEG]= DBSFILT_cutdataEEG(A1.x,A1.borderlength,A1.EEG);
                               fprintf('DBSFILT >> OK.\n');
                           catch
                               msgbox('ERROR... Data length might be to short.','ERROR','custom',A1.Ie,[],'modal')
                           end
                        end
                    else
                        msgbox('Data matrix is empty...','ERROR','custom',A1.Ie,[],'modal')
                    end
                else
                    msgbox('You must enter a numeric value for the length of data removed.','Bad Input','custom',A1.Ie,[],'modal')
                end
                        
                        


%) Box 4 - Plot spectra
%% ------------------------------------------------------------------------

                function pushbutton_tab1_box4_plot_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(A1.x)==1)
                   msgbox('Data matrix is empty...','ERROR','custom',A1.Ie,[],'modal')
                else
      
                if(A1.Fmin<A1.Fmax)
                    if(isnumeric(A1.sr))
                        DBSFILT_display_rawfftspectra(A1.x,A1.sr,A1.Fmin,A1.Fmax,'Mean spectrum (FFT)')
                    else
                        msgbox('You must enter a numeric value for the sampling rate','Bad Input','custom',A1.Ie,[],'modal')
                    end
                else
                   msgbox('fmin and fmax must be numeric values, with fmin<fmax.','Bad Input','custom',A1.Ie,[],'modal')
                end
                
                end

                function edit_tab1_box4_fmin_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.Fmin=temp;
                  fprintf('DBSFILT - Plot spectra, fmin : %d Hz\n',A1.Fmin);
                end


                function edit_tab1_box4_fmax_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A1.Fmax=temp;
                  fprintf('DBSFILT - Plot spectra, fmax : %d Hz\n',A1.Fmax);
                end

                
                function edit_tab1_box4_fmin_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end

                function edit_tab1_box4_fmax_CreateFcn(hObject, eventdata, handles)
                if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                    set(hObject,'BackgroundColor','white');
                end



%) Box 5 - GUI controls
%% ------------------------------------------------------------------------

                function pushbutton_tab1_box5_saveas_Callback(hObject, eventdata, handles)
                global A1;
                if(isempty(A1.x)==1)
                   msgbox('Data matrix is empty...','ERROR','custom',A1.Ie,[],'modal')
                else
                    try
                    flag = DBSFILT_savedataas(A1.x,A1.EEG,A1.ext,A1.varname,A1.filename,'_TemporalFiltered');
                    %if(flag==0)
                    catch
                        msgbox('File not saved','Warning','custom',A1.Iw,[],'modal');
                    end
                end                    

                function pushbutton_tab1_box5_reset_Callback(hObject, eventdata, handles)
                strflag = DBSFILT_warndlg('title','Warning','string','This will clear all data in memory for the current tab. Do you want to proceed ?');
                if(strcmp(strflag,'Yes'))
                    DBSFILT_InitA1(hObject, eventdata, handles);
                end
                    



%) Others
%% ------------------------------------------------------------------------



%% ////////////////////////////////////////////////////////////////////////
%%  Tab 2 - Spikes detection
%% ////////////////////////////////////////////////////////////////////////

%) Box 1 - Import
%% ------------------------------------------------------------------------

        function pushbutton_tab2_box1_load_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
                [A2.x,A2.filename,A2.sr,A2.EEG, A2.ext,A2.varname,flag] = DBSFILT_loaddata();
                if(flag==0)
                    A2.filename='No file loaded...';
                    A2.sr='?';
                    A2.x=[];
                    A2.EEG=[];
                    A2.ext='';
                    A2.varname='';
                    set(handles.text_tab2_box1_filename,'String',A2.filename);
                    set(handles.edit_tab2_box1_sr,'String',A2.sr);
                    msgbox('File not loaded.','ERROR','custom',A1.Ie,[],'modal')
                else
                    if(strcmp(A2.ext,'.set') || strcmp(A2.ext,'.SET'))
                        set(handles.edit_tab2_box1_sr,'String',num2str(A2.sr));
                    else
                        A2.sr='?';
                        set(handles.edit_tab2_box1_sr,'String',A2.sr);
                    end
                    set(handles.text_tab2_box1_filename,'String',A2.filename); 
                end
                   

        function text_tab2_box1_filename_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
        
        
        function edit_tab2_box1_sr_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end


        function edit_tab2_box1_sr_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A2.sr=temp;
                  fprintf('DBSFILT - Sampling Rate : %d Hz\n',A2.sr);
                end




%) Box 2 - Spikes detection
%% ------------------------------------------------------------------------



    %) Radio
        
        function radiobutton_tab2_box2_hampel_Callback(hObject, eventdata, handles)
        global A2;
        set(handles.radiobutton_tab2_box2_dbsID,'Value',0);
        fprintf('DBSFILT - DBS spikes identification : OFF\n');
        A2.type=1;
        drawnow

        function radiobutton_tab2_box2_dbsID_Callback(hObject, eventdata, handles)
        global A2;
        set(handles.radiobutton_tab2_box2_hampel,'Value',0);
        fprintf('DBSFILT - DBS spikes identification : ON\n');
        A2.type=2;
        drawnow
        
     %) Hampel parameters

        % - Hampel T -
        function edit_tab2_box2_hampelT_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end

        function edit_tab2_box2_hampelT_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                  return
                else
                  A2.HampelT=temp;
                  fprintf('DBSFILT - Hampel threshold : %d \n',A2.HampelT);
                end

            
        % - Hampel WL -
        function edit_tab2_box2_hampelWL_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end

        function edit_tab2_box2_hampelWL_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                  return
                else
                  A2.HampelL=temp;
                  fprintf('DBSFILT - Hampel, windows length : %d Hz\n',A2.HampelL);
                end
     
     
     %) DBS spikes ID parameters

        % - dbsR -
        function edit_tab2_box2_dbsR_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                  return
                else
                  A2.FdbsR=temp;
                  fprintf('DBSFILT - Right DBS frequency : %d Hz\n',A2.FdbsR);
                end

        
        function edit_tab2_box2_dbsR_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
        
        % - dbsL -
        function edit_tab2_box2_dbsL_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end

        function edit_tab2_box2_dbsL_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                  return
                else
                  A2.FdbsL=temp;
                  fprintf('DBSFILT - Left DBS frequency : %d Hz\n',A2.FdbsL);
                end

        
        % - Ftol -
        function edit_tab2_box2_Ftol_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                  return
                else
                  A2.eps=temp;
                  fprintf('DBSFILT - DBS frequency tolerance : %d Hz\n',A2.eps);
                end
        
        function edit_tab2_box2_Ftol_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end

        % - nmax -
        function edit_tab2_box2_Nmax_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end

        function edit_tab2_box2_Nmax_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                  return
                else
                  A2.nmax=temp;
                  fprintf('DBSFILT - Maximum aliasing rate : %d \n',A2.nmax);
                end

%         A2.HampelL=1;
%         A2.HampelT=1.5;
% 
%         A2.FdbsL=130;
%         A2.FdbsR=130;
%         A2.nmax=10;
%         A2.eps=0.001;
% 
%         A2.type=2;
%         A2.nb_spikes=0;
%         A2.str_spike='0 spike detected';
% 
%         A2.Fmin=1;
%         A2.Fmax=100;
%         A2.SpikeFlag=1;

            
     %) START
        
        function pushbutton_tab2_box2_start_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
                               
                if(isnumeric(A2.sr))
                     if(isempty(A2.x)~=1)
                          try
                             [A2.spikes, A2.FFTlength, A2.DATAlength]=DBSFILT_PrepareSpikesDetection(A2.x,A2.sr);
                             [A2.spikes, A2.nb_spikes]=DBSFILT_SpikesDetection(A2.spikes, A2.type, A2.HampelL, A2.HampelT, A2.FdbsL, A2.FdbsR, A2.nmax, A2.eps);
                             if(A2.nb_spikes~=0)
                                 if(A2.nb_spikes==1)
                                    A2.str_spike='1 spike detected';
                                    set(handles.text_tab2_box2_DetectedSpikes,'ForegroundColor',[0.7 0 0]);
                                 else
                                    A2.str_spike=sprintf('%d spikes detected',A2.nb_spikes);
                                    set(handles.text_tab2_box2_DetectedSpikes,'ForegroundColor',[0.7 0 0]);
                                 end
                             else
                                A2.str_spike='0 spike detected';
                                set(handles.text_tab2_box2_DetectedSpikes,'ForegroundColor',[0 0 0]);
                             end
                             set(handles.text_tab2_box2_DetectedSpikes,'String',A2.str_spike);
                             
                           catch
                             msgbox('Invalid spike detection parameters','Bad Input','custom',A1.Ie,[],'modal')
                             A2.str_spike='0 spike detected';
                             set(handles.text_tab2_box2_DetectedSpikes,'String',A2.str_spike);
                             set(handles.text_tab2_box2_DetectedSpikes,'ForegroundColor',[0 0 0]);
                             
                           end

                     else
                        msgbox('No loaded file...','ERROR','custom',A1.Ie,[],'modal')
                     end
                else
                  msgbox('You must enter a numeric value for the sampling rate','Bad Input','custom',A1.Ie,[],'modal')
                end
                
              
            

        

%) Box 3 - Plot spectrum
%% ------------------------------------------------------------------------

        % - flag spike -
        function checkbox_tab2_box3_showspikes_Callback(hObject, eventdata, handles)
            global A2;
            A2.SpikeFlag=get(hObject,'Value');
            if(A2.SpikeFlag)
            fprintf('DBSFILT - Plot spikes : ON\n');
            else
            fprintf('DBSFILT - Plot spikes : OFF\n');    
            end

        % - Fmin -
        function edit_tab2_box3_fmin_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A2.Fmin=temp;
                  fprintf('DBSFILT - Plot spectra, fmin : %d Hz\n',A2.Fmin);
                end
      
        function edit_tab2_box3_fmin_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
            

        % -Fmax -
        function edit_tab2_box3_fmax_Callback(hObject, eventdata, handles)
            global A1;
            global A2;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A2.Fmax=temp;
                  fprintf('DBSFILT - Plot spectra, fmax : %d Hz\n',A2.Fmax);
                end

        function edit_tab2_box3_fmax_CreateFcn(hObject, eventdata, handles)
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end

        % - Plot -
        function pushbutton_tab2_box3_plot_Callback(hObject, eventdata, handles)
        global A1;
        global A2;
        
        if(A2.Fmin<A2.Fmax)    
                                   
                if(isnumeric(A2.sr))
                     if(isempty(A2.x)~=1)
                         if(isempty(A2.spikes))
                             DBSFILT_display_rawfftspectra(A2.x,A2.sr,A2.Fmin,A2.Fmax,'Mean spectrum (FFT)')
                         else
                            if(A2.SpikeFlag) 
                                DBSFILT_display_rawfftspectraFAST(A2.spikes,1,A2.Fmin,A2.Fmax,'Mean spectrum + Detected spikes');
                            else
                                DBSFILT_display_rawfftspectraFAST(A2.spikes,0,A2.Fmin,A2.Fmax,'Mean spectrum (FFT)');
                            end
                         end
                     else
                        msgbox('No loaded file...','ERROR','custom',A1.Ie,[],'modal')
                     end
                else
                  msgbox('You must enter a numeric value for the sampling rate','Bad Input','custom',A1.Ie,[],'modal')
                end

        else
                msgbox('fmin and fmax must be numeric values, with fmin<fmax.','Bad Input','custom',A1.Ie,[],'modal')
                
        end

        
        
%) Box 4 - GUI controls
%% ------------------------------------------------------------------------


        function pushbutton_tab2_box4_saveas_Callback(hObject, eventdata, handles)
            global A2;
            global A1;
            if A2.nb_spikes==0
                   msgbox('No spike detected, File not saved.','Warning','custom',A1.Iw,[],'modal')
            else
                    try
                    flag = DBSFILT_savespikesas(A2.spikes);
                    %if(flag==0)
                    catch
                        msgbox('File not saved','Warning','custom',A1.Iw,[],'modal');
                    end
            end   



            
            
        function pushbutton_tab2_box4_reset_Callback(hObject, eventdata, handles)
            strflag = DBSFILT_warndlg('title','Warning','string','This will clear all data in memory for the current tab. Do you want to proceed ?');
            if(strcmp(strflag,'Yes'))
                DBSFILT_InitA2(hObject, eventdata, handles);
            end





%% ////////////////////////////////////////////////////////////////////////
%%  Tab 3 - Spikes removal
%% ////////////////////////////////////////////////////////////////////////


%) Box 1 - Import data
%% ------------------------------------------------------------------------


function pushbutton_tab3_box1_load_Callback(hObject, eventdata, handles)
            global A1;
            global A3;
                [A3.x,A3.filename,A3.sr,A3.EEG, A3.ext,A3.varname,flag] = DBSFILT_loaddata();
                if(flag==0)
                    A3.filename='No file loaded...';
                    A3.sr='?';
                    A3.x=[];
                    A3.EEG=[];
                    A3.ext='';
                    A3.varname='';
                    set(handles.text_tab3_box1_filename,'String',A3.filename);
                    set(handles.edit_tab3_box1_sr,'String',A3.sr);
                    msgbox('File not loaded.','ERROR','custom',A1.Ie,[],'modal')
                else
                    if(strcmp(A3.ext,'.set') || strcmp(A3.ext,'.SET'))
                        set(handles.edit_tab3_box1_sr,'String',num2str(A3.sr));
                    else
                        A3.sr='?';
                        set(handles.edit_tab3_box1_sr,'String',A3.sr);
                    end
                    set(handles.text_tab3_box1_filename,'String',A3.filename); 
                end
                   
function text_tab3_box1_filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
        
        
function edit_tab3_box1_sr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

        function edit_tab3_box1_sr_Callback(hObject, eventdata, handles)
            global A1;
            global A3;
            if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A3.sr=temp;
                  fprintf('DBSFILT - Sampling Rate : %d Hz\n',A3.sr);
                end


    
    
    

%) Box 2 - Import spikes
%% ------------------------------------------------------------------------

function pushbutton_tab3_box2_load_Callback(hObject, eventdata, handles)
    global A1;
    global A3;
    
    flag=1;
    try
        [A3.spikes, A3.filename2] = DBSFILT_loadspikes();
    catch
        msgbox('Invalid .spikes file.','Error','custom',A1.Ie,[],'modal');
        A3.spikes=[];
        A3.spikes=[];
        A3.nb_spikes=0;
        A3.FFTlength=[];
        A3.DATAlength=[];
        A3.str_spike='0 spike detected';
        A3.filename2='No file loaded...';
        set(handles.text_tab3_box2_filename,'String',A3.filename2);
        set(handles.text_tab3_box2_detectedspikes,'String',A3.str_spike);
        set(handles.text_tab3_box2_detectedspikes,'ForegroundColor',[0 0 0]);
        flag=0;
    end
    
    if(flag)
        A3.nb_spikes=sum(A3.spikes(6,:));
        A3.str_spike=sprintf('%d spikes detected',A3.nb_spikes);
        set(handles.text_tab3_box2_detectedspikes,'String',A3.str_spike);
        set(handles.text_tab3_box2_detectedspikes,'ForegroundColor',[0.7 0 0]);
        set(handles.text_tab3_box2_filename,'String',A3.filename2);
       
        
        
    end
    
    
    

%) Box 3a - Spikes removal (.spikes file)
%% ------------------------------------------------------------------------

function pushbutton_tab3_box3_start_spikerejection_Callback(hObject, eventdata, handles)
    global A1;
    global A3;
    
    flag=1;
    if(isempty(A3.x))
        flag=0;
        fprintf('DBSFILT >> Test EEG data : ERROR\n')
        msgbox('Data not found in memory.','Error','custom',A1.Ie,[],'modal');
    else
        fprintf('DBSFILT >> Test loaded data : OK\n')
        
        if(isempty(A3.spikes))
        flag=0;
        fprintf('DBSFILT >> Test Spike locations : ERROR\n')
        msgbox('Spike locations not found in memory.','Error','custom',A1.Ie,[],'modal');
        else
            fprintf('DBSFILT >> Test Spike locations : OK\n')
            
            DATAlength=size(A3.x,2);
            %) parity check 
            if((DATAlength/2)~=round(DATAlength/2))
                FFTlength=DATAlength-1;
            else
                FFTlength=DATAlength;
            end
            
            if((FFTlength/2 +1)~=size(A3.spikes,2))
                flag=0;
                fprintf('DBSFILT >> Test data consistency : ERROR\n')
                msgbox('The loaded .spikes file is not compatible with loaded data length.','Error','custom',A1.Ie,[],'modal');
            else
                fprintf('DBSFILT >> Test data consistency : OK\n')
            end

        end

    end
    
    if(flag)
    strflag = DBSFILT_warndlg('title','Warning','string','This will remove and interpolate selected frequencies. Do you want to proceed ?');
            if(strcmp(strflag,'Yes'))
                A3.x=DBSFILT_SpikesRemoval(A3.spikes, A3.x, A3.sr);
            end
    end
        
    
 

%) Box 3b - Spikes removal (manual)
%% ------------------------------------------------------------------------

% A3.Manual_Fwinwidth=1;
% A3.Manual_nbspikes=1;
% A3.Manual_targetF=130;


function edit_tab3_box3_Fwinwidth_Callback(hObject, eventdata, handles)
    global A1;
    global A3;
    if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
    end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A3.Manual_Fwinwidth=temp;
                  fprintf('DBSFILT - Manual spike rejection. Windows width : %d Hz\n',A3.Manual_Fwinwidth);
                end
    
function edit_tab3_box3_nbspikes_Callback(hObject, eventdata, handles)
    global A1;
    global A3;
    if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A3.Manual_nbspikes=temp;
                  fprintf('DBSFILT - Manual spike rejection. Number of spikes : %d \n',A3.Manual_nbspikes);
                end
    
function edit_tab3_box3_targetF_Callback(hObject, eventdata, handles)
    global A1;
    global A3;
                if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A3.Manual_targetF=temp;
                  fprintf('DBSFILT - Manual spike rejection. Target frequency : %d Hz\n',A3.Manual_targetF);
                end
    
    
    
    

function edit_tab3_box3_targetF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_tab3_box3_Fwinwidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_tab3_box3_nbspikes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pushbutton_tab3_box3_start_manualspikesrejection_Callback(hObject, eventdata, handles)
global A1;
global A3;
                if(isempty(A3.sr)~=1)
                    if(isempty(A3.x)~=1)

                        try
                            [A3.x]=DBSFILT_ManualSpikesRemoval(A3.Manual_targetF,A3.Manual_Fwinwidth,A3.Manual_nbspikes, A3.x, A3.sr);
                        catch
                            msgbox('Invalid parameters','Error','custom',A1.Ie,[],'modal');
                        end
                        
                    else
                         msgbox('Data not found in memory.','Error','custom',A1.Ie,[],'modal');
                    end
                    
                else
                     msgbox('You must enter a numeric value for the sampling rate','Error','custom',A1.Ie,[],'modal');
                end
    

    
    

%) Box 4 - Plot spectrum
%% ------------------------------------------------------------------------

function edit_tab3_box4_fmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_tab3_box4_fmax_Callback(hObject, eventdata, handles)
     global A1;
     global A3;
               if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A3.Fmax=temp;
                  fprintf('DBSFILT - Plot spectra, fmax : %d Hz\n',A3.Fmax);
                end

function edit_tab3_box4_fmin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_tab3_box4_fmin_Callback(hObject, eventdata, handles)
    global A1;
    global A3;
              if(isempty(get(hObject,'string')))
                      msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                      uicontrol(hObject)
                      return
                end
                temp = str2double(get(hObject,'string'));
                if isnan(temp)
                  msgbox('You must enter a numeric value','Bad Input','custom',A1.Ie,[],'modal')
                  uicontrol(hObject)
                    return
                else
                  A3.Fmin=temp;
                  fprintf('DBSFILT - Plot spectra, fmin : %d Hz\n',A3.Fmin);
                end

function pushbutton_tab3_box4_plot_Callback(hObject, eventdata, handles)
        global A1;
        global A3;
        
        if(A3.Fmin<A3.Fmax)    
                                   
                if(isnumeric(A3.sr))
                     if(isempty(A3.x)~=1)
                         DBSFILT_display_rawfftspectra(A3.x,A3.sr,A3.Fmin,A3.Fmax,'Mean spectrum (FFT)')
                     else
                        msgbox('No loaded file...','ERROR','custom',A1.Ie,[],'modal')
                     end
                else
                  msgbox('You must enter a numeric value for the sampling rate','Bad Input','custom',A1.Ie,[],'modal')
                end

        else
                msgbox('fmin and fmax must be numeric values, with fmin<fmax.','Bad Input','custom',A1.Ie,[],'modal')
                
        end


    
%) Box 5 - GUI controls
%% ------------------------------------------------------------------------


function pushbutton_tab3_box5_reset_Callback(hObject, eventdata, handles)
strflag = DBSFILT_warndlg('title','Warning','string','This will clear all data in memory for the current tab. Do you want to proceed ?');
if(strcmp(strflag,'Yes'))
    DBSFILT_InitA3(hObject, eventdata, handles);
end


function pushbutton_tab3_box5_saveas_Callback(hObject, eventdata, handles)
                global A1;
                global A3;
                if(isempty(A3.x)==1)
                   msgbox('Data matrix is empty...','ERROR','custom',A1.Ie,[],'modal')
                else
                    try
                    flag = DBSFILT_savedataas(A3.x,A3.EEG,A3.ext,A3.varname,A3.filename,'_DBSfiltered');
                    %if(flag==0)
                    catch
                        msgbox('File not saved','Warning','custom',A1.Iw,[],'modal');
                    end
                end




    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TAB 4





%%

% function edit17_Callback(hObject, eventdata, handles)
% % hObject    handle to edit17 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of edit17 as text
% %        str2double(get(hObject,'String')) returns contents of edit17 as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit17_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit17 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% 
% function edit18_Callback(hObject, eventdata, handles)
% % hObject    handle to edit18 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of edit18 as text
% %        str2double(get(hObject,'String')) returns contents of edit18 as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit18_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit18 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% % --- Executes on button press in pushbutton7.
% function pushbutton7_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton7 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% 
% function edit20_Callback(hObject, eventdata, handles)
% % hObject    handle to edit20 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of edit20 as text
% %        str2double(get(hObject,'String')) returns contents of edit20 as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit20_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit20 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
