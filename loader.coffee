
cheerio = require 'cheerio'
coffee = require 'coffeescript'

reAttrTest = /^(v-|@|:)/
reTextInterpolationMatch = /{{.*?}}/g
reForMatch = /(.*?)\sin\s(.*)/

# replace entities encoded by cheerio
replaceEntities = (str) ->
	return str
	.replace /&apos;/g, "'"
	.replace /&quot;/g, '"'
	.replace /&amp;/g, '&'

compile = (js) ->
	js = replaceEntities js
	
	# compile, then remove newlines and semicolon at the end
	cof = coffee
		.compile js, bare: yes
		.replace /\n\s*/g, ' '
		.replace /;\s*$/, ''
		.replace /^"use strict"; /, ''

	# unwrap object literals
	if cof.startsWith('({') and cof.endsWith('})')
		cof = cof.substring 1, cof.length-1
	return cof

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
						[_, what, js] = matches
						cof = compile js
						node.attribs[key] = "#{what} in #{cof}"
					else if reAttrTest.test key
						cof = compile val
						node.attribs[key] = cof
			when 'text'
				# transpile interpolations
				text = node.data
				matches = text.match reTextInterpolationMatch
				continue unless matches
				for interpolation in matches
					js = interpolation.substring 2, interpolation.length-2
					cof = compile js
					text = text.replace interpolation, "{{ #{cof} }}"
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
