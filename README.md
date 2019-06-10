
# coffee-in-vue-templates-loader [CIVTL]

| Webpack-loader to use coffeescript in vue templates as attributes or interpolations.

- [Installation](#installation)
- [Example usage](#example-usage)
- [Webpack configuration](#webpack-configuration)
  - [Nuxt](#nuxt)

## Installation

```sh
yarn add --dev coffee-in-vue-templates-loader
```

## Example usage

### Example usage with `pug` (as intended):
```vue
<template lang="pug">
	div(:class="active: i is 2" @click="fn item, something: yes") {{ $t 'buttons.ok' }}
</template>
```

### Same example with just html:
```vue
<template>
	<div :class="active: i is 2" @click="fn item, something: yes">{{ $t 'buttons.ok' }}</div>
</template>
```

### Both would get transpiled to:
```vue
<template>
	<div :class="{ active: i === 2 }" @click="fn(item, { something: true })">{{ $t('buttons.ok') }}</div>
</template>
```

## Webpack configuration

### With `nuxt`

For example to use with `pug`, put the following in `nuxt.config.coffee`:
```coffee
[...]
	build:
		extend: (config, ctx) ->
			config.module.rules.push
				test: /\.pug$/
				use: ['coffee-in-vue-templates-loader', 'pug-plain-loader']
```
