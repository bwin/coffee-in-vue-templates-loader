
coffee = require 'coffeescript'
cheerio = require 'cheerio'

# which attributes we want to transpile
reAttrTest = /^(v-|@|:)/

# match v-for expressions
reForMatch = /(.*?)\sin\s(.*)/

# match interpolations
reTextInterpolationMatch = /{{.*?}}/g

module.exports = coffeeInVueTemplatesLoader = (html) ->
	throw new Error 'html has to be a string' unless typeof html is 'string'

	# add an extra wrapper div,
	# because the outermost node somehow gets lost in `.html()`
	$ = cheerio "<div>#{html}</div>"

	# transpile code
	walkNodes $, (node) ->
		switch node.type
			when 'tag' then compileAttributes node
			when 'text' then compileInterpolations node
		return

	# replace entities encoded by cheerio
	result = replaceEntities $.html()

	return result

walkNodes = (nodes, cb) ->
	for node in nodes
		cb node
		walkNodes node.children, cb if node.children?.length > 0
	return

compileAttributes = (node) ->
	for key, val of node.attribs when val
		if key is 'v-for'
			matches = val.match reForMatch
			if matches
				[_, alias, cof] = matches
				js = compile cof
				node.attribs[key] = "#{alias} in #{js}"
		else if reAttrTest.test key
			js = compile val
			node.attribs[key] = js
	return

compileInterpolations = (node) ->
	text = node.data
	matches = text.match reTextInterpolationMatch
	if matches
		for interpolation in matches
			cof = interpolation.substring 2, interpolation.length-2
			js = compile cof
			text = text.replace interpolation, "{{ #{js} }}"
		node.data = text
	return

compile = (cof) ->
	cof = replaceEntities cof
	
	# assign expression to var to get ternary op working
	tmpVarName = '__x__'
	cof = "#{tmpVarName} = #{cof}"
	
	# compile, then remove newlines, semicolon at the end and "use strict"
	js = coffee
		.compile cof, bare: yes
		.replace /\n\s*/g, ' '
		.replace /;\s*$/, ''
		.replace /^"use strict"; /, ''

	# remove assignment to var again
	js = js.substring "var #{tmpVarName}; #{tmpVarName} = ".length

	# unwrap object literals
	js = js.substring 1, js.length-1 if js.startsWith('({') and js.endsWith('})')

	return js

replaceEntities = (str) ->
	return str
		.replace /&apos;/g, "'"
		.replace /&quot;/g, '"'
		.replace /&amp;/g, '&'
