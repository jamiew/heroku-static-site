check_single_acronym = (text_array, acronym_list) ->
	matches = []
	for acronym1 in acronym_list
		for acronym2 in acronym_list
			if acronym1 in text_array and acronym2 in text_array and acronym1 isnt acronym2 and acronym1 not in matches
				matches.push acronym1
				if matches.length == acronym_list.length
					break
	return matches
			

###
This function checks the EPR/OPR content for duplicate acronyms
by duplicates we mean using both CDR and CMDR in the same text
since these mean the same thing, you should be consistent
###
duplicate_acronym_check = (text_content) ->
	# get the actual text in the duplicate acronyms text box
	duplicate_acronym_list_raw = $('#duplicate_acronyms').val()

	# lowercase it, we don't care about case for dupes
	# duplicate_acronym_list_raw = duplicate_acronym_list_raw.toLowerCase()

	#get rid of spaces
	duplicate_acronym_list_raw = duplicate_acronym_list_raw.replace /[ ]/g,""
	
	# make our text an array split on newlines
	duplicate_acronym_list = duplicate_acronym_list_raw.split("\n")
	
	# split each line on commas (only supports csv right now)
	for acronym_list in duplicate_acronym_list
		duplicate_acronym_list[duplicate_acronym_list.indexOf(acronym_list)] = acronym_list.split(",")

	clean_text = text_content.replace /[.,\/()\;:{}!?-]/g," "
	# clean_text = clean_text.toLowerCase()
	clean_text = clean_text.replace /\s+/g," "

	text_array = clean_text.split(" ")

	duplicate_acronyms = []
	
	for acronym_list in duplicate_acronym_list
		new_elem = check_single_acronym(text_array, acronym_list)
		if new_elem
			duplicate_acronyms.push new_elem
	
	return duplicate_acronyms



###
highlights all items in the array passed to it

TODO: tie together elements from the same array
###
highlight_dupes = (duplicate_acronyms, text_content) ->
	for acronym_list in duplicate_acronyms
		for acronym in acronym_list
			text_content = text_content.replace ///(?<=[^a-zA-Z]|^)#{acronym}(?=([^a-zA-Z]|$))///gi,'<span class="dupe">'+acronym+'</span>'
	return text_content

highlight_typos = (typos,text_content) ->
	for typo in typos
		text_content = text_content.replace ///(?<=[^a-zA-Z]|^)#{typo}(?=([^a-zA-Z]|$))///gi,'<span class="typo">'+typo+'</span>'
	return text_content

spell_check = (text_content,dict_array) ->
	clean_text = text_content.replace /[.,\/()\;:{}!?-]/g," "
	# clean_text = clean_text.toLowerCase()
	clean_text = clean_text.replace /\s+/g," "

	text_array = clean_text.split(" ")

	typos = []

	for word in text_array
		if word.toLowerCase() not in dict_array and word not in typos
			typos.push(word)

	return typos

acronym_and_word_check = (text_content,word_acro_array) ->
	text_array = text_content.split(" ")
	# console.log clean_text
	acronym_words = []

	lower_case_tokens = []

	`text_array.forEach(function(ele){
	lower_case_tokens.push(ele.toLowerCase());
	})`
	
	for word in text_array
		word = word.toLowerCase();

		#If the word is an ancronym
		if word_acro_array[word] 
			#See if any of the spelled out versions exists in the input
			for alt_word in word_acro_array[word]
				if alt_word in lower_case_tokens and [word, word_acro_array[word]] not in acronym_words
					acronym_words.push([word,alt_word])

	return acronym_words

highlight_word_acro_pairs = (text_content,acronym_words) ->
	for pair in acronym_words
		word1 = pair[0]
		word2 = pair[1]
		id1 = word1+word2
		id2 = word2+word1
		if navigator.userAgent.indexOf('Chrome') is not -1
			text_content = text_content.replace ///(?<=[\ ]|^)#{word1}(?=([\ ]|$))///gi,'<span id="'+id1+'" class="acro_pair">$&</span>'
			text_content = text_content.replace ///(?<=[\ ]|^)#{word2}(?=([\ ]|$))///gi,'<span id="'+id2+'" class="acro_pair">$&</span>'
		else
			text_content = text_content.replace ///[\ ]#{word1}(?=([\ \<]|$))///gi,'<span id="'+id1+'" class="acro_pair">$&</span>'
			text_content = text_content.replace ///[\ ]#{word2}(?=([\ \<]|$))///gi,'<span id="'+id2+'" class="acro_pair">$&</span>'
			
			text_content = text_content.replace ///^#{word1}(?=([\ \<]|$))///gi,'<span id="'+id1+'" class="acro_pair">$&</span>'
			text_content = text_content.replace ///^#{word2}(?=([\ \<]|$))///gi,'<span id="'+id2+'" class="acro_pair">$&</span>'

	return text_content

add_tooltip_custom = (selector, msg) ->
	tippy(selector, {content:msg,flip:false})
	return

add_tooltips = (acronym_words) ->
	for pair in acronym_words
		add_tooltip_custom('#'+pair[0]+pair[1],pair[1])
		add_tooltip_custom('#'+pair[1]+pair[0],pair[0])
	return

highlight_valid_acros = (text_content, word_acro_array) ->
	acronym_array = Object.keys word_acro_array
	text_array = text_content.split(" ")
	for word in text_array

		if word.toLowerCase() in acronym_array
			console.log "ST8"
			text_content = text_content.replace ///^#{word}|[\ ]#{word}(?=([\ ]|$))///gi,'<span id="'+word+'" class="acro_green">$&</span>'
			
	return text_content

queep= ->

	text_content = $('#output').html()
	
	# console.log("EPR/OPR text content:" + text_content)
	# approved_acronym_check(text_content)
	# duplicate_acronyms = duplicate_acronym_check(text_content)
	# text_content = highlight_dupes(duplicate_acronyms, text_content)

	acronym_words = acronym_and_word_check(text_content,word_acro_data)
	text_content = highlight_word_acro_pairs(text_content,acronym_words)
	text_content = highlight_valid_acros(text_content, word_acro_data)
	# typos = spell_check(text_content,dict_array)
	# text_content = highlight_typos(typos,text_content)
	# $('#text_content').focus()
	return {'html':text_content,'acronym_words':acronym_words}

$ ->
	$("#input").on "input propertychange paste", ->
		#Adds the text you type in, to the output. 
		$('#output').text $('#input').val()
		result = queep()
		$('#output').html result['html']
		add_tooltips(result['acronym_words'])
		add_tooltip_custom(".acro_green", "Approved abbreviation")
		return