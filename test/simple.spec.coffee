
# see https://www.chaijs.com/api/bdd/
{ expect } = require 'chai'

loader = require '../src/loader'

simpleTest = (title, { input, expected }) -> it title, ->
	expect loader input
	.to.equal expected
	return

# expected errors tests

it 'Should throw when providing a non-string html argument', ->
	expect -> loader null
	.to.throw()
	return

# basic tests

simpleTest 'Text interpolation should work',
	input: """<h1>An {{ $t 'errTyp' }} error occurred</h1> in {{title a: 1, b: "B", c: 'C'}}"""
	expected: """<h1>An {{ $t('errTyp') }} error occurred</h1> in {{ title({ a: 1, b: "B", c: 'C' }) }}"""

simpleTest 'Text interpolation should work with coffeescript text interpolation',
	input: '<h1>An {{ "something-#{val}-else" }} info</h1>'
	expected: """<h1>An {{ "something-".concat(val, "-else") }} info</h1>"""

simpleTest 'Attribute interpolation should work',
	input: """<h1 v-if="fn 1, 2, c: 3" title="hans" @click="clicked 'peter'" :raw="maybe and a or b">Page not found (404)</h1>"""
	expected: """<h1 v-if="fn(1, 2, { c: 3 })" title="hans" @click="clicked('peter')" :raw="maybe && a || b">Page not found (404)</h1>"""

simpleTest 'Attribute interpolation should work with v-for',
	input: """
		<ul>
			<li v-for="item in items.count 2">{{item.title}}</li>
			<li v-for="(x, y) in items.count 2">{{item.title}}</li>
		</ul>
	"""
	expected: """
		<ul>
			<li v-for="item in items.count(2)">{{ item.title }}</li>
			<li v-for="(x, y) in items.count(2)">{{ item.title }}</li>
		</ul>
	"""

simpleTest 'Unwrap object literals',
	input: """<div :x="a: 1, b: 2"></div>"""
	expected: """<div :x="{ a: 1, b: 2 }"></div>"""

# coverage completeness tests

simpleTest 'Skip empty html',
	input: ""
	expected: ""

simpleTest 'Skip empty attributes',
	input: """<div :x=""></div>"""
	expected: """<div :x=""></div>"""

simpleTest 'Skip unrecognized v-for format',
	input: """<div v-for="a b c"></div>"""
	expected: """<div v-for="a b c"></div>"""
