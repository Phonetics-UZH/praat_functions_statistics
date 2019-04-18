### START SCRIPT ###
#
# function_SDT.praat 
#
# Praat Script for Praat software (www.praat.org)
# Written by Volker Dellwo (volker.dellwo@uzh.ch)
#
# DESCRIPTION:
# This script calculates Signal Detection Theory (SDT) 
# statistics (%C, d', beta, A', B"D) for a Table object in Praat. 
# 
# INPUT: a Praat Table object (select object)
# OUTPUT: a Praat Table object containing SDT
# 
# METHOD: 
# Make sure your Table contains a variable that contains 'signal' 
# and 'noise' (presentation variable) and a second binary variable 
# containing the responses to the signal and noise presentations (response
# variable). When you run the script you have to name your signal and 
# response variables (column name of the respective variables) and you 
# need to specify how the signal is referred to in you presentation variable 
# and how the signal response is referred to in your response variable. From
# this information the script will calculate the following variables: 
#
# tp = true positive (also: hit; signal presented and signal responded)
# fp = false positive (also: false alarm; noise presented and signal responded)
# tn = true negative (also: correct rejection; noise presented and noise responded)
# fn = false negative (also: miss; signal presented and noise responded)
#
#			  R			P = stimulus presented, 
#			 S	N		S = signal 
#		-----------		N = noise
#	P	S	tp	fn
#		N	fp	tn
#
# HISTORY:  
# 12.17.2016 (01): created
#
# LICENSE: 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation (see <http://www.gnu.org/licenses/>). This 
# program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY.
#

form Report SDT...
	comment Define your signal:
	word presentation_variable speaker
	word signal T
	comment Define your response:
	word response_variable response
	word signal_response 1
	boolean Print_detailed_report
endform

table = selected("Table")
nRows = Get number of rows

# get tp and fp rates:

	tp=0
	fp=0
	tn=0
	fn=0

	for iRow to nRows

		signal_presented$ = Get value: iRow, presentation_variable$
		response$ = Get value: iRow, response_variable$

		if signal_presented$ = signal$
			signal=1
		else 
			signal=0
		endif

		if response$ = signal_response$
			response=1
		else
			response=0
		endif

		if signal=1 and response=1
			tp+=1
		elsif signal=0 and response=1
			fp+=1
		elsif signal=1 and response=0
			fn+=1
		elsif signal=0 and response=0
			tn+=1
		endif

	endfor

	tp_rate = tp/(tp+fn)
	fp_rate = fp/(fp+tn)

# compute percent correct:

	percentCorrect = (tp+tn)/(tp+fn+fp+tn)

# compute d' and beta:

	# Scale tp rate of 1 and fp rate of 0:
	if tp_rate = 0
		tp_rate = 0.000000001
	elsif tp_rate = 1
		tp_rate = 0.999999999
	endif

	if fp_rate = 0
		fp_rate = 0.000000001
	elsif fp_rate = 1
		fp_rate = 0.999999999
	endif

	ztp = -1*invGaussQ(tp_rate)
	zfp = -1*invGaussQ(fp_rate)

	# compute d':
	dPrime = ztp-zfp

	# compute beta: 
	beta = exp(-ztp*ztp/2+zfp*zfp/2)

# compute A' and B''D:

	if tp_rate>fp_rate
		aPrime = 1/2+((tp_rate-fp_rate)*(1+tp_rate-fp_rate))/(4*tp_rate*(1-fp_rate))
	elsif fp_rate>tp_rate
		aPrime = 1/2-((fp_rate-tp_rate)*(1+fp_rate-tp_rate))/(4*fp_rate*(1-tp_rate))
	else
		aPrime = 1/2
	endif

	bPrimeD = ((1-tp_rate)*(1-fp_rate)-tp_rate*fp_rate)/((1-tp_rate)*(1-fp_rate)+tp_rate*fp_rate)

# Write results to Table: 

	Create Table with column names: "SDT", 1, "percentC dPrime beta aPrime bPrimeD"
	Set string value: 1, "percentC", fixed$(percentCorrect, 3)
	Set string value: 1, "dPrime", fixed$(dPrime, 3)
	Set string value: 1, "beta", fixed$(beta, 3)
	Set string value: 1, "aPrime", fixed$(aPrime, 3)
	Set string value: 1, "bPrimeD", fixed$(bPrimeD, 3)

# Print details to Info window: 

	if print_detailed_report
		writeInfoLine: "SDT report"
		appendInfoLine: ""
		appendInfoLine: "tp", tab$, "fp", tab$, "tn", tab$, "fn"
		appendInfoLine: tp, tab$, fp, tab$, tn, tab$, fn
		appendInfoLine: ""
		appendInfoLine: "tp rate: ", fixed$(tp_rate,3), "; z: ", fixed$(ztp,3)
		appendInfoLine: "fp rate: ", fixed$(fp_rate,3), "; z: ", fixed$(zfp,3)
	endif

### END SCRIPT ###