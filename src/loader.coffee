
cheerio = require 'cheerio'
coffee = require 'coffeescript'

# which attributes we want to transpile
reAttrTest = /^(v-|@|:)/
# match v-for expressions
reForMatch = /(.*?)\sin\s(.*)/
# match interpolations
reTextInterpolationMatch = /{{.*?}}/g

# replace entities encoded by cheerio
replaceEntities = (str) ->
	return str
	.replace /&apos;/g, "'"
	.replace /&quot;/g, '"'
	.replace /&amp;/g, '&'

compile = (cof) ->
	cof = replaceEntities cof
	
	# compile, then remove newlines and semicolon at the end
	js = coffee
		.compile cof, bare: yes
		.replace /\n\s*/g, ' '
		.replace /;\s*$/, ''
		.replace /^"use strict"; /, ''

	# unwrap object literals
	if js.startsWith('({') and js.endsWith('})')
		js = js.substring 1, js.length-1
	return js

walkNodes = (nodes) ->
	for node in nodes
		walkNodes node.children if node.children?.length > 0
		switch node.type
			when 'tag'
				# transpile attributes
				for key, val of node.attribs
					continue unless val
					if key is 'v-for'
						matches = val.match reForMatch
						continue unless matches?[1]
						[_, alias, cof] = matches
						js = compile cof
						node.attribs[key] = "#{alias} in #{js}"
					else if reAttrTest.test key
						js = compile val
						node.attribs[key] = js
			when 'text'
				# transpile interpolations
				text = node.data
				matches = text.match reTextInterpolationMatch
				continue unless matches
				for interpolation in matches
					cof = interpolation.substring 2, interpolation.length-2
					js = compile cof
					text = text.replace interpolation, "{{ #{js} }}"
				node.data = text
	return

module.exports = (html) ->
	throw new Error 'html has to be a string' unless typeof html is 'string'

	# add an extra wrapper div,
	# because the outer node somehow gets lost in `.html()`
	$ = cheerio "<div>#{html}</div>"

	walkNodes $.find '> template'

	result = replaceEntities $.html()

	return result
