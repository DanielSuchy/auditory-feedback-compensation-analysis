%try different mass univariate methods using the mass univariate toolbox
clear;

files = dir('/Users/diskuser/analysis/all_data/eeg/**/*_bins.set');
allpaths = [];
for i=3:31%length(files)
    path = {[files(i).folder '/' files(i).name]};
    allpaths = [allpaths; path];
end

GND=sets2GND(allpaths,'bsln',[-400 0]);

gui_erp(GND)
plot_wave(GND,[1 2]);
GND=bin_dif(GND,1,2,'aware-unaware difference');
gui_erp(GND,'bin',3);
GND=clustGND(GND,3,'time_wind',[200 500],'chan_hood',.61,'thresh_p',.05);
GND=tmaxGND(GND,3,'time_wind',[200 280],'output_file','temp.txt');

pop_resample