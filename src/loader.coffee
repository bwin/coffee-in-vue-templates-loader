
coffee = require 'coffeescript'
{ JSDOM } = require 'jsdom'

# which attributes we want to transpile
reAttrTest = /^(v-|@|:)/

# match v-for expressions
reForMatch = /(.*?)\sin\s(.*)/

# match interpolations
reTextInterpolationMatch = /{{.*?}}/g

module.exports = coffeeInVueTemplatesLoader = (html) ->
	throw new Error 'html has to be a string' unless typeof html is 'string'

	# rename the <template> tag, so it's not treated as a html5 template
	html = html.replace /template>/g, 'template__vue>'

	# transpile code inside <template> tag
	dom = new JSDOM "<html><body>#{html}</body></html>"
	{ body } = dom.window.document
	
	templateNode = body.querySelector 'template__vue'

	return '' unless templateNode
	walkNodes templateNode.childNodes, (node) ->
		switch node.nodeType
			# nodeType 1 = tag
			when 1 then compileAttributes node
			# nodeType 3 = text
			when 3 then compileInterpolations node
		return

	result = body.innerHTML
	# rename back to template, after we're done
	result = result.replace /template__vue>/g, 'template>'
	# replace entities encoded by jsdom
	result = replaceEntities result

	return result

walkNodes = (nodes, cb) ->
	for node in nodes
		cb node
		walkNodes node.childNodes, cb if node.hasChildNodes()
	return

compileAttributes = (node) ->
	for i in [0...node.attributes.length]
		attr = node.attributes[i]
		key = attr.nodeName
		val = attr.value
		if key is 'v-for'
			matches = val.match reForMatch
			if matches
				[_, alias, cof] = matches
				js = compile cof
				attr.value = "#{alias} in #{js}"
		else if reAttrTest.test key
			js = compile val
			attr.value = js
	return

compileInterpolations = (node) ->
	text = node.textContent
	matches = text.match reTextInterpolationMatch
	if matches
		for interpolation in matches
			cof = interpolation.substring 2, interpolation.length-2
			js = compile cof
			text = text.replace interpolation, "{{ #{js} }}"
		node.textContent = text
	return

compile = (cof) ->
	cof = replaceEntities cof
	
	# compile, then remove newlines, semicolon at the end and "use strict"
	js = coffee
		.compile cof, bare: yes
		.replace /\n\s*/g, ' '
		.replace /;\s*$/, ''
		.replace /^"use strict"(; )?/, ''

	# unwrap object literals
	js = js.substring 1, js.length-1 if js.startsWith('({') and js.endsWith('})')

	return js

replaceEntities = (str) ->
	return str
		.replace /&apos;/g, "'"
		.replace /&quot;/g, '"'
		.replace /&amp;/g, '&'
