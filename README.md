
# coffee-in-vue-templates-loader

| Use coffeescript in vue templates as attributes or interpolations.

This is a webpack-loader.

Example usage:
```vue
<template lang="pug">
	div(:class="active: i is 2" @click="fn item, something: yes") {{ $t 'buttons.ok' }}
</template>
```

This would get transpiled to:
```vue
<template>
	<div :class="{ active: i === 2 }" @click="fn(item, { something: true })">{{ $t('buttons.ok') }}</div>
</template>
```

For example to use with `pug`, put the following in `nuxt.config.coffee`:
```coffee
[...]
	build:
		extend: (config, ctx) ->
			config.module.rules.push
				test: /\.pug$/
				use: ['coffee-in-vue-templates-loader', 'pug-plain-loader']
```
