# extract features from nationwide corpus data
# assumes you have created:
#	short audio files with speech of interest
# created jmculnan 5/1/21
# last update 6/7/21
# speech rate measures done separately

form Enter path to files and save path 
	comment the path to the wav files you choose to extract info from
	text Enter_path_to_file Downloads/nationwide speech project/short_clips/
	comment the name and path to the file where you save extract feature info
	text Save_name_and_path Downloads/nationwide speech project/extracted_feats.txt
endform

# delete the file in Save_name_and_path if it exists
filedelete 'Save_name_and_path$'

# from https://www.fon.hum.uva.nl/praat/manual/Create_Strings_as_file_list___.html
strings = Create Strings as file list: "list", enter_path_to_file$ + "/*.wav"
numberOfFiles = Get number of strings

# write a header for the save file
file_header$ = "file_name'tab$'jitter'tab$'shimmer'tab$'hnr'tab$'mean_f0'tab$'median_f0'tab$'range_f0'tab$'max_f0'tab$'min_f0'tab$'mean_intensity'tab$'median_intensity'tab$'range_intensity'newline$'"
fileappend "'Save_name_and_path$'" 'file_header$'

for ifile to numberOfFiles
	selectObject: strings
	fileName$ = Get string: ifile
	Read from file: enter_path_to_file$ + fileName$
	name$ = selected$ ("Sound")

	## get intensity measures
	To Intensity... 50 0.0 yes

	## select the intensity object and get values
	select Intensity 'name$'
	int_min = Get minimum... 0.0 0.0 Parabolic
	int_max = Get maximum... 0.0 0.0 Parabolic
	int_range = int_max - int_min
	int_mean = Get mean... 0.0 0.0 dB
	int_median = Get quantile... 0.0 0.0 0.50

	select Sound 'name$'
	To PointProcess (periodic, cc)... 50 450
	select Sound 'name$'
	To Pitch... 0.0 50 450
	select Sound 'name$'
	plus Pitch 'name$'
	plus PointProcess 'name$'

	# enter values for voice report
	# Voice report... start_time end_time min_pitch max_pitch max_period_factor max_amplitude_factor 
	vr$ = Voice report... 0.0 0.0 50 450 1.3 1.6 0.03 0.45

	# get jitter and shimmer
	jitter = extractNumber (vr$, "Jitter (local): ")
	shimmer = extractNumber (vr$, "Shimmer (local): ")
	
	# get hnr
	hnr = extractNumber (vr$, "Mean harmonics-to-noise ratio: ")
	
	# get f0 values
	f0_mean = extractNumber (vr$, "Mean pitch: ")
	f0_median = extractNumber (vr$, "Median pitch: ")
	f0_max = extractNumber (vr$, "Maximum pitch: ")
	f0_min = extractNumber (vr$, "Minimum pitch: ")
	f0_range = f0_max - f0_min
	
	# add these values to the file of features
	results$ = "'name$''tab$''jitter''tab$''shimmer''tab$''hnr''tab$''f0_mean''tab$''f0_median''tab$''f0_range''tab$''f0_max''tab$''f0_min''tab$''int_mean''tab$''int_median''tab$''int_range''newline$'"
	echo 'results$'
	fileappend "'Save_name_and_path$'" 'results$'
	
endfor


