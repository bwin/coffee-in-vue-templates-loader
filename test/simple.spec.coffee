
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
	input: """<template><h1>An {{ $t 'errTyp' }} error occurred</h1> in {{title a: 1, b: "B", c: 'C'}}</template>"""
	expected: """<template><h1>An {{ $t('errTyp') }} error occurred</h1> in {{ title({ a: 1, b: "B", c: 'C' }) }}</template>"""

simpleTest 'Text interpolation should work with coffeescript text interpolation',
	input: '<template><h1>An {{ "something-#{val}-else" }} info</h1></template>'
	expected: """<template><h1>An {{ "something-".concat(val, "-else") }} info</h1></template>"""

simpleTest 'Attribute interpolation should work',
	input: """<template><h1 v-if="fn 1, 2, c: 3" title="hans" @click="clicked 'peter'" :raw="maybe and a or b">Page not found (404)</h1></template>"""
	expected: """<template><h1 v-if="fn(1, 2, { c: 3 })" title="hans" @click="clicked('peter')" :raw="maybe && a || b">Page not found (404)</h1></template>"""

simpleTest 'Attribute interpolation should work with v-for',
	input: """
		<template>
			<ul>
				<li v-for="item in items.count 2">{{item.title}}</li>
				<li v-for="(x, y) in items.count 2">{{item.title}}</li>
			</ul>
		</template>
	"""
	expected: """
		<template>
			<ul>
				<li v-for="item in items.count(2)">{{ item.title }}</li>
				<li v-for="(x, y) in items.count(2)">{{ item.title }}</li>
			</ul>
		</template>
	"""

simpleTest "Skip everything that's not inside the <template> tag",
	input: '<template>An {{ "something-#{val}" }} info</template><script :x="fn 3">{{fn 9}}</script>'
	expected: """<template>An {{ "something-".concat(val) }} info</template><script :x="fn 3">{{fn 9}}</script>"""

# coverage completeness tests

simpleTest 'Skip empty html',
	input: ""
	expected: ""

simpleTest 'Skip empty attributes',
	input: """<template><div :x=""></div></template>"""
	expected: """<template><div :x=""></div></template>"""

simpleTest 'Skip unrecognized v-for format',
	input: """<template><div v-for="a b c"></div></template>"""
	expected: """<template><div v-for="a b c"></div></template>"""

simpleTest 'Unwrap object literals',
	input: """<template><div :x="a: 1, b: 2"></div></template>"""
	expected: """<template><div :x="{ a: 1, b: 2 }"></div></template>"""
