approved_acronym_check = (text_content) ->

	if text_content in Object.keys(acronyms_dict)
		console.log "yeah"
	else
		console.log "nope"

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
	clean_text = text_content.replace /[.,\/()\;:{}!?-]/g," "
	clean_text = clean_text.replace /\s+/g," "

	text_array = clean_text.split(" ")
	acronym_words = []
	console.log "TEXTARRAY"
	console.log text_array

	lower_case_tokens = []

	`text_array.forEach(function(ele){
	lower_case_tokens.push(ele.toLowerCase());
	})`

	for word in text_array
		word = word.toLowerCase();
		#for every item in all lowercase text array, check to see if there is a match in the mapping. 
		#if there is a match, replace the original text array word in the end. 
		if word_acro_array[word] and word_acro_array[word] in lower_case_tokens and [word, word_acro_array[word]] not in acronym_words
			console.log "WORD"
			console.log [word,word_acro_array[word]]
			acronym_words.push([word,word_acro_array[word]])

	return acronym_words

highlight_word_acro_pairs = (text_content,acronym_words) ->
	console.log text_content
	for pair in acronym_words
		word1 = pair[0]
		word2 = pair[1]
		id1 = word1+word2
		id2 = word2+word1
		text_content = text_content.replace ///(?<=[^a-zA-Z]|^)#{word1}(?=([^a-zA-Z]|$))///gi,'<span id="'+id1+'" class="acro_pair">$&</span>'
		text_content = text_content.replace ///(?<=[^a-zA-Z]|^)#{word2}(?=([^a-zA-Z]|$))///gi,'<span id="'+id2+'" class="acro_pair">$&</span>'
		
	console.log text_content
	return text_content

add_tooltips = (acronym_words) ->
	for pair in acronym_words
		tippy('#'+pair[0]+pair[1],{content:pair[1],flip:false})
		tippy('#'+pair[1]+pair[0],{content:pair[0],flip:false})

queep= ->

	text_content = $('#input').val()
	
	console.log tippy('#main_title',{content:"hello"})
	# console.log("EPR/OPR text content:" + text_content)
	# approved_acronym_check(text_content)
	# duplicate_acronyms = duplicate_acronym_check(text_content)
	# text_content = highlight_dupes(duplicate_acronyms, text_content)

	acronym_words = acronym_and_word_check(text_content,word_acro_data)
	text_content = highlight_word_acro_pairs(text_content,acronym_words)

	# typos = spell_check(text_content,dict_array)
	# text_content = highlight_typos(typos,text_content)
	# $('#text_content').focus()
	return {'html':text_content,'acronym_words':acronym_words}

$ ->
	$("#input").on "input propertychange paste", ->
		#Adds the text you type in, to the output. 
		result = queep()
		$('#output').html result['html']
		add_tooltips(result['acronym_words'])



		return
	
