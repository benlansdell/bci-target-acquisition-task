%Charlie's scripts uses these global variables...
%global metaData matpath nevpath
%matpath = '/home/lansdell/projects/bci/matlab/labview';
%nevpath = '/home/lansdell/projects/bci/matlab/blackrock';
%metaData = '/home/lansdell/projects/bci/matlab/labview';

if ismac
	homedir = '/Users/';
else
	homedir = '/home/';
end

%opengl software

addpath([homedir 'lansdell/projects/bci/functions']);
addpath_recurse([homedir 'lansdell/projects/bci/functions']);
addpath_recurse([homedir 'lansdell/projects/bci/preprocess']);
addpath_recurse([homedir 'lansdell/projects/bci/models']);
addpath_recurse([homedir 'lansdell/projects/bci/fitting']);
addpath_recurse([homedir 'lansdell/projects/bci/eval']);
addpath_recurse([homedir 'lansdell/projects/bci/worksheets']);
addpath_recurse([homedir 'lansdell/projects/bci/sql']);
%nev files, labview files, respectively
addpath([homedir '/lansdell/projects/bci/blackrock'], [homedir '/lansdell/projects/bci/labview']);
addpath_recurse([homedir 'lansdell/matlab/schmidt']);
addpath_recurse([homedir 'lansdell/projects/bci/gpfa']);

addpath([homedir '/lansdell/matlab/mvgc_v1.0']);
addpath([homedir '/lansdell/matlab/te_matlab_0.5/']);
mvgcstartup

javaaddpath([homedir 'lansdell/matlab/mysql-connector-java-5.1.35-bin.jar']);
%javaaddpath([matlabroot '/java/jar/mysql-connector-java-5.1.35-bin.jar']);
%javaaddpath([matlabroot '/java/jar/mysql-connector-java-5.1.35-bin.jar']);

%Add extra color
%my_ColorOrder = [   0.00000   0.00000   1.00000;
%   0.00000   0.50000   0.00000;
%   1.00000   0.00000   0.00000;
%   0.00000   0.75000   0.75000;
%   0.75000   0.00000   0.75000;
%   0.75000   0.75000   0.00000;
%   0.25000   0.25000   0.25000;
%   0.00000   0.90000   0.00000;
%   1.00000   0.50000   0.00000;
%   0.95000   0.95000   0.00000;
%   0.60000   0.60000   0.60000;
%   0.00000   0.00000   0.00000;
%   1.00000   0.00000   1.00000];
%set(0,'DefaultAxesColorOrder',my_ColorOrder);

% Change default axes fonts.
%set(0,'DefaultAxesFontName', 'Arial')
%set(0,'DefaultAxesFontSize', 10)

% Change default text fonts.
%set(0,'DefaultTextFontname', 'Arial')
%set(0,'DefaultTextFontSize', 10)

% Change default line width
%set(0,'DefaultLineLineWidth',1.5)

%%%%%%%%%%%%%%%%%%%%%%%%
%GPFA startup....
%%%%%%%%%%%%%%%%%%

path(path,'gpfa/util/invToeplitz');
% Create the mex file if necessary.
if ~exist(sprintf('gpfa/util/invToeplitz/invToeplitzFastZohar.%s',mexext),'file')
  try
    eval(sprintf('mex -outdir util/invToeplitz util/invToeplitz/invToeplitzFastZohar.c'));
    fprintf('NOTE: the relevant invToeplitz mex files were not found.  They have been created.\n');
  catch
    fprintf('NOTE: the relevant invToeplitz mex files were not found, and your machine failed to create them.\n');
    fprintf('      This usually means that you do not have the proper C/MEX compiler setup.\n');
    fprintf('      The code will still run identically, albeit slower (perhaps considerably).\n');
    fprintf('      Please read the README file, section Notes on the Use of C/MEX.\n');
  end
end

% Posterior Covariance Precomputation  
path(path,'gpfa/util/precomp');
% Create the mex file if necessary.
if ~exist(sprintf('gpfa/util/precomp/makePautoSumFast.%s',mexext),'file')
  try
    eval(sprintf('mex -outdir util/precomp util/precomp/makePautoSumFast.c'));
    fprintf('NOTE: the relevant precomp mex files were not found.  They have been created.\n');
  catch
    fprintf('NOTE: the relevant precomp mex files were not found, and your machine failed to create them.\n');
    fprintf('      This usually means that you do not have the proper C/MEX compiler setup.\n');
    fprintf('      The code will still run identically, albeit slower (perhaps considerably).\n');
    fprintf('      Please read the README file, section Notes on the Use of C/MEX.\n');
  end
end
